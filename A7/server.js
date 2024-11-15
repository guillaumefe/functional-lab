// server.js
const express = require('express');
const jwt = require('jsonwebtoken');
const app = express();
const path = require('path');

// Clé secrète pour signer les tokens JWT (en production, stockez-la de manière sécurisée)
const SECRET_KEY = 'votre_clé_secrète';

app.use(express.json());

// Servir les fichiers statiques (y compris index.html)
app.use(express.static(path.join(__dirname, '/')));

// Base de données simulée des utilisateurs
const users = {
  'utilisateur1': 'motdepasse123',
  'utilisateur2': 'password456'
};

// Route de connexion
app.post('/login', (req, res) => {
  const { username, password } = req.body;

  // Vérifier si l'utilisateur existe et si le mot de passe est correct
  if (users[username] && users[username] === password) {
    // Générer un token JWT
    const token = jwt.sign({ username }, SECRET_KEY, { expiresIn: '1h' });
    res.status(200).json({ success: true, token });
  } else {
    // Gestion des erreurs HTTP distinctes (vulnérable)
    if (users[username]) {
      // Nom d'utilisateur correct, mot de passe incorrect
      res.status(401).json({ success: false, message: 'Mot de passe incorrect.' });
    } else {
      // Nom d'utilisateur incorrect
      res.status(403).json({ success: false, message: 'Nom d\'utilisateur inexistant.' });
    }
  }
});

// Middleware pour vérifier le token JWT
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    // Token manquant
    return res.status(401).json({ success: false, message: 'Token manquant.' });
  }

  jwt.verify(token, SECRET_KEY, (err, user) => {
    if (err) {
      // Token invalide ou expiré
      return res.status(403).json({ success: false, message: 'Token invalide ou expiré.' });
    }
    req.user = user;
    next();
  });
}

// Route protégée
app.get('/protected', authenticateToken, (req, res) => {
  res.status(200).json({ success: true, message: `Bienvenue, ${req.user.username}! Ceci est une section protégée.` });
});

// Démarrage du serveur
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Serveur en cours d'exécution sur le port ${PORT}`);
  console.log(`Ouvrez http://localhost:${PORT}/ dans votre navigateur pour accéder à l'application.`);
});

