# Quick Start - Render Deployment

## 🚀 Fast Deployment Steps

### Backend Deployment

1. **Go to Render Dashboard** → New Web Service
2. **Connect GitHub** repository
3. **Configure**:
   - **Name**: `sudharshini-stock-backend`
   - **Environment**: `Java`
   - **Build Command**: `cd backend && ./mvnw clean package -DskipTests`
   - **Start Command**: `cd backend && java -jar target/stock-management-1.0.0.jar --spring.profiles.active=production`

4. **Set Environment Variables**:
   ```
   SPRING_PROFILES_ACTIVE=production
   CORS_ORIGINS=https://your-frontend.onrender.com
   JWT_SECRET=<generate-strong-secret>
   MAIL_USERNAME=your-email@gmail.com
   MAIL_PASSWORD=your-app-password
   GOOGLE_CLIENT_ID=your-client-id
   GOOGLE_CLIENT_SECRET=your-client-secret
   GOOGLE_MAPS_API_KEY=your-maps-key
   ```

5. **Deploy** and note the backend URL

### Frontend Deployment

1. **Go to Render Dashboard** → New Web Service
2. **Connect GitHub** repository
3. **Configure**:
   - **Name**: `sudharshini-stock-frontend`
   - **Environment**: `Node`
   - **Build Command**: `cd frontend && npm install && npm run build`
   - **Start Command**: `cd frontend && npx serve -s dist -l 3000`

4. **Set Environment Variables**:
   ```
   VITE_API_URL=https://sudharshini-stock-backend.onrender.com/api
   NODE_ENV=production
   ```

5. **Update Backend CORS**: Add frontend URL to `CORS_ORIGINS`

## ⚡ Generate JWT Secret

```bash
openssl rand -base64 32
```

## 📝 Important Notes

- **SQLite**: Data is ephemeral (lost on redeploy). Consider PostgreSQL for production.
- **File Uploads**: Use external storage (S3, Cloudinary) for persistence.
- **Free Tier**: Services sleep after 15 min inactivity (wake on request).

## 🔗 Full Guide

See `RENDER_DEPLOYMENT_GUIDE.md` for complete instructions.

