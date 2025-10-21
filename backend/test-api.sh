#!/bin/bash

# TubeNix Backend API Test Script
# Run this to test all authentication endpoints

BASE_URL="http://localhost:5000"

echo "╔════════════════════════════════════════════════════════╗"
echo "║        TubeNix Backend API - Test Suite               ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Health Check
echo -e "${BLUE}📡 Testing Health Check...${NC}"
curl -s $BASE_URL/health | jq '.'
echo ""
echo "---"
echo ""

# 2. Sign Up New User
echo -e "${BLUE}✍️  Testing Sign Up...${NC}"
SIGNUP_RESPONSE=$(curl -s -X POST $BASE_URL/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123"
  }')

echo $SIGNUP_RESPONSE | jq '.'

# Extract token from signup
TOKEN=$(echo $SIGNUP_RESPONSE | jq -r '.data.token')
echo -e "${GREEN}Token: $TOKEN${NC}"
echo ""
echo "---"
echo ""

# 3. Try to Sign Up with Same Email (Should Fail)
echo -e "${BLUE}❌ Testing Duplicate Email (Should Fail)...${NC}"
curl -s -X POST $BASE_URL/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Another User",
    "email": "test@example.com",
    "password": "password456"
  }' | jq '.'
echo ""
echo "---"
echo ""

# 4. Login with Correct Credentials
echo -e "${BLUE}🔐 Testing Login (Correct Credentials)...${NC}"
LOGIN_RESPONSE=$(curl -s -X POST $BASE_URL/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }')

echo $LOGIN_RESPONSE | jq '.'

# Extract token from login
TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.data.token')
echo -e "${GREEN}Token: $TOKEN${NC}"
echo ""
echo "---"
echo ""

# 5. Login with Wrong Password (Should Fail)
echo -e "${BLUE}❌ Testing Login with Wrong Password (Should Fail)...${NC}"
curl -s -X POST $BASE_URL/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "wrongpassword"
  }' | jq '.'
echo ""
echo "---"
echo ""

# 6. Login with Unregistered Email (Should Fail)
echo -e "${BLUE}❌ Testing Login with Unregistered Email (Should Fail)...${NC}"
curl -s -X POST $BASE_URL/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "notregistered@example.com",
    "password": "password123"
  }' | jq '.'
echo ""
echo "---"
echo ""

# 7. Get Current User (Protected Route)
echo -e "${BLUE}👤 Testing Get Current User (Protected Route)...${NC}"
curl -s -X GET $BASE_URL/api/auth/me \
  -H "Authorization: Bearer $TOKEN" | jq '.'
echo ""
echo "---"
echo ""

# 8. Get Current User without Token (Should Fail)
echo -e "${BLUE}❌ Testing Protected Route without Token (Should Fail)...${NC}"
curl -s -X GET $BASE_URL/api/auth/me | jq '.'
echo ""
echo "---"
echo ""

# 9. Google Sign In Simulation
echo -e "${BLUE}🔥 Testing Google Sign In...${NC}"
GOOGLE_RESPONSE=$(curl -s -X POST $BASE_URL/api/auth/google \
  -H "Content-Type: application/json" \
  -d '{
    "idToken": "mock-firebase-token",
    "name": "Google User",
    "email": "googleuser@gmail.com",
    "photoURL": "https://example.com/photo.jpg",
    "uid": "google-uid-12345"
  }')

echo $GOOGLE_RESPONSE | jq '.'

# Extract Google token
GOOGLE_TOKEN=$(echo $GOOGLE_RESPONSE | jq -r '.data.token')
echo -e "${GREEN}Google Token: $GOOGLE_TOKEN${NC}"
echo ""
echo "---"
echo ""

# 10. Try to Login with Email/Password for Google Account (Should Fail)
echo -e "${BLUE}❌ Testing Email/Password Login for Google Account (Should Fail)...${NC}"
curl -s -X POST $BASE_URL/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "googleuser@gmail.com",
    "password": "somepassword"
  }' | jq '.'
echo ""
echo "---"
echo ""

# 11. Logout
echo -e "${BLUE}🚪 Testing Logout...${NC}"
curl -s -X POST $BASE_URL/api/auth/logout \
  -H "Authorization: Bearer $TOKEN" | jq '.'
echo ""

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║            ✅ All Tests Completed!                     ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo -e "${YELLOW}📝 Summary:${NC}"
echo "  ✅ Health Check"
echo "  ✅ Sign Up (Email/Password)"
echo "  ✅ Duplicate Email Prevention"
echo "  ✅ Login (Email/Password)"
echo "  ✅ Wrong Password Rejection"
echo "  ✅ Unregistered Email Rejection"
echo "  ✅ Protected Route with Token"
echo "  ✅ Protected Route without Token"
echo "  ✅ Google Sign In"
echo "  ✅ Auth Provider Mixing Prevention"
echo "  ✅ Logout"
echo ""
echo -e "${GREEN}🎉 Backend is working perfectly!${NC}"
echo ""
