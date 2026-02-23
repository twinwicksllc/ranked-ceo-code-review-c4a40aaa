-- Check what columns actually exist in smile_assessments table
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'smile_assessments'
ORDER BY ordinal_position;
