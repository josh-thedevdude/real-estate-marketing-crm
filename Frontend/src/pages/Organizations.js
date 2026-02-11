import React, { useState, useEffect } from 'react';
import organizationService from '../services/organizationService';
import Card from '../components/Card';
import Button from '../components/Button';
import Table from '../components/Table';
import Modal from '../components/Modal';
import ConfirmModal from '../components/ConfirmModal';
import Input from '../components/Input';
import { formatDate } from '../utils/helpers';
import './Organizations.css';

const Organizations = () => {
  const [organizations, setOrganizations] = useState([]);
  const [loading, setLoading] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isViewModalOpen, setIsViewModalOpen] = useState(false);
  const [editingOrg, setEditingOrg] = useState(null);
  const [viewingOrg, setViewingOrg] = useState(null);
  const [formData, setFormData] = useState({ name: '' });
  const [error, setError] = useState('');
  const [showDeleted, setShowDeleted] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterStatus, setFilterStatus] = useState('');
  const [confirmModal, setConfirmModal] = useState({
    isOpen: false,
    title: '',
    message: '',
    onConfirm: null,
    variant: 'primary',
  });

  useEffect(() => {
    fetchOrganizations();
  }, [showDeleted]);

  const fetchOrganizations = async () => {
    setLoading(true);
    try {
      const data = await organizationService.getAll(showDeleted);
      setOrganizations(data);
    } catch (err) {
      console.error('Error fetching organizations:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleAdd = () => {
    setEditingOrg(null);
    setFormData({ name: '' });
    setError('');
    setIsModalOpen(true);
  };

  const handleEdit = (org) => {
    setEditingOrg(org);
    setFormData({ name: org.name });
    setError('');
    setIsModalOpen(true);
  };

  const handleView = async (org) => {
    try {
      const data = await organizationService.getById(org.id);
      setViewingOrg(data);
      setIsViewModalOpen(true);
    } catch (err) {
      setError('Error fetching organization details');
    }
  };

  const handleDelete = (org) => {
    setConfirmModal({
      isOpen: true,
      title: 'Delete Organization',
      message: `Are you sure you want to delete "${org.name}"? This action cannot be undone.`,
      onConfirm: async () => {
        try {
          await organizationService.delete(org.id);
          fetchOrganizations();
        } catch (err) {
          setError('Error deleting organization');
        }
      },
      variant: 'danger',
      confirmText: 'Delete',
    });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    const action = editingOrg ? 'update' : 'create';
    const actionText = editingOrg ? 'Update' : 'Create';
    
    setConfirmModal({
      isOpen: true,
      title: `${actionText} Organization`,
      message: `Are you sure you want to ${action} this organization?`,
      onConfirm: async () => {
        setError('');
        try {
          if (editingOrg) {
            await organizationService.update(editingOrg.id, formData);
          } else {
            await organizationService.create(formData);
          }
          setIsModalOpen(false);
          fetchOrganizations();
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
    {
      key: 'users_count',
      label: 'Users',
      render: (value) => value || 0,
    },
    {
      key: 'contacts_count',
      label: 'Contacts',
      render: (value) => value || 0,
    },
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
    render: (_, org) => (
      <button 
        className="btn-action btn-action-view"
        onClick={() => handleView(org)}
        disabled={!!org.deleted_at}
        style={{
          opacity: org.deleted_at ? 0.5 : 1,
          cursor: org.deleted_at ? 'not-allowed' : 'pointer'
        }}
      >
        View Details
      </button>
    ),
  };

  const displayColumns = [...columns, actionColumn];

  // Wrapper functions to prevent actions on deleted organizations
  const handleEditWrapper = (org) => {
    if (org.deleted_at) return;
    handleEdit(org);
  };

  const handleDeleteWrapper = (org) => {
    if (org.deleted_at) return;
    handleDelete(org);
  };

  // Filter and search logic
  const filteredOrganizations = organizations.filter(org => {
    // Search filter (name)
    const matchesSearch = org.name?.toLowerCase().includes(searchTerm.toLowerCase());
    
    // Status filter (deleted or active)
    const matchesStatus = !filterStatus || 
      (filterStatus === 'active' && !org.deleted_at) ||
      (filterStatus === 'deleted' && org.deleted_at);
    
    return matchesSearch && matchesStatus;
  });

  return (
    <div>
      <h1 className="page-title">Organizations</h1>
      
      {/* Filters and Search Section */}
      <Card style={{ marginBottom: '1.5rem', padding: '1.25rem' }}>
        <div className="filters-row">
          {/* Search Bar */}
          <div>
            <label style={{ display: 'block', marginBottom: '0.5rem', fontSize: '0.875rem', fontWeight: '500' }}>
              Search by Name
            </label>
            <input
              type="text"
              placeholder="Search organization..."
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

          {/* Status Filter */}
          <div>
            <label style={{ display: 'block', marginBottom: '0.5rem', fontSize: '0.875rem', fontWeight: '500' }}>
              Filter by Status
            </label>
            <select
              value={filterStatus}
              onChange={(e) => setFilterStatus(e.target.value)}
              style={{
                width: '100%',
                padding: '0.5rem',
                border: '1px solid #d1d5db',
                borderRadius: '6px',
                fontSize: '0.875rem',
                backgroundColor: 'white'
              }}
            >
              <option value="">All Statuses</option>
              <option value="active">Active</option>
              <option value="deleted">Deleted</option>
            </select>
          </div>
        </div>

        {/* Clear Filters Button */}
        {(searchTerm || filterStatus) && (
          <Button
            onClick={() => {
              setSearchTerm('');
              setFilterStatus('');
            }}
            variant="secondary"
            style={{ marginTop: '1rem' }}
          >
            Clear Filters
          </Button>
        )}
      </Card>
      
      {/* Actions Section */}
      <div className="action-bar">
        <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', cursor: 'pointer' }}>
          <input
            type="checkbox"
            checked={showDeleted}
            onChange={(e) => setShowDeleted(e.target.checked)}
            style={{ cursor: 'pointer' }}
          />
          <span>Include Deleted Organizations</span>
        </label>
        
        <Button onClick={handleAdd} variant="primary">
          Create Organization
        </Button>
      </div>

      <Card>
        <Table
          columns={displayColumns}
          data={filteredOrganizations}
          loading={loading}
          onEdit={handleEditWrapper}
          onDelete={handleDeleteWrapper}
        />
      </Card>

      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title={editingOrg ? 'Edit Organization' : 'Add Organization'}
      >
        <form onSubmit={handleSubmit}>
          {error && <div className="error-alert">{error}</div>}
          <Input
            label="Organization Name"
            name="name"
            value={formData.name}
            onChange={(e) => setFormData({ name: e.target.value })}
            required
            minLength={3}
            maxLength={50}
            placeholder="Minimum 3 characters"
          />
          <div className="modal-actions">
            <Button type="button" variant="secondary" onClick={() => setIsModalOpen(false)}>
              Cancel
            </Button>
            <Button type="submit" variant="primary">
              {editingOrg ? 'Update' : 'Create'}
            </Button>
          </div>
        </form>
      </Modal>

      <Modal
        isOpen={isViewModalOpen}
        onClose={() => setIsViewModalOpen(false)}
        title="Organization Details"
        size="medium"
      >
        {viewingOrg && (
          <div style={{ padding: '1rem' }}>
            <div style={{ marginBottom: '1rem' }}>
              <strong>ID:</strong> {viewingOrg.id}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Name:</strong> {viewingOrg.name}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Users Count:</strong> {viewingOrg.users_count || 0}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Contacts Count:</strong> {viewingOrg.contacts_count || 0}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Audiences Count:</strong> {viewingOrg.audiences_count || 0}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Campaigns Count:</strong> {viewingOrg.campaigns_count || 0}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Created At:</strong> {formatDate(viewingOrg.created_at)}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Updated At:</strong> {formatDate(viewingOrg.updated_at)}
            </div>
            {viewingOrg.deleted_at && (
              <div style={{ marginBottom: '1rem' }}>
                <strong>Deleted At:</strong> {formatDate(viewingOrg.deleted_at)}
              </div>
            )}
            <div style={{ marginBottom: '1rem' }}>
              <strong>Status:</strong>{' '}
              {viewingOrg.deleted_at ? (
                <span className="badge badge-danger">Deleted</span>
              ) : (
                <span className="badge badge-success">Active</span>
              )}
            </div>
          </div>
        )}
        <div style={{ padding: '0 1rem 1rem', display: 'flex', justifyContent: 'flex-end' }}>
          <Button variant="secondary" onClick={() => setIsViewModalOpen(false)}>
            Close
          </Button>
        </div>
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

export default Organizations;
