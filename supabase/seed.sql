-- Sample seed data for Real Estate Marketing CRM
-- Run this after schema.sql to populate initial data

-- Insert a sample organization
INSERT INTO organizations (name, created_at, updated_at)
VALUES ('Demo Real Estate Agency', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert a sample super admin user (password: password123)
-- Note: You'll need to generate a proper bcrypt hash for production
INSERT INTO users (
    email, 
    password_digest, 
    role, 
    status, 
    organization_id, 
    jti,
    created_at,
    updated_at
)
VALUES (
    'admin@system.com',
    '$2a$12$K8mQXjdPGJgQHH.UPUYvgef.gKPqFqvHQH8Zu2gHZQcCdLSQlbxba', -- password: password123
    0, -- super_admin role
    1, -- active status
    1,
    'unique-jti-' || gen_random_uuid()::text,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

-- Insert sample contacts
INSERT INTO contacts (organization_id, email, first_name, last_name, phone, preferences, created_by_id, created_at, updated_at)
VALUES 
    (1, 'rajesh.kumar@system.com', 'Rajesh', 'Kumar', '+919876543210', '{"marketing_consent": true, "preferred_contact": "email"}', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (1, 'priya.sharma@system.com', 'Priya', 'Sharma', '+919876543211', '{"marketing_consent": true, "preferred_contact": "phone"}', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (1, 'amit.patel@system.com', 'Amit', 'Patel', '+919876543212', '{"marketing_consent": true, "preferred_contact": "email"}', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (1, 'sneha.gupta@system.com', 'Sneha', 'Gupta', '+919876543213', '{"marketing_consent": true, "preferred_contact": "phone"}', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (1, 'vikram.singh@system.com', 'Vikram', 'Singh', '+919876543214', '{"marketing_consent": true}', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (1, 'ananya.reddy@system.com', 'Ananya', 'Reddy', '+919876543215', '{"marketing_consent": true, "preferred_contact": "email"}', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert sample audience
INSERT INTO audiences (organization_id, name, description, filters, created_by_id, created_at, updated_at)
VALUES (
    1,
    'All Contacts',
    'All active contacts in the system',
    '{}',
    1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

-- Link contacts to audience
INSERT INTO audience_contacts (audience_id, contact_id, created_at, updated_at)
VALUES 
    (1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (1, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (1, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (1, 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (1, 5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (1, 6, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert sample email template
INSERT INTO email_templates (
    organization_id,
    name,
    subject,
    body,
    variables,
    created_by_id,
    created_at,
    updated_at
)
VALUES (
    1,
    'Welcome Email',
    'Welcome to {{organization_name}}!',
    'Hi {{first_name}},\n\nWelcome to our real estate services! We''re excited to help you find your dream property.\n\nBest regards,\n{{organization_name}}',
    '{"organization_name": "Demo Real Estate Agency"}',
    1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

-- Insert sample campaign
INSERT INTO campaigns (
    organization_id,
    name,
    description,
    subject,
    body,
    status,
    scheduled_type,
    filters,
    custom_variables,
    email_template_id,
    created_by_id,
    created_at,
    updated_at
)
VALUES (
    1,
    'Welcome Campaign',
    'Send welcome emails to new contacts',
    'Welcome to Demo Real Estate Agency!',
    'Hi {{first_name}},\n\nWelcome to our real estate services!',
    0, -- pending
    0, -- immediate
    '{}',
    '{"organization_name": "Demo Real Estate Agency"}',
    1,
    1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

-- Link campaign to audience
INSERT INTO campaign_audiences (campaign_id, audience_id, created_at)
VALUES (1, 1, CURRENT_TIMESTAMP);

-- Initialize campaign statistics
INSERT INTO campaign_statistics (
    campaign_id,
    total_contacts,
    emails_sent,
    emails_delivered,
    emails_opened,
    emails_clicked,
    emails_bounced,
    emails_failed,
    created_at,
    updated_at
)
VALUES (1, 6, 0, 0, 0, 0, 0, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

COMMENT ON TABLE organizations IS 'Sample data loaded - 1 organization';
COMMENT ON TABLE users IS 'Sample data loaded - 1 admin user (admin@system.com / password123)';
COMMENT ON TABLE contacts IS 'Sample data loaded - 6 contacts with Indian names';
