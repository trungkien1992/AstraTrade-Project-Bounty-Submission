#!/usr/bin/env python3
"""
Data ingestion pipeline for Claude Code context system.
Scans repository using gitpython and extracts logical code chunks using tree-sitter.
"""

import json
import hashlib
from pathlib import Path
from typing import Dict, List, Optional, Iterator, Set
from dataclasses import dataclass, asdict
import logging

import git
import tree_sitter_python as tspython
import tree_sitter_javascript as tsjavascript  
import tree_sitter_typescript as tstypescript
import tree_sitter_java as tsjava
import tree_sitter_cpp as tscpp
import tree_sitter_rust as tsrust
import tree_sitter_go as tsgo
from tree_sitter import Language, Parser, Node


# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@dataclass
class CodeChunk:
    """Represents a logical code chunk extracted from source files."""
    id: str
    filepath: str
    content: str
    language: str
    chunk_type: str  # function, class, method, module
    name: Optional[str]
    line_start: int
    line_end: int
    metadata: Dict[str, any]


class LanguageParser:
    """Handles parsing of different programming languages using tree-sitter."""
    
    LANGUAGE_CONFIGS = {
        'python': {
            'language': Language(tspython.language(), "python"),
            'extensions': ['.py'],
            'chunk_queries': [
                '(function_def name: (identifier) @name) @function',
                '(class_def name: (identifier) @name) @class',
                '(async_function_def name: (identifier) @name) @function',
            ]
        },
        'javascript': {
            'language': Language(tsjavascript.language(), "javascript"),
            'extensions': ['.js', '.jsx'],
            'chunk_queries': [
                '(function_declaration name: (identifier) @name) @function',
                '(method_definition name: (property_identifier) @name) @method',
                '(class_declaration name: (identifier) @name) @class',
                '(arrow_function) @function',
            ]
        },
        'typescript': {
            'language': Language(tstypescript.language(), "typescript"),
            'extensions': ['.ts', '.tsx'],
            'chunk_queries': [
                '(function_declaration name: (identifier) @name) @function',
                '(method_definition name: (property_identifier) @name) @method',
                '(class_declaration name: (type_identifier) @name) @class',
                '(interface_declaration name: (type_identifier) @name) @interface',
            ]
        },
        'java': {
            'language': Language(tsjava.language(), "java"),
            'extensions': ['.java'],
            'chunk_queries': [
                '(method_declaration name: (identifier) @name) @method',
                '(class_declaration name: (identifier) @name) @class',
                '(interface_declaration name: (identifier) @name) @interface',
            ]
        },
        'cpp': {
            'language': Language(tscpp.language(), "cpp"),
            'extensions': ['.cpp', '.cc', '.cxx', '.c', '.h', '.hpp'],
            'chunk_queries': [
                '(function_definition declarator: (function_declarator declarator: (identifier) @name)) @function',
                '(class_specifier name: (type_identifier) @name) @class',
            ]
        },
        'rust': {
            'language': Language(tsrust.language(), "rust"),
            'extensions': ['.rs'],
            'chunk_queries': [
                '(function_item name: (identifier) @name) @function',
                '(struct_item name: (type_identifier) @name) @struct',
                '(impl_item type: (type_identifier) @name) @impl',
            ]
        },
        'go': {
            'language': Language(tsgo.language(), "go"),
            'extensions': ['.go'],
            'chunk_queries': [
                '(function_declaration name: (identifier) @name) @function',
                '(method_declaration name: (field_identifier) @name) @method',
                '(type_declaration (type_spec name: (type_identifier) @name)) @type',
            ]
        }
    }
    
    def __init__(self):
        self.parsers = {}
        for lang, config in self.LANGUAGE_CONFIGS.items():
            parser = Parser()
            parser.set_language(config['language'])
            self.parsers[lang] = parser
    
    def get_language_from_path(self, filepath: Path) -> Optional[str]:
        """Determine programming language from file extension."""
        ext = filepath.suffix.lower()
        for lang, config in self.LANGUAGE_CONFIGS.items():
            if ext in config['extensions']:
                return lang
        return None
    
    def extract_chunks(self, filepath: Path, content: str) -> List[CodeChunk]:
        """Extract logical code chunks from source file."""
        language = self.get_language_from_path(filepath)
        if not language:
            return self._create_file_chunk(filepath, content)
        
        parser = self.parsers[language]
        tree = parser.parse(bytes(content, "utf8"))
        
        chunks = []
        config = self.LANGUAGE_CONFIGS[language]
        
        for query_str in config['chunk_queries']:
            query = config['language'].query(query_str)
            captures = query.captures(tree.root_node)
            
            for node, capture_name in captures:
                if capture_name in ['function', 'class', 'method', 'interface', 'struct', 'impl', 'type']:
                    chunk = self._create_chunk_from_node(
                        filepath, content, node, language, capture_name, captures
                    )
                    if chunk:
                        chunks.append(chunk)
        
        # If no chunks found, create a file-level chunk
        if not chunks:
            chunks = self._create_file_chunk(filepath, content)
        
        return chunks
    
    def _create_chunk_from_node(self, filepath: Path, content: str, node: Node, 
                               language: str, chunk_type: str, captures) -> Optional[CodeChunk]:
        """Create a CodeChunk from a tree-sitter node."""
        try:
            lines = content.split('\n')
            start_line = node.start_point[0]
            end_line = node.end_point[0]
            
            chunk_content = '\n'.join(lines[start_line:end_line + 1])
            
            # Try to extract name from captures
            name = None
            for capture_node, capture_name in captures:
                if capture_name == 'name' and capture_node.parent == node:
                    name = capture_node.text.decode('utf8')
                    break
            
            # Generate unique ID
            chunk_id = self._generate_chunk_id(filepath, chunk_type, name, start_line)
            
            # Extract metadata
            metadata = {
                'imports': self._extract_imports(content, language),
                'node_type': node.type,
                'file_size': len(content),
                'chunk_size': len(chunk_content)
            }
            
            return CodeChunk(
                id=chunk_id,
                filepath=str(filepath),
                content=chunk_content,
                language=language,
                chunk_type=chunk_type,
                name=name,
                line_start=start_line + 1,  # 1-indexed for display
                line_end=end_line + 1,
                metadata=metadata
            )
        except Exception as e:
            logger.warning(f"Failed to create chunk from node in {filepath}: {e}")
            return None
    
    def _create_file_chunk(self, filepath: Path, content: str) -> List[CodeChunk]:
        """Create a single chunk representing the entire file."""
        language = self.get_language_from_path(filepath) or 'text'
        chunk_id = self._generate_chunk_id(filepath, 'file', filepath.name, 0)
        
        metadata = {
            'imports': self._extract_imports(content, language),
            'file_size': len(content),
            'line_count': len(content.split('\n'))
        }
        
        chunk = CodeChunk(
            id=chunk_id,
            filepath=str(filepath),
            content=content,
            language=language,
            chunk_type='file',
            name=filepath.name,
            line_start=1,
            line_end=len(content.split('\n')),
            metadata=metadata
        )
        
        return [chunk]
    
    def _generate_chunk_id(self, filepath: Path, chunk_type: str, name: Optional[str], line: int) -> str:
        """Generate a unique, stable ID for a code chunk."""
        identifier = f"{filepath}:{chunk_type}:{name or 'anonymous'}:{line}"
        return hashlib.sha256(identifier.encode()).hexdigest()[:16]
    
    def _extract_imports(self, content: str, language: str) -> List[str]:
        """Extract import/include statements from code."""
        imports = []
        lines = content.split('\n')
        
        if language == 'python':
            for line in lines[:50]:  # Check first 50 lines
                line = line.strip()
                if line.startswith(('import ', 'from ')):
                    imports.append(line)
        elif language in ['javascript', 'typescript']:
            for line in lines[:50]:
                line = line.strip()
                if line.startswith(('import ', 'const ', 'require(')):
                    imports.append(line)
        elif language == 'java':
            for line in lines[:50]:
                line = line.strip()
                if line.startswith('import '):
                    imports.append(line)
        
        return imports


class RepositoryScanner:
    """Scans Git repository and extracts code chunks."""
    
    def __init__(self, repo_path: Path, ignore_patterns: Optional[Set[str]] = None):
        self.repo_path = Path(repo_path)
        self.ignore_patterns = ignore_patterns or {
            'node_modules', 'build', 'dist', '.git', '__pycache__',
            '*.pyc', '*.log', 'target', 'vendor'
        }
        self.parser = LanguageParser()
        
        try:
            self.repo = git.Repo(self.repo_path)
            logger.info(f"Initialized Git repository scanner at {repo_path}")
        except git.InvalidGitRepositoryError:
            logger.warning(f"Not a Git repository: {repo_path}. Scanning all files.")
            self.repo = None
    
    def scan_repository(self) -> Iterator[CodeChunk]:
        """Scan repository and yield code chunks."""
        if self.repo:
            # Use Git to get tracked files, respecting .gitignore
            for item in self.repo.index.entries:
                filepath = Path(self.repo_path) / item[0]
                if self._should_process_file(filepath):
                    yield from self._process_file(filepath)
        else:
            # Fallback: scan all files
            for filepath in self.repo_path.rglob('*'):
                if filepath.is_file() and self._should_process_file(filepath):
                    yield from self._process_file(filepath)
    
    def _should_process_file(self, filepath: Path) -> bool:
        """Check if file should be processed based on ignore patterns."""
        try:
            # Check file size (skip very large files)
            if filepath.stat().st_size > 1024 * 1024:  # 1MB limit
                return False
            
            # Check against ignore patterns
            path_parts = set(filepath.parts)
            if any(pattern in path_parts for pattern in self.ignore_patterns):
                return False
            
            # Check if it's a supported file type
            return self.parser.get_language_from_path(filepath) is not None
            
        except (OSError, PermissionError):
            return False
    
    def _process_file(self, filepath: Path) -> Iterator[CodeChunk]:
        """Process a single file and extract chunks."""
        try:
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            chunks = self.parser.extract_chunks(filepath, content)
            for chunk in chunks:
                yield chunk
                
            logger.debug(f"Processed {filepath}: {len(chunks)} chunks")
            
        except Exception as e:
            logger.error(f"Failed to process {filepath}: {e}")


def main():
    """Main ingestion script."""
    import argparse
    
    parser = argparse.ArgumentParser(description="Ingest repository for Claude context system")
    parser.add_argument("--repo-path", default="../", help="Path to repository")
    parser.add_argument("--output", default="chunks.jsonl", help="Output JSONL file")
    parser.add_argument("--ignore", nargs="*", help="Additional ignore patterns")
    
    args = parser.parse_args()
    
    ignore_patterns = {
        'node_modules', 'build', 'dist', '.git', '__pycache__',
        '*.pyc', '*.log', 'target', 'vendor'
    }
    if args.ignore:
        ignore_patterns.update(args.ignore)
    
    scanner = RepositoryScanner(args.repo_path, ignore_patterns)
    
    chunk_count = 0
    with open(args.output, 'w') as f:
        for chunk in scanner.scan_repository():
            f.write(json.dumps(asdict(chunk)) + '\n')
            chunk_count += 1
            
            if chunk_count % 100 == 0:
                logger.info(f"Processed {chunk_count} chunks")
    
    logger.info(f"Ingestion complete. Generated {chunk_count} chunks in {args.output}")


if __name__ == "__main__":
    main()