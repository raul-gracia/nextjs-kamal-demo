# Quick Start Guide

Get the Next.js Todo application running in 5 minutes!

## Option 1: Local Development (No Database Required Initially)

### Step 1: Install Dependencies
```bash
npm install
```

### Step 2: Set Up PostgreSQL

**Option A: Using Docker (Recommended)**
```bash
# Run PostgreSQL in Docker
docker run -d \
  --name todo-postgres \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_USER=todouser \
  -e POSTGRES_DB=todos \
  -p 5432:5432 \
  postgres:16-alpine

# Your DATABASE_URL will be:
# postgresql://todouser:password@localhost:5432/todos
```

**Option B: Cloud Database (Fastest)**
- [Supabase](https://supabase.com) - Free tier available
- [Neon](https://neon.tech) - Free tier available
- [Railway](https://railway.app) - Free tier available

Get your connection string and use it in the next step.

### Step 3: Configure Environment
```bash
echo 'DATABASE_URL="postgresql://todouser:password@localhost:5432/todos"' > .env
```

Replace with your actual database URL if using cloud.

### Step 4: Set Up Database
```bash
# Generate Prisma Client
npx prisma generate

# Create database tables
npx prisma migrate dev --name init
```

### Step 5: Run Application
```bash
npm run dev
```

Visit [http://localhost:3000](http://localhost:3000)

## Option 2: Production Build

### Build and Run
```bash
# Build
npm run build

# Start production server
npm start
```

## Verification

### Test Health Endpoint
```bash
curl http://localhost:3000/api/health
```

Expected response:
```json
{
  "status": "healthy",
  "database": "ok",
  ...
}
```

### Test Todo Creation
```bash
# Create a todo
curl -X POST http://localhost:3000/api/todos \
  -H "Content-Type: application/json" \
  -d '{"title": "Test Todo"}'

# Get all todos
curl http://localhost:3000/api/todos
```

## Common Issues

### "Failed to connect to database"
- Check if PostgreSQL is running: `docker ps` (if using Docker)
- Verify DATABASE_URL is correct in `.env`
- Test connection: `psql $DATABASE_URL`

### "Prisma Client not generated"
```bash
npx prisma generate
```

### "Port 3000 already in use"
```bash
# Use different port
PORT=3001 npm run dev
```

### Build fails
```bash
# Clean and rebuild
rm -rf .next node_modules
npm install
npm run build
```

## Docker Quick Start

### Build and Run with Docker
```bash
# Build image
docker build -t nextjs-todo .

# Run with Docker
docker run -p 3000:3000 \
  -e DATABASE_URL="your-database-url" \
  nextjs-todo
```

## Database Management

### View Data in Prisma Studio
```bash
npx prisma studio
```

Opens a browser interface at http://localhost:5555

### Reset Database
```bash
npx prisma migrate reset
```

### Create New Migration
```bash
npx prisma migrate dev --name your_migration_name
```

## Next Steps

1. ✅ Application running locally
2. 📝 Read [README.md](README.md) for detailed documentation
3. 🚀 Follow [DEPLOYMENT.md](DEPLOYMENT.md) for production deployment
4. 📊 Check [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) for technical details

## Support

Having issues? Check:
- DATABASE_URL is correctly formatted
- PostgreSQL is running and accessible
- Node.js version is 18 or higher
- All dependencies are installed

## Quick Commands Reference

```bash
# Development
npm run dev              # Start dev server
npm run build            # Build for production
npm start               # Start production server
npm run lint            # Run ESLint

# Prisma
npx prisma generate     # Generate Prisma Client
npx prisma migrate dev  # Run migrations (dev)
npx prisma migrate deploy  # Run migrations (prod)
npx prisma studio       # Open Prisma Studio
npx prisma db push      # Push schema without migration

# Docker
docker build -t todo .  # Build image
docker run -p 3000:3000 todo  # Run container
```

---

**Time to first render:** ~5 minutes
**Prerequisites:** Node.js 18+, PostgreSQL
**Documentation:** README.md, DEPLOYMENT.md, PROJECT_SUMMARY.md
