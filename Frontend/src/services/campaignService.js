import api from './api';

const campaignService = {
  // GET /api/v1/campaigns - List all campaigns
  getAll: async (includeDeleted = false) => {
    const params = includeDeleted ? { include_deleted: 'true' } : {};
    const response = await api.get('/campaigns', { params });
    return response.data.campaigns || [];
  },

  // GET /api/v1/campaigns/:id - Get single campaign
  getById: async (id) => {
    const response = await api.get(`/campaigns/${id}`);
    return response.data.campaign;
  },

  // POST /api/v1/campaigns - Create campaign
  create: async (data) => {
    // Clean up data: if scheduled_at is empty, don't send it and set scheduled_type to immediate
    const { audience_ids, ...campaignData } = data;
    const cleanData = { ...campaignData };
    if (!cleanData.scheduled_at || cleanData.scheduled_at.trim() === '') {
      delete cleanData.scheduled_at;
      cleanData.scheduled_type = 'immediate';
    } else {
      cleanData.scheduled_type = 'scheduled';
    }
    
    const response = await api.post('/campaigns', { campaign: cleanData, audience_ids });
    return response.data.campaign;
  },

  // PATCH /api/v1/campaigns/:id - Update campaign
  update: async (id, data) => {
    // Clean up data: if scheduled_at is empty, don't send it and set scheduled_type to immediate
    const { audience_ids, ...campaignData } = data;
    const cleanData = { ...campaignData };
    if (!cleanData.scheduled_at || cleanData.scheduled_at.trim() === '') {
      delete cleanData.scheduled_at;
      cleanData.scheduled_type = 'immediate';
    } else {
      cleanData.scheduled_type = 'scheduled';
    }
    
    const response = await api.patch(`/campaigns/${id}`, { campaign: cleanData, audience_ids });
    return response.data.campaign;
  },

  // DELETE /api/v1/campaigns/:id - Delete campaign
  delete: async (id) => {
    const response = await api.delete(`/campaigns/${id}`);
    return response.data;
  },

  // POST /api/v1/campaigns/:id/execute - Execute campaign
  execute: async (id) => {
    const response = await api.post(`/campaigns/${id}/execute`);
    return response.data;
  },

  // GET /api/v1/campaigns/:id/monitor - Monitor campaign
  monitor: async (id) => {
    const response = await api.get(`/campaigns/${id}/monitor`);
    return response.data;
  },

  // GET /api/v1/campaigns/:id/emails - Get campaign emails
  getEmails: async (id) => {
    const response = await api.get(`/campaigns/${id}/emails`);
    return response.data.emails || [];
  },

  // POST /api/v1/campaigns/:id/audience_contacts - Add audience contacts
  addAudienceContacts: async (id, audienceIds) => {
    const response = await api.post(`/campaigns/${id}/audience_contacts`, { 
      audience_ids: audienceIds 
    });
    return response.data;
  },

  // GET /api/v1/campaigns/templates - Get email templates from backend
  getTemplates: async () => {
    const response = await api.get('/campaigns/templates');
    return response.data.templates || [];
  },
};

export default campaignService;
