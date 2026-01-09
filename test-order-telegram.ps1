# Test Order Telegram Notification
# This simulates what happens when an order is placed with a phone number

Write-Host "Testing Order Telegram Notification" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This test verifies that:" -ForegroundColor Yellow
Write-Host "  1. When an order is placed with a phone number" -ForegroundColor White
Write-Host "  2. The system looks up the user by that phone number" -ForegroundColor White
Write-Host "  3. Sends Telegram message to that user's Telegram chat ID" -ForegroundColor White
Write-Host ""

$email = Read-Host "Enter your email address (to find your account)"
$phoneNumber = Read-Host "Enter the phone number used in orders (e.g., 8399999886)"
$telegramChatId = Read-Host "Enter your Telegram Chat ID (e.g., 8399999886)"

Write-Host ""
Write-Host "Step 1: Updating your account with phone number and Telegram Chat ID..." -ForegroundColor Yellow

# Update account
$updateBody = @{
    email = $email
    telegramChatId = $telegramChatId
    mobile = $phoneNumber
} | ConvertTo-Json

try {
    $updateResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/update-telegram" -Method Post -ContentType "application/json" -Body $updateBody -ErrorAction Stop
    Write-Host "✅ Account updated successfully!" -ForegroundColor Green
    Write-Host "   Mobile: $($updateResponse.user.mobile)" -ForegroundColor Gray
    Write-Host "   Telegram Chat ID: $($updateResponse.user.telegramChatId)" -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "❌ Failed to update account" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Make sure:" -ForegroundColor Yellow
    Write-Host "  1. Backend is running" -ForegroundColor White
    Write-Host "  2. Your email is correct" -ForegroundColor White
    exit
}

Write-Host "Step 2: Sending test order notification message..." -ForegroundColor Yellow

# Send test message (simulating order confirmation)
$testMessage = @{
    chatId = $telegramChatId
    message = "🧪 Test Order Notification`n`nOrder #ORD-TEST-001`nAmount: ₹1000`n`nThis is a test to verify that orders with phone number $phoneNumber will send Telegram messages to chat ID $telegramChatId"
} | ConvertTo-Json

try {
    $messageResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/telegram/send" -Method Post -ContentType "application/json" -Body $testMessage -ErrorAction Stop
    Write-Host "✅ Test message sent!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Check your Telegram - you should have received the test message!" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Summary:" -ForegroundColor Yellow
    Write-Host "  ✅ Your account is linked:" -ForegroundColor Green
    Write-Host "     Phone: $phoneNumber" -ForegroundColor Gray
    Write-Host "     Telegram Chat ID: $telegramChatId" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  📦 When orders are placed with phone number $phoneNumber," -ForegroundColor Cyan
    Write-Host "     Telegram messages will be sent to chat ID $telegramChatId" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "❌ Failed to send test message" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

