# Déploiement d'Applications avec Docker Compose

Ce projet vous permet de détecter, configurer et déployer automatiquement plusieurs applications basées sur JavaScript en utilisant Docker et Docker Compose. Chaque application est placée dans un répertoire dédié et définie par son propre `app-info.json` et `Dockerfile`. Le script de configuration génère un fichier `docker-compose.yml` et un `index.html` qui affiche toutes les applications, organisées par catégories.

## Prérequis

- **Docker** : Assurez-vous que Docker est installé sur votre système. Sinon, téléchargez et installez-le depuis [le site officiel de Docker](https://docs.docker.com/get-docker/).
- **jq** : Ce script nécessite `jq` pour traiter les fichiers JSON. Vous pouvez l'installer avec Homebrew sur macOS :
  ```bash
  brew install jq
  ```
- **Connaissances de Base en Docker et Docker Compose** : Une compréhension de la création de Dockerfile et de Docker Compose est recommandée.

## Structure du Projet

La structure attendue pour vos applications est la suivante :

```plaintext
.
├── docker-compose.template.yml
├── index.template.html
├── app1/
│   ├── Dockerfile
│   ├── app-info.json
│   └── src/
│       └── index.js
├── app2/
│   ├── Dockerfile
│   ├── app-info.json
│   └── src/
│       └── index.js
├── install.sh
└── README.md
```

- **docker-compose.template.yml** : Le template pour générer `docker-compose.yml`.
- **index.template.html** : Le template pour générer l'interface web qui affiche toutes les applications.
- **appX/** : Chaque application doit être dans son propre répertoire et contenir :
  - `Dockerfile` : Définit comment construire et exécuter l'application.
  - `app-info.json` : Contient les métadonnées de l'application (titre, description et catégorie).

## Format de `app-info.json`

Chaque `app-info.json` doit inclure les champs suivants :

```json
{
  "title": "Mon Application",
  "description": "Une brève description de ce que fait cette application.",
  "category": "Sécurité"
}
```

- **title** : Le nom de l'application.
- **description** : Une brève description de la fonctionnalité de l'application.
- **category** : La catégorie sous laquelle l'application doit être regroupée dans l'interface.

## Comment Utiliser

1. **Cloner le dépôt** et naviguer dans le répertoire du projet.

2. **Ajouter Vos Applications** :
   - Créez un nouveau répertoire pour chaque application que vous souhaitez ajouter (par exemple, `app1`, `app2`).
   - Chaque répertoire doit contenir un `Dockerfile` et un `app-info.json` valides comme décrit ci-dessus.

3. **Exécuter le Script d'Installation** :
   - Assurez-vous que le script `install.sh` est exécutable :
     ```bash
     chmod +x install.sh
     ```
   - Exécutez le script :
     ```bash
     ./install.sh
     ```
   - Ce script va :
     - Détecter toutes les applications avec un `app-info.json` et `Dockerfile` valides.
     - Générer `docker-compose.yml` basé sur les applications détectées.
     - Générer un fichier `index.html` qui affiche toutes les applications, organisées par catégories.
     - Démarrer les applications en utilisant Docker Compose.
     - Servir le `index.html` sur un serveur web local.

4. **Accéder à l'Interface Web** :
   - Ouvrez votre navigateur et naviguez vers :
     ```plaintext
     http://localhost:8000/index.html
     ```
   - Vous verrez un aperçu de toutes vos applications, regroupées par catégories. Chaque application aura un bouton pour y accéder et un bouton "Mark" pour suivre votre progression.

5. **Interagir avec l'Interface** :
   - Cliquez sur le bouton "Go to [Nom de l'Application]" pour ouvrir l'application dans un nouvel onglet.
   - Utilisez le bouton "Mark" pour marquer l'application comme "Done" une fois que vous avez complété le challenge. Vous pouvez cliquer à nouveau pour dé-marquer.

## Exemple de Résultat

Si vous avez deux applications (`app1` et `app2`) avec les `app-info.json` suivants :

### app1/app-info.json

```json
{
  "title": "Challenge Injection SQL",
  "description": "Apprenez les vulnérabilités d'injection SQL.",
  "category": "Sécurité"
}
```

### app2/app-info.json

```json
{
  "title": "Challenge Cross-Site Scripting (XSS)",
  "description": "Comprenez les attaques XSS et comment les prévenir.",
  "category": "Sécurité"
}
```

Le fichier généré `index.html` affichera les deux applications sous la catégorie "Sécurité", chacune avec des boutons pour y accéder et marquer les challenges.

## Personnalisation

- **Changer les Titres** :
  - Modifiez `pageTitle` et `sectionTitle` dans `index.template.html` pour changer le titre affiché de la page et l'en-tête de la section.
- **Ajouter de Nouvelles Applications** :
  - Il suffit de créer un nouveau répertoire pour l'application, d'ajouter un `Dockerfile` et `app-info.json` valides, puis de relancer `./install.sh`.

## Dépannage

- **Erreur : `docker-compose.yml` non généré** :
  - Assurez-vous que chaque répertoire d'application contient un `Dockerfile` non vide et un `app-info.json` correctement formaté.
- **Conflits de Ports** :
  - Le script assigne automatiquement les ports à partir de `3000`. Si un port est déjà utilisé, il trouvera le port suivant disponible.
- **Accéder à l'Interface** :
  - Assurez-vous que Docker et le serveur local sont en cours d'exécution. Relancez `./install.sh` si nécessaire.

## Licence

Ce projet est sous licence `GNU General Public License v3.0` - voir le fichier [LICENSE](LICENSE) pour plus de détails.

---
