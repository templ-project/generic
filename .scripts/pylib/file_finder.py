import glob
import os
from typing import List, Optional, Set

DEFAULT_IGNORES = [
    "__pycache__",
    ".git",
    ".husky",
    ".venv",
    "build",
    "dist",
    "node_modules",
    "target",
    "vendor",
    "venv"
]

def is_ignored(path: str, ignore_patterns: Set[str]) -> bool:
    parts = path.split(os.sep)
    for part in parts:
        if part in ignore_patterns:
            return True
    return False

def find_files(patterns: List[str], ignore_patterns: Optional[List[str]] = None) -> List[str]:
    if ignore_patterns is None:
        ignore_patterns = []

    all_ignores = set(DEFAULT_IGNORES + ignore_patterns)
    found_files = set()

    if not patterns:
        return []

    for pattern in patterns:
        # If the pattern is a direct file path that exists, add it (unless ignored)
        if os.path.isfile(pattern):
            if not is_ignored(pattern, all_ignores):
                found_files.add(os.path.normpath(pattern))
            continue

        # Otherwise treat as glob
        # recursive=True allows ** to match subdirectories
        matches = glob.glob(pattern, recursive=True)

        for match in matches:
            if os.path.isfile(match) and not is_ignored(match, all_ignores):
                found_files.add(os.path.normpath(match))

    return sorted(found_files)
