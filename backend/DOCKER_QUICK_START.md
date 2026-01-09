# Docker Quick Start Guide

## 🚀 Quick Commands

### Build Image
```bash
cd backend
docker build -t sudharshini-stock-management:latest .
```

### Run Container
```bash
docker run -p 8080:8080 \
  -e JWT_SECRET=your-secret \
  -e CORS_ORIGINS=http://localhost:3000 \
  sudharshini-stock-management:latest
```

### Using Docker Compose
```bash
cd backend
# Edit docker-compose.yml with your environment variables
docker-compose up -d
```

## 📋 Render Deployment Steps

1. **Push code to GitHub** (with Dockerfile)

2. **Create Web Service on Render**:
   - Environment: `Docker`
   - Dockerfile Path: `backend/Dockerfile`
   - Docker Context: `backend`

3. **Set Environment Variables** in Render dashboard

4. **Deploy!**

## 📚 Full Documentation

See `DOCKER_GUIDE.md` for complete guide.

