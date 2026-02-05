export const formatDate = (dateString) => {
  if (!dateString) return '-';
  const date = new Date(dateString);
  return date.toLocaleDateString('en-IN', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  });
};

export const formatDateTime = (dateString) => {
  if (!dateString) return '-';
  const date = new Date(dateString);
  return date.toLocaleString('en-IN', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
};

export const capitalizeFirst = (str) => {
  if (!str) return '';
  return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
};

export const getRoleBadgeClass = (role) => {
  switch (role) {
    case 'super_admin':
      return 'badge-danger';
    case 'org_admin':
      return 'badge-warning';
    case 'org_user':
      return 'badge-info';
    default:
      return 'badge-secondary';
  }
};

export const getStatusBadgeClass = (status) => {
  switch (status) {
    case 'active':
      return 'badge-success';
    case 'inactive':
      return 'badge-secondary';
    default:
      return 'badge-secondary';
  }
};
