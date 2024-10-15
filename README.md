## **Guide d'Installation pour les Démonstrations des Vulnérabilités OWASP Top 10**

Ce document Markdown fournit des instructions sur la configuration d'un serveur hébergeant des démonstrations pour les vulnérabilités OWASP Top 10 2021 en utilisant Docker. La configuration est automatisée via des scripts pour faciliter la mise en place par les utilisateurs avec un effort minimal.

### **Table des Matières**

- [Prérequis](#prérequis)
- [Structure du Projet](#structure-du-projet)
- [Scripts et Fichiers](#scripts-et-fichiers)
- [Étapes d'Installation](#étapes-dinstallation)
- [Utilisation du Serveur](#utilisation-du-serveur)
- [Personnalisation et Extensions](#personnalisation-et-extensions)
- [Dépannage](#dépannage)
- [Conclusion](#conclusion)

### **Prérequis**

Avant de commencer, assurez-vous que votre système dispose des éléments suivants installés :
- Docker (19.03 ou ultérieur)
- Docker Compose (1.25 ou ultérieur)
- Git
- Accès Internet pour télécharger les images Docker nécessaires et les dépendances

### **Structure du Projet**

- **owasp-top10-vulnerabilities/** : Racine du projet
  - **A01_Broken_Access_Control/** : Catégorie pour la vulnérabilité de contrôle d'accès cassé
    - **app1/** : Première application démontrant cette vulnérabilité
      - `Dockerfile` : Instructions pour Docker
      - `app-info.json` : Informations sur l'application
      - *(autres fichiers spécifiques à l'application)*
    - **app2/** : Deuxième application démontrant cette vulnérabilité
      - `Dockerfile`
      - `app-info.json`
      - *(autres fichiers spécifiques à l'application)*
  - **A02_Cryptographic_Failures/** : Catégorie pour les échecs cryptographiques
    - **app1/** : Application démontrant cette vulnérabilité
      - `Dockerfile`
      - `app-info.json`
      - *(autres fichiers spécifiques à l'application)*
  - *(autres catégories des vulnérabilités OWASP)*
  - `generate-compose.sh` : Script pour générer docker-compose.yml et index.html
  - `setup.sh` : Script pour configurer et démarrer le projet
  - `docker-compose.template.yml` : Modèle pour Docker Compose
  - `index.template.html` : Modèle pour la page d'index
  - `README.md` : Document expliquant comment configurer et utiliser le projet

### **Scripts et Fichiers**

- **setup.sh** : Script principal pour automatiser l'installation et le déploiement.
- **generate-compose.sh** : Génère `docker-compose.yml` et `index.html`.
- **docker-compose.template.yml** : Modèle pour la configuration Docker Compose.
- **index.template.html** : Modèle pour la page d'index listant les vulnérabilités.

### **Étapes d'Installation**

1. **Cloner le Dépôt**
   ```bash
   git clone https://your-repository-url/owasp-top10-vulnerabilities.git
   cd owasp-top10-vulnerabilities
   ```

2. **Rendre le Script Exécutable**
   ```bash
   chmod +x setup.sh
   ```

3. **Exécuter le Script d'Installation**
   ```bash
   ./setup.sh
   ```

Ce script vérifiera la présence de Docker et Docker Compose, les installera s'ils sont manquants, générera les fichiers nécessaires, construira les images Docker et démarrera les conteneurs.

### **Utilisation du Serveur**

- **Accéder à la Page d'Index** : Naviguez à `http://localhost:8080/index.html` pour voir la liste des vulnérabilités.
- **Interagir avec les Démonstrations** : Cliquez sur "Accéder à la démonstration" pour des vulnérabilités spécifiques.

### **Personnalisation et Extensions**

- **Ajout de Nouvelles Applications** : Placez-les dans le répertoire de catégorie approprié avec les Dockerfiles et `app-info.json` nécessaires.
- **Modification des Modèles** : Changez `index.template.html` ou `docker-compose.template.yml` selon les besoins.

### **Dépannage**

- **Problèmes Courants** : Conflits de ports, permissions Docker, problèmes de réseau.
- **Logs et Statut** : Utilisez `docker-compose logs` et `docker-compose ps` pour vérifier le statut et les logs des conteneurs.
