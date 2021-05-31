package org.sample.foo.service;

import org.springframework.stereotype.Service;

/**
 *  A service with name starting with Z to validate that AALoggingSystemGreacefulShutdownService is executed last.
 */
@Service
public class ZZFooService extends AFooService{

}
