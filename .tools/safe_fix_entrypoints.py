#!/usr/bin/env python3
# Safe fixer: replace ${VAR} -> ${VAR:-} only in simple presence-test lines
# Rules:
# - Only operate on lines that contain exactly one ${VAR} occurrence
# - Line must contain at least one of: '[', '[[', '-z', '-n', '==', '!='
# - Exclude lines that contain '$(' or '`' or 'printf %s' or '&& printf' or 'DepotDownloader' or 'steamcmd' (unsafe contexts)

from pathlib import Path
import re

repo_root = Path(r"x:\Github Workspace\own-pterodactyl-images")
files = list(repo_root.glob('**/entrypoint.sh'))
var_pattern = re.compile(r'\$\{([A-Za-z0-9_]+)\}')
changed = []
for p in files:
    text = p.read_text(encoding='utf-8')
    lines = text.splitlines()
    new_lines = lines.copy()
    modified = False
    for i, line in enumerate(lines):
        if any(x in line for x in ['$(', '`', 'printf %s', '&& printf', 'DepotDownloader', 'steamcmd', 'DepotDownloader', 'numactl']):
            continue
        if not any(tok in line for tok in ['[', '[[', '-z', '-n', '==', '!=' , ' -z ', ' -n ']):
            continue
        matches = var_pattern.findall(line)
        if len(matches) != 1:
            continue
        # safe to replace single occurrence
        var = matches[0]
        # replace only this specific ${VAR}
        new_line = line.replace('${' + var + '}', '${' + var + ':-}')
        if new_line != line:
            new_lines[i] = new_line
            modified = True
    if modified:
        p.write_text('\n'.join(new_lines) + '\n', encoding='utf-8')
        changed.append(str(p))

print('Changed files:')
for c in changed:
    print(c)
print('Done')
