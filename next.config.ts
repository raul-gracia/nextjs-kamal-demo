import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // REQUIRED for Kamal deployment: Enable standalone output
  // This creates a minimal production server in .next/standalone
  output: "standalone",

  // Disable x-powered-by header for security
  poweredByHeader: false,

  // Enable strict mode for React
  reactStrictMode: true,

  // Image optimization configuration
  images: {
    // Add your image domains here if using next/image with external sources
    remotePatterns: [
      // Example:
      // {
      //   protocol: 'https',
      //   hostname: 'example.com',
      //   port: '',
      //   pathname: '/images/**',
      // },
    ],
  },

  // Headers for security (in addition to what kamal-proxy provides)
  async headers() {
    return [
      {
        source: "/:path*",
        headers: [
          {
            key: "X-Content-Type-Options",
            value: "nosniff",
          },
          {
            key: "X-Frame-Options",
            value: "DENY",
          },
          {
            key: "X-XSS-Protection",
            value: "1; mode=block",
          },
          {
            key: "Referrer-Policy",
            value: "strict-origin-when-cross-origin",
          },
        ],
      },
    ];
  },
};

export default nextConfig;
