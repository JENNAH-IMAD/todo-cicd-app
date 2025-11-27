# ✅ Todo CI/CD App

Application Todo minimaliste construite avec **React** et livrée automatiquement grâce à une chaîne **Docker + GitHub Actions**.  
Objectif : démontrer un flux complet « dev → test → build → push → (déploiement simulé) ».

---

## 🧱 Stack & fonctionnalités

| Domaine | Technologies | Détails |
| --- | --- | --- |
| Front | React 18, CRA | Liste de tâches simple, tests Jest/RTL |
| Qualité | Jest, react-testing-library | Couverture exportée dans la CI |
| Packaging | Docker multi-stage, docker-compose | Build Node → serve statique via Nginx |
| CI/CD | GitHub Actions (`.github/workflows/ci-cd.yml`) | Jobs Tests → Build → Deploy (mock) |
| Registry | Docker Hub (`bluekayn11/todo-cicd-app`) | Image poussée depuis la CI |

---

## 🚀 Getting Started

### Prérequis
- Node.js 18+
- npm 9+
- Docker & Docker Compose (fortement conseillés)
- Compte Docker Hub + PAT si vous poussez l’image

### 1. Cloner et installer
```bash
git clone https://github.com/<votre-compte>/todo-cicd-app.git
cd todo-cicd-app
npm ci
```

### 2. Lancer en mode développement
```bash
npm start
```
Application disponible sur `http://localhost:3000`.

### 3. Lancer les tests
```bash
npm test -- --watchAll=false
```

### 4. Construire la version production
```bash
npm run build
```

---

## 🐳 Exécuter via Docker

### Build & run directs
```bash
docker build -t todo-cicd-app .
docker run -d -p 3000:80 --name todo-cicd-app todo-cicd-app
```
Visitez `http://localhost:3000`.

### Avec docker-compose
```bash
docker-compose up --build
```
Le fichier `docker-compose.yml` crée le container `todo-cicd-app` et mappe `3000 -> 80`.

---

## 🔁 Pipeline CI/CD (GitHub Actions)

Fichier : `.github/workflows/ci-cd.yml`

1. **Tests**  
   - `npm ci`, `npm test -- --coverage --watchAll=false`  
   - Upload du rapport de couverture (`actions/upload-artifact@v4`)
2. **Build**  
   - Login Docker Hub (`docker/login-action@v2`)  
   - Génération des tags via `docker/metadata-action@v4`  
   - `docker/build-push-action@v4` pour pousser `bluekayn11/todo-cicd-app`
3. **Deploy (simulation)**  
   - Message de réussite + rappel des étapes à adapter (SSH, Kubernetes, etc.)

### Secrets requis
| Clé | Description |
| --- | --- |
| `DOCKER_USERNAME` | Votre identifiant Docker Hub |
| `DOCKER_PASSWORD` | Personal Access Token Docker Hub |

Ajoutez-les dans **Repo → Settings → Secrets and variables → Actions**.

---

## 📦 Scripts npm disponibles
| Commande | Description |
| --- | --- |
| `npm start` | Mode développement (CRA) |
| `npm test -- --watchAll=false` | Tests unitaires en mode CI |
| `npm run build` | Build production (dossier `build/`) |
| `npm run eject` | ⚠️ Action irréversible pour personnaliser CRA |

---

## 📑 Notes supplémentaires
- `Dockerfile` utilise deux étapes : build Node → serve Nginx.
- `docker-compose.yml` expose l’app sur `http://localhost:3000`.
- `deploy.ps1` fournit un exemple de déploiement PowerShell si besoin.
- `version.txt` peut servir pour tracer les releases / tags Docker.

---

## 🤝 Contribution
1. Fork du repo
2. Créer une branche `feat/xxx`
3. Commit + push
4. Ouvrir une Pull Request (les tests CI se lancent automatiquement)

---

## 📄 Licence
Projet éducatif.

---

Happy shipping! 🚀

