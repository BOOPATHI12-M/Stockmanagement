package com.sudharshini.stockmanagement.controller;

import com.sudharshini.stockmanagement.entity.Product;
import com.sudharshini.stockmanagement.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Report Controller
 * Handles dashboard reports and summaries
 */
@RestController
@RequestMapping("/api/reports")
@CrossOrigin(origins = "*")
public class ReportController {
    
    @Autowired
    private ProductRepository productRepository;
    
    @GetMapping("/summary")
    @Transactional(readOnly = true)
    public ResponseEntity<?> getSummary() {
        System.out.println("🔵 [GET SUMMARY] Starting summary generation...");
        try {
            List<Product> allProducts;
            try {
                allProducts = productRepository.findAll();
                System.out.println("🔵 [GET SUMMARY] Found " + (allProducts != null ? allProducts.size() : 0) + " products");
            } catch (Exception e) {
                System.err.println("❌ [GET SUMMARY] Error fetching all products: " + e.getMessage());
                e.printStackTrace();
                allProducts = List.of();
            }
            
            List<Product> lowStock;
            try {
                lowStock = productRepository.findByStockQuantityLessThan(10);
                System.out.println("🔵 [GET SUMMARY] Found " + (lowStock != null ? lowStock.size() : 0) + " low stock items");
            } catch (Exception e) {
                System.err.println("❌ [GET SUMMARY] Error fetching low stock: " + e.getMessage());
                e.printStackTrace();
                lowStock = List.of();
            }
            
            // Safely get near expiry products (within 5 days)
            List<Product> nearExpiry = List.of();
            try {
                nearExpiry = productRepository.findNearExpiryProducts();
                System.out.println("🔵 [GET SUMMARY] Found " + (nearExpiry != null ? nearExpiry.size() : 0) + " near expiry items (expiring within 5 days)");
                
                // Log details of near expiry products for debugging
                if (nearExpiry != null && !nearExpiry.isEmpty()) {
                    System.out.println("📅 [GET SUMMARY] Near expiry products:");
                    for (Product p : nearExpiry) {
                        System.out.println("   - " + p.getName() + " (ID: " + p.getId() + ") expires on: " + p.getExpiryDate());
                    }
                }
                
                // Fallback: If SQL query returns empty but we have products with expiry dates, check manually
                if ((nearExpiry == null || nearExpiry.isEmpty()) && allProducts != null && !allProducts.isEmpty()) {
                    System.out.println("🔍 [GET SUMMARY] SQL query returned empty, checking products manually...");
                    List<Product> manualCheck = allProducts.stream()
                        .filter(p -> p != null && p.getExpiryDate() != null && p.isNearExpiry())
                        .toList();
                    if (!manualCheck.isEmpty()) {
                        System.out.println("✅ [GET SUMMARY] Found " + manualCheck.size() + " near expiry products via manual check");
                        nearExpiry = manualCheck;
                    }
                }
            } catch (Exception e) {
                System.err.println("⚠️ [GET SUMMARY] Warning: Error fetching near expiry products: " + e.getMessage());
                e.printStackTrace();
                
                // Fallback: Try manual check if SQL query fails
                try {
                    if (allProducts != null && !allProducts.isEmpty()) {
                        System.out.println("🔍 [GET SUMMARY] Attempting fallback manual check for near expiry products...");
                        List<Product> manualCheck = allProducts.stream()
                            .filter(p -> p != null && p.getExpiryDate() != null && p.isNearExpiry())
                            .toList();
                        if (!manualCheck.isEmpty()) {
                            System.out.println("✅ [GET SUMMARY] Fallback found " + manualCheck.size() + " near expiry products");
                            nearExpiry = manualCheck;
                        }
                    }
                } catch (Exception fallbackError) {
                    System.err.println("❌ [GET SUMMARY] Fallback also failed: " + fallbackError.getMessage());
                }
            }
            
            // Calculate total stock value
            BigDecimal totalStockValue = BigDecimal.ZERO;
            try {
                if (allProducts != null && !allProducts.isEmpty()) {
                    totalStockValue = allProducts.stream()
                            .filter(p -> p != null && p.getPrice() != null && p.getStockQuantity() != null)
                            .map(p -> {
                                try {
                                    return p.getPrice().multiply(BigDecimal.valueOf(p.getStockQuantity()));
                                } catch (Exception ex) {
                                    System.err.println("⚠️ Warning: Error calculating value for product " + p.getId() + ": " + ex.getMessage());
                                    return BigDecimal.ZERO;
                                }
                            })
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
                }
                System.out.println("🔵 [GET SUMMARY] Total stock value: " + totalStockValue);
            } catch (Exception e) {
                System.err.println("⚠️ [GET SUMMARY] Warning: Error calculating total stock value: " + e.getMessage());
                e.printStackTrace();
                // Continue with zero value
            }
            
            Map<String, Object> summary = new HashMap<>();
            summary.put("totalProducts", allProducts != null ? allProducts.size() : 0);
            summary.put("totalStockValue", totalStockValue);
            summary.put("lowStockCount", lowStock != null ? lowStock.size() : 0);
            summary.put("lowStockItems", lowStock != null ? lowStock : List.of());
            summary.put("nearExpiryCount", nearExpiry != null ? nearExpiry.size() : 0);
            summary.put("nearExpiryItems", nearExpiry != null ? nearExpiry : List.of());
            
            System.out.println("✅ [GET SUMMARY] Summary generated successfully");
            return ResponseEntity.ok(summary);
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("❌ [GET SUMMARY] Error in getSummary: " + e.getMessage());
            System.err.println("❌ [GET SUMMARY] Exception type: " + e.getClass().getName());
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of(
                "error", "Failed to load summary",
                "message", e.getMessage() != null ? e.getMessage() : "Unknown error",
                "exceptionType", e.getClass().getSimpleName()
            ));
        }
    }
}

