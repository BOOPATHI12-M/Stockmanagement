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
            
            // Check if the users table exists and has the old constraint
            Query checkQuery = entityManager.createNativeQuery(
                "SELECT sql FROM sqlite_master WHERE type='table' AND name='users'"
            );
            
            @SuppressWarnings("unchecked")
            java.util.List<Object> results = checkQuery.getResultList();
            
            if (results.isEmpty()) {
                System.out.println("ℹ️  Users table doesn't exist yet. It will be created by Hibernate with the correct schema.");
                return;
            }
            
            String tableSql = (String) results.get(0);
            if (tableSql == null) {
                System.out.println("⚠️  Could not retrieve table schema");
                return;
            }
            
            // Print full schema for debugging
            System.out.println("📋 Full table schema:");
            System.out.println(tableSql);
            
            // Convert to uppercase for case-insensitive matching
            String upperTableSql = tableSql.toUpperCase();
            
            // Check if there's a CHECK constraint on the role column
            boolean hasCheckConstraint = upperTableSql.contains("CHECK") && upperTableSql.contains("ROLE");
            boolean needsMigration = false;
            
            if (hasCheckConstraint) {
                System.out.println("🔍 CHECK constraint found on role column");
                
                // Check if DELIVERY_MAN is mentioned in the constraint
                boolean hasDeliveryMan = upperTableSql.contains("'DELIVERY_MAN'") || upperTableSql.contains("\"DELIVERY_MAN\"");
                
                if (!hasDeliveryMan) {
                    // If there's a CHECK constraint but DELIVERY_MAN is not included, we need to migrate
                    needsMigration = true;
                    System.out.println("⚠️  CHECK constraint found but DELIVERY_MAN is not included - migration needed");
                    
                    // Try to extract the constraint pattern for logging
                    if (upperTableSql.contains("ROLE IN ('CUSTOMER','ADMIN')") || 
                        upperTableSql.contains("ROLE IN('CUSTOMER','ADMIN')")) {
                        System.out.println("   Detected pattern: role IN ('CUSTOMER','ADMIN')");
                    }
                } else {
                    System.out.println("✅ CHECK constraint includes DELIVERY_MAN - no migration needed");
                }
            } else {
                System.out.println("✅ No CHECK constraint found on role column - all roles are supported");
            }
            
            // If there's a CHECK constraint but it doesn't include DELIVERY_MAN, we need to migrate
            if (needsMigration) {
                System.out.println("🔄 Migrating database schema to support DELIVERY_MAN role...");
                
                // Get count of existing users for verification
                Query countQuery = entityManager.createNativeQuery("SELECT COUNT(*) FROM users");
                Long userCount = ((Number) countQuery.getSingleResult()).longValue();
                System.out.println("📊 Found " + userCount + " existing users to migrate");
                
                // Create backup table with all data
                entityManager.createNativeQuery(
                    "CREATE TABLE users_backup AS SELECT * FROM users"
                ).executeUpdate();
                System.out.println("💾 Backup table created");
                
                // Drop old table
                entityManager.createNativeQuery("DROP TABLE users").executeUpdate();
                System.out.println("🗑️  Old table dropped");
                
                // Recreate table WITHOUT CHECK constraint - we validate at application level
                // This avoids constraint issues and is more flexible
                String createTableSql = 
                    "CREATE TABLE users (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                    "email TEXT UNIQUE NOT NULL, " +
                    "name TEXT, " +
                    "mobile TEXT, " +
                    "role TEXT NOT NULL, " +
                    "username TEXT, " +
                    "password TEXT, " +
                    "google_id TEXT, " +
                    "whatsapp_number TEXT, " +
                    "telegram_chat_id TEXT, " +
                    "created_at TIMESTAMP" +
                    ")";
                
                entityManager.createNativeQuery(createTableSql).executeUpdate();
                System.out.println("✨ New table created with DELIVERY_MAN support");
                
                // Restore all data from backup - explicitly specify column names to avoid column order issues
                entityManager.createNativeQuery(
                    "INSERT INTO users (id, email, name, mobile, role, username, password, google_id, whatsapp_number, telegram_chat_id, created_at) " +
                    "SELECT id, email, name, mobile, role, username, password, google_id, whatsapp_number, telegram_chat_id, created_at FROM users_backup"
                ).executeUpdate();
                
                // Verify data was restored
                Query verifyQuery = entityManager.createNativeQuery("SELECT COUNT(*) FROM users");
                Long restoredCount = ((Number) verifyQuery.getSingleResult()).longValue();
                System.out.println("✅ Restored " + restoredCount + " users");
                
                if (!userCount.equals(restoredCount)) {
                    throw new RuntimeException("Data loss detected! Expected " + userCount + " users but found " + restoredCount);
                }
                
                // Drop backup table
                entityManager.createNativeQuery("DROP TABLE users_backup").executeUpdate();
                System.out.println("🗑️  Backup table removed");
                
                System.out.println("✅ Database schema migrated successfully! CHECK constraint removed - DELIVERY_MAN role is now supported.");
            } else if (hasCheckConstraint && tableSql.contains("DELIVERY_MAN")) {
                System.out.println("✅ Database schema is up to date. DELIVERY_MAN role is supported.");
            } else if (!hasCheckConstraint) {
                System.out.println("✅ Database schema is up to date. No CHECK constraint found - all roles are supported.");
            } else {
                System.out.println("✅ Database schema check completed.");
            }
        } catch (Exception e) {
            System.err.println("❌ Error during database migration: " + e.getMessage());
            e.printStackTrace();
            System.err.println("⚠️  Application will continue, but DELIVERY_MAN role creation may fail.");
            System.err.println("   Please check the database schema manually or restart the application.");
            // Don't throw - allow application to continue
            // The migration will be retried on next startup if needed
        }
    }
    
    private void migrateOrdersTableSchema() {
        try {
            System.out.println("🔍 Checking orders table schema for ACCEPTED and PICKED_UP status support...");
            
            // Check if the orders table exists
            Query checkQuery = entityManager.createNativeQuery(
                "SELECT sql FROM sqlite_master WHERE type='table' AND name='orders'"
            );
            
            @SuppressWarnings("unchecked")
            java.util.List<Object> results = checkQuery.getResultList();
            
            if (results.isEmpty()) {
                System.out.println("ℹ️  Orders table doesn't exist yet. It will be created by Hibernate with the correct schema.");
                return;
            }
            
            String tableSql = (String) results.get(0);
            if (tableSql == null) {
                System.out.println("⚠️  Could not retrieve orders table schema");
                return;
            }
            
            // Print full schema for debugging
            System.out.println("📋 Orders table schema:");
            System.out.println(tableSql);
            
            // Convert to uppercase for case-insensitive matching
            String upperTableSql = tableSql.toUpperCase();
            
            // Check if there's a CHECK constraint on the status column that doesn't include ACCEPTED and PICKED_UP
            boolean hasCheckConstraint = upperTableSql.contains("CHECK") && upperTableSql.contains("STATUS");
            boolean includesAccepted = upperTableSql.contains("'ACCEPTED'") || upperTableSql.contains("\"ACCEPTED\"");
            boolean includesPickedUp = upperTableSql.contains("'PICKED_UP'") || upperTableSql.contains("\"PICKED_UP\"");
            
            boolean needsMigration = false;
            
            if (hasCheckConstraint && (!includesAccepted || !includesPickedUp)) {
                needsMigration = true;
                System.out.println("⚠️  CHECK constraint found but ACCEPTED or PICKED_UP is missing - migration needed");
            } else if (!hasCheckConstraint) {
                System.out.println("✅ No explicit CHECK constraint found on status column - all statuses are supported.");
            } else {
                System.out.println("✅ Database schema is up to date. CHECK constraint found and ACCEPTED/PICKED_UP statuses are supported.");
            }
            
            if (needsMigration) {
                System.out.println("🔄 Migrating orders table schema to support ACCEPTED and PICKED_UP statuses...");
                
                // Get count of existing orders for verification
                Query countQuery = entityManager.createNativeQuery("SELECT COUNT(*) FROM orders");
                Long orderCount = ((Number) countQuery.getSingleResult()).longValue();
                System.out.println("📊 Found " + orderCount + " existing orders to migrate");
                
                if (orderCount > 0) {
                    // Create backup table with all data
                    entityManager.createNativeQuery(
                        "CREATE TABLE orders_backup AS SELECT * FROM orders"
                    ).executeUpdate();
                    System.out.println("💾 Backup table created");
                }
                
                // Drop old table - Hibernate will recreate it without the CHECK constraint
                entityManager.createNativeQuery("DROP TABLE orders").executeUpdate();
                System.out.println("🗑️  Old table dropped");
                
                // Clear entity manager to force Hibernate to recreate the table
                entityManager.clear();
                
                System.out.println("✨ Table will be recreated by Hibernate on next operation without CHECK constraint");
                if (orderCount > 0) {
                    System.out.println("⚠️  Note: Existing orders data is backed up in orders_backup table");
                    System.out.println("   The table will be recreated and data can be restored if needed");
                }
                
                System.out.println("✅ Orders table schema migration initiated. Restart the application to complete the migration.");
            } else {
                System.out.println("✅ Orders table schema is up to date. No migration needed for ACCEPTED/PICKED_UP statuses.");
            }
        } catch (Exception e) {
            System.err.println("❌ Error during orders table migration: " + e.getMessage());
            e.printStackTrace();
            // Don't throw - allow app to continue
        }
    }
}

