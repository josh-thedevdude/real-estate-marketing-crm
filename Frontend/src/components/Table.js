import React from 'react';
import './Table.css';

const Table = ({ columns, data, onEdit, onDelete, loading = false }) => {
  if (loading) {
    return <div className="table-loading">Loading...</div>;
  }

  if (!data || data.length === 0) {
    return <div className="table-empty">No data available</div>;
  }

  return (
    <div className="table-container">
      <table className="table">
        <thead>
          <tr>
            {columns.map((column) => (
              <th key={column.key} className={column.className || ''}>
                {column.label}
              </th>
            ))}
            {(onEdit || onDelete) && <th className="actions-col">Actions</th>}
          </tr>
        </thead>
        <tbody>
          {data.map((row) => (
            <tr key={row.id}>
              {columns.map((column) => (
                <td key={column.key} className={column.className || ''}>
                  {column.render
                    ? column.render(row[column.key], row)
                    : row[column.key] || '-'}
                </td>
              ))}
              {(onEdit || onDelete) && (
                <td className="actions-col">
                  <div className="action-buttons">
                    {onEdit && (
                      <button
                        className="btn-action btn-edit"
                        onClick={() => onEdit(row)}
                        title="Edit"
                      >
                        Edit
                      </button>
                    )}
                    {onDelete && (
                      <button
                        className="btn-action btn-delete"
                        onClick={() => onDelete(row)}
                        title="Delete"
                      >
                        Delete
                      </button>
                    )}
                  </div>
                </td>
              )}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default Table;
