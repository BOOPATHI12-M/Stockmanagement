# Render Dashboard Setup - Step by Step

## 🎯 Your URLs

- **Frontend**: `https://stockmanagement-3.onrender.com`
- **Backend**: `https://stockmanagement-802q.onrender.com`

---

## 📋 Frontend Service Configuration

### Environment Variables

Go to: Render Dashboard → `stockmanagement-3` → **Environment** tab

| Variable Name | Value | Required |
|--------------|-------|----------|
| `VITE_API_URL` | `https://stockmanagement-802q.onrender.com/api` | ✅ YES |
| `NODE_ENV` | `production` | Optional |

**Steps**:
1. Click **"Add Environment Variable"**
2. Key: `VITE_API_URL`
3. Value: `https://stockmanagement-802q.onrender.com/api`
4. Click **"Save Changes"**
5. **IMPORTANT**: Click **"Manual Deploy"** → **"Deploy latest commit"**

### Build Settings

Go to: Render Dashboard → `stockmanagement-3` → **Settings** tab

| Setting | Value |
|---------|-------|
| **Build Command** | `npm install && npm run build` |
| **Publish Directory** | `dist` |
| **Start Command** | `npx serve -s dist -l 3000` |

---

## 📋 Backend Service Configuration

### Environment Variables

Go to: Render Dashboard → `stockmanagement-802q` → **Environment** tab

| Variable Name | Value | Required |
|--------------|-------|----------|
| `CORS_ORIGINS` | `https://stockmanagement-3.onrender.com` | ✅ YES |
| `SPRING_PROFILES_ACTIVE` | `production` | ✅ YES |
| `PORT` | `8080` | ✅ YES |
| `JWT_SECRET` | `<your-secret>` | ✅ YES |
| `MAIL_USERNAME` | `<your-email>` | ✅ YES |
| `MAIL_PASSWORD` | `<your-password>` | ✅ YES |
| `GOOGLE_CLIENT_ID` | `<your-client-id>` | ✅ YES |
| `GOOGLE_CLIENT_SECRET` | `<your-client-secret>` | ✅ YES |
| `GOOGLE_MAPS_API_KEY` | `<your-maps-key>` | Optional |
| `DB_PATH` | `/tmp/stock_management.db` | Optional |
| `UPLOAD_DIR` | `/tmp/uploads/products` | Optional |

**Critical**: Make sure `CORS_ORIGINS` includes your frontend URL!

---

## 🔄 Deployment Order

1. **First**: Set backend `CORS_ORIGINS` → Deploy backend
2. **Then**: Set frontend `VITE_API_URL` → Deploy frontend
3. **Wait**: For both deployments to complete (~10 minutes)
4. **Test**: Open frontend URL and check browser console

---

## ✅ Success Indicators

### Frontend Console Should Show:
```
🔗 [API] Base URL: https://stockmanagement-802q.onrender.com/api
🔗 [API] Environment: production
🔗 [API] VITE_API_URL: https://stockmanagement-802q.onrender.com/api
```

### Backend Logs Should Show:
```
🌐 [CORS] Using origins from environment: [https://stockmanagement-3.onrender.com]
```

### Network Tab Should Show:
- Requests to: `https://stockmanagement-802q.onrender.com/api/...`
- Status: 200 OK (not ERR_CONNECTION_REFUSED)
- No CORS errors

---

## 🚨 Common Mistakes

### ❌ Wrong Environment Variable Names
- `API_URL` → Should be `VITE_API_URL`
- `REACT_APP_API_URL` → Should be `VITE_API_URL`
- `CORS_ORIGIN` → Should be `CORS_ORIGINS` (with S)

### ❌ Forgetting to Redeploy
- Environment variables are embedded at BUILD time
- You MUST redeploy after adding/changing variables

### ❌ Wrong CORS URL
- `http://stockmanagement-3.onrender.com` → Should be `https://...`
- Missing `https://` prefix
- Trailing slash: `https://stockmanagement-3.onrender.com/` → Remove trailing slash

### ❌ Wrong API URL Format
- `https://stockmanagement-802q.onrender.com` → Should include `/api`
- Correct: `https://stockmanagement-802q.onrender.com/api`

---

## 📝 Copy-Paste Ready Values

### Frontend Environment Variable
```
VITE_API_URL=https://stockmanagement-802q.onrender.com/api
```

### Backend Environment Variable
```
CORS_ORIGINS=https://stockmanagement-3.onrender.com
```

---

**Follow this guide exactly and your services will be connected!** 🚀

