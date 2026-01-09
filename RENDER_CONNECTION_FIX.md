# Render Frontend-Backend Connection Fix

## 🔴 Problem Summary

- Frontend URL: `https://stockmanagement-3.onrender.com`
- Backend URL: `https://stockmanagement-802q.onrender.com`
- Error: Frontend calling `http://localhost:8080/api` (wrong!)
- Result: `ERR_CONNECTION_REFUSED`, `403 Forbidden`, Login failures

## ✅ Complete Fix Guide

### STEP 1: Fix Frontend API Configuration ✅

**File**: `frontend/src/services/api.js`

**Already Fixed**: The code now uses `VITE_API_URL` environment variable with fallback.

**What to do**: Set environment variable in Render dashboard (see Step 2).

---

### STEP 2: Set Frontend Environment Variable in Render

1. Go to Render Dashboard → Your Frontend Service
2. Go to **Environment** tab
3. Add new environment variable:

   **Key**: `VITE_API_URL`  
   **Value**: `https://stockmanagement-802q.onrender.com/api`

4. **Save** and **Redeploy** frontend

**Important**: 
- Vite requires `VITE_` prefix for environment variables
- After adding, you MUST redeploy for changes to take effect
- The variable is embedded at BUILD time, not runtime

---

### STEP 3: Fix Backend CORS Configuration ✅

**File**: `backend/src/main/java/.../config/SecurityConfig.java`

**Already Fixed**: CORS reads from `CORS_ORIGINS` environment variable.

**What to do**: Set environment variable in Render dashboard:

1. Go to Render Dashboard → Your Backend Service
2. Go to **Environment** tab
3. Add/Update environment variable:

   **Key**: `CORS_ORIGINS`  
   **Value**: `https://stockmanagement-3.onrender.com`

   **OR** for multiple origins (comma-separated):
   ```
   https://stockmanagement-3.onrender.com,http://localhost:3000
   ```

4. **Save** and **Redeploy** backend

---

### STEP 4: Verify Spring Security Configuration ✅

**File**: `backend/src/main/java/.../config/SecurityConfig.java`

**Already Fixed**: 
- ✅ Public endpoints: `/`, `/health`, `/error`, `/favicon.ico`
- ✅ Auth endpoints: `/api/auth/**` are public
- ✅ OAuth endpoints: `/oauth2/**` are public
- ✅ CSRF disabled
- ✅ Stateless sessions

**No action needed** - configuration is correct!

---

### STEP 5: Verify Frontend Build Configuration ✅

**File**: `frontend/package.json`

**Already Correct**:
```json
{
  "scripts": {
    "build": "vite build"
  }
}
```

**Render Frontend Settings**:
- **Build Command**: `npm install && npm run build`
- **Publish Directory**: `dist`
- **Start Command**: `npx serve -s dist -l 3000`

---

### STEP 6: Create Environment Files (Optional - For Local Development)

Create these files in `frontend/` directory:

#### `frontend/.env.production`
```env
VITE_API_URL=https://stockmanagement-802q.onrender.com/api
```

#### `frontend/.env.local` (for local dev)
```env
# Leave empty or uncomment to test against production:
# VITE_API_URL=https://stockmanagement-802q.onrender.com/api
```

**Note**: `.env` files are gitignored, so create them manually.

---

## 🧪 Testing Steps

### 1. Test Backend Health

```bash
curl https://stockmanagement-802q.onrender.com/
```

**Expected**: JSON response with status "UP"

### 2. Test Backend CORS

Open browser console on frontend and check Network tab:
- Request to backend should succeed
- No CORS errors in console

### 3. Test Frontend API Connection

1. Open: `https://stockmanagement-3.onrender.com/login`
2. Open browser console (F12)
3. Look for: `🔗 [API] Base URL: https://stockmanagement-802q.onrender.com/api`
4. **MUST NOT see**: `localhost:8080`

### 4. Test Login

1. Try logging in on frontend
2. Check Network tab for API calls
3. Should see requests to: `https://stockmanagement-802q.onrender.com/api/auth/admin/login`
4. Should NOT see: `http://localhost:8080`

---

## 🔧 Render Dashboard Configuration

### Backend Service Environment Variables

| Key | Value |
|-----|-------|
| `CORS_ORIGINS` | `https://stockmanagement-3.onrender.com` |
| `SPRING_PROFILES_ACTIVE` | `production` |
| `PORT` | `8080` |
| `JWT_SECRET` | `<your-secret>` |
| `MAIL_USERNAME` | `<your-email>` |
| `MAIL_PASSWORD` | `<your-password>` |
| ... (all other env vars) |

### Frontend Service Environment Variables

| Key | Value |
|-----|-------|
| `VITE_API_URL` | `https://stockmanagement-802q.onrender.com/api` |
| `NODE_ENV` | `production` |

### Frontend Build Settings

| Setting | Value |
|---------|-------|
| **Build Command** | `npm install && npm run build` |
| **Publish Directory** | `dist` |
| **Start Command** | `npx serve -s dist -l 3000` |

---

## 🚨 Common Issues & Fixes

### Issue 1: Still seeing localhost:8080

**Cause**: Environment variable not set or frontend not redeployed.

**Fix**:
1. Verify `VITE_API_URL` is set in Render dashboard
2. Redeploy frontend service
3. Clear browser cache
4. Check browser console for actual API URL

### Issue 2: CORS errors

**Cause**: Backend CORS_ORIGINS doesn't include frontend URL.

**Fix**:
1. Set `CORS_ORIGINS=https://stockmanagement-3.onrender.com` in backend
2. Redeploy backend
3. Check backend logs for CORS configuration

### Issue 3: 403 Forbidden on login

**Cause**: Spring Security blocking auth endpoints.

**Fix**: Already fixed! `/api/auth/**` is public. If still happening:
1. Check backend logs
2. Verify SecurityConfig has `.requestMatchers("/api/auth/**").permitAll()`
3. Redeploy backend

### Issue 4: Build directory not found

**Cause**: Wrong publish directory in Render.

**Fix**: Set **Publish Directory** to `dist` in Render frontend settings.

### Issue 5: Environment variable not working

**Cause**: 
- Wrong variable name (must be `VITE_API_URL`, not `API_URL`)
- Not redeployed after adding variable
- Variable added after build (variables are embedded at build time)

**Fix**:
1. Use exact name: `VITE_API_URL`
2. Add variable BEFORE building
3. Redeploy after adding variable

---

## ✅ Verification Checklist

After deploying, verify:

- [ ] Backend health check works: `https://stockmanagement-802q.onrender.com/`
- [ ] Frontend loads: `https://stockmanagement-3.onrender.com`
- [ ] Browser console shows correct API URL (not localhost)
- [ ] Login API call goes to Render backend (check Network tab)
- [ ] No CORS errors in browser console
- [ ] No 403 errors on public endpoints
- [ ] Login works successfully
- [ ] API calls succeed

---

## 📝 Quick Reference

### Frontend API URL
- **Production**: `https://stockmanagement-802q.onrender.com/api`
- **Local Dev**: `/api` (Vite proxy to localhost:8080)

### Backend CORS
- **Production**: `https://stockmanagement-3.onrender.com`
- **Local Dev**: `http://localhost:3000,http://localhost:5173`

### Environment Variables Needed

**Frontend (Render)**:
```
VITE_API_URL=https://stockmanagement-802q.onrender.com/api
```

**Backend (Render)**:
```
CORS_ORIGINS=https://stockmanagement-3.onrender.com
```

---

## 🎯 Next Steps

1. ✅ Set `VITE_API_URL` in Render frontend dashboard
2. ✅ Set `CORS_ORIGINS` in Render backend dashboard
3. ✅ Redeploy both services
4. ✅ Test login functionality
5. ✅ Verify API calls in browser Network tab

---

**After these changes, your frontend and backend will be properly connected on Render!** 🚀

