# Next Steps - WhatsApp Integration Setup

You're on the Meta Developer Console! Here's exactly what to do next:

## Step 1: Get Your Phone Number ID

1. **Click on "Phone numbers"** in the left sidebar (under WhatsApp section)
   - OR click the "Phone numbers" card in the main content area
2. You'll see your phone number(s) listed
3. **Copy the Phone Number ID** (it's a long number like `936143042909174`)
   - This is usually displayed next to or under your phone number

## Step 2: Get Your Access Token

1. **Click on "API Setup"** in the left sidebar (under WhatsApp section)
   - OR look for "API Setup" or "Getting Started" section
2. You'll see a section with **"Temporary access token"**
3. **Click "Generate token"** or copy the existing token
4. **Copy the token** (it starts with `EAAd...` and is very long)
   - ⚠️ **Important**: This token expires in 24 hours. For production, you'll need a permanent token later.

## Step 3: Test the API (Optional but Recommended)

1. **Click the "Test the API" button** (the blue button you see on the page)
2. This will open a testing interface
3. You can send a test message to your own phone number
4. This confirms your setup is working before integrating with your app

## Step 4: Update Your Configuration

1. Open: `backend/src/main/resources/application.properties`
2. Update these lines with your actual values:

```properties
# WhatsApp Business Cloud API Configuration
whatsapp.api.url=https://graph.facebook.com/v18.0
whatsapp.phone.number.id=PASTE_YOUR_PHONE_NUMBER_ID_HERE
whatsapp.access.token=PASTE_YOUR_ACCESS_TOKEN_HERE
whatsapp.verify.token=sudha-whatsapp
```

**Example:**
```properties
whatsapp.phone.number.id=936143042909174
whatsapp.access.token=EAAdzYvZB2bz8BQGcXjMx3U2S0MY6JSyT9gpSTfZANfE5R4SbL6nw34c1UEyij4uNNwsLfS8xaCZBBTfH1oyBTGvksFYWOXdyCEYawW3bcj58cPhh3ehlbmQx65KMsk7l9tVT8UxwYZCRshxpAW5gq0w0QZATu6ZCOjH0Fin47TyaEUJd2yQvmt3L4cdQxBjVFJ8ZC539ihtqVirYmLpLXklYBHvAJMiIxfX4YV4zZCcGHUZBSYZBeM1ukfAPc6ZABlIhXSQAK96KLiv9BR7Nmkm7gZCNAQZDZD
```

## Step 5: Restart Your Backend

1. Stop your backend server (if running)
2. Restart it:
   ```bash
   cd backend
   mvn spring-boot:run
   ```

## Step 6: Test Your Integration

### Test 1: Check Configuration
Open in browser: `http://localhost:8080/api/whatsapp/test`

You should see:
```json
{
  "apiUrl": "https://graph.facebook.com/v18.0",
  "phoneNumberId": "936143042909174",
  "accessTokenConfigured": true,
  "verifyToken": "sudha-whatsapp",
  "status": "Configuration loaded"
}
```

### Test 2: Send a Test Message

**Option A: Using Browser (if you have a REST client extension)**
- URL: `http://localhost:8080/api/whatsapp/send`
- Method: POST
- Headers: `Content-Type: application/json`
- Body:
```json
{
  "to": "YOUR_PHONE_NUMBER",
  "message": "Hello! This is a test from my app."
}
```

**Option B: Using curl (in terminal/PowerShell)**
```bash
curl -X POST http://localhost:8080/api/whatsapp/send -H "Content-Type: application/json" -d "{\"to\": \"YOUR_PHONE_NUMBER\", \"message\": \"Hello! This is a test from my app.\"}"
```

**Option C: Using Postman**
1. Create new POST request
2. URL: `http://localhost:8080/api/whatsapp/send`
3. Headers: Add `Content-Type: application/json`
4. Body (raw JSON):
```json
{
  "to": "YOUR_PHONE_NUMBER",
  "message": "Hello! This is a test from my app."
}
```

**⚠️ Important**: Replace `YOUR_PHONE_NUMBER` with a real phone number in international format:
- ✅ `919876543210` (India: 91 + number, no + sign)
- ❌ `+919876543210` (wrong - has + sign)
- ❌ `9876543210` (wrong - missing country code)

## Step 7: Check Backend Logs

After sending a test message, check your backend console. You should see:

**Success:**
```
Sending WhatsApp message to: 919876543210
URL: https://graph.facebook.com/v18.0/936143042909174/messages
✅ WhatsApp sent successfully!
Response: {"messages":[{"id":"wamid.xxx"}]}
```

**Error:**
```
❌ WhatsApp error occurred:
Error: 401 Unauthorized
```

If you see an error, check:
1. Is your access token valid? (They expire after 24 hours)
2. Is your phone number ID correct?
3. Is the recipient phone number in correct format?

## Step 8: Set Up Webhook (Optional - For Receiving Messages)

If you want to receive WhatsApp messages and use the bot commands:

1. **Install ngrok** (for local testing): https://ngrok.com/download
2. **Start your backend** on port 8080
3. **Run ngrok**:
   ```bash
   ngrok http 8080
   ```
4. **Copy the HTTPS URL** (e.g., `https://abc123.ngrok.io`)
5. **In Meta Console**:
   - Go to **WhatsApp → Configuration → Webhook**
   - Click **"Edit"** or **"Configure"**
   - Webhook URL: `https://your-ngrok-url.ngrok.io/api/whatsapp/webhook`
   - Verify Token: `sudha-whatsapp`
   - Click **"Verify and Save"**
   - Subscribe to: `messages` and `message_status`

## Quick Checklist

- [ ] Got Phone Number ID from Meta Console
- [ ] Got Access Token from Meta Console
- [ ] Updated `application.properties` with credentials
- [ ] Restarted backend server
- [ ] Tested configuration endpoint (`/api/whatsapp/test`)
- [ ] Sent a test message successfully
- [ ] Checked backend logs for any errors

## Need Help?

- **Token expired?** → Go back to Meta Console → API Setup → Generate new token
- **Message not sending?** → Check backend logs for specific error
- **401 Unauthorized?** → Your token is invalid/expired, get a new one
- **Phone number format error?** → Use international format without + (e.g., `919876543210`)

## What Happens Next?

Once working, your app will automatically:
- ✅ Send order confirmations via WhatsApp
- ✅ Send order status updates
- ✅ Send low stock alerts to admin
- ✅ Send expiry alerts to admin
- ✅ Respond to WhatsApp bot commands (if webhook is set up)

🎉 **You're all set!** Just get those credentials and update the config file!
