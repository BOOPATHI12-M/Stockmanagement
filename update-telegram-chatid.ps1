# Script to Update Telegram Chat ID for Your Account
# This links your phone number with your Telegram chat ID

Write-Host "🔗 Link Telegram Chat ID to Your Account" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$apiUrl = "http://localhost:8080/api/auth/update-telegram"

# Get user input
$email = Read-Host "Enter your email address"
$telegramChatId = Read-Host "Enter your Telegram Chat ID (e.g., 8399999886)"
$mobile = Read-Host "Enter your mobile number (optional, press Enter to skip)"

# Prepare request body
$body = @{
    email = $email
    telegramChatId = $telegramChatId
} | ConvertTo-Json

# Add mobile if provided
if ($mobile -and $mobile -ne "") {
    $bodyObj = $body | ConvertFrom-Json
    $bodyObj | Add-Member -MemberType NoteProperty -Name "mobile" -Value $mobile -Force
    $body = $bodyObj | ConvertTo-Json
}

Write-Host ""
Write-Host "📤 Updating your account..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri $apiUrl -Method Post -ContentType "application/json" -Body $body -ErrorAction Stop
    
    Write-Host "✅ Success!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your account has been updated:" -ForegroundColor Cyan
    Write-Host "  Email: $($response.user.email)" -ForegroundColor Gray
    Write-Host "  Mobile: $($response.user.mobile)" -ForegroundColor Gray
    Write-Host "  Telegram Chat ID: $($response.user.telegramChatId)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🎉 Now when orders are placed with your phone number, you'll receive Telegram notifications!" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Error updating account" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.ErrorDetails.Message) {
        $errorDetails = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "Details: $($errorDetails.error)" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "💡 Make sure:" -ForegroundColor Yellow
    Write-Host "  1. Your backend is running (http://localhost:8080)" -ForegroundColor White
    Write-Host "  2. Your email address is correct" -ForegroundColor White
    Write-Host "  3. You have an account registered with this email" -ForegroundColor White
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

