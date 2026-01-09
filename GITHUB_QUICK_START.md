# Quick Start - Push to GitHub

## 🚀 Fast Method (PowerShell Script)

1. **Create GitHub Repository**:
   - Go to https://github.com/new
   - Name: `sudharshini-stock-management`
   - Click "Create repository"

2. **Run the push script**:
   ```powershell
   .\push-to-github.ps1
   ```
   - Enter your repository URL when prompted
   - Use Personal Access Token as password (not your GitHub password)

## 📝 Manual Method

### Step 1: Create GitHub Repository
1. Go to https://github.com/new
2. Repository name: `sudharshini-stock-management`
3. **DO NOT** check "Initialize with README"
4. Click "Create repository"

### Step 2: Get Personal Access Token
1. Go to https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Name: "Render Deployment"
4. Check `repo` scope
5. Click "Generate token"
6. **Copy the token** (you won't see it again!)

### Step 3: Push Code

Open PowerShell in your project folder:

```powershell
# Add all files
git add .

# Commit
git commit -m "Initial commit: Stock Management System"

# Add remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/sudharshini-stock-management.git

# Push
git branch -M main
git push -u origin main
```

When prompted:
- **Username**: Your GitHub username
- **Password**: Paste your Personal Access Token

## ✅ Verify

1. Go to https://github.com/YOUR_USERNAME/sudharshini-stock-management
2. Verify all files are uploaded

## 🎯 Next: Deploy on Render

Once code is on GitHub:
1. Follow `RENDER_DEPLOYMENT_GUIDE.md`
2. Connect GitHub repository in Render
3. Deploy!

## 🆘 Need Help?

See `GITHUB_SETUP.md` for detailed instructions.

