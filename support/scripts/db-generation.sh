#!/bin/bash

echo "===== EG SURVEILR DB GENERATION ====="

# -------------------------------------------------
# Strict error handling with visibility
# -------------------------------------------------
set -Eeuo pipefail
trap 'echo "Error at line $LINENO"; exit 1' ERR

# -------------------------------------------------
# Paths
# -------------------------------------------------
APP_DIR="${APP_DIR:-/app}"
RSSD_DIR="${RSSD_DIR:-/rssd}"
LOG_DIR="$RSSD_DIR/logs"

export DENO_DIR="$HOME/.deno"

# -------------------------------------------------
# Required ENV validation
# -------------------------------------------------
: "${EG_SURVEILR_COM_IMAP_FOLDER:?Missing IMAP folder}"
: "${EG_SURVEILR_COM_IMAP_USER_NAME:?Missing IMAP username}"
: "${EG_SURVEILR_COM_IMAP_PASS:?Missing IMAP password}"
: "${EG_SURVEILR_COM_IMAP_HOST:?Missing IMAP host}"

# -------------------------------------------------
# 1. Create base directories
# -------------------------------------------------
echo "Creating base directories..."
rm -rf "$APP_DIR" "$RSSD_DIR"
mkdir -p "$APP_DIR" "$LOG_DIR"

# -------------------------------------------------
# 2. Clone repository (shallow clone for CI)
# -------------------------------------------------
echo "Cloning www.surveilr.com..."
cd "$APP_DIR"
git clone --depth 1 https://github.com/surveilr/www.surveilr.com.git

# -------------------------------------------------
# 3. Create provenance & index
# -------------------------------------------------
echo "Creating RSSD metadata..."

echo -e "git_repo\tfull_clone_url" > "$RSSD_DIR/provenance.tsv"
echo -e "git_repo\thttps://github.com/surveilr/www.surveilr.com.git" >> "$RSSD_DIR/provenance.tsv"

echo -e "expose_endpoint\trelative_path\trssd_name\tport\tpackage_sql" > "$RSSD_DIR/index.tsv"

# -------------------------------------------------
# 4. Run prepare scripts
# -------------------------------------------------
echo "Running prepare scripts..."

PREPARE_PATHS=$(find "$APP_DIR/www.surveilr.com" -type f -name 'eg.surveilr.com-prepare.ts' -exec dirname {} \;)

if [ -z "$PREPARE_PATHS" ]; then
  echo "No prepare scripts found"
  exit 1
fi

for path in $PREPARE_PATHS; do
  relative_path="${path#$APP_DIR/www.surveilr.com/}"
  rssd_name="$(echo "$relative_path" | tr '/' '-').sqlite.db"
  basename_path="$(basename "$relative_path")"

  cd "$path"

  if [ "$basename_path" = "content-assembler" ] && [ "${CI:-}" = "true" ]; then
    echo "Skipping content-assembler in CI"
    continue
  fi

  if [ "$basename_path" = "site-quality-explorer" ]; then
    deno run -A ./eg.surveilr.com-prepare.ts \
      resourceName=surveilr.com \
      rssdPath="$RSSD_DIR/$rssd_name" \
      | tee "$LOG_DIR/$rssd_name.log"
  else
    deno run -A ./eg.surveilr.com-prepare.ts \
      rssdPath="$RSSD_DIR/$rssd_name" \
      | tee "$LOG_DIR/$rssd_name.log"
  fi
done

# -------------------------------------------------
# 5. Run final scripts
# -------------------------------------------------
echo "Running final scripts..."

FINAL_PATHS=$(find "$APP_DIR/www.surveilr.com" -type f -name 'eg.surveilr.com-final.ts' -exec dirname {} \;)

if [ -n "$FINAL_PATHS" ]; then
  for path in $FINAL_PATHS; do
    if [ "$(basename "$path")" = "direct-messaging-service" ]; then
      cd "$path"
      deno run -A ./eg.surveilr.com-final.ts \
        destFolder="$RSSD_DIR/" \
        | tee "$LOG_DIR/direct-messaging-service-final.log"
    fi
  done
fi

# -------------------------------------------------
# 6. Run package.sql.ts scripts
# -------------------------------------------------
echo "Running package.sql.ts scripts..."

PACKAGE_PATHS=$(find "$APP_DIR/www.surveilr.com" -type f -name 'package.sql.ts' -exec dirname {} \;)

if [ -z "$PACKAGE_PATHS" ]; then
  echo "No package.sql.ts scripts found"
  exit 1
fi

port=9000

for path in $PACKAGE_PATHS; do
  relative_path="${path#$APP_DIR/www.surveilr.com/}"
  rssd_name="$(echo "$relative_path" | tr '/' '-').sqlite.db"

  cd "$path"

  surveilr shell ./package.sql.ts -d "$RSSD_DIR/$rssd_name" \
    | tee -a "$LOG_DIR/$rssd_name.log"

  echo -e "1\t$relative_path\t$rssd_name\t$port\t$relative_path/package.sql.ts" \
    >> "$RSSD_DIR/index.tsv"

  port=$((port + 1))
done

# -------------------------------------------------
# 7. Copy qualityfolio package.sql
# -------------------------------------------------
echo "Copying qualityfolio package.sql..."

mkdir -p "$RSSD_DIR/lib/service/qualityfolio"
find "$APP_DIR/www.surveilr.com/lib/service/qualityfolio" \
  -type f -name "package.sql" \
  -exec cp {} "$RSSD_DIR/lib/service/qualityfolio/" \;

echo "SURVEILR PIPELINE COMPLETED SUCCESSFULLY"
