# Stage 1: Build and Preparation
FROM debian:latest AS builder

# Install necessary build tools and dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    bash \
    unzip \
    file

# Install Deno
RUN curl -fsSL https://deno.land/x/install/install.sh | sh && \
    mv /root/.deno/bin/deno /usr/local/bin/deno

# Install surveilr using the provided script
WORKDIR /usr/local/bin
RUN curl -sL https://raw.githubusercontent.com/opsfolio/releases.opsfolio.com/main/surveilr/install.sh | bash

# Clone the www.surveilr.com repository
WORKDIR /app
RUN git clone https://github.com/surveilr/www.surveilr.com.git

# Create a provenance file with the Git clone URL in /rssd/provenance.tsv
RUN mkdir -p /rssd && \
    echo "git_repo\tfull_clone_url" > /rssd/provenance.tsv && \
    echo "git_repo\thttps://github.com/surveilr/www.surveilr.com.git" >> /rssd/provenance.tsv

# Create an index tsv file with a header for RSSDs
RUN /bin/bash -c 'echo -e "expose_endpoint\trelative_path\trssd_name\tport\tpackage_sql" > /rssd/index.tsv'
# Find directories containing `package.sql.ts`, build RSSDs, save in /rssd, and update index file with port number
RUN /bin/bash -c "RSSD_SRC_PATH=(\$(find /app/www.surveilr.com -type f -name 'package.sql.ts' -exec dirname {} \;)) && \
    port=9000 && \
    for path in \"\${RSSD_SRC_PATH[@]}\"; do \
      # Convert path to a format suitable for the RSSD filename and get package_sql
      relative_path=\$(echo \"\$path\" | sed 's#/app/www.surveilr.com/##; s/-//g'); \
      rssd_name=\$(echo \"\$relative_path\" | sed 's#/#-#g').sqlite.db; \
      package_sql=\"\${relative_path}/package.sql.ts\"; \
      cd \"\$path\" && \
      mkdir -p /rssd/logs && \
      surveilr shell ./package.sql.ts -d /rssd/\$rssd_name > /rssd/logs/\$rssd_name.log 2>&1 && \
      # Set expose_endpoint to 1 by default
      echo -e \"1\t\${relative_path}\t\${rssd_name}\t\${port}\t\${package_sql}\" >> /rssd/index.tsv; \
      port=\$((port+1)); \
    done"

# Stage 2: Final Runtime Image
FROM debian:latest AS final

# Install essential runtime dependencies (including Nginx)
RUN apt-get update && apt-get install -y \
    curl && \
    apt-get install -y nginx findutils && \
    rm -rf /var/lib/apt/lists/*

# Copy surveilr binary from builder stage
COPY --from=builder /usr/local/bin/surveilr /usr/local/bin/surveilr

# Copy prepared RSSDs, index file, and provenance file from builder stage
COPY --from=builder /rssd /rssd

# Expose the /rssd directory for external access and debugging
VOLUME /rssd

# Create the script for generating /rssd/index.html
RUN echo '#!/bin/bash\n\
\n\
# Set output file for the generated HTML index\n\
output_file="/rssd/index.html"\n\
\n\
# Extract the repository URL from the provenance file and add to HTML header\n\
repo_url=$(awk -F"\t" "NR==2 {print \$2}" /rssd/provenance.tsv)\n\
echo "<h1>RSSDs in ${repo_url}</h1><ul>" > "$output_file"\n\
\n\
# Process each line in the index file, starting from the second line\n\
tail -n +2 /rssd/index.tsv | while IFS=$'"'"'\t'"'"' read -r expose_endpoint relative_path rssd_name port package_sql; do\n\
  full_path="/${relative_path}"\n\
\n\
  if [ "$expose_endpoint" = "1" ]; then\n\
    # Add exposed endpoint links to the HTML\n\
    echo "<li><a href=\"${full_path}\">${package_sql}</a></li>" >> "$output_file"\n\
  else\n\
    # Add non-exposed RSSDs to the HTML\n\
    echo "<li>${package_sql} (not exposed)</li>" >> "$output_file"\n\
  fi\n\
done\n\
\n\
# Close the HTML unordered list\n\
echo "</ul>" >> "$output_file"' > /generate_rssd_index.sh

# Make the script executable
RUN chmod +x /generate_rssd_index.sh

# Write the configure_nginx.sh script
RUN echo '#!/bin/bash' > /configure_nginx.sh && \
    echo 'nginx_conf="/etc/nginx/sites-available/default"' >> /configure_nginx.sh && \
    echo 'echo "server {" > "$nginx_conf"' >> /configure_nginx.sh && \
    echo 'echo "    listen 80;" >> "$nginx_conf"' >> /configure_nginx.sh && \
    echo 'echo "    root /rssd;" >> "$nginx_conf"' >> /configure_nginx.sh && \
    echo 'echo "    location = / {" >> "$nginx_conf"' >> /configure_nginx.sh && \
    echo 'echo "        index index.html;" >> "$nginx_conf"' >> /configure_nginx.sh && \
    echo 'echo "    }" >> "$nginx_conf"' >> /configure_nginx.sh && \
    echo 'tail -n +2 /rssd/index.tsv | while IFS=$'"'\\t'"' read -r expose_endpoint relative_path rssd_name port package_sql; do' >> /configure_nginx.sh && \
    echo '  if [ "$expose_endpoint" = "1" ]; then' >> /configure_nginx.sh && \
    echo '    full_path="/${relative_path}"' >> /configure_nginx.sh && \
    echo '    echo "" >> "$nginx_conf"' >> /configure_nginx.sh && \
    echo '    echo "    location $full_path {" >> "$nginx_conf"' >> /configure_nginx.sh && \
    echo '    echo "       proxy_pass http://localhost:$port;" >> "$nginx_conf"' >> /configure_nginx.sh && \
    echo '    echo "       proxy_set_header Host \$host;" >> "$nginx_conf"' >> /configure_nginx.sh && \
    echo '    echo "       proxy_set_header X-Real-IP \$remote_addr;" >> "$nginx_conf"' >> /configure_nginx.sh && \
    echo '    echo "       proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;" >> "$nginx_conf"' >> /configure_nginx.sh && \
    echo '    echo "       proxy_set_header X-Forwarded-Proto \$scheme;" >> "$nginx_conf"' >> /configure_nginx.sh && \
    echo '    echo "    }" >> "$nginx_conf"' >> /configure_nginx.sh && \
    echo '  fi' >> /configure_nginx.sh && \
    echo 'done' >> /configure_nginx.sh && \
    echo 'echo "}" >> "$nginx_conf"' >> /configure_nginx.sh && \
    chmod +x /configure_nginx.sh

# Execute the script
RUN /configure_nginx.sh

# Expose port 80
EXPOSE 80

# Create the application startup script
RUN echo '#!/bin/bash' > /start_application.sh && \
    echo 'tail -n +2 /rssd/index.tsv | while IFS=$'"'\\t'"' read -r expose_endpoint relative_path rssd_name port package_sql; do' >> /start_application.sh && \
    echo 'sleep 5' >> /start_application.sh && \
    echo '  if [ "$expose_endpoint" = "1" ]; then' >> /start_application.sh && \
    echo '    SQLPAGE_SITE_PREFIX="/${relative_path}" surveilr web-ui -d "/rssd/$rssd_name" --port "${port}" --host 0.0.0.0 >> /rssd/logs/$rssd_name.log 2>&1 &' >> /start_application.sh && \
    echo '  fi' >> /start_application.sh && \
    echo 'done' >> /start_application.sh && \
    echo 'echo "Completed starting up surveilr web-ui services, you can view logs at path=/rssd/logs/ \nStarted Nginx reverse-proxy"' >> /start_application.sh && \
    echo 'nginx -g "daemon off;"' >> /start_application.sh && \
    /bin/bash /generate_rssd_index.sh && \
    chmod +x /start_application.sh

# CMD to run the start_application.sh script
CMD ["/start_application.sh"]
