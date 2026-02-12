import { formatDate, formatDateTime, capitalizeFirst, getRoleBadgeClass, getStatusBadgeClass } from '../helpers';

describe('Helper Functions', () => {
  describe('formatDate', () => {
    test('formats date string correctly', () => {
      const date = '2026-02-11T10:30:00Z';
      const formatted = formatDate(date);
      expect(formatted).toContain('2026');
      expect(formatted).toContain('Feb');
    });

    test('returns "-" for null or undefined', () => {
      expect(formatDate(null)).toBe('-');
      expect(formatDate(undefined)).toBe('-');
      expect(formatDate('')).toBe('-');
    });
  });

  describe('formatDateTime', () => {
    test('formats datetime string with time', () => {
      const datetime = '2026-02-11T10:30:00Z';
      const formatted = formatDateTime(datetime);
      expect(formatted).toContain('2026');
      expect(formatted).toContain(':');
    });

    test('returns "-" for null or undefined', () => {
      expect(formatDateTime(null)).toBe('-');
      expect(formatDateTime(undefined)).toBe('-');
    });
  });

  describe('capitalizeFirst', () => {
    test('capitalizes first letter of string', () => {
      expect(capitalizeFirst('hello')).toBe('Hello');
      expect(capitalizeFirst('WORLD')).toBe('World');
    });

    test('handles empty or null strings', () => {
      expect(capitalizeFirst('')).toBe('');
      expect(capitalizeFirst(null)).toBe('');
      expect(capitalizeFirst(undefined)).toBe('');
    });

    test('handles single character', () => {
      expect(capitalizeFirst('a')).toBe('A');
    });
  });

  describe('getRoleBadgeClass', () => {
    test('returns correct badge class for super_admin', () => {
      expect(getRoleBadgeClass('super_admin')).toBe('badge-danger');
    });

    test('returns correct badge class for org_admin', () => {
      expect(getRoleBadgeClass('org_admin')).toBe('badge-warning');
    });

    test('returns correct badge class for org_user', () => {
      expect(getRoleBadgeClass('org_user')).toBe('badge-info');
    });

    test('returns default badge class for unknown role', () => {
      expect(getRoleBadgeClass('unknown')).toBe('badge-secondary');
      expect(getRoleBadgeClass(null)).toBe('badge-secondary');
    });
  });

  describe('getStatusBadgeClass', () => {
    test('returns correct badge class for active status', () => {
      expect(getStatusBadgeClass('active')).toBe('badge-success');
    });

    test('returns correct badge class for inactive status', () => {
      expect(getStatusBadgeClass('inactive')).toBe('badge-secondary');
    });

    test('returns default badge class for unknown status', () => {
      expect(getStatusBadgeClass('unknown')).toBe('badge-secondary');
      expect(getStatusBadgeClass(null)).toBe('badge-secondary');
    });
  });
});
