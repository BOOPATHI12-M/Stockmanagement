# Delivery Man User Management

## Overview

Delivery man accounts can **ONLY be created by admins**. Regular users cannot create delivery man accounts through normal registration.

## Admin Endpoints for Delivery Man Management

### 1. Create Delivery Man Account
**Endpoint:** `POST /api/auth/admin/create-delivery-man`

**Authorization:** Admin only

**Request Body:**
```json
{
  "username": "delivery1",
  "password": "password123",
  "email": "delivery1@example.com",
  "name": "John Delivery",
  "mobile": "9876543210"
}
```

**Required Fields:**
- `username` - Unique username for login
- `password` - Password (minimum 6 characters)
- `email` - Email address (must be unique)
- `name` - Full name

**Optional Fields:**
- `mobile` - Phone number

**Response:**
```json
{
  "message": "Delivery man account created successfully",
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

### 2. Get All Delivery Men
**Endpoint:** `GET /api/auth/admin/delivery-men`

**Authorization:** Admin only

**Response:**
```json
[
  {
    "id": 1,
    "username": "delivery1",
    "email": "delivery1@example.com",
    "name": "John Delivery",
    "mobile": "9876543210",
    "role": "DELIVERY_MAN"
  }
]
```

### 3. Update Delivery Man Account
**Endpoint:** `PUT /api/auth/admin/delivery-men/{id}`

**Authorization:** Admin only

**Request Body:**
```json
{
  "name": "John Updated",
  "mobile": "9876543211",
  "email": "newemail@example.com",
  "password": "newpassword123"
}
```

**Note:** All fields are optional. Only include fields you want to update.

### 4. Delete Delivery Man Account
**Endpoint:** `DELETE /api/auth/admin/delivery-men/{id}`

**Authorization:** Admin only

**Response:**
```json
{
  "message": "Delivery man deleted successfully"
}
```

## Delivery Man Login

**Endpoint:** `POST /api/auth/delivery/login`

**Request Body:**
```json
{
  "username": "delivery1",
  "password": "password123"
}
```

**Response:**
```json
{
  "token": "jwt_token_here",
  "user": {
    "id": 1,
    "username": "delivery1",
    "email": "delivery1@example.com",
    "name": "John Delivery",
    "role": "DELIVERY_MAN"
  }
}
```

## Security Features

1. **Admin-Only Creation:** Only users with `ADMIN` role can create delivery man accounts
2. **Username Validation:** Username must be unique
3. **Email Validation:** Email must be unique
4. **Password Requirements:** Minimum 6 characters
5. **Role Verification:** All endpoints verify the user's role before allowing access

## Example Usage

### Create a Delivery Man (Admin Only)

```bash
# Login as admin first
curl -X POST http://localhost:8080/api/auth/admin/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}'

# Use the token to create delivery man
curl -X POST http://localhost:8080/api/auth/admin/create-delivery-man \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -d '{
    "username": "delivery1",
    "password": "delivery123",
    "email": "delivery1@example.com",
    "name": "John Delivery",
    "mobile": "9876543210"
  }'
```

### Delivery Man Login

```bash
curl -X POST http://localhost:8080/api/auth/delivery/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "delivery1",
    "password": "delivery123"
  }'
```

## Frontend Integration

### Admin Dashboard - Create Delivery Man Form

```javascript
const createDeliveryMan = async (formData) => {
  const response = await fetch('/api/auth/admin/create-delivery-man', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${adminToken}`
    },
    body: JSON.stringify({
      username: formData.username,
      password: formData.password,
      email: formData.email,
      name: formData.name,
      mobile: formData.mobile
    })
  });
  
  return response.json();
};
```

### Delivery Man Login

```javascript
const deliveryManLogin = async (username, password) => {
  const response = await fetch('/api/auth/delivery/login', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ username, password })
  });
  
  return response.json();
};
```

## Notes

- Delivery man accounts use username/password authentication (like admin accounts)
- Delivery men cannot create their own accounts
- Only admins can manage (create, update, delete) delivery man accounts
- Delivery man accounts are separate from customer accounts
- Delivery men can login and access delivery-specific endpoints

