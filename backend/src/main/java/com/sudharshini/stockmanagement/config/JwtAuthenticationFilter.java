package com.sudharshini.stockmanagement.config;

import com.sudharshini.stockmanagement.util.JwtUtil;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;

/**
 * JWT Authentication Filter
 * Validates JWT tokens and sets authentication context
 */
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    
    @Autowired
    private JwtUtil jwtUtil;
    
    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        
        // Skip JWT validation for public endpoints and OPTIONS requests
        String path = request.getRequestURI();
        
        // Skip OPTIONS requests (CORS preflight)
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            chain.doFilter(request, response);
            return;
        }
        
        // Skip JWT validation for public root and health endpoints
        if (path.equals("/") || path.equals("/health") || path.equals("/actuator/health")) {
            chain.doFilter(request, response);
            return;
        }
        
        // Skip JWT validation for error pages and favicon
        if (path.equals("/error") || path.equals("/favicon.ico") || path.startsWith("/favicon")) {
            chain.doFilter(request, response);
            return;
        }
        
        // Skip JWT validation for OAuth endpoints
        if (path.startsWith("/oauth2/") || path.startsWith("/login/oauth2/")) {
            chain.doFilter(request, response);
            return;
        }
        
        // Skip JWT validation for public auth endpoints (including admin login)
        if (path.equals("/api/auth/admin/login")) {
            chain.doFilter(request, response);
            return;
        }
        // Skip JWT validation for public auth endpoints, but NOT for profile endpoints
        // Profile endpoints require authentication
        if (path.startsWith("/api/auth/") && !path.startsWith("/api/auth/admin/") 
            && !path.equals("/api/auth/profile") && !path.equals("/api/auth/change-password")
            && !path.equals("/api/auth/profile/photo") && !path.startsWith("/api/auth/profile/photo/")
            && !path.equals("/api/auth/profile/addresses") && !path.startsWith("/api/auth/profile/addresses/")) {
            chain.doFilter(request, response);
            return;
        }
        
        // Allow public access to view product reviews (GET only)
        // POST requests to add reviews require authentication
        if (path.startsWith("/api/reviews/product/") && "GET".equalsIgnoreCase(request.getMethod())) {
            chain.doFilter(request, response);
            return;
        }
        
        // Skip JWT validation for public tracking endpoints
        // Match pattern: /api/orders/{any}/tracking or /api/orders/{any}/location-tracking
        if (path.matches("/api/orders/[^/]+/tracking") || path.matches("/api/orders/[^/]+/location-tracking")) {
            chain.doFilter(request, response);
            return;
        }
        
        // Skip JWT validation for profile photo serving (public access)
        if (path.startsWith("/api/auth/profile/photo/") && "GET".equalsIgnoreCase(request.getMethod())) {
            chain.doFilter(request, response);
            return;
        }
        
        final String authorizationHeader = request.getHeader("Authorization");
        
        String username = null;
        String jwt = null;
        String role = null;
        
        if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
            jwt = authorizationHeader.substring(7);
            try {
                username = jwtUtil.extractUsername(jwt);
                role = jwtUtil.extractRole(jwt);
                System.out.println("🔑 JWT Filter - Extracted username: " + username + ", role: " + role);
            } catch (Exception e) {
                System.out.println("❌ JWT token extraction failed for path: " + path);
                System.out.println("   Error: " + e.getMessage());
                logger.error("JWT token validation failed", e);
            }
        } else {
            System.out.println("⚠️ No Authorization header found for path: " + path);
        }
        
        if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            boolean isValid = jwtUtil.validateToken(jwt, username);
            System.out.println("🔍 [JWT Filter] Validation result for " + username + ": " + isValid);
            System.out.println("🔍 [JWT Filter] Extracted role: " + role);
            
            if (isValid) {
                // Ensure role follows Spring Security convention (ROLE_ prefix)
                String authority = role;
                if (role != null && !role.startsWith("ROLE_")) {
                    authority = "ROLE_" + role.toUpperCase();
                } else if (role != null) {
                    authority = role.toUpperCase();
                }
                
                System.out.println("🔍 [JWT Filter] Setting authority: " + authority);
                
                UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                    username, null, Collections.singletonList(new SimpleGrantedAuthority(authority))
                );
                authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(authToken);
                
                System.out.println("✅ [JWT Filter] Authentication set for user: " + username + " with role: " + authority);
                System.out.println("✅ [JWT Filter] Security context authorities: " + 
                    SecurityContextHolder.getContext().getAuthentication().getAuthorities());
            } else {
                System.out.println("❌ [JWT Filter] Token validation failed for user: " + username);
            }
        } else if (username == null && !path.startsWith("/api/auth/") && !path.startsWith("/api/products") 
                   && !path.matches("/api/orders/[^/]+/tracking") && !path.matches("/api/orders/[^/]+/location-tracking")
                   && !path.startsWith("/api/orders/by-order-number/") && !path.startsWith("/api/orders/by-tracking-id/")) {
            System.out.println("⚠️ [JWT Filter] No username extracted for protected path: " + path);
            System.out.println("⚠️ [JWT Filter] Authorization header: " + 
                (authorizationHeader != null ? authorizationHeader.substring(0, Math.min(20, authorizationHeader.length())) + "..." : "null"));
        }
        
        chain.doFilter(request, response);
    }
}

