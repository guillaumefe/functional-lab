#!/bin/bash

TEMPLATE_COMPOSE_FILE="./docker-compose.template.yml"
OUTPUT_COMPOSE_FILE="docker-compose.yml"
TEMPLATE_INDEX_FILE="./index.template.html"
OUTPUT_INDEX_FILE="index.html"

if [ ! -f "$TEMPLATE_COMPOSE_FILE" ]; then
    echo "Erreur: Le fichier template $TEMPLATE_COMPOSE_FILE est introuvable."
    exit 1
fi

if [ ! -f "$TEMPLATE_INDEX_FILE" ]; then
    echo "Erreur: Le fichier template $TEMPLATE_INDEX_FILE est introuvable."
    exit 1
fi

START_PORT=3000
SERVICES=""
VULNERABILITIES_DATA="const vulnerabilities = ["
VALID_SERVICE_FOUND=false

find_app_dirs() {
    find . -mindepth 2 -type f -name "app-info.json"
}

is_port_available() {
    local port=$1
    if lsof -i :"$port" > /dev/null 2>&1; then
        return 1
    else
        return 0
    fi
}

find_next_available_port() {
    local port=$1
    local max_attempts=1000
    local attempts=0
    
    while [ $attempts -lt $max_attempts ]; do
        if lsof -i :"$port" > /dev/null 2>&1; then
            port=$((port + 1))
            attempts=$((attempts + 1))
        else
            echo "$port"
            return 0
        fi
    done
    
    echo "Erreur: Impossible de trouver un port disponible après $max_attempts tentatives" >&2
    return 1
}

start_python_server() {
    local port=$1
    python3 -m http.server "$port" 2>/dev/null &
    local pid=$!
    sleep 1
    if kill -0 $pid 2>/dev/null; then
        echo "Serveur web démarré sur le port $port"
        echo "Accédez à la page d'index via http://localhost:${port}/index.html"
        wait $pid
    else
        return 1
    fi
}

file_count=0

while IFS= read -r app_info_file; do
    file_count=$((file_count + 1))
    APP_DIR=$(dirname "$app_info_file")
    APP_NAME=$(basename "$APP_DIR" | tr '[:upper:]' '[:lower:]')
    CATEGORY_DIR=$(dirname "$APP_DIR")
    CATEGORY_NAME=$(basename "$CATEGORY_DIR")

    if [ ! -s "${app_info_file}" ]; then
        echo "Avertissement: Le fichier app-info.json est vide dans ${APP_DIR}. L'application ${APP_NAME} sera ignorée."
        continue
    fi

    if ! TITLE=$(jq -r '.title' "${app_info_file}" 2>/dev/null) || [ -z "$TITLE" ] || [ "$TITLE" = "null" ]; then
        echo "Avertissement: Titre manquant ou mal formé dans ${APP_DIR}/app-info.json. L'application ${APP_NAME} sera ignorée."
        continue
    fi

    if ! DESCRIPTION=$(jq -r '.description' "${app_info_file}" 2>/dev/null) || [ -z "$DESCRIPTION" ] || [ "$DESCRIPTION" = "null" ]; then
        echo "Avertissement: Description manquante ou mal formée dans ${APP_DIR}/app-info.json. L'application ${APP_NAME} sera ignorée."
        continue
    fi

    if [ -f "${APP_DIR}/Dockerfile" ]; then
        if [ ! -s "${APP_DIR}/Dockerfile" ]; then
            echo "Avertissement: Dockerfile vide dans ${APP_DIR}. L'application ${APP_NAME} sera ignorée."
            continue
        fi

        PORT=$(find_next_available_port $START_PORT) || exit 1
        
        SERVICE_BLOCK="
  ${APP_NAME}:
    build:
      context: ${APP_DIR}
    ports:
      - \"${PORT}:3000\"
    "
        SERVICES="${SERVICES}${SERVICE_BLOCK}"
        VALID_SERVICE_FOUND=true
        echo "Dockerfile trouvé pour ${APP_NAME}, port attribué : ${PORT}."
        START_PORT=$((PORT + 1))
    else
        echo "Avertissement: Dockerfile manquant dans ${APP_DIR}. L'application ${APP_NAME} sera ignorée."
        continue
    fi

    INDEX_ENTRY="{
        id: '${APP_NAME}',
        category: '${CATEGORY_NAME}',
        title: \"${TITLE}\",
        description: \"${DESCRIPTION}\",
        port: ${PORT}
    },"
    VULNERABILITIES_DATA="${VULNERABILITIES_DATA}${INDEX_ENTRY}"
done < <(find_app_dirs)

VULNERABILITIES_DATA="${VULNERABILITIES_DATA%?}
];"

if [ "$VALID_SERVICE_FOUND" = true ]; then
    echo "$SERVICES" > services.tmp
    echo "$VULNERABILITIES_DATA" > vulnerabilities.tmp

    sed '/^version:/d' "$TEMPLATE_COMPOSE_FILE" > compose.tmp
    sed "/{{SERVICES}}/ {
        r services.tmp
        d
    }" compose.tmp > "$OUTPUT_COMPOSE_FILE"
    rm compose.tmp
    echo "docker-compose.yml généré avec succès."

    sed "/{{VULNERABILITIES_DATA}}/ {
        r vulnerabilities.tmp
        d
    }" "$TEMPLATE_INDEX_FILE" > "$OUTPUT_INDEX_FILE"
    echo "index.html généré avec succès."

    rm services.tmp vulnerabilities.tmp

    if docker-compose up -d --build; then
        echo "Les conteneurs Docker ont été démarrés avec succès."
        
        WEB_PORT=8000
        MAX_PORT=9000
        
        while [ $WEB_PORT -lt $MAX_PORT ]; do
            if start_python_server $WEB_PORT; then
                break
            fi
            echo "Port $WEB_PORT non disponible, essai du port suivant..."
            WEB_PORT=$((WEB_PORT + 1))
        done

        if [ $WEB_PORT -eq $MAX_PORT ]; then
            echo "Erreur: Impossible de trouver un port disponible entre 8000 et $MAX_PORT"
            exit 1
        fi
    else
        echo "Erreur lors du démarrage des conteneurs Docker."
        exit 1
    fi
else
    echo "Aucun service valide trouvé. Aucun fichier docker-compose.yml généré."
fi
