import React from 'react';
import { screen } from '@testing-library/react';
import { renderWithProviders } from '../utils/test-utils';
import Table from './Table';

describe('Table Component', () => {
  const mockColumns = [
    { key: 'id', label: 'ID' },
    { key: 'name', label: 'Name' },
    { key: 'email', label: 'Email' },
  ];

  const mockData = [
    { id: 1, name: 'John Doe', email: 'john@example.com' },
    { id: 2, name: 'Jane Smith', email: 'jane@example.com' },
  ];

  test('renders table with columns and data', () => {
    renderWithProviders(<Table columns={mockColumns} data={mockData} />);
    
    expect(screen.getByText('ID')).toBeInTheDocument();
    expect(screen.getByText('Name')).toBeInTheDocument();
    expect(screen.getByText('Email')).toBeInTheDocument();
    expect(screen.getByText('John Doe')).toBeInTheDocument();
    expect(screen.getByText('jane@example.com')).toBeInTheDocument();
  });

  test('displays loading state', () => {
    renderWithProviders(<Table columns={mockColumns} data={[]} loading />);
    expect(screen.getByText('Loading...')).toBeInTheDocument();
  });

  test('displays empty state when no data', () => {
    renderWithProviders(<Table columns={mockColumns} data={[]} />);
    expect(screen.getByText('No data available')).toBeInTheDocument();
  });

  test('renders actions column when onEdit is provided', () => {
    const handleEdit = jest.fn();
    renderWithProviders(
      <Table columns={mockColumns} data={mockData} onEdit={handleEdit} />
    );
    
    expect(screen.getByText('Actions')).toBeInTheDocument();
    expect(screen.getAllByText('Edit')).toHaveLength(2);
  });

  test('renders delete buttons when onDelete is provided', () => {
    const handleDelete = jest.fn();
    renderWithProviders(
      <Table columns={mockColumns} data={mockData} onDelete={handleDelete} />
    );
    
    expect(screen.getAllByText('Delete')).toHaveLength(2);
  });

  test('renders custom cell content with render function', () => {
    const columns = [
      {
        key: 'status',
        label: 'Status',
        render: (value) => <span className="badge">{value}</span>,
      },
    ];
    
    const data = [{ status: 'Active' }];
    
    renderWithProviders(<Table columns={columns} data={data} />);
    expect(screen.getByText('Active')).toHaveClass('badge');
  });

  test('applies deleted-row class to deleted entries', () => {
    const dataWithDeleted = [
      { id: 1, name: 'Active User', deleted_at: null },
      { id: 2, name: 'Deleted User', deleted_at: '2026-02-10' },
    ];
    
    renderWithProviders(<Table columns={mockColumns} data={dataWithDeleted} />);
    
    const rows = screen.getAllByRole('row');
    // First row is header, second is active, third is deleted
    expect(rows[2]).toHaveClass('deleted-row');
  });

  test('disables edit button for deleted entries', () => {
    const handleEdit = jest.fn();
    const dataWithDeleted = [
      { id: 1, name: 'Deleted User', deleted_at: '2026-02-10' },
    ];
    
    renderWithProviders(
      <Table columns={mockColumns} data={dataWithDeleted} onEdit={handleEdit} />
    );
    
    const editButton = screen.getByText('Edit');
    expect(editButton).toBeDisabled();
  });

  test('disables edit button for executed campaigns', () => {
    const handleEdit = jest.fn();
    const dataWithExecuted = [
      { id: 1, name: 'Completed Campaign', status: 'completed' },
    ];
    
    renderWithProviders(
      <Table columns={mockColumns} data={dataWithExecuted} onEdit={handleEdit} />
    );
    
    const editButton = screen.getByText('Edit');
    expect(editButton).toBeDisabled();
  });

  test('displays "-" for empty cell values', () => {
    const dataWithEmpty = [{ id: 1, name: null, email: '' }];
    
    renderWithProviders(<Table columns={mockColumns} data={dataWithEmpty} />);
    
    const cells = screen.getAllByText('-');
    expect(cells.length).toBeGreaterThan(0);
  });
});
