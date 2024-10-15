#!/bin/bash

TEMPLATE_COMPOSE_FILE="docker-compose.template.yml"
OUTPUT_COMPOSE_FILE="docker-compose.yml"
TEMPLATE_INDEX_FILE="index.template.html"
OUTPUT_INDEX_FILE="index.html"
START_PORT=3000
SERVICES=""
PORT=$START_PORT

VULNERABILITIES_DATA="const vulnerabilities = ["

find_app_dirs() {
    find . -type f -name "app-info.json"
}

while IFS= read -r app_info_file; do
    APP_DIR=$(dirname "$app_info_file")
    APP_NAME=$(basename "$APP_DIR")
    CATEGORY_DIR=$(dirname "$APP_DIR")
    CATEGORY_NAME=$(basename "$CATEGORY_DIR")

    if [ -f "${app_info_file}" ]; then
        TITLE=$(jq -r '.title' "${app_info_file}")
        DESCRIPTION=$(jq -r '.description' "${app_info_file}")
    else
        echo "Le fichier app-info.json est manquant dans ${APP_DIR}"
        continue
    fi

    SERVICE_BLOCK="
  ${APP_NAME}:
    build:
      context: ${APP_DIR}
    ports:
      - \"${PORT}:3000\"
    volumes:
      - ./uploads:/app/uploads
"
    SERVICES="${SERVICES}${SERVICE_BLOCK}"

    INDEX_ENTRY="
    {
        id: '${APP_NAME}',
        category: '${CATEGORY_NAME}',
        title: \"${TITLE}\",
        description: \"${DESCRIPTION}\",
        port: ${PORT}
    },"

    VULNERABILITIES_DATA="${VULNERABILITIES_DATA}${INDEX_ENTRY}"

    PORT=$((PORT + 1))

done < <(find_app_dirs)

VULNERABILITIES_DATA="${VULNERABILITIES_DATA}
];"

sed "s|{{SERVICES}}|${SERVICES}|g" $TEMPLATE_COMPOSE_FILE > $OUTPUT_COMPOSE_FILE
echo "docker-compose.yml généré avec succès."

sed "s|{{VULNERABILITIES_DATA}}|${VULNERABILITIES_DATA}|g" $TEMPLATE_INDEX_FILE > $OUTPUT_INDEX_FILE
echo "index.html généré avec succès."
