# Claude Code Notebook Integration Guide

## Overview
The Notebook system is now integrated into your Claude Code workflow. It provides persistent memory and note-taking capabilities across sessions.

## Available Commands

### 1. Show all notebook entries
```
/notebook show:
```
Lists all entries with usage statistics (entries count, storage used)

### 2. Add a new entry
```
/notebook add:[key] [value]
```
Example: `/notebook add:project-status Working on AstraTrade integration`

### 3. Get a specific entry
```
/notebook get:[key]
```
Example: `/notebook get:project-status`

### 4. Delete an entry
```
/notebook delete:[key]
```
Example: `/notebook delete:old-notes`

## Key Features

1. **Persistent Storage**: All entries are saved to `.claude/sessions/notebook-storage.json`
2. **Session Integration**: Notebook entries are included in Claude's context
3. **Rate Limiting**: 300ms cooldown between additions to prevent spam
4. **Storage Limits**: 
   - Max 30 entries per notebook
   - Max 30,000 characters total storage
   - Max 2,048 characters per entry

## Usage in Your Workflow

### Starting a new project session
```python
# The notebook can help track:
/notebook add:project-name AstraTrade Flutter App
/notebook add:current-task Integrating blockchain features
/notebook add:blockers DNS resolution for extended.exchange API
```

### During development
```python
# Track important findings
/notebook add:api-endpoint https://api.example.com/v1/trades
/notebook add:test-account 0x1234...5678
/notebook add:bug-found Balance parsing issue with hex values
```

### Reviewing progress
```python
# Check all your notes
/notebook show:

# Get specific information
/notebook get:api-endpoint
```

## Integration with Claude Code Sessions

The notebook system automatically:
- Creates session start/end entries
- Logs major workflow stages
- Includes notebook contents in AI context
- Maintains backward compatibility with existing Claude Code features

## File Structure
```
.claude/
├── sessions/
│   └── notebook-storage.json    # Persistent storage
├── commands/
│   └── Notebook/               # Notebook implementation
└── test_notebook.py           # Test script
```

## Best Practices

1. Use descriptive keys: `api-key-location` instead of `key1`
2. Keep values concise and actionable
3. Delete outdated entries to stay within limits
4. Use for capturing insights, decisions, and key findings
5. Remember entries enhance Claude's understanding of your project

## Testing the Integration

Run the test script to verify everything is working:
```bash
python3 .claude/test_notebook.py
```

The notebook is now ready to use in your Claude Code sessions!