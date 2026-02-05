import { ROLES } from './constants';

export const hasRole = (user, requiredRoles) => {
  if (!user || !user.role) return false;
  if (Array.isArray(requiredRoles)) {
    return requiredRoles.includes(user.role);
  }
  return user.role === requiredRoles;
};

export const isSuperAdmin = (user) => {
  return user?.role === ROLES.SUPER_ADMIN;
};

export const isOrgAdmin = (user) => {
  return user?.role === ROLES.ORG_ADMIN;
};

export const isOrgUser = (user) => {
  return user?.role === ROLES.ORG_USER;
};

export const canAccessOrganizations = (user) => {
  return isSuperAdmin(user);
};

export const canManageUsers = (user) => {
  return isSuperAdmin(user) || isOrgAdmin(user);
};

export const canViewContacts = (user) => {
  return !!user; // All authenticated users can view contacts
};
