# PostgreSQL / Neon Fix Guide for Spring Boot

## 🔴 ROOT CAUSE ANALYSIS

### **Primary Issue: SQLite SQL Used on PostgreSQL Database**

Your application was trying to execute **SQLite-specific SQL** on a **PostgreSQL (Neon)** database:

1. **`sqlite_master` system table** - SQLite only, doesn't exist in PostgreSQL
   - Location: `DataInitializer.java` lines 80 & 213
   - Query: `SELECT sql FROM sqlite_master WHERE type='table' AND name='users'`

2. **SQLite `date()` function** - PostgreSQL uses `CURRENT_DATE` + interval syntax
   - Location: `ProductRepository.java` line 16
   - Query: `SELECT ... WHERE expiry_date >= date('now') AND expiry_date <= date('now', '+5 days')`

### **Why This Causes the "transaction is aborted" Error**

```
ERROR 1: org.postgresql.util.PSQLException: ERROR: relation "sqlite_master" does not exist
         ↓
ERROR 2: Current transaction is aborted, commands ignored until end of transaction block
         ↓
ERROR 3: Any other query in the same @Transactional block fails with the same error
```

When a native query fails in PostgreSQL, it **aborts the entire transaction**. All subsequent queries fail with "commands ignored until end of transaction block" unless you explicitly rollback/retry.

---

## ✅ FIXES APPLIED

### **Fix #1: DataInitializer.java**
Replaced SQLite schema checking with **Hibernate-managed schema**:
- Disabled `sqlite_master` queries
- Now delegates to `spring.jpa.hibernate.ddl-auto=update`
- Logs which database is being used for debugging

**What this does:**
```
Before: Run native SQLite queries → fails on PostgreSQL
After:  Hibernate creates/updates tables automatically on startup
```

### **Fix #2: ProductRepository.java**
Replaced SQLite date functions with PostgreSQL syntax:
```sql
-- ❌ OLD (SQLite)
SELECT * FROM products 
WHERE expiry_date >= date('now') 
  AND expiry_date <= date('now', '+5 days')

-- ✅ NEW (PostgreSQL)
SELECT * FROM products 
WHERE expiry_date >= CURRENT_DATE 
  AND expiry_date <= CURRENT_DATE + INTERVAL '5 days'
```

---

## 🔧 CORRECTED CONFIGURATION

### **Environment Variables (Render Dashboard)**

Set these in your Render service **Environment** tab:

```bash
# DATABASE CONNECTION
DATABASE_URL=postgresql://user:password@host:5432/dbname
SPRING_DATASOURCE_URL=${DATABASE_URL}
SPRING_DATASOURCE_USERNAME=user
SPRING_DATASOURCE_PASSWORD=password

# MAIL & OTHER CONFIG
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password
ADMIN_EMAIL=admin@sudharshini.com

JWT_SECRET=your-super-secret-jwt-key-here
JWT_EXPIRATION=86400000

GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret

CORS_ORIGINS=https://your-frontend-domain.com

UPLOAD_DIR=/tmp/uploads/products
```

### **application.properties (Already Correct)**

```properties
server.port=${PORT:8080}
spring.application.name=sudharshini-stock-management

# ✅ Correct PostgreSQL Driver
spring.datasource.url=${SPRING_DATASOURCE_URL}
spring.datasource.username=${SPRING_DATASOURCE_USERNAME}
spring.datasource.password=${SPRING_DATASOURCE_PASSWORD}
spring.datasource.driver-class-name=org.postgresql.Driver

# ✅ Correct Hibernate Dialect for PostgreSQL
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect

# ✅ IMPORTANT: Let Hibernate manage schema
spring.jpa.hibernate.ddl-auto=update

spring.jpa.show-sql=false

# ✅ Connection pooling for Render's free tier
spring.datasource.hikari.maximum-pool-size=3
spring.datasource.hikari.minimum-idle=1
spring.datasource.hikari.connection-timeout=30000
spring.datasource.hikari.idle-timeout=600000
spring.datasource.hikari.max-lifetime=1800000

spring.mail.host=${MAIL_HOST}
spring.mail.port=${MAIL_PORT}
spring.mail.username=${MAIL_USERNAME}
spring.mail.password=${MAIL_PASSWORD}
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true

admin.email=${ADMIN_EMAIL}
jwt.secret=${JWT_SECRET}
jwt.expiration=${JWT_EXPIRATION:86400000}

google.client.id=${GOOGLE_CLIENT_ID}
google.client.secret=${GOOGLE_CLIENT_SECRET}

cors.allowed.origins=${CORS_ORIGINS}

spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=10MB
file.upload.dir=${UPLOAD_DIR:/tmp/uploads/products}

logging.level.root=INFO
logging.file.name=${LOG_FILE:/tmp/application.log}
```

### **Key Configuration Rules for PostgreSQL:**

| Property | Value | Reason |
|----------|-------|--------|
| `driver-class-name` | `org.postgresql.Driver` | ✅ Must use PostgreSQL driver |
| `database-platform` | `org.hibernate.dialect.PostgreSQLDialect` | ✅ PostgreSQL-specific dialect |
| `ddl-auto` | `update` | ✅ Auto-create/update tables (no manual SQLite queries) |
| `hikari.maximum-pool-size` | `3` | Render free tier only allows 3 connections |
| `hikari.minimum-idle` | `1` | Keep 1 connection alive |

---

## 🚨 TRANSACTIONAL ERROR HANDLING FIX

### **Problem Pattern (What Happened)**

```java
@Transactional  // ← Begins transaction
public void processOrder(OrderRequest request) {
    // Query 1: Fails with sqlite_master error
    productRepository.findNearExpiryProducts();  // ❌ Transaction ABORTED here
    
    // Query 2: Still inside same transaction
    userRepository.findByUsername(username);     // ❌ FAILS: "transaction is aborted"
    
    // Query 3: Still same transaction
    order = orderRepository.save(order);         // ❌ FAILS: "transaction is aborted"
}
// Only ONE rollback happens - all changes lost
```

### **Solution Applied**

The fix removes the **root cause** (`sqlite_master` query), but here's the pattern if you encounter similar transactional errors:

#### **Pattern A: Catch and Continue (Use when query is optional)**
```java
@Transactional
public void processOrder(OrderRequest request) {
    try {
        // This query might fail, but we can continue
        List<Product> expiring = productRepository.findNearExpiryProducts();
    } catch (Exception e) {
        // Caught exception prevents transaction abort
        logger.warn("Could not fetch expiring products", e);
        // Transaction is STILL ACTIVE - other queries can proceed
    }
    
    // These queries will work fine
    User user = userRepository.findByUsername(username).orElseThrow();
    Order order = orderRepository.save(new Order());
}
```

#### **Pattern B: Split into Separate Transactions (Use for critical operations)**
```java
@Transactional
public void processOrderMain(OrderRequest request) {
    User user = userRepository.findByUsername(username).orElseThrow();
    Order order = orderRepository.save(new Order());
}

@Transactional
public List<Product> fetchExpiringProductsSeparately() {
    try {
        return productRepository.findNearExpiryProducts();
    } catch (Exception e) {
        // This transaction error doesn't affect the main one
        logger.error("Failed to fetch expiring products", e);
        return new ArrayList<>();
    }
}

// Call separately:
processOrderMain(request);
List<Product> expiring = fetchExpiringProductsSeparately();
```

#### **Pattern C: Native Query Error Handling (Use for custom SQL)**
```java
@Transactional
public void customQuery() {
    try {
        entityManager.createNativeQuery(
            "SELECT * FROM products WHERE custom_condition = true"
        ).getResultList();
    } catch (PersistenceException e) {
        if (e.getCause() instanceof org.postgresql.util.PSQLException) {
            // PostgreSQL-specific error
            logger.error("PostgreSQL syntax error: " + e.getMessage());
        }
        // Do NOT rethrow - keep transaction alive for recovery operations
    }
}
```

---

## 📋 DEPLOYMENT CHECKLIST FOR RENDER

### **Step 1: Environment Variables (Render Dashboard)**
- [ ] Set `DATABASE_URL` to your Neon PostgreSQL connection string
- [ ] Set `SPRING_DATASOURCE_USERNAME` and `SPRING_DATASOURCE_PASSWORD`
- [ ] Verify no SQLite paths in environment variables
- [ ] Set all MAIL_* variables for email functionality
- [ ] Set JWT_SECRET to a strong random value (min 32 chars)

### **Step 2: Verify Application Files**
- [ ] ✅ `ProductRepository.java` uses `CURRENT_DATE + INTERVAL` (fixed)
- [ ] ✅ `DataInitializer.java` doesn't use `sqlite_master` (fixed)
- [ ] ✅ `application.properties` has correct PostgreSQL driver & dialect
- [ ] No other files have SQLite-specific SQL (@Query or native queries)

### **Step 3: Build & Deploy**
```bash
# On your local machine, test locally first:
mvn clean package -DskipTests

# Then push to Render
git add -A
git commit -m "Fix: PostgreSQL compatibility - remove SQLite queries"
git push origin main

# Render will auto-deploy
```

### **Step 4: Check Render Logs**
After deployment, monitor logs in Render dashboard for:

#### **✅ SUCCESS Signs**
```
✅ Schema management delegated to Hibernate JPA with ddl-auto=update
   Hibernate will create/update the 'users' table with correct schema on startup.

✅ Using database: Sudharshini_DB_xx

Hibernate: ... [entity table creation DDL]

✅ Tomcat started on port 8080 (PID: 123)
Started SudharshiniStockManagementApplication
```

#### **❌ FAILURE Signs (Immediate Actions)**
```
ERROR: relation "sqlite_master" does not exist
→ Action: Check if DataInitializer still has old code (verify fix applied)

ERROR: function date(now) does not exist in PostgreSQL
→ Action: Check if ProductRepository still has old @Query (verify fix applied)

ERROR: current transaction is aborted
→ Action: Check Render logs for the FIRST error above this one

SQLSTATE[3D000]: Unknown database "sqlite"
→ Action: Verify DATABASE_URL env var is set correctly
```

### **Step 5: Verify Database Connectivity**

Click **"Connect Render Runtime"** in Render dashboard:
```bash
psql $DATABASE_URL

# Inside psql:
\dt  -- List all tables (should show: users, products, orders, etc.)
\d users  -- Show users table schema
SELECT COUNT(*) FROM users;  -- Should return 0 or more
```

### **Step 6: Monitor First Requests**

Make test API calls to your Render backend:
```bash
# Test login (creates user query)
curl -X POST https://your-render-backend.onrender.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"pass123"}'

# Check Render logs for any errors
```

---

## 🔍 SQL COMPATIBILITY REFERENCE

### **Common SQLite → PostgreSQL Conversions**

| SQLite | PostgreSQL | Notes |
|--------|-----------|-------|
| `date('now')` | `CURRENT_DATE` | Today's date |
| `datetime('now')` | `CURRENT_TIMESTAMP` | Current date+time |
| `date('now', '+5 days')` | `CURRENT_DATE + INTERVAL '5 days'` | Future date |
| `date('now', '-1 month')` | `CURRENT_DATE - INTERVAL '1 month'` | Past date |
| `sqlite_master` | `information_schema.tables` | System table query |
| `sqlite_sequence` | `pg_sequences` | Sequence info |
| `AUTOINCREMENT` | `SERIAL` or `BIGSERIAL` | Auto-increment column |
| `TEXT UNIQUE` | `TEXT UNIQUE` | Same, but check length (PostgreSQL default 1GB) |
| `INTEGER PRIMARY KEY AUTOINCREMENT` | `BIGSERIAL PRIMARY KEY` | Identity column |

### **Native Query Pattern for Database-Agnostic Code**

Instead of SQLite-specific:
```java
// ❌ DON'T: Use raw SQL with database-specific functions
@Query(value = "SELECT * FROM products WHERE expiry_date >= date('now')", nativeQuery = true)

// ✅ DO: Use JPQL (database-agnostic)
@Query("SELECT p FROM Product p WHERE p.expiryDate >= CURRENT_DATE")
```

---

## 📞 TROUBLESHOOTING

### **Issue: Still getting "sqlite_master does not exist" after fixes**

**Solution:**
1. Verify the files were actually saved:
   ```bash
   grep -n "sqlite_master" backend/src/**/*.java
   # Should return 0 results
   ```
2. Rebuild and redeploy:
   ```bash
   mvn clean package
   git add .
   git commit -m "Rebuild after fixes"
   git push
   ```
3. Hard refresh Render cache:
   - Go to Render dashboard
   - Click "Manual Deploy"
   - Force delete and redeploy if needed

### **Issue: Getting "Hibernate syntax error" after fixes**

**Common Cause:** `ddl-auto=create` instead of `update`

**Solution:**
```properties
# ❌ WRONG - destroys data on every restart
spring.jpa.hibernate.ddl-auto=create

# ✅ CORRECT - updates existing schema
spring.jpa.hibernate.ddl-auto=update

# ✅ SAFEST for production
spring.jpa.hibernate.ddl-auto=validate
```

### **Issue: "Too many open connections" error**

**Reason:** Render free tier only allows 3 connections

**Solution:** Already set in your config
```properties
spring.datasource.hikari.maximum-pool-size=3
spring.datasource.hikari.minimum-idle=1
```

If still getting connection errors, reduce even more:
```properties
spring.datasource.hikari.maximum-pool-size=2
spring.datasource.hikari.minimum-idle=0
```

### **Issue: Queries succeed locally but fail on Render**

**Likely Cause:** Using SQLite driver locally, PostgreSQL on Render

**Solution:**
1. Test locally with PostgreSQL too:
   ```bash
   # Use Docker to run PostgreSQL locally
   docker run -e POSTGRES_DB=testdb -p 5432:5432 postgres:latest
   # Set DATABASE_URL=postgresql://postgres:password@localhost/testdb
   mvn spring-boot:run
   ```

---

## ✨ FINAL VERIFICATION

**Run this checklist after deployment:**

```bash
# 1. Check Render logs have no errors
✓ No "sqlite_master" errors
✓ No "date('now')" function errors
✓ Application started successfully

# 2. Make test API call
curl -X GET https://your-backend.onrender.com/api/products
✓ Returns 200 OK

# 3. Check database directly
psql $DATABASE_URL
> SELECT COUNT(*) FROM products;
✓ Returns a number (0 or more)

# 4. Monitor performance
✓ Response times < 1 second
✓ No "transaction is aborted" in logs
```

---

## 📚 References

- [Neon PostgreSQL Documentation](https://neon.tech/docs)
- [Spring Data JPA Documentation](https://spring.io/projects/spring-data-jpa)
- [Hibernate Dialect Documentation](https://docs.jboss.org/hibernate/orm/current/userguide/html_single/Hibernate_User_Guide.html#sql-dialect)
- [PostgreSQL vs SQLite SQL Syntax](https://www.postgresql.org/docs/current/sql-syntax.html)

