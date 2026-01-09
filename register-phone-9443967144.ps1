# Register Phone Number 9443967144 with Telegram Chat ID 6147323999
# This will link the phone number to receive Telegram order notifications

Write-Host "Registering Phone Number with Telegram Chat ID" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$phoneNumber = "9443967144"
$telegramChatId = "6147323999"

Write-Host "Phone Number: $phoneNumber" -ForegroundColor Yellow
Write-Host "Telegram Chat ID: $telegramChatId" -ForegroundColor Yellow
Write-Host ""

# First, we need to find the user by phone number or email
# Let's try to find users and update them

Write-Host "Step 1: Finding user account..." -ForegroundColor Yellow

# We'll need to check the database or use an API endpoint
# For now, let's create a script that can update via SQL or API

Write-Host ""
Write-Host "To register this phone number with Telegram Chat ID:" -ForegroundColor Cyan
Write-Host ""
Write-Host "Option 1: Use the API (if you know the email)" -ForegroundColor Yellow
Write-Host "  Run: .\update-telegram-chatid.ps1" -ForegroundColor White
Write-Host "  Enter the email associated with phone $phoneNumber" -ForegroundColor White
Write-Host "  Enter Telegram Chat ID: $telegramChatId" -ForegroundColor White
Write-Host "  Enter Mobile: $phoneNumber" -ForegroundColor White
Write-Host ""

Write-Host "Option 2: Use Telegram Bot" -ForegroundColor Yellow
Write-Host "  1. Message your bot: /register $phoneNumber" -ForegroundColor White
Write-Host "  2. The bot will link your chat ID automatically" -ForegroundColor White
Write-Host ""

Write-Host "Option 3: Direct SQL Update (if you have database access)" -ForegroundColor Yellow
Write-Host "  UPDATE users SET telegram_chat_id = '$telegramChatId', mobile = '$phoneNumber' WHERE mobile = '$phoneNumber' OR email LIKE '%@%';" -ForegroundColor White
Write-Host ""

Write-Host "Testing Telegram message to chat ID $telegramChatId..." -ForegroundColor Yellow

$testBody = @{
    chatId = $telegramChatId
    message = "Test message - If you receive this, Telegram is working! Phone: $phoneNumber"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/telegram/send" -Method Post -ContentType "application/json" -Body $testBody -ErrorAction Stop
    
    Write-Host "✅ Test message sent successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Response:" -ForegroundColor Gray
    $response | ConvertTo-Json | Write-Host
    
} catch {
    Write-Host "❌ Failed to send test message" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Make sure:" -ForegroundColor Yellow
    Write-Host "  1. Backend is running on http://localhost:8080" -ForegroundColor White
    Write-Host "  2. Telegram bot token is configured correctly" -ForegroundColor White
    Write-Host "  3. The chat ID $telegramChatId is correct" -ForegroundColor White
}

Write-Host ""

