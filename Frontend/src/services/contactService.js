import api from './api';

const contactService = {
  getAll: async () => {
    const response = await api.get('/contacts');
    return response.data.contacts || [];
  },

  getById: async (id) => {
    const response = await api.get(`/contacts/${id}`);
    return response.data.contact;
  },

  create: async (data) => {
    const response = await api.post('/contacts', { contact: data });
    return response.data.contact;
  },

  update: async (id, data) => {
    const response = await api.put(`/contacts/${id}`, { contact: data });
    return response.data.contact;
  },

  delete: async (id) => {
    const response = await api.delete(`/contacts/${id}`);
    return response.data;
  },

  import: async (file) => {
    const formData = new FormData();
    formData.append('file', file);
    const response = await api.post('/contacts/import', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  },
};

export default contactService;
