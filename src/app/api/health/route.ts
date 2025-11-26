import { NextResponse } from 'next/server';

/**
 * Health Check Endpoint for Kamal Proxy
 *
 * This endpoint is probed by kamal-proxy during deployment to verify
 * the application is ready to receive traffic. It enables zero-downtime
 * deployments by ensuring new containers are healthy before routing traffic.
 *
 * Returns:
 * - 200 OK: Application is healthy and ready
 * - 503 Service Unavailable: Application is not ready (optional database check)
 */

interface HealthStatus {
  status: 'healthy' | 'unhealthy';
  timestamp: string;
  version: string;
  uptime: number;
  checks: {
    server: 'ok' | 'error';
    database?: 'ok' | 'error' | 'skipped';
  };
}

// Track server start time for uptime calculation
const startTime = Date.now();

export async function GET(): Promise<NextResponse<HealthStatus>> {
  const healthStatus: HealthStatus = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version || '1.0.0',
    uptime: Math.floor((Date.now() - startTime) / 1000),
    checks: {
      server: 'ok',
    },
  };

  // Database connectivity check (soft check - doesn't fail health)
  // The app should be considered healthy even if database isn't ready yet
  // This allows Kamal to route traffic to the container while DB is starting
  // Note: kamal-proxy health check timeout is 3s, so we use a shorter timeout
  try {
    const { prisma } = await import('@/lib/prisma');
    // Add 2 second timeout to prevent health check from hanging
    const timeoutPromise = new Promise((_, reject) =>
      setTimeout(() => reject(new Error('Database check timeout')), 2000)
    );
    await Promise.race([
      prisma.$queryRaw`SELECT 1`,
      timeoutPromise
    ]);
    healthStatus.checks.database = 'ok';
  } catch {
    // Database not ready is a soft failure - app is still healthy
    healthStatus.checks.database = 'error';
    // Don't return 503 - let the app start and handle DB errors gracefully
  }

  return NextResponse.json(healthStatus, {
    status: 200,
    headers: {
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      'Pragma': 'no-cache',
      'Expires': '0',
    },
  });
}

// Also support HEAD requests for lightweight health checks
export async function HEAD(): Promise<NextResponse> {
  return new NextResponse(null, {
    status: 200,
    headers: {
      'Cache-Control': 'no-cache, no-store, must-revalidate',
    },
  });
}
