# Benchmark Results Analysis

Detailed analysis of Node.js (Express + Axios) vs Bun (Hono + fetch) streaming proxy performance.

## Test Configuration

- **Duration**: 10 seconds per test
- **Concurrency levels**: 50, 100, 200, 500 connections
- **File sizes**: 8 KB (small), 200 KB (large)
- **Servers restarted** between each concurrency level for clean results

---

## Small File (8 KB) Performance

### Throughput (Requests/sec)

| Connections | Node.js | Bun | Ratio |
|-------------|---------|-----|-------|
| 50 | 9,904 | 76,663 | Bun **7.7x** faster |
| 100 | 9,979 | 28,476 | Bun **2.9x** faster |
| 200 | 9,781 | 14,940 | Bun **1.5x** faster |
| 500 | 8,926 | 11,225 | Bun **1.3x** faster |

### Bytes/sec Throughput

| Connections | Node.js | Bun | Ratio |
|-------------|---------|-----|-------|
| 50 | 83 MB/s | 640 MB/s | Bun **7.7x** |
| 100 | 83.6 MB/s | 238 MB/s | Bun **2.8x** |
| 200 | 81.9 MB/s | 125 MB/s | Bun **1.5x** |
| 500 | 74.8 MB/s | 93.5 MB/s | Bun **1.25x** |

### Latency

| Connections | Node.js Avg | Node.js p99 | Bun Avg | Bun p99 |
|-------------|-------------|-------------|---------|---------|
| 50 | 4.54ms | 7ms | **0.02ms** | 1ms |
| 100 | 9.52ms | 15ms | **3.01ms** | 17ms |
| 200 | 19.94ms | 28ms | **12.89ms** | 62ms |
| 500 | 55.4ms | 103ms | **43.87ms** | 260ms |

### Observations - Small Files

1. **Bun dominates at low concurrency** - 7.7x faster at 50 connections due to:
   - Lower per-request overhead
   - Native Web Streams (no conversion needed)
   - More efficient event loop

2. **Advantage decreases with load** - As concurrency increases, both runtimes spend more time on I/O rather than per-request overhead

3. **Node.js throughput is remarkably stable** - Stays at ~10k req/s regardless of concurrency

4. **Bun latency degrades at high concurrency** - p99 jumps to 260ms at 500 connections vs Node's 103ms

---

## Large File (200 KB) Performance

### Throughput (Requests/sec)

| Connections | Node.js | Bun | Winner |
|-------------|---------|-----|--------|
| 50 | 4,822 | 14,380 | Bun **3.0x** faster |
| 100 | 4,682 | 10,320 | Bun **2.2x** faster |
| 200 | 5,069 | 3,522 | Node **1.4x** faster |
| 500 | 4,917 | 6,101 | Bun **1.2x** faster |

### Bytes/sec Throughput

| Connections | Node.js | Bun | Winner |
|-------------|---------|-----|--------|
| 50 | 988 MB/s | 2.95 GB/s | Bun **3x** |
| 100 | 960 MB/s | 2.11 GB/s | Bun **2.2x** |
| 200 | 1.04 GB/s | 681 MB/s | Node **1.5x** |
| 500 | 1.01 GB/s | 1.25 GB/s | Bun **1.2x** |

### Latency

| Connections | Node.js Avg | Node.js p99 | Bun Avg | Bun p99 |
|-------------|-------------|-------------|---------|---------|
| 50 | 9.87ms | 15ms | **3.03ms** | 6ms |
| 100 | 20.84ms | 29ms | **9.21ms** | 29ms |
| 200 | 38.89ms | 55ms | 56.04ms | 338ms |
| 500 | 97.08ms | 182ms | 77.82ms | 180ms |

### Failure Analysis

| Connections | Node.js Failures | Bun Failures |
|-------------|------------------|--------------|
| 50 | 0 | 0 |
| 100 | 0 | 141 non-2xx (0.14%) |
| 200 | 0 | 1,995 non-2xx (5.7%) |
| 500 | 18 timeouts | 0 |

### Observations - Large Files

1. **Bun excels at low-medium concurrency** - 2-3x faster at ≤100 connections

2. **Crossover at 200 connections** - Node.js becomes faster and more reliable
   - Bun failure rate jumps to 5.7%
   - Node.js maintains zero failures

3. **Node.js throughput incredibly stable** - Stays at ~5k req/s (1 GB/s) regardless of load

---

## Total Data Transferred

| Test | Node.js | Bun |
|------|---------|-----|
| Small @ 50 | 913 MB | 7.04 GB |
| Small @ 100 | 920 MB | 2.62 GB |
| Small @ 200 | 901 MB | 1.25 GB |
| Small @ 500 | 748 MB | 935 MB |
| Large @ 50 | 9.88 GB | 32.4 GB |
| Large @ 100 | 10.6 GB | 21.1 GB |
| Large @ 200 | 10.4 GB | 6.81 GB |
| Large @ 500 | 11.1 GB | 12.5 GB |


