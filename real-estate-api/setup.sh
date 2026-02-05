#!/bin/bash

# Real Estate Marketing CRM - Database Setup Script
# This script sets up all databases and runs migrations

set -e  # Exit on error


echo "Real Estate API - Database Setup"

echo ""

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Database configurations
DB_USERNAME="postgres"
DB_PASSWORD="harish"

# Development database
DEV_DB="real_estate_api_development"

# Test database
TEST_DB="real_estate_api_test"

# Production databases (for reference - not created in this script)
# PROD_DB="real_estate_api_production"
# PROD_CACHE_DB="real_estate_api_production_cache"
# PROD_QUEUE_DB="real_estate_api_production_queue"
# PROD_CABLE_DB="real_estate_api_production_cable"

echo -e "${BLUE}Step 1: Checking PostgreSQL connection...${NC}"
if PGPASSWORD=$DB_PASSWORD psql -U $DB_USERNAME -h localhost -lqt | cut -d \| -f 1 | grep -qw postgres; then
    echo -e "${GREEN} PostgreSQL connection successful${NC}"
else
    echo -e "${RED} Failed to connect to PostgreSQL${NC}"
    echo "Please ensure PostgreSQL is running and credentials are correct"
    exit 1
fi
echo ""

echo -e "${BLUE}Step 2: Creating databases...${NC}"
# Create development database
if PGPASSWORD=$DB_PASSWORD psql -U $DB_USERNAME -h localhost -lqt | cut -d \| -f 1 | grep -qw $DEV_DB; then
    echo -e "${GREEN} Database '$DEV_DB' already exists${NC}"
else
    PGPASSWORD=$DB_PASSWORD createdb -U $DB_USERNAME -h localhost $DEV_DB
    echo -e "${GREEN} Created database '$DEV_DB'${NC}"
fi

# Create test database
if PGPASSWORD=$DB_PASSWORD psql -U $DB_USERNAME -h localhost -lqt | cut -d \| -f 1 | grep -qw $TEST_DB; then
    echo -e "${GREEN} Database '$TEST_DB' already exists${NC}"
else
    PGPASSWORD=$DB_PASSWORD createdb -U $DB_USERNAME -h localhost $TEST_DB
    echo -e "${GREEN} Created database '$TEST_DB'${NC}"
fi
echo ""

echo -e "${BLUE}Step 3: Running database migrations...${NC}"
echo "This will create the following tables:"
echo "  - organizations"
echo "  - users"
echo "  - contacts"
echo "  - audiences"
echo "  - campaigns"
echo "  - campaign_audiences"
echo "  - contact_import_logs"
echo ""

# Run migrations
bundle exec rails db:migrate RAILS_ENV=development
echo -e "${GREEN} Development database migrations completed${NC}"
echo ""

echo -e "${BLUE}Step 4: Loading schema to test database...${NC}"
bundle exec rails db:schema:load RAILS_ENV=test
echo -e "${GREEN} Test database schema loaded${NC}"
echo ""

echo -e "${BLUE}Step 5: Database setup summary${NC}"

echo -e "${GREEN}Databases created:${NC}"
echo "  • $DEV_DB"
echo "  • $TEST_DB"
echo ""
echo -e "${GREEN}Tables created:${NC}"
echo "  • organizations"
echo "  • users"
echo "  • contacts"
echo "  • audiences"
echo "  • campaigns"
echo "  • campaign_audiences"
echo "  • contact_import_logs"
echo ""
echo -e "${GREEN}Migrations applied (22 total):${NC}"
echo "  1. create_organizations"
echo "  2. create_users"
echo "  3. rename_encrypted_password_to_password_digest"
echo "  4. create_contacts"
echo "  5. create_audiences"
echo "  6. create_campaigns"
echo "  7. create_campaign_audiences"
echo "  8. remove_audience_ids_from_campaigns"
echo "  9. add_partial_unique_indexes"
echo " 10. add_composite_indexes"
echo " 11. rename_org_id_to_organization_id"
echo " 12. add_check_constraints"
echo " 13. add_not_null_to_jsonb_columns"
echo " 14. optimize_jsonb_indexes"
echo " 15. add_unique_index_to_users_invitation_token"
echo " 16. add_unique_index_on_contacts_not_globally"
echo " 17. allow_null_names_on_contacts"
echo " 18. remove_global_unique_index_on_campaign_names"
echo " 19. remove_global_unique_index_on_audience_names"
echo " 20. update_phone_check_constraint_on_contacts"
echo " 21. update_scheduled_at_constraint_on_campaigns"
echo " 22. create_contact_import_logs"
echo ""

echo -e "${GREEN} Setup completed successfully!${NC}"
echo ""
echo "You can now start the Rails server:"
echo "  rails s"
echo ""
echo "Optional: Seed the database with sample data:"
echo "  rails db:seed"

