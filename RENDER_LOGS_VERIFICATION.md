# Render Logs Verification Checklist

After deploying the PostgreSQL fixes, use this checklist to confirm everything is working correctly on Render.

---

## 📊 HOW TO VIEW LOGS ON RENDER

1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click on your backend service
3. Click **"Logs"** tab
4. Look for recent entries (sorting by newest first)

---

## ✅ SUCCESS CHECKLIST

### **Step 1: Check Application Start Logs**

**Expected log messages (in order):**

```
✅ [SUCCESS] Log appears with this text:
"✅ Schema management delegated to Hibernate JPA with ddl-auto=update"

✅ [SUCCESS] Log appears with database name:
"ℹ️  Using database: <your_neon_database_name>"

✅ [SUCCESS] Hibernate creates tables:
"Hibernate: CREATE TABLE users (...)"
"Hibernate: CREATE TABLE products (...)"
"Hibernate: CREATE TABLE orders (...)"

✅ [SUCCESS] Application fully started:
"Tomcat started on port 8080"
"Started SudharshiniStockManagementApplication"
```

**Example of GOOD startup log:**
```
2024-01-17 12:34:56.123 INFO  - Starting SudharshiniStockManagementApplication
2024-01-17 12:34:58.456 INFO  - ✅ Schema management delegated to Hibernate JPA with ddl-auto=update
2024-01-17 12:34:58.457 INFO  - ℹ️  Using database: sudharshini_db_neon
2024-01-17 12:34:59.123 INFO  - Hibernate: CREATE TABLE users (id BIGSERIAL PRIMARY KEY, ...)
2024-01-17 12:35:00.234 INFO  - Hibernate: CREATE TABLE products (id BIGSERIAL PRIMARY KEY, ...)
2024-01-17 12:35:01.345 INFO  - Tomcat started on port 8080 (PID: 12345)
2024-01-17 12:35:02.456 INFO  - Started SudharshiniStockManagementApplication in 6.789 seconds
```

### **Step 2: Check for SQLite Errors**

**CRITICAL: Search logs for these errors (should NOT appear)**

```
❌ [CRITICAL] Do NOT see:
"ERROR: relation "sqlite_master" does not exist"
"ERROR: function date(now) does not exist"
"ERROR: syntax error at or near 'AUTOINCREMENT'"
"ERROR: current transaction is aborted"

If you see these → Fix not applied correctly, re-deploy
```

### **Step 3: Test API Calls**

After confirming logs are clean, test the API:

```bash
# Test 1: Get all products
curl -X GET https://your-backend.onrender.com/api/products

# Expected response:
# HTTP 200 OK
# Body: [] or [{ id, name, price, ... }]

# Check Render logs for:
✅ [SUCCESS] "GET /api/products" appears with "200" status code
```

```bash
# Test 2: Try login (uses findByUsername query)
curl -X POST https://your-backend.onrender.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# Expected response:
# HTTP 200 OK with JWT token
# OR HTTP 401 with "Invalid credentials"

# Check Render logs for:
✅ [SUCCESS] "POST /api/auth/login" appears with "200" or "401" status
❌ [FAILURE] No "sqlite_master" errors
```

### **Step 4: Check for Connection Errors**

**Normal warning (OK to see):**
```
WARN - HikariPool-1 - Connection is not available, request timed out
```
This is normal on Render free tier when pool is saturated - app will retry.

**NOT OK to see:**
```
❌ ERROR - Connection refused
❌ ERROR - Unknown database name
❌ ERROR - Invalid authentication
```

### **Step 5: Monitor Response Times**

**GOOD response times:**
```
✅ API response: 200-500ms (database queries)
✅ Login: 300-800ms (password hashing + query)
✅ Product list: 100-300ms (simple query)
```

**BAD response times:**
```
❌ All requests > 10 seconds → connection pool issue or query hanging
❌ Random timeouts → Render dyno restarting
❌ Getting 503 Service Unavailable → Build failed
```

---

## 🔴 FAILURE SCENARIOS

### **Scenario 1: Still seeing "sqlite_master" error**

**Logs will show:**
```
ERROR - org.postgresql.util.PSQLException: ERROR: relation "sqlite_master" does not exist
```

**Causes & Solutions:**
1. **Code changes didn't deploy**
   - [ ] Verify files are updated locally: `grep sqlite_master backend/src/**/*.java`
   - [ ] Rebuild: `mvn clean package`
   - [ ] Push again: `git push origin main`
   - [ ] Wait 2-3 minutes for Render auto-deploy

2. **Force refresh deployment**
   - [ ] Go to Render Dashboard
   - [ ] Click "Manual Deploy" button
   - [ ] Wait for green checkmark

3. **Check if correct files were edited**
   - [ ] `backend/src/main/java/com/sudharshini/stockmanagement/config/DataInitializer.java` should have `return;` after "Schema management delegated"
   - [ ] `backend/src/main/java/com/sudharshini/stockmanagement/repository/ProductRepository.java` should use `CURRENT_DATE + INTERVAL`

---

### **Scenario 2: "ERROR: function date(now) does not exist"**

**Logs will show:**
```
ERROR - org.hibernate.query.QuerySyntaxError: ERROR: function date(now) does not exist
```

**Cause:** `ProductRepository.findNearExpiryProducts()` query wasn't updated

**Solution:**
```bash
# Step 1: Verify the query was updated
grep -n "date('now')" backend/src/main/java/com/sudharshini/stockmanagement/repository/ProductRepository.java

# If it shows results → file wasn't updated correctly
# Step 2: Manually verify the query is:
# "SELECT * FROM products WHERE expiry_date >= CURRENT_DATE AND expiry_date <= CURRENT_DATE + INTERVAL '5 days'"

# Step 3: Rebuild and push
mvn clean package
git add backend/src/main/java/com/sudharshini/stockmanagement/repository/ProductRepository.java
git commit -m "Fix: Update ProductRepository to use PostgreSQL date functions"
git push origin main
```

---

### **Scenario 3: "ERROR: current transaction is aborted"**

**Logs will show:**
```
ERROR - org.postgresql.util.PSQLException: ERROR: current transaction is aborted, commands ignored until end of transaction block
```

**Cause:** A previous query in the same @Transactional method failed

**To find root cause:**
1. Look ABOVE this error in the logs for the FIRST error
2. It might be one of:
   - SQLite query (should be fixed now)
   - Invalid SQL syntax
   - Constraint violation
3. Fix that root error, deploy again

---

### **Scenario 4: "ERROR: relation \"users\" does not exist"**

**Logs will show:**
```
ERROR - org.hibernate.engine.jdbc.spi.SqlExceptionHelper: ERROR: relation "users" does not exist
```

**Possible causes:**
1. **Hibernate didn't create the table** → Check for schema creation errors in startup logs
2. **Wrong database** → `DATABASE_URL` env var points to wrong PostgreSQL database
3. **Table creation failed due to constraint** → Check Hibernate logs above this error

**Solutions:**
```bash
# Check 1: Verify database connection
psql $DATABASE_URL
# If this fails → DATABASE_URL is wrong

# Check 2: Connect and list tables
psql $DATABASE_URL
> \dt
# Should show: users, products, orders, etc.
# If empty → Hibernate never ran

# Check 3: Restart app on Render
# Go to Render Dashboard → Click "Restart" button
# Wait 60 seconds for Hibernate to initialize
```

---

### **Scenario 5: 503 Service Unavailable**

**Logs will show:**
```
ERROR - Build failed
```

**Cause:** Maven compilation error during build

**Solution:**
1. Check build log in Render Dashboard → "Build" tab
2. Look for Java compilation error
3. Common issues:
   - Syntax error in fixed code → verify edits were correct
   - Missing dependency → check pom.xml
   - Java version mismatch → should be Java 17+

```bash
# Test locally:
mvn clean package -DskipTests
# If this fails locally → fix the error first
# Then push to Render
```

---

## 📈 REAL-TIME MONITORING

### **Set up alerts in Render**

1. Go to Render Dashboard
2. Click your backend service
3. Click **"Settings"**
4. Scroll to **"Notifications"**
5. Add email or Slack alerts for:
   - [ ] Build failure
   - [ ] Service down (stopped)
   - [ ] Critical errors in logs

### **Check metrics while running**

In Render dashboard, monitor:
- **Memory usage:** Should be < 500MB (free tier limit)
- **CPU:** Should spike during requests, return to 0% idle
- **Response time:** Should be consistent (not growing over time)
- **Request count:** Should match your traffic

---

## 🧪 SPECIFIC TEST CASES

Run these after confirming basic startup:

### **Test Case 1: User Registration (Transactional Test)**
```bash
curl -X POST https://your-backend.onrender.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "TestPass123@",
    "name": "Test User",
    "phone": "9876543210"
  }'

# Expected:
# ✅ HTTP 201 Created with new user data
# ✅ Logs show: "POST /api/auth/register" with 201

# If fails:
# ❌ Check for "role" constraint errors (should be fixed now)
# ❌ Check for transactional errors
```

### **Test Case 2: Product Expiry Query (Date Function Test)**
```bash
# This internally calls findNearExpiryProducts()
curl -X GET "https://your-backend.onrender.com/api/products/near-expiry"

# Expected:
# ✅ HTTP 200 with product list (empty or with products)
# ✅ Logs show: "GET /api/products/near-expiry" with 200

# If fails:
# ❌ Check for "date('now') does not exist" → ProductRepository wasn't fixed
# ❌ Check for SQL syntax errors
```

### **Test Case 3: Login Query (User Query Test)**
```bash
curl -X POST https://your-backend.onrender.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# Expected:
# ✅ HTTP 200 with JWT token (if credentials correct)
# ✅ HTTP 401 Unauthorized (if credentials wrong)
# ✅ Logs show: "POST /api/auth/login" with 200 or 401

# If fails:
# ❌ Check for "users where username=?" errors
# ❌ Check for transaction errors
```

---

## 📋 FINAL VERIFICATION CHECKLIST

Before considering the fix complete:

- [ ] Application started without errors
- [ ] ✅ "Schema management delegated to Hibernate" appears in logs
- [ ] ✅ Database name detected correctly ("Using database: ...")
- [ ] ✅ Hibernate created tables (CREATE TABLE logs visible)
- [ ] ✅ No "sqlite_master" errors
- [ ] ✅ No "date('now')" function errors
- [ ] ✅ No "transaction is aborted" errors
- [ ] ✅ API test 1 (registration) returns 201
- [ ] ✅ API test 2 (expiry products) returns 200
- [ ] ✅ API test 3 (login) returns 200 or 401 (not error)
- [ ] ✅ Response times < 1 second
- [ ] ✅ No errors in last 10 requests

**All checks passed? ✨ Your PostgreSQL migration is successful!**

---

## 🆘 STILL HAVING ISSUES?

If after following this guide you still see errors:

1. **Share the FULL error message** (including stack trace)
2. **Check the first error** (scroll to top of logs) - that's usually the root cause
3. **Check application.properties** - verify:
   ```properties
   spring.datasource.driver-class-name=org.postgresql.Driver
   spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
   spring.jpa.hibernate.ddl-auto=update
   ```
4. **Verify environment variables** in Render Dashboard:
   - DATABASE_URL starts with `postgresql://`
   - SPRING_DATASOURCE_USERNAME is set
   - SPRING_DATASOURCE_PASSWORD is set

