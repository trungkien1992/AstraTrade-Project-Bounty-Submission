#!/usr/bin/env python3
import http.server
import socketserver
import urllib.request
import urllib.parse
import os
import json
from urllib.error import HTTPError

PORT = 8080
API_BASE = 'https://api.extended.exchange'

class CORSProxyHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory='build/web', **kwargs)
    
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-API-Key')
        super().end_headers()
    
    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()
        
    def do_GET(self):
        if self.path.startswith('/api/v1/'):
            self.proxy_request()
        else:
            super().do_GET()
    
    def do_POST(self):
        if self.path.startswith('/api/v1/'):
            self.proxy_request()
        else:
            self.send_error(404)
    
    def proxy_request(self):
        try:
            url = API_BASE + self.path
            print(f"Proxying {self.command} {self.path} -> {url}")
            
            # Prepare request
            req_headers = {}
            for header, value in self.headers.items():
                if header.lower() not in ['host', 'connection']:
                    req_headers[header] = value
            
            # Get request data for POST/PUT
            content_length = self.headers.get('Content-Length')
            data = None
            if content_length:
                data = self.rfile.read(int(content_length))
            
            # Make request
            request = urllib.request.Request(url, data=data, headers=req_headers, method=self.command)
            
            with urllib.request.urlopen(request) as response:
                self.send_response(response.status)
                
                # Copy response headers
                for header, value in response.headers.items():
                    if header.lower() not in ['connection', 'transfer-encoding']:
                        self.send_header(header, value)
                self.end_headers()
                
                # Copy response body
                self.wfile.write(response.read())
                
        except HTTPError as e:
            print(f"HTTP Error: {e.code} {e.reason}")
            self.send_error(e.code, e.reason)
        except Exception as e:
            print(f"Proxy Error: {e}")
            self.send_error(502, 'Bad Gateway')

if __name__ == "__main__":
    with socketserver.TCPServer(("", PORT), CORSProxyHandler) as httpd:
        print(f"🚀 CORS Proxy Server running on http://localhost:{PORT}")
        print(f"📡 Proxying /api/v1/* requests to {API_BASE}")
        print(f"📁 Serving static files from build/web/")
        httpd.serve_forever()