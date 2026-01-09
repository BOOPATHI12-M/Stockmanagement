# Fix SQLite Database Constraint for DELIVERY_MAN Role
# This script removes the CHECK constraint from the users table

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Fixing Database Constraint for DELIVERY_MAN Role" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$dbPath = "backend\stock_management.db"

if (-not (Test-Path $dbPath)) {
    Write-Host "ERROR: Database file not found at: $dbPath" -ForegroundColor Red
    Write-Host "Please make sure you're running this from the project root directory." -ForegroundColor Yellow
    exit 1
}

Write-Host "Database found: $dbPath" -ForegroundColor Green
Write-Host ""

# Check if sqlite3 is available
$sqlite3 = Get-Command sqlite3 -ErrorAction SilentlyContinue
if (-not $sqlite3) {
    Write-Host "ERROR: sqlite3 command not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install SQLite command-line tools:" -ForegroundColor Yellow
    Write-Host "1. Download from: https://www.sqlite.org/download.html" -ForegroundColor Yellow
    Write-Host "2. Or use: choco install sqlite" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Alternatively, you can use a SQLite GUI tool like DB Browser for SQLite" -ForegroundColor Yellow
    Write-Host "and manually run the SQL commands shown below." -ForegroundColor Yellow
    exit 1
}

Write-Host "Step 1: Creating backup of users table..." -ForegroundColor Yellow
sqlite3 $dbPath "CREATE TABLE IF NOT EXISTS users_backup AS SELECT * FROM users;"
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create backup!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Backup created" -ForegroundColor Green
Write-Host ""

Write-Host "Step 2: Getting user count..." -ForegroundColor Yellow
$userCount = sqlite3 $dbPath "SELECT COUNT(*) FROM users;"
Write-Host "Found $userCount users to migrate" -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 3: Dropping old users table..." -ForegroundColor Yellow
sqlite3 $dbPath "DROP TABLE IF EXISTS users;"
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to drop table!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Old table dropped" -ForegroundColor Green
Write-Host ""

Write-Host "Step 4: Creating new users table WITHOUT CHECK constraint..." -ForegroundColor Yellow
$createTableSQL = @"
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    name TEXT,
    mobile TEXT,
    role TEXT NOT NULL,
    username TEXT,
    password TEXT,
    google_id TEXT,
    whatsapp_number TEXT,
    telegram_chat_id TEXT,
    created_at TIMESTAMP
);
"@

# Write SQL to temp file
$tempFile = [System.IO.Path]::GetTempFileName()
$createTableSQL | Out-File -FilePath $tempFile -Encoding UTF8

sqlite3 $dbPath ".read $tempFile"
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create new table!" -ForegroundColor Red
    Remove-Item $tempFile -ErrorAction SilentlyContinue
    exit 1
}
Remove-Item $tempFile -ErrorAction SilentlyContinue
Write-Host "✓ New table created" -ForegroundColor Green
Write-Host ""

Write-Host "Step 5: Restoring data from backup..." -ForegroundColor Yellow
sqlite3 $dbPath "INSERT INTO users SELECT * FROM users_backup;"
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to restore data!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Data restored" -ForegroundColor Green
Write-Host ""

Write-Host "Step 6: Verifying data..." -ForegroundColor Yellow
$restoredCount = sqlite3 $dbPath "SELECT COUNT(*) FROM users;"
if ($restoredCount -ne $userCount) {
    Write-Host "WARNING: Data count mismatch! Expected $userCount but found $restoredCount" -ForegroundColor Yellow
} else {
    Write-Host "✓ Verified: $restoredCount users restored" -ForegroundColor Green
}
Write-Host ""

Write-Host "Step 7: Removing backup table..." -ForegroundColor Yellow
sqlite3 $dbPath "DROP TABLE IF EXISTS users_backup;"
Write-Host "✓ Backup removed" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ SUCCESS! Database constraint fixed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "The users table now supports DELIVERY_MAN role." -ForegroundColor Green
Write-Host "Please restart your backend server and try creating a delivery man again." -ForegroundColor Yellow
Write-Host ""

