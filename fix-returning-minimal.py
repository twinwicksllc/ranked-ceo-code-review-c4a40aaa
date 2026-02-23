#!/usr/bin/env python3
with open('lib/actions/smile-assessment.ts', 'r') as f:
    content = f.read()

# Find and replace the insert statement properly
old_code = '''          status: 'pending',
        })'''

new_code = '''          status: 'pending',
        }, { returning: 'minimal' })'''

content = content.replace(old_code, new_code)

with open('lib/actions/smile-assessment.ts', 'w') as f:
    f.write(content)

print("Fixed returning: 'minimal' syntax")