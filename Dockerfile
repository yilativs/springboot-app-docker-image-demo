#install dive https://github.com/wagoodman/dive
#about layers https://spring.io/blog/2020/08/14/creating-efficient-docker-images-with-spring-boot-2-3
#instead of layers uses target staructure https://spring.io/guides/gs/spring-boot-docker/
#https://www.youtube.com/watch?v=WL7U-yGfUXA&t=240sf

#https://www.baeldung.com/docker-layers-spring-boot
#best article on signals
#https://hynek.me/articles/docker-signals/

FROM adoptopenjdk:11-jre-hotspot as builder
WORKDIR /opt/service
#needed only if your jar file name is not constunt (instead of it it's better to use <finalName> in pom
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} /opt/service/service.jar
RUN java -Djarmode=layertools -jar service.jar extract

RUN mkdir -p /opt/service/ssl
RUN keytool  -noprompt -genkeypair -alias service -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore /opt/service/ssl/dev-cert.p12 -validity 3650 -storepass notAsecret -dname CN="*.platform.dev.intranet"
RUN keytool  -noprompt -genkeypair -alias service -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore /opt/service/ssl/int-cert.p12 -validity 3650 -storepass notAsecret -dname CN="*.platform.int.intranet"
RUN keytool  -noprompt -genkeypair -alias service -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore /opt/service/ssl/prod-cert.p12 -validity 3650 -storepass notAsecret -dname CN="*.platform.prod.intranet"

#FROM adoptopenjdk:11-jre-hotspot
#RUN adduser --system  --group --home /opt/service service

FROM amazoncorretto:11-alpine-jdk
#alpine based images should use this ugly command
RUN addgroup -S service && adduser -S service -G service -h /opt/service
#see https://stackoverflow.com/questions/27701930/how-to-add-users-to-docker-container
#RUN addgroup -S service  


WORKDIR /opt/service
COPY --from=builder /opt/service/dependencies/ ./
COPY --from=builder /opt/service/snapshot-dependencies/ ./
COPY --from=builder /opt/service/spring-boot-loader/ ./
COPY --from=builder /opt/service/application/ ./


RUN mkdir -p /opt/service/ssl
COPY --from=builder /opt/service/ssl/ ./ssl

COPY entry-point.sh /opt/service/entry-point.sh
RUN chown -R service:service /opt/service 
RUN chmod u+x /opt/service/entry-point.sh

RUN apk add --no-cache tini

USER service:service

#we can mount it in case we want to provide application with some changing data, ssl certs, property files and so on
VOLUME [/opt/service/data]
EXPOSE 8080/tcp
EXPOSE 8443/tcp

#java opts to override
ENV JAVA_OPTS="-Xms1g -Xmx1g"

#https://github.com/krallin/tini
# -v -vv and -vvv stands for verbosity level
ENTRYPOINT ["/sbin/tini", "-v", "--", "/opt/service/entry-point.sh"]
CMD "--spring.profiles.active=dev"