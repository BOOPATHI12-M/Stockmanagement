# Test Backend Telegram API
# Tests the backend API endpoint for sending Telegram messages

Write-Host "Testing Backend Telegram API" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host ""

$chatId = "8399999886"
$message = "Test message from backend API - Order notifications are working!"

$body = @{
    chatId = $chatId
    message = $message
} | ConvertTo-Json

$url = "http://localhost:8080/api/telegram/send"

Write-Host "Sending message via backend API..." -ForegroundColor Yellow
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri $url -Method Post -ContentType "application/json" -Body $body -ErrorAction Stop
    
    Write-Host "Success!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Response:" -ForegroundColor Gray
    $response | ConvertTo-Json -Depth 3 | Write-Host
    Write-Host ""
    Write-Host "Check your Telegram - you should have received the message!" -ForegroundColor Cyan
    
} catch {
    Write-Host "Failed to send message" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.ErrorDetails.Message) {
        Write-Host ""
        Write-Host "Error Details:" -ForegroundColor Yellow
        $_.ErrorDetails.Message | Write-Host
    }
    
    Write-Host ""
    Write-Host "Make sure your backend is running on http://localhost:8080" -ForegroundColor Yellow
}

Write-Host ""

