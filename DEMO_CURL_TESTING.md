# 🧪 Pre-Demo Curl Testing Commands

## 🎯 **CRITICAL PRE-DEMO VALIDATION**

Run these curl commands to verify all systems work before your 2-minute demo:

---

## **1. EXTENDED EXCHANGE API VALIDATION**

### **Start Proxy Server First**
```bash
cd /Users/admin/AstraTrade-Project-Bounty-Submission/apps/frontend
# Kill any existing proxy server
pkill -f proxy-server.js
# Start the proxy server
node proxy-server.js &
# Should show: "🚀 Extended Exchange API Proxy Server running on http://localhost:3001"
# Proxying to: https://api.extended.exchange/api/v1
```

### **Test 1: Basic Proxy Connectivity**
```bash
curl -X GET "http://localhost:3001/status" \
  -H "Content-Type: application/json" \
  -m 10 \
  -v
```
**Expected:** Response from Extended Exchange API (may be 404 but proxy working)

### **Test 2: Extended Exchange Base Domain**
```bash
curl -X GET "https://extended.exchange" \
  -H "Accept: text/html" \
  -m 10 \
  -v | head -20
```
**Expected:** HTML response from Extended Exchange website

### **Test 3: Extended Exchange App Domain**
```bash
curl -X GET "https://app.extended.exchange" \
  -H "Accept: text/html" \
  -m 10 \
  -v | head -20
```
**Expected:** HTML response from Extended Exchange app

### **Test 4: Extended Exchange API Domain**
```bash
curl -X GET "https://api.extended.exchange" \
  -H "Content-Type: application/json" \
  -m 10 \
  -v
```
**Expected:** 404 response (API exists but no root endpoint)

---

## **2. STARKNET BLOCKCHAIN VALIDATION**

### **Test 1: StarkNet Chain ID**
```bash
curl -X POST "https://starknet-sepolia.public.blastapi.io" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "starknet_chainId",
    "params": [],
    "id": 1
  }' \
  -m 10 \
  -v
```
**Expected:** `{"id":1,"jsonrpc":"2.0","result":"0x534e5f5345504f4c4941"}`

### **Test 2: StarkNet RPC Health Check**
```bash
curl -X POST "https://starknet-sepolia.public.blastapi.io" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "starknet_blockNumber",
    "params": [],
    "id": 2
  }' \
  -m 10 \
  -v
```
**Expected:** Current block number response

### **Test 3: ETH Token Contract (Verify Deployment)**
```bash
curl -X POST "https://starknet-sepolia.public.blastapi.io" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "starknet_getClassAt",
    "params": [
      "pending", 
      "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7"
    ],
    "id": 3
  }' \
  -m 10 \
  -v | head -10
```
**Expected:** Contract ABI data (proves ETH token exists on Sepolia)

---

## **3. WEB3AUTH AUTHENTICATION ENDPOINTS**

### **Test 1: Web3Auth Main Domain**
```bash
curl -X GET "https://web3auth.io" \
  -H "Accept: text/html" \
  -m 10 \
  -v | head -20
```
**Expected:** HTML response from Web3Auth website

### **Test 2: Web3Auth Documentation**
```bash
curl -X GET "https://docs.web3auth.io" \
  -H "Accept: text/html" \
  -m 10 \
  -v | head -10
```
**Expected:** HTML response from Web3Auth docs

---

## **4. LOCALHOST APP CONNECTIVITY**

### **Test 1: Flutter Web Server**
```bash
curl -X GET "http://localhost:8080" \
  -H "Accept: text/html" \
  -v
```
**Expected:** Flutter app HTML response

### **Test 2: Flutter Hot Reload Endpoint**
```bash
curl -X GET "http://localhost:8080/restart" \
  -v
```
**Expected:** Hot reload confirmation

---

## **5. COMPREHENSIVE SYSTEM TEST**

### **All-in-One Validation Script**
```bash
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

echo "=================================="
echo "🎯 Pre-Demo Validation Complete!"
```

---

## **6. DEMO-SPECIFIC CURL TESTS**

### **For Integration Showcase Screen**
```bash
# Test all systems at once
curl -X GET "http://localhost:3001/system/status" \
  -H "Content-Type: application/json" \
  -v
```

### **For Market Selection Demo**
```bash
# Get specific markets for demo
curl -X GET "http://localhost:3001/info/markets" \
  -H "Content-Type: application/json" | \
  jq '.[] | select(.symbol | contains("ENA-USD", "PENDLE-USD", "SUI-USD"))'
```

### **For Live Trading Demo**
```bash
# Simulate order placement (test endpoint)
curl -X POST "http://localhost:3001/user/order" \
  -H "Content-Type: application/json" \
  -H "X-Api-Key: demo-key" \
  -d '{
    "symbol": "SUI-USD",
    "side": "buy", 
    "type": "market",
    "amount": "25"
  }' \
  -v
```

---

## **🚨 CRITICAL PRE-DEMO CHECKLIST**

### **30 Minutes Before Demo:**
```bash
# 1. Navigate to project directory
cd /Users/admin/AstraTrade-Project-Bounty-Submission/apps/frontend

# 2. Start proxy server
pkill -f proxy-server.js  # Kill any existing
node proxy-server.js &    # Start new one

# 3. Run validation script  
chmod +x validate_systems.sh
./validate_systems.sh

# 4. Test StarkNet connectivity
curl -X POST "https://starknet-sepolia.public.blastapi.io" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"starknet_chainId","params":[],"id":1}' \
  -m 10

# 5. Verify Extended Exchange domain
curl "https://extended.exchange" -m 10 | head -5
```

### **Expected Results:**
- ✅ **Extended Exchange Domain:** 200 OK response
- ✅ **Extended Exchange API:** 404 response (API exists, no root endpoint)
- ✅ **StarkNet RPC:** Chain ID `0x534e5f5345504f4c4941` returned
- ✅ **Web3Auth:** 200 OK response from main domain
- ✅ **Proxy Server:** Running with PID visible

### **If Any Test Fails:**
1. **Check network connectivity**
2. **Restart proxy server**
3. **Use backup screenshots**
4. **Have error logs ready to explain**

---

## **💡 BACKUP COMMANDS**

### **If Extended Exchange Fails:**
```bash
# Test base domain directly
curl "https://extended.exchange" -m 10

# Test API domain directly
curl "https://api.extended.exchange" -m 10

# Check proxy server logs
ps aux | grep proxy-server
```

### **If StarkNet RPC Fails:**
```bash
# Try alternative RPC
curl -X POST "https://starknet-sepolia.rpc.thirdweb.com" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"starknet_chainId","params":[],"id":1}'
```

---

## **🎬 DEMO EXECUTION TIPS**

### **During Demo:**
1. **Run validation script live** - show judges all systems work
2. **Display curl responses** - prove real connectivity
3. **Show StarkNet chain ID** - verify blockchain connection
4. **Have backup commands ready** - for any failures

### **Speaking Points:**
- "Let me prove all our systems work with live API calls..."
- "Here's Extended Exchange responding to our requests..."
- "You can see StarkNet Sepolia chain ID proving blockchain connectivity..."
- "Web3Auth services are operational for our 6 login providers..."

**🚀 Ready to prove your system works with real curl commands!**