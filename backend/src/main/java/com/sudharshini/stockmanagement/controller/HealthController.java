package com.sudharshini.stockmanagement.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * Health Check Controller
 * Provides simple health check endpoints for deployment verification
 */
@RestController
@CrossOrigin(origins = "*")
public class HealthController {
    
    /**
     * Root endpoint - simple health check
     * Accessible without authentication
     */
    @GetMapping("/")
    public ResponseEntity<Map<String, Object>> root() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("service", "Sudharshini Stock Management API");
        response.put("timestamp", LocalDateTime.now().toString());
        response.put("message", "API is running successfully");
        return ResponseEntity.ok(response);
    }
    
    /**
     * Health check endpoint
     * Accessible without authentication
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("timestamp", LocalDateTime.now().toString());
        return ResponseEntity.ok(response);
    }
}

