# Aide-mémoire des commandes (Jenkins Multibranch + Blue Ocean via Docker)

> Ouvrez un terminal **dans ce dossier** (`projet04-jenkins-multibranch-blueocean`), là où se trouve `docker-compose.yml`.

## Démarrer Jenkins

```bash
docker compose up -d --build
```

Puis ouvrez **http://localhost:8080** → menu **Open Blue Ocean**.

> L'assistant d'installation est désactivé : **aucun mot de passe** n'est demandé, et **Blue Ocean est déjà installé**.
>
> **Le port 8080 est déjà occupé ?** Voir l'**[Annexe — Le port 8080 est déjà occupé ?](#annexe--le-port-8080-est-déjà-occupé-)** en fin de document.

## Vérifier les outils dans le conteneur

```bash
docker exec jenkins-multibranch-tp which git     # /usr/bin/git
docker exec jenkins-multibranch-tp mvn -version   # version de Maven + JDK
```

## Vérifier que Blue Ocean est bien installé

```bash
docker exec jenkins-multibranch-tp ls /var/jenkins_home/plugins | findstr blueocean
```

## Voir les logs

```bash
docker compose logs -f jenkins
```

## Pousser le projet sur GitHub (depuis depot-exemple/)

```bash
cd depot-exemple
git init
git add .
git commit -m "Initial commit : projet Maven + Jenkinsfile"
git branch -M main
git remote add origin https://github.com/VOTRE-COMPTE/demo-pipeline.git
git push -u origin main

# Deuxieme branche pour demontrer le multibranch
git switch -c dev
git push -u origin dev
```

## Tester le projet Maven en local (optionnel, sans Jenkins)

Placez-vous **dans le dossier `depot-exemple/`** (là où se trouve `pom.xml`), puis lancez :

```bash
docker run --rm -v "${PWD}:/app" -w /app maven:3.9-eclipse-temurin-17 mvn clean package
```

> Le JAR et les rapports de tests apparaissent dans `depot-exemple/target/`.
> Sur l'ancien `cmd` Windows, remplacez `${PWD}` par `%cd%`.

## Arrêter / réinitialiser

```bash
docker compose stop          # arreter (donnees conservees)
docker compose down          # supprimer le conteneur (volume conserve)
docker compose down -v       # tout supprimer (config Jenkins incluse)
```

---

## Annexe — Le port 8080 est déjà occupé ?

Si `docker compose up` affiche une erreur du type :

```text
Error response from daemon: ports are not available: exposing port TCP 0.0.0.0:8080 ...
bind: Only one usage of each socket address ... is normally permitted.
```

…c'est qu'**une autre application utilise déjà le port 8080** (souvent un autre Jenkins, Tomcat ou un serveur Java déjà lancé).

Vous avez **deux solutions** au choix : **arrêter le processus** qui occupe le port (Solution A), ou **utiliser un autre port** sans rien arrêter (Solution B).

### Solution A — Trouver et arrêter le processus qui occupe le port 8080

**Étape 1 — repérer le programme.** Avant de tuer un processus, vérifiez d'abord s'il s'agit d'un conteneur Docker.

```bash
docker ps                    # un conteneur apparait-il sur le port 8080 ?
```

- **Si c'est un conteneur Docker**, arrêtez-le proprement :

```bash
docker stop <nom>            # ex: docker stop jenkins-maven-tp
```

- **Sinon** (programme classique sur le PC), suivez les commandes selon votre système.

**Windows (PowerShell) :**

```powershell
# 1. Trouver le PID (numero de processus) qui ecoute sur le port 8080
Get-NetTCPConnection -LocalPort 8080 -State Listen | Select-Object OwningProcess

# 2. Voir de quel programme il s'agit (remplacez 8144 par le PID trouve)
Get-Process -Id 8144

# 3. Arreter ce processus (remplacez 8144 par le PID trouve)
Stop-Process -Id 8144 -Force
```

**Windows (ancien `cmd`) :**

```bat
:: 1. Trouver le PID qui ecoute sur 8080 (derniere colonne = PID)
netstat -ano | findstr :8080

:: 2. Arreter ce processus (remplacez 8144 par le PID trouve)
taskkill /PID 8144 /F
```

**macOS / Linux :**

```bash
# 1. Trouver le PID qui occupe le port 8080
lsof -i :8080
# 2. Arreter ce processus (remplacez 8144 par le PID trouve)
kill -9 8144
```

**Étape 2 — relancer Jenkins :**

```bash
docker compose up -d --build
```

### Solution B — Utiliser un autre port (sans rien arrêter)

Dans `docker-compose.yml`, changez le **port de gauche** (celui du PC). Le port de droite (8080, interne à Jenkins) ne change pas :

```yaml
    ports:
      - "8081:8080"   # 8081 = port sur votre PC, 8080 = port interne de Jenkins
```

Puis relancez et ouvrez **http://localhost:8081** :

```bash
docker compose up -d --build
```

---

<p align="center">
  <strong>Cours créé par Dr. Haythem REHOUMA — Développement et déploiement de solutions de données</strong>
</p>
