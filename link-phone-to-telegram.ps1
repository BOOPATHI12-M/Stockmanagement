# Link Phone Number to Telegram Chat ID
# Phone: 9443967144 -> Telegram Chat ID: 6147323999

$phoneNumber = "9443967144"
$telegramChatId = "6147323999"

Write-Host "Linking Phone Number to Telegram Chat ID" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Phone Number: $phoneNumber" -ForegroundColor Yellow
Write-Host "Telegram Chat ID: $telegramChatId" -ForegroundColor Yellow
Write-Host ""

$body = @{
    phoneNumber = $phoneNumber
    telegramChatId = $telegramChatId
} | ConvertTo-Json

$url = "http://localhost:8080/api/auth/update-telegram-by-phone"

Write-Host "Updating..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri $url -Method Post -ContentType "application/json" -Body $body -ErrorAction Stop
    
    Write-Host ""
    Write-Host "Success!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Linked:" -ForegroundColor Cyan
    Write-Host "  Phone Number: $($response.phoneNumber)" -ForegroundColor Gray
    Write-Host "  Telegram Chat ID: $($response.telegramChatId)" -ForegroundColor Gray
    Write-Host "  User Email: $($response.user.email)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Now when orders are placed with phone number $phoneNumber," -ForegroundColor Green
    Write-Host "Telegram messages will be sent to chat ID $telegramChatId" -ForegroundColor Green
    Write-Host ""
    
} catch {
    Write-Host ""
    Write-Host "Failed to link" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.ErrorDetails.Message) {
        $errorDetails = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "Details: $($errorDetails.error)" -ForegroundColor Red
        Write-Host "Message: $($errorDetails.message)" -ForegroundColor Yellow
        
        if ($errorDetails.suggestion) {
            Write-Host ""
            Write-Host "Suggestion: $($errorDetails.suggestion)" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "Make sure:" -ForegroundColor Yellow
    Write-Host "  1. Backend is running on http://localhost:8080" -ForegroundColor White
    Write-Host "  2. A user account exists with phone number: $phoneNumber" -ForegroundColor White
    Write-Host ""
}

