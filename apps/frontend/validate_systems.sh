#!/bin/bash
echo "🚀 AstraTrade Pre-Demo Validation"
echo "=================================="

# Test 1: Extended Exchange base domain
echo "1. Testing Extended Exchange domain..."
response1=$(curl -s -o /dev/null -w "%{http_code}" -m 10 "https://extended.exchange")
if [ "$response1" = "200" ]; then
  echo "✅ Extended Exchange domain: WORKING"
else
  echo "❌ Extended Exchange domain: FAILED ($response1)"
fi

# Test 2: Extended Exchange API domain
echo "2. Testing Extended Exchange API..."
response2=$(curl -s -o /dev/null -w "%{http_code}" -m 10 "https://api.extended.exchange")
if [ "$response2" = "404" ]; then
  echo "✅ Extended Exchange API: WORKING (404 expected)"
else
  echo "❌ Extended Exchange API: UNEXPECTED ($response2)"
fi

# Test 3: StarkNet RPC
echo "3. Testing StarkNet RPC..."
response3=$(curl -s -o /dev/null -w "%{http_code}" -m 10 \
  -X POST "https://starknet-sepolia.public.blastapi.io" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"starknet_chainId","params":[],"id":1}')
if [ "$response3" = "200" ]; then
  echo "✅ StarkNet RPC: WORKING"
  # Show actual chain ID
  chain_id=$(curl -s -m 10 \
    -X POST "https://starknet-sepolia.public.blastapi.io" \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"starknet_chainId","params":[],"id":1}' | \
    grep -o '"result":"[^"]*"' | cut -d'"' -f4)
  echo "   Chain ID: $chain_id"
else
  echo "❌ StarkNet RPC: FAILED ($response3)"
fi

# Test 4: Web3Auth
echo "4. Testing Web3Auth..."
response4=$(curl -s -o /dev/null -w "%{http_code}" -m 10 "https://web3auth.io")
if [ "$response4" = "200" ]; then
  echo "✅ Web3Auth: WORKING"
else
  echo "❌ Web3Auth: FAILED ($response4)"
fi

# Test 5: Proxy server
echo "5. Testing proxy server..."
proxy_pid=$(ps aux | grep 'node proxy-server.js' | grep -v grep | awk '{print $2}')
if [ ! -z "$proxy_pid" ]; then
  echo "✅ Proxy server: RUNNING (PID: $proxy_pid)"
else
  echo "❌ Proxy server: NOT RUNNING"
fi

# Test 6: ETH Token Contract on StarkNet
echo "6. Testing ETH token contract..."
eth_response=$(curl -s -m 15 \
  -X POST "https://starknet-sepolia.public.blastapi.io" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "starknet_getClassAt",
    "params": [
      "pending", 
      "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7"
    ],
    "id": 3
  }' | grep -o '"abi"' | wc -l)

if [ "$eth_response" -gt "0" ]; then
  echo "✅ ETH Token Contract: DEPLOYED"
else
  echo "❌ ETH Token Contract: NOT FOUND"
fi

echo "=================================="
echo "🎯 Pre-Demo Validation Complete!"
echo ""
echo "🎬 DEMO READINESS STATUS:"
if [ "$response1" = "200" ] && [ "$response2" = "404" ] && [ "$response3" = "200" ] && [ "$response4" = "200" ] && [ ! -z "$proxy_pid" ]; then
  echo "🟢 ALL SYSTEMS GO - READY FOR DEMO!"
else
  echo "🟡 SOME ISSUES DETECTED - CHECK ABOVE"
fi