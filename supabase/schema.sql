-- Real Estate Marketing CRM Database Schema for Supabase
-- This file can be run directly in Supabase SQL Editor

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Create Organizations table
CREATE TABLE IF NOT EXISTS organizations (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE INDEX idx_organizations_deleted_at ON organizations(deleted_at);
CREATE UNIQUE INDEX idx_organizations_unique_active_name ON organizations(name) WHERE (deleted_at IS NULL);

-- Create Users table
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR NOT NULL,
    password_digest VARCHAR,
    role INTEGER NOT NULL DEFAULT 2,
    status INTEGER NOT NULL DEFAULT 0,
    organization_id BIGINT REFERENCES organizations(id) ON DELETE SET NULL,
    jti VARCHAR NOT NULL,
    invitation_token VARCHAR,
    invitation_created_at TIMESTAMP,
    invitation_accepted_at TIMESTAMP,
    invited_by_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    created_by_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    CONSTRAINT valid_user_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$'),
    CONSTRAINT valid_role_range CHECK (role >= 0 AND role <= 2),
    CONSTRAINT valid_user_status CHECK (status >= 0),
    CONSTRAINT unique_jti UNIQUE (jti)
);

CREATE UNIQUE INDEX idx_users_unique_active_email ON users(email) WHERE (deleted_at IS NULL);
CREATE UNIQUE INDEX idx_users_unique_active_invitation_token ON users(invitation_token) WHERE (invitation_token IS NOT NULL);
CREATE INDEX idx_users_organization_id ON users(organization_id);
CREATE INDEX idx_users_deleted_at ON users(deleted_at);
CREATE INDEX idx_users_org_and_deleted ON users(organization_id, deleted_at);
CREATE INDEX idx_users_status_and_deleted ON users(status, deleted_at);
CREATE INDEX idx_users_invitation_token ON users(invitation_token);
CREATE INDEX idx_users_pending_invitations ON users(invitation_token, invitation_accepted_at) 
    WHERE (invitation_accepted_at IS NULL AND invitation_token IS NOT NULL);
CREATE INDEX idx_users_invited_by_id ON users(invited_by_id);
CREATE INDEX idx_users_created_by_id ON users(created_by_id);

-- Create Contacts table
CREATE TABLE IF NOT EXISTS contacts (
    id BIGSERIAL PRIMARY KEY,
    organization_id BIGINT NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    email VARCHAR NOT NULL,
    first_name VARCHAR,
    last_name VARCHAR,
    phone VARCHAR,
    preferences JSONB NOT NULL DEFAULT '{}',
    created_by_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    CONSTRAINT valid_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$'),
    CONSTRAINT valid_india_mobile_phone CHECK (phone IS NULL OR phone ~ '^(\+91|91)?[6-9][0-9]{9}$')
);

CREATE UNIQUE INDEX idx_contacts_unique_org_email ON contacts(organization_id, email) WHERE (deleted_at IS NULL);
CREATE UNIQUE INDEX idx_contacts_unique_phone ON contacts(phone) WHERE (deleted_at IS NULL AND phone IS NOT NULL);
CREATE INDEX idx_contacts_organization_id ON contacts(organization_id);
CREATE INDEX idx_contacts_deleted_at ON contacts(deleted_at);
CREATE INDEX idx_contacts_org_and_deleted ON contacts(organization_id, deleted_at);
CREATE INDEX idx_contacts_created_by_id ON contacts(created_by_id);
CREATE INDEX idx_contacts_preferences ON contacts USING gin(preferences jsonb_path_ops);

-- Create Audiences table
CREATE TABLE IF NOT EXISTS audiences (
    id BIGSERIAL PRIMARY KEY,
    organization_id BIGINT NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR NOT NULL,
    description TEXT,
    filters JSONB NOT NULL DEFAULT '{}',
    created_by_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE UNIQUE INDEX idx_audiences_unique_org_name ON audiences(organization_id, name) WHERE (deleted_at IS NULL);
CREATE INDEX idx_audiences_organization_id ON audiences(organization_id);
CREATE INDEX idx_audiences_deleted_at ON audiences(deleted_at);
CREATE INDEX idx_audiences_org_and_deleted ON audiences(organization_id, deleted_at);
CREATE INDEX idx_audiences_created_by_id ON audiences(created_by_id);
CREATE INDEX idx_audiences_filters ON audiences USING gin(filters jsonb_path_ops);

-- Create Audience Contacts junction table
CREATE TABLE IF NOT EXISTS audience_contacts (
    id BIGSERIAL PRIMARY KEY,
    audience_id BIGINT NOT NULL REFERENCES audiences(id) ON DELETE CASCADE,
    contact_id BIGINT NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_audience_contact UNIQUE (audience_id, contact_id)
);

CREATE INDEX idx_audience_contacts_audience_id ON audience_contacts(audience_id);
CREATE INDEX idx_audience_contacts_contact_id ON audience_contacts(contact_id);

-- Create Email Templates table
CREATE TABLE IF NOT EXISTS email_templates (
    id BIGSERIAL PRIMARY KEY,
    organization_id BIGINT NOT NULL REFERENCES organizations(id),
    name VARCHAR NOT NULL,
    subject VARCHAR NOT NULL,
    body TEXT NOT NULL,
    variables JSONB NOT NULL DEFAULT '{}',
    created_by_id BIGINT NOT NULL REFERENCES users(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE UNIQUE INDEX idx_email_templates_unique_org_name ON email_templates(organization_id, name) WHERE (deleted_at IS NULL);
CREATE INDEX idx_email_templates_organization_id ON email_templates(organization_id);
CREATE INDEX idx_email_templates_deleted_at ON email_templates(deleted_at);
CREATE INDEX idx_email_templates_org_and_deleted ON email_templates(organization_id, deleted_at);
CREATE INDEX idx_email_templates_created_by_id ON email_templates(created_by_id);

-- Create Campaigns table
CREATE TABLE IF NOT EXISTS campaigns (
    id BIGSERIAL PRIMARY KEY,
    organization_id BIGINT NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR NOT NULL,
    description TEXT,
    subject VARCHAR,
    body TEXT,
    status INTEGER NOT NULL DEFAULT 0,
    scheduled_type INTEGER NOT NULL DEFAULT 0,
    scheduled_at TIMESTAMP,
    filters JSONB NOT NULL DEFAULT '{}',
    custom_variables JSONB NOT NULL DEFAULT '{}',
    email_template_id BIGINT REFERENCES email_templates(id),
    created_by_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    CONSTRAINT valid_campaign_status CHECK (status >= 0),
    CONSTRAINT valid_scheduled_type CHECK (scheduled_type >= 0),
    CONSTRAINT scheduled_at_on_or_after_created CHECK (scheduled_at IS NULL OR scheduled_at >= created_at)
);

CREATE UNIQUE INDEX idx_campaigns_unique_org_name ON campaigns(organization_id, name) WHERE (deleted_at IS NULL);
CREATE INDEX idx_campaigns_organization_id ON campaigns(organization_id);
CREATE INDEX idx_campaigns_deleted_at ON campaigns(deleted_at);
CREATE INDEX idx_campaigns_org_and_deleted ON campaigns(organization_id, deleted_at);
CREATE INDEX idx_campaigns_created_by_id ON campaigns(created_by_id);
CREATE INDEX idx_campaigns_email_template_id ON campaigns(email_template_id);
CREATE INDEX idx_campaigns_status ON campaigns(status);
CREATE INDEX idx_campaigns_scheduled_at ON campaigns(scheduled_at);
CREATE INDEX idx_campaigns_org_status_deleted ON campaigns(organization_id, status, deleted_at);
CREATE INDEX idx_campaigns_filters ON campaigns USING gin(filters);
CREATE INDEX idx_campaigns_status_and_scheduled ON campaigns(status, scheduled_at) 
    WHERE (deleted_at IS NULL AND status = 0);
CREATE INDEX idx_campaigns_scheduled_pending ON campaigns(scheduled_at, status) 
    WHERE (deleted_at IS NULL AND scheduled_at IS NOT NULL);

-- Create Campaign Audiences junction table
CREATE TABLE IF NOT EXISTS campaign_audiences (
    id BIGSERIAL PRIMARY KEY,
    campaign_id BIGINT NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
    audience_id BIGINT NOT NULL REFERENCES audiences(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_campaign_audience UNIQUE (campaign_id, audience_id)
);

CREATE INDEX idx_campaign_audiences_campaign_id ON campaign_audiences(campaign_id);
CREATE INDEX idx_campaign_audiences_audience_id ON campaign_audiences(audience_id);

-- Create Campaign Emails table
CREATE TABLE IF NOT EXISTS campaign_emails (
    id BIGSERIAL PRIMARY KEY,
    campaign_id BIGINT NOT NULL REFERENCES campaigns(id),
    contact_id BIGINT NOT NULL REFERENCES contacts(id),
    audience_id BIGINT REFERENCES audiences(id),
    email VARCHAR NOT NULL,
    subject VARCHAR NOT NULL,
    body TEXT NOT NULL,
    status INTEGER NOT NULL DEFAULT 0,
    sent_at TIMESTAMP,
    delivered_at TIMESTAMP,
    opened_at TIMESTAMP,
    clicked_at TIMESTAMP,
    bounced_at TIMESTAMP,
    error_message TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_campaign_contact UNIQUE (campaign_id, contact_id)
);

CREATE INDEX idx_campaign_emails_campaign_id ON campaign_emails(campaign_id);
CREATE INDEX idx_campaign_emails_contact_id ON campaign_emails(contact_id);
CREATE INDEX idx_campaign_emails_audience_id ON campaign_emails(audience_id);
CREATE INDEX idx_campaign_emails_status ON campaign_emails(status);
CREATE INDEX idx_campaign_emails_sent_at ON campaign_emails(sent_at);
CREATE INDEX idx_campaign_emails_campaign_id_and_status ON campaign_emails(campaign_id, status);

-- Create Campaign Statistics table
CREATE TABLE IF NOT EXISTS campaign_statistics (
    id BIGSERIAL PRIMARY KEY,
    campaign_id BIGINT NOT NULL REFERENCES campaigns(id),
    total_contacts INTEGER NOT NULL DEFAULT 0,
    emails_sent INTEGER NOT NULL DEFAULT 0,
    emails_delivered INTEGER NOT NULL DEFAULT 0,
    emails_opened INTEGER NOT NULL DEFAULT 0,
    emails_clicked INTEGER NOT NULL DEFAULT 0,
    emails_bounced INTEGER NOT NULL DEFAULT 0,
    emails_failed INTEGER NOT NULL DEFAULT 0,
    last_sent_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_campaign_stats UNIQUE (campaign_id)
);

CREATE INDEX idx_campaign_statistics_campaign_id ON campaign_statistics(campaign_id);

-- Create Contact Import Logs table
CREATE TABLE IF NOT EXISTS contact_import_logs (
    id BIGSERIAL PRIMARY KEY,
    organization_id BIGINT NOT NULL REFERENCES organizations(id),
    user_id BIGINT NOT NULL REFERENCES users(id),
    filename VARCHAR NOT NULL,
    job_id VARCHAR NOT NULL,
    status INTEGER NOT NULL DEFAULT 0,
    total_rows INTEGER NOT NULL DEFAULT 0,
    successful_rows INTEGER NOT NULL DEFAULT 0,
    failed_rows INTEGER NOT NULL DEFAULT 0,
    error_details JSONB NOT NULL DEFAULT '[]',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_job_id UNIQUE (job_id)
);

CREATE INDEX idx_contact_import_logs_organization_id ON contact_import_logs(organization_id);
CREATE INDEX idx_contact_import_logs_user_id ON contact_import_logs(user_id);
CREATE INDEX idx_contact_import_logs_status ON contact_import_logs(status);
CREATE INDEX idx_contact_import_logs_created_at ON contact_import_logs(created_at);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_organizations_updated_at BEFORE UPDATE ON organizations 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_contacts_updated_at BEFORE UPDATE ON contacts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_audiences_updated_at BEFORE UPDATE ON audiences 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_audience_contacts_updated_at BEFORE UPDATE ON audience_contacts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_email_templates_updated_at BEFORE UPDATE ON email_templates 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_campaigns_updated_at BEFORE UPDATE ON campaigns 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_campaign_emails_updated_at BEFORE UPDATE ON campaign_emails 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_campaign_statistics_updated_at BEFORE UPDATE ON campaign_statistics 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_contact_import_logs_updated_at BEFORE UPDATE ON contact_import_logs 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Add comments to tables
COMMENT ON TABLE organizations IS 'Organizations/companies using the CRM system';
COMMENT ON TABLE users IS 'Users with role-based access to organizations';
COMMENT ON TABLE contacts IS 'Contact database for marketing campaigns';
COMMENT ON TABLE audiences IS 'Segmented groups of contacts based on filters';
COMMENT ON TABLE audience_contacts IS 'Junction table linking audiences and contacts';
COMMENT ON TABLE email_templates IS 'Reusable email templates for campaigns';
COMMENT ON TABLE campaigns IS 'Marketing campaigns with email scheduling';
COMMENT ON TABLE campaign_audiences IS 'Junction table linking campaigns and audiences';
COMMENT ON TABLE campaign_emails IS 'Individual emails sent as part of campaigns';
COMMENT ON TABLE campaign_statistics IS 'Aggregated statistics for campaigns';
COMMENT ON TABLE contact_import_logs IS 'Logs of bulk contact import operations';
