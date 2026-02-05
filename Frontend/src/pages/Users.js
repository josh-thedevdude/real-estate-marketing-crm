import React, { useState, useEffect } from 'react';
import userService from '../services/userService';
import organizationService from '../services/organizationService';
import Card from '../components/Card';
import Button from '../components/Button';
import Table from '../components/Table';
import Modal from '../components/Modal';
import ConfirmModal from '../components/ConfirmModal';
import Input from '../components/Input';
import Select from '../components/Select';
import { useSelector } from 'react-redux';
import { isSuperAdmin } from '../utils/permissions';
import { formatDate, capitalizeFirst, getRoleBadgeClass, getStatusBadgeClass } from '../utils/helpers';

const Users = () => {
  const { user: currentUser } = useSelector((state) => state.auth);
  const [users, setUsers] = useState([]);
  const [organizations, setOrganizations] = useState([]);
  const [loading, setLoading] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isViewModalOpen, setIsViewModalOpen] = useState(false);
  const [editingUser, setEditingUser] = useState(null);
  const [viewingUser, setViewingUser] = useState(null);
  const [showDeleted, setShowDeleted] = useState(false);
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    role: 'org_user',
    status: 'active',
    organization_id: '',
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
    fetchUsers();
    if (isSuperAdmin(currentUser)) {
      fetchOrganizations();
    }
  }, [currentUser, showDeleted]);

  const fetchUsers = async () => {
    setLoading(true);
    try {
      const data = await userService.getAll(showDeleted);
      setUsers(data);
    } catch (err) {
      console.error('Error fetching users:', err);
    } finally {
      setLoading(false);
    }
  };

  const fetchOrganizations = async () => {
    try {
      const data = await organizationService.getAll();
      setOrganizations(data);
    } catch (err) {
      console.error('Error fetching organizations:', err);
    }
  };

  const handleAdd = () => {
    setEditingUser(null);
    setFormData({
      email: '',
      role: 'org_user',
      organization_id: '',
    });
    setError('');
    setIsModalOpen(true);
  };

  const handleEdit = (user) => {
    setEditingUser(user);
    setFormData({
      email: user.email,
      role: user.role,
      status: user.status,
      organization_id: user.organization_id || '',
    });
    setError('');
    setIsModalOpen(true);
  };

  const handleView = async (user) => {
    try {
      const data = await userService.getById(user.id);
      setViewingUser(data);
      setIsViewModalOpen(true);
    } catch (err) {
      setError('Error fetching user details');
    }
  };

  const handleDelete = (user) => {
    setConfirmModal({
      isOpen: true,
      title: 'Delete User',
      message: `Are you sure you want to delete "${user.email}"? This action cannot be undone.`,
      onConfirm: async () => {
        try {
          await userService.delete(user.id);
          fetchUsers();
        } catch (err) {
          setError('Error deleting user');
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
    const action = editingUser ? 'update' : 'invite';
    const actionText = editingUser ? 'Update' : 'Invite';
    
    setConfirmModal({
      isOpen: true,
      title: `${actionText} User`,
      message: editingUser 
        ? `Are you sure you want to ${action} this user?`
        : `Are you sure you want to send an invitation to ${formData.email}?`,
      onConfirm: async () => {
        setError('');
        try {
          const submitData = { ...formData };
          if (editingUser) {
            await userService.update(editingUser.id, submitData);
          } else {
            // Only send email, role, organization_id for creation
            await userService.create({
              email: submitData.email,
              role: submitData.role,
              organization_id: submitData.organization_id
            });
          }
          setIsModalOpen(false);
          fetchUsers();
        } catch (err) {
          setError(err.response?.data?.error || 'An error occurred');
        }
      },
      variant: 'primary',
      confirmText: actionText,
    });
  };

  const roleOptions = [
    { value: 'super_admin', label: 'Super Admin' },
    { value: 'org_admin', label: 'Organization Admin' },
    { value: 'org_user', label: 'Organization User' },
  ];

  const statusOptions = [
    { value: 'active', label: 'Active' },
    { value: 'inactive', label: 'Inactive' },
  ];

  const organizationOptions = organizations.map((org) => ({
    value: org.id,
    label: org.name,
  }));

  const getRoleBadge = (role) => {
    const roleMap = {
      super_admin: { class: 'badge-danger', text: 'Super Admin' },
      org_admin: { class: 'badge-warning', text: 'Org Admin' },
      org_user: { class: 'badge-info', text: 'Org User' },
    };
    const config = roleMap[role] || { class: 'badge-secondary', text: role };
    return <span className={`badge ${config.class}`}>{config.text}</span>;
  };

  const getStatusBadge = (status) => {
    return status === 'active' ? (
      <span className="badge badge-success">Active</span>
    ) : (
      <span className="badge badge-inactive">Inactive</span>
    );
  };

  const columns = [
    { key: 'id', label: 'ID' },
    { key: 'email', label: 'Email' },
    {
      key: 'role',
      label: 'Role',
      render: (value) => getRoleBadge(value),
    },
    {
      key: 'status',
      label: 'Status',
      render: (value) => getStatusBadge(value),
    },
    {
      key: 'organization_name',
      label: 'Organization',
      render: (value) => value || '-',
    },
    {
      key: 'created_at',
      label: 'Created At',
      render: (value) => formatDate(value),
    },
    {
      key: 'deleted_at',
      label: 'Account Status',
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
    render: (_, user) => (
      <button 
        className="btn-action btn-action-view"
        onClick={() => handleView(user)}
        disabled={!!user.deleted_at}
        style={{ 
          opacity: user.deleted_at ? 0.5 : 1,
          cursor: user.deleted_at ? 'not-allowed' : 'pointer'
        }}
      >
        View
      </button>
    ),
  };

  const displayColumns = [...columns, actionColumn];

  const handleEditWrapper = (user) => {
    if (user.deleted_at) return;
    handleEdit(user);
  };

  const handleDeleteWrapper = (user) => {
    if (user.deleted_at) return;
    handleDelete(user);
  };

  return (
    <div>
      <h1 className="page-title">Users</h1>
      
      <div style={{ marginBottom: '1rem', display: 'flex', gap: '1rem', alignItems: 'center', justifyContent: 'space-between' }}>
        <label style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', cursor: 'pointer' }}>
          <input
            type="checkbox"
            checked={showDeleted}
            onChange={(e) => setShowDeleted(e.target.checked)}
            style={{ cursor: 'pointer' }}
          />
          <span>Include Deleted Users</span>
        </label>
        
        <div style={{ display: 'flex', gap: '0.5rem' }}>
          {isSuperAdmin(currentUser) && (
            <Button 
              onClick={() => {
                setFormData({ ...formData, role: 'org_admin' });
                handleAdd();
              }} 
              variant="warning"
              style={{ backgroundColor: '#f59e0b' }}
            >
              Invite Org Admin
            </Button>
          )}
          <Button 
            onClick={() => {
              setFormData({ ...formData, role: 'org_user' });
              handleAdd();
            }} 
            variant="primary"
          >
            Invite Org User
          </Button>
        </div>
      </div>

      <Card>
        <Table
          columns={displayColumns}
          data={users}
          loading={loading}
          onEdit={handleEditWrapper}
          onDelete={handleDeleteWrapper}
        />
      </Card>

      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title={editingUser ? 'Edit User' : 'Invite User'}
        size="medium"
      >
        <form onSubmit={handleSubmit}>
          {error && <div className="error-alert">{error}</div>}
          
          {!editingUser && (
            <div style={{ padding: '1rem', backgroundColor: '#dbeafe', borderRadius: '6px', marginBottom: '1rem' }}>
              <p style={{ margin: 0, fontSize: '0.875rem', color: '#1e40af' }}>
                ℹ️ An invitation email will be sent to the user. They will set their password when accepting the invitation.
              </p>
            </div>
          )}
          
          <Input
            label="Email"
            type="email"
            name="email"
            value={formData.email}
            onChange={handleChange}
            required
            disabled={editingUser}
          />
          <Select
            label="Role"
            name="role"
            value={formData.role}
            onChange={handleChange}
            options={roleOptions}
            required
          />
          {editingUser && (
            <Select
              label="Status"
              name="status"
              value={formData.status}
              onChange={handleChange}
              options={statusOptions}
              required
            />
          )}
          {isSuperAdmin(currentUser) && (
            <Select
              label="Organization"
              name="organization_id"
              value={formData.organization_id}
              onChange={handleChange}
              options={organizationOptions}
              placeholder="Select organization (optional)"
            />
          )}
          <div className="modal-actions">
            <Button type="button" variant="secondary" onClick={() => setIsModalOpen(false)}>
              Cancel
            </Button>
            <Button type="submit" variant="primary">
              {editingUser ? 'Update' : 'Send Invitation'}
            </Button>
          </div>
        </form>
      </Modal>

      <Modal
        isOpen={isViewModalOpen}
        onClose={() => setIsViewModalOpen(false)}
        title="User Details"
        size="medium"
      >
        {viewingUser && (
          <div style={{ padding: '1rem' }}>
            <div style={{ marginBottom: '1rem' }}>
              <strong>ID:</strong> {viewingUser.id}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Email:</strong> {viewingUser.email}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Role:</strong> {getRoleBadge(viewingUser.role)}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Status:</strong> {getStatusBadge(viewingUser.status)}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Organization:</strong> {viewingUser.organization_name || 'N/A'}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Invitation Status:</strong>{' '}
              {viewingUser.invitation_accepted_at ? (
                <span className="badge badge-success">Accepted</span>
              ) : viewingUser.invitation_token ? (
                <span className="badge badge-warning">Pending</span>
              ) : (
                <span className="badge badge-secondary">N/A</span>
              )}
            </div>
            {viewingUser.invitation_sent_at && (
              <div style={{ marginBottom: '1rem' }}>
                <strong>Invitation Sent:</strong> {formatDate(viewingUser.invitation_sent_at)}
              </div>
            )}
            {viewingUser.invitation_accepted_at && (
              <div style={{ marginBottom: '1rem' }}>
                <strong>Invitation Accepted:</strong> {formatDate(viewingUser.invitation_accepted_at)}
              </div>
            )}
            <div style={{ marginBottom: '1rem' }}>
              <strong>Created At:</strong> {formatDate(viewingUser.created_at)}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Updated At:</strong> {formatDate(viewingUser.updated_at)}
            </div>
            {viewingUser.deleted_at && (
              <div style={{ marginBottom: '1rem' }}>
                <strong>Deleted At:</strong> {formatDate(viewingUser.deleted_at)}
              </div>
            )}
            <div style={{ marginBottom: '1rem' }}>
              <strong>Account Status:</strong>{' '}
              {viewingUser.deleted_at ? (
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

export default Users;
