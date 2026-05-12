FROM openjdk:21-jdk-slim
COPY target/my-java-app-1.0.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
EOF
