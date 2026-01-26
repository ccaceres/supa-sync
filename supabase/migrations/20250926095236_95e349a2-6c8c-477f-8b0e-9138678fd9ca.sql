-- Add document and signature requirements to pipeline stages
ALTER TABLE public.pipeline_stages 
ADD COLUMN requires_electronic_signature boolean DEFAULT false,
ADD COLUMN requires_meeting_transcript boolean DEFAULT false,
ADD COLUMN requires_final_presentation boolean DEFAULT false;

-- Create model documents table for collaborative document management
CREATE TABLE public.model_documents (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  model_id uuid NOT NULL,
  stage_id uuid REFERENCES public.pipeline_stages(id),
  document_type varchar NOT NULL DEFAULT 'other',
  file_name varchar NOT NULL,
  file_path varchar NOT NULL,
  file_size bigint,
  content_type varchar,
  is_public boolean DEFAULT true,
  uploaded_by uuid NOT NULL,
  uploaded_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Create approval signatures table for electronic signature tracking
CREATE TABLE public.approval_signatures (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  approval_action_id uuid NOT NULL REFERENCES public.approval_actions(id),
  user_id uuid NOT NULL,
  signature_method varchar NOT NULL DEFAULT 'electronic',
  signed_at timestamp with time zone DEFAULT now(),
  signature_data jsonb DEFAULT '{}',
  ip_address inet,
  user_agent text,
  created_at timestamp with time zone DEFAULT now()
);

-- Enable RLS on new tables
ALTER TABLE public.model_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.approval_signatures ENABLE ROW LEVEL SECURITY;

-- RLS policies for model_documents
CREATE POLICY "Users can view documents for accessible models"
ON public.model_documents FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM models m
    WHERE m.id = model_documents.model_id
    AND can_access_project(auth.uid(), m.project_id)
  )
);

CREATE POLICY "Users can upload documents for editable models"
ON public.model_documents FOR INSERT
WITH CHECK (
  auth.uid() = uploaded_by AND
  EXISTS (
    SELECT 1 FROM models m
    WHERE m.id = model_documents.model_id
    AND can_edit_project(auth.uid(), m.project_id)
  )
);

CREATE POLICY "Users can delete their own documents"
ON public.model_documents FOR DELETE
USING (
  auth.uid() = uploaded_by OR
  EXISTS (
    SELECT 1 FROM models m
    WHERE m.id = model_documents.model_id
    AND can_edit_project(auth.uid(), m.project_id)
  )
);

-- RLS policies for approval_signatures
CREATE POLICY "Users can view signatures for accessible approvals"
ON public.approval_signatures FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM approval_actions aa
    JOIN model_approvals ma ON aa.model_approval_id = ma.id
    JOIN models m ON ma.model_id = m.id
    WHERE aa.id = approval_signatures.approval_action_id
    AND can_access_project(auth.uid(), m.project_id)
  )
);

CREATE POLICY "Users can create their own signatures"
ON public.approval_signatures FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Create storage bucket for model documents
INSERT INTO storage.buckets (id, name, public) 
VALUES ('model-documents', 'model-documents', false);

-- Storage policies for model documents
CREATE POLICY "Users can view documents for accessible projects"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'model-documents' AND
  EXISTS (
    SELECT 1 FROM model_documents md
    JOIN models m ON md.model_id = m.id
    WHERE md.file_path = name
    AND can_access_project(auth.uid(), m.project_id)
  )
);

CREATE POLICY "Users can upload documents for editable projects"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'model-documents' AND
  auth.uid() IS NOT NULL
);

CREATE POLICY "Users can delete their uploaded documents"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'model-documents' AND
  EXISTS (
    SELECT 1 FROM model_documents md
    JOIN models m ON md.model_id = m.id
    WHERE md.file_path = name
    AND (md.uploaded_by = auth.uid() OR can_edit_project(auth.uid(), m.project_id))
  )
);

-- Add indexes for performance
CREATE INDEX idx_model_documents_model_id ON public.model_documents(model_id);
CREATE INDEX idx_model_documents_stage_id ON public.model_documents(stage_id);
CREATE INDEX idx_model_documents_document_type ON public.model_documents(document_type);
CREATE INDEX idx_approval_signatures_approval_action_id ON public.approval_signatures(approval_action_id);

-- Add trigger for updated_at
CREATE TRIGGER update_model_documents_updated_at
  BEFORE UPDATE ON public.model_documents
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();