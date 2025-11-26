# Deployment Guide for Kamal

This guide explains how to deploy the Next.js Todo application using Kamal.

## Prerequisites

- Kamal installed on your local machine
- Access to a server (VPS, cloud instance, etc.)
- PostgreSQL database accessible from your server
- Docker registry access (Docker Hub, GitHub Container Registry, etc.)

## Configuration

### 1. Environment Variables

Create a `.env.production` file with your production DATABASE_URL:

```env
DATABASE_URL="postgresql://username:password@hostname:5432/database?schema=public"
```

This file should NOT be committed to git (already in .gitignore).

### 2. Kamal Configuration

The application includes a basic Kamal configuration at `config/deploy.yml`. Update it with your details:

```yaml
service: nextjs-todo-app
image: your-username/nextjs-todo-app

servers:
  web:
    - your-server-ip

registry:
  username: your-registry-username
  password:
    - KAMAL_REGISTRY_PASSWORD

env:
  secret:
    - DATABASE_URL

healthcheck:
  path: /api/health
  port: 3000
  interval: 10s
  timeout: 5s
  max_attempts: 10
```

### 3. Database Setup

Before deployment, ensure your PostgreSQL database is ready:

```bash
# Option 1: Run migrations locally against production database
DATABASE_URL="your-production-db-url" npx prisma migrate deploy

# Option 2: SSH into your server and run migrations
ssh user@your-server
docker run --rm \
  -e DATABASE_URL="your-production-db-url" \
  your-username/nextjs-todo-app:latest \
  npx prisma migrate deploy
```

## Deployment Steps

### Initial Setup

1. Set up Kamal secrets:

```bash
export KAMAL_REGISTRY_PASSWORD="your-docker-registry-password"
```

2. Initialize Kamal on your server:

```bash
kamal setup
```

This will:
- Install Docker on your server
- Set up the kamal-proxy for zero-downtime deployments
- Configure necessary directories

### Deploy Application

1. Build and push the Docker image:

```bash
kamal build deliver
```

2. Deploy to your servers:

```bash
kamal deploy
```

This will:
- Pull the Docker image to your server
- Start the container with health checks
- Route traffic via kamal-proxy
- Perform zero-downtime deployment

### Verify Deployment

1. Check application status:

```bash
kamal app details
```

2. View application logs:

```bash
kamal app logs -f
```

3. Test the health endpoint:

```bash
curl https://your-domain.com/api/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "2024-11-26T12:00:00.000Z",
  "version": "1.0.0",
  "uptime": 120,
  "checks": {
    "server": "ok",
    "database": "ok"
  }
}
```

## Health Check Details

The application includes a comprehensive health check at `/api/health` that:

- Verifies the application server is running
- Tests database connectivity with a simple query
- Returns application uptime and version
- Returns 200 OK when healthy, 503 when unhealthy

Kamal uses this endpoint to:
- Verify new containers are ready before routing traffic
- Ensure zero-downtime deployments
- Monitor application health continuously

## Troubleshooting

### Container fails health checks

1. Check container logs:

```bash
kamal app logs --tail 100
```

2. Verify database connectivity:

```bash
kamal app exec 'wget -O- http://localhost:3000/api/health'
```

3. Check environment variables:

```bash
kamal app exec 'printenv | grep DATABASE'
```

### Database connection issues

1. Verify DATABASE_URL is correctly set in Kamal secrets
2. Ensure database is accessible from your server's IP
3. Check firewall rules allow PostgreSQL connections
4. Verify database credentials are correct

### Build failures

1. Test build locally:

```bash
docker build -t test-build .
docker run -p 3000:3000 -e DATABASE_URL="..." test-build
```

2. Check build logs:

```bash
kamal build details
```

## Rollback

If deployment fails, rollback to previous version:

```bash
kamal rollback [VERSION]
```

## Additional Commands

```bash
# Restart application
kamal app restart

# Stop application
kamal app stop

# Remove application
kamal app remove

# SSH into server
kamal app exec bash

# View environment variables
kamal env print
```

## Production Checklist

Before deploying to production:

- [ ] Database migrations run successfully
- [ ] DATABASE_URL environment variable is set
- [ ] Health check endpoint returns 200 OK
- [ ] Application builds successfully
- [ ] Docker image is pushed to registry
- [ ] Server has sufficient resources (CPU, RAM, disk)
- [ ] Database backup strategy is in place
- [ ] SSL/TLS certificates are configured
- [ ] Domain DNS points to your server
- [ ] Monitoring and logging are set up

## Security Recommendations

1. Use strong database passwords
2. Enable SSL/TLS for database connections
3. Keep Docker images updated
4. Regular security audits
5. Monitor application logs for suspicious activity
6. Use environment variables for all secrets
7. Enable firewall on your server
8. Regular backups of database

## Performance Optimization

1. Enable database connection pooling (already configured in Prisma)
2. Add caching layer (Redis) for frequent queries
3. Configure CDN for static assets
4. Monitor database query performance
5. Adjust container resource limits as needed

## Support

For issues with:
- **Next.js**: https://nextjs.org/docs
- **Prisma**: https://www.prisma.io/docs
- **Kamal**: https://kamal-deploy.org/docs
- **PostgreSQL**: https://www.postgresql.org/docs
