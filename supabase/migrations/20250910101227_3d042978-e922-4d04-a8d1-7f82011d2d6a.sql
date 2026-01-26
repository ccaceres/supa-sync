-- Create notifications table
CREATE TABLE public.notifications (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  type CHARACTER VARYING NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  data JSONB DEFAULT '{}',
  read_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  expires_at TIMESTAMP WITH TIME ZONE,
  related_entity_type CHARACTER VARYING,
  related_entity_id UUID,
  action_url TEXT,
  priority CHARACTER VARYING NOT NULL DEFAULT 'medium'
);

-- Create notification_templates table
CREATE TABLE public.notification_templates (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  type CHARACTER VARYING NOT NULL UNIQUE,
  subject_template TEXT NOT NULL,
  body_template TEXT NOT NULL,
  email_template TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS on notifications
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Users can view their own notifications
CREATE POLICY "Users can view their own notifications" 
ON public.notifications 
FOR SELECT 
USING (auth.uid() = user_id);

-- Users can update their own notifications (mark as read)
CREATE POLICY "Users can update their own notifications" 
ON public.notifications 
FOR UPDATE 
USING (auth.uid() = user_id);

-- Enable RLS on notification_templates
ALTER TABLE public.notification_templates ENABLE ROW LEVEL SECURITY;

-- Anyone can view active notification templates
CREATE POLICY "Anyone can view notification templates" 
ON public.notification_templates 
FOR SELECT 
USING (is_active = true);

-- Only admins can modify notification templates
CREATE POLICY "Admins can manage notification templates" 
ON public.notification_templates 
FOR ALL 
USING (has_role(auth.uid(), 'admin'::app_role));

-- Add trigger for updated_at on notifications
CREATE TRIGGER update_notifications_updated_at
BEFORE UPDATE ON public.notifications
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Add trigger for updated_at on notification_templates
CREATE TRIGGER update_notification_templates_updated_at
BEFORE UPDATE ON public.notification_templates
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- Insert initial notification templates
INSERT INTO public.notification_templates (type, subject_template, body_template, email_template) VALUES
('project_shared', 'You''ve been added to project: {{project_name}}', '{{inviter_name}} has added you to the project "{{project_name}}" with {{access_level}} access.', 
'<h2>Project Invitation</h2><p>Hello,</p><p>{{inviter_name}} has invited you to collaborate on the project <strong>{{project_name}}</strong> with <strong>{{access_level}}</strong> access.</p><p><a href="{{action_url}}">View Project</a></p>'),

('project_access_changed', 'Your access to {{project_name}} has been updated', 'Your access level for project "{{project_name}}" has been changed to {{access_level}}.', 
'<h2>Access Level Updated</h2><p>Hello,</p><p>Your access level for the project <strong>{{project_name}}</strong> has been updated to <strong>{{access_level}}</strong>.</p><p><a href="{{action_url}}">View Project</a></p>'),

('project_removed', 'You''ve been removed from project: {{project_name}}', 'You no longer have access to the project "{{project_name}}".', 
'<h2>Project Access Removed</h2><p>Hello,</p><p>You have been removed from the project <strong>{{project_name}}</strong>.</p>'),

('model_submitted', 'Model {{model_name}} submitted for approval', 'The model "{{model_name}}" in project "{{project_name}}" has been submitted for approval.', 
'<h2>Model Submitted</h2><p>Hello,</p><p>The model <strong>{{model_name}}</strong> in project <strong>{{project_name}}</strong> has been submitted for approval.</p><p><a href="{{action_url}}">Review Model</a></p>'),

('model_approved', 'Model {{model_name}} has been approved', 'Your model "{{model_name}}" in project "{{project_name}}" has been approved.', 
'<h2>Model Approved</h2><p>Hello,</p><p>Your model <strong>{{model_name}}</strong> in project <strong>{{project_name}}</strong> has been approved.</p><p><a href="{{action_url}}">View Model</a></p>'),

('model_rejected', 'Model {{model_name}} needs revision', 'Your model "{{model_name}}" in project "{{project_name}}" requires revision. Reason: {{reason}}', 
'<h2>Model Requires Revision</h2><p>Hello,</p><p>Your model <strong>{{model_name}}</strong> in project <strong>{{project_name}}</strong> requires revision.</p><p><strong>Reason:</strong> {{reason}}</p><p><a href="{{action_url}}">View Model</a></p>');