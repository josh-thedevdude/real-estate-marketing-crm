import React, { useState, useEffect } from 'react';
import importLogService from '../services/importLogService';
import Card from '../components/Card';
import Table from '../components/Table';
import Modal from '../components/Modal';
import Button from '../components/Button';
import { formatDateTime } from '../utils/helpers';

const ImportLogs = () => {
  const [logs, setLogs] = useState([]);
  const [loading, setLoading] = useState(false);
  const [viewingLog, setViewingLog] = useState(null);
  const [isViewModalOpen, setIsViewModalOpen] = useState(false);

  useEffect(() => {
    fetchLogs();
  }, []);

  const fetchLogs = async () => {
    setLoading(true);
    try {
      const data = await importLogService.getAll();
      setLogs(data);
    } catch (err) {
      console.error('Error fetching logs:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleView = async (log) => {
    try {
      const data = await importLogService.getById(log.id);
      setViewingLog(data);
      setIsViewModalOpen(true);
    } catch (err) {
      console.error('Error fetching log details:', err);
    }
  };

  const columns = [
    { key: 'id', label: 'ID' },
    { key: 'filename', label: 'Filename' },
    { 
      key: 'status', 
      label: 'Status',
      render: (value) => (
        <span className={`badge badge-${value === 'completed' ? 'success' : value === 'failed' ? 'danger' : 'warning'}`}>
          {value?.toUpperCase()}
        </span>
      )
    },
    { 
      key: 'total_rows', 
      label: 'Total',
      render: (value) => value || 0
    },
    { 
      key: 'successful_rows', 
      label: 'Success',
      render: (value) => value || 0
    },
    { 
      key: 'failed_rows', 
      label: 'Failed',
      render: (value) => value || 0
    },
    {
      key: 'created_at',
      label: 'Created At',
      render: (value) => formatDateTime(value),
    },
  ];

  const actionColumn = {
    key: 'actions',
    label: 'Actions',
    render: (_, log) => (
      <div style={{ display: 'flex', gap: '0.5rem' }}>
        <Button onClick={() => handleView(log)} variant="info" size="small">
          View Details
        </Button>
      </div>
    ),
  };

  const displayColumns = [...columns, actionColumn];

  return (
    <div>
      <h1 className="page-title">Contact Import Logs</h1>
      <Card>
        <Table columns={displayColumns} data={logs} loading={loading} />
      </Card>

      {/* View Details Modal */}
      <Modal
        isOpen={isViewModalOpen}
        onClose={() => setIsViewModalOpen(false)}
        title="Import Log Details"
        size="large"
      >
        {viewingLog && (
          <div style={{ padding: '1rem' }}>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Filename:</strong> {viewingLog.filename}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Status:</strong> <span className={`badge badge-${viewingLog.status === 'completed' ? 'success' : 'danger'}`}>{viewingLog.status?.toUpperCase()}</span>
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Total Rows:</strong> {viewingLog.total_rows || 0}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Successful:</strong> {viewingLog.successful_rows || 0}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Failed:</strong> {viewingLog.failed_rows || 0}
            </div>
            <div style={{ marginBottom: '1rem' }}>
              <strong>Created At:</strong> {formatDateTime(viewingLog.created_at)}
            </div>

            {viewingLog.error_details && viewingLog.error_details.length > 0 && (
              <div style={{ marginTop: '1.5rem' }}>
                <h3 style={{ marginBottom: '1rem', fontSize: '1.1rem', fontWeight: '600', color: '#dc2626' }}>Error Details</h3>
                <div style={{ maxHeight: '400px', overflowY: 'auto', border: '1px solid #e5e7eb', borderRadius: '6px', padding: '1rem', backgroundColor: '#fef2f2' }}>
                  {viewingLog.error_details.map((error, index) => (
                    <div key={index} style={{ marginBottom: '1.5rem', paddingBottom: '1rem', borderBottom: index < viewingLog.error_details.length - 1 ? '1px solid #fecaca' : 'none' }}>
                      {error.row_number && (
                        <div style={{ marginBottom: '0.5rem', fontWeight: '600', color: '#991b1b' }}>
                          Row {error.row_number}
                        </div>
                      )}
                      {error.data && (
                        <div style={{ marginBottom: '0.5rem', fontSize: '0.875rem', color: '#7f1d1d' }}>
                          <strong>Data:</strong> {JSON.stringify(error.data)}
                        </div>
                      )}
                      {error.errors && Array.isArray(error.errors) && (
                        <ul style={{ marginLeft: '1rem', color: '#991b1b' }}>
                          {error.errors.map((err, errIdx) => (
                            <li key={errIdx}>{err}</li>
                          ))}
                        </ul>
                      )}
                      {error.error && (
                        <div style={{ color: '#991b1b' }}>{error.error}</div>
                      )}
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        )}
      </Modal>
    </div>
  );
};

export default ImportLogs;
