package org.sample.foo.web;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZonedDateTime;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController()
@RequestMapping("/date-time")
public class DateTimeController {

	@GetMapping("local")
	public LocalDateTime getLocal() {
		return LocalDateTime.now();
	}
	
	@GetMapping("zoned")
	public ZonedDateTime getZoned() {
		return ZonedDateTime.now();
	}
}
