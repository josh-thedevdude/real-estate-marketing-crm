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
    preferences: {
      contact_type: '',
      min_budget: '',
      max_budget: '',
      property_locations: [],
      property_types: [],
      timeline: ''
    }
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
    setFormData({ 
      first_name: '', 
      last_name: '', 
      email: '', 
      phone: '',
      preferences: {
        contact_type: '',
        min_budget: '',
        max_budget: '',
        property_locations: [],
        property_types: [],
        timeline: ''
      }
    });
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
      preferences: {
        contact_type: contact.preferences?.contact_type || '',
        min_budget: contact.preferences?.min_budget || '',
        max_budget: contact.preferences?.max_budget || '',
        property_locations: contact.preferences?.property_locations || [],
        property_types: contact.preferences?.property_types || [],
        timeline: contact.preferences?.timeline || ''
      }
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

  const handlePreferenceChange = (e) => {
    const { name, value } = e.target;
    setFormData({
      ...formData,
      preferences: {
        ...formData.preferences,
        [name]: value
      }
    });
  };

  const handleMultiSelectChange = (e, fieldName) => {
    const options = Array.from(e.target.selectedOptions);
    const values = options.map(option => option.value);
    setFormData({
      ...formData,
      preferences: {
        ...formData.preferences,
        [fieldName]: values
      }
    });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    
    // Validate budgets
    const minBudget = parseFloat(formData.preferences.min_budget);
    const maxBudget = parseFloat(formData.preferences.max_budget);
    
    if (formData.preferences.min_budget && minBudget <= 0) {
      setError('Min Budget must be greater than 0');
      return;
    }
    
    if (formData.preferences.max_budget && maxBudget <= 0) {
      setError('Max Budget must be greater than 0');
      return;
    }
    
    if (formData.preferences.min_budget && formData.preferences.max_budget && maxBudget <= minBudget) {
      setError('Max Budget must be greater than Min Budget');
      return;
    }
    
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
      <div className="action-bar">
        <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', cursor: 'pointer' }}>
          <input
            type="checkbox"
            checked={showDeleted}
            onChange={(e) => setShowDeleted(e.target.checked)}
            style={{ cursor: 'pointer' }}
          />
          <span>Include Deleted Contacts</span>
        </label>
        
        <div className="action-bar-right">
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
            minLength={3}
            maxLength={50}
            placeholder="Minimum 3 characters"
          />
          <Input
            label="Last Name"
            name="last_name"
            value={formData.last_name}
            onChange={handleChange}
            minLength={3}
            maxLength={50}
            placeholder="Minimum 3 characters"
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
            type="tel"
            value={formData.phone}
            onChange={handleChange}
            pattern="[0-9]{10}"
            minLength={10}
            maxLength={10}
            placeholder="10-digit mobile number"
          />

          <hr style={{ margin: '1.5rem 0', border: 'none', borderTop: '1px solid #e5e7eb' }} />
          <h3 style={{ marginBottom: '1rem', fontSize: '1.1rem', fontWeight: '600' }}>Contact Preferences</h3>

          <div className="input-group">
            <label className="input-label">Contact Type</label>
            <select
              name="contact_type"
              value={formData.preferences.contact_type}
              onChange={handlePreferenceChange}
              className="input-field"
            >
              <option value="">-- Select Type --</option>
              <option value="buyer">Buyer</option>
              <option value="seller">Seller</option>

            </select>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
            <Input
              label="Min Budget"
              type="number"
              name="min_budget"
              value={formData.preferences.min_budget}
              onChange={handlePreferenceChange}
              placeholder="e.g., 500000"
              min="1"
              step="1"
            />
            <Input
              label="Max Budget"
              type="number"
              name="max_budget"
              value={formData.preferences.max_budget}
              onChange={handlePreferenceChange}
              placeholder="e.g., 1000000"
              min="1"
              step="1"
            />
          </div>

          <div className="input-group">
            <label className="input-label">Property Locations (Hold Ctrl/Cmd for multiple)</label>
            <select
              multiple
              value={formData.preferences.property_locations}
              onChange={(e) => handleMultiSelectChange(e, 'property_locations')}
              className="input-field"
              style={{ minHeight: '150px' }}
            >
              <option value="baner">Baner</option>
              <option value="wakad">Wakad</option>
              <option value="hinjewadi">Hinjewadi</option>
              <option value="kharadi">Kharadi</option>
              <option value="hadapsar">Hadapsar</option>
              <option value="wagholi">Wagholi</option>
              <option value="kondhwa">Kondhwa</option>
              <option value="undri">Undri</option>
              <option value="ravet">Ravet</option>
              <option value="moshi">Moshi</option>
              <option value="pimpri">Pimpri</option>
              <option value="chinchwad">Chinchwad</option>
              <option value="akurdi">Akurdi</option>
            </select>
            <small style={{ color: '#6b7280', fontSize: '0.875rem', marginTop: '0.25rem', display: 'block' }}>
              Selected: {formData.preferences.property_locations.length} location(s)
            </small>
          </div>

          <div className="input-group">
            <label className="input-label">Property Types (Hold Ctrl/Cmd for multiple)</label>
            <select
              multiple
              value={formData.preferences.property_types}
              onChange={(e) => handleMultiSelectChange(e, 'property_types')}
              className="input-field"
              style={{ minHeight: '120px' }}
            >
              <option value="apartment">Apartment</option>
              <option value="villa">Villa</option>
              <option value="plot">Plot</option>
              <option value="commercial">Commercial</option>
              <option value="1bhk">1 BHK</option>
              <option value="2bhk">2 BHK</option>
              <option value="3bhk">3 BHK</option>
              <option value="4bhk">4 BHK</option>
            </select>
            <small style={{ color: '#6b7280', fontSize: '0.875rem', marginTop: '0.25rem', display: 'block' }}>
              Selected: {formData.preferences.property_types.length} type(s)
            </small>
          </div>

          <div className="input-group">
            <label className="input-label">Timeline</label>
            <select
              name="timeline"
              value={formData.preferences.timeline}
              onChange={handlePreferenceChange}
              className="input-field"
            >
              <option value="">-- Select Timeline --</option>
              <option value="immediate">Immediate</option>
              <option value="within_3_months">Within 3 Months</option>
              <option value="within_6_months">Within 6 Months</option>
              <option value="within_12_months">Within 12 Months</option>
            </select>
          </div>

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
            <hr style={{ margin: '1rem 0', border: 'none', borderTop: '1px solid #e5e7eb' }} />
            <h4 style={{ marginBottom: '0.75rem', fontWeight: '600' }}>Preferences</h4>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Contact Type:</strong> {viewingContact.preferences?.contact_type || '-'}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Budget Range:</strong> {
                viewingContact.preferences?.min_budget || viewingContact.preferences?.max_budget
                  ? `$${viewingContact.preferences?.min_budget || '0'} - $${viewingContact.preferences?.max_budget || 'No limit'}`
                  : '-'
              }
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Property Locations:</strong> {
                viewingContact.preferences?.property_locations?.length > 0
                  ? viewingContact.preferences.property_locations.join(', ')
                  : '-'
              }
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Property Types:</strong> {
                viewingContact.preferences?.property_types?.length > 0
                  ? viewingContact.preferences.property_types.join(', ')
                  : '-'
              }
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Timeline:</strong> {viewingContact.preferences?.timeline || '-'}
            </div>
            <hr style={{ margin: '1rem 0', border: 'none', borderTop: '1px solid #e5e7eb' }} />
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
