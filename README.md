# Node.js (Express + Axios) vs Bun (Hono + fetch) Streaming Benchmark

Isolated benchmark comparing streaming proxy performance between Node.js and Bun for different payload sizes and concurrency levels.

## Structure

```
streaming-benchmark/
├── file-server/     # Static file server (8 KB and 200 KB files)
├── node-proxy/      # Node.js + Express + Axios proxy (port 3000)
├── bun-proxy/       # Bun + Hono + fetch proxy (port 4000)
└── run-benchmark.sh # Automated benchmark script
```

## Setup

```bash
cd node-proxy && npm install
cd ../bun-proxy && bun install
```

## Run Benchmark

```bash
./run-benchmark.sh
```

Tests run at 50, 100, 200, and 500 concurrent connections. Servers restart between each concurrency level for clean results.

---

## Results

### Small File (8 KB) - Requests/sec

| Connections | Node.js | Bun | Bun Advantage |
|-------------|---------|-----|---------------|
| 50 | 9,904 | 76,663 | **7.7x faster** |
| 100 | 9,979 | 28,476 | **2.9x faster** |
| 200 | 9,781 | 14,940 | **1.5x faster** |
| 500 | 8,926 | 11,225 | **1.3x faster** |

### Large File (200 KB) - Requests/sec

| Connections | Node.js | Bun | Winner | Notes |
|-------------|---------|-----|--------|-------|
| 50 | 4,822 | 14,380 | **Bun 3x** | No failures |
| 100 | 4,682 | 10,320 | **Bun 2.2x** | Minor Bun failures (141) |
| 200 | 5,069 | 3,522 | **Node 1.4x** | Bun failures (1,995) |
| 500 | 4,917 | 6,101 | **Bun 1.2x** | Node timeouts (18) |

### Latency @ 50 Connections

| File | Node.js | Bun |
|------|---------|-----|
| Small (8 KB) | 4.5ms | **0.02ms** |
| Large (200 KB) | 9.9ms | **3.0ms** |

---

## Key Findings

### 1. Small Files - Bun Dominates
- **7.7x faster** at low concurrency (50 connections)
- Advantage decreases with load but Bun always wins
- Node.js throughput stays flat (~10k req/s) regardless of concurrency

### 2. Large Files - Mixed Results
- **Bun 2-3x faster** at low-medium concurrency (≤100)
- **Node.js more stable** at high concurrency (≥200)
- Bun starts failing under heavy load with large payloads

### 3. Stability Patterns
- **Node.js**: Rock solid, predictable ~5k req/s for large files
- **Bun**: Higher peak performance but degrades under pressure

---

## Recommendations

| Scenario | Recommendation |
|----------|----------------|
| Small files, any load | ✅ **Bun** |
| Large files, low-medium concurrency (≤100) | ✅ **Bun** |
| Large files, high concurrency (≥200) | ⚠️ **Node.js** (more reliable) |

---

## Test Environment

- macOS
- Node.js v20+
- Bun 1.0+
- autocannon for load testing

