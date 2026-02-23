#!/usr/bin/env python3
import re

with open('lib/actions/smile-assessment.ts', 'r') as f:
    content = f.read()

# Replace the insert statement with HIPAA compliant version
old_pattern = r'\.select\(\'id\'\)\.single\(\)'
new_code = ', { returning: \'minimal\' })'

content = re.sub(old_pattern, new_code, content)

# Also remove the 'assessment' from destructuring since we're not returning data
content = content.replace('const { data: assessment, error: insertError }', 'const { error: insertError }')

with open('lib/actions/smile-assessment.ts', 'w') as f:
    f.write(content)

print("Updated smile-assessment.ts for HIPAA compliance")