#!/usr/bin/env python3
with open('lib/actions/smile-assessment.ts', 'r') as f:
    lines = f.readlines()

# Line 136 (index 135) is the line we need to fix
if lines[135].strip() == "})":
    lines[135] = lines[135].replace("})", "}, { returning: 'minimal' })")
    print(f"Fixed line 136: {lines[135].strip()}")
else:
    print(f"Line 136 content: {lines[135].strip()}")

with open('lib/actions/smile-assessment.ts', 'w') as f:
    f.writelines(lines)