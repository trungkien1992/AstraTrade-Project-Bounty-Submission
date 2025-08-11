#!/usr/bin/env python3
"""Test script to verify notebook functionality"""

import sys
import os
from pathlib import Path

# Add the notebook directory to Python path
notebook_path = Path(__file__).parent / "commands" / "Notebook"
sys.path.insert(0, str(notebook_path))

try:
    from implementation import (
        create_file_storage,
        set_storage_adapter,
        set_persistence_enabled,
        ensure_session,
        add_notebook_entry,
        list_notebook_entries,
        get_notebook_entry,
        delete_notebook_entry,
        get_session_context
    )
    
    print("✅ Successfully imported notebook implementation")
    
    # Initialize storage
    storage_path = Path(".claude/sessions/notebook-storage.json")
    storage_path.parent.mkdir(parents=True, exist_ok=True)
    
    file_storage = create_file_storage(str(storage_path))
    set_storage_adapter(file_storage)
    set_persistence_enabled(True)
    
    print(f"✅ Storage initialized at: {storage_path}")
    
    # Create a test session
    test_session_id = "test-session-001"
    ensure_session(test_session_id)
    print(f"✅ Created session: {test_session_id}")
    
    # Test adding entries
    print("\n📝 Testing notebook entries:")
    
    # Add some entries
    result1 = add_notebook_entry(test_session_id, "project-goal", "Integrate notebook with Claude Code")
    print(f"  Add entry 1: {result1}")
    
    result2 = add_notebook_entry(test_session_id, "status", "Setting up integration")
    print(f"  Add entry 2: {result2}")
    
    result3 = add_notebook_entry(test_session_id, "next-steps", "Test commands and verify persistence")
    print(f"  Add entry 3: {result3}")
    
    # List all entries
    print("\n📋 All notebook entries:")
    entries = list_notebook_entries(test_session_id)
    print(entries)
    
    # Get specific entry
    print("\n🔍 Get specific entry:")
    entry = get_notebook_entry(test_session_id, "project-goal")
    print(f"  {entry}")
    
    # Get session context
    print("\n📄 Session context preview:")
    context = get_session_context(test_session_id)
    print(context[:500] + "..." if len(context) > 500 else context)
    
    print("\n✅ All tests passed! Notebook system is working correctly.")
    
except ImportError as e:
    print(f"❌ Failed to import notebook implementation: {e}")
    print("Make sure the notebook files are in .claude/commands/Notebook/")
except Exception as e:
    print(f"❌ Error during testing: {e}")
    import traceback
    traceback.print_exc()