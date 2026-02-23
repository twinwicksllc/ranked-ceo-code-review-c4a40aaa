#!/usr/bin/env python3
with open('lib/actions/smile-assessment.ts', 'r') as f:
    content = f.read()

# Find and replace the problematic insert block
old_insert = '''      const { error: insertError } = await supabase
        .from('smile_assessments')
        .insert({
          account_id: accountId,
          auth_user_id: targetUserId,
          patient_name: data.patient_name,
          patient_email: data.patient_email,
          patient_phone: data.patient_phone,
          patient_dob: data.patient_dob || null,
          dentist_name: data.dentist_name || null,
          last_dental_visit: data.last_dental_visit || null,
          dental_insurance: data.dental_insurance,
          insurance_provider: data.insurance_provider || null,
          current_concerns: data.current_concerns || null,
          pain_sensitivity: data.pain_sensitivity || null,
          smile_goals: data.smile_goals || [],
          desired_outcome: data.desired_outcome || null,
          medical_conditions: data.medical_conditions || [],
          medications: data.medications || null,
          allergies: data.allergies || null,
          status: 'pending',
        },
      '''

new_insert = '''      const { error: insertError } = await supabase
        .from('smile_assessments')
        .insert({
          account_id: accountId,
          auth_user_id: targetUserId,
          patient_name: data.patient_name,
          patient_email: data.patient_email,
          patient_phone: data.patient_phone,
          patient_dob: data.patient_dob || null,
          dentist_name: data.dentist_name || null,
          last_dental_visit: data.last_dental_visit || null,
          dental_insurance: data.dental_insurance,
          insurance_provider: data.insurance_provider || null,
          current_concerns: data.current_concerns || null,
          pain_sensitivity: data.pain_sensitivity || null,
          smile_goals: data.smile_goals || [],
          desired_outcome: data.desired_outcome || null,
          medical_conditions: data.medical_conditions || [],
          medications: data.medications || null,
          allergies: data.allergies || null,
          status: 'pending',
        }, { returning: 'minimal' })'''

content = content.replace(old_insert, new_insert)

with open('lib/actions/smile-assessment.ts', 'w') as f:
    f.write(content)

print("Rewrote insert statement with correct syntax")