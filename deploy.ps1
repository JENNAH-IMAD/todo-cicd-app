# ============================================
# Script de déploiement automatisé TodoCI/CD
# ============================================

$DOCKER_USERNAME = "bluekayn11"
$IMAGE_NAME = "todocicd"
$CONTAINER_NAME = "todo-app"
$PORT = 8060
$VERSION_FILE = "version.txt"

# Afficher le titre
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TodoCI/CD - Systeme de Versioning" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# ETAPE 1 : NETTOYAGE COMPLET
# ============================================
Write-Host "[1/7] Nettoyage des anciens containers et images..." -ForegroundColor Yellow

# Arreter et supprimer le container
Write-Host "  -> Arret du container existant..."
docker stop $CONTAINER_NAME 2>$null | Out-Null
docker rm $CONTAINER_NAME 2>$null | Out-Null

# Supprimer toutes les anciennes images todocicd
Write-Host "  -> Suppression des anciennes images..."
$oldImages = docker images --format "{{.Repository}}:{{.Tag}}" | Select-String "$DOCKER_USERNAME/$IMAGE_NAME"
if ($oldImages) {
    foreach ($image in $oldImages) {
        docker rmi -f $image 2>$null | Out-Null
    }
}

Write-Host "  Nettoyage termine" -ForegroundColor Green
Write-Host ""

# ============================================
# ETAPE 2 : GESTION DE LA VERSION
# ============================================
Write-Host "[2/7] Gestion du versioning..." -ForegroundColor Yellow

# Creer le fichier version.txt s'il n'existe pas
if (-not (Test-Path $VERSION_FILE)) {
    "0" | Out-File -FilePath $VERSION_FILE -NoNewline -Encoding ASCII
    Write-Host "  -> Fichier version.txt cree (V0)" -ForegroundColor Gray
}

# Lire la version actuelle
$CURRENT_VERSION = [int](Get-Content $VERSION_FILE -Raw)

# Incrementer la version
$NEW_VERSION = $CURRENT_VERSION + 1

# Sauvegarder la nouvelle version
$NEW_VERSION.ToString() | Out-File -FilePath $VERSION_FILE -NoNewline -Encoding ASCII

# Creer les tags
$IMAGE_TAG_VERSIONED = "${DOCKER_USERNAME}/${IMAGE_NAME}:v${NEW_VERSION}"
$IMAGE_TAG_LATEST = "${DOCKER_USERNAME}/${IMAGE_NAME}:latest"

Write-Host "  -> Version precedente : V$CURRENT_VERSION" -ForegroundColor Gray
Write-Host "  -> Nouvelle version   : V$NEW_VERSION" -ForegroundColor Cyan
Write-Host "  -> Tag image          : $IMAGE_TAG_VERSIONED" -ForegroundColor Cyan
Write-Host "  Version mise a jour" -ForegroundColor Green
Write-Host ""

# ============================================
# ETAPE 3 : BUILD DE L'IMAGE DOCKER
# ============================================
Write-Host "[3/7] Build de l'image Docker..." -ForegroundColor Yellow
Write-Host "  -> Cette etape peut prendre 2-3 minutes..." -ForegroundColor Gray

$buildOutput = docker build -t $IMAGE_TAG_VERSIONED -t $IMAGE_TAG_LATEST . 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "  Build reussi !" -ForegroundColor Green
} else {
    Write-Host "  Erreur lors du build" -ForegroundColor Red
    Write-Host $buildOutput
    exit 1
}
Write-Host ""

# ============================================
# ETAPE 4 : VERIFIER LA CONNEXION DOCKER HUB
# ============================================
Write-Host "[4/7] Verification de la connexion Docker Hub..." -ForegroundColor Yellow

$dockerInfo = docker info 2>$null | Select-String "Username: $DOCKER_USERNAME"
if (-not $dockerInfo) {
    Write-Host "  -> Connexion a Docker Hub requise..." -ForegroundColor Yellow
    docker login -u $DOCKER_USERNAME
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  Echec de connexion a Docker Hub" -ForegroundColor Red
        exit 1
    }
}

Write-Host "  Connecte en tant que $DOCKER_USERNAME" -ForegroundColor Green
Write-Host ""

# ============================================
# ETAPE 5 : PUSH VERS DOCKER HUB
# ============================================
Write-Host "[5/7] Push vers Docker Hub..." -ForegroundColor Yellow

# Push de la version specifique
Write-Host "  -> Push de $IMAGE_TAG_VERSIONED..." -ForegroundColor Gray
docker push $IMAGE_TAG_VERSIONED 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "  Version V$NEW_VERSION pushee" -ForegroundColor Green
} else {
    Write-Host "  Erreur lors du push de la version" -ForegroundColor Red
    exit 1
}

# Push du tag latest
Write-Host "  -> Push de $IMAGE_TAG_LATEST..." -ForegroundColor Gray
docker push $IMAGE_TAG_LATEST 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "  Tag 'latest' pushe" -ForegroundColor Green
} else {
    Write-Host "  Avertissement: echec du push 'latest'" -ForegroundColor Yellow
}
Write-Host ""

# ============================================
# ETAPE 6 : LANCER LE CONTAINER
# ============================================
Write-Host "[6/7] Lancement du container..." -ForegroundColor Yellow

docker run -d `
    --name $CONTAINER_NAME `
    -p ${PORT}:80 `
    --restart unless-stopped `
    $IMAGE_TAG_VERSIONED 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "  Container lance avec succes !" -ForegroundColor Green
    Write-Host "  -> URL locale : http://localhost:$PORT" -ForegroundColor Cyan
} else {
    Write-Host "  Erreur lors du lancement du container" -ForegroundColor Red
    exit 1
}
Write-Host ""

# ============================================
# ETAPE 7 : COMMIT GIT
# ============================================
Write-Host "[7/7] Mise a jour Git..." -ForegroundColor Yellow

# Verifier si c'est un repo Git
if (Test-Path ".git") {
    git add version.txt 2>$null
    git commit -m "Version bump to V$NEW_VERSION" 2>$null | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Version committee dans Git" -ForegroundColor Green
        Write-Host "  -> N'oublie pas de faire: git push origin main" -ForegroundColor Yellow
    } else {
        Write-Host "  -> Aucun changement a committer" -ForegroundColor Gray
    }
} else {
    Write-Host "  -> Pas un repository Git, skip" -ForegroundColor Gray
}
Write-Host ""

# ============================================
# RESUME FINAL
# ============================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "         DEPLOIEMENT REUSSI !" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Image Docker Hub:" -ForegroundColor White
Write-Host "   -> $IMAGE_TAG_VERSIONED" -ForegroundColor Cyan
Write-Host "   -> $IMAGE_TAG_LATEST" -ForegroundColor Cyan
Write-Host ""
Write-Host "Version        : V$NEW_VERSION" -ForegroundColor White
Write-Host "Container      : $CONTAINER_NAME" -ForegroundColor White
Write-Host "Port           : $PORT" -ForegroundColor White
Write-Host "URL locale     : http://localhost:$PORT" -ForegroundColor Cyan
Write-Host ""
Write-Host "Commandes utiles:" -ForegroundColor Yellow
Write-Host "   docker logs $CONTAINER_NAME           # Voir les logs"
Write-Host "   docker stop $CONTAINER_NAME           # Arreter"
Write-Host "   docker restart $CONTAINER_NAME        # Redemarrer"
Write-Host "   docker exec -it $CONTAINER_NAME sh    # Acceder au shell"
Write-Host ""
Write-Host "Docker Hub:" -ForegroundColor Yellow
Write-Host "   https://hub.docker.com/r/$DOCKER_USERNAME/$IMAGE_NAME"
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Ouvrir le navigateur (optionnel)
$response = Read-Host "Voulez-vous ouvrir l'application dans le navigateur ? (O/N)"
if ($response -eq "O" -or $response -eq "o") {
    Start-Process "http://localhost:$PORT"
    Write-Host "Navigateur ouvert !" -ForegroundColor Green
}

Write-Host ""
Write-Host "Appuyez sur une touche pour terminer..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")