# Test Telegram Message Script
# Sends a test message to your Telegram chat ID

Write-Host "Testing Telegram Message" -ForegroundColor Cyan
Write-Host "===========================" -ForegroundColor Cyan
Write-Host ""

$botToken = "8450804892:AAEPQ21Tczy6nZ1DjUFA_4cRFX4V0CwSTmA"
$chatId = "8399999886"

Write-Host "Sending test message to Chat ID: $chatId" -ForegroundColor Yellow
Write-Host ""

# Test message
$message = "Test Message from Stock Management System`n`nThis is a test message to verify Telegram integration.`n`nIf you received this message, your Telegram bot is working correctly!`n`nOrder notifications will be sent to this chat ID when orders are placed."

# Prepare the request
$body = @{
    chat_id = $chatId
    text = $message
} | ConvertTo-Json

$url = "https://api.telegram.org/bot$botToken/sendMessage"

try {
    Write-Host "Sending message..." -ForegroundColor Yellow
    
    $response = Invoke-RestMethod -Uri $url -Method Post -ContentType "application/json" -Body $body -ErrorAction Stop
    
    Write-Host ""
    Write-Host "Message sent successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Check your Telegram - you should have received the test message!" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Response:" -ForegroundColor Gray
    $response | ConvertTo-Json -Depth 3 | Write-Host
    
} catch {
    Write-Host ""
    Write-Host "Failed to send message" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.ErrorDetails.Message) {
        Write-Host ""
        Write-Host "Error Details:" -ForegroundColor Yellow
        $_.ErrorDetails.Message | Write-Host
    }
    
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "  1. Check if your Chat ID is correct (8399999886)" -ForegroundColor White
    Write-Host "  2. Make sure you've started a conversation with your bot" -ForegroundColor White
    Write-Host "  3. Verify the bot token is correct in application.properties" -ForegroundColor White
    Write-Host "  4. Check your internet connection" -ForegroundColor White
}

Write-Host ""
