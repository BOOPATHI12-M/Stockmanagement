# Render PostgreSQL Database Setup Guide

## 🔧 Required Environment Variables in Render

Go to your Render backend service → **Environment** tab and add these variables:

### Option 1: Use Neon/External Postgres (Recommended)

If you're using Neon PostgreSQL, set these three variables:

```
DATABASE_URL = jdbc:postgresql://ep-xxx-xxx.us-east-2.aws.neon.tech:5432/neondb?sslmode=require
DB_USER = your_neon_username
DB_PASSWORD = your_neon_password
```

**Important:** Make sure `DATABASE_URL` starts with `jdbc:postgresql://` (NOT `postgres://`)

---

### Option 2: Use Render PostgreSQL Database

If using Render's built-in PostgreSQL:

1. In your Render Dashboard → Create New → PostgreSQL
2. After creation, go to the database page and copy the **JDBC URL**
3. Set in your backend service:

```
DATABASE_URL = jdbc:postgresql://dpg-xxx.oregon-postgres.render.com:5432/dbname
DB_USER = (from Render database page)
DB_PASSWORD = (from Render database page)
```

---

## 📝 Converting postgres:// to jdbc:postgresql://

If you have a URL like:
```
postgres://user:pass@host:5432/dbname
```

Convert it to:
```
jdbc:postgresql://host:5432/dbname
```

And set username/password separately:
```
DB_USER = user
DB_PASSWORD = pass
```

---

## ✅ Complete Environment Variables Checklist

Make sure ALL these are set in Render:

```
PORT = 8080
DATABASE_URL = jdbc:postgresql://your-host:5432/your-db?sslmode=require
DB_USER = your_username
DB_PASSWORD = your_password
SPRING_PROFILES_ACTIVE = production

MAIL_HOST = smtp.gmail.com
MAIL_PORT = 587
MAIL_USERNAME = your-email@gmail.com
MAIL_PASSWORD = your-app-password

ADMIN_EMAIL = admin@example.com

JWT_SECRET = your-secret-key-min-256-bits
JWT_EXPIRATION = 86400000

GOOGLE_CLIENT_ID = your-google-client-id
GOOGLE_CLIENT_SECRET = your-google-client-secret

CORS_ORIGINS = https://your-frontend.onrender.com,http://localhost:5173

UPLOAD_DIR = /tmp/uploads/products
LOG_FILE = /tmp/application.log
```

---

## 🔍 Testing the Connection

After deployment, check the logs in Render:

✅ **Success** - Look for:
```
HikariPool-1 - Start completed
Initialized JPA EntityManagerFactory
Started Application in X.XXX seconds
```

❌ **Error** - If you see:
```
jdbcUrl is required with driverClassName
Cannot create PoolableConnectionFactory
```

Then:
1. Verify `DATABASE_URL` format is `jdbc:postgresql://...`
2. Check username and password are correct
3. Ensure PostgreSQL dependency exists in pom.xml

---

## 🚀 Deploy

After setting environment variables:

1. Commit any local changes:
   ```bash
   git add .
   git commit -m "Update database configuration"
   git push origin main
   ```

2. Render will auto-deploy
3. Check logs for successful connection
