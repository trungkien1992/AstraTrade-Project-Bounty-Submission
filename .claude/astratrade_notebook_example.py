#!/usr/bin/env python3
"""Example of using notebook for AstraTrade project tracking"""

import sys
from pathlib import Path

# Add notebook to path
sys.path.insert(0, str(Path(__file__).parent / "commands" / "Notebook"))

from implementation import (
    create_file_storage,
    set_storage_adapter,
    set_persistence_enabled,
    ensure_session,
    add_notebook_entry,
    list_notebook_entries,
    manage_user_notebook
)

# Initialize storage
storage_path = Path(".claude/sessions/notebook-storage.json")
file_storage = create_file_storage(str(storage_path))
set_storage_adapter(file_storage)
set_persistence_enabled(True)

# Create AstraTrade project session
session_id = "astratrade-project-session"
ensure_session(session_id)

print("🚀 AstraTrade Project Notebook")
print("=" * 50)

# Add project-specific entries
entries = [
    ("project", "AstraTrade Flutter Trading App"),
    ("blockchain", "Starknet Sepolia testnet integration"),
    ("current-issue", "Extended Exchange API DNS resolution failing"),
    ("wallet-address", "0x04d542c2db3dec288c7bc7c6a9844e7ec00b3c36b085f51297be1bb71b09e0b0"),
    ("api-status", "Production API client partially working"),
    ("frontend-path", "apps/frontend/"),
    ("main-service", "lib/services/extended_service.dart"),
    ("test-commands", "dart execute_final_v3_transaction.dart"),
]

print("\n📝 Adding project tracking entries:")
for key, value in entries:
    result = add_notebook_entry(session_id, key, value)
    print(f"  ✓ {key}")

print("\n📋 Current notebook status:")
print(list_notebook_entries(session_id))

# Demonstrate command usage
print("\n💡 Example notebook commands for your workflow:")
print("  /notebook add:bug-fix Fixed balance parsing in extended_exchange_client")
print("  /notebook add:todo Implement proper error handling for DNS failures")
print("  /notebook get:wallet-address")
print("  /notebook show:")

print("\n✅ Notebook is ready for tracking your AstraTrade development!")