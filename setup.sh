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
    apt-get update && apt-get install -y docker.io || { echo "L'installation de Docker a échoué"; exit 1; }
  elif [[ "$OS" == "Darwin" ]]; then
    echo "Veuillez installer Docker Desktop pour Mac depuis https://docs.docker.com/docker-for-mac/install/"
    exit 1
  fi
fi

if ! command -v docker-compose &> /dev/null; then
  echo "Docker Compose n'est pas installé. Installation en cours..."
  if [[ "$OS" == "Linux" ]]; then
    apt-get install -y docker-compose || { echo "L'installation de Docker Compose a échoué"; exit 1; }
  elif [[ "$OS" == "Darwin" ]]; then
    echo "Docker Compose est inclus avec Docker Desktop pour Mac."
  fi
fi

# Vérification de jq
if ! command -v jq &> /dev/null; then
  echo "jq n'est pas installé. Installation en cours..."
  if [[ "$OS" == "Linux" ]]; then
    apt-get install -y jq || { echo "L'installation de jq a échoué"; exit 1; }
  elif [[ "$OS" == "Darwin" ]]; then
    brew install jq || { echo "L'installation de jq a échoué"; exit 1; }
  fi
fi

# Donner les permissions nécessaires
chmod +x generate-compose.sh

# Génération des fichiers docker-compose.yml et index.html
./generate-compose.sh || { echo "Échec de la génération des fichiers"; exit 1; }

# Construction et démarrage des conteneurs
docker-compose up -d --build || { echo "Échec du démarrage des conteneurs"; exit 1; }

# Installation et démarrage du serveur web
if ! command -v python3 &> /dev/null; then
  echo "Python3 n'est pas installé. Installation en cours..."
  if [[ "$OS" == "Linux" ]]; then
    apt-get install -y python3 || { echo "L'installation de Python3 a échoué"; exit 1; }
  elif [[ "$OS" == "Darwin" ]]; then
    brew install python || { echo "L'installation de Python a échoué"; exit 1; }
  fi
fi

# Vérification de la disponibilité du port 8080
if lsof -i:8080 >/dev/null; then
  echo "Le port 8080 est déjà utilisé. Choisissez un autre port."
  exit 1
fi

echo "Démarrage du serveur web pour servir index.html sur le port 8080..."
cd "$(dirname "$0")"
python3 -m http.server 8080 &

echo "Installation terminée !"
echo "Accédez à la page d'index via http://localhost:8080/index.html"
