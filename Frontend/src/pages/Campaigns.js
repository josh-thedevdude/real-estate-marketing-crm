import React, { useState, useEffect } from 'react';
import campaignService from '../services/campaignService';
import audienceService from '../services/audienceService';
import Card from '../components/Card';
import Button from '../components/Button';
import Table from '../components/Table';
import Modal from '../components/Modal';
import ConfirmModal from '../components/ConfirmModal';
import Input from '../components/Input';
import Select from '../components/Select';
import { formatDate } from '../utils/helpers';

const Campaigns = () => {
  const [campaigns, setCampaigns] = useState([]);
  const [audiences, setAudiences] = useState([]);
  const [templates, setTemplates] = useState([]);
  const [loading, setLoading] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isViewModalOpen, setIsViewModalOpen] = useState(false);
  const [editingCampaign, setEditingCampaign] = useState(null);
  const [viewingCampaign, setViewingCampaign] = useState(null);
  const [showDeleted, setShowDeleted] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedTemplate, setSelectedTemplate] = useState('');
  const [formData, setFormData] = useState({
    name: '',
    subject: '',
    body: '',
    audience_ids: [],
    scheduled_at: '',
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
    fetchCampaigns();
    fetchAudiences();
    fetchTemplates();
  }, []);

  useEffect(() => {
    fetchCampaigns();
  }, [showDeleted]);

  const fetchCampaigns = async () => {
    setLoading(true);
    try {
      const data = await campaignService.getAll(showDeleted);
      setCampaigns(data);
    } catch (err) {
      console.error('Error fetching campaigns:', err);
    } finally {
      setLoading(false);
    }
  };

  const fetchAudiences = async () => {
    try {
      const data = await audienceService.getAll();
      setAudiences(data);
    } catch (err) {
      console.error('Error fetching audiences:', err);
    }
  };

  const fetchTemplates = async () => {
    try {
      const data = await campaignService.getTemplates();
      setTemplates(data);
    } catch (err) {
      console.error('Error fetching templates:', err);
      // Fallback to empty array if templates endpoint doesn't exist
      setTemplates([]);
    }
  };

  const handleView = async (campaign) => {
    try {
      const data = await campaignService.getById(campaign.id);
      setViewingCampaign(data);
      setIsViewModalOpen(true);
    } catch (err) {
      setError('Error fetching campaign details');
    }
  };

  const handleExecute = (campaign) => {
    setConfirmModal({
      isOpen: true,
      title: 'Execute Campaign',
      message: `Are you sure you want to execute "${campaign.name}"? Emails will be sent to all contacts in the selected audiences.`,
      onConfirm: async () => {
        try {
          await campaignService.execute(campaign.id);
          fetchCampaigns();
          alert('Campaign execution started successfully! Emails are being sent.');
        } catch (err) {
          const errorMessage = err.response?.data?.error || err.response?.data?.reasons?.join(', ') || 'Error executing campaign';
          alert(`Failed to execute campaign: ${errorMessage}`);
          setError(errorMessage);
        }
      },
      variant: 'warning',
      confirmText: 'Execute',
    });
  };

  const handleAdd = () => {
    setEditingCampaign(null);
    setSelectedTemplate('');
    setFormData({
      name: '',
      subject: '',
      body: '',
      audience_ids: [],
      scheduled_at: '',
    });
    setError('');
    setIsModalOpen(true);
  };

  const handleEdit = (campaign) => {
    setEditingCampaign(campaign);
    setSelectedTemplate('');
    setFormData({
      name: campaign.name || '',
      subject: campaign.subject || '',
      body: campaign.body || '',
      audience_ids: campaign.audience_ids || [],
      scheduled_at: campaign.scheduled_at ? new Date(campaign.scheduled_at).toISOString().slice(0, 16) : '',
    });
    setError('');
    setIsModalOpen(true);
  };

  const handleTemplateChange = (e) => {
    const templateId = e.target.value;
    setSelectedTemplate(templateId);
    
    if (templateId) {
      const template = templates.find(t => t.id === parseInt(templateId));
      if (template) {
        setFormData({
          ...formData,
          subject: template.subject || '',
          body: template.body || '',
        });
      }
    }
  };

  const handleDelete = (campaign) => {
    setConfirmModal({
      isOpen: true,
      title: 'Delete Campaign',
      message: `Are you sure you want to delete "${campaign.name}"? This action cannot be undone.`,
      onConfirm: async () => {
        try {
          await campaignService.delete(campaign.id);
          fetchCampaigns();
        } catch (err) {
          setError('Error deleting campaign');
        }
      },
      variant: 'danger',
      confirmText: 'Delete',
    });
  };

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleAudienceChange = (e) => {
    const options = Array.from(e.target.selectedOptions);
    const values = options.map(option => parseInt(option.value));
    setFormData({ ...formData, audience_ids: values });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    const action = editingCampaign ? 'update' : 'create';
    const actionText = editingCampaign ? 'Update' : 'Create';
    
    setConfirmModal({
      isOpen: true,
      title: `${actionText} Campaign`,
      message: `Are you sure you want to ${action} this campaign?`,
      onConfirm: async () => {
        setError('');
        try {
          if (editingCampaign) {
            await campaignService.update(editingCampaign.id, formData);
          } else {
            await campaignService.create(formData);
          }
          setIsModalOpen(false);
          fetchCampaigns();
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
    { key: 'subject', label: 'Subject' },
    {
      key: 'status',
      label: 'Status',
      render: (value) => {
        const statusColors = {
          draft: 'badge-secondary',
          scheduled: 'badge-warning',
          executing: 'badge-info',
          completed: 'badge-success',
          failed: 'badge-danger',
        };
        return (
          <span className={`badge ${statusColors[value] || 'badge-secondary'}`}>
            {value ? value.toUpperCase() : 'DRAFT'}
          </span>
        );
      },
    },
    {
      key: 'scheduled_at',
      label: 'Scheduled At',
      render: (value) => value ? formatDate(value) : '-',
    },
    {
      key: 'created_at',
      label: 'Created At',
      render: (value) => formatDate(value),
    },
    {
      key: 'deleted_at',
      label: 'Active Status',
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
    key: 'quick_actions',
    label: 'Quick Actions',
    render: (_, campaign) => (
      <div style={{ display: 'flex', gap: '0.5rem', justifyContent: 'center' }}>
        <button 
          className="btn-action btn-action-view"
          onClick={() => handleView(campaign)}
          disabled={!!campaign.deleted_at}
          style={{
            opacity: campaign.deleted_at ? 0.5 : 1,
            cursor: campaign.deleted_at ? 'not-allowed' : 'pointer',
            padding: '0.25rem 0.5rem',
            fontSize: '0.75rem',
          }}
          title="View campaign details"
        >
          View
        </button>
        <button 
          className="btn-action btn-action-success"
          onClick={() => handleExecute(campaign)}
          disabled={!!campaign.deleted_at || campaign.status !== 'created'}
          style={{
            opacity: (campaign.deleted_at || campaign.status !== 'created') ? 0.5 : 1,
            cursor: (campaign.deleted_at || campaign.status !== 'created') ? 'not-allowed' : 'pointer',
            padding: '0.25rem 0.5rem',
            fontSize: '0.75rem',
            backgroundColor: '#10b981',
          }}
          title={
            campaign.deleted_at 
              ? 'Cannot execute deleted campaign' 
              : campaign.status !== 'created' 
                ? `Campaign is ${campaign.status} - can only execute campaigns in created status` 
                : 'Send emails to all contacts in selected audiences immediately'
          }
        >
          Execute
        </button>
      </div>
    ),
  };

  const displayColumns = [...columns, actionColumn];

  // Wrapper functions to prevent actions on deleted campaigns
  const handleEditWrapper = (campaign) => {
    if (campaign.deleted_at) return;
    handleEdit(campaign);
  };

  const handleDeleteWrapper = (campaign) => {
    if (campaign.deleted_at) return;
    handleDelete(campaign);
  };

  // Filter and search logic (backend handles deleted filter via API param)
  const filteredCampaigns = campaigns.filter(campaign => {
    // Search filter
    const searchLower = searchTerm.toLowerCase();
    const matchesSearch = 
      campaign.name?.toLowerCase().includes(searchLower) ||
      campaign.subject?.toLowerCase().includes(searchLower);
    
    return matchesSearch;
  });

  const audienceOptions = audiences
    .filter(a => !a.deleted_at)
    .map((audience) => ({
      value: audience.id,
      label: audience.name,
    }));

  return (
    <div>
      <h1 className="page-title">Campaigns</h1>
      
      {/* Filters and Search Section */}
      <Card style={{ marginBottom: '1.5rem', padding: '1.25rem' }}>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr', gap: '1rem' }}>
          {/* Search Bar */}
          <div>
            <label style={{ display: 'block', marginBottom: '0.5rem', fontSize: '0.875rem', fontWeight: '500' }}>
              Search Campaigns
            </label>
            <input
              type="text"
              placeholder="Search by name or subject..."
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
          <span>Include Deleted Campaigns</span>
        </label>
        
        <Button onClick={handleAdd} variant="primary">
          Create Campaign
        </Button>
      </div>

      <Card>
        <Table
          columns={displayColumns}
          data={filteredCampaigns}
          loading={loading}
          onEdit={handleEditWrapper}
          onDelete={handleDeleteWrapper}
        />
      </Card>

      {/* Create/Edit Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title={editingCampaign ? 'Edit Campaign' : 'Create Campaign'}
        size="large"
      >
        <form onSubmit={handleSubmit}>
          {error && <div className="error-alert">{error}</div>}
          
          {/* Template Selector */}
          {!editingCampaign && templates.length > 0 && (
            <div className="input-group">
              <label className="input-label">Choose Email Template (Optional)</label>
              <select
                value={selectedTemplate}
                onChange={handleTemplateChange}
                className="input-field"
                style={{ marginBottom: '1rem' }}
              >
                <option value="">-- Select Template --</option>
                {templates.map((template) => (
                  <option key={template.id} value={template.id}>
                    {template.name}
                  </option>
                ))}
              </select>
              <small style={{ color: '#6b7280', fontSize: '0.875rem' }}>
                Select a template to auto-fill subject and body (you can edit them after selection)
              </small>
            </div>
          )}
          
          <Input
            label="Campaign Name"
            name="name"
            value={formData.name}
            onChange={handleChange}
            required
          />
          
          <Input
            label="Email Subject"
            name="subject"
            value={formData.subject}
            onChange={handleChange}
            required
          />
          
          <div className="input-group">
            <label className="input-label">Email Body</label>
            <textarea
              name="body"
              value={formData.body}
              onChange={handleChange}
              className="input-field"
              rows="8"
              required
              placeholder="Enter email content... Use {{variable_name}} for dynamic content (e.g., {{contact_name}}, {{property_name}})"
            />
            <small style={{ color: '#6b7280', fontSize: '0.875rem', marginTop: '0.25rem', display: 'block' }}>
              Tip: Use {`{{contact_name}}, {{property_name}}, {{agent_name}}`} for personalization
            </small>
          </div>

          <div className="input-group">
            <label className="input-label">Select Audiences (Hold Ctrl/Cmd for multiple)</label>
            <select
              multiple
              value={formData.audience_ids}
              onChange={handleAudienceChange}
              className="input-field"
              style={{ minHeight: '120px' }}
              required
            >
              {audienceOptions.map((option) => (
                <option key={option.value} value={option.value}>
                  {option.label}
                </option>
              ))}
            </select>
            <small style={{ color: '#6b7280', fontSize: '0.875rem' }}>
              Selected: {formData.audience_ids.length} audience(s)
            </small>
          </div>

          <div className="input-group">
            <label className="input-label">Schedule At (Optional)</label>
            <input
              type="datetime-local"
              name="scheduled_at"
              value={formData.scheduled_at}
              onChange={handleChange}
              className="input-field"
              min={new Date(Date.now() - new Date().getTimezoneOffset() * 60000).toISOString().slice(0, 16)}
            />
            <small style={{ color: '#6b7280', fontSize: '0.875rem', marginTop: '0.25rem', display: 'block' }}>
              Leave empty to save as draft. Set a future date/time to schedule automatic sending.
            </small>
          </div>

          <div className="modal-actions">
            <Button type="button" variant="secondary" onClick={() => setIsModalOpen(false)}>
              Cancel
            </Button>
            <Button type="submit" variant="primary">
              {editingCampaign ? 'Update' : 'Create'}
            </Button>
          </div>
        </form>
      </Modal>

      {/* View Details Modal */}
      <Modal
        isOpen={isViewModalOpen}
        onClose={() => setIsViewModalOpen(false)}
        title="Campaign Details"
        size="large"
      >
        {viewingCampaign && (
          <div style={{ padding: '1rem' }}>
            <div style={{ marginBottom: '1rem' }}>
              <strong>ID:</strong> {viewingCampaign.id}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Name:</strong> {viewingCampaign.name}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Subject:</strong> {viewingCampaign.subject}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Body:</strong>
              <div style={{ 
                marginTop: '0.5rem',
                padding: '0.75rem',
                backgroundColor: '#f3f4f6',
                borderRadius: '4px',
                whiteSpace: 'pre-wrap'
              }}>
                {viewingCampaign.body}
              </div>
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Status:</strong> {viewingCampaign.status || 'draft'}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Scheduled At:</strong> {viewingCampaign.scheduled_at ? formatDate(viewingCampaign.scheduled_at) : 'Not scheduled'}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Created At:</strong> {formatDate(viewingCampaign.created_at)}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Updated At:</strong> {formatDate(viewingCampaign.updated_at)}
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

export default Campaigns;
