package org.sample.foo.service;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.BeanNameAware;
import org.springframework.beans.factory.DisposableBean;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.stereotype.Service;

/**
 * A service for logging Spring bean states
 */
@Service
public class BeanStatesLoggingService implements BeanNameAware, ApplicationContextAware, InitializingBean, DisposableBean {
    final Logger logger = LoggerFactory.getLogger(BeanStatesLoggingService.class);

    //a parameter that you can pass to docker image with --foo.parameter=something
    @Value("${foo.parameter}")
    String fooParameter;
    
    
    @Override
    public void setBeanName(String name) {
        logToSystemAndSysOut("--- setBeanName executed ---");
        logToSystemAndSysOut("foo.parameter=" + fooParameter);
    }

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) {
        logToSystemAndSysOut("--- setApplicationContext executed ---");
    }

    @PostConstruct
    public void postConstruct() {
        logToSystemAndSysOut("--- @PostConstruct executed ---");
    }

    @Override
    public void afterPropertiesSet() {
        logToSystemAndSysOut("--- afterPropertiesSet executed ---");
    }

    @PreDestroy
    public void preDestroy() {
        logToSystemAndSysOut("--- @PreDestroy executed ---");
    }

    @Override
    public void destroy() throws Exception {
        logToSystemAndSysOut("--- destroy executed ---");
    }
    
    //in case you want to use @Bean(initMethod="initMethod")
    public void initMethod() {
        logToSystemAndSysOut("--- init-method executed ---");
    }
    //in case you want to use @Bean(destroyMethod="destroyMethod")
    public void destroyMethod() {
        logToSystemAndSysOut("--- destroy-method executed ---");
    }

    private void logToSystemAndSysOut(String message) {
        logger.info(message);
        //to log when log system is unavailable (there used to be a bug with logging system shutdown to early in spring)
        System.out.println(message);
    }

}
