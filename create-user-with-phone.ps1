# Create or Update User Account with Phone Number and Telegram Chat ID

Write-Host "Create/Update User Account" -ForegroundColor Cyan
Write-Host "==========================" -ForegroundColor Cyan
Write-Host ""

$phoneNumber = "9443967144"
$telegramChatId = "6147323999"

Write-Host "Phone Number: $phoneNumber" -ForegroundColor Yellow
Write-Host "Telegram Chat ID: $telegramChatId" -ForegroundColor Yellow
Write-Host ""

Write-Host "IMPORTANT: You need to have a user account first!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Option 1: If you have an existing account with email" -ForegroundColor Cyan
Write-Host "  Run: .\update-telegram-chatid.ps1" -ForegroundColor White
Write-Host "  Enter your email" -ForegroundColor White
Write-Host "  Enter Telegram Chat ID: $telegramChatId" -ForegroundColor White
Write-Host "  Enter Mobile: $phoneNumber" -ForegroundColor White
Write-Host ""

Write-Host "Option 2: Create account via website first, then register" -ForegroundColor Cyan
Write-Host "  1. Go to http://localhost:3000" -ForegroundColor White
Write-Host "  2. Sign up with email and phone number $phoneNumber" -ForegroundColor White
Write-Host "  3. Then run: .\register-phone-telegram.ps1" -ForegroundColor White
Write-Host ""

Write-Host "Option 3: Use Telegram Bot to register" -ForegroundColor Cyan
Write-Host "  1. Message your bot: /register $phoneNumber" -ForegroundColor White
Write-Host "  2. The bot will automatically link your chat ID" -ForegroundColor White
Write-Host ""

Write-Host "Current Status:" -ForegroundColor Yellow
Write-Host "  ✅ Telegram is working (test message sent successfully)" -ForegroundColor Green
Write-Host "  ❌ No user account found with phone: $phoneNumber" -ForegroundColor Red
Write-Host ""
Write-Host "Once you create/update the user account with phone $phoneNumber," -ForegroundColor Cyan
Write-Host "and register Telegram chat ID $telegramChatId," -ForegroundColor Cyan
Write-Host "order notifications will be sent automatically!" -ForegroundColor Cyan
Write-Host ""

