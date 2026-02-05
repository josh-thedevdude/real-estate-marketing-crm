import React, { useState, useEffect } from 'react';
import importLogService from '../services/importLogService';
import Card from '../components/Card';
import Table from '../components/Table';
import { formatDateTime } from '../utils/helpers';

const ImportLogs = () => {
  const [logs, setLogs] = useState([]);
  const [loading, setLoading] = useState(false);

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

  const columns = [
    { key: 'id', label: 'ID' },
    { key: 'filename', label: 'Filename' },
    { key: 'status', label: 'Status' },
    { key: 'total_rows', label: 'Total' },
    { key: 'successful_rows', label: 'Success' },
    { key: 'failed_rows', label: 'Failed' },
    {
      key: 'created_at',
      label: 'Created At',
      render: (value) => formatDateTime(value),
    },
  ];

  return (
    <div>
      <h1 className="page-title">Contact Import Logs</h1>
      <Card>
        <Table columns={columns} data={logs} loading={loading} />
      </Card>
    </div>
  );
};

export default ImportLogs;
