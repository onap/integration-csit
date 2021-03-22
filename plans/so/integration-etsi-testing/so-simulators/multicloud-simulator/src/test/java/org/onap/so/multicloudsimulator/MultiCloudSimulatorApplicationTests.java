package org.onap.so.multicloudsimulator;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.onap.so.multicloudsimulator.utils.Constants;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import static org.junit.Assert.assertEquals;

@RunWith(SpringJUnit4ClassRunner.class)
@ActiveProfiles("test")
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Configuration
class MultiCloudSimulatorApplicationTests {
	@LocalServerPort
	private int port;

	@Autowired
	private TestRestTemplate restTemplate;

	@Test
	public void test_createInstance() {
		final String url = "http://localhost:" + port + Constants.BASE_URL + "/operations";
		;
		final ResponseEntity<String> object = restTemplate.getForEntity(url, String.class);

		assertEquals(Constants.OPERATIONS_URL, object.getBody());

	}

}