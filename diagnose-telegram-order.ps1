# Diagnose why Telegram messages aren't being sent for orders

Write-Host "Diagnosing Telegram Order Notifications" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

$phoneNumber = "9443967144"
$telegramChatId = "6147323999"

Write-Host "Checking configuration..." -ForegroundColor Yellow
Write-Host ""

# Check if backend is running
Write-Host "1. Checking if backend is running..." -ForegroundColor Yellow
try {
    $testResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/telegram/test" -Method Get -ErrorAction Stop
    Write-Host "   Backend is running" -ForegroundColor Green
    Write-Host "   Telegram configured: $($testResponse.configured)" -ForegroundColor Gray
} catch {
    Write-Host "   Backend is NOT running!" -ForegroundColor Red
    Write-Host "   Start it with: cd backend; mvn spring-boot:run" -ForegroundColor Yellow
    exit
}

Write-Host ""

# Test Telegram message sending
Write-Host "2. Testing Telegram message to chat ID $telegramChatId..." -ForegroundColor Yellow
$testBody = @{
    chatId = $telegramChatId
    message = "Diagnostic test - If you receive this, Telegram is working!"
} | ConvertTo-Json

try {
    $msgResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/telegram/send" -Method Post -ContentType "application/json" -Body $testBody -ErrorAction Stop
    Write-Host "   Test message sent successfully!" -ForegroundColor Green
    Write-Host "   Check your Telegram - you should have received the message" -ForegroundColor Cyan
} catch {
    Write-Host "   Failed to send test message" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Try to register the phone number
Write-Host "3. Registering phone number $phoneNumber with Telegram chat ID $telegramChatId..." -ForegroundColor Yellow

# First try the new endpoint (if backend was restarted)
$registerBody = @{
    phoneNumber = $phoneNumber
    telegramChatId = $telegramChatId
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/update-telegram-by-phone" -Method Post -ContentType "application/json" -Body $registerBody -ErrorAction Stop
    Write-Host "   Registration successful!" -ForegroundColor Green
    Write-Host "   User Email: $($registerResponse.user.email)" -ForegroundColor Gray
    Write-Host "   Mobile: $($registerResponse.user.mobile)" -ForegroundColor Gray
    Write-Host "   Telegram Chat ID: $($registerResponse.user.telegramChatId)" -ForegroundColor Gray
} catch {
    if ($_.Exception.Response.StatusCode.value__ -eq 404) {
        Write-Host "   User not found with phone number $phoneNumber" -ForegroundColor Red
        Write-Host ""
        Write-Host "   Solution:" -ForegroundColor Yellow
        Write-Host "   1. Make sure a user account exists with phone number $phoneNumber" -ForegroundColor White
        Write-Host "   2. The phone number in the database must match exactly: $phoneNumber" -ForegroundColor White
        Write-Host "   3. You can create/update the user account first" -ForegroundColor White
    } else {
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "   The endpoint might not exist yet - restart your backend after the code update" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Phone Number: $phoneNumber" -ForegroundColor White
Write-Host "  Telegram Chat ID: $telegramChatId" -ForegroundColor White
Write-Host ""
Write-Host "When an order is placed with phone number:" -ForegroundColor Yellow
Write-Host "  1. System looks up user by phone number" -ForegroundColor White
Write-Host "  2. If found, checks for Telegram chat ID" -ForegroundColor White
Write-Host "  3. If chat ID exists, sends message to Telegram" -ForegroundColor White
Write-Host ""
Write-Host "Check backend logs when placing an order to see detailed information." -ForegroundColor Cyan
Write-Host ""

