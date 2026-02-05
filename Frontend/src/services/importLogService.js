import api from './api';

const importLogService = {
  getAll: async () => {
    const response = await api.get('/contact_import_logs');
    return response.data.import_logs || [];
  },

  getById: async (id) => {
    const response = await api.get(`/contact_import_logs/${id}`);
    return response.data.import_log;
  },
};

export default importLogService;
