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
  const [editingContact, setEditingContact] = useState(null);
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
  ];

  return (
    <div>
      <h1 className="page-title">Contacts</h1>
      <Card
        actions={
          <div style={{ display: 'flex', gap: '0.5rem' }}>
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
                Upload
              </Button>
            )}
            <Button onClick={handleAdd} variant="primary">
              Add Contact
            </Button>
          </div>
        }
      >
        <Table
          columns={columns}
          data={contacts}
          loading={loading}
          onEdit={handleEdit}
          onDelete={handleDelete}
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
