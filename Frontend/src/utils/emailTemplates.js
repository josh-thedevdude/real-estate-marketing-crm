// Email templates for campaigns
export const EMAIL_TEMPLATES = {
  USER_INVITATION: {
    id: 'user_invitation',
    name: 'User Invitation Email',
    subject: 'Welcome to Real Estate CRM - Invitation to Join',
    body: `Dear {{user_name}},

You have been invited to join our Real Estate CRM platform!

Your account has been created with the following details:
Email: {{user_email}}
Role: {{user_role}}

Please click on the invitation link sent to your email to set your password and activate your account.

If you have any questions, feel free to reach out to our support team.

Best regards,
Real Estate CRM Team`,
  },

  NEW_PROPERTY_ADDED: {
    id: 'new_property',
    name: 'New Property Listing',
    subject: 'Exciting New Property Available - {{property_name}}',
    body: `Hello {{contact_name}},

We're excited to share a new property listing that matches your preferences!

Property Details:
Name: {{property_name}}
Location: {{property_location}}
Price: {{property_price}}
Bedrooms: {{property_bedrooms}}
Bathrooms: {{property_bathrooms}}
Area: {{property_area}} sq ft

Description:
{{property_description}}

Don't miss this opportunity! Contact us today to schedule a viewing.

Best regards,
{{agent_name}}
Real Estate Team`,
  },

  PRICE_DROP_ALERT: {
    id: 'price_drop',
    name: 'Price Drop Alert',
    subject: 'Price Reduced - {{property_name}}',
    body: `Hi {{contact_name}},

Great news! The price has been reduced on a property you showed interest in.

Property: {{property_name}}
Previous Price: {{old_price}}
New Price: {{new_price}}
Savings: {{savings_amount}}

This is a limited-time offer. Contact us now to schedule a viewing!

Best regards,
{{agent_name}}
Real Estate Team`,
  },

  OPEN_HOUSE_INVITATION: {
    id: 'open_house',
    name: 'Open House Invitation',
    subject: 'You\'re Invited - Open House Event',
    body: `Dear {{contact_name}},

You're invited to our Open House event!

Event Details:
Property: {{property_name}}
Date: {{event_date}}
Time: {{event_time}}
Location: {{property_address}}

Join us to explore this beautiful property and meet our team. Refreshments will be served!

RSVP by replying to this email or calling us at {{contact_phone}}.

We look forward to seeing you there!

Best regards,
{{agent_name}}
Real Estate Team`,
  },

  PROPERTY_UPDATE: {
    id: 'property_update',
    name: 'Property Status Update',
    subject: 'Update on {{property_name}}',
    body: `Hello {{contact_name}},

We wanted to update you on the property you inquired about.

Property: {{property_name}}
Status: {{property_status}}
Update: {{update_message}}

{{additional_details}}

If you have any questions or would like more information, please don't hesitate to reach out.

Best regards,
{{agent_name}}
Real Estate Team`,
  },

  MARKET_REPORT: {
    id: 'market_report',
    name: 'Monthly Market Report',
    subject: 'Real Estate Market Report - {{month}} {{year}}',
    body: `Dear {{contact_name}},

Here's your monthly real estate market update for {{location}}.

Market Highlights:
- Average Price: {{avg_price}}
- Properties Sold: {{properties_sold}}
- Market Trend: {{market_trend}}
- Inventory Level: {{inventory_level}}

Key Insights:
{{market_insights}}

Stay informed and make the best decisions for your real estate needs.

Best regards,
{{agent_name}}
Real Estate Team`,
  },

  FOLLOW_UP: {
    id: 'follow_up',
    name: 'Follow-Up Email',
    subject: 'Following Up on Your Real Estate Inquiry',
    body: `Hi {{contact_name}},

I hope this email finds you well. I wanted to follow up on our recent conversation about your real estate needs.

I've identified some properties that might interest you:
{{property_list}}

Would you like to schedule a viewing or discuss these options further?

I'm here to help you find the perfect property!

Best regards,
{{agent_name}}
Real Estate Team
Phone: {{agent_phone}}
Email: {{agent_email}}`,
  },

  THANK_YOU: {
    id: 'thank_you',
    name: 'Thank You Email',
    subject: 'Thank You for Your Interest',
    body: `Dear {{contact_name}},

Thank you for reaching out to us regarding your real estate needs!

We appreciate your interest and look forward to helping you find the perfect property.

Next Steps:
{{next_steps}}

If you have any questions or need immediate assistance, please feel free to contact me directly.

Best regards,
{{agent_name}}
Real Estate Team
Phone: {{agent_phone}}
Email: {{agent_email}}`,
  },

  CUSTOM: {
    id: 'custom',
    name: 'Custom Email (Start from scratch)',
    subject: '',
    body: '',
  },
};

// Helper function to get template by ID
export const getTemplateById = (templateId) => {
  return Object.values(EMAIL_TEMPLATES).find(t => t.id === templateId);
};

// Helper function to get all template options for dropdown
export const getTemplateOptions = () => {
  return Object.values(EMAIL_TEMPLATES).map(template => ({
    value: template.id,
    label: template.name,
  }));
};

// Helper function to replace template variables
export const fillTemplate = (template, variables = {}) => {
  let subject = template.subject;
  let body = template.body;

  // Replace all {{variable}} placeholders with actual values
  Object.keys(variables).forEach(key => {
    const placeholder = `{{${key}}}`;
    subject = subject.replace(new RegExp(placeholder, 'g'), variables[key] || '');
    body = body.replace(new RegExp(placeholder, 'g'), variables[key] || '');
  });

  return { subject, body };
};
