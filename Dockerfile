FROM openjdk:17-alpine

ARG JAR_FILE=target/*.jar
WORKDIR .

COPY . .
EXPOSE 8080
CMD ["java","-jar","$JAR_FILE"]



