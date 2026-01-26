-- Add last_accessed_at field to projects table
ALTER TABLE public.projects 
ADD COLUMN last_accessed_at TIMESTAMP WITH TIME ZONE DEFAULT now();

-- Create an index for better performance on recent projects queries
CREATE INDEX idx_projects_last_accessed_at ON public.projects(last_accessed_at DESC);

-- Update existing projects to have a last_accessed_at value
UPDATE public.projects 
SET last_accessed_at = COALESCE(updated_at, created_at) 
WHERE last_accessed_at IS NULL;