FROM adoptopenjdk:11-jre-hotspot as builder
RUN  apt-get -y update &&  apt-get -y install tini
WORKDIR /opt/service
#needed only if your jar file name is not constunt (instead of it it's better to use <finalName> in pom
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} /opt/service/service.jar
RUN java -Djarmode=layertools -jar service.jar extract

RUN mkdir -p /opt/service/ssl

RUN keytool  -noprompt -genkeypair -alias service-local -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore /opt/service/ssl/cert.p12 -validity 365 -storepass notAsecret -dname CN="localhost"
RUN keytool  -noprompt -genkeypair -alias service-dev -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore /opt/service/ssl/cert.p12 -validity 365 -storepass notAsecret -dname CN="*.platform.dev.intranet"
RUN keytool  -noprompt -genkeypair -alias service-int -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore /opt/service/ssl/cert.p12 -validity 365 -storepass notAsecret -dname CN="*.platform.int.intranet"
RUN keytool  -noprompt -genkeypair -alias service-prod -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore /opt/service/ssl/cert.p12 -validity 365 -storepass notAsecret -dname CN="*.platform.prod.intranet"

FROM adoptopenjdk:11-jre-hotspot

#install tini to run service not on pid 1
COPY --from=builder /usr/bin/tini /usr/bin/tini

#create user service in order not to run service not as root
RUN adduser --system  --group --home /opt/service service

COPY entry-point.sh /opt/service/entry-point.sh
RUN chown -R service:service /opt/service
RUN chmod u+x /opt/service/entry-point.sh

#switch to user 
USER service:service

WORKDIR /opt/service
COPY --from=builder /opt/service/dependencies/ ./
COPY --from=builder /opt/service/snapshot-dependencies/ ./
COPY --from=builder /opt/service/spring-boot-loader/ ./
COPY --from=builder /opt/service/application/ ./

RUN mkdir -p /opt/service/ssl
COPY --from=builder /opt/service/ssl/ ./ssl

#can be used to override image build in configs (e.g. in kubernetes)
VOLUME ["/opt/service/config"]

#can be used in order to store service logs
VOLUME ["/opt/service/logs"]

#can be used in order to provide certificates (if you have any)
VOLUME ["/opt/service/ssl"]


EXPOSE 8080/tcp
EXPOSE 8443/tcp

#java opts to override

ENV JAVA_OPTS="-Xms1g -Xmx1g"
#https://github.com/krallin/tini
# -v -vv and -vvv stands for verbosity level
ENTRYPOINT ["/usr/bin/tini", "-v", "--", "/opt/service/entry-point.sh"]
CMD [--spring.profiles.active=local]