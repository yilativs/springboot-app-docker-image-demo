# base image was changed to alpine to prevent issuses with prebuild tini binary is not running in target container when binary was build in other disto (not alpine)
FROM adoptopenjdk/openjdk11:x86_64-alpine-jre-11.0.11_9 as builder
WORKDIR /opt/service
RUN apk add tini --no-cache
#needed only if your jar file name is not constunt (instead of it it's better to use <finalName> in pom
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} /opt/service/service.jar
RUN java -Djarmode=layertools -jar service.jar extract

RUN mkdir -p /opt/service/ssl

RUN keytool  -noprompt -genkeypair -alias service-local -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore /opt/service/ssl/cert.p12 -validity 365 -storepass notAsecret -dname CN="localhost"
RUN keytool  -noprompt -genkeypair -alias service-dev -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore /opt/service/ssl/cert.p12 -validity 365 -storepass notAsecret -dname CN="*.platform.dev.intranet"
RUN keytool  -noprompt -genkeypair -alias service-int -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore /opt/service/ssl/cert.p12 -validity 365 -storepass notAsecret -dname CN="*.platform.int.intranet"
RUN keytool  -noprompt -genkeypair -alias service-prod -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore /opt/service/ssl/cert.p12 -validity 365 -storepass notAsecret -dname CN="*.platform.prod.intranet"

FROM amazoncorretto:11-alpine-jdk
#alpine based images should use this ugly command
WORKDIR /opt/service
COPY entry-point.sh /opt/service/entry-point.sh

RUN addgroup -S service && \
adduser -S service -G service -h /opt/service && \
mkdir -p /opt/service/ssl && \
chown -R service:service /opt/service \
&& chmod u+x /opt/service/entry-point.sh

COPY --from=builder /opt/service/dependencies/ ./
COPY --from=builder /opt/service/snapshot-dependencies/ ./
COPY --from=builder /opt/service/spring-boot-loader/ ./
COPY --from=builder /opt/service/application/ ./
COPY --from=builder /opt/service/ssl/ ./ssl
COPY --from=builder /sbin/tini /sbin/tini

USER service:service

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
ENTRYPOINT ["/sbin/tini", "-v", "--", "/opt/service/entry-point.sh"]
CMD [--spring.profiles.active=local]
