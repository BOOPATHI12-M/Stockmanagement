# Telegram Bot Diagnostic Script
# Run this to check if everything is set up correctly

Write-Host "🔍 Telegram Bot Diagnostic Tool" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

$botToken = "8450804892:AAEPQ21Tczy6nZ1DjUFA_4cRFX4V0CwSTmA"

# Test 1: Check Backend is Running
Write-Host "1️⃣ Checking if backend is running..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/telegram/test" -Method Get -ErrorAction Stop
    Write-Host "   ✅ Backend is running" -ForegroundColor Green
    Write-Host "   Configuration: $($response.status)" -ForegroundColor Gray
} catch {
    Write-Host "   ❌ Backend is NOT running on port 8080" -ForegroundColor Red
    Write-Host "   Start it with: cd backend; mvn spring-boot:run" -ForegroundColor Yellow
    exit
}

Write-Host ""

# Test 2: Check Bot Token
Write-Host "2️⃣ Checking bot token..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/telegram/validate" -Method Get -ErrorAction Stop
    if ($response.valid) {
        Write-Host "   ✅ Bot token is valid" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Bot token is invalid" -ForegroundColor Red
        Write-Host "   Error: $($response.message)" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Cannot validate token" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 3: Check Webhook
Write-Host "3️⃣ Checking webhook status..." -ForegroundColor Yellow
try {
    $webhookInfo = Invoke-RestMethod -Uri "https://api.telegram.org/bot$botToken/getWebhookInfo" -Method Get -ErrorAction Stop
    if ($webhookInfo.ok) {
        if ($webhookInfo.result.url) {
            Write-Host "   ✅ Webhook is set" -ForegroundColor Green
            Write-Host "   URL: $($webhookInfo.result.url)" -ForegroundColor Gray
            Write-Host "   Pending updates: $($webhookInfo.result.pending_update_count)" -ForegroundColor Gray
            
            if ($webhookInfo.result.pending_update_count -gt 0) {
                Write-Host "   ⚠️  There are pending updates - webhook might not be working" -ForegroundColor Yellow
            }
        } else {
            Write-Host "   ❌ Webhook is NOT set" -ForegroundColor Red
            Write-Host "   Follow TELEGRAM_WEBHOOK_SETUP.md to set it up" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "   ❌ Cannot check webhook (might be network issue)" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 4: Check Internet Connectivity
Write-Host "4️⃣ Checking internet connectivity..." -ForegroundColor Yellow
try {
    $test = Test-NetConnection api.telegram.org -Port 443 -WarningAction SilentlyContinue
    if ($test.TcpTestSucceeded) {
        Write-Host "   ✅ Can reach Telegram API" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Cannot reach Telegram API" -ForegroundColor Red
        Write-Host "   Check your internet connection" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Network test failed" -ForegroundColor Red
}

Write-Host ""

# Test 5: Test Manual Send
Write-Host "5️⃣ Testing manual message send..." -ForegroundColor Yellow
$chatId = Read-Host "   Enter your Telegram Chat ID (or press Enter to skip)"
if ($chatId) {
    try {
        $body = @{
            chatId = $chatId
            message = "🧪 Test message from diagnostic script"
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "http://localhost:8080/api/telegram/send" -Method Post -ContentType "application/json" -Body $body -ErrorAction Stop
        Write-Host "   ✅ Message sent successfully" -ForegroundColor Green
        Write-Host "   Check your Telegram - you should receive the message" -ForegroundColor Cyan
    } catch {
        Write-Host "   ❌ Failed to send message" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "   ⏭️  Skipped (no chat ID provided)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "📋 Summary:" -ForegroundColor Cyan
Write-Host ""
Write-Host "If webhook is not set:" -ForegroundColor Yellow
Write-Host "  1. Start ngrok: ngrok http 8080" -ForegroundColor White
Write-Host "  2. Copy the HTTPS URL" -ForegroundColor White
Write-Host "  3. Set webhook (see TELEGRAM_WEBHOOK_SETUP.md)" -ForegroundColor White
Write-Host ""
Write-Host "If commands still don't work:" -ForegroundColor Yellow
Write-Host "  1. Check backend logs when you send a command" -ForegroundColor White
Write-Host "  2. Verify your Chat ID is registered in database" -ForegroundColor White
Write-Host "  3. See TELEGRAM_COMMANDS_TROUBLESHOOTING.md" -ForegroundColor White
Write-Host ""
