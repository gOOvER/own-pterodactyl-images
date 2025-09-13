#!/usr/bin/env python3
"""
Robust Colors/Functions block replacer for entrypoint.sh files.

Features:
- Detects multiple start patterns (comment markers, direct tput lines, or msg() start).
- Finds the `line()` function and uses brace-matching to determine the end of the block.
- Creates a `.bak` backup before writing changes.
- Prints a summary of modified files.

Usage: run from repository root with the project's Python.
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]

CANONICAL_BLOCK = (
    "# ----------------------------\n"
    "# Colors via tput\n"
    "RED=$(tput setaf 1)\n"
    "GREEN=$(tput setaf 2)\n"
    "YELLOW=$(tput setaf 3)\n"
    "BLUE=$(tput setaf 4)\n"
    "CYAN=$(tput setaf 6)\n"
    "NC=$(tput sgr0)\n\n"
    "# ----------------------------\n"
    "# Functions\n"
    "# ----------------------------\n"
    "msg() {\n"
    "    local color=\"$1\"\n"
    "    shift\n"
    "    # If RED, also write the message to install_error.log\n"
    "    if [ \"$color\" = \"RED\" ]; then\n"
    "        printf \"%b\\n\" \"${RED}$*${NC}\" | tee -a \"$ERROR_LOG\" >&2\n"
    "    else\n"
    "        printf \"%b\\n\" \"${!color}$*${NC}\"\n"
    "    fi\n"
    "}\n\n"
    "line() {\n"
    "    local color=\"${1:-BLUE}\"\n"
    "    local term_width\n"
    "    term_width=$(tput cols 2>/dev/null || echo 70)\n"
    "    local sep\n"
    "    sep=$(printf '%*s' \"$term_width\" '' | tr ' ' '-')\n\n"
    "    case \"$color\" in\n"
    "        RED) COLOR=\"$RED\";;\n"
    "        GREEN) COLOR=\"$GREEN\";;\n"
    "        YELLOW) COLOR=\"$YELLOW\";;\n"
    "        BLUE) COLOR=\"$BLUE\";;\n"
    "        CYAN) COLOR=\"$CYAN\";;\n"
    "        *) COLOR=\"$NC\";;\n"
    "    esac\n"
    "    printf \"%b\\n\" \"${COLOR}${sep}${NC}\"\n"
    "}\n"
)


def find_entrypoints(root: pathlib.Path):
    return list(root.glob('**/entrypoint.sh'))


def find_start_index(text: str):
    """Return earliest index of a plausible start marker, or -1."""
    candidates = [
        r"#\s*-+\s*\n#\s*Colors via tput",
        r"#\s*Colors via tput",
        r"RED=\$\(tput setaf",
        r"msg\s*\(\)\s*\{",
    ]
    indices = []
    for pat in candidates:
        m = re.search(pat, text)
        if m:
            indices.append(m.start())
    return min(indices) if indices else -1


def find_line_function_start(text: str, after: int):
    # Match 'line() {' with or without a preceding newline/whitespace
    m = re.search(r"line\s*\(\)\s*\{", text[after:])
    return (after + m.start()) if m else -1


def find_matching_brace(text: str, open_brace_idx: int):
    """Given index of '{', find the index after the matching '}' (returns index of the character after '}') or -1."""
    i = open_brace_idx
    n = len(text)
    depth = 0
    while i < n:
        c = text[i]
        if c == '{':
            depth += 1
        elif c == '}':
            depth -= 1
            if depth == 0:
                return i + 1
        i += 1
    return -1


def replace_block(path: pathlib.Path):
    text = path.read_text(encoding='utf-8')
    start_idx = find_start_index(text)
    if start_idx == -1:
        return False

    line_start = find_line_function_start(text, start_idx)
    if line_start == -1:
        # no line() function found after start; give up
        return False

    # find the position of the opening brace for line() function
    open_brace_pos = text.find('{', line_start)
    if open_brace_pos == -1:
        return False

    end_idx = find_matching_brace(text, open_brace_pos)
    if end_idx == -1:
        return False

    # include following newline if present
    if end_idx < len(text) and text[end_idx] == '\n':
        end_idx += 1

    new_text = text[:start_idx] + CANONICAL_BLOCK + text[end_idx:]

    backup = path.with_suffix(path.suffix + '.bak')
    # do not overwrite an existing backup
    if not backup.exists():
        path.rename(backup)
    else:
        # create numbered backup
        i = 1
        while True:
            alt = path.with_suffix(path.suffix + f'.bak{i}')
            if not alt.exists():
                backup = alt
                path.rename(backup)
                break
            i += 1

    path.write_text(new_text, encoding='utf-8')
    print(f"Replaced block in {path} (backup: {backup})")
    return True


def main():
    files = find_entrypoints(ROOT)
    changed = 0
    for p in files:
        try:
            if replace_block(p):
                changed += 1
        except Exception as e:
            print(f"Failed to process {p}: {e}")
    print(f"Done. Modified {changed} files out of {len(files)} entrypoint.sh files.")


if __name__ == '__main__':
    main()
