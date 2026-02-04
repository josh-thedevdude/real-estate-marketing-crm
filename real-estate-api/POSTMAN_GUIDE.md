# Postman Collection - Real Estate CRM API

## Overview
This Postman collection contains all API endpoints for testing the Real Estate CRM application.

## Import Instructions

1. Open Postman
2. Click **Import** button
3. Select the `postman_collection.json` file
4. The collection will be imported with all requests and variables

## Collection Variables

The collection uses the following variables that are automatically set by test scripts:

- `base_url` - API base URL (default: http://localhost:3000)
- `super_admin_token` - JWT token for super admin (auto-set on login)
- `org_admin_token` - JWT token for org admin (auto-set on invitation acceptance)
- `org_user_token` - JWT token for org user
- `organization_id` - ID of created organization (auto-set)
- `user_id` - ID of created user (auto-set)
- `invitation_token` - Invitation token for new user (auto-set)

## Testing Workflow

### 1. Health Check
```
GET /health
```
Verify the server is running.

### 2. Authentication Flow

**Step 1: Login as Super Admin**
```
POST /api/v1/auth/login
Body: {
  "email": "admin@system.com",
  "password": "ChangeMe123!"
}
```
✅ Automatically saves `super_admin_token`

**Step 2: Get Current User**
```
GET /api/v1/auth/me
Headers: Authorization: Bearer {{super_admin_token}}
```

### 3. Organizations Management

**Create Organization**
```
POST /api/v1/organizations
Headers: Authorization: Bearer {{super_admin_token}}
Body: {
  "organization": {
    "name": "Acme Real Estate"
  }
}
```
✅ Automatically saves `organization_id`

**List Organizations**
```
GET /api/v1/organizations
GET /api/v1/organizations?include_deleted=true
```

**Get/Update/Delete Organization**
```
GET    /api/v1/organizations/{{organization_id}}
PATCH  /api/v1/organizations/{{organization_id}}
DELETE /api/v1/organizations/{{organization_id}}
```

### 4. Users Management

**Create User (Invite)**
```
POST /api/v1/users
Headers: Authorization: Bearer {{super_admin_token}}
Body: {
  "user": {
    "email": "orgadmin@acme.com",
    "role": "org_admin",
    "organization_id": {{organization_id}}
  }
}
```
✅ Automatically saves `user_id` and `invitation_token`
✅ Email sent to Mailtrap inbox

**Accept Invitation**
```
POST /api/v1/users/accept_invitation
Body: {
  "invitation_token": "{{invitation_token}}",
  "password": "SecurePass1!"
}
```
✅ Automatically saves `org_admin_token`
✅ Password must be 8-15 characters

**List/Get/Update/Delete Users**
```
GET    /api/v1/users
GET    /api/v1/users?include_deleted=true
GET    /api/v1/users/{{user_id}}
PATCH  /api/v1/users/{{user_id}}
DELETE /api/v1/users/{{user_id}}
```

### 5. Authorization Tests

Test different role permissions:

- **Org Admin - List Users**: Should see only users they created
- **Org Admin - Create Org User**: Should succeed
- **Org Admin - Create Super Admin**: Should fail (403)
- **Org Admin - Access Organizations**: Should fail (403)

## Password Validation Tests

The collection includes requests to test password validation:

1. **Valid Password** (8-15 chars): `SecurePass1!` ✅
2. **Too Short** (< 8 chars): `Short1!` ❌
3. **Too Long** (> 15 chars): `VeryLongPassword123!` ❌

## Expected Responses

### Success Responses
- `200 OK` - Successful GET, PATCH, DELETE
- `201 Created` - Successful POST (create)

### Error Responses
- `401 Unauthorized` - Missing/invalid token
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `422 Unprocessable Entity` - Validation errors

## Auto-Set Variables

The collection uses Postman test scripts to automatically extract and save:

1. **JWT Tokens** - From login and accept_invitation responses
2. **Organization ID** - From create organization response
3. **User ID** - From create user response
4. **Invitation Token** - From create user response

This allows you to run requests sequentially without manual copying!

## Tips

1. **Run in Order**: Execute requests in the order they appear for best results
2. **Check Variables**: View collection variables to see saved tokens and IDs
3. **Email Testing**: Check Mailtrap inbox for invitation emails
4. **Token Expiry**: Re-login if you get 401 errors

## Troubleshooting

**401 Unauthorized**
- Token expired or invalid
- Re-run the login request

**403 Forbidden**
- User doesn't have permission
- Check role-based access rules

**422 Validation Error**
- Check request body format
- Verify password length (8-15 chars)
- Ensure required fields are present

## Environment Setup

If you want to use different environments (dev, staging, prod):

1. Create a Postman environment
2. Set the `base_url` variable
3. Select the environment before running requests
