import React, { useState, useEffect } from 'react';
import audienceService from '../services/audienceService';
import contactService from '../services/contactService';
import Card from '../components/Card';
import Button from '../components/Button';
import Table from '../components/Table';
import Modal from '../components/Modal';
import ConfirmModal from '../components/ConfirmModal';
import Input from '../components/Input';
import { formatDate } from '../utils/helpers';

const Audiences = () => {
  const [audiences, setAudiences] = useState([]);
  const [contacts, setContacts] = useState([]);
  const [loading, setLoading] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isViewModalOpen, setIsViewModalOpen] = useState(false);
  const [editingAudience, setEditingAudience] = useState(null);
  const [viewingAudience, setViewingAudience] = useState(null);
  const [showDeleted, setShowDeleted] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    filters: {},
    contact_ids: [],
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
    fetchContacts();
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

  const fetchContacts = async () => {
    try {
      const data = await contactService.getAll();
      setContacts(data.filter(c => !c.deleted_at));
    } catch (err) {
      console.error('Error fetching contacts:', err);
    }
  };

  const handleView = async (audience) => {
    try {
      const data = await audienceService.getById(audience.id);
      setViewingAudience(data);
      setIsViewModalOpen(true);
    } catch (err) {
      setError('Error fetching audience details');
    }
  };

  const handleAdd = () => {
    setEditingAudience(null);
    setFormData({ name: '', description: '', filters: {}, contact_ids: [] });
    setError('');
    setIsModalOpen(true);
  };

  const handleEdit = (audience) => {
    setEditingAudience(audience);
    setFormData({
      name: audience.name,
      description: audience.description || '',
      filters: audience.filters || {},
      contact_ids: audience.contact_ids || [],
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

  const handleContactChange = (e) => {
    const options = Array.from(e.target.selectedOptions);
    const values = options.map(option => parseInt(option.value));
    setFormData({ ...formData, contact_ids: values });
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
    {
      key: 'deleted_at',
      label: 'Status',
      render: (value) => (
        value ? (
          <span className="badge badge-danger">Deleted</span>
        ) : (
          <span className="badge badge-success">Active</span>
        )
      ),
    },
  ];

  const actionColumn = {
    key: 'view',
    label: 'View',
    render: (_, audience) => (
      <button 
        className="btn-action btn-action-view"
        onClick={() => handleView(audience)}
        disabled={!!audience.deleted_at}
        style={{
          opacity: audience.deleted_at ? 0.5 : 1,
          cursor: audience.deleted_at ? 'not-allowed' : 'pointer'
        }}
      >
        View Details
      </button>
    ),
  };

  const displayColumns = [...columns, actionColumn];

  // Wrapper functions to prevent actions on deleted audiences
  const handleEditWrapper = (audience) => {
    if (audience.deleted_at) return;
    handleEdit(audience);
  };

  const handleDeleteWrapper = (audience) => {
    if (audience.deleted_at) return;
    handleDelete(audience);
  };

  // Filter and search logic
  const filteredAudiences = audiences.filter(audience => {
    // Show deleted filter
    if (!showDeleted && audience.deleted_at) return false;
    
    // Search filter (name, description)
    const searchLower = searchTerm.toLowerCase();
    const matchesSearch = 
      audience.name?.toLowerCase().includes(searchLower) ||
      audience.description?.toLowerCase().includes(searchLower);
    
    return matchesSearch;
  });

  return (
    <div>
      <h1 className="page-title">Audiences</h1>
      
      {/* Filters and Search Section */}
      <Card style={{ marginBottom: '1.5rem', padding: '1.25rem' }}>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr', gap: '1rem' }}>
          {/* Search Bar */}
          <div>
            <label style={{ display: 'block', marginBottom: '0.5rem', fontSize: '0.875rem', fontWeight: '500' }}>
              Search Audiences
            </label>
            <input
              type="text"
              placeholder="Search by name or description..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              style={{
                width: '100%',
                padding: '0.5rem',
                border: '1px solid #d1d5db',
                borderRadius: '6px',
                fontSize: '0.875rem'
              }}
            />
          </div>
        </div>

        {/* Clear Filters Button */}
        {searchTerm && (
          <Button
            onClick={() => setSearchTerm('')}
            variant="secondary"
            style={{ marginTop: '1rem' }}
          >
            Clear Search
          </Button>
        )}
      </Card>
      
      {/* Actions Section */}
      <div style={{ marginTop: '2rem', marginBottom: '1.5rem', display: 'flex', gap: '1rem', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap' }}>
        <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', cursor: 'pointer' }}>
          <input
            type="checkbox"
            checked={showDeleted}
            onChange={(e) => setShowDeleted(e.target.checked)}
            style={{ cursor: 'pointer' }}
          />
          <span>Include Deleted Audiences</span>
        </label>
        
        <Button onClick={handleAdd} variant="primary">
          Create Audience
        </Button>
      </div>

      <Card>
        <Table
          columns={displayColumns}
          data={filteredAudiences}
          loading={loading}
          onEdit={handleEditWrapper}
          onDelete={handleDeleteWrapper}
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
            <label className="input-label">Description (minimum 10 characters if provided)</label>
            <textarea
              name="description"
              value={formData.description}
              onChange={handleChange}
              className="input-field"
              rows="3"
              minLength="10"
              maxLength="255"
              placeholder="Enter at least 10 characters..."
            />
            {formData.description && formData.description.length > 0 && formData.description.length < 10 && (
              <small style={{ color: '#dc2626', fontSize: '0.875rem' }}>
                Description must be at least 10 characters
              </small>
            )}
          </div>
          
          <div className="input-group">
            <label className="input-label">Select Contacts (Optional - Hold Ctrl/Cmd for multiple)</label>
            <select
              multiple
              value={formData.contact_ids}
              onChange={handleContactChange}
              className="input-field"
              style={{ minHeight: '150px' }}
            >
              {contacts.map((contact) => (
                <option key={contact.id} value={contact.id}>
                  {contact.first_name} {contact.last_name} ({contact.email})
                </option>
              ))}
            </select>
            <small style={{ color: '#6b7280', fontSize: '0.875rem', marginTop: '0.25rem', display: 'block' }}>
              Selected: {formData.contact_ids.length} contact(s). These contacts will be automatically included when you use this audience in campaigns.
            </small>
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

      <Modal
        isOpen={isViewModalOpen}
        onClose={() => setIsViewModalOpen(false)}
        title="Audience Details"
        size="medium"
      >
        {viewingAudience && (
          <div style={{ padding: '1rem' }}>
            <div style={{ marginBottom: '1rem' }}>
              <strong>ID:</strong> {viewingAudience.id}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Name:</strong> {viewingAudience.name}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Description:</strong> {viewingAudience.description || '-'}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Total Contacts:</strong> {viewingAudience.contacts?.length || 0}
            </div>
            {viewingAudience.contacts && viewingAudience.contacts.length > 0 && (
              <div style={{ marginBottom: '1rem' }}>
                <strong>Contacts:</strong>
                <ul style={{ marginTop: '0.5rem', paddingLeft: '1.5rem' }}>
                  {viewingAudience.contacts.map((contact) => (
                    <li key={contact.id}>
                      {contact.name} ({contact.email})
                    </li>
                  ))}
                </ul>
              </div>
            )}
            <div style={{ marginBottom: '1rem' }}>
              <strong>Filters:</strong>{' '}
              <pre style={{ 
                backgroundColor: '#f3f4f6', 
                padding: '0.5rem', 
                borderRadius: '4px',
                fontSize: '0.875rem',
                overflowX: 'auto'
              }}>
                {JSON.stringify(viewingAudience.filters, null, 2)}
              </pre>
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Created At:</strong> {formatDate(viewingAudience.created_at)}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Updated At:</strong> {formatDate(viewingAudience.updated_at)}
            </div>
          </div>
        )}
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
