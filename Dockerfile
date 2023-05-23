FROM openjdk:17-alpine

ARG JAR_FILE=target/numeric-0.0.1.jar
WORKDIR .

COPY . .
EXPOSE 8080
CMD ["java","-jar","$JAR_FILE"]



