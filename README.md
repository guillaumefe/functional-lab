\`\`\`
## **Setup Guide for OWASP Top 10 Vulnerability Demonstrations**

This Markdown document provides instructions on how to set up a server hosting demonstrations for the OWASP Top 10 2021 vulnerabilities using Docker. The setup is automated through scripts to make it easy for users with minimal effort.

### **Table of Contents**

- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Scripts and Files](#scripts-and-files)
- [Installation Steps](#installation-steps)
- [Using the Server](#using-the-server)
- [Customization and Extensions](#customization-and-extensions)
- [Troubleshooting](#troubleshooting)
- [Conclusion](#conclusion)

### **Prerequisites**

Before you begin, ensure your system has the following installed:
- Docker (19.03 or later)
- Docker Compose (1.25 or later)
- Git
- Internet access for downloading necessary Docker images and dependencies

### **Project Structure**

\`\`\`
owasp-top10-vulnerabilities/
│
├── A01_Broken_Access_Control/
│   ├── app1/
│   │   ├── Dockerfile
│   │   ├── app-info.json
│   │   └── (autres fichiers spécifiques à l'application)
│   └── app2/
│       ├── Dockerfile
│       ├── app-info.json
│       └── (autres fichiers spécifiques à l'application)
│
├── A02_Cryptographic_Failures/
│   ├── app1/
│   │   ├── Dockerfile
│   │   ├── app-info.json
│   │   └── (autres fichiers spécifiques à l'application)
│   └── app2/
│       ├── Dockerfile
│       ├── app-info.json
│       └── (autres fichiers spécifiques à l'application)
│
├── (autres catégories des vulnérabilités OWASP)
│
├── generate-compose.sh
├── setup.sh
├── docker-compose.template.yml
├── index.template.html
└── README.md
\`\`\`

### **Scripts and Files**

- **setup.sh** - Main script to automate the installation and deployment.
- **generate-compose.sh** - Generates \`docker-compose.yml\` and \`index.html\`.
- **docker-compose.template.yml** - Template for Docker Compose configuration.
- **index.template.html** - Template for the index page listing vulnerabilities.

### **Installation Steps**

1. **Clone the Repository**
   \`\`\`bash
   git clone https://your-repository-url/owasp-top10-vulnerabilities.git
   cd owasp-top10-vulnerabilities
   \`\`\`

2. **Make the Script Executable**
   \`\`\`bash
   chmod +x setup.sh
   \`\`\`

3. **Run the Installation Script**
   \`\`\`bash
   ./setup.sh
   \`\`\`

This script will check for Docker and Docker Compose, install them if they are missing, generate necessary files, build Docker images, and start the containers.

### **Using the Server**

- **Access the Index Page**: Navigate to \`http://localhost:8080/index.html\` to view the list of vulnerabilities.
- **Interact with Demonstrations**: Click on "Access Demonstration" for specific vulnerabilities.

### **Customization and Extensions**

- **Adding New Applications**: Place them in the appropriate category directory with necessary Dockerfiles and \`app-info.json\`.
- **Modifying Templates**: Change \`index.template.html\` or \`docker-compose.template.yml\` as needed.

### **Troubleshooting**

- **Common Issues**: Port conflicts, Docker permissions, network issues.
- **Logs and Status**: Use \`docker-compose logs\` and \`docker-compose ps\` to check the status and logs of the containers.

### **Conclusion**

This setup provides a hands-on experience with web vulnerabilities as categorized by OWASP Top 10 2021, facilitating learning and demonstration in a controlled environment. Customize and expand this project to enhance learning or to add new demonstrations.
\`\`\`
