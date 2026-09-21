#!/usr/bin/env bash
# Seedance 2.0 Mini — submit a task and poll it
set -eu
export APIMART_API_KEY="${APIMART_API_KEY:?set APIMART_API_KEY first}"
curl --request POST --url https://api.apimart.ai/v1/videos/generations \
  --header "Authorization: Bearer $APIMART_API_KEY" \
  --header 'Content-Type: application/json' \
  --data '{"model":"seedance-2.0-mini","prompt":"a cozy reading nook by a rainy window","n":1}'
