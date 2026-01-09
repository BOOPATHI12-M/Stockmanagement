# 🚀 Quick Fix - Render Frontend-Backend Connection

## ⚡ IMMEDIATE ACTION REQUIRED

### Step 1: Set Frontend Environment Variable (2 minutes)

1. Go to: https://dashboard.render.com
2. Click your **Frontend Service** (`stockmanagement-3`)
3. Go to **Environment** tab
4. Click **"Add Environment Variable"**
5. Enter:
   - **Key**: `VITE_API_URL`
   - **Value**: `https://stockmanagement-802q.onrender.com/api`
6. Click **"Save Changes"**
7. Click **"Manual Deploy"** → **"Deploy latest commit"**

### Step 2: Set Backend CORS (2 minutes)

1. Go to: https://dashboard.render.com
2. Click your **Backend Service** (`stockmanagement-802q`)
3. Go to **Environment** tab
4. Find `CORS_ORIGINS` or add it:
   - **Key**: `CORS_ORIGINS`
   - **Value**: `https://stockmanagement-3.onrender.com`
5. Click **"Save Changes"**
6. Click **"Manual Deploy"** → **"Deploy latest commit"**

### Step 3: Wait for Deployment (5-10 minutes)

- Watch the build logs
- Wait for "Deploy successful"

### Step 4: Test (1 minute)

1. Open: https://stockmanagement-3.onrender.com/login
2. Press **F12** (open browser console)
3. Look for: `🔗 [API] Base URL: https://stockmanagement-802q.onrender.com/api`
4. ✅ **MUST see**: Render URL (not localhost)
5. Try logging in

---

## ✅ What Was Fixed in Code

### Frontend (`frontend/src/services/api.js`)
- ✅ Uses `VITE_API_URL` environment variable
- ✅ Fallback to Render URL if env var not set
- ✅ Logs API URL to console for debugging

### Backend (`backend/src/main/java/.../config/SecurityConfig.java`)
- ✅ Reads CORS from `CORS_ORIGINS` environment variable
- ✅ Public endpoints configured (`/`, `/health`, `/api/auth/**`)
- ✅ No 403 errors on public endpoints

---

## 🔍 Verification Checklist

After deployment, check:

- [ ] Browser console shows: `🔗 [API] Base URL: https://stockmanagement-802q.onrender.com/api`
- [ ] Network tab shows requests to Render backend (not localhost)
- [ ] No CORS errors in console
- [ ] Login works
- [ ] No 403 errors

---

## 🆘 Still Not Working?

### Check 1: Environment Variable Name
- ✅ Correct: `VITE_API_URL`
- ❌ Wrong: `API_URL`, `REACT_APP_API_URL`, `API_BASE_URL`

### Check 2: Did You Redeploy?
- Environment variables are embedded at BUILD time
- You MUST redeploy after adding/changing variables

### Check 3: Browser Cache
- Clear browser cache
- Hard refresh: `Ctrl+Shift+R` (Windows) or `Cmd+Shift+R` (Mac)

### Check 4: Check Backend Logs
- Go to Render Dashboard → Backend Service → Logs
- Look for: `🌐 [CORS] Using origins from environment: ...`
- Should show your frontend URL

---

## 📞 Quick Test URLs

**Backend Health**:
```
https://stockmanagement-802q.onrender.com/
```

**Backend Login API**:
```
https://stockmanagement-802q.onrender.com/api/auth/admin/login
```

**Frontend**:
```
https://stockmanagement-3.onrender.com/login
```

---

**Follow these steps and your frontend-backend will be connected!** 🎉

