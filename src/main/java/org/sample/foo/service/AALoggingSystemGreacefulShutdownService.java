package org.sample.foo.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.DisposableBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.logging.LoggingSystem;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Service;

@Service
//doesn't affect extShutdownHook order
@Order(Ordered.LOWEST_PRECEDENCE)
//AA affects shutdown order making service to be destroyed last
public class AALoggingSystemGreacefulShutdownService implements DisposableBean {
    private static final Logger logger = LoggerFactory.getLogger(AALoggingSystemGreacefulShutdownService.class);

    @Autowired
    LoggingSystem loggingSystem;
    
    @Override
    public void destroy() throws Exception {
        logger.info("cleaning logging system");
        loggingSystem.cleanUp();
    }

}