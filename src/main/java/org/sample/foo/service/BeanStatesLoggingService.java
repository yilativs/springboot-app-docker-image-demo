package org.sample.foo.service;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.BeanNameAware;
import org.springframework.beans.factory.DisposableBean;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.info.BuildProperties;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.stereotype.Service;

/**
 * A service for logging Spring bean states.
 * Demonstrates graceful shutdown.
 */
@Service
public class BeanStatesLoggingService implements BeanNameAware, ApplicationContextAware, InitializingBean, DisposableBean {
    final Logger logger = LoggerFactory.getLogger(BeanStatesLoggingService.class);

    @Autowired
    public void setBuildProperties(BuildProperties buildProperties) {
        log("standard build properties are:");

        log("groupId=" + buildProperties.getGroup());
        log("artifactId=" + buildProperties.getArtifact());
        log("artifact.name=" + buildProperties.getName());
        log("artifact.version=" + buildProperties.getVersion());
        log("build timestamp=" + buildProperties.getTime().toString());

        log("additional build properties are:");
        log("java.version=" + buildProperties.get("java.version"));
        log("foo.build.value=" + buildProperties.get("foo.build.value"));

    }

    // a parameter that you can pass to docker image with --foo.parameter=something
    @Autowired
    public void setFooParameter(@Value("${foo.parameter}") String fooParameter) {
        log("foo.parameter=" + fooParameter);
    }

    @Override
    public void setBeanName(String name) {
        log("--- setBeanName executed ---");
    }

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) {
        log("--- setApplicationContext executed ---");
    }

    @PostConstruct
    public void postConstruct() {
        log("--- @PostConstruct executed ---");
    }

    @Override
    public void afterPropertiesSet() {
        log("--- afterPropertiesSet executed ---");
    }

    @PreDestroy
    public void preDestroy() {
        log("--- @PreDestroy executed ---");
    }

    @Override
    public void destroy() throws Exception {
        System.out.println("!!!if you don't see log message after this message, your log system shuts down before other beans are destoyed!!!");
        log("--- destroy executed ---");
    }

    // in case you want to use @Bean(initMethod="initMethod")
    public void initMethod() {
        log("--- init-method executed ---");
    }

    // in case you want to use @Bean(destroyMethod="destroyMethod")
    public void destroyMethod() {
        log("--- destroy-method executed ---");

    }

    private void log(String message) {
        logger.info(message);
    }
}
