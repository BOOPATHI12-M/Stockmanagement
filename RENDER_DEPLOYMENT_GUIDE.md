# Render Deployment Guide - Sudharshini Stock Management

Complete step-by-step guide to deploy your Spring Boot + React application on Render.

## 📋 Prerequisites

1. **Render Account**: Sign up at [render.com](https://render.com)
2. **GitHub Repository**: Push your code to GitHub (Render connects via GitHub)
3. **Environment Variables**: Prepare all sensitive values (API keys, secrets, etc.)

## 🏗️ Project Structure

Your project should be structured as:
```
project/
├── backend/
│   ├── src/
│   ├── pom.xml
│   ├── mvnw (Maven wrapper)
│   └── ...
├── frontend/
│   ├── src/
│   ├── package.json
│   └── ...
└── README.md
```

## 🔧 Step 1: Update Backend Configuration

### 1.1 Update SecurityConfig.java for Dynamic CORS

The CORS configuration needs to read from environment variables:

```java
@Bean
public CorsConfigurationSource corsConfigurationSource() {
    CorsConfiguration configuration = new CorsConfiguration();
    
    // Read allowed origins from environment variable
    String allowedOrigins = System.getenv("CORS_ORIGINS");
    if (allowedOrigins == null || allowedOrigins.isEmpty()) {
        allowedOrigins = "http://localhost:3000,http://localhost:5173";
    }
    
    // Split comma-separated origins
    configuration.setAllowedOrigins(Arrays.asList(allowedOrigins.split(",")));
    configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"));
    configuration.setAllowedHeaders(Arrays.asList(
        "Authorization", 
        "Content-Type", 
        "X-Requested-With",
        "Accept",
        "Origin",
        "Access-Control-Request-Method",
        "Access-Control-Request-Headers"
    ));
    configuration.setExposedHeaders(Arrays.asList("Authorization"));
    configuration.setAllowCredentials(true);
    configuration.setMaxAge(3600L);
    
    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/**", configuration);
    return source;
}
```

### 1.2 Update Main Application Class

Ensure your `StockManagementApplication.java` can read the PORT environment variable:

```java
@SpringBootApplication
public class StockManagementApplication {
    public static void main(String[] args) {
        // Read PORT from environment (Render provides this)
        String port = System.getenv("PORT");
        if (port != null) {
            System.setProperty("server.port", port);
        }
        
        SpringApplication.run(StockManagementApplication.class, args);
    }
}
```

## 🚀 Step 2: Deploy Backend on Render

### 2.1 Create Backend Web Service

1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click **"New +"** → **"Web Service"**
3. Connect your GitHub repository
4. Configure the service:

**Basic Settings:**
- **Name**: `sudharshini-stock-backend`
- **Environment**: `Java`
- **Region**: Choose closest to your users
- **Branch**: `main` or `master`

**Build & Deploy:**
- **Build Command**: 
  ```bash
  cd backend && ./mvnw clean package -DskipTests
  ```
- **Start Command**: 
  ```bash
  cd backend && java -jar target/stock-management-1.0.0.jar --spring.profiles.active=production
  ```

**Note**: If `mvnw` doesn't work, use:
- **Build Command**: `cd backend && mvn clean package -DskipTests`
- Make sure Maven is available in Render's environment

### 2.2 Set Environment Variables

In the Render dashboard, go to **Environment** tab and add:

| Key | Value | Description |
|-----|-------|-------------|
| `SPRING_PROFILES_ACTIVE` | `production` | Activate production profile |
| `PORT` | `8080` | Server port (Render auto-assigns, but set default) |
| `DB_PATH` | `/tmp/stock_management.db` | SQLite database path |
| `CORS_ORIGINS` | `https://your-frontend.onrender.com` | Your frontend URL (set after deploying frontend) |
| `JWT_SECRET` | `your-secure-random-secret-key-here` | Generate a strong secret (min 32 chars) |
| `MAIL_HOST` | `smtp.gmail.com` | SMTP server |
| `MAIL_PORT` | `587` | SMTP port |
| `MAIL_USERNAME` | `your-email@gmail.com` | Your email |
| `MAIL_PASSWORD` | `your-app-password` | Gmail app password |
| `ADMIN_EMAIL` | `admin@yourdomain.com` | Admin email |
| `GOOGLE_CLIENT_ID` | `your-google-client-id` | Google OAuth client ID |
| `GOOGLE_CLIENT_SECRET` | `your-google-client-secret` | Google OAuth secret |
| `GOOGLE_MAPS_API_KEY` | `your-maps-api-key` | Google Maps API key |
| `UPLOAD_DIR` | `/tmp/uploads/products` | File upload directory |

**Important Notes:**
- **JWT_SECRET**: Generate a secure random string:
  ```bash
  openssl rand -base64 32
  ```
- **CORS_ORIGINS**: Update this after deploying frontend with the actual URL
- **SQLite Warning**: Render's filesystem is ephemeral. Data will be lost on redeploy. Consider:
  - Using Render PostgreSQL (free tier available)
  - Using external storage (AWS S3, etc.)
  - Implementing database backups

### 2.3 Deploy Backend

1. Click **"Create Web Service"**
2. Wait for build to complete (5-10 minutes)
3. Note your backend URL: `https://sudharshini-stock-backend.onrender.com`

## 🎨 Step 3: Deploy Frontend on Render

### 3.1 Update Frontend API Configuration

Update `frontend/src/services/api.js`:

```javascript
// Use environment variable for API URL in production
const API_BASE_URL = import.meta.env.VITE_API_URL || 
  (import.meta.env.DEV ? '/api' : 'http://localhost:8080/api')

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json'
  }
})
```

### 3.2 Update Vite Config (if needed)

Update `frontend/vite.config.js`:

```javascript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: process.env.VITE_API_URL || 'http://localhost:8080',
        changeOrigin: true,
      }
    }
  },
  build: {
    outDir: 'dist',
    sourcemap: false
  }
})
```

### 3.3 Create Frontend Web Service

1. In Render Dashboard, click **"New +"** → **"Web Service"**
2. Connect the same GitHub repository
3. Configure:

**Basic Settings:**
- **Name**: `sudharshini-stock-frontend`
- **Environment**: `Node`
- **Region**: Same as backend
- **Branch**: `main` or `master`

**Build & Deploy:**
- **Build Command**: 
  ```bash
  cd frontend && npm install && npm run build
  ```
- **Start Command**: 
  ```bash
  cd frontend && npm run preview
  ```

**Alternative Start Command** (if preview doesn't work):
```bash
cd frontend && npx serve -s dist -l 3000
```

### 3.4 Set Frontend Environment Variables

| Key | Value |
|-----|-------|
| `VITE_API_URL` | `https://sudharshini-stock-backend.onrender.com/api` |
| `NODE_ENV` | `production` |

### 3.5 Update Backend CORS

After frontend is deployed, update backend's `CORS_ORIGINS` environment variable:
```
https://sudharshini-stock-frontend.onrender.com
```

## 📝 Step 4: Update Application Properties

The `application-production.properties` file is already created. It uses environment variables for all sensitive configuration.

## 🔍 Step 5: Verify Deployment

### Backend Health Check

Visit: `https://sudharshini-stock-backend.onrender.com/api/reports/summary`

You should get a JSON response (may require authentication).

### Frontend Check

Visit: `https://sudharshini-stock-frontend.onrender.com`

The app should load and connect to the backend.

## ⚠️ Common Issues & Solutions

### Issue 1: Build Fails - Maven Not Found

**Solution**: Use Maven wrapper or update build command:
```bash
cd backend && chmod +x mvnw && ./mvnw clean package -DskipTests
```

Or install Maven in Render:
```bash
cd backend && apt-get update && apt-get install -y maven && mvn clean package -DskipTests
```

### Issue 2: Port Already in Use

**Solution**: Render automatically sets PORT. Don't hardcode it. Use:
```properties
server.port=${PORT:8080}
```

### Issue 3: CORS Errors

**Solution**: 
1. Check `CORS_ORIGINS` includes your frontend URL
2. Ensure no trailing slashes
3. Use HTTPS URLs (not HTTP)
4. Check backend logs for CORS errors

### Issue 4: SQLite Database Lost on Redeploy

**Solution**: 
- **Option A**: Use Render PostgreSQL (Recommended)
  - Add PostgreSQL service in Render
  - Update `application.properties` to use PostgreSQL
  - Update `pom.xml` to include PostgreSQL driver

- **Option B**: Use Persistent Disk (Paid feature)
- **Option C**: Implement database backups to external storage

### Issue 5: File Uploads Not Persisting

**Solution**: 
- Use external storage (AWS S3, Cloudinary, etc.)
- Or use Render's persistent disk (paid)
- Current setup uses `/tmp` which is ephemeral

### Issue 6: Frontend Can't Connect to Backend

**Solution**:
1. Check `VITE_API_URL` is set correctly
2. Verify backend URL is accessible
3. Check CORS configuration
4. Check browser console for errors

### Issue 7: JWT Token Issues

**Solution**:
1. Ensure `JWT_SECRET` is set and consistent
2. Don't change `JWT_SECRET` after deployment (users will be logged out)
3. Use a strong secret (32+ characters)

### Issue 8: Google OAuth Not Working

**Solution**:
1. Update Google OAuth redirect URIs:
   - Add: `https://sudharshini-stock-backend.onrender.com/api/auth/customer/google/callback`
2. Update frontend Google Client ID
3. Verify `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` are set

### Issue 9: Email Not Sending

**Solution**:
1. Use Gmail App Password (not regular password)
2. Enable "Less secure app access" or use OAuth2
3. Check `MAIL_USERNAME` and `MAIL_PASSWORD` are correct
4. Verify SMTP settings

### Issue 10: Build Timeout

**Solution**:
- Render free tier has 15-minute build timeout
- Optimize build: Skip tests, use Maven wrapper
- Consider upgrading to paid plan for longer builds

## 🔄 Step 6: Database Migration (Optional - PostgreSQL)

If you want to use PostgreSQL instead of SQLite:

### 6.1 Add PostgreSQL Service

1. In Render Dashboard: **"New +"** → **"PostgreSQL"**
2. Create database
3. Note connection string

### 6.2 Update pom.xml

Add PostgreSQL dependency:
```xml
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <scope>runtime</scope>
</dependency>
```

### 6.3 Update application-production.properties

```properties
# PostgreSQL Configuration
spring.datasource.url=${DATABASE_URL}
spring.datasource.driver-class-name=org.postgresql.Driver
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.hibernate.ddl-auto=update
```

### 6.4 Set Environment Variable

In Render dashboard, add:
- `DATABASE_URL`: (Auto-provided by Render PostgreSQL service)

## 📊 Monitoring & Logs

### View Logs

1. Go to Render Dashboard
2. Select your service
3. Click **"Logs"** tab
4. View real-time logs

### Health Checks

Render automatically pings your service. Ensure:
- Backend responds to health check endpoint
- Frontend serves static files correctly

## 🔐 Security Best Practices

1. **Never commit secrets** to Git
2. **Use environment variables** for all sensitive data
3. **Rotate secrets** periodically
4. **Use HTTPS** (Render provides this automatically)
5. **Enable 2FA** on Render account
6. **Review logs** regularly for suspicious activity

## 📈 Scaling

### Free Tier Limitations

- **Build time**: 15 minutes max
- **Sleep after inactivity**: 15 minutes (wakes on request)
- **Bandwidth**: 100 GB/month
- **Disk**: Ephemeral (lost on redeploy)

### Paid Tier Benefits

- **Always-on**: No sleep
- **Persistent disk**: Data persists
- **Longer builds**: No timeout
- **More bandwidth**: 750 GB/month

## 🆘 Support

- **Render Docs**: [render.com/docs](https://render.com/docs)
- **Render Community**: [community.render.com](https://community.render.com)
- **Your Logs**: Check Render dashboard logs tab

## ✅ Deployment Checklist

- [ ] Backend builds successfully
- [ ] Backend starts without errors
- [ ] All environment variables set
- [ ] CORS configured correctly
- [ ] Frontend builds successfully
- [ ] Frontend connects to backend
- [ ] Database accessible (if using external)
- [ ] File uploads work (if using external storage)
- [ ] Email sending works
- [ ] Google OAuth works
- [ ] JWT authentication works
- [ ] All routes accessible
- [ ] Logs show no errors

## 🎉 Success!

Your application should now be live on Render!

**Backend URL**: `https://sudharshini-stock-backend.onrender.com`  
**Frontend URL**: `https://sudharshini-stock-frontend.onrender.com`

Remember to update your Google OAuth redirect URIs and any other external service configurations!

