#!/bin/bash

# Vérification de la présence des commandes nécessaires
command -v jq >/dev/null 2>&1 || { echo >&2 "jq est requis mais non installé.  Abandon."; exit 1; }
command -v find >/dev/null 2>&1 || { echo >&2 "find est requis mais non installé.  Abandon."; exit 1; }

TEMPLATE_COMPOSE_FILE="docker-compose.template.yml"
OUTPUT_COMPOSE_FILE="docker-compose.yml"
TEMPLATE_INDEX_FILE="index.template.html"
OUTPUT_INDEX_FILE="index.html"
START_PORT=3000
SERVICES=""
PORT=$START_PORT

VULNERABILITIES_DATA="const vulnerabilities = ["

# Fonction pour trouver les répertoires d'application
find_app_dirs() {
    find . -type f -name "app-info.json"
}

# Boucle pour traiter chaque fichier app-info.json trouvé
while IFS= read -r app_info_file; do
    APP_DIR=$(dirname "$app_info_file")
    APP_NAME=$(basename "$APP_DIR")
    CATEGORY_DIR=$(dirname "$APP_DIR")
    CATEGORY_NAME=$(basename "$CATEGORY_DIR")

    if [ -f "${app_info_file}" ]; then
        TITLE=$(jq -r '.title' "${app_info_file}")
        DESCRIPTION=$(jq -r '.description' "${app_info_file}")
        if [ $? -ne 0 ]; then
            echo "Erreur lors de l'extraction des données avec jq pour $app_info_file"
            continue
        fi
    else
        echo "Le fichier app-info.json est manquant dans ${APP_DIR}"
        continue
    fi

    # Vérifie si le port est disponible (simplifié ici, nécessite une implémentation réelle)
    # Exemple : netstat -tuln | grep ":$PORT " > /dev/null && PORT=$((PORT + 1)) && continue

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

# Génération de docker-compose.yml
if ! sed "s|{{SERVICES}}|${SERVICES}|g" $TEMPLATE_COMPOSE_FILE > $OUTPUT_COMPOSE_FILE; then
    echo "Erreur lors de la génération de docker-compose.yml"
    exit 1
fi
echo "docker-compose.yml généré avec succès."

# Génération de index.html
if ! sed "s|{{VULNERABILITIES_DATA}}|${VULNERABILITIES_DATA}|g" $TEMPLATE_INDEX_FILE > $OUTPUT_INDEX_FILE; then
    echo "Erreur lors de la génération de index.html"
    exit 1
fi
echo "index.html généré avec succès."
