const https = require('https');
const http = require('http');
const fs = require('fs');
const url = require('url');

const EXTENDED_EXCHANGE_API = 'https://api.extended.exchange/api/v1';
const PORT = 3443;

// Create self-signed certificate for localhost
const serverOptions = {
  key: `-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC7VJTUt9Us8cKB
wEiOfH5pJZhX7dF7Uf8YX7J8A9+gQvFmAlL1i8V0QkXCiGPmEsjBa1Fv3pBWvF
5LwGQKkDfxfD7+8zXzFJZvTvY8b9a2F8kT9+9yVlRKjZlJ6VQ3Ql3p2cYb0Yoz
eHlKsNGt6g5QWBUoEcmT0zDG4WFjzO+Y9KOp5m6pZW7Qyp0k5zN8h0pL1JmU
r0cqOFX0qA9lF8F5v6NrX0w7x6tI8qAzOHJJ0vR7bUg0c4xF3w+G7qD5p1o5V
gU4sFJ7V9OgU3Gl7UqKRmFjmPF1xFi7o8iZG0B8Jv7ZJzPiVsT9xk2K8A9rF8D
F6tF6HeFdFBLAgMBAAECggEBAKdWtlmHnOWgQq4K5M2tZ5UYa+Jz+DnFYLwwEGZ
w8f4qZz7mRXFrD1c1g3X4YfZZQ7qK1F9A5v6HmGz0gK4FGHJNiEiPcR9YBjz4
DqM1JX4KmFjb8gHhRtP9YAK3kW3vJV4zE9jqF7m2jHKhF+8jF6P2dA3zF5Xk
wT5n2EFyF9oD8V3F5Y1fF9R0zJ7qF3F7J8iKhJ2hL4z1Q0aX7P4oPc8+K9q
O6YcF4VL2z3Q2hcL7E+xJ+3U3Y5fQcaJz1a8KiF6g8H4Y7XfQ7eO5b4dFyK9
2Z4mGh5GwqK1XgE2gT4iNbPb7k9PbYc5Q+H0dO2F6m8zHjF9gf8ECQQD4VVi
c7VJQjg9m2Y4xF7aH8fF2xQfL7iYAQABAgKBgD3z8f3R9YQj4FiMbJ8wW3nN
WvE9LUKzVQfpG2e9r1lUz4FsWfPz7W3r4Y8oI+JKFvJ9p2UgKJCGKt8jRvT
qKmFjDv5IjP8F2F0mE1FvFqI2YvB9gL0KmR8T4zYo4V3nG+8F4q9Q2M2tN
oL7q+0Y7QcF4y4kWxF8vQ9J9QBAoGAJv+OyPZJo5Hm1Bc8Z0eQKHoLiI4q
F4cJF9Gu4FqT9xHfqQvZ2kY4pX8oZ8YxE3jh4FuPjF7g6TjXl6wWz3F4+2Y
cG4tKz3Y5pKmGcQ8M5Y4iT7FqL9fBFdF5JqHgT8Y5Fb4iF9L8e6U7QhR4Y
oGAPmzp9qF9Y4GpKmGf8FzQ8bX4o4L4m7Y4pF6qXgF7JhO8F8Y4g9F6y0=
-----END PRIVATE KEY-----`,
  cert: `-----BEGIN CERTIFICATE-----
MIIDazCCAlOgAwIBAgIUQFjD4Bg4V4TL8MjNyZ4K8+1J7+0wDQYJKoZIhvcNAQEL
BQAwRTELMAkGA1UEBhMCVVMxEzARBgNVBAgMCkNhbGlmb3JuaWExITAfBgNVBAoM
GEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDAeFw0yNDA4MTAxMDAwMDBaFw0yNTA4
MTAxMDAwMDBaMEUxCzAJBgNVBAYTAlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMSEw
HwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQwggEiMA0GCSqGSIb3DQEB
AQUAA4IBDwAwggEKAoIBAQC7VJTUt9Us8cKBwEiOfH5pJZhX7dF7Uf8YX7J8A9+g
QvFmAlL1i8V0QkXCiGPmEsjBa1Fv3pBWvF5LwGQKkDfxfD7+8zXzFJZvTvY8b9a2
F8kT9+9yVlRKjZlJ6VQ3Ql3p2cYb0YozeHlKsNGt6g5QWBUoEcmT0zDG4WFjzO+Y
9KOp5m6pZW7Qyp0k5zN8h0pL1JmUr0cqOFX0qA9lF8F5v6NrX0w7x6tI8qAzOHJ
J0vR7bUg0c4xF3w+G7qD5p1o5VgU4sFJ7V9OgU3Gl7UqKRmFjmPF1xFi7o8iZG0B
8Jv7ZJzPiVsT9xk2K8A9rF8DF6tF6HeFdFBLAgMBAAGjUzBRMB0GA1UdDgQWBBS
C5LF2dYoF4HLOdDGhGY9VFXK7jTAfBgNVHSMEGDAWgBSC5LF2dYoF4HLOdDGhGY
9VFXK7jTAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQAKGBU0
I7Z1vJ2X5F6fD2n5K8Qv9w+6Oj8MjgL7Ld9+9zz5QrR8fV9pC4Kc7Q9m2L7yG+
OjOjJ3mF7G+7z5yF4z5F9z2I4z7y9KgH2F8J9x7w8K7XfO5c2Y7F6QJ3Xf2I8
oK1Y5F4Z6z8Y5Q3K4xZ7Y2F8gG9mY4x8xG7Y8kQ2aY6yY4F8i1z5xF7Y5o7f8
Y9X5cH9rY3z6F4qI8P9+H7qZgY3F4L2h9mY4x8Y5F7Q6Y8L5g+mY4o9Y5F2X
Y5H7yGz2Y5F4Y4J8xY5y7mY4xY5F4Y8H7Y9x5QrY3F7Y5F8o7Y3z6F4xY5F
OY5rJ8xY5x7Y4z6F4YJxY5F4Y8xY5F7Y4xY5F7Y2J3mY4z6F4xY8L2Y
-----END CERTIFICATE-----`
};

// Create HTTPS server that proxies requests to Extended Exchange
const server = https.createServer(serverOptions, (req, res) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);

  // Enable CORS for all requests
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, X-Api-Key, Authorization');

  // Handle preflight OPTIONS requests
  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  // Parse the incoming request
  const parsedUrl = url.parse(req.url, true);
  const targetPath = parsedUrl.path;
  
  // Build the target URL
  const targetUrl = `${EXTENDED_EXCHANGE_API}${targetPath}`;
  console.log(`  → Proxying to: ${targetUrl}`);

  // Collect request body for POST requests
  let body = '';
  req.on('data', chunk => {
    body += chunk.toString();
  });

  req.on('end', () => {
    // Prepare request options
    const options = {
      method: req.method,
      headers: {
        ...req.headers,
        'host': 'api.extended.exchange',
        'origin': 'https://api.extended.exchange',
        'referer': 'https://api.extended.exchange/'
      }
    };

    // Remove headers that might cause issues
    delete options.headers['connection'];
    delete options.headers['content-length'];

    // Make request to Extended Exchange API
    const proxyReq = https.request(targetUrl, options, (proxyRes) => {
      console.log(`  ← Response: ${proxyRes.statusCode} ${proxyRes.statusMessage}`);

      // Copy response headers
      Object.keys(proxyRes.headers).forEach(key => {
        res.setHeader(key, proxyRes.headers[key]);
      });

      // Set status code
      res.statusCode = proxyRes.statusCode;

      // Pipe the response
      proxyRes.pipe(res);
    });

    proxyReq.on('error', (error) => {
      console.error(`  ✗ Proxy error: ${error.message}`);
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({
        error: 'Proxy Error',
        message: error.message
      }));
    });

    // Send the request body if present
    if (body) {
      proxyReq.write(body);
    }

    proxyReq.end();
  });

  req.on('error', (error) => {
    console.error(`Request error: ${error.message}`);
    res.writeHead(400, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      error: 'Request Error',
      message: error.message
    }));
  });
});

server.listen(PORT, () => {
  console.log(`🚀 HTTPS Extended Exchange API Proxy Server running on https://localhost:${PORT}`);
  console.log(`   Proxying requests to: ${EXTENDED_EXCHANGE_API}`);
  console.log('');
  console.log('⚠️  Note: This uses a self-signed certificate. Browser will show security warning.');
  console.log('   Click "Advanced" → "Proceed to localhost (unsafe)" to accept.');
  console.log('');
  console.log('Example usage:');
  console.log(`  GET Markets: https://localhost:${PORT}/info/markets`);
  console.log(`  POST Orders: https://localhost:${PORT}/user/order`);
  console.log('');
});

server.on('error', (error) => {
  console.error(`Server error: ${error.message}`);
});