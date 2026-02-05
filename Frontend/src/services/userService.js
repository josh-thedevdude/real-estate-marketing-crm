import api from './api';

const userService = {
  getAll: async (includeDeleted = false) => {
    const params = includeDeleted ? { include_deleted: 'true' } : {};
    const response = await api.get('/users', { params });
    return response.data.users || [];
  },

  getById: async (id) => {
    const response = await api.get(`/users/${id}`);
    return response.data.user;
  },

  create: async (data) => {
    const response = await api.post('/users', { user: data });
    return response.data.user;
  },

  update: async (id, data) => {
    const response = await api.put(`/users/${id}`, { user: data });
    return response.data.user;
  },

  delete: async (id) => {
    const response = await api.delete(`/users/${id}`);
    return response.data;
  },

  acceptInvitation: async (data) => {
    const response = await api.post('/users/accept_invitation', data);
    return response.data;
  },
};

export default userService;
