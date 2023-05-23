FROM openjdk:17-alpine
WORKDIR .

COPY . .
EXPOSE 8080
CMD ["java","-jar","target/numeric-0.0.1.jar"]



