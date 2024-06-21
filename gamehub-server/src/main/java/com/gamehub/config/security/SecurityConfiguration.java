package com.gamehub.config.security;

import com.gamehub.config.properties.CorsProperties;
import com.gamehub.config.properties.EndpointSecurityProperties;
import com.gamehub.config.security.filter.JwtTokenFilter;
import com.gamehub.config.security.handlers.AuthenticationExceptionHandler;
import com.gamehub.config.security.handlers.AuthorizationExceptionHandler;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AuthorizeHttpRequestsConfigurer;
import org.springframework.security.config.core.GrantedAuthorityDefaults;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.util.CollectionUtils;
import org.springframework.web.cors.CorsConfiguration;

import java.util.Collections;
import java.util.Objects;
import java.util.Optional;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity(securedEnabled = true, jsr250Enabled = true)
public class SecurityConfiguration {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http, JwtTokenFilter jwtTokenFilter,
                                           EndpointSecurityProperties endpointSecurityProperties,
                                           AuthenticationExceptionHandler authenticationExceptionHandler,
                                           AuthorizationExceptionHandler authorizationExceptionHandler,
                                           CorsProperties corsProperties) throws Exception {

        // TODO: don't leave this off pls
        http.csrf().disable();
        http.cors().configurationSource(request -> {
            final var configuration = new CorsConfiguration();
            configuration.setAllowedOrigins(Optional.ofNullable(corsProperties.getAllowedOrigins()).orElseGet(Collections::emptyList));
            configuration.setAllowedMethods(Optional.ofNullable(corsProperties.getAllowedMethods()).orElseGet(Collections::emptyList));
            configuration.setAllowedHeaders(Optional.ofNullable(corsProperties.getAllowedHeaders()).orElseGet(Collections::emptyList));
            configuration.setExposedHeaders(Optional.ofNullable(corsProperties.getExposedHeaders()).orElseGet(Collections::emptyList));

            return configuration;
        });
        http.sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS);
        http.authorizeHttpRequests(setPermissions(endpointSecurityProperties));

        http.exceptionHandling()
                .authenticationEntryPoint(authenticationExceptionHandler)
                .accessDeniedHandler(authorizationExceptionHandler);

        http.addFilterBefore(jwtTokenFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    private Customizer<AuthorizeHttpRequestsConfigurer<HttpSecurity>.AuthorizationManagerRequestMatcherRegistry> setPermissions(EndpointSecurityProperties endpointSecurityProperties) {
        return (auth) -> {
            applyPrivateEndpointPermissions(endpointSecurityProperties, auth);
            applyPublicEndpointPermissions(endpointSecurityProperties, auth);
            auth.anyRequest().authenticated();
        };
    }

    /**
     * Method takes as parameter, an object which contains filters provided in the properties.yaml
     * Based on some criteria: method(optional), uri and roles(optional) it builds ant matchers
     * which will provide security for the private endpoints
     *
     * @param endpointSecurityProperties
     * @param auth
     */
    private void applyPrivateEndpointPermissions(EndpointSecurityProperties endpointSecurityProperties,
                                                 AuthorizeHttpRequestsConfigurer<HttpSecurity>.AuthorizationManagerRequestMatcherRegistry auth) {
        if (Objects.isNull(endpointSecurityProperties.getPrivateEndpoints())) {
            return;
        }
        endpointSecurityProperties.getPrivateEndpoints()
                .forEach((restrictions) -> {
                    if (CollectionUtils.isEmpty(restrictions.getUris())) {
                        return;
                    }

                    String[] uris = restrictions.getUris().toArray(new String[0]);
                    if (restrictions.hasMethod()) {
                        var configurator = auth.requestMatchers(restrictions.getMethod(), uris);
                        if (restrictions.hasRoles()) {
                            String[] roles = restrictions.getRoles().toArray(new String[0]);
                            configurator.hasAnyAuthority(roles);
                        } else {
                            configurator.authenticated();
                        }
                    } else {
                        var configurator = auth.requestMatchers(uris);
                        if (restrictions.hasRoles()) {
                            String[] roles = restrictions.getRoles().toArray(new String[0]);
                            configurator.hasAnyAuthority(roles);
                        } else {
                            configurator.authenticated();
                        }
                    }
                });
    }

    /**
     * Method takes as parameter an object which contains filters provided in the application.yaml for
     * securing the endpoints.
     * Based on some criteria: uri, method(optional) it builds ant matchers for the public endpoints,
     * for providing security.
     *
     * @param endpointSecurityProperties
     * @param auth
     */
    private void applyPublicEndpointPermissions(EndpointSecurityProperties endpointSecurityProperties,
                                                AuthorizeHttpRequestsConfigurer<HttpSecurity>.AuthorizationManagerRequestMatcherRegistry auth) {
        if (Objects.isNull(endpointSecurityProperties.getPublicEndpoints())) {
            return;
        }

        endpointSecurityProperties.getPublicEndpoints()
                .forEach(restrictions -> {
                    String[] uris = restrictions.getUris().toArray(new String[0]);
                    if (restrictions.hasMethod()) {
                        auth.requestMatchers(restrictions.getMethod(), uris).permitAll();
                    } else {
                        auth.requestMatchers(uris).permitAll();
                    }
                });
    }

    /**
     * Disable ROLE_ prefix for @RolesAllowed annotation
     *
     * @return GrantedAuthorityDefaults
     */
    @Bean
    public GrantedAuthorityDefaults grantedAuthorityDefaults() {
        return new GrantedAuthorityDefaults("");
    }


    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public AuthenticationManager authenticationManager(HttpSecurity http,
                                                       PasswordEncoder passwordEncoder,
                                                       UserDetailsService userDetailService) throws Exception {

        return http.getSharedObject(AuthenticationManagerBuilder.class)
                .userDetailsService(userDetailService)
                .passwordEncoder(passwordEncoder)
                .and()
                .build();
    }

}
