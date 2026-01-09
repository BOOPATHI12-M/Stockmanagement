# Delivery Man Login Script
# This script helps delivery men login to the system

Write-Host "Delivery Man Login" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Cyan
Write-Host ""

$apiUrl = "http://localhost:8080/api/auth/admin/login"

Write-Host "Enter your delivery man credentials:" -ForegroundColor Yellow
Write-Host ""

$username = Read-Host "Username"
$password = Read-Host "Password" -AsSecureString
$plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
)

Write-Host ""
Write-Host "Logging in..." -ForegroundColor Yellow

$body = @{
    username = $username
    password = $plainPassword
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $apiUrl -Method Post -ContentType "application/json" -Body $body -ErrorAction Stop
    
    Write-Host ""
    Write-Host "Login successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "User Information:" -ForegroundColor Cyan
    Write-Host "  ID: $($response.user.id)" -ForegroundColor Gray
    Write-Host "  Username: $($response.user.username)" -ForegroundColor Gray
    Write-Host "  Name: $($response.user.name)" -ForegroundColor Gray
    Write-Host "  Email: $($response.user.email)" -ForegroundColor Gray
    Write-Host "  Role: $($response.user.role)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Your JWT Token:" -ForegroundColor Cyan
    Write-Host $response.token -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Save this token to use for API requests!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Example API call:" -ForegroundColor Cyan
    Write-Host '  $headers = @{ "Authorization" = "Bearer ' + $response.token + '" }' -ForegroundColor Gray
    Write-Host '  Invoke-RestMethod -Uri "http://localhost:8080/api/delivery/my-orders" -Headers $headers' -ForegroundColor Gray
    Write-Host ""
    
    # Save token to file for easy access
    $tokenFile = "delivery-man-token.txt"
    $response.token | Out-File -FilePath $tokenFile -NoNewline
    Write-Host "Token saved to: $tokenFile" -ForegroundColor Green
    
} catch {
    Write-Host ""
    Write-Host "Login failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.ErrorDetails.Message) {
        $errorDetails = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "Details: $($errorDetails.error)" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "Make sure:" -ForegroundColor Yellow
    Write-Host "  1. Backend is running on http://localhost:8080" -ForegroundColor White
    Write-Host "  2. Username and password are correct" -ForegroundColor White
    Write-Host "  3. Your account exists and has DELIVERY_MAN role" -ForegroundColor White
    Write-Host ""
    Write-Host "If you don't have an account, ask an admin to create one for you." -ForegroundColor Yellow
}

Write-Host ""

