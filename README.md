# Node.js (Express) vs Bun (Hono) Streaming Performance Benchmark

This benchmark isolates and compares streaming performance between Node.js (Express) and Bun (Hono) for different payload sizes.

## Structure

```
streaming-benchmark/
├── file-server/     # Static file server (serves large and small files)
├── node-proxy/      # Node.js + Express proxy server
└── bun-proxy/       # Bun + Hono proxy server
```

## Setup

### 1. Start the file server (port 8080)
```bash
cd file-server
node server.js
```

### 2. Start the Node.js proxy (port 3000)
```bash
cd node-proxy
npm install
node server.js
```

### 3. Start the Bun proxy (port 4000)
```bash
cd bun-proxy
bun install
bun server.js
```

## Running Benchmarks

```bash
# Small file (~8 KB)
autocannon -c 500 -d 10 http://localhost:3000/small
autocannon -c 500 -d 10 http://localhost:4000/small

# Large file (~200 KB)
autocannon -c 500 -d 10 http://localhost:3000/large
autocannon -c 500 -d 10 http://localhost:4000/large
```

## Hypothesis

- **Small files**: Bun should significantly outperform Node.js (per-request overhead dominates)
- **Large files**: Performance should be similar (I/O throughput dominates)

