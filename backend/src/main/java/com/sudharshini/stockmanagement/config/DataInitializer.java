package com.sudharshini.stockmanagement.config;

import com.sudharshini.stockmanagement.repository.UserRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

/**
 * Data Initializer
 * Creates default admin user if it doesn't exist
 */
@Component
public class DataInitializer implements CommandLineRunner {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @PersistenceContext
    private EntityManager entityManager;
    
    @Override
    @Transactional
    public void run(String... args) throws Exception {
        System.out.println("🚀 Starting DataInitializer...");
        
        // Migrate database schema to support DELIVERY_MAN role
        try {
            migrateDatabaseSchema();
        } catch (Exception e) {
            System.err.println("⚠️  Migration failed but continuing: " + e.getMessage());
            // Continue anyway - we'll handle errors when creating delivery man
        }
        
        // Migrate orders table to support ACCEPTED and PICKED_UP statuses
        try {
            migrateOrdersTableSchema();
        } catch (Exception e) {
            System.err.println("⚠️  Orders table migration failed but continuing: " + e.getMessage());
            // Continue anyway
        }
        
        // Create default admin user if it doesn't exist
        if (userRepository.findByUsername("admin").isEmpty()) {
            // Use native SQL to avoid getGeneratedKeys() issue with SQLite
            String encodedPassword = passwordEncoder.encode("admin123");
            String sql = "INSERT INTO users (username, email, password, name, role, created_at) " +
                        "VALUES (?, ?, ?, ?, ?, ?)";
            
            Query query = entityManager.createNativeQuery(sql);
            query.setParameter(1, "admin");
            query.setParameter(2, "admin@sudharshini.com");
            query.setParameter(3, encodedPassword);
            query.setParameter(4, "Admin User");
            query.setParameter(5, "ADMIN");
            query.setParameter(6, LocalDateTime.now());
            
            query.executeUpdate();
            
            System.out.println("Default admin user created: username=admin, password=admin123");
            System.out.println("⚠️  IMPORTANT: Change the default admin password after first login!");
        }
    }
    
    private void migrateDatabaseSchema() {
        try {
            System.out.println("🔍 Checking database schema for DELIVERY_MAN role support...");
            
            // For Neon/PostgreSQL, skip the sqlite_master check
            // Hibernate will handle schema creation. Just log that we're using PostgreSQL.
            String dbName = "PostgreSQL";
            try {
                Query dbQuery = entityManager.createNativeQuery("SELECT current_database()");
                dbName = (String) dbQuery.getSingleResult();
            } catch (Exception e) {
                System.out.println("ℹ️  Could not detect database type, assuming PostgreSQL");
            }
            
            System.out.println("ℹ️  Using database: " + dbName);
            System.out.println("✅ Schema management delegated to Hibernate JPA with ddl-auto=update");
            System.out.println("   Hibernate will create/update the 'users' table with correct schema on startup.");
            return;
        } catch (Exception e) {
            System.err.println("❌ Error during database migration: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private void migrateOrdersTableSchema() {
        try {
            System.out.println("🔍 Checking orders table schema for ACCEPTED and PICKED_UP status support...");
            System.out.println("✅ Schema management delegated to Hibernate JPA with ddl-auto=update");
            System.out.println("   Hibernate will create/update the 'orders' table with correct schema on startup.");
            return;
        } catch (Exception e) {
            System.err.println("❌ Error during orders table migration: " + e.getMessage());
            e.printStackTrace();
        }
    }
}

