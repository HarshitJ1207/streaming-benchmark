const http = require('http');

// Generate test files in memory (uncompressed)
const SMALL_FILE = Buffer.alloc(8 * 1024, 'a'); // 8 KB
const LARGE_FILE = Buffer.alloc(200 * 1024, 'b'); // 200 KB

console.log(`Small file: ${SMALL_FILE.length} bytes (8 KB)`);
console.log(`Large file: ${LARGE_FILE.length} bytes (200 KB)`);

const server = http.createServer((req, res) => {
  const path = req.url.split('?')[0];

  if (path === '/small') {
    res.writeHead(200, {
      'Content-Type': 'application/javascript',
      'Content-Length': SMALL_FILE.length,
    });
    res.end(SMALL_FILE);
  } else if (path === '/large') {
    res.writeHead(200, {
      'Content-Type': 'application/javascript',
      'Content-Length': LARGE_FILE.length,
    });
    res.end(LARGE_FILE);
  } else {
    res.writeHead(404);
    res.end('Not found');
  }
});

const PORT = 8080;
server.listen(PORT, () => {
  console.log(`File server running on http://localhost:${PORT}`);
  console.log('Routes: /small (8 KB), /large (200 KB)');
});

