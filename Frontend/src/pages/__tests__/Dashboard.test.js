import React from 'react';
import { screen } from '@testing-library/react';
import { renderWithProviders, mockSuperAdmin, mockAuthState } from '../utils/test-utils';
import Dashboard from './Dashboard';

// Mock the dashboard stats API
jest.mock('../services/dashboardService', () => ({
  getStats: jest.fn(() =>
    Promise.resolve({
      organizations: 5,
      admins: 10,
      users: 50,
      total_users: 60,
    })
  ),
}));

describe('Dashboard Page', () => {
  test('renders dashboard for super admin', async () => {
    renderWithProviders(<Dashboard />, {
      preloadedState: mockAuthState(mockSuperAdmin),
    });

    expect(screen.getByText(/dashboard/i)).toBeInTheDocument();
  });

  test('displays welcome message with user email', () => {
    renderWithProviders(<Dashboard />, {
      preloadedState: mockAuthState(mockSuperAdmin),
    });

    expect(screen.getByText(/admin@test.com/i)).toBeInTheDocument();
  });

  test('displays user role', () => {
    renderWithProviders(<Dashboard />, {
      preloadedState: mockAuthState(mockSuperAdmin),
    });

    expect(screen.getByText(/super admin/i)).toBeInTheDocument();
  });
});
