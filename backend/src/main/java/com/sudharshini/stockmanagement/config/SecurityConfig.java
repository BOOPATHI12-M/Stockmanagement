package com.sudharshini.stockmanagement.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.List;

/**
 * Security Configuration
 * Handles CORS and endpoint security
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfig {
    
    @Autowired
    private JwtAuthenticationFilter jwtAuthenticationFilter;
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
    
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/admin/login").permitAll() // Allow login for admin and delivery man
                .requestMatchers("/api/auth/admin/proof-documents/**").authenticated() // Allow authenticated users to view proof documents
                .requestMatchers("/api/auth/admin/**").hasRole("ADMIN") // Other admin-only auth endpoints
                .requestMatchers("/api/auth/**").permitAll() // Public auth endpoints (profile endpoints require auth via JWT filter)
                .requestMatchers("/api/products").permitAll()
                .requestMatchers("/api/products/images/**").permitAll()
                .requestMatchers("/api/products/upload").authenticated()
                .requestMatchers("/api/auth/profile/photo/**").permitAll() // Allow public access to profile photos
                .requestMatchers("/api/reviews/product/**").permitAll() // Allow public access to view reviews
                .requestMatchers("/api/reviews/**").authenticated() // Require auth for adding/deleting reviews
                .requestMatchers("/api/cart/**").authenticated()
                // Public tracking endpoints - must be before /api/orders/** to match first
                .requestMatchers("/api/orders/*/tracking").permitAll()
                // Location tracking is public (like tracking) - must be before /api/orders/** to match first
                .requestMatchers("/api/orders/*/location-tracking").permitAll()
                .requestMatchers("/api/orders/by-order-number/**").permitAll() // Public tracking
                .requestMatchers("/api/orders/by-tracking-id/**").permitAll() // Public tracking
                .requestMatchers("/api/orders/all").hasRole("ADMIN") // Admin only - get all orders
                .requestMatchers("/api/orders/customer/me").authenticated() // User's own orders
                .requestMatchers("/api/orders/customer/**").hasRole("ADMIN") // Admin viewing customer orders
                .requestMatchers("/api/orders/**").authenticated() // Other order endpoints require auth
                .requestMatchers("/api/delivery/**").hasAnyRole("DELIVERY_MAN", "ADMIN") // Delivery man or admin
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                .requestMatchers("/error").permitAll()
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);
        
        return http.build();
    }
    
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        
        // Read allowed origins from environment variable (for production)
        // Fallback to localhost for development
        String corsOriginsEnv = System.getenv("CORS_ORIGINS");
        if (corsOriginsEnv != null && !corsOriginsEnv.isEmpty()) {
            // Split comma-separated origins
            List<String> allowedOrigins = Arrays.asList(corsOriginsEnv.split(","));
            configuration.setAllowedOrigins(allowedOrigins);
            System.out.println("🌐 [CORS] Using origins from environment: " + allowedOrigins);
        } else {
            // Default to localhost for development
            configuration.setAllowedOrigins(Arrays.asList(
                "http://localhost:3000", 
                "http://localhost:5173", 
                "http://127.0.0.1:3000", 
                "http://127.0.0.1:5173"
            ));
            System.out.println("🌐 [CORS] Using default localhost origins");
        }
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"));
        // Explicitly allow Authorization header and Content-Type
        configuration.setAllowedHeaders(Arrays.asList(
            "Authorization", 
            "Content-Type", 
            "X-Requested-With",
            "Accept",
            "Origin",
            "Access-Control-Request-Method",
            "Access-Control-Request-Headers"
        ));
        // Expose Authorization header in response (if needed)
        configuration.setExposedHeaders(Arrays.asList("Authorization"));
        // Allow credentials for cookies (if needed in future)
        configuration.setAllowCredentials(true);
        configuration.setMaxAge(3600L); // Cache preflight requests for 1 hour
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}

