# Spring Boot Application Docker Image Demo

### Features

This project demonstrates following features of a Spring Boot Java application packaged with maven as a docker image:

* Layered jar - allows to minimize docker image size on rebuilds and speed up docker push and pull phases
* Uses tini alpine image
* Exposes build properties such as:
    * pom.xml properties 
    * build timestamp
    * git information 
    * custom properties
* Exposes liveness probes at /actuator/health/liveness
* Exposes readiness probes at /actuator/health/readiness
* SIGTERM handling
* Graceful shutdown
* Logging system shutdown - shuts down your log system after all other beans are destroyed
* Environment variables are passed via JAVA_OPTS
* Docker run parameters handling
* Runs as non privileged user with custom uid and guid
* Self signed SSL certificate generation - often useful for services running behind a reversed proxy
* Provides a VOLUMES for data: 
    * for overriding application.properties
    * for temporary files (never modify your root file system)
    * for ssl certificates if you need to rotate them without re-building image
    * for logs in case you have a good reason to store logs on disk
* Exposes ports: 
    * 8080 HTTP
    * 8081 management port
    * 8443 HTTPS
    * 5005 JVM debugging
 * Docker tag support for:
    * Build id
    * Git commit id 
    * pom.version

### Usage

#### Create image with maven:
```
mvn clean install 
```
or if you want to specify build.id from your build pipeline:
```
mvn clean install "-Dbuild.id=2"
```


#### Launch image instance using docker command:

```
docker run -it -v "$PWD/data":/opt/service/data -p 8000:8000 -p 8080:8080 -p 8081:8081 -p 8443:8443 -e JAVA_OPTS="-Xms2g -Xmx2g" --rm springboot-image-demo:latest --spring.profiles.active=local --foo.parameter=some-value
```

* JAVA_OPTS environment variable allows to pass jvm parameters to the application 1g is used by default (make sure to set Xms and Xms to same value if you override it)
* service - is the unprivileged  user name to be used
* /opt/service - is your service location
* /opt/service/data - is where your service can load data from
* --spring.profiles.active - a parameter that sets active spring profile,  other parameters can be passed in same manner 


#### Launch image instance using docker-compose command

```
docker-compose up
```
Note: Environment variables are passed to docker-compose via docker-compose-env.txt

### Validating Service Info, Health, Liveness and Readiness
```
curl --insecure https://127.0.0.1:8081/actuator/info
```

```
curl --insecure https://127.0.0.1:8081/actuator/health
```

```
curl --insecure https://127.0.0.1:8081/actuator/health/liveness
```

```
curl --insecure https://127.0.0.1:8081/actuator/health/readiness
```

### Common issues this demo solves

* Service runs as root, causes multiple security issues in docker environment and is prohibited in OpenShift by default
* Layered jars are not reused used. Causes each docker build to take around 500Mb while it can take less than 1kb.
* Graceful shutdown is not enabled in spring and because of it a system can stop in the middle of response leading to errors on the client side, as well as issues with termination of scheduled job. Logging system may fail to send last log messages to log system.
* system does not handle SIGTERM from container environment and hence graceful shutdown is not working even if it is enabled
* tini is not used and as a result a docker container can fail top stop properly leading to resource exhaustion problems 

### Reference Documentation
* [Spring Layered Images](https://docs.spring.io/spring-boot/docs/3.2.0/reference/html/executable-jar.html)
* [Article on layered jar in spring boot](https://www.baeldung.com/docker-layers-spring-boot)
* [Article on signals in docker](https://hynek.me/articles/docker-signals/)
* [Graceful shutdowns with AWS ECS](https://aws.amazon.com/ru/blogs/containers/graceful-shutdowns-with-ecs/)
* [A video on Spring Boot dive and layers](https://www.youtube.com/watch?v=WL7U-yGfUXA&t=240sf)
* [dive - a tool to inspert docker imager layers ](https://github.com/wagoodman/dive)
* [Actuator docs](https://docs.spring.io/spring-boot/docs/2.5.x/reference/html/actuator.html#actuator)
