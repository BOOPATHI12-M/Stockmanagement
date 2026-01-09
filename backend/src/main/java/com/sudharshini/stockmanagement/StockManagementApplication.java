package com.sudharshini.stockmanagement;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

/**
 * Main Spring Boot Application
 * Sudharshini Stock Management System
 */
@SpringBootApplication
@EnableAsync
public class StockManagementApplication {
    public static void main(String[] args) {
        // Read PORT from environment variable (Render provides this)
        String port = System.getenv("PORT");
        if (port != null && !port.isEmpty()) {
            System.setProperty("server.port", port);
            System.out.println("🔧 [Application] Using PORT from environment: " + port);
        } else {
            System.out.println("🔧 [Application] Using default port from application.properties");
        }
        
        SpringApplication.run(StockManagementApplication.class, args);
    }
}

