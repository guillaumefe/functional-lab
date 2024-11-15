# Utilise l'image officielle de Node.js (version 14 LTS)
FROM node:14

# Définition du répertoire de travail dans le conteneur
WORKDIR /usr/src/app

# Copie les fichiers package.json et package-lock.json (si présent)
COPY package*.json ./

# Installation des dépendances
RUN npm install

# Copie tous les fichiers de l'application
COPY . .

# Expose le port sur lequel l'application écoute
EXPOSE 3000

# Commande pour lancer l'application
CMD [ "npm", "start" ]

