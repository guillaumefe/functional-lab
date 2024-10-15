#!/bin/bash

# Vérification des privilèges root
if [ "$EUID" -ne 0 ]; then
  echo "Veuillez exécuter ce script avec les privilèges root."
  exit 1
fi

# Vérification de l'OS
OS="$(uname)"
if [[ "$OS" != "Linux" && "$OS" != "Darwin" ]]; then
  echo "Ce script est compatible uniquement avec Linux ou macOS."
  exit 1
fi

# Installation de Docker et Docker Compose si nécessaire
if ! command -v docker &> /dev/null; then
  echo "Docker n'est pas installé. Installation en cours..."
  if [[ "$OS" == "Linux" ]]; then
    apt-get update
    apt-get install -y docker.io
  elif [[ "$OS" == "Darwin" ]]; then
    echo "Veuillez installer Docker Desktop pour Mac manuellement."
    exit 1
  fi
fi

if ! command -v docker-compose &> /dev/null; then
  echo "Docker Compose n'est pas installé. Installation en cours..."
  if [[ "$OS" == "Linux" ]]; then
    apt-get install -y docker-compose
  elif [[ "$OS" == "Darwin" ]]; then
    echo "Docker Compose est inclus avec Docker Desktop pour Mac."
  fi
fi

# Vérification de jq
if ! command -v jq &> /dev/null; then
  echo "jq n'est pas installé. Installation en cours..."
  if [[ "$OS" == "Linux" ]]; then
    apt-get install -y jq
  elif [[ "$OS" == "Darwin" ]]; then
    brew install jq
  fi
fi

# Donner les permissions nécessaires
chmod +x generate-compose.sh

# Génération des fichiers docker-compose.yml et index.html
./generate-compose.sh

# Construction et démarrage des conteneurs
docker-compose up -d --build

# Servir la page index.html via un serveur web simple
if ! command -v python3 &> /dev/null; then
  echo "Python3 n'est pas installé. Installation en cours..."
  if [[ "$OS" == "Linux" ]]; then
    apt-get install -y python3
  elif [[ "$OS" == "Darwin" ]]; then
    brew install python
  fi
fi

# Démarrage du serveur web
echo "Démarrage du serveur web pour servir index.html sur le port 8080..."
cd "$(dirname "$0")"
python3 -m http.server 8080 &

echo "Installation terminée !"
echo "Accédez à la page d'index via http://localhost:8080/index.html"
