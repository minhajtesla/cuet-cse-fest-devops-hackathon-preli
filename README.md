# E-Commerce Microservices - DevOps Hackathon Solution

A fully containerized microservices e-commerce backend with Docker, implementing security best practices, data persistence, and optimized deployments.

## 📋 Problem Statement

The backend setup consisting of:

- A service for managing products (Backend)
- A gateway that forwards API requests (Gateway)
- MongoDB database for data persistence

The system is containerized, secure, optimized, and maintains data persistence across container restarts.

## 🏗️ Architecture

```
                    ┌─────────────────┐
                    │   Client/User   │
                    └────────┬────────┘
                             │
                             │ HTTP (port 5921)
                             │
                    ┌────────▼────────┐
                    │    Gateway      │
                    │  (port 5921)    │
                    │   [Exposed]     │
                    └────────┬────────┘
                             │
                    ┌────────┴────────┐
                    │                 │
         ┌──────────▼──────────┐      │
         │   Private Network   │      │
         │  (Docker Network)   │      │
         └──────────┬──────────┘      │
                    │                 │
         ┌──────────┴──────────┐      │
         │                     │      │
    ┌────▼────┐         ┌──────▼──────┐
    │ Backend │         │   MongoDB   │
    │(port    │◄────────┤  (port      │
    │ 3847)   │         │  27017)     │
    │[Not     │         │ [Not        │
    │Exposed] │         │ Exposed]    │
    └─────────┘         └─────────────┘
```

**Key Points:**
- ✅ Gateway is the only service exposed to external clients (port 5921)
- ✅ All external requests must go through the Gateway
- ✅ Backend and MongoDB are NOT exposed to public network
- ✅ All services communicate via private Docker network

## 📁 Project Structure

```
.
├── backend/                      # Backend microservice (TypeScript + Express)
│   ├── Dockerfile               # Production Dockerfile (multi-stage build)
│   ├── Dockerfile.dev           # Development Dockerfile
│   ├── .dockerignore            # Docker ignore file
│   ├── package.json
│   ├── tsconfig.json
│   └── src/
│       ├── index.ts
│       ├── config/
│       ├── models/
│       ├── routes/
│       └── types/
├── gateway/                     # API Gateway (Node.js + Express)
│   ├── Dockerfile               # Production Dockerfile (multi-stage build)
│   ├── Dockerfile.dev           # Development Dockerfile
│   ├── .dockerignore            # Docker ignore file
│   ├── package.json
│   └── src/
│       └── gateway.js
├── docker/                      # Docker Compose configurations
│   ├── compose.development.yaml # Development environment
│   └── compose.production.yaml  # Production environment
├── .env                         # Environment variables (DO NOT COMMIT)
├── .env.example                 # Example environment file
├── .gitignore                   # Git ignore file
├── Makefile                     # CLI commands for DevOps
└── README.md
```

## 🔐 Environment Setup

### Step 1: Copy Environment File

```bash
# Copy the example file
cp .env.example .env
```

### Step 2: Configure Environment Variables

Edit `.env` file with your values:

```env
# MongoDB Configuration
MONGO_INITDB_ROOT_USERNAME=admin
MONGO_INITDB_ROOT_PASSWORD=your_strong_password

# MongoDB URI (use 'mongodb' as hostname in Docker)
MONGO_URI=mongodb://admin:your_strong_password@mongodb:27017/ecomdb?authSource=admin

# Database name
MONGO_DATABASE=ecomdb

# Service Ports (DO NOT CHANGE)
BACKEND_PORT=3847
GATEWAY_PORT=5921

# Environment
NODE_ENV=development  # or production
```

**⚠️ IMPORTANT:** Never commit the `.env` file to Git!

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Make (optional, for Makefile commands)

### Development Mode

```bash
# Using Make (Recommended)
make quick-start

# Or manually
docker-compose -f docker/compose.development.yaml up --build
```

### Production Mode

```bash
# Using Make (Recommended)
make quick-start-prod

# Or manually
docker-compose -f docker/compose.production.yaml up --build
```

## 📖 Makefile Commands

### Main Commands

```bash
make help              # Show all available commands
make dev-up            # Start development environment
make dev-down          # Stop development environment
make dev-build         # Build development containers
make dev-logs          # View development logs
make prod-up           # Start production environment
make prod-down         # Stop production environment
make prod-build        # Build production containers
```

### Health Checks

```bash
make health            # Check gateway health
make health-backend    # Check backend health via gateway
make health-all        # Check all services
```

### Testing

```bash
make test-all          # Run all API tests
make test-create-product   # Test product creation
make test-get-products     # Test product retrieval
make test-security         # Verify backend is not directly accessible
```

### Cleanup

```bash
make clean             # Remove containers
make clean-all         # Remove containers, images, and volumes
make docker-clean      # Clean Docker system
```

### Other Useful Commands

```bash
make logs SERVICE=backend   # View specific service logs
make shell SERVICE=gateway  # Open shell in container
make ps                     # List running containers
make stats                  # Show container resource usage
```

## 🧪 Testing

Use the following commands to test the implementation:

### Using Make Commands (Recommended)

```bash
# Run all tests automatically
make test-all

# Individual tests
make health              # Check gateway health
make health-backend      # Check backend health
make test-create-product # Create a test product
make test-get-products   # Get all products
make test-security       # Verify backend is not directly accessible
```

### Using cURL Commands

#### Health Checks

Check gateway health:
```bash
curl http://localhost:5921/health
```

Check backend health via gateway:
```bash
curl http://localhost:5921/api/health
```

#### Product Management

Create a product:
```bash
curl -X POST http://localhost:5921/api/products \
  -H 'Content-Type: application/json' \
  -d '{"name":"Test Product","price":99.99}'
```

Get all products:
```bash
curl http://localhost:5921/api/products
```

#### Security Test

Verify backend is not directly accessible (should fail or timeout):
```bash
curl http://localhost:3847/api/products
# This should NOT work - backend is not exposed!
```

## 🔒 Security Features Implemented

1. **Network Isolation**
   - ✅ Backend and MongoDB are NOT exposed to public network
   - ✅ Only Gateway port (5921) is accessible externally
   - ✅ All services communicate via private Docker network

2. **Docker Security**
   - ✅ Multi-stage builds to reduce image size and attack surface
   - ✅ Non-root users in production containers
   - ✅ Health checks for all services
   - ✅ `.dockerignore` files to prevent sensitive data in images

3. **Best Practices**
   - ✅ Environment variables for configuration
   - ✅ Separate dev and prod configurations
   - ✅ Data persistence with Docker volumes
   - ✅ Proper dependency management (`npm ci` instead of `npm install`)
   - ✅ Image optimization with layer caching

## 🎯 DevOps Best Practices Implemented

1. **Container Optimization**
   - Multi-stage Docker builds
   - Minimal Alpine-based images
   - Layer caching for faster builds
   - `.dockerignore` to reduce build context

2. **Configuration Management**
   - Separate dev and production compose files
   - Environment-based configuration
   - `.env.example` for template

3. **Automation**
   - Comprehensive Makefile with 30+ commands
   - Health checks and monitoring
   - Automated testing scripts

4. **Data Persistence**
   - Named Docker volumes for MongoDB
   - Data survives container restarts
   - Separate volumes for dev and prod

5. **Developer Experience**
   - Hot-reloading in development mode
   - Volume mounts for code changes
   - Easy-to-use CLI commands
   - Comprehensive documentation

## 📊 Project Implementation Details

### Development vs Production

| Feature | Development | Production |
|---------|-------------|------------|
| **Dockerfile** | `Dockerfile.dev` | `Dockerfile` (multi-stage) |
| **Build Type** | Single-stage, includes dev deps | Multi-stage, optimized |
| **Hot Reload** | ✅ Yes (volume mounts) | ❌ No |
| **Image Size** | Larger | Optimized |
| **Security** | Basic | Enhanced (non-root user) |
| **Restart Policy** | On failure | Always |
| **Health Checks** | Optional | ✅ Enabled |

### Port Configuration

- **Gateway**: `5921` (Publicly accessible)
- **Backend**: `3847` (Internal network only)
- **MongoDB**: `27017` (Internal network only)

### Docker Network Architecture

```
┌─────────────────────────────────────┐
│         app-network (bridge)        │
│  ┌──────────┐  ┌──────────┐  ┌────┐│
│  │ Gateway  │  │ Backend  │  │ DB ││
│  │  :5921   │──│  :3847   │──│:270││
│  └────┬─────┘  └──────────┘  └────┘│
└───────┼─────────────────────────────┘
        │
    [Public]
```

## 📦 Docker Images

The project builds the following Docker images:

1. **Backend Image**
   - Base: `node:20-alpine`
   - Multi-stage build
   - TypeScript compilation
   - Production dependencies only

2. **Gateway Image**
   - Base: `node:20-alpine`
   - Multi-stage build
   - Optimized for proxy operations

3. **MongoDB Image**
   - Official MongoDB image
   - Persistent volume storage
   - Authentication enabled

## 🛠️ Troubleshooting

### Container won't start

```bash
# Check container logs
make logs SERVICE=backend

# Check all containers
make ps

# Restart services
make restart
```

### Database connection issues

```bash
# Check MongoDB logs
make logs SERVICE=mongodb

# Reset database
make db-reset

# Verify environment variables
cat .env
```

### Port already in use

```bash
# Check what's using the ports
netstat -ano | findstr :5921
netstat -ano | findstr :3847

# Stop all containers
make clean
```

### Clean start

```bash
# Remove everything and start fresh
make clean-all
make quick-start
```

## 📝 Additional Notes

- This project follows the hackathon requirements strictly
- Ports **3847** and **5921** are fixed as per requirements
- Project structure cannot be changed
- All security and optimization best practices are implemented
- Comprehensive Makefile for easy DevOps operations

## 🤝 Submission Checklist

Before submitting, ensure:

- [ ] `.env` file is NOT committed (use `.env.example`)
- [ ] All tests pass (`make test-all`)
- [ ] Backend is NOT directly accessible
- [ ] Gateway is accessible on port 5921
- [ ] Data persists after container restart
- [ ] Production build works (`make prod-up`)
- [ ] Documentation is complete

---

**Good luck with your hackathon!** 🚀

