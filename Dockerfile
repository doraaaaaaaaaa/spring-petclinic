# ---- Étape 1 : Build ----
FROM eclipse-temurin:17 AS builder
WORKDIR /app

# Copier tous les fichiers du projet
COPY . .

# Build Maven sans tests
RUN apt-get update && apt-get install -y maven git \
    && mvn clean package -DskipTests

# ---- Étape 2 : Runtime ----
FROM eclipse-temurin:17
WORKDIR /app

# Copier le jar généré depuis l'étape builder
COPY --from=builder /app/target/*.jar ./app.jar

# Exposer le port 8080
EXPOSE 8080

# Lancer l'application
ENTRYPOINT ["java","-jar","app.jar"]
