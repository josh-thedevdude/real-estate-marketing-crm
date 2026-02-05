import api from './api';

const audienceService = {
  getAll: async () => {
    const response = await api.get('/audiences');
    return response.data.audiences || [];
  },

  getById: async (id) => {
    const response = await api.get(`/audiences/${id}`);
    return response.data.audience;
  },

  create: async (data) => {
    const response = await api.post('/audiences', { audience: data });
    return response.data.audience;
  },

  update: async (id, data) => {
    const response = await api.put(`/audiences/${id}`, { audience: data });
    return response.data.audience;
  },

  delete: async (id) => {
    const response = await api.delete(`/audiences/${id}`);
    return response.data;
  },

  preview: async (filters) => {
    const response = await api.post('/audiences/preview', { filters });
    return response.data;
  },
};

export default audienceService;
