#!/usr/bin/env python3
import re
import sys
from pathlib import Path

repo_root = Path(r"x:\Github Workspace\own-pterodactyl-images")
pattern = re.compile(r'(\[\s*[-nzh]{1,2}\s*)(\"?\$\{([A-Za-z0-9_]+)\}\}"?)')
# We'll also catch ${VAR} inside double-quoted context within [[ ... ]]
# Approach: replace occurrences of ${VAR} inside tests with ${VAR:-}

files = list(repo_root.glob('**/entrypoint.sh'))
modified = []
for p in files:
    text = p.read_text(encoding='utf-8')
    new = text
    # Replace patterns like "${VAR}" or ${VAR} inside [ ] or [[ ]]
    # Simpler approach: look for ${VAR} occurrences and if they appear inside a test-like line
    for m in re.finditer(r'\$\{([A-Za-z0-9_]+)\}', text):
        var = m.group(1)
        # find line
        line_start = text.rfind('\n', 0, m.start())+1
        line_end = text.find('\n', m.end())
        if line_end == -1:
            line_end = len(text)
        line = text[line_start:line_end]
        # heuristics: only modify if line contains [ or [[ or == or -z or -n or printf %s used in inline conditionals
        if any(tok in line for tok in ['[', '[[', '-z', '-n', '==', '!=', 'printf %s', '$( [', '$( [[']):
            # replace only this specific ${VAR} occurrence with ${VAR:-}
            before = new[:m.start()]
            after = new[m.end():]
            new = before + '${' + var + ':-}' + after
            # adjust subsequent matches by restarting search on new text
            text = new
    if new != p.read_text(encoding='utf-8'):
        p.write_text(new, encoding='utf-8')
        modified.append(str(p))

print('Modified files:')
for m in modified:
    print(m)
print('Done')
