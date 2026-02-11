import api from './api';

const dashboardService = {
  // GET /api/v1/dashboard/stats - Get dashboard statistics
  getStats: async () => {
    const response = await api.get('/dashboard/stats');
    return response.data;
  },
};

export default dashboardService;
