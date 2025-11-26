# Dockerfile

# ============================================
# ÉTAPE 1 : Build de l'application React
# ============================================
# Utiliser l'image Node.js version 18 Alpine (légère)
FROM node:18-alpine AS build

# Définir le répertoire de travail dans le container
WORKDIR /app

# Copier les fichiers de dépendances
# On copie d'abord package.json et package-lock.json pour profiter du cache Docker
COPY package*.json ./

# Installer les dépendances
# npm ci est plus rapide et plus fiable que npm install pour la CI/CD
RUN npm ci --silent

# Copier tout le code source de l'application
COPY . .

# Builder l'application React pour la production
# Cela crée un dossier /app/build avec les fichiers optimisés
RUN npm run build

# ============================================
# ÉTAPE 2 : Servir l'application avec Nginx
# ============================================
# Utiliser Nginx Alpine pour servir les fichiers statiques
FROM nginx:alpine

# Copier les fichiers buildés depuis l'étape précédente
# On prend uniquement le dossier /build de l'étape "build"
COPY --from=build /app/build /usr/share/nginx/html

# Copier la configuration Nginx personnalisée (optionnel)
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Exposer le port 80 (port par défaut de Nginx)
EXPOSE 80

# Commande de démarrage de Nginx
# daemon off; permet de garder Nginx en premier plan
CMD ["nginx", "-g", "daemon off;"]

# ============================================
# LABELS pour les métadonnées de l'image
# ============================================
LABEL maintainer="votre-email@example.com"
LABEL description="Todo App React avec CI/CD"
LABEL version="1.0"