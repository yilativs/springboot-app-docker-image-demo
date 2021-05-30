#!/bin/sh
#printing what will be launched
echo "exec java ${JAVA_OPTS} org.springframework.boot.loader.JarLauncher $@"
exec java ${JAVA_OPTS} org.springframework.boot.loader.JarLauncher $@
