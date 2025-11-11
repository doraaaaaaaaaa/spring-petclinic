# Étape 1 : Image de base Java 25
FROM eclipse-temurin:25-jdk

# Répertoire de travail
WORKDIR /app

# Copier le JAR généré par Maven (doit exister avant le build)
COPY target/*.jar app.jar

# Port de l’application
EXPOSE 8080

# Commande de lancement
ENTRYPOINT ["java", "-jar", "app.jar"]
