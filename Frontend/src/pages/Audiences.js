import React, { useState, useEffect } from 'react';
import audienceService from '../services/audienceService';
import Card from '../components/Card';
import Button from '../components/Button';
import Table from '../components/Table';
import Modal from '../components/Modal';
import ConfirmModal from '../components/ConfirmModal';
import Input from '../components/Input';
import { formatDate } from '../utils/helpers';

const Audiences = () => {
  const [audiences, setAudiences] = useState([]);
  const [loading, setLoading] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingAudience, setEditingAudience] = useState(null);
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    filters: {},
  });
  const [error, setError] = useState('');
  const [confirmModal, setConfirmModal] = useState({
    isOpen: false,
    title: '',
    message: '',
    onConfirm: null,
    variant: 'primary',
  });

  useEffect(() => {
    fetchAudiences();
  }, []);

  const fetchAudiences = async () => {
    setLoading(true);
    try {
      const data = await audienceService.getAll();
      setAudiences(data);
    } catch (err) {
      console.error('Error fetching audiences:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleAdd = () => {
    setEditingAudience(null);
    setFormData({ name: '', description: '', filters: {} });
    setError('');
    setIsModalOpen(true);
  };

  const handleEdit = (audience) => {
    setEditingAudience(audience);
    setFormData({
      name: audience.name,
      description: audience.description || '',
      filters: audience.filters || {},
    });
    setError('');
    setIsModalOpen(true);
  };

  const handleDelete = (audience) => {
    setConfirmModal({
      isOpen: true,
      title: 'Delete Audience',
      message: `Are you sure you want to delete "${audience.name}"? This action cannot be undone.`,
      onConfirm: async () => {
        try {
          await audienceService.delete(audience.id);
          fetchAudiences();
        } catch (err) {
          setError('Error deleting audience');
        }
      },
      variant: 'danger',
      confirmText: 'Delete',
    });
  };

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    const action = editingAudience ? 'update' : 'create';
    const actionText = editingAudience ? 'Update' : 'Create';
    
    setConfirmModal({
      isOpen: true,
      title: `${actionText} Audience`,
      message: `Are you sure you want to ${action} this audience?`,
      onConfirm: async () => {
        setError('');
        try {
          if (editingAudience) {
            await audienceService.update(editingAudience.id, formData);
          } else {
            await audienceService.create(formData);
          }
          setIsModalOpen(false);
          fetchAudiences();
        } catch (err) {
          setError(err.response?.data?.error || 'An error occurred');
        }
      },
      variant: 'primary',
      confirmText: actionText,
    });
  };

  const columns = [
    { key: 'id', label: 'ID' },
    { key: 'name', label: 'Name' },
    { key: 'description', label: 'Description' },
    {
      key: 'created_at',
      label: 'Created At',
      render: (value) => formatDate(value),
    },
  ];

  return (
    <div>
      <h1 className="page-title">Audiences</h1>
      <Card
        actions={
          <Button onClick={handleAdd} variant="primary">
            Create Audience
          </Button>
        }
      >
        <Table
          columns={columns}
          data={audiences}
          loading={loading}
          onEdit={handleEdit}
          onDelete={handleDelete}
        />
      </Card>

      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title={editingAudience ? 'Edit Audience' : 'Create Audience'}
      >
        <form onSubmit={handleSubmit}>
          {error && <div className="error-alert">{error}</div>}
          <Input
            label="Audience Name"
            name="name"
            value={formData.name}
            onChange={handleChange}
            required
          />
          <div className="input-group">
            <label className="input-label">Description</label>
            <textarea
              name="description"
              value={formData.description}
              onChange={handleChange}
              className="input-field"
              rows="3"
            />
          </div>
          <div className="modal-actions">
            <Button type="button" variant="secondary" onClick={() => setIsModalOpen(false)}>
              Cancel
            </Button>
            <Button type="submit" variant="primary">
              {editingAudience ? 'Update' : 'Create'}
            </Button>
          </div>
        </form>
      </Modal>

      <ConfirmModal
        isOpen={confirmModal.isOpen}
        onClose={() => setConfirmModal({ ...confirmModal, isOpen: false })}
        onConfirm={confirmModal.onConfirm}
        title={confirmModal.title}
        message={confirmModal.message}
        variant={confirmModal.variant}
        confirmText={confirmModal.confirmText}
      />
    </div>
  );
};

export default Audiences;
