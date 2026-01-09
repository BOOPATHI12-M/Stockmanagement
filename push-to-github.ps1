# PowerShell script to push code to GitHub
# Run this script after creating your GitHub repository

Write-Host "🚀 GitHub Push Script" -ForegroundColor Cyan
Write-Host ""

# Check if git is installed
try {
    $gitVersion = git --version
    Write-Host "✅ Git is installed: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Git is not installed. Please install Git first." -ForegroundColor Red
    Write-Host "Download from: https://git-scm.com/downloads" -ForegroundColor Yellow
    exit 1
}

# Get GitHub repository URL
Write-Host ""
Write-Host "📝 Enter your GitHub repository URL:" -ForegroundColor Yellow
Write-Host "   Example: https://github.com/YOUR_USERNAME/sudharshini-stock-management.git" -ForegroundColor Gray
$repoUrl = Read-Host "Repository URL"

if ([string]::IsNullOrWhiteSpace($repoUrl)) {
    Write-Host "❌ Repository URL is required!" -ForegroundColor Red
    exit 1
}

# Check if remote already exists
$remoteExists = git remote get-url origin 2>$null
if ($remoteExists) {
    Write-Host ""
    Write-Host "⚠️  Remote 'origin' already exists: $remoteExists" -ForegroundColor Yellow
    $update = Read-Host "Update it? (y/n)"
    if ($update -eq "y" -or $update -eq "Y") {
        git remote set-url origin $repoUrl
        Write-Host "✅ Remote updated" -ForegroundColor Green
    }
} else {
    git remote add origin $repoUrl
    Write-Host "✅ Remote 'origin' added" -ForegroundColor Green
}

# Add all files
Write-Host ""
Write-Host "📦 Adding files to git..." -ForegroundColor Cyan
git add .

# Check if there are changes to commit
$status = git status --porcelain
if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host "ℹ️  No changes to commit" -ForegroundColor Yellow
} else {
    # Commit
    Write-Host ""
    Write-Host "💾 Committing changes..." -ForegroundColor Cyan
    $commitMessage = "Initial commit: Stock Management System ready for Render deployment"
    git commit -m $commitMessage
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Changes committed" -ForegroundColor Green
    } else {
        Write-Host "❌ Commit failed!" -ForegroundColor Red
        exit 1
    }
}

# Push to GitHub
Write-Host ""
Write-Host "🚀 Pushing to GitHub..." -ForegroundColor Cyan
Write-Host "   You may be prompted for GitHub credentials:" -ForegroundColor Yellow
Write-Host "   - Username: Your GitHub username" -ForegroundColor Gray
Write-Host "   - Password: Use a Personal Access Token (not your password)" -ForegroundColor Gray
Write-Host "   Get token from: https://github.com/settings/tokens" -ForegroundColor Gray
Write-Host ""

# Set branch to main
git branch -M main

# Push
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Successfully pushed to GitHub!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🎉 Next steps:" -ForegroundColor Cyan
    Write-Host "   1. Go to Render Dashboard: https://dashboard.render.com" -ForegroundColor White
    Write-Host "   2. Create new Web Service" -ForegroundColor White
    Write-Host "   3. Connect your GitHub repository" -ForegroundColor White
    Write-Host "   4. Follow RENDER_DEPLOYMENT_GUIDE.md" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "❌ Push failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "   - Authentication failed: Use Personal Access Token" -ForegroundColor Gray
    Write-Host "   - Repository not found: Check repository URL" -ForegroundColor Gray
    Write-Host "   - Permission denied: Verify repository access" -ForegroundColor Gray
    Write-Host ""
    Write-Host "See GITHUB_SETUP.md for detailed help" -ForegroundColor Cyan
}

