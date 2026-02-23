#!/usr/bin/env python3
with open('lib/actions/smile-assessment.ts', 'r') as f:
    lines = f.readlines()

# Find the line with status: 'pending' and fix the next line
for i, line in enumerate(lines):
    if "status: 'pending'," in line and i < len(lines) - 1:
        # Check if next line is just closing brace
        if lines[i+1].strip() == "})":
            lines[i+1] = lines[i+1].replace("})", "}, { returning: 'minimal' })")
            print(f"Fixed line {i+2}")
            break

with open('lib/actions/smile-assessment.ts', 'w') as f:
    f.writelines(lines)

print("Done!")