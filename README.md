# Next.js 15 Todo Application

A modern, full-stack todo application built with Next.js 15, TypeScript, PostgreSQL, Prisma ORM, and TailwindCSS.

## Features

- Create, read, update, and delete todos
- Toggle todo completion status
- Real-time statistics (total, completed, pending)
- Modern, responsive UI with dark mode support
- Health check endpoint for Kamal proxy deployments
- PostgreSQL database with Prisma ORM
- Type-safe API routes with Next.js 15 App Router

## Tech Stack

- **Framework**: Next.js 15 (App Router)
- **Language**: TypeScript
- **Database**: PostgreSQL
- **ORM**: Prisma v7
- **Styling**: TailwindCSS
- **Deployment**: Kamal-ready with health checks

## Prerequisites

- Node.js 18+ installed
- PostgreSQL database instance (local or remote)

## Setup Instructions

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Database

Create a `.env` file in the root directory and add your PostgreSQL connection string:

```env
DATABASE_URL="postgresql://username:password@localhost:5432/database_name?schema=public"
```

Replace the placeholders:
- `username`: Your PostgreSQL username
- `password`: Your PostgreSQL password
- `localhost:5432`: Your PostgreSQL host and port
- `database_name`: Your database name

### 3. Run Database Migrations

Generate Prisma client and create the database schema:

```bash
# Generate Prisma Client
npx prisma generate

# Create database tables (requires running PostgreSQL)
npx prisma migrate dev --name init
```

If you don't have a local PostgreSQL instance, you can:
- Use a cloud provider (Supabase, Railway, Neon, etc.)
- Run PostgreSQL with Docker: `docker run -e POSTGRES_PASSWORD=password -p 5432:5432 postgres`

### 4. Run Development Server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to view the application.

## Project Structure

```
nextjs-test-kamal/
├── prisma/
│   └── schema.prisma          # Prisma database schema
├── src/
│   ├── app/
│   │   ├── api/
│   │   │   ├── health/        # Health check endpoint
│   │   │   │   └── route.ts
│   │   │   └── todos/         # Todo CRUD endpoints
│   │   │       ├── route.ts   # GET, POST
│   │   │       └── [id]/
│   │   │           └── route.ts # PATCH, DELETE
│   │   ├── globals.css        # Global styles
│   │   ├── layout.tsx         # Root layout
│   │   └── page.tsx           # Home page
│   ├── components/
│   │   └── TodoList.tsx       # Main todo list component
│   └── lib/
│       └── prisma.ts          # Prisma client singleton
├── .env                       # Environment variables (not in git)
├── next.config.ts             # Next.js configuration
├── package.json
├── tailwind.config.ts         # TailwindCSS configuration
└── tsconfig.json              # TypeScript configuration
```

## API Endpoints

### Todos

- `GET /api/todos` - List all todos
- `POST /api/todos` - Create a new todo
  - Body: `{ "title": "Todo title" }`
- `PATCH /api/todos/[id]` - Toggle todo completion
  - Body: `{ "completed": true/false }`
- `DELETE /api/todos/[id]` - Delete a todo

### Health Check

- `GET /api/health` - Application health status
  - Returns: `{ status: "healthy", timestamp: "...", database: "ok", ... }`

## Production Build

```bash
# Build for production
npm run build

# Start production server
npm start
```

## Deployment with Kamal

This application is configured for Kamal deployment with:
- Health check endpoint at `/api/health`
- Standalone output mode in `next.config.ts`
- Database connectivity verification

The health endpoint checks:
- Application server status
- Database connectivity
- Application uptime

## Database Schema

### Todo Model

```prisma
model Todo {
  id        String   @id @default(uuid())
  title     String
  completed Boolean  @default(false)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

## Environment Variables

Required environment variables:

- `DATABASE_URL` - PostgreSQL connection string

Optional environment variables:

- `NODE_ENV` - Environment (development, production)

## Development Tips

### Reset Database

```bash
npx prisma migrate reset
```

### View Database in Prisma Studio

```bash
npx prisma studio
```

### Generate Prisma Client After Schema Changes

```bash
npx prisma generate
```

## License

MIT
