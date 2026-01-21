#!/bin/bash
#set -Eeuo pipefail

# trap '
# echo " ERROR"
# echo "Line    : $LINENO"
# echo "Command : $BASH_COMMAND"
# echo "Path    : $(pwd)"
# exit 1
# ' ERR

# --------------------------------------------------
# Global paths
# --------------------------------------------------
APP_DIR="${APP_DIR:-/app}"
RSSD_DIR="${RSSD_DIR:-/rssd}"
LOG_DIR="$RSSD_DIR/logs"
REPO_DIR="$APP_DIR/www.surveilr.com"

echo "===== SURVEILR PIPELINE STARTED ====="

# --------------------------------------------------
# Validate ENV
# --------------------------------------------------
: "${EG_SURVEILR_COM_IMAP_FOLDER:?Missing IMAP folder}"
: "${EG_SURVEILR_COM_IMAP_USER_NAME:?Missing IMAP username}"
: "${EG_SURVEILR_COM_IMAP_PASS:?Missing IMAP password}"
: "${EG_SURVEILR_COM_IMAP_HOST:?Missing IMAP host}"

# --------------------------------------------------
# Prepare directories (CI SAFE)
# --------------------------------------------------
rm -rf "$APP_DIR" "$RSSD_DIR" "$LOG_DIR"
mkdir -p "$APP_DIR" "$RSSD_DIR" "$LOG_DIR"

# --------------------------------------------------
# Clone repo
# --------------------------------------------------
if [ ! -d "$REPO_DIR/.git" ]; then
  cd "$APP_DIR"
  git clone https://github.com/surveilr/www.surveilr.com.git
fi

# --------------------------------------------------
# index.tsv
# --------------------------------------------------
if [ ! -f "$RSSD_DIR/index.tsv" ]; then
  echo -e "expose_endpoint\trelative_path\trssd_name\tport\tpackage_sql" \
    > "$RSSD_DIR/index.tsv"
fi

# ==================================================
# PREPARE
# ==================================================
mapfile -t PREPARE_PATHS < <(find "$REPO_DIR" -type f -name 'eg.surveilr.com-prepare.ts' -exec dirname {} \;)

for path in "${PREPARE_PATHS[@]}"; do
    relative_path="${path#$REPO_DIR/}"
    rssd_name=$(echo "$relative_path" | sed 's#/#-#g' ).sqlite.db
    basename_path=$(basename "$relative_path")

    echo "→ Prepare: $relative_path"

    cd "$path"

    if [ "$basename_path" == "site-quality-explorer" ]; then
        deno run -A ./eg.surveilr.com-prepare.ts \
            resourceName=surveilr.com \
            rssdPath="$RSSD_DIR/$rssd_name" > "$LOG_DIR/$rssd_name.log" 2>&1

    elif [ "$basename_path" == "content-assembler" ]; then
        cat > .env <<EOF
IMAP_FOLDER=${EG_SURVEILR_COM_IMAP_FOLDER}
IMAP_USER_NAME=${EG_SURVEILR_COM_IMAP_USER_NAME}
IMAP_PASS=${EG_SURVEILR_COM_IMAP_PASS}
IMAP_HOST=${EG_SURVEILR_COM_IMAP_HOST}
EOF
        # We use || { tail ... } to print the error only if Deno fails
        deno run -A ./eg.surveilr.com-prepare.ts \
            rssdPath="$RSSD_DIR/$rssd_name" > "$LOG_DIR/$rssd_name.log" 2>&1 || {
                echo " Deno Content Assembler Failed. Log output:"
                cat "$LOG_DIR/$rssd_name.log"
                true
            }

    else
        deno run -A ./eg.surveilr.com-prepare.ts \
            rssdPath="$RSSD_DIR/$rssd_name" > "$LOG_DIR/$rssd_name.log" 2>&1
    fi
done

# ==================================================
# FINAL
# ==================================================
echo " Running final scripts"

mapfile -t FINAL_PATHS < <(
  find "$REPO_DIR" -name 'eg.surveilr.com-final.ts' -exec dirname {} \;
)

for path in "${FINAL_PATHS[@]}"; do
  if [ "$(basename "$path")" = "direct-messaging-service" ]; then
    cd "$path"
    deno run -A ./eg.surveilr.com-final.ts \
      destFolder="$RSSD_DIR/" \
      > "$LOG_DIR/direct-messaging-final.log" 2>&1
  fi
done

# ==================================================
# PACKAGE.SQL.TS
# ==================================================
echo " Running package.sql.ts"

port=9000

mapfile -t PKG_PATHS < <(
  find "$REPO_DIR" -name 'package.sql.ts' -exec dirname {} \;
)

for path in "${PKG_PATHS[@]}"; do
  relative="${path#$REPO_DIR/}"
  rssd="$(echo "$relative" | tr '/' '-').sqlite.db"

  cd "$path"
  chmod +x package.sql.ts

  surveilr shell ./package.sql.ts \
    -d "$RSSD_DIR/$rssd" \
    >> "$LOG_DIR/$rssd.log" 2>&1

  echo -e "1\t$relative\t$rssd\t$port\t$relative/package.sql.ts" \
    >> "$RSSD_DIR/index.tsv"

  port=$((port + 1))
done

# ==================================================
# QUALITYFOLIO
# ==================================================
mkdir -p "$RSSD_DIR/lib/service/qualityfolio"
cp "$REPO_DIR/lib/service/qualityfolio"/package.sql \
   "$RSSD_DIR/lib/service/qualityfolio/" || true

echo "===== SURVEILR PIPELINE COMPLETED SUCCESSFULLY ====="
