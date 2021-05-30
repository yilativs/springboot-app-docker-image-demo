package org.sample.foo.service;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.BeanNameAware;
import org.springframework.beans.factory.DisposableBean;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.stereotype.Service;

/**
 *  A service with name starting with Z to validate that AALoggingSystemGreacefulShutdownService is executed last.
 */
@Service
public class ZZFooService implements BeanNameAware, ApplicationContextAware,    InitializingBean, DisposableBean {

  private static final Logger logger = LoggerFactory.getLogger(ZZFooService.class);

  @Override
  public void setBeanName(String name) {
    logToSystemAndSysOut("--- setBeanName executed ---");
  }

  @Override
  public void setApplicationContext(ApplicationContext applicationContext)
      throws BeansException {
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

  public void initMethod() {
    logToSystemAndSysOut("--- init-method executed ---");
  }

  @PreDestroy
  public void preDestroy() {
    logToSystemAndSysOut("--- @PreDestroy executed ---");
  }

  @Override
  public void destroy() throws Exception {
    logToSystemAndSysOut("--- destroy executed ---");
  }

  public void destroyMethod() {
    logToSystemAndSysOut("--- destroy-method executed ---");
  }
  
  private static void logToSystemAndSysOut(String message) {
      logger.info(message);
      System.out.println(message);
  }

}
