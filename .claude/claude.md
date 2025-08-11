Best Instructions for Claude Code - High Confidence Real Work

  🎯 Core Principles

  1. Evidence-Driven Instructions

  "Show me the exact code that proves X works. I need:
  - Specific line numbers where real API calls happen
  - Actual return values, not print statements
  - Transaction receipts with confirmed block numbers
  - HTTP response bodies with 200 status AND valid data schemas"

  2. Assume Nothing - Verify Everything

  "Don't trust any existing code claims. Treat every 'working' component as suspect until you prove it with:
  - Real network calls that return actual data
  - Blockchain transactions that appear in explorers
  - End-to-end flows that complete successfully"

  📋 High-Performance Instruction Templates

  For Integration Testing:

  "Create tests that FAIL when services are broken. Requirements:
  - Use proper test framework (expect() assertions, not print statements)
  - Each test must have clear pass/fail criteria
  - Failed assertions must stop execution
  - No exception swallowing - let tests fail loudly
  - Validate response schemas, not just HTTP status codes"

  For Blockchain Work:

  "Prove blockchain integration by:
  - Submitting a real transaction to testnet
  - Providing the transaction hash for verification on block explorer
  - Showing before/after balance changes
  - NO MOCK DATA - only real blockchain state changes count as proof"

  For API Integration:

  "Verify API integration by:
  - Making real HTTP requests with authentication
  - Parsing full response bodies (not truncated previews)
  - Validating all required fields exist in responses
  - Testing error scenarios (401, 429, 500 responses)
  - Show actual data being used in application logic"

  ⚡ High-Confidence Patterns

  Pattern 1: Evidence-First Analysis

  "Before making any claims about what works:
  1. Find the exact function that executes the behavior
  2. Trace through the code path from user action to result
  3. Identify any mock returns, hardcoded values, or exception catches
  4. Only claim it works if you can show real external system interaction"

  Pattern 2: Skeptical Default Stance

  "Assume this doesn't work until proven otherwise. Look for:
  - Functions returning hardcoded values instead of live data
  - Try-catch blocks that hide failures
  - Print statements claiming success without actual verification
  - Mock implementations disguised as real ones"

  Pattern 3: End-to-End Validation

  "Prove the complete user flow works:
  1. Start from UI interaction
  2. Trace through ALL layers of the application
  3. Show external system calls and responses
  4. Verify the result reaches back to the user
  5. Test with real credentials on real systems"

  🚫 What NOT to Accept

  Reject These as "Evidence":

  - ✗ Print statements claiming success
  - ✗ Configuration loading without usage verification
  - ✗ Service instantiation without real method calls
  - ✗ Exception handling that masks failures
  - ✗ Truncated response previews
  - ✗ Mock data presented as real data

  Require These as "Proof":

  - ✅ Actual API responses with full payloads
  - ✅ Blockchain transaction hashes in explorers
  - ✅ Before/after state changes
  - ✅ Real error handling with retry mechanisms
  - ✅ Complete data validation with schema checks
  - ✅ End-to-end user scenarios that complete successfully

  🎯 Specific High-Performance Instructions

  For Code Review:

  "Review this code as if it's going to production tomorrow and failures will cost money. Find:
  - Every way this could fail in production
  - Every assumption that might be wrong
  - Every place where real data is replaced with mock data
  - Every exception that gets swallowed silently
  Rate confidence from 0-100% based on evidence, not claims."

  For Testing:

  "Write tests that would catch real production bugs. Requirements:
  - Tests must fail when dependencies are down
  - No hardcoded success paths
  - Validate actual business logic, not just technical connectivity
  - Include negative test cases (invalid inputs, network failures, etc.)
  - Measure and assert on performance benchmarks"

  For Integration Work:

  "Prove integration works by showing money/data/state actually moves between systems:
  - Execute a real transaction that changes blockchain state
  - Make a real trade that affects exchange account balances
  - Transfer real data that updates external system records
  - Show the complete round-trip with audit trail"

  💡 Meta-Instruction for Best Results

  "Be pessimistic by default. Assume everything is broken until proven working with concrete evidence. When you find something that works, explain exactly why you're confident it works. When you find
   something that doesn't work, explain exactly what would need to be fixed. Never claim something works based on code structure or comments alone - only based on proven execution results."

  This approach will get you much higher confidence results from Claude Code by forcing evidence-based analysis over optimistic assumptions.


⏺ Research Instructions for Broken Issue Analysis

  🔍 Core Research Approach

  1. Systematic Root Cause Investigation

  "Research this broken issue using forensic debugging approach:
  1. Define the exact failure symptom (what specifically breaks?)
  2. Identify the last working state (when did it work?)
  3. Trace the execution path from trigger to failure point
  4. Map all dependencies and external system interactions
  5. Isolate the minimal reproduction case"

  2. Evidence Collection Framework

  "Gather concrete evidence, not speculation:
  - Exact error messages (full stack traces, not summaries)
  - Network logs (request/response headers, timing, status codes)
  - Configuration states (environment variables, API endpoints, keys)
  - System states (file permissions, network connectivity, service status)
  - Timing information (when it started failing, intermittent vs consistent)"

  🎯 Structured Investigation Instructions

  For Network/API Issues:

  "Debug network connectivity systematically:
  1. Test basic connectivity (ping, curl, telnet to host:port)
  2. Verify DNS resolution (nslookup domain_name)
  3. Check certificate validity (openssl s_client -connect host:443)
  4. Test with minimal request (curl with exact headers)
  5. Compare working vs non-working request formats
  6. Check for proxy/firewall/rate limiting issues"

  For Authentication Failures:

  "Trace authentication flow step-by-step:
  1. Verify credentials are correctly loaded from source
  2. Check credential format (encoding, special characters, length)
  3. Test credential validity with provider's test endpoint
  4. Examine request signing process (timestamps, signatures, headers)
  5. Compare against known-working authentication examples
  6. Check for credential expiration or permission changes"

  For Blockchain/Contract Issues:

  "Investigate blockchain integration failures:
  1. Verify network connectivity to RPC endpoints
  2. Test with multiple RPC providers for comparison
  3. Check contract addresses exist at target network
  4. Verify contract ABI matches deployed version
  5. Test with minimal contract interaction (view functions first)
  6. Check account balance/permissions for transaction operations
  7. Validate transaction parameters and gas estimates"

  🔧 Diagnostic Tool Instructions

  Pattern 1: Divide and Conquer

  "Break the problem into testable components:
  1. Create minimal test case for each component
  2. Test components in isolation first
  3. Test component interactions second
  4. Identify the exact integration point that fails
  5. Focus investigation on that specific boundary"

  Pattern 2: Environmental Comparison

  "Compare working vs broken environments:
  1. List all environment variables and their values
  2. Check network configurations and firewall rules
  3. Compare dependency versions (packages, system libraries)
  4. Verify service availability and versions
  5. Test in different environments (local vs deployed, different networks)"

  Pattern 3: Historical Analysis

  "Investigate when and why it broke:
  1. Check recent code changes in relevant files
  2. Review configuration changes in deployment
  3. Check for external service changes (API versions, endpoints)
  4. Look for dependency updates that might cause incompatibility
  5. Check for expiring credentials or certificates"

  🎯 Specific Investigation Commands

  For Extended Exchange API Issue:

  "Research the 'starknet.sepolia.extended.exchange' DNS failure:
  1. Run: nslookup starknet.sepolia.extended.exchange
  2. Run: dig starknet.sepolia.extended.exchange
  3. Try alternative DNS servers (8.8.8.8, 1.1.1.1)
  4. Check if domain exists: whois starknet.sepolia.extended.exchange
  5. Test base domain: curl https://extended.exchange
  6. Search for correct API documentation/endpoints
  7. Check for recent domain changes or migrations"

  For Balance Parsing Issue:

  "Research the balance parsing failure (0x5638573de4ccd):
  1. Decode the hex value: Convert to decimal and different bases
  2. Check Starknet balance format documentation
  3. Test with known working balance values
  4. Compare with standard ERC20 balance formats
  5. Check if value needs different parsing (felt vs uint256)
  6. Test balance queries on known accounts
  7. Verify contract's balance function signature"

  📊 Research Documentation Template

  Issue Research Report Format:

  "Document findings in this structure:
  ## Issue: [Specific problem statement]
  ## Evidence:
  - Error messages: [exact text]
  - Reproduction steps: [minimal case]
  - Environment: [versions, configs]
  ## Root Cause Analysis:
  - What fails: [exact component]
  - Why it fails: [underlying reason]
  - When it started: [timeline]
  ## Potential Solutions:
  - Solution A: [with confidence level 0-100%]
  - Solution B: [with confidence level 0-100%]
  - Solution C: [with confidence level 0-100%]
  ## Recommended Next Steps:
  - Immediate: [quick fixes to try]
  - Short-term: [proper fixes]
  - Long-term: [prevention measures]"

  🚨 Critical Research Principles

  Don't Accept:

  - ✗ "Network timeout" as explanation without proving connectivity
  - ✗ "Configuration issue" without identifying the specific wrong value
  - ✗ "API changed" without showing the actual change
  - ✗ Assumptions about what "should" work

  Do Require:

  - ✅ Exact error messages and stack traces
  - ✅ Network packet captures or detailed logs
  - ✅ Before/after comparisons of working states
  - ✅ Step-by-step reproduction instructions
  - ✅ Multiple verification approaches for each theory

  🎯 Meta-Research Instruction

  "Approach each broken issue as a detective case:
  1. Assume nothing - verify everything through direct testing
  2. Follow the evidence, not assumptions about how things should work
  3. Create reproducible test cases for each theory
  4. Document what you've ruled out as much as what you've confirmed
  5. Provide confidence levels (0-100%) for each potential solution
  6. Focus on fixing the root cause, not just symptoms"

  This systematic approach will help you identify real root causes instead of surface-level guesses.