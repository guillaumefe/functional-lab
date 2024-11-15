// server.js
const express = require('express');
const app = express();
const path = require('path');

// Middleware pour parser les requêtes JSON
app.use(express.json());

// Servir les fichiers statiques (y compris index.html)
app.use(express.static(path.join(__dirname, '/')));

// Route pour le formulaire d'inscription (sans validation côté serveur)
app.post('/register', (req, res) => {
  const { username, email } = req.body;

  // Aucune validation côté serveur (vulnérable)
  // Enregistrer les données (simulation)
  console.log('Données reçues sans validation côté serveur:', { username, email });

  res.json({ success: true, message: 'Inscription réussie !' });
});

// Démarrage du serveur
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Serveur en cours d'exécution sur le port ${PORT}`);
  console.log(`Ouvrez http://localhost:${PORT}/ dans votre navigateur pour accéder à l'application.`);
});

