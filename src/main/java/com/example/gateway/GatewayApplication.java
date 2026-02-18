package com.example.gateway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.http.HttpStatus;

@SpringBootApplication
public class GatewayApplication {

    public static void main(String[] args) {
        SpringApplication.run(GatewayApplication.class, args);
    }

    /**
     * Программная конфигурация маршрутов (альтернатива application.yml).
     * Этот бин используется в дополнение к конфигурации в application.yml.
     */
    @Bean
    public RouteLocator routeLocator(RouteLocatorBuilder builder) {
        return builder.routes()
                .route("service1_route", r -> r
                        .path("/service1/**")
                        .filters(f -> f
                                .stripPrefix(1)
                                .retry(config -> config
                                        .setRetries(3)
                                        .setMethods("GET", "POST", "PUT", "DELETE")
                                        .setBackoff(100, 1.0, 0, false)
                                )
                        )
                        .uri("http://api-service-1:8080")
                )
                .route("mock_route", r -> r
                        .path("/mock/**")
                        .filters(f -> f
                                .stripPrefix(1)
                        )
                        .uri("http://wiremock:8080")
                )
                .route("fallback_route", r -> r
                        .path("/**")
                        .filters(f -> f
                                .setStatus(HttpStatus.NOT_FOUND)
                        )
                        .uri("no://op")
                )
                .build();
    }
}
