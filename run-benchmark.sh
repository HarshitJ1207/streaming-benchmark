#!/bin/bash

OUTPUT_FILE="benchmark_results.txt"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Function to start all servers
start_servers() {
  # Start file server
  node "$SCRIPT_DIR/file-server/server.js" &
  FILE_SERVER_PID=$!

  # Start Node.js proxy
  node "$SCRIPT_DIR/node-proxy/server.js" &
  NODE_PROXY_PID=$!

  # Start Bun proxy
  bun "$SCRIPT_DIR/bun-proxy/server.js" &
  BUN_PROXY_PID=$!

  # Wait for servers to be ready
  sleep 3

  # Check if servers are running
  curl -s http://localhost:8080/small > /dev/null || { echo "File server not responding"; return 1; }
  curl -s http://localhost:3000/health > /dev/null || { echo "Node proxy not responding"; return 1; }
  curl -s http://localhost:4000/health > /dev/null || { echo "Bun proxy not responding"; return 1; }

  return 0
}

# Function to stop all servers
stop_servers() {
  kill $FILE_SERVER_PID $NODE_PROXY_PID $BUN_PROXY_PID 2>/dev/null
  sleep 2
}

# Cleanup function for script exit
cleanup() {
  echo "Stopping servers..."
  stop_servers
  exit
}

trap cleanup EXIT INT TERM

# Start benchmark
echo "Streaming Benchmark Results - $(date)" > $OUTPUT_FILE
echo "==========================================" >> $OUTPUT_FILE
echo "File Server: localhost:8080" >> $OUTPUT_FILE
echo "Node.js Proxy: localhost:3000 (Express + Axios)" >> $OUTPUT_FILE
echo "Bun Proxy: localhost:4000 (Hono + fetch)" >> $OUTPUT_FILE
echo "Servers restarted between each concurrency level" >> $OUTPUT_FILE
echo "==========================================" >> $OUTPUT_FILE

# Test with different concurrency levels
for CONN in 50 100 200 500; do
  echo ""
  echo "========================================" | tee -a $OUTPUT_FILE
  echo "Starting fresh servers for ${CONN} connections test..." | tee -a $OUTPUT_FILE
  echo "========================================" | tee -a $OUTPUT_FILE

  start_servers
  if [ $? -ne 0 ]; then
    echo "Failed to start servers, exiting..."
    exit 1
  fi
  echo "All servers ready!"

  echo ""
  echo "=== SMALL FILE (8 KB) @ ${CONN} connections - Node.js ===" | tee -a $OUTPUT_FILE
  autocannon -c $CONN -d 10 http://localhost:3000/small 2>&1 | tee -a $OUTPUT_FILE
  sleep 2

  echo ""
  echo "=== SMALL FILE (8 KB) @ ${CONN} connections - Bun ===" | tee -a $OUTPUT_FILE
  autocannon -c $CONN -d 10 http://localhost:4000/small 2>&1 | tee -a $OUTPUT_FILE
  sleep 2

  echo ""
  echo "=== LARGE FILE (200 KB) @ ${CONN} connections - Node.js ===" | tee -a $OUTPUT_FILE
  autocannon -c $CONN -d 10 http://localhost:3000/large 2>&1 | tee -a $OUTPUT_FILE
  sleep 2

  echo ""
  echo "=== LARGE FILE (200 KB) @ ${CONN} connections - Bun ===" | tee -a $OUTPUT_FILE
  autocannon -c $CONN -d 10 http://localhost:4000/large 2>&1 | tee -a $OUTPUT_FILE

  echo ""
  echo "Stopping servers before next concurrency level..." | tee -a $OUTPUT_FILE
  stop_servers
done

echo ""
echo "==========================================" >> $OUTPUT_FILE
echo "Completed: $(date)" >> $OUTPUT_FILE

echo ""
echo "Results saved to $OUTPUT_FILE"

