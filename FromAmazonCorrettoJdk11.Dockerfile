FROM adoptopenjdk:11-jre-hotspot as builder
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

FROM amazoncorretto:11-alpine-jdk
#alpine based images should use this ugly command
RUN addgroup -S service && adduser -S service -G service -h /opt/service

# if you want to copy tini binary from builder it will not work(alpine not working with precompiled binaries from other distros)
#https://github.com/github/hub/issues/1818
# you should change the builder image to alpine or install tini as apk
RUN apk add tini --no-cache

WORKDIR /opt/service
RUN mkdir -p /opt/service/ssl

COPY --from=builder /opt/service/dependencies/ ./
COPY --from=builder /opt/service/snapshot-dependencies/ ./
COPY --from=builder /opt/service/spring-boot-loader/ ./
COPY --from=builder /opt/service/application/ ./
COPY --from=builder /opt/service/ssl/ ./ssl

COPY entry-point.sh /opt/service/entry-point.sh
RUN chown -R service:service /opt/service
RUN chmod u+x /opt/service/entry-point.sh


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
