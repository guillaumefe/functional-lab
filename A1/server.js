// server.js
const express = require('express');
const bodyParser = require('body-parser');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = 3000;

// Clé secrète pour signer les JWT (normalement utilisée, mais ignorée si 'none')
const SECRET_KEY = 'votre_clé_secrète_super_sécurisée';

app.use(bodyParser.json());
app.use(express.static(__dirname));

// Endpoint pour traiter la soumission du JWT
app.post('/submit', (req, res) => {
  const token = req.body.token;

  try {
    // Vérification du token sans restreindre les algorithmes acceptés (vulnérabilité)
    const decoded = jwt.verify(token, SECRET_KEY, { algorithms: ['HS256', 'RS256', 'none'] });

    // Accès autorisé si le token est valide
    res.json({ success: true });
  } catch (err) {
    // Accès refusé en cas d'erreur
    res.json({ success: false });
  }
});

app.listen(PORT, () => {
  console.log(`Serveur en cours d'exécution sur le port ${PORT}`);
  console.log(`Ouvrez http://localhost:${PORT}/ dans votre navigateur pour accéder à l'application.`);
});

