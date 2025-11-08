# ---- Étape 1 : Build ----
FROM eclipse-temurin:17-jdk AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# ---- Étape 2 : Run ----
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
