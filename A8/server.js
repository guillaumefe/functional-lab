// server.js
const express = require('express');
const app = express();
const path = require('path');

// Middleware pour servir les fichiers statiques (y compris index.html)
app.use(express.static(path.join(__dirname, '/')));

// Démarrage du serveur sur le port 3000
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Serveur CI Backdoor Demo lancé sur le port ${PORT}`);
  console.log(`Ouvrez http://localhost:${PORT}/ dans votre navigateur pour accéder à l'application.`);
});

