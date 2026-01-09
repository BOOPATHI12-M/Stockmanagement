# Delivery Man Login Guide

## Quick Login

Delivery men login using **username and password** (similar to admin login).

## Login Endpoint

**URL:** `POST http://localhost:8080/api/auth/admin/login`

**Note:** Delivery men use the same login endpoint as admins. The system automatically detects the role.

**Request Body:**
```json
{
  "username": "delivery1",
  "password": "delivery123"
}
```

## Response

**Success Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "username": "delivery1",
    "email": "delivery1@example.com",
    "name": "John Delivery",
    "mobile": "9876543210",
    "role": "DELIVERY_MAN"
  }
}
```

**Error Response (401 Unauthorized):**
```json
{
  "error": "Invalid credentials"
}
```

## Methods to Login

### Method 1: Using PowerShell Script (Easiest)

1. Run the script:
   ```powershell
   .\delivery-man-login.ps1
   ```

2. Enter your username and password when prompted

3. The script will:
   - Login and get your token
   - Display your user information
   - Save the token to `delivery-man-token.txt` for easy access

### Method 2: Using PowerShell Command

```powershell
$body = @{
    username = "delivery1"
    password = "delivery123"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/admin/login" -Method Post -ContentType "application/json" -Body $body

# Save token
$token = $response.token
Write-Host "Token: $token"
```

### Method 3: Using cURL

```bash
curl -X POST http://localhost:8080/api/auth/admin/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "delivery1",
    "password": "delivery123"
  }'
```

### Method 4: Using Postman or API Client

1. Set method to **POST**
2. URL: `http://localhost:8080/api/auth/admin/login`
3. Headers: `Content-Type: application/json`
4. Body (raw JSON):
   ```json
   {
     "username": "delivery1",
     "password": "delivery123"
   }
   ```

## Using the Token

After login, you'll receive a JWT token. Use this token to access delivery man endpoints:

### Example: Get My Orders

```powershell
$token = "YOUR_TOKEN_HERE"
$headers = @{
    "Authorization" = "Bearer $token"
}

$orders = Invoke-RestMethod -Uri "http://localhost:8080/api/delivery/my-orders" -Headers $headers
```

### Example: Accept an Order

```powershell
$token = "YOUR_TOKEN_HERE"
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$response = Invoke-RestMethod -Uri "http://localhost:8080/api/delivery/orders/1/accept" -Method Post -Headers $headers
```

## Available Endpoints After Login

Once logged in, delivery men can access:

- `GET /api/delivery/my-orders` - View assigned orders
- `GET /api/delivery/available-orders` - View available orders
- `POST /api/delivery/orders/{id}/accept` - Accept an order
- `POST /api/delivery/orders/{id}/update-status` - Update order status
- `POST /api/delivery/orders/{id}/update-location` - Update GPS location
- `GET /api/delivery/orders/{id}` - Get order details

## Troubleshooting

### "Invalid credentials" Error

**Possible causes:**
1. Wrong username or password
2. Account doesn't exist
3. Account doesn't have DELIVERY_MAN role

**Solution:**
- Verify your username and password
- Contact admin to create/verify your account
- Make sure your account role is `DELIVERY_MAN`

### "Backend not running" Error

**Solution:**
- Start the backend: `cd backend; mvn spring-boot:run`
- Wait for "Started StockManagementApplication" message
- Try login again

### "Access denied" Error

**Possible causes:**
1. Token expired
2. Token not included in request
3. Wrong role

**Solution:**
- Login again to get a new token
- Make sure to include `Authorization: Bearer YOUR_TOKEN` header
- Verify your account has DELIVERY_MAN role

## Creating a Delivery Man Account

**Note:** Only admins can create delivery man accounts.

If you don't have an account, ask an admin to create one using:
- `POST /api/auth/admin/create-delivery-man`

## Example Complete Flow

```powershell
# 1. Login
$loginBody = @{
    username = "delivery1"
    password = "delivery123"
} | ConvertTo-Json

$loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/admin/login" -Method Post -ContentType "application/json" -Body $loginBody

# 2. Save token
$token = $loginResponse.token

# 3. Use token for API calls
$headers = @{
    "Authorization" = "Bearer $token"
}

# 4. Get my orders
$myOrders = Invoke-RestMethod -Uri "http://localhost:8080/api/delivery/my-orders" -Headers $headers

# 5. View available orders
$availableOrders = Invoke-RestMethod -Uri "http://localhost:8080/api/delivery/available-orders" -Headers $headers

# 6. Accept an order
$acceptResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/delivery/orders/1/accept" -Method Post -Headers $headers
```

## Frontend Integration Example

```javascript
// Login function
const deliveryManLogin = async (username, password) => {
  const response = await fetch('http://localhost:8080/api/auth/admin/login', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ username, password })
  });
  
  if (!response.ok) {
    throw new Error('Login failed');
  }
  
  const data = await response.json();
  
  // Save token to localStorage
  localStorage.setItem('deliveryManToken', data.token);
  localStorage.setItem('deliveryManUser', JSON.stringify(data.user));
  
  return data;
};

// Use token for API calls
const getMyOrders = async () => {
  const token = localStorage.getItem('deliveryManToken');
  
  const response = await fetch('http://localhost:8080/api/delivery/my-orders', {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  
  return response.json();
};
```

