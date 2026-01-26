-- Add signature fields to profiles table
ALTER TABLE public.profiles 
ADD COLUMN default_signature_data TEXT,
ADD COLUMN signature_setup_completed BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN signature_updated_at TIMESTAMP WITH TIME ZONE;

-- Create user_signatures table for multiple signature support
CREATE TABLE public.user_signatures (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  signature_name VARCHAR(255) NOT NULL,
  signature_data TEXT NOT NULL,
  is_default BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS on user_signatures table
ALTER TABLE public.user_signatures ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for user_signatures
CREATE POLICY "Users can view their own signatures"
ON public.user_signatures 
FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own signatures"
ON public.user_signatures 
FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own signatures"
ON public.user_signatures 
FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own signatures"
ON public.user_signatures 
FOR DELETE 
USING (auth.uid() = user_id);

-- Add trigger for automatic updated_at timestamp
CREATE TRIGGER update_user_signatures_updated_at
BEFORE UPDATE ON public.user_signatures
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Add index for better query performance
CREATE INDEX idx_user_signatures_user_id ON public.user_signatures(user_id);
CREATE INDEX idx_user_signatures_default ON public.user_signatures(user_id, is_default) WHERE is_default = true;