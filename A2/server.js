// server.js
const express = require('express');
const path = require('path');

const app = express();
const PORT = 3000;

// Middleware pour servir les fichiers statiques (index.html, CSS, etc.)
app.use(express.static(path.join(__dirname, '/')));

// Middleware pour parser les requêtes JSON
app.use(express.json());

// Endpoint pour traiter la soumission du formulaire de chiffrement
app.post('/encrypt', (req, res) => {
  const plaintext = req.body.plaintext;

  // Simuler le chiffrement (sans utiliser de mode ECB vulnérable)
  if (plaintext.trim() === '') {
    res.json({ success: false, message: 'Veuillez entrer des données à chiffrer.' });
  } else {
    // Simuler le chiffrement en affichant un texte chiffré factice
    const simulatedCiphertext = 'U2FsdGVkX1' + Buffer.from(plaintext).toString('base64').slice(0, 20) + '...';
    res.json({ success: true, ciphertext: simulatedCiphertext });
  }
});

// Démarrage du serveur
app.listen(PORT, () => {
  console.log(`Serveur en cours d'exécution sur le port ${PORT}`);
  console.log(`Ouvrez http://localhost:${PORT}/ dans votre navigateur pour accéder à l'application.`);
});

