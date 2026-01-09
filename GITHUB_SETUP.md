# GitHub Setup Guide

## 🔐 Step 1: Login to GitHub

### Option A: Using GitHub Desktop (Easiest)
1. Download GitHub Desktop: https://desktop.github.com/
2. Install and open GitHub Desktop
3. Sign in with your GitHub account
4. Follow the authentication flow

### Option B: Using Git Command Line
1. **Install Git** (if not installed): https://git-scm.com/downloads
2. **Configure Git** (one-time setup):
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

3. **Login to GitHub**:
   - Go to https://github.com/login
   - Sign in with your credentials
   - Or use GitHub CLI: `gh auth login`

## 📦 Step 2: Create GitHub Repository

1. Go to https://github.com/new
2. **Repository name**: `sudharshini-stock-management` (or your preferred name)
3. **Description**: "Full-stack Stock Management System"
4. **Visibility**: 
   - **Public** (free, anyone can see)
   - **Private** (requires paid plan, only you can see)
5. **DO NOT** initialize with README, .gitignore, or license (we already have these)
6. Click **"Create repository"**

## 🚀 Step 3: Push Your Code to GitHub

### Using Git Command Line

Open terminal/command prompt in your project directory:

```bash
# Navigate to your project folder
cd "C:\Users\BOOPATHI M\OneDrive\Desktop\project"

# Initialize git repository (if not already initialized)
git init

# Add all files
git add .

# Commit files
git commit -m "Initial commit: Stock Management System ready for Render deployment"

# Add remote repository (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/sudharshini-stock-management.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### Using GitHub Desktop

1. Open GitHub Desktop
2. Click **"File"** → **"Add Local Repository"**
3. Browse to your project folder: `C:\Users\BOOPATHI M\OneDrive\Desktop\project`
4. Click **"Add Repository"**
5. Click **"Publish repository"** (top right)
6. Enter repository name
7. Choose visibility (Public/Private)
8. Click **"Publish Repository"**

## 🔑 Step 4: GitHub Authentication Methods

### Personal Access Token (Recommended)

1. Go to GitHub → **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Click **"Generate new token"** → **"Generate new token (classic)"**
3. **Note**: "Render Deployment"
4. **Expiration**: Choose duration (90 days recommended)
5. **Select scopes**: Check `repo` (full control of private repositories)
6. Click **"Generate token"**
7. **Copy the token** (you won't see it again!)

### Using Token with Git

When pushing, use token as password:
```bash
git push
# Username: your-github-username
# Password: paste-your-token-here
```

### Using GitHub CLI

```bash
# Install GitHub CLI: https://cli.github.com/
gh auth login
# Follow the prompts
```

## ✅ Step 5: Verify Repository

1. Go to your GitHub profile: https://github.com/YOUR_USERNAME
2. Click on your repository
3. Verify all files are uploaded:
   - `backend/` folder
   - `frontend/` folder
   - `README.md`
   - `.gitignore`
   - All other project files

## 🔒 Step 6: Security Checklist

Before pushing, ensure:

- [ ] `.gitignore` is in place (excludes sensitive files)
- [ ] No passwords/secrets in code
- [ ] No database files committed
- [ ] No `credentials.json` files
- [ ] Environment variables documented (not committed)

## 📝 Step 7: Update .gitignore (If Needed)

Your `.gitignore` should exclude:
```
*.db
*.db-journal
*.db-wal
.env
credentials.json
uploads/
node_modules/
target/
```

## 🚨 Troubleshooting

### Issue: "Authentication failed"

**Solution**:
- Use Personal Access Token instead of password
- Or use GitHub Desktop (handles auth automatically)

### Issue: "Repository not found"

**Solution**:
- Check repository name matches
- Verify you have access (for private repos)
- Check remote URL: `git remote -v`

### Issue: "Large file warning"

**Solution**:
- Remove large files from git history
- Use Git LFS for large files
- Or exclude them in `.gitignore`

### Issue: "Permission denied"

**Solution**:
- Check your GitHub account has access
- Verify SSH keys (if using SSH)
- Use HTTPS with Personal Access Token

## 🎯 Next Steps After GitHub Setup

1. ✅ Code is on GitHub
2. ✅ Go to Render Dashboard
3. ✅ Connect GitHub repository
4. ✅ Deploy backend service
5. ✅ Deploy frontend service
6. ✅ Set environment variables
7. ✅ Test deployment

## 📚 Useful Commands

```bash
# Check git status
git status

# View remote repository
git remote -v

# View commit history
git log --oneline

# Add specific file
git add filename

# Commit changes
git commit -m "Your commit message"

# Push changes
git push

# Pull latest changes
git pull
```

## 🔗 Quick Links

- **GitHub**: https://github.com
- **GitHub Desktop**: https://desktop.github.com
- **Git Download**: https://git-scm.com/downloads
- **GitHub CLI**: https://cli.github.com
- **Personal Access Tokens**: https://github.com/settings/tokens

---

**Ready to deploy?** Once your code is on GitHub, follow `RENDER_DEPLOYMENT_GUIDE.md` to deploy on Render!

