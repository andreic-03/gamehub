package com.gamehub.config.properties;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;

import java.util.List;
import java.util.Objects;

@Configuration
@ConfigurationProperties(prefix = "security.apis")
@Getter
@Setter
public class EndpointSecurityProperties {
    private List<PublicEndpointsDefinition> publicEndpoints;
    private List<PrivateEndpointsDefinition> privateEndpoints;

    @Getter
    @Setter
    public static class PrivateEndpointsDefinition extends PublicEndpointsDefinition {
        private List<String> roles;

        public boolean hasRoles() {
            return Objects.nonNull(roles);
        }
    }

    @Getter
    @Setter
    public static class PublicEndpointsDefinition {
        private HttpMethod method;
        private List<String> uris;

        public boolean hasMethod() {
            return Objects.nonNull(method);
        }
    }
}
