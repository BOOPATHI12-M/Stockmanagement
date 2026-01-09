package com.sudharshini.stockmanagement.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityCustomizer;
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
    
    /**
     * Configure WebSecurity to ignore static resources
     * These resources bypass Spring Security entirely (no filters run)
     */
    @Bean
    public WebSecurityCustomizer webSecurityCustomizer() {
        return (web) -> web.ignoring()
                .requestMatchers("/favicon.ico")
                .requestMatchers("/robots.txt")
                .requestMatchers("/static/**")
                .requestMatchers("/css/**")
                .requestMatchers("/js/**")
                .requestMatchers("/images/**")
                .requestMatchers("/webjars/**");
    }
    
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            // Disable CSRF for stateless REST API
            .csrf(csrf -> csrf.disable())
            
            // Enable CORS
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            
            // Stateless session management (no sessions, JWT only)
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            
            // Configure authorization rules
            .authorizeHttpRequests(auth -> auth
                // Public endpoints - no authentication required
                .requestMatchers("/").permitAll() // Root path for health check
                .requestMatchers("/health").permitAll() // Health check endpoint
                .requestMatchers("/actuator/health").permitAll() // Spring Boot Actuator health
                .requestMatchers("/error").permitAll() // Error pages
                .requestMatchers("/favicon.ico").permitAll() // Favicon
                
                // OAuth endpoints (if using OAuth2)
                .requestMatchers("/oauth2/**").permitAll()
                .requestMatchers("/login/oauth2/**").permitAll()
                
                // Public authentication endpoints
                .requestMatchers("/api/auth/admin/login").permitAll() // Admin login
                .requestMatchers("/api/auth/**").permitAll() // All auth endpoints (login, register, etc.)
                
                // Public product endpoints
                .requestMatchers("/api/products").permitAll() // List products
                .requestMatchers("/api/products/*").permitAll() // Get product by ID (single level)
                .requestMatchers("/api/products/images/**").permitAll() // Product images
                
                // Public profile photo access
                .requestMatchers("/api/auth/profile/photo/**").permitAll()
                
                // Public review endpoints (view only)
                .requestMatchers("/api/reviews/product/**").permitAll() // View product reviews
                
                // Public tracking endpoints
                .requestMatchers("/api/orders/*/tracking").permitAll()
                .requestMatchers("/api/orders/*/location-tracking").permitAll()
                .requestMatchers("/api/orders/by-order-number/**").permitAll()
                .requestMatchers("/api/orders/by-tracking-id/**").permitAll()
                
                // Protected endpoints - require authentication
                .requestMatchers("/api/products/upload").authenticated() // Upload product image
                .requestMatchers("/api/reviews/**").authenticated() // Add/delete reviews
                .requestMatchers("/api/cart/**").authenticated() // Cart operations
                .requestMatchers("/api/orders/customer/me").authenticated() // User's own orders
                .requestMatchers("/api/orders/**").authenticated() // Other order endpoints
                
                // Role-based endpoints
                .requestMatchers("/api/orders/all").hasRole("ADMIN") // Admin only
                .requestMatchers("/api/orders/customer/**").hasRole("ADMIN") // Admin viewing customer orders
                .requestMatchers("/api/delivery/**").hasAnyRole("DELIVERY_MAN", "ADMIN") // Delivery or admin
                .requestMatchers("/api/admin/**").hasRole("ADMIN") // Admin only
                .requestMatchers("/api/auth/admin/**").hasRole("ADMIN") // Admin auth endpoints
                .requestMatchers("/api/auth/admin/proof-documents/**").authenticated() // View proof documents
                
                // All other requests require authentication
                .anyRequest().authenticated()
            )
            // Add JWT filter before UsernamePasswordAuthenticationFilter
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

