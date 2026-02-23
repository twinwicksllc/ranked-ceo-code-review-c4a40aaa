#!/usr/bin/env python3
with open('lib/actions/smile-assessment.ts', 'r') as f:
    lines = f.readlines()

new_lines = []
for i, line in enumerate(lines):
    # Replace .select('id').single() with , { returning: 'minimal' })
    if ".select('id')" in line and ".single()" in lines[i+1]:
        new_lines.append(line.replace(".select('id')", ", { returning: 'minimal' })"))
        # Skip the next line (.single())
        continue
    elif ".select('id').single()" in line:
        new_lines.append(line.replace(".select('id').single()", ", { returning: 'minimal' })"))
    else:
        new_lines.append(line)

with open('lib/actions/smile-assessment.ts', 'w') as f:
    f.writelines(new_lines)

print("Fixed HIPAA compliant return type")