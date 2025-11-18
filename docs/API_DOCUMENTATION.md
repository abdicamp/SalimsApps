# API Documentation

Dokumentasi API untuk Salims Apps.

## Base URL

```
https://api-salims.chemitechlogilab.com/v1
```

## Authentication

API menggunakan token-based authentication. Token dikirim melalui header atau parameter sesuai endpoint.

## Endpoints

### 1. Check Token

**Endpoint:** `GET /auth/check-token/{username}`

**Description:** Mengecek validitas token user

**Headers:**
- `Authorization: Bearer {token}` (optional)

**Response:**
- `200 OK` - Token valid
- `401 Unauthorized` - Token invalid/expired

---

### 2. Login

**Endpoint:** `POST /auth/login`

**Description:** Login user dan mendapatkan token

**Request Body:**
```json
{
  "username": "string",
  "password": "string",
  "fcm_token": "string"
}
```

**Response Success (200):**
```json
{
  "data": {
    "token": "string",
    "user": {
      "username": "string",
      "name": "string",
      "division": "string",
      // ... other user data
    }
  }
}
```

**Response Error:**
```json
{
  "error": "Error message"
}
```

---

### 3. Get Task List

**Endpoint:** `GET /tasks`

**Description:** Mendapatkan daftar tugas

**Headers:**
- `Authorization: Bearer {token}`

**Query Parameters:**
- `status` (optional) - Filter by status
- `page` (optional) - Page number
- `limit` (optional) - Items per page

**Response:**
```json
{
  "data": [
    {
      "id": "string",
      "title": "string",
      "status": "string",
      "location": "string",
      // ... other task data
    }
  ]
}
```

---

### 4. Get Task Detail

**Endpoint:** `GET /tasks/{taskId}`

**Description:** Mendapatkan detail tugas

**Headers:**
- `Authorization: Bearer {token}`

**Response:**
```json
{
  "data": {
    "id": "string",
    "title": "string",
    "description": "string",
    "parameters": [],
    "samples": [],
    // ... other task detail
  }
}
```

---

### 5. Submit Task

**Endpoint:** `POST /tasks/{taskId}/submit`

**Description:** Submit hasil tugas/sampling

**Headers:**
- `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "samples": [
    {
      "parameter_id": "string",
      "value": "string",
      "image_url": "string",
      "location": {
        "latitude": 0.0,
        "longitude": 0.0,
        "address": "string"
      }
    }
  ]
}
```

**Response:**
```json
{
  "data": {
    "success": true,
    "message": "Task submitted successfully"
  }
}
```

---

### 6. Get History

**Endpoint:** `GET /tasks/history`

**Description:** Mendapatkan riwayat tugas

**Headers:**
- `Authorization: Bearer {token}`

**Query Parameters:**
- `start_date` (optional)
- `end_date` (optional)
- `page` (optional)
- `limit` (optional)

**Response:**
```json
{
  "data": [
    {
      "id": "string",
      "title": "string",
      "completed_at": "datetime",
      // ... other history data
    }
  ]
}
```

---

### 7. Change Password

**Endpoint:** `POST /auth/change-password`

**Description:** Mengubah password user

**Headers:**
- `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "old_password": "string",
  "new_password": "string"
}
```

**Response:**
```json
{
  "data": {
    "success": true,
    "message": "Password changed successfully"
  }
}
```

---

## Error Handling

Semua endpoint mengembalikan error dalam format:

```json
{
  "error": "Error message",
  "code": "ERROR_CODE" // optional
}
```

### HTTP Status Codes

- `200 OK` - Request berhasil
- `400 Bad Request` - Request tidak valid
- `401 Unauthorized` - Token tidak valid atau expired
- `403 Forbidden` - Tidak memiliki akses
- `404 Not Found` - Resource tidak ditemukan
- `500 Internal Server Error` - Server error

---

## Notes

- Semua endpoint yang memerlukan authentication harus menyertakan token di header
- Token memiliki expiration time, perlu refresh jika expired
- Format tanggal menggunakan ISO 8601
- File upload menggunakan multipart/form-data

