#!/bin/sh

#consider following 
#memory sizing https://docs.oracle.com/javase/8/docs/technotes/guides/vm/gctuning/sizing.html
#jvm parameters https://www.baeldung.com/jvm-parameters
#gc https://www.baeldung.com/java-verbose-gc

#-verbose:gc - will give information on what can be tuned in terms of memory
#-XX:+UseLargePages - reduces memory usage and calculation overhead on apps that consumes more than 4GB of RAM
#-XX:SurvivorRatio=2 - can be increased for system that extract huge sets of data, makes each survivor space be half that of Eden
#-XX:NewRatio=2 - ration between young and tenured generation (for apps that mostly read data and store nothubg it can be 1)
#-XX:+UseStringDeduplication optimizes the heap memory by reducing duplicate String values to a single global char[] array
#-XX:+UseStringCache  enables caching of commonly allocated strings available in the String pool
#-XX:+PrintFlagsFinal - always print all flags of the jvm

#printing what will be launched
echo "exec java ${JAVA_OPTS} org.springframework.boot.loader.JarLauncher $@"
exec java ${JAVA_OPTS} org.springframework.boot.loader.JarLauncher $@
