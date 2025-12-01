# 🎯 Complete Instructions - DevOps Hackathon Project

## 📌 Project Overview
এই project টি একটি fully containerized e-commerce microservices backend যেখানে:
- **Backend Service**: Product management (TypeScript + Express + MongoDB)
- **Gateway Service**: API routing এবং proxy (Node.js + Express)
- **MongoDB**: Database for data persistence
- **Docker**: সব services containerized
- **Security**: শুধু Gateway public, Backend ও DB private network এ

---

## 🚀 Complete Setup এবং Run Instructions

### Prerequisites (যা লাগবে)

1. **Docker Desktop**
   - Download: https://www.docker.com/products/docker-desktop
   - Install করো এবং চালু করো
   - Green icon দেখলে ready

2. **Git** (already installed হওয়া উচিত)

3. **Make** (Optional - Windows এ থাকতেও পারে নাও পারে)
   - না থাকলে direct docker commands use করবে

---

## 📁 Step 1: Project Clone এবং Navigate

```powershell
# যদি clone করা না থাকে
git clone https://github.com/minhajtesla/cuet-cse-fest-devops-hackathon-preli.git

# Project directory তে যাও
cd "d:\github project Network\cuet-cse-fest-devops-hackathon-preli"

# Project structure দেখো
dir
```

---

## 🔐 Step 2: Environment Variables Setup

### Check করো `.env` file আছে কিনা:
```powershell
cat .env
```

### যদি `.env` না থাকে, তাহলে তৈরি করো:
```powershell
# .env.example থেকে copy করো
copy .env.example .env
```

### `.env` file এ এই values থাকতে হবে:
```env
MONGO_INITDB_ROOT_USERNAME=admin
MONGO_INITDB_ROOT_PASSWORD=password
MONGO_URI=mongodb://admin:password@mongodb:27017/ecomdb?authSource=admin
MONGO_DATABASE=ecomdb
BACKEND_PORT=3847
GATEWAY_PORT=5921
NODE_ENV=development
```

**⚠️ Important**: `.env` file **কখনো Git এ commit করবে না!** (Already `.gitignore` এ আছে)

---

## 🏗️ Step 3: Build Docker Images

### Option A: Make command ব্যবহার করে (Recommended)
```powershell
make dev-build
```

### Option B: Direct Docker command (যদি Make না থাকে)
```powershell
docker compose -f docker/compose.development.yaml build
```

**Build process কি করবে:**
- Backend image build করবে (TypeScript compile হবে)
- Gateway image build করবে
- Dependencies install হবে containers এর ভিতরে
- 2-5 minutes লাগতে পারে first build এ

---

## ▶️ Step 4: Start Services (Development Mode)

### Option A: Make command
```powershell
make dev-up
```

### Option B: Direct Docker command
```powershell
docker compose -f docker/compose.development.yaml up -d
```

**`-d` মানে detached mode (background এ run হবে)**

### Services start হচ্ছে কিনা check করো:
```powershell
# Make দিয়ে
make ps

# অথবা Direct
docker compose -f docker/compose.development.yaml ps
```

**Expected Output:**
```
NAME              STATUS    PORTS
backend-dev       Up        (no external ports)
gateway-dev       Up        0.0.0.0:5921->5921/tcp
mongodb-dev       Up        (no external ports)
```

⏳ **10-15 seconds wait করো services পুরোপুরি start হতে**

---

## ✅ Step 5: Health Checks

### Gateway Health Check:
```powershell
# Make দিয়ে
make health

# অথবা Direct
curl http://localhost:5921/health
```

**Expected Response:** `{"ok":true}`

### Backend Health Check (via Gateway):
```powershell
# Make দিয়ে
make health-backend

# অথবা Direct
curl http://localhost:5921/api/health
```

**Expected Response:** `{"ok":true}`

---

## 🧪 Step 6: API Testing

### Test 1: Create a Product
```powershell
# Make দিয়ে
make test-create-product

# অথবা Direct
curl -X POST http://localhost:5921/api/products -H "Content-Type: application/json" -d "{\"name\":\"Test Product\",\"price\":99.99}"
```

**Expected Response:**
```json
{
  "_id": "...",
  "name": "Test Product",
  "price": 99.99,
  "createdAt": "...",
  "updatedAt": "..."
}
```

### Test 2: Get All Products
```powershell
# Make দিয়ে
make test-get-products

# অথবা Direct
curl http://localhost:5921/api/products
```

**Expected Response:** Array of products

### Test 3: Security Test (Backend Direct Access)
```powershell
# Make দিয়ে
make test-security

# অথবা Direct
curl http://localhost:3847/api/products
```

**Expected Result:** ❌ **Connection refused বা timeout** (This is CORRECT!)

কারণ: Backend port externally exposed না, শুধু Gateway access করতে পারবে

---

## 🎯 Step 7: All Tests একসাথে

```powershell
# Make দিয়ে (Recommended)
make test-all
```

এটা automatically সব tests run করবে:
1. Gateway health ✅
2. Backend health ✅
3. Create product ✅
4. Get products ✅
5. Security check ❌ (Should fail - this is correct!)

---

## 📊 Step 8: Monitor Services

### View Logs:
```powershell
# সব services এর logs
make logs

# Specific service logs
make logs SERVICE=backend
make logs SERVICE=gateway
make logs SERVICE=mongodb

# Direct commands
docker compose -f docker/compose.development.yaml logs -f backend
docker compose -f docker/compose.development.yaml logs -f gateway
```

### Resource Usage দেখো:
```powershell
make stats

# অথবা
docker stats
```

### Container inspect করো:
```powershell
make inspect-backend
make inspect-gateway
```

---

## 🛑 Step 9: Stop Services

```powershell
# Make দিয়ে
make dev-down

# Direct command
docker compose -f docker/compose.development.yaml down
```

**Data persistence:** MongoDB data volume এ save থাকবে, next time start করলে data পাবে

---

## 🏭 Step 10: Production Mode Test

### Stop Development (যদি running থাকে):
```powershell
make dev-down
```

### Build Production Images:
```powershell
# Make দিয়ে
make prod-build

# Direct
docker compose -f docker/compose.production.yaml build
```

**Production build এ কি আলাদা:**
- Multi-stage Docker builds
- Optimized images (smaller size)
- Non-root users (security)
- Health checks enabled
- No hot-reload (stable deployment)

### Start Production:
```powershell
# Make দিয়ে
make prod-up

# Direct
docker compose -f docker/compose.production.yaml up -d
```

### Test Production:
```powershell
# 10-15 seconds wait করে
make test-all

# অথবা individual tests
curl http://localhost:5921/health
curl http://localhost:5921/api/health
curl http://localhost:5921/api/products
```

### Stop Production:
```powershell
make prod-down

# Direct
docker compose -f docker/compose.production.yaml down
```

---

## 🧹 Step 11: Cleanup Commands

### Remove containers only:
```powershell
make clean

# Direct
docker compose -f docker/compose.development.yaml down
docker compose -f docker/compose.production.yaml down
```

### Remove containers + volumes (data মুছে যাবে):
```powershell
make clean-all

# Direct
docker compose -f docker/compose.development.yaml down -v
docker compose -f docker/compose.production.yaml down -v
```

### Docker system cleanup:
```powershell
make docker-clean

# Direct
docker system prune -f
```

---

## 🔧 Troubleshooting Guide

### Problem 1: Port Already in Use (5921 বা 3847)

**Solution:**
```powershell
# সব containers stop করো
make clean-all

# অথবা specific port check করো
netstat -ano | findstr :5921
netstat -ano | findstr :3847

# Process kill করতে হলে (Replace PID)
taskkill /PID <PID_NUMBER> /F
```

### Problem 2: Cannot Connect to Docker Daemon

**Solution:**
1. Docker Desktop open করো
2. Green icon দেখা পর্যন্ত wait করো
3. PowerShell restart করো
4. আবার try করো

### Problem 3: Build Failed

**Solution:**
```powershell
# Cache ছাড়া rebuild করো
docker compose -f docker/compose.development.yaml build --no-cache
```

### Problem 4: Database Connection Error

**Solution:**
```powershell
# Database reset করো
make db-reset

# Direct
docker compose -f docker/compose.development.yaml down -v
docker compose -f docker/compose.development.yaml up -d mongodb
```

### Problem 5: Container Keeps Crashing

**Solution:**
```powershell
# Logs দেখো কি error
make logs SERVICE=backend

# Container inspect করো
docker compose -f docker/compose.development.yaml ps
docker logs backend-dev

# Clean restart
make clean-all
make dev-build
make dev-up
```

---

## 📝 Step 12: Git Commit এবং Push

### Check করো কি changes আছে:
```powershell
git status
```

### Add all changes:
```powershell
git add .
```

### Commit করো:
```powershell
git commit -m "Complete DevOps hackathon solution with Docker containerization"
```

### Push to GitHub:
```powershell
git push origin main
```

**⚠️ Verify করো:**
- `.env` file committed হয়নি ✅
- `node_modules/` committed হয়নি ✅
- `dist/` committed হয়নি ✅

---

## 🏆 Contest Submission Process

### Before Contest Ends:

#### 1. Final Testing
```powershell
# Development test
make dev-build
make dev-up
make test-all

# Production test
make prod-build
make prod-up
make test-all
```

#### 2. Verify Security
```powershell
make test-security
```
**Should FAIL** - Backend directly accessible হবে না

#### 3. Commit এবং Push
```powershell
git add .
git commit -m "Final submission - Complete solution"
git push origin main
```

### Last 5 Minutes of Contest:

#### 1. Make Repository Public
1. GitHub.com এ যাও
2. তোমার repository তে যাও
3. **Settings** click করো
4. Scroll down to **Danger Zone**
5. **Change repository visibility** click করো
6. **Change visibility** button
7. **Make public** select করো
8. Repository name type করো confirm করতে
9. **I understand, change repository visibility** click করো

#### 2. Submit Repository URL
1. **arena.bongodev.com** এ যাও
2. Submission form এ যাও
3. Repository URL paste করো:
   ```
   https://github.com/minhajtesla/cuet-cse-fest-devops-hackathon-preli
   ```
4. Submit করো

### ❌ After Contest Ends:
- **কোনো commit করো না**
- **কোনো push করো না**
- **কোনো code change করো না**
- Disqualification হয়ে যাবে!

---

## 📋 Complete Command Reference

### Quick Start Commands:
```powershell
make help              # Show all commands
make quick-start       # Build + Start + Health check (Dev)
make quick-start-prod  # Build + Start + Health check (Prod)
```

### Build Commands:
```powershell
make dev-build         # Build development images
make prod-build        # Build production images
make build             # Build with MODE=dev or MODE=prod
```

### Service Management:
```powershell
make dev-up            # Start development
make dev-down          # Stop development
make prod-up           # Start production
make prod-down         # Stop production
make restart           # Restart services
```

### Testing Commands:
```powershell
make test-all          # Run all tests
make health            # Gateway health
make health-backend    # Backend health
make health-all        # All health checks
make test-create-product   # Create product test
make test-get-products     # Get products test
make test-security         # Security test
```

### Monitoring Commands:
```powershell
make ps                # List containers
make logs              # View all logs
make logs SERVICE=backend   # View specific logs
make stats             # Container resource usage
```

### Cleanup Commands:
```powershell
make clean             # Remove containers
make clean-all         # Remove containers + volumes + images
make clean-volumes     # Remove volumes only
make docker-clean      # Clean Docker system
make docker-clean-all  # Clean everything
```

### Shell Access:
```powershell
make shell SERVICE=backend   # Backend shell
make backend-shell          # Backend shell
make gateway-shell          # Gateway shell
make mongo-shell            # MongoDB shell
```

### Database Commands:
```powershell
make db-reset          # Reset database
```

### Inspection Commands:
```powershell
make inspect-backend   # Inspect backend container
make inspect-gateway   # Inspect gateway container
make network-inspect   # Inspect Docker network
make volume-inspect    # Inspect volumes
```

---

## 🎯 Features Implemented (Hackathon Requirements)

### ✅ 1. Security
- **Network Isolation**: Backend ও MongoDB private network এ, শুধু Gateway exposed
- **Port Security**: শুধু Gateway port 5921 public, backend 3847 ও MongoDB 27017 internal only
- **Non-root Users**: Production containers এ non-root users
- **Health Checks**: সব services এ health checks enabled

### ✅ 2. Docker Optimization
- **Multi-stage Builds**: Backend ও Gateway উভয়ে multi-stage Dockerfiles
- **Minimal Images**: Alpine-based images (node:20-alpine)
- **Layer Caching**: Efficient layer ordering for faster builds
- **.dockerignore**: Unnecessary files exclude করা হয়েছে
- **npm ci**: `npm install` এর বদলে `npm ci` use করা হয়েছে

### ✅ 3. Data Persistence
- **Named Volumes**: MongoDB data persist করে container restart এ
- **Separate Volumes**: Dev ও Prod এর জন্য আলাদা volumes
- **Volume Backup**: Volume inspect এবং management commands available

### ✅ 4. Separate Dev/Prod Configs
- **Development**: Hot-reload, volume mounts, debug logging
- **Production**: Optimized builds, restart policies, health checks
- **Environment-based**: `.env` file দিয়ে configuration

### ✅ 5. DevOps Best Practices
- **Makefile**: 30+ commands for automation
- **Documentation**: Comprehensive README এবং setup guides
- **Testing**: Automated testing scripts
- **Monitoring**: Logging এবং health check commands
- **.gitignore**: Proper Git ignore configuration
- **.env.example**: Template for environment variables

### ✅ 6. Architecture
```
Client → Gateway (5921) → Private Network → Backend (3847) → MongoDB (27017)
```
- Gateway: Public facing, load balancing
- Backend: Private, business logic
- MongoDB: Private, data storage

---

## 📊 Project Structure

```
cuet-cse-fest-devops-hackathon-preli/
├── backend/
│   ├── Dockerfile              # Production (multi-stage)
│   ├── Dockerfile.dev          # Development
│   ├── .dockerignore           # Build optimization
│   ├── package.json
│   ├── tsconfig.json
│   └── src/
│       ├── index.ts
│       ├── config/             # Configuration files
│       ├── models/             # MongoDB models
│       ├── routes/             # API routes
│       └── types/              # TypeScript types
├── gateway/
│   ├── Dockerfile              # Production (multi-stage)
│   ├── Dockerfile.dev          # Development
│   ├── .dockerignore           # Build optimization
│   ├── package.json
│   └── src/
│       └── gateway.js          # Proxy server
├── docker/
│   ├── compose.development.yaml   # Dev configuration
│   └── compose.production.yaml    # Prod configuration
├── .env                        # Environment variables (NOT committed)
├── .env.example                # Template
├── .gitignore                  # Git ignore rules
├── Makefile                    # DevOps automation
├── README.md                   # Full documentation
├── QUICK_SETUP.md             # Quick start guide
└── COMPLETE_INSTRUCTIONS.md   # This file
```

---

## ✅ Final Checklist

### Before Running:
- [ ] Docker Desktop installed এবং running
- [ ] `.env` file created এবং configured
- [ ] Git repository cloned

### Development Testing:
- [ ] `make dev-build` success
- [ ] `make dev-up` success
- [ ] `make health-all` passes
- [ ] `make test-all` passes (except security test)
- [ ] `make test-security` fails (correct behavior)

### Production Testing:
- [ ] `make prod-build` success
- [ ] `make prod-up` success
- [ ] `make test-all` passes

### Before Submission:
- [ ] All changes committed
- [ ] Pushed to GitHub
- [ ] `.env` NOT committed
- [ ] Repository is PRIVATE

### During Last 5 Minutes:
- [ ] Repository made PUBLIC
- [ ] URL submitted at arena.bongodev.com
- [ ] No more commits after deadline

---

## 🎓 Learning Points

এই project থেকে শিখেছো:
1. **Docker containerization** - Multi-stage builds, optimization
2. **Microservices architecture** - Gateway pattern, service communication
3. **Security** - Network isolation, port management
4. **DevOps** - CI/CD concepts, automation with Makefile
5. **Data persistence** - Docker volumes
6. **Configuration management** - Environment variables
7. **Monitoring** - Logging, health checks
8. **Best practices** - Code organization, documentation

---

## 📞 Support

যদি কোনো problem হয়:
1. `make help` - সব commands দেখো
2. `make logs SERVICE=backend` - Logs check করো
3. `make clean-all` - Clean start করো
4. Docker Desktop restart করো

---

## 🎉 You're Ready!

এই instructions follow করলে তোমার project perfectly run হবে এবং contest এর সব requirements meet করবে।

**All the best for the hackathon!** 🚀

---

**Last Updated:** December 1, 2025  
**Project:** CUET CSE Fest DevOps Hackathon  
**Author:** Complete DevOps Solution with Docker
