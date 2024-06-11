FROM eclipse-temurin:17-jre-alpine as builder

WORKDIR /opt/service

# * is needed only if your jar file name is not constant in pom
#we recommend to  to use <finalName>
ARG JAR_FILE=target/service*.jar
COPY ${JAR_FILE} /opt/service/service.jar
RUN java -Djarmode=tools -jar service.jar extract --layers --launcher

RUN mkdir -p /opt/service/ssl
RUN keytool  -noprompt -genkeypair -alias service-local -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore /opt/service/ssl/cert.p12 -validity 365 -storepass notAsecret -dname CN="localhost"
RUN keytool  -noprompt -genkeypair -alias service-dev -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore /opt/service/ssl/cert.p12 -validity 365 -storepass notAsecret -dname CN="*.platform.dev.intranet"
RUN keytool  -noprompt -genkeypair -alias service-int -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore /opt/service/ssl/cert.p12 -validity 365 -storepass notAsecret -dname CN="*.platform.int.intranet"
RUN keytool  -noprompt -genkeypair -alias service-prod -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore /opt/service/ssl/cert.p12 -validity 365 -storepass notAsecret -dname CN="*.platform.prod.intranet"

FROM eclipse-temurin:17-jre-alpine

#install tini to run service not on pid 1
RUN /sbin/apk add --no-cache tini



#create user servuce and group service in order not to run as nonroot
# -S system user (without login)
# -D don't create password
#create user service in order not to run service as root
RUN addgroup -S service -g1000
RUN adduser -S service -G service -u1000 -g1000 -h /opt/service

COPY  --chown=service:service  entry-point.sh /opt/service/entry-point.sh
#chmod can be used in COPY with DOCKER_BUILDKIT=1
RUN chmod u+x /opt/service/entry-point.sh
#switch to user 
USER service:service

WORKDIR /opt/service
COPY --from=builder /opt/service/service/dependencies/ ./
COPY --from=builder /opt/service/service/snapshot-dependencies/ ./
COPY --from=builder /opt/service/service/spring-boot-loader/ ./
COPY --from=builder /opt/service/service/application/ ./

RUN mkdir -p /opt/service/ssl
COPY --from=builder /opt/service/ssl/ ./ssl

#can be used to override image application.propertries file
VOLUME ["/opt/service/config"]

#can be used to store service logs
VOLUME ["/opt/service/logs"]

#can be used to provide certificates 
VOLUME ["/opt/service/ssl"]

#java remote debuging
EXPOSE 8000/tcp
#HTTP
EXPOSE 8080/tcp
#managment port (actuator)
EXPOSE 8081/tcp
#HTTPS
EXPOSE 8443/tcp


#java opts to override

ENV JAVA_OPTS="-Xms1g -Xmx1g"
#https://github.com/krallin/tini
# -v -vv and -vvv stands for verbosity level
ENTRYPOINT ["/sbin/tini", "-v", "--", "/opt/service/entry-point.sh"]
CMD [--spring.profiles.active=local]