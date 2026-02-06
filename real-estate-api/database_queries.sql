-- ==================================================
-- Real Estate Marketing CRM - pgAdmin4 Database Queries
-- ==================================================
-- Database: real_estate_api_development
-- Instructions: 
--   1. Open pgAdmin4
--   2. Connect to PostgreSQL server
--   3. Select database: real_estate_api_development
--   4. Right-click on the database → Query Tool
--   5. Copy and paste any query below
--   6. Click Execute (F5) or the Play button
-- ==================================================

-- ==================================================
-- VIEW ALL TABLES
-- ==================================================

-- ORGANIZATIONS
SELECT * FROM organizations LIMIT 50;

-- USERS
SELECT * FROM users LIMIT 50;

-- CONTACTS
SELECT * FROM contacts ORDER BY created_at DESC LIMIT 50;

-- AUDIENCES
SELECT * FROM audiences ORDER BY created_at DESC LIMIT 50;

-- CAMPAIGNS
SELECT * FROM campaigns ORDER BY created_at DESC LIMIT 50;

-- CAMPAIGN AUDIENCES (JOIN TABLE)
SELECT * FROM campaign_audiences ORDER BY created_at DESC LIMIT 50;

-- CONTACT IMPORT LOGS
SELECT * FROM contact_import_logs ORDER BY created_at DESC LIMIT 50;

-- ==================================================
-- INSERT SUPERADMIN USER
-- ==================================================

-- Step 1: First, create an organization (if not exists)
INSERT INTO organizations (name, created_at, updated_at)
VALUES ('Main Organization', NOW(), NOW())
ON CONFLICT DO NOTHING
RETURNING id;
-- Note the organization ID returned (e.g., 1)

-- Step 2: Insert Superadmin User
-- Password: 'Password@123' (bcrypt hash below)
-- Role: 0 = Superadmin, 1 = Manager, 2 = User
-- Status: 0 = Active, 1 = Inactive
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
    'admin@realestate.com',
    '$2a$12$K.gF4bW8qN0rXHJK8zYxJ.XZH1tZ9vJ8qYkZL3mN2nP5qW7rT9uXS', -- Password: 'Password@123'
    0,  -- Role: 0 = Superadmin
    0,  -- Status: 0 = Active
    1,  -- organization_id (use the ID from Step 1)
    'superadmin-' || gen_random_uuid()::text,  -- Unique JWT identifier
    NOW(),
    NOW()
);

-- Alternative: Insert Superadmin without organization
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
    'superadmin@gmail.com',
    '$2a$12$K.gF4bW8qN0rXHJK8zYxJ.XZH1tZ9vJ8qYkZL3mN2nP5qW7rT9uXS', -- Password: 'Password@123'
    0,  -- Role: 0 = Superadmin
    0,  -- Status: 0 = Active
    NULL,  -- No organization
    'superadmin-' || gen_random_uuid()::text,  -- Unique JWT identifier
    NOW(),
    NOW()
);

-- Verify the superadmin was created
SELECT id, email, role, status, organization_id, created_at 
FROM users 
WHERE role = 0
ORDER BY created_at DESC;

-- ==================================================
-- GENERATE BCRYPT PASSWORD HASH
-- ==================================================
-- To generate a bcrypt hash for a new password, use Rails console:
-- 
-- rails console
-- BCrypt::Password.create('YourPassword123')
-- 
-- Or use this online tool: https://bcrypt-generator.com/
-- Recommended rounds: 12

-- ==================================================
-- USEFUL JOINS AND QUERIES
-- ==================================================

-- Get campaigns with their audiences
SELECT 
    c.id,
    c.name AS campaign_name,
    c.status,
    c.scheduled_at,
    a.name AS audience_name,
    a.description AS audience_description
FROM campaigns c
JOIN campaign_audiences ca ON c.id = ca.campaign_id
JOIN audiences a ON ca.audience_id = a.id
WHERE c.deleted_at IS NULL
ORDER BY c.created_at DESC
LIMIT 50;

-- Get contacts with their creator info
SELECT 
    c.id,
    c.first_name,
    c.last_name,
    c.email,
    c.phone,
    o.name AS organization_name,
    u.email AS created_by_email,
    c.created_at
FROM contacts c
JOIN organizations o ON c.organization_id = o.id
JOIN users u ON c.created_by_id = u.id
WHERE c.deleted_at IS NULL
ORDER BY c.created_at DESC
LIMIT 50;

-- Get users by organization
SELECT 
    u.id,
    u.email,
    u.role,
    u.status,
    o.name AS organization_name,
    u.created_at
FROM users u
LEFT JOIN organizations o ON u.organization_id = o.id
WHERE u.deleted_at IS NULL
ORDER BY u.created_at DESC
LIMIT 50;

-- Get audience with contact count (requires executing filters)
SELECT 
    a.id,
    a.name,
    a.description,
    a.filters,
    o.name AS organization_name,
    a.created_at
FROM audiences a
JOIN organizations o ON a.organization_id = o.id
WHERE a.deleted_at IS NULL
ORDER BY a.created_at DESC
LIMIT 50;

-- Get contact import logs with user info
SELECT 
    cil.id,
    cil.filename,
    cil.status,
    cil.total_rows,
    cil.successful_rows,
    cil.failed_rows,
    u.email AS imported_by,
    o.name AS organization_name,
    cil.created_at
FROM contact_import_logs cil
JOIN users u ON cil.user_id = u.id
JOIN organizations o ON cil.organization_id = o.id
ORDER BY cil.created_at DESC
LIMIT 50;

-- ==================================================
-- DELETE OPERATIONS (USE WITH CAUTION)
-- ==================================================

-- Delete a specific organization (will cascade to related records)
-- DELETE FROM organizations WHERE id = 1;

-- Delete a specific user
-- DELETE FROM users WHERE id = 1;

-- Delete a specific contact
-- DELETE FROM contacts WHERE id = 1;

-- Delete a specific audience
-- DELETE FROM audiences WHERE id = 1;

-- Delete a specific campaign
-- DELETE FROM campaigns WHERE id = 1;

-- Delete a campaign-audience association
-- DELETE FROM campaign_audiences WHERE campaign_id = 1 AND audience_id = 1;

-- Delete a contact import log
-- DELETE FROM contact_import_logs WHERE id = 1;

-- ==================================================
-- SOFT DELETE OPERATIONS (RECOMMENDED)
-- ==================================================

-- Soft delete organization
-- UPDATE organizations SET deleted_at = NOW() WHERE id = 1;

-- Soft delete user
-- UPDATE users SET deleted_at = NOW() WHERE id = 1;

-- Soft delete contact
-- UPDATE contacts SET deleted_at = NOW() WHERE id = 1;

-- Soft delete audience
-- UPDATE audiences SET deleted_at = NOW() WHERE id = 1;

-- Soft delete campaign
-- UPDATE campaigns SET deleted_at = NOW() WHERE id = 1;

-- ==================================================
-- RESTORE SOFT DELETED RECORDS
-- ==================================================

-- Restore organization
-- UPDATE organizations SET deleted_at = NULL WHERE id = 1;

-- Restore user
-- UPDATE users SET deleted_at = NULL WHERE id = 1;

-- Restore contact
-- UPDATE contacts SET deleted_at = NULL WHERE id = 1;

-- Restore audience
-- UPDATE audiences SET deleted_at = NULL WHERE id = 1;

-- Restore campaign
-- UPDATE campaigns SET deleted_at = NULL WHERE id = 1;

-- ==================================================
-- COUNT QUERIES
-- ==================================================

-- Count active records by table
SELECT 'organizations' AS table_name, COUNT(*) AS count FROM organizations WHERE deleted_at IS NULL
UNION ALL
SELECT 'users', COUNT(*) FROM users WHERE deleted_at IS NULL
UNION ALL
SELECT 'contacts', COUNT(*) FROM contacts WHERE deleted_at IS NULL
UNION ALL
SELECT 'audiences', COUNT(*) FROM audiences WHERE deleted_at IS NULL
UNION ALL
SELECT 'campaigns', COUNT(*) FROM campaigns WHERE deleted_at IS NULL
UNION ALL
SELECT 'campaign_audiences', COUNT(*) FROM campaign_audiences
UNION ALL
SELECT 'contact_import_logs', COUNT(*) FROM contact_import_logs;
