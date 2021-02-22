package org.onap.so.multicloudsimulator;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication(scanBasePackages = {"org.onap"})
public class MultiCloudSimulatorApplication {

	public static void main(String[] args) {
		SpringApplication.run(MultiCloudSimulatorApplication.class, args);
	}

}
