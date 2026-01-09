# Register Phone Number 9443967144 with Telegram Chat ID 6147323999

Write-Host "Registering Phone Number with Telegram Chat ID" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$phoneNumber = "9443967144"
$telegramChatId = "6147323999"

Write-Host "Phone Number: $phoneNumber" -ForegroundColor Yellow
Write-Host "Telegram Chat ID: $telegramChatId" -ForegroundColor Yellow
Write-Host ""

Write-Host "Registering..." -ForegroundColor Yellow

$body = @{
    phoneNumber = $phoneNumber
    telegramChatId = $telegramChatId
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/update-telegram-by-phone" -Method Post -ContentType "application/json" -Body $body -ErrorAction Stop
    
    Write-Host ""
    Write-Host "Success!" -ForegroundColor Green
    Write-Host ""
    Write-Host "User Account Updated:" -ForegroundColor Cyan
    Write-Host "  Email: $($response.user.email)" -ForegroundColor Gray
    Write-Host "  Mobile: $($response.user.mobile)" -ForegroundColor Gray
    Write-Host "  Telegram Chat ID: $($response.user.telegramChatId)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Now when orders are placed with phone number $phoneNumber," -ForegroundColor Green
    Write-Host "Telegram messages will be sent to chat ID $telegramChatId" -ForegroundColor Green
    Write-Host ""
    
    # Test sending a message
    Write-Host "Testing Telegram message..." -ForegroundColor Yellow
    $testBody = @{
        chatId = $telegramChatId
        message = "Test: Phone number $phoneNumber is now linked! You will receive order notifications here."
    } | ConvertTo-Json
    
    $testResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/telegram/send" -Method Post -ContentType "application/json" -Body $testBody -ErrorAction Stop
    Write-Host "Test message sent! Check your Telegram." -ForegroundColor Green
    
} catch {
    Write-Host ""
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.ErrorDetails.Message) {
        $errorDetails = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "Details: $($errorDetails.error)" -ForegroundColor Red
        if ($errorDetails.message) {
            Write-Host "Message: $($errorDetails.message)" -ForegroundColor Yellow
        }
        if ($errorDetails.suggestion) {
            Write-Host "Suggestion: $($errorDetails.suggestion)" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "Make sure:" -ForegroundColor Yellow
    Write-Host "  1. Backend is running on http://localhost:8080" -ForegroundColor White
    Write-Host "  2. A user account exists with phone number $phoneNumber" -ForegroundColor White
    Write-Host "  3. The phone number in the database matches exactly" -ForegroundColor White
}

Write-Host ""
