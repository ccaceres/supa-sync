-- Create sequence for ticket numbers
CREATE SEQUENCE ticket_number_seq START 1;

-- Create ticket statuses enum
CREATE TYPE ticket_status AS ENUM (
  'new',
  'in_progress',
  'waiting_for_user',
  'resolved',
  'closed',
  'reopened'
);

-- Create ticket priorities enum
CREATE TYPE ticket_priority AS ENUM (
  'low',
  'medium',
  'high',
  'urgent'
);

-- Create ticket types enum
CREATE TYPE ticket_type AS ENUM (
  'bug',
  'feature_request',
  'question',
  'technical_support',
  'other'
);

-- Main tickets table
CREATE TABLE support_tickets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_number VARCHAR UNIQUE NOT NULL DEFAULT 'TKT-' || LPAD(nextval('ticket_number_seq')::TEXT, 6, '0'),
  created_by UUID NOT NULL REFERENCES auth.users(id),
  assigned_to UUID REFERENCES auth.users(id),
  
  type ticket_type NOT NULL,
  status ticket_status NOT NULL DEFAULT 'new',
  priority ticket_priority NOT NULL DEFAULT 'medium',
  
  subject VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  
  -- Feature request specific fields
  feature_use_case TEXT,
  feature_business_value TEXT,
  
  -- Resolution info
  resolution TEXT,
  resolved_at TIMESTAMP WITH TIME ZONE,
  resolved_by UUID REFERENCES auth.users(id),
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  
  -- Tags for categorization
  tags TEXT[],
  
  CONSTRAINT valid_resolution CHECK (
    (status IN ('resolved', 'closed') AND resolution IS NOT NULL) OR
    (status NOT IN ('resolved', 'closed'))
  )
);

-- Ticket comments/activity log
CREATE TABLE ticket_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id UUID NOT NULL REFERENCES support_tickets(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id),
  
  comment TEXT NOT NULL,
  is_internal BOOLEAN DEFAULT false,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Ticket attachments tracking
CREATE TABLE ticket_attachments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id UUID NOT NULL REFERENCES support_tickets(id) ON DELETE CASCADE,
  uploaded_by UUID NOT NULL REFERENCES auth.users(id),
  
  file_name VARCHAR(255) NOT NULL,
  file_path TEXT NOT NULL,
  file_size BIGINT NOT NULL,
  mime_type VARCHAR(100),
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Ticket status change history
CREATE TABLE ticket_status_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id UUID NOT NULL REFERENCES support_tickets(id) ON DELETE CASCADE,
  changed_by UUID NOT NULL REFERENCES auth.users(id),
  
  old_status ticket_status,
  new_status ticket_status NOT NULL,
  notes TEXT,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Indexes for performance
CREATE INDEX idx_tickets_created_by ON support_tickets(created_by);
CREATE INDEX idx_tickets_assigned_to ON support_tickets(assigned_to);
CREATE INDEX idx_tickets_status ON support_tickets(status);
CREATE INDEX idx_tickets_created_at ON support_tickets(created_at DESC);
CREATE INDEX idx_ticket_comments_ticket_id ON ticket_comments(ticket_id);
CREATE INDEX idx_ticket_attachments_ticket_id ON ticket_attachments(ticket_id);

-- Enable RLS
ALTER TABLE support_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_status_history ENABLE ROW LEVEL SECURITY;

-- RLS Policies for support_tickets
CREATE POLICY "Users can view their own tickets"
ON support_tickets FOR SELECT
USING (created_by = auth.uid());

CREATE POLICY "Admins can view all tickets"
ON support_tickets FOR SELECT
USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Users can create tickets"
ON support_tickets FOR INSERT
WITH CHECK (created_by = auth.uid());

CREATE POLICY "Users can update their own open tickets"
ON support_tickets FOR UPDATE
USING (created_by = auth.uid() AND status NOT IN ('resolved', 'closed'))
WITH CHECK (created_by = auth.uid());

CREATE POLICY "Admins can update all tickets"
ON support_tickets FOR UPDATE
USING (has_role(auth.uid(), 'admin'::app_role));

-- RLS Policies for ticket_comments
CREATE POLICY "Users can view their ticket comments"
ON ticket_comments FOR SELECT
USING (
  (is_internal = false AND EXISTS (
    SELECT 1 FROM support_tickets 
    WHERE id = ticket_comments.ticket_id 
    AND created_by = auth.uid()
  )) OR
  has_role(auth.uid(), 'admin'::app_role)
);

CREATE POLICY "Users can comment on their tickets"
ON ticket_comments FOR INSERT
WITH CHECK (
  user_id = auth.uid() AND
  is_internal = false AND
  EXISTS (
    SELECT 1 FROM support_tickets 
    WHERE id = ticket_comments.ticket_id 
    AND created_by = auth.uid()
  )
);

CREATE POLICY "Admins can add any comments"
ON ticket_comments FOR INSERT
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- RLS Policies for ticket_attachments
CREATE POLICY "Users can view attachments on their tickets"
ON ticket_attachments FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM support_tickets 
    WHERE id = ticket_attachments.ticket_id 
    AND created_by = auth.uid()
  ) OR
  has_role(auth.uid(), 'admin'::app_role)
);

CREATE POLICY "Users can upload attachments to their tickets"
ON ticket_attachments FOR INSERT
WITH CHECK (
  uploaded_by = auth.uid() AND
  EXISTS (
    SELECT 1 FROM support_tickets 
    WHERE id = ticket_attachments.ticket_id 
    AND created_by = auth.uid()
  )
);

CREATE POLICY "Admins can upload any attachments"
ON ticket_attachments FOR INSERT
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- RLS Policies for ticket_status_history
CREATE POLICY "Users can view status history of their tickets"
ON ticket_status_history FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM support_tickets 
    WHERE id = ticket_status_history.ticket_id 
    AND created_by = auth.uid()
  ) OR
  has_role(auth.uid(), 'admin'::app_role)
);

CREATE POLICY "Admins can insert status history"
ON ticket_status_history FOR INSERT
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

-- Trigger to log status changes
CREATE OR REPLACE FUNCTION log_ticket_status_change()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    INSERT INTO ticket_status_history (ticket_id, changed_by, old_status, new_status)
    VALUES (NEW.id, auth.uid(), OLD.status, NEW.status);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER ticket_status_change_trigger
AFTER UPDATE OF status ON support_tickets
FOR EACH ROW
EXECUTE FUNCTION log_ticket_status_change();

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_ticket_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_ticket_timestamp
BEFORE UPDATE ON support_tickets
FOR EACH ROW
EXECUTE FUNCTION update_ticket_updated_at();

-- Create storage bucket for ticket attachments
INSERT INTO storage.buckets (id, name, public)
VALUES ('ticket-attachments', 'ticket-attachments', false)
ON CONFLICT (id) DO NOTHING;

-- Storage RLS policies
CREATE POLICY "Users can upload their own ticket attachments"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'ticket-attachments' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can view their own attachments"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'ticket-attachments' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Admins can view all ticket attachments"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'ticket-attachments' AND
  has_role(auth.uid(), 'admin'::app_role)
);