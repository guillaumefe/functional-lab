// server.js
const express = require('express');
const path = require('path');

const app = express();
const PORT = 3000;

// Middleware pour servir les fichiers statiques
app.use(express.static(path.join(__dirname, '/')));

// Middleware pour parser les requêtes JSON
app.use(express.json());

// Démarrage du serveur
app.listen(PORT, () => {
  console.log(`Serveur en cours d'exécution sur le port ${PORT}`);
  console.log(`Ouvrez http://localhost:${PORT}/ dans votre navigateur pour accéder à l'application.`);
});

