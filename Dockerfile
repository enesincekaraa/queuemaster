# ---- build stage ----
FROM eclipse-temurin:21-jdk AS build
WORKDIR /workspace

# Maven wrapper first (cache-friendly)
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./

# Download deps (cache layer)
RUN ./mvnw -q -DskipTests dependency:go-offline

# Copy source
COPY src/ src/

# Build jar
RUN ./mvnw -q -DskipTests package

# ---- runtime stage ----
FROM eclipse-temurin:21-jre
WORKDIR /app

# Copy the built jar (Spring Boot default: target/*.jar)
COPY --from=build /workspace/target/*.jar /app/app.jar

EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
