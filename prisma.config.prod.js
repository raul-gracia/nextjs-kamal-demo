// Production-ready Prisma config (no TypeScript dependencies)
// Used by Prisma CLI for database migrations in the production container

module.exports = {
  schema: 'prisma/schema.prisma',
  datasource: {
    url: process.env.DATABASE_URL
  }
};
