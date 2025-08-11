const http = require('http');
const https = require('https');
const url = require('url');

const EXTENDED_EXCHANGE_API = 'https://api.extended.exchange/api/v1';
const PORT = 3001;

// Create HTTP server that proxies requests to Extended Exchange
const server = http.createServer((req, res) => {
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
  console.log(`🚀 Extended Exchange API Proxy Server running on http://localhost:${PORT}`);
  console.log(`   Proxying requests to: ${EXTENDED_EXCHANGE_API}`);
  console.log('');
  console.log('Example usage:');
  console.log(`  GET Markets: http://localhost:${PORT}/info/markets`);
  console.log(`  POST Orders: http://localhost:${PORT}/user/order`);
  console.log('');
});

server.on('error', (error) => {
  console.error(`Server error: ${error.message}`);
});