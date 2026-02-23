#!/usr/bin/env python3
import re

with open('lib/actions/smile-assessment.ts', 'r') as f:
    content = f.read()

# Pattern to match the entire insert statement
pattern = r"""(\.from\('smile_assessments'\)\s*\n\s*\.insert\(\{[^}]+\})\)"""

replacement = r"""\1, { returning: 'minimal' })"""

content = re.sub(pattern, replacement, content, flags=re.MULTILINE | re.DOTALL)

with open('lib/actions/smile-assessment.ts', 'w') as f:
    f.write(content)

print("Fixed insert statement with returning: 'minimal'")