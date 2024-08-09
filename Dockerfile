# Set base image to tomcat:9-jdk11-openjdk-slim and install git and maven
FROM tomcat:9-jdk11-openjdk-slim

RUN apt-get update && apt-get install -y git maven

# Clone the repository into the Tomcat webapps directory
RUN git clone https://github.com/boxfuse/boxfuse-sample-java-war-hello.git /usr/local/tomcat/webapps/hello

# Set the working directory to the cloned repository
WORKDIR /usr/local/tomcat/webapps/hello

# Build the application using Maven
RUN mvn package

# Copy the built WAR file to the Tomcat webapps directory
RUN cp target/*.war /usr/local/tomcat/webapps/

# Expose port 8080 for Tomcat
EXPOSE 8080
