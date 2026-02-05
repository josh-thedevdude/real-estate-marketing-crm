import api from './api';

const organizationService = {
  getAll: async (includeDeleted = false) => {
    const params = includeDeleted ? { include_deleted: 'true' } : {};
    const response = await api.get('/organizations', { params });
    return response.data.organizations || [];
  },

  getById: async (id) => {
    const response = await api.get(`/organizations/${id}`);
    return response.data.organization;
  },

  create: async (data) => {
    const response = await api.post('/organizations', { organization: data });
    return response.data.organization;
  },

  update: async (id, data) => {
    const response = await api.put(`/organizations/${id}`, { organization: data });
    return response.data.organization;
  },

  delete: async (id) => {
    const response = await api.delete(`/organizations/${id}`);
    return response.data;
  },
};

export default organizationService;
