#!/bin/sh
# Run one generation batch headless. Usage: tools/run_batch.sh <batch-name>  (reads gen/<batch-name>.md)
set -eu
cd "$(dirname "$0")/.."
mkdir -p gen/raw gen/logs
start=$(date +%s)
omp -p --model xai-oauth/grok-4.7 --thinking high --config omp-imagegen.yml --no-session --auto-approve --no-title \
  --max-time 10m --max-cost 3 "@gen/$1.md" "Follow the instructions in the attached file." >"gen/logs/$1.log" 2>&1
echo "$1: $(( $(date +%s) - start ))s" | tee -a gen/logs/times.txt
