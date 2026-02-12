import { ROLES } from '../constants';
import {
  hasRole,
  isSuperAdmin,
  isOrgAdmin,
  isOrgUser,
  canAccessOrganizations,
  canManageUsers,
  canViewContacts,
} from '../permissions';

describe('Permissions Utility Functions', () => {
  const superAdmin = { id: 1, role: ROLES.SUPER_ADMIN };
  const orgAdmin = { id: 2, role: ROLES.ORG_ADMIN };
  const orgUser = { id: 3, role: ROLES.ORG_USER };

  describe('hasRole', () => {
    test('returns true when user has exact role', () => {
      expect(hasRole(superAdmin, ROLES.SUPER_ADMIN)).toBe(true);
    });

    test('returns true when user has one of multiple roles', () => {
      expect(hasRole(orgAdmin, [ROLES.ORG_ADMIN, ROLES.SUPER_ADMIN])).toBe(true);
    });

    test('returns false when user does not have role', () => {
      expect(hasRole(orgUser, ROLES.SUPER_ADMIN)).toBe(false);
    });

    test('returns false when user is null', () => {
      expect(hasRole(null, ROLES.SUPER_ADMIN)).toBe(false);
    });

    test('returns false when user has no role property', () => {
      expect(hasRole({}, ROLES.SUPER_ADMIN)).toBe(false);
    });
  });

  describe('isSuperAdmin', () => {
    test('returns true for super admin', () => {
      expect(isSuperAdmin(superAdmin)).toBe(true);
    });

    test('returns false for non-super admin', () => {
      expect(isSuperAdmin(orgAdmin)).toBe(false);
      expect(isSuperAdmin(orgUser)).toBe(false);
    });

    test('returns false for null user', () => {
      expect(isSuperAdmin(null)).toBe(false);
    });
  });

  describe('isOrgAdmin', () => {
    test('returns true for org admin', () => {
      expect(isOrgAdmin(orgAdmin)).toBe(true);
    });

    test('returns false for non-org admin', () => {
      expect(isOrgAdmin(superAdmin)).toBe(false);
      expect(isOrgAdmin(orgUser)).toBe(false);
    });
  });

  describe('isOrgUser', () => {
    test('returns true for org user', () => {
      expect(isOrgUser(orgUser)).toBe(true);
    });

    test('returns false for non-org user', () => {
      expect(isOrgUser(superAdmin)).toBe(false);
      expect(isOrgUser(orgAdmin)).toBe(false);
    });
  });

  describe('canAccessOrganizations', () => {
    test('returns true for super admin', () => {
      expect(canAccessOrganizations(superAdmin)).toBe(true);
    });

    test('returns false for org admin and org user', () => {
      expect(canAccessOrganizations(orgAdmin)).toBe(false);
      expect(canAccessOrganizations(orgUser)).toBe(false);
    });
  });

  describe('canManageUsers', () => {
    test('returns true for super admin and org admin', () => {
      expect(canManageUsers(superAdmin)).toBe(true);
      expect(canManageUsers(orgAdmin)).toBe(true);
    });

    test('returns false for org user', () => {
      expect(canManageUsers(orgUser)).toBe(false);
    });
  });

  describe('canViewContacts', () => {
    test('returns true for all authenticated users', () => {
      expect(canViewContacts(superAdmin)).toBe(true);
      expect(canViewContacts(orgAdmin)).toBe(true);
      expect(canViewContacts(orgUser)).toBe(true);
    });

    test('returns false for null user', () => {
      expect(canViewContacts(null)).toBe(false);
    });
  });
});
