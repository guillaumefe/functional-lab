// server.js
const express = require('express');
const path = require('path');

const app = express();
const PORT = 3000;

// Middleware pour servir les fichiers statiques (index.html, CSS, etc.)
app.use(express.static(path.join(__dirname, '/')));

// Middleware pour parser les requêtes JSON
app.use(express.json());

// Endpoint pour traiter la soumission du formulaire
app.post('/search', (req, res) => {
  const userInput = req.body.userInput;

  // Simuler une réponse sans exécuter de requête SQL réelle
  if (userInput.trim() === '') {
    res.json({ success: false, message: 'Veuillez entrer un nom d\'utilisateur valide.' });
  } else {
    res.json({ success: true, message: `Résultats pour l'utilisateur : ${userInput}` });
  }
});

// Démarrage du serveur
app.listen(PORT, () => {
  console.log(`Serveur en cours d'exécution sur le port ${PORT}`);
  console.log(`Ouvrez http://localhost:${PORT}/ dans votre navigateur pour accéder à l'application.`);
});

