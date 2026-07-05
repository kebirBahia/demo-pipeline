# Jenkins LTS avec JDK 17 (java + javac + git), Maven et les plugins Blue Ocean.
# Permet d'executer un pipeline Maven (compile + tests + JAR) et de le visualiser
# avec Blue Ocean, en mode Multibranch Pipeline.
FROM jenkins/jenkins:lts-jdk17

USER root

# Maven (pour : mvn clean package dans la pipeline)
RUN apt-get update \
    && apt-get install -y --no-install-recommends maven \
    && rm -rf /var/lib/apt/lists/*

USER jenkins

# Plugins preinstalles : Blue Ocean, pipelines, Git/GitHub multibranch, JUnit, HTML.
# Evite de devoir les installer a la main dans l'interface.
RUN jenkins-plugin-cli --plugins \
    blueocean \
    workflow-aggregator \
    workflow-multibranch \
    git \
    github-branch-source \
    junit \
    htmlpublisher

# On saute l'assistant initial (mot de passe + plugins suggeres) : le conteneur est pret a l'emploi.
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
