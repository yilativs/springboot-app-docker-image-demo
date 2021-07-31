# Spring Boot Application Docker Image Demo

### Features

This project demonstrates following features of a Spring Boot Java application packaged as a docker image:

* Layered jar - allows to minimize docker image size on rebuilds and speed up docker push and pull phases
* Build properties - allows to use build properties such as pom.xml properties and build timestamp 
* Multiple profiles to build docker image on top of popular java images - AdoptOpenJdk and Amazoncorretto are supported
* Readiness at /actuator/health/readiness
* Liveness at /actuator/health/liveness
* SIGTERM handling
* Graceful shutdown
* Logging system shutdown - shuts down your log system after all other beans destoyed 
* Environment variables are passed via JAVA_OPTS
* Docker run parameters handling
* Runs as not a privileged user
* Self signed SSL certificate generation - often useful for services running behind a reversed proxy.
* Provides a VOLUME for data
* Exposes ports 8080 and 8443

### Usage

#### Create image with maven:
```
mvn clean install -P build-docker-from-amazoncorretto11
```
or

```
mvn clean install -P build-docker-from-adoptopenjdk11
```

#### Launch image instance using docker command:
```
docker run -it -v "$PWD/data":/opt/service/data -p 8443:8443 -p 8080:8080 -e JAVA_OPTS="-Xms2g -Xmx2g" --rm spring-boot-application-docker-image-demo-amazoncorrettojdk11:latest --spring.profiles.active=local --foo.parameter=some-value
```
or

```
docker run -it -v "$PWD/data":/opt/service/data -p 8443:8443 -p 8080:8080 -e JAVA_OPTS="-Xms2g -Xmx2g" --rm spring-boot-application-docker-image-demo-adoptopenjdk11:latest --spring.profiles.active=local --foo.parameter=some-value
```

* JAVA_OPTS environment variable allows to pass jvm parameters to the application 1g is used by default (make sure to set Xms and Xms to same value if you override it)
* service - is the unprivileged  user name to be used
* /opt/service - is your service location
* /opt/service/data - is where your service can load data from
* --spring.profiles.active - a parameter that sets active spring profile,  other parameters can be passed in same manner 


#### Launch image instance using docker-compose command


```
docker-compose -f docker-compose-AmazonCorretoJdk11.yml up
```
or

```
docker-compose -f docker-compose-AdoptOpenJdk11.yml up
```
Note: Environment variables are passed to docker-compose via docker-compose-env.txt

### Validating Service Info, Health, Liveness and Readiness
```
curl -k https://127.0.0.1:8443/actuator/info
```

```
curl -k https://127.0.0.1:8443/actuator/health
```

```
curl -k https://127.0.0.1:8443/actuator/health/liveness
```

```
curl -k https://127.0.0.1:8443/actuator/health/readiness
```

### Common issues this demo solves

* service runs as root - opens multiple security halls in docker environment and is prohibited in OpenShift by default
* layered jars are not used (IMPACT - large images)
* layered jars are used but not properly handled during docker build (IMPACT - created docker layers can not be reused)
* graceful shutdown is not enabled in spring and because of it a system can stop in the middle of response leading to errors on the client side
* system does not handle SIGTERM from container environment and hence graceful shutdown is not working even if it is enabled
* tini is not used and as a result a docker container can fail top stop properly leading to resource exhaustion problems 
* logging system is stopped before all other services, so logging informations of shutdown process is missing (ie. we can not detect if there are some issues)

### Reference Documentation

* [Article on layered jar in spring boot ](https://www.baeldung.com/docker-layers-spring-boot)
* [Article on signals in docker](https://hynek.me/articles/docker-signals/)
* [Graceful shutdowns with AWS ECS](https://aws.amazon.com/ru/blogs/containers/graceful-shutdowns-with-ecs/)
* [A video on Spring Boot dive and layers](https://www.youtube.com/watch?v=WL7U-yGfUXA&t=240sf)
* [dive - a tool to inspert docker imager layers ](https://github.com/wagoodman/dive)
* [Actuator docs](https://docs.spring.io/spring-boot/docs/2.5.x/reference/html/actuator.html#actuator)
