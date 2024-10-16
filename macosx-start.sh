#!/bin/bash

# Définir les chemins des fichiers templates et de sortie
TEMPLATE_COMPOSE_FILE="./docker-compose.template.yml"
OUTPUT_COMPOSE_FILE="docker-compose.yml"
TEMPLATE_INDEX_FILE="./index.template.html"
OUTPUT_INDEX_FILE="index.html"

# Vérifier que les fichiers templates existent avant de continuer
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

# Fonction pour trouver les répertoires contenant 'app-info.json'
find_app_dirs() {
    find . -mindepth 2 -type f -name "app-info.json"
}

# Fonction pour vérifier si un port est disponible
is_port_available() {
    local port=$1
    if ! lsof -i :"$port" >/dev/null; then
        return 0  # Le port est disponible
    else
        return 1  # Le port est occupé
    fi
}

# Fonction pour trouver le prochain port disponible à partir de START_PORT
find_next_available_port() {
    local port=$START_PORT
    while ! is_port_available "$port"; do
        port=$((port + 1))
    done
    echo "$port"
}

# Compteur de fichiers
file_count=0

# Traitement de chaque fichier 'app-info.json'
while IFS= read -r app_info_file; do
    file_count=$((file_count + 1))
    APP_DIR=$(dirname "$app_info_file")
    APP_NAME=$(basename "$APP_DIR")
    CATEGORY_DIR=$(dirname "$APP_DIR")
    CATEGORY_NAME=$(basename "$CATEGORY_DIR")

    # Vérifier si le fichier app-info.json est vide ou malformé
    if [ ! -s "${app_info_file}" ]; then
        echo "Avertissement: Le fichier app-info.json est vide dans ${APP_DIR}. L'application ${APP_NAME} sera ignorée."
        continue
    fi

    # Lire les informations depuis le fichier app-info.json et vérifier la validité JSON
    if ! TITLE=$(jq -r '.title' "${app_info_file}" 2>/dev/null) || [ -z "$TITLE" ] || [ "$TITLE" = "null" ]; then
        echo "Avertissement: Titre manquant ou mal formé dans ${APP_DIR}/app-info.json. L'application ${APP_NAME} sera ignorée."
        continue
    fi

    if ! DESCRIPTION=$(jq -r '.description' "${app_info_file}" 2>/dev/null) || [ -z "$DESCRIPTION" ] || [ "$DESCRIPTION" = "null" ]; then
        echo "Avertissement: Description manquante ou mal formée dans ${APP_DIR}/app-info.json. L'application ${APP_NAME} sera ignorée."
        continue
    fi

    if ! CATEGORY=$(jq -r '.category' "${app_info_file}" 2>/dev/null) || [ -z "$CATEGORY" ] || [ "$CATEGORY" = "null" ]; then
        echo "Avertissement: Catégorie manquante ou mal formée dans ${APP_DIR}/app-info.json. L'application ${APP_NAME} sera ignorée."
        continue
    fi

    # Vérifier si un Dockerfile est présent et non vide dans le dossier de l'application
    if [ -f "${APP_DIR}/Dockerfile" ]; then
        if [ ! -s "${APP_DIR}/Dockerfile" ]; then
            echo "Avertissement: Dockerfile vide dans ${APP_DIR}. L'application ${APP_NAME} sera ignorée."
            continue
        fi

        # Trouver un port disponible pour l'application
        PORT=$(find_next_available_port)

        # Ajouter la configuration de service Docker pour cette application
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
    else
        echo "Avertissement: Dockerfile manquant dans ${APP_DIR}. L'application ${APP_NAME} sera ignorée."
        continue
    fi

    # Ajouter l'entrée pour index.html
    INDEX_ENTRY="{
        id: '${APP_NAME}',
        category: '${CATEGORY}',
        title: \"${TITLE}\",
        description: \"${DESCRIPTION}\",
        port: ${PORT}
    },"
    VULNERABILITIES_DATA="${VULNERABILITIES_DATA}${INDEX_ENTRY}"

    START_PORT=$((PORT + 1))
done < <(find_app_dirs)

# Terminer le tableau JavaScript pour les données des vulnérabilités
VULNERABILITIES_DATA="${VULNERABILITIES_DATA%?}
];" # Retire la dernière virgule avant de fermer le tableau

# Génération de fichiers seulement si des services valides ont été trouvés
if [ "$VALID_SERVICE_FOUND" = true ]; then
    # Créer des fichiers temporaires pour les services et les données de vulnérabilités
    echo "$SERVICES" > services.tmp
    echo "$VULNERABILITIES_DATA" > vulnerabilities.tmp

    # Remplacer le placeholder {{SERVICES}} dans le template docker-compose
    sed "/{{SERVICES}}/ {
        r services.tmp
        d
    }" "$TEMPLATE_COMPOSE_FILE" > "$OUTPUT_COMPOSE_FILE"
    echo "docker-compose.yml généré avec succès."

    # Remplacer le placeholder {{VULNERABILITIES_DATA}} dans le template index.html
    sed "/{{VULNERABILITIES_DATA}}/ {
        r vulnerabilities.tmp
        d
    }" "$TEMPLATE_INDEX_FILE" > "$OUTPUT_INDEX_FILE"
    echo "index.html généré avec succès."

    # Supprimer les fichiers temporaires après utilisation
    rm services.tmp vulnerabilities.tmp

    # Démarrer les conteneurs avec Docker Compose
    docker-compose up -d --build
    echo "Les conteneurs Docker ont été démarrés avec succès."

    # Démarrer un serveur web pour servir index.html sur un port élevé (non root)
    PORT=8000
    echo "Démarrage du serveur web pour servir index.html sur le port ${PORT}..."
    cd "$(dirname "$0")" && python3 -m http.server ${PORT}
    echo "Accédez à la page d'index via http://localhost:${PORT}/index.html"
else
    echo "Aucun service valide trouvé (aucun Dockerfile détecté ou les Dockerfiles étaient vides, ou les app-info.json étaient absents, vides ou mal formés). Aucun fichier docker-compose.yml généré."
fi
