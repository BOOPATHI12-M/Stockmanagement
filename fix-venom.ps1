# Venom WhatsApp Server Diagnostic and Fix Script

Write-Host "`n=== Venom WhatsApp Server Diagnostic ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if server is running
Write-Host "Step 1: Checking if Venom server is running..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:3001/health" -Method Get -ErrorAction Stop
    Write-Host "✅ Server is running" -ForegroundColor Green
    Write-Host "   Status: $($health.status)" -ForegroundColor Gray
    Write-Host "   Initialized: $($health.venomInitialized)" -ForegroundColor Gray
    Write-Host "   Initializing: $($health.isInitializing)" -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "❌ Server is not running on port 3001" -ForegroundColor Red
    Write-Host "   Please start the server with: node venom-server.js" -ForegroundColor Yellow
    exit 1
}

# Step 2: Check detailed status
Write-Host "Step 2: Checking Venom connection status..." -ForegroundColor Yellow
try {
    $status = Invoke-RestMethod -Uri "http://localhost:3001/api/default/status" -Method Get -ErrorAction Stop
    Write-Host "✅ Status retrieved successfully" -ForegroundColor Green
    $status | ConvertTo-Json -Depth 5 | Write-Host
    
    if ($status.connected -eq $true) {
        Write-Host "`n✅ Venom is connected and ready!" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "`n⚠️  Venom is not connected" -ForegroundColor Yellow
        Write-Host "   State: $($status.state)" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Error getting status" -ForegroundColor Red
    $errorResponse = $_.Exception.Response
    
    if ($errorResponse) {
        $reader = New-Object System.IO.StreamReader($errorResponse.GetResponseStream())
        $body = $reader.ReadToEnd() | ConvertFrom-Json
        Write-Host "   Error: $($body.error)" -ForegroundColor Red
        Write-Host "   Message: $($body.message)" -ForegroundColor Yellow
        
        if ($body.solution) {
            Write-Host "   Solution: $($body.solution)" -ForegroundColor Cyan
        }
        
        if ($body.instructions) {
            Write-Host "`n   Instructions:" -ForegroundColor Cyan
            foreach ($instruction in $body.instructions) {
                Write-Host "     - $instruction" -ForegroundColor Gray
            }
        }
    } else {
        Write-Host "   $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Step 3: Clear session and reinitialize
Write-Host "`nStep 3: Clearing session and reinitializing..." -ForegroundColor Yellow

# Clear session first
try {
    Write-Host "   Clearing old session..." -ForegroundColor Gray
    $clearResult = Invoke-RestMethod -Uri "http://localhost:3001/api/default/clear-session" -Method Post -ErrorAction Stop
    Write-Host "   ✅ $($clearResult.message)" -ForegroundColor Green
    Start-Sleep -Seconds 2
} catch {
    Write-Host "   ⚠️  Could not clear session (may not exist): $($_.Exception.Message)" -ForegroundColor Yellow
}

# Reinitialize
try {
    Write-Host "   Starting reinitialization..." -ForegroundColor Gray
    $reinitBody = @{
        clearSession = $true
    } | ConvertTo-Json
    
    $reinit = Invoke-RestMethod -Uri "http://localhost:3001/api/default/reinitialize" -Method Post -ContentType "application/json" -Body $reinitBody -ErrorAction Stop
    Write-Host "   ✅ $($reinit.message)" -ForegroundColor Green
    
    if ($reinit.instructions) {
        Write-Host "`n   📋 Next steps:" -ForegroundColor Cyan
        foreach ($instruction in $reinit.instructions) {
            Write-Host "     - $instruction" -ForegroundColor Gray
        }
    }
    
    Write-Host "`n   ⏳ Waiting 5 seconds for QR code generation..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    
    # Check status again
    Write-Host "`nStep 4: Checking status after reinitialization..." -ForegroundColor Yellow
    try {
        $newStatus = Invoke-RestMethod -Uri "http://localhost:3001/api/default/status" -Method Get -ErrorAction Stop
        if ($newStatus.isInitializing) {
            Write-Host "   ✅ Initialization in progress" -ForegroundColor Green
            Write-Host "   📱 A browser window should have opened with a QR code" -ForegroundColor Cyan
            Write-Host "   📸 Scan the QR code with WhatsApp within 60 seconds" -ForegroundColor Cyan
            Write-Host "`n   💡 Monitor status with:" -ForegroundColor Yellow
            Write-Host "      Invoke-RestMethod -Uri 'http://localhost:3001/api/default/status' -Method Get" -ForegroundColor Gray
        } else {
            $newStatus | ConvertTo-Json -Depth 5 | Write-Host
        }
    } catch {
        Write-Host "   ⚠️  Status check failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "   ❌ Reinitialization failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $body = $reader.ReadToEnd() | ConvertFrom-Json
        Write-Host "   Error details: $($body | ConvertTo-Json)" -ForegroundColor Red
    }
}

Write-Host "`n=== Diagnostic Complete ===" -ForegroundColor Cyan
Write-Host ""
