# Fix Phone Number Format and Token Issues

## Issue 1: Phone Number Format ❌

You used: `9443967144` (missing country code)
**Should be:** `919443967144` (with country code 91)

## Issue 2: Token Expired ❌

The validate endpoint is returning 401 Unauthorized, which means your access token has expired.

## ✅ Solutions

### Fix 1: Use Correct Phone Number Format

**Wrong:**
```powershell
-Body '{"to": "9443967144", "message": "Hello!"}'
```

**Correct:**
```powershell
-Body '{"to": "919443967144", "message": "Hello!"}'
```

### Fix 2: Get New Access Token

1. **Go to Meta Developer Console:**
   - https://developers.facebook.com/apps/
   - Select your app
   - Go to **WhatsApp → API Setup**

2. **Generate New Token:**
   - Click **"Generate token"** or copy the existing token
   - Copy the new token (starts with `EAAd...` or `EAAS...`)

3. **Update application.properties:**
   - Open: `backend/src/main/resources/application.properties`
   - Update line 38:
     ```properties
     whatsapp.access.token=YOUR_NEW_TOKEN_HERE
     ```

4. **Restart Backend:**
   ```powershell
   # Stop backend (Ctrl+C)
   cd backend
   mvn spring-boot:run
   ```

5. **Test Again:**
   ```powershell
   Invoke-RestMethod -Uri "http://localhost:8080/api/whatsapp/validate" -Method Get
   ```

## ✅ Correct PowerShell Commands

### Send Message (with correct phone number):
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/whatsapp/send" -Method Post -ContentType "application/json" -Body '{"to": "919443967144", "message": "Hello! This is a test message."}'
```

### Validate Token (after updating):
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/api/whatsapp/validate" -Method Get
```

## Important Notes

1. **Phone Number Format:**
   - ✅ `919443967144` (India: 91 + 9443967144)
   - ❌ `9443967144` (missing country code)
   - ❌ `+919443967144` (has + sign)

2. **Token Expiration:**
   - Temporary tokens expire after ~24 hours
   - You need to generate a new one from Meta Console
   - For production, set up a permanent System User Token

3. **After Updating Token:**
   - Always restart your backend
   - Test with `/api/whatsapp/validate` first
   - Then try sending a message

## Quick Checklist

- [ ] Get new token from Meta Console
- [ ] Update `application.properties` with new token
- [ ] Restart backend
- [ ] Test validation: `/api/whatsapp/validate`
- [ ] Send message with correct phone number: `919443967144`
