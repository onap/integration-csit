package org.onap.so.svnfm.simulator.oauth;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.security.oauth2.config.annotation.configurers.ClientDetailsServiceConfigurer;
import org.springframework.security.oauth2.config.annotation.web.configuration.AuthorizationServerConfigurerAdapter;
import org.springframework.security.oauth2.config.annotation.web.configuration.EnableAuthorizationServer;

@Configuration
@EnableAuthorizationServer
@Profile("oauth-authentication")
/**
 * Configures the authorization server for oauth token based authentication when the spring profile
 * "oauth-authentication" is active
 */
public class AuthorizationServerConfig extends AuthorizationServerConfigurerAdapter {
    private static final Logger LOGGER = LoggerFactory.getLogger(AuthorizationServerConfig.class);

    private static final int ONE_DAY = 60 * 60 * 24;

    @Override
    public void configure(final ClientDetailsServiceConfigurer clients) throws Exception {
        LOGGER.info("configuring oauth-authentication ...");
        clients.inMemory().withClient("vnfm")
                .secret("$2a$10$Fh9ffgPw2vnmsghsRD3ZauBL1aKXebigbq3BB1RPWtE62UDILsjke") //password1$
                .authorizedGrantTypes("client_credentials").scopes("write").accessTokenValiditySeconds(ONE_DAY)
                .refreshTokenValiditySeconds(ONE_DAY);
    }

}
