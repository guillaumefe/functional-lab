# Utilisation de l'image officielle de Node.js (version 14 LTS)
FROM node:14

# Répertoire de travail dans le conteneur
WORKDIR /usr/src/app

# Copier les fichiers package.json et package-lock.json
COPY package*.json ./

# Installation des dépendances
RUN npm install

# Copier tous les fichiers de l'application
COPY . .

# Exposer le port sur lequel l'application écoute
EXPOSE 3000

# Commande pour démarrer l'application
CMD [ "npm", "start" ]

