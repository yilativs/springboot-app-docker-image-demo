package org.sample.foo.service;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.DisposableBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.boot.logging.LoggingSystem;
import org.springframework.context.event.ContextClosedEvent;
import org.springframework.context.event.ContextStoppedEvent;
import org.springframework.context.event.EventListener;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Service;

@Service
//doesn't affect extShutdownHook order
@Order(Ordered.HIGHEST_PRECEDENCE)
//AA affects shutdown order making service to be destroyed last
public class AALoggingSystemGreacefulShutdownService implements DisposableBean {
    private static final Logger logger = LoggerFactory.getLogger(AALoggingSystemGreacefulShutdownService.class);

    @Autowired
    LoggingSystem loggingSystem;

    @PostConstruct
    public void postConstruct() {
        logToSystemAndSysOut("postConstruct");
    }

    @PreDestroy
    public void preDestroy() {
        logToSystemAndSysOut("preDestroy");
    }

    @EventListener
    void onApplicationReadyEvent(ApplicationReadyEvent event)  {
        logToSystemAndSysOut("onApplicationReadyEvent : " + event);
    }

    @EventListener
    void onContextClosedEvent(ContextClosedEvent event)  {
        logToSystemAndSysOut("onContextClosedEvent : " + event);
    }

    @EventListener
    void onContextStoppedEvent(ContextStoppedEvent event)  {
        logToSystemAndSysOut("onContextStoppedEvent : " + event);
    }

    
    @Override
    public void destroy() throws Exception {
        loggingSystem.cleanUp();
    }

    private static void logToSystemAndSysOut(String message) {
        logger.info(message);
        System.out.println(message);
    }

}