# Environment Variables Setup for Frontend

## 📝 Create These Files Manually

Since `.env` files are gitignored, you need to create them manually.

### 1. Create `frontend/.env.production`

Create this file in the `frontend/` directory:

```env
# Production Environment Variables
# Used when building for production (npm run build)

# Backend API URL - Your Render backend URL
VITE_API_URL=https://stockmanagement-802q.onrender.com/api
```

### 2. Create `frontend/.env.local` (Optional - for local dev)

Create this file in the `frontend/` directory:

```env
# Local Development Environment Variables
# Used for local development (npm run dev)

# For local dev, Vite proxy handles /api -> localhost:8080
# No need to set VITE_API_URL here unless testing against production
```

## 🚀 Render Deployment

**IMPORTANT**: Environment variables in Render are set in the dashboard, NOT in .env files!

### In Render Dashboard:

1. Go to your Frontend Service
2. Click **Environment** tab
3. Add:
   - **Key**: `VITE_API_URL`
   - **Value**: `https://stockmanagement-802q.onrender.com/api`
4. **Save** and **Redeploy**

## ✅ Verification

After deployment, check browser console:
```
🔗 [API] Base URL: https://stockmanagement-802q.onrender.com/api
```

If you see `localhost:8080`, the environment variable is not set correctly!

