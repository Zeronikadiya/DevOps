# Changed from eclipse-temurin:21-jdk to 21-jre
# JRE is ~200MB lighter — no compiler needed at runtime
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY target/my-java-app-1.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
