# 📡 API Usage Guide

This document describes how the MyModusFlutter app communicates with its backend services.

## 🔐 Authentication

### Login
**Endpoint:** `POST /api/login`
**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

### Response:
```json
{
  "token": "jwt_token_here",
  "user": {
    "id": "123",
    "email": "user@example.com"
  }
}
```

## 📋 Fetching Tasks
**Endpoint:** `GET /api/tasks`
**Headers:**
```
Authorization: Bearer jwt_token_here
```

### Response:
```json
[
  {
    "id": "1",
    "title": "Morning Routine",
    "completed": false
  }
]
```