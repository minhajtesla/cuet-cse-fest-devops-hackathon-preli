# 🚀 Quick Setup Guide for Your Friend

## Prerequisites
- Docker Desktop installed and running
- Git installed
- (Optional) Node.js and npm for local development

## Setup Steps

### 1. Navigate to Project
```powershell
cd "d:\github project Network\cuet-cse-fest-devops-hackathon-preli"
```

### 2. Verify Environment File
Check that `.env` file exists with proper values:
```powershell
cat .env
```

Should contain:
```
MONGO_INITDB_ROOT_USERNAME=admin
MONGO_INITDB_ROOT_PASSWORD=password
MONGO_URI=mongodb://admin:password@mongodb:27017/ecomdb?authSource=admin
MONGO_DATABASE=ecomdb
BACKEND_PORT=3847
GATEWAY_PORT=5921
NODE_ENV=development
```

### 3. Start Development Environment
```powershell
# Build and start all services
make dev-build
make dev-up

# Wait 10-15 seconds for services to start
```

### 4. Test the Application
```powershell
# Run all tests
make test-all
```

Expected results:
- ✅ Gateway health check: SUCCESS
- ✅ Backend health check: SUCCESS
- ✅ Create product: SUCCESS
- ✅ Get products: SUCCESS
- ❌ Direct backend access: SHOULD FAIL (this is correct - security working!)

### 5. View Logs (if needed)
```powershell
make logs SERVICE=backend
make logs SERVICE=gateway
make logs SERVICE=mongodb
```

### 6. Stop Services
```powershell
make dev-down
```

## Testing Production Mode

```powershell
# Stop development if running
make dev-down

# Start production
make prod-build
make prod-up

# Wait 10-15 seconds, then test
make test-all

# Stop when done
make prod-down
```

## Common Commands

```powershell
make help              # Show all available commands
make ps                # List running containers
make stats             # Show resource usage
make clean             # Remove containers
make clean-all         # Complete cleanup
```

## Troubleshooting

### "Port already in use"
```powershell
make clean-all
```

### "Cannot connect to Docker daemon"
- Start Docker Desktop
- Wait for it to fully start
- Try again

### Database connection issues
```powershell
make db-reset
```

### View service details
```powershell
make inspect-backend
make inspect-gateway
make network-inspect
```

## For Contest Submission

### Before Submitting:
1. ✅ Test everything works: `make test-all`
2. ✅ Verify security: `make test-security` (should fail)
3. ✅ Test production mode: `make prod-up` → `make test-all`
4. ✅ Commit all changes
5. ✅ Push to GitHub

### During Contest:
- Keep repository PRIVATE until last 5 minutes
- Make repository PUBLIC in last 5 minutes
- Submit URL at arena.bongodev.com
- NO COMMITS after contest ends!

## Project Status: ✅ READY FOR CONTEST

All features implemented:
- ✅ Security (only Gateway exposed)
- ✅ Data persistence (MongoDB volumes)
- ✅ Optimization (multi-stage builds)
- ✅ Dev & Prod configs
- ✅ Comprehensive Makefile
- ✅ Full documentation

Good luck! 🎉
