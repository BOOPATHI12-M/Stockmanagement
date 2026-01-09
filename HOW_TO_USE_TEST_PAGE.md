# How to Use the WhatsApp Test Page

## Option 1: Use a Local HTTP Server (Recommended)

Opening HTML files directly with `file://` can cause CORS issues. Use a simple HTTP server instead:

### Using Python (if installed):
```powershell
# Navigate to project directory
cd "C:\Users\BOOPATHI M\OneDrive\Desktop\project"

# Python 3
python -m http.server 8000

# Or Python 2
python -m SimpleHTTPServer 8000
```

Then open: `http://localhost:8000/test-whatsapp.html`

### Using Node.js (if installed):
```powershell
# Install http-server globally (one time)
npm install -g http-server

# Then run
cd "C:\Users\BOOPATHI M\OneDrive\Desktop\project"
http-server -p 8000
```

Then open: `http://localhost:8000/test-whatsapp.html`

### Using VS Code Live Server:
1. Install "Live Server" extension in VS Code
2. Right-click on `test-whatsapp.html`
3. Select "Open with Live Server"

## Option 2: Use PowerShell (Quick Test)

Instead of the HTML page, you can test directly with PowerShell:

```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/whatsapp/send" -Method Post -ContentType "application/json" -Body '{"to": "919443967144", "message": "Hello! This is a test from my app."}'
```

## Option 3: Fix CORS and Use File Directly

I've updated the CORS configuration to allow `null` origin (file:// protocol). 

**Steps:**
1. **Restart your backend** (the CORS changes need a restart):
   ```powershell
   cd backend
   mvn spring-boot:run
   ```

2. **Make sure backend is running** - Check that you see:
   ```
   Started StockManagementApplication in X.XXX seconds
   ```

3. **Open the HTML file** in your browser:
   - Double-click `test-whatsapp.html`
   - Or right-click → Open with → Browser

4. **Try sending a message**

## Troubleshooting

### "Connection Refused" Error
- **Backend is not running** - Start it with `mvn spring-boot:run`
- **Wrong port** - Make sure backend is on port 8080
- **Firewall blocking** - Check Windows Firewall settings

### CORS Error Still Appearing
1. **Restart backend** after CORS changes
2. **Clear browser cache** - Press Ctrl+Shift+Delete
3. **Try a different browser** - Sometimes browser extensions interfere
4. **Use Option 1** (local HTTP server) instead

### Message Not Sending
1. **Check backend console** for error messages
2. **Verify token** - Run: `http://localhost:8080/api/whatsapp/validate`
3. **Check phone number format** - Must be `919443967144` (no + sign)

## Quick Checklist

- [ ] Backend is running on port 8080
- [ ] Backend was restarted after CORS changes
- [ ] Using local HTTP server OR opened HTML file directly
- [ ] Phone number is in correct format (no + sign)
- [ ] Check backend console for any errors

## Best Practice

**Use Option 1 (Local HTTP Server)** - It's the most reliable way and avoids CORS issues completely!
