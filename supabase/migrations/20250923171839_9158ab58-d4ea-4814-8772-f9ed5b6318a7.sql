-- Create notification templates for labor role request workflows
INSERT INTO notification_templates (type, subject_template, body_template, email_template, is_active) VALUES
(
  'labor_request_submitted',
  'New FLBR Request Requires Your Approval',
  'A new Future Labor Business Request has been submitted for {{job_title}} in {{country}}. Please review and approve at your earliest convenience.',
  '<h2>New FLBR Request Submitted</h2>
   <p>Dear HR Team,</p>
   <p>A new Future Labor Business Request has been submitted that requires your approval:</p>
   <ul>
     <li><strong>Job Title:</strong> {{job_title}}</li>
     <li><strong>Classification:</strong> {{classification}}</li>
     <li><strong>Location:</strong> {{city}}, {{country}}</li>
     <li><strong>Year:</strong> {{year}}</li>
     <li><strong>Request Type:</strong> {{request_type}}</li>
     <li><strong>Requested By:</strong> {{requested_by_name}}</li>
   </ul>
   <p><strong>Comments:</strong> {{comments}}</p>
   <p>Please log into the system to review and approve this request.</p>
   <p>Thank you,<br>The System</p>',
  true
),
(
  'labor_request_approved',
  'Labor Role Request Approved - {{job_title}}',
  'Your labor role request for {{job_title}} has been approved by HR. You can now proceed with your model planning.',
  '<h2>Labor Role Request Approved</h2>
   <p>Good news! Your labor role request has been approved:</p>
   <ul>
     <li><strong>Job Title:</strong> {{job_title}}</li>
     <li><strong>Classification:</strong> {{classification}}</li>
     <li><strong>Location:</strong> {{city}}, {{country}}</li>
     <li><strong>Approved By:</strong> {{approved_by_name}}</li>
     <li><strong>Approved On:</strong> {{approved_at}}</li>
   </ul>
   <p>You can now proceed with adding this role to your model.</p>
   <p>Thank you,<br>The System</p>',
  true
),
(
  'labor_request_rejected',
  'Labor Role Request Rejected - {{job_title}}',
  'Your labor role request for {{job_title}} has been rejected. Reason: {{rejected_reason}}',
  '<h2>Labor Role Request Rejected</h2>
   <p>Your labor role request has been rejected:</p>
   <ul>
     <li><strong>Job Title:</strong> {{job_title}}</li>
     <li><strong>Classification:</strong> {{classification}}</li>
     <li><strong>Location:</strong> {{city}}, {{country}}</li>
     <li><strong>Rejected By:</strong> {{approved_by_name}}</li>
     <li><strong>Rejected On:</strong> {{approved_at}}</li>
   </ul>
   <p><strong>Reason for Rejection:</strong> {{rejected_reason}}</p>
   <p>Please contact HR if you need clarification or wish to submit a revised request.</p>
   <p>Thank you,<br>The System</p>',
  true
);