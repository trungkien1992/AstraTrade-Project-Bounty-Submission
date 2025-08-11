const http = require('http');
const https = require('https');
const url = require('url');

const PORT = 8080;
const API_BASE = 'https://api.extended.exchange';

const server = http.createServer((req, res) => {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-API-Key');
  
  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  const reqUrl = url.parse(req.url);
  console.log(`${new Date().toISOString()} ${req.method} ${req.url}`);
  
  // Check if this is an API request
  if (reqUrl.pathname.startsWith('/api/v1/')) {
    // Proxy API requests
    const targetUrl = API_BASE + req.url;
    console.log(`Proxying to: ${targetUrl}`);
    
    const options = {
      method: req.method,
      headers: {
        ...req.headers,
        host: 'api.extended.exchange'
      }
    };
    
    const proxyReq = https.request(targetUrl, options, (proxyRes) => {
      // Set CORS headers on the proxied response
      res.setHeader('Access-Control-Allow-Origin', '*');
      res.writeHead(proxyRes.statusCode, proxyRes.headers);
      proxyRes.pipe(res);
    });
    
    proxyReq.on('error', (e) => {
      console.error('Proxy error:', e.message);
      res.writeHead(502);
      res.end('Bad Gateway');
    });
    
    req.pipe(proxyReq);
    
  } else {
    // Serve static files from build/web
    const fs = require('fs');
    const path = require('path');
    
    let filePath = path.join(__dirname, 'build/web', reqUrl.pathname);
    
    // Default to index.html for SPA routing
    if (reqUrl.pathname === '/' || !path.extname(filePath)) {
      filePath = path.join(__dirname, 'build/web/index.html');
    }
    
    fs.readFile(filePath, (err, data) => {
      if (err) {
        res.writeHead(404);
        res.end('File not found');
        return;
      }
      
      // Set correct content type
      const ext = path.extname(filePath);
      const contentTypes = {
        '.html': 'text/html',
        '.js': 'application/javascript',
        '.css': 'text/css',
        '.json': 'application/json',
        '.png': 'image/png',
        '.jpg': 'image/jpeg',
        '.ico': 'image/x-icon',
        '.ttf': 'font/ttf',
        '.otf': 'font/otf'
      };
      
      const contentType = contentTypes[ext] || 'application/octet-stream';
      res.setHeader('Content-Type', contentType);
      res.writeHead(200);
      res.end(data);
    });
  }
});

server.listen(PORT, () => {
  console.log(`🚀 CORS Proxy Server running on http://localhost:${PORT}`);
  console.log(`📡 Proxying /api/v1/* requests to ${API_BASE}`);
  console.log(`📁 Serving static files from build/web/`);
});