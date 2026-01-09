# Quick Venom Test Script

Write-Host "`n=== Venom WhatsApp Quick Test ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check health
Write-Host "1. Checking server health..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:3001/health" -Method Get
    Write-Host "   ✅ Server is running" -ForegroundColor Green
    Write-Host "   Initialized: $($health.venomInitialized)" -ForegroundColor Gray
    Write-Host "   Initializing: $($health.isInitializing)" -ForegroundColor Gray
} catch {
    Write-Host "   ❌ Server not responding!" -ForegroundColor Red
    Write-Host "   Make sure to run: node venom-server.js" -ForegroundColor Yellow
    exit 1
}

# Step 2: Check status
Write-Host "`n2. Checking connection status..." -ForegroundColor Yellow
try {
    $status = Invoke-RestMethod -Uri "http://localhost:3001/api/default/status" -Method Get
    if ($status.connected) {
        Write-Host "   ✅ CONNECTED! Ready to send messages." -ForegroundColor Green
        exit 0
    } else {
        Write-Host "   ⚠️  Not connected. State: $($status.state)" -ForegroundColor Yellow
    }
} catch {
    $errorResponse = $_.Exception.Response
    if ($errorResponse) {
        $reader = New-Object System.IO.StreamReader($errorResponse.GetResponseStream())
        $body = $reader.ReadToEnd() | ConvertFrom-Json
        Write-Host "   ❌ $($body.error)" -ForegroundColor Red
        Write-Host "   $($body.message)" -ForegroundColor Yellow
        
        if ($body.solution) {
            Write-Host "`n3. Attempting solution: $($body.solution)" -ForegroundColor Cyan
            
            # Clear and reinitialize
            try {
                Write-Host "   Clearing session..." -ForegroundColor Gray
                Invoke-RestMethod -Uri "http://localhost:3001/api/default/clear-session" -Method Post | Out-Null
                Start-Sleep -Seconds 1
                
                Write-Host "   Reinitializing..." -ForegroundColor Gray
                $body = @{clearSession=$true} | ConvertTo-Json
                $result = Invoke-RestMethod -Uri "http://localhost:3001/api/default/reinitialize" -Method Post -ContentType "application/json" -Body $body
                
                Write-Host "   ✅ $($result.message)" -ForegroundColor Green
                
                if ($result.qrAvailable) {
                    Write-Host "   📱 QR Code is available!" -ForegroundColor Green
                    Write-Host "   📸 Check the browser window and scan the QR code" -ForegroundColor Cyan
                } else {
                    Write-Host "   ⚠️  QR code not yet available" -ForegroundColor Yellow
                    if ($result.warning) {
                        Write-Host "   ⚠️  $($result.warning)" -ForegroundColor Yellow
                    }
                    Write-Host "   💡 Wait 5-10 seconds and check /api/default/qr" -ForegroundColor Cyan
                }
                
                if ($result.instructions) {
                    Write-Host "`n   📋 Instructions:" -ForegroundColor Cyan
                    foreach ($inst in $result.instructions) {
                        Write-Host "      $inst" -ForegroundColor Gray
                    }
                }
                
                # Wait and check QR code
                Write-Host "`n4. Waiting 5 seconds and checking for QR code..." -ForegroundColor Yellow
                Start-Sleep -Seconds 5
                
                try {
                    $qrStatus = Invoke-RestMethod -Uri "http://localhost:3001/api/default/qr" -Method Get
                    if ($qrStatus.success) {
                        Write-Host "   ✅ QR code is now available!" -ForegroundColor Green
                        Write-Host "   📱 Scan it with WhatsApp" -ForegroundColor Cyan
                    }
                } catch {
                    Write-Host "   ⚠️  QR code still not available. Check server console for errors." -ForegroundColor Yellow
                }
                
            } catch {
                Write-Host "   ❌ Failed to reinitialize: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "   ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=== Test Complete ===" -ForegroundColor Cyan
Write-Host "💡 Monitor status: Invoke-RestMethod -Uri 'http://localhost:3001/api/default/status' -Method Get" -ForegroundColor Gray
Write-Host ""
