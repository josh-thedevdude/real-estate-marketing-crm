import React, { useState, useEffect } from 'react';
import contactService from '../services/contactService';
import Card from '../components/Card';
import Button from '../components/Button';
import Table from '../components/Table';
import Modal from '../components/Modal';
import ConfirmModal from '../components/ConfirmModal';
import Input from '../components/Input';
import { formatDate } from '../utils/helpers';

const Contacts = () => {
  const [contacts, setContacts] = useState([]);
  const [loading, setLoading] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isViewModalOpen, setIsViewModalOpen] = useState(false);
  const [editingContact, setEditingContact] = useState(null);
  const [viewingContact, setViewingContact] = useState(null);
  const [showDeleted, setShowDeleted] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [formData, setFormData] = useState({
    first_name: '',
    last_name: '',
    email: '',
    phone: '',
  });
  const [error, setError] = useState('');
  const [importFile, setImportFile] = useState(null);
  const [confirmModal, setConfirmModal] = useState({
    isOpen: false,
    title: '',
    message: '',
    onConfirm: null,
    variant: 'primary',
  });

  useEffect(() => {
    fetchContacts();
  }, []);

  const fetchContacts = async () => {
    setLoading(true);
    try {
      const data = await contactService.getAll();
      setContacts(data);
    } catch (err) {
      console.error('Error fetching contacts:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleView = async (contact) => {
    try {
      const data = await contactService.getById(contact.id);
      setViewingContact(data);
      setIsViewModalOpen(true);
    } catch (err) {
      setError('Error fetching contact details');
    }
  };

  const handleAdd = () => {
    setEditingContact(null);
    setFormData({ first_name: '', last_name: '', email: '', phone: '' });
    setError('');
    setIsModalOpen(true);
  };

  const handleEdit = (contact) => {
    setEditingContact(contact);
    setFormData({
      first_name: contact.first_name || '',
      last_name: contact.last_name || '',
      email: contact.email,
      phone: contact.phone || '',
    });
    setError('');
    setIsModalOpen(true);
  };

  const handleDelete = (contact) => {
    setConfirmModal({
      isOpen: true,
      title: 'Delete Contact',
      message: `Are you sure you want to delete "${contact.email}"? This action cannot be undone.`,
      onConfirm: async () => {
        try {
          await contactService.delete(contact.id);
          fetchContacts();
        } catch (err) {
          setError('Error deleting contact');
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
    const action = editingContact ? 'update' : 'create';
    const actionText = editingContact ? 'Update' : 'Create';
    
    setConfirmModal({
      isOpen: true,
      title: `${actionText} Contact`,
      message: `Are you sure you want to ${action} this contact?`,
      onConfirm: async () => {
        setError('');
        try {
          if (editingContact) {
            await contactService.update(editingContact.id, formData);
          } else {
            await contactService.create(formData);
          }
          setIsModalOpen(false);
          fetchContacts();
        } catch (err) {
          setError(err.response?.data?.error || 'An error occurred');
        }
      },
      variant: 'primary',
      confirmText: actionText,
    });
  };

  const handleImport = (e) => {
    e.preventDefault();
    if (!importFile) {
      setError('Please select a CSV file');
      return;
    }
    
    setConfirmModal({
      isOpen: true,
      title: 'Import Contacts',
      message: `Are you sure you want to import contacts from "${importFile.name}"? This will add new contacts to your database.`,
      onConfirm: async () => {
        try {
          await contactService.import(importFile);
          setError('');
          alert('Import started successfully');
          setImportFile(null);
          fetchContacts();
        } catch (err) {
          setError(err.response?.data?.error || 'Import failed');
        }
      },
      variant: 'warning',
      confirmText: 'Import',
    });
  };

  const columns = [
    { key: 'id', label: 'ID' },
    { key: 'first_name', label: 'First Name' },
    { key: 'last_name', label: 'Last Name' },
    { key: 'email', label: 'Email' },
    { key: 'phone', label: 'Phone' },
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
    render: (_, contact) => (
      <button 
        className="btn-action btn-action-view"
        onClick={() => handleView(contact)}
        disabled={!!contact.deleted_at}
        style={{
          opacity: contact.deleted_at ? 0.5 : 1,
          cursor: contact.deleted_at ? 'not-allowed' : 'pointer'
        }}
      >
        View Details
      </button>
    ),
  };

  const displayColumns = [...columns, actionColumn];

  // Wrapper functions to prevent actions on deleted contacts
  const handleEditWrapper = (contact) => {
    if (contact.deleted_at) return;
    handleEdit(contact);
  };

  const handleDeleteWrapper = (contact) => {
    if (contact.deleted_at) return;
    handleDelete(contact);
  };

  // Filter and search logic
  const filteredContacts = contacts.filter(contact => {
    // Show deleted filter
    if (!showDeleted && contact.deleted_at) return false;
    
    // Search filter (first name, last name, email)
    const searchLower = searchTerm.toLowerCase();
    const matchesSearch = 
      contact.first_name?.toLowerCase().includes(searchLower) ||
      contact.last_name?.toLowerCase().includes(searchLower) ||
      contact.email?.toLowerCase().includes(searchLower);
    
    return matchesSearch;
  });

  return (
    <div>
      <h1 className="page-title">Contacts</h1>
      
      {/* Filters and Search Section */}
      <Card style={{ marginBottom: '1.5rem', padding: '1.25rem' }}>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr', gap: '1rem' }}>
          {/* Search Bar */}
          <div>
            <label style={{ display: 'block', marginBottom: '0.5rem', fontSize: '0.875rem', fontWeight: '500' }}>
              Search Contacts
            </label>
            <input
              type="text"
              placeholder="Search by name or email..."
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
          <span>Include Deleted Contacts</span>
        </label>
        
        <div style={{ display: 'flex', gap: '0.5rem', flexWrap: 'wrap' }}>
          <label className="btn btn-secondary btn-medium" style={{ cursor: 'pointer', margin: 0 }}>
            Import CSV
            <input
              type="file"
              accept=".csv"
              onChange={(e) => setImportFile(e.target.files[0])}
              style={{ display: 'none' }}
            />
          </label>
          {importFile && (
            <Button onClick={handleImport} variant="success">
              Upload {importFile.name}
            </Button>
          )}
          <Button onClick={handleAdd} variant="primary">
            Add Contact
          </Button>
        </div>
      </div>

      <Card>
        <Table
          columns={displayColumns}
          data={filteredContacts}
          loading={loading}
          onEdit={handleEditWrapper}
          onDelete={handleDeleteWrapper}
        />
      </Card>

      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title={editingContact ? 'Edit Contact' : 'Add Contact'}
      >
        <form onSubmit={handleSubmit}>
          {error && <div className="error-alert">{error}</div>}
          <Input
            label="First Name"
            name="first_name"
            value={formData.first_name}
            onChange={handleChange}
          />
          <Input
            label="Last Name"
            name="last_name"
            value={formData.last_name}
            onChange={handleChange}
          />
          <Input
            label="Email"
            type="email"
            name="email"
            value={formData.email}
            onChange={handleChange}
            required
          />
          <Input
            label="Phone"
            name="phone"
            value={formData.phone}
            onChange={handleChange}
          />
          <div className="modal-actions">
            <Button type="button" variant="secondary" onClick={() => setIsModalOpen(false)}>
              Cancel
            </Button>
            <Button type="submit" variant="primary">
              {editingContact ? 'Update' : 'Create'}
            </Button>
          </div>
        </form>
      </Modal>

      <Modal
        isOpen={isViewModalOpen}
        onClose={() => setIsViewModalOpen(false)}
        title="Contact Details"
        size="medium"
      >
        {viewingContact && (
          <div style={{ padding: '1rem' }}>
            <div style={{ marginBottom: '1rem' }}>
              <strong>ID:</strong> {viewingContact.id}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>First Name:</strong> {viewingContact.first_name || '-'}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Last Name:</strong> {viewingContact.last_name || '-'}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Full Name:</strong> {viewingContact.full_name || '-'}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Email:</strong> {viewingContact.email}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Phone:</strong> {viewingContact.phone || '-'}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Created At:</strong> {formatDate(viewingContact.created_at)}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Updated At:</strong> {formatDate(viewingContact.updated_at)}
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

export default Contacts;
