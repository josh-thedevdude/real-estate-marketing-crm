import React from 'react';
import { screen, waitFor } from '@testing-library/react';
import { Navigate } from 'react-router-dom';
import { renderWithProviders, mockSuperAdmin, mockOrgUser, mockAuthState } from '../utils/test-utils';
import PrivateRoute from './PrivateRoute';

// Mock Navigate component
jest.mock('react-router-dom', () => ({
  ...jest.requireActual('react-router-dom'),
  Navigate: jest.fn(() => null),
}));

describe('PrivateRoute Component', () => {
  beforeEach(() => {
    Navigate.mockClear();
  });

  test('renders children when user is authenticated', () => {
    renderWithProviders(
      <PrivateRoute>
        <div>Protected Content</div>
      </PrivateRoute>,
      { preloadedState: mockAuthState(mockSuperAdmin) }
    );

    expect(screen.getByText('Protected Content')).toBeInTheDocument();
  });

  test('redirects to login when user is not authenticated', () => {
    renderWithProviders(
      <PrivateRoute>
        <div>Protected Content</div>
      </PrivateRoute>,
      { preloadedState: mockAuthState(null) }
    );

    expect(Navigate).toHaveBeenCalledWith({ to: '/login' }, {});
  });

  test('redirects to unauthorized when user lacks required role', () => {
    renderWithProviders(
      <PrivateRoute allowedRoles={['super_admin']}>
        <div>Admin Only Content</div>
      </PrivateRoute>,
      { preloadedState: mockAuthState(mockOrgUser) }
    );

    expect(Navigate).toHaveBeenCalledWith({ to: '/unauthorized' }, {});
  });

  test('renders children when user has required role', () => {
    renderWithProviders(
      <PrivateRoute allowedRoles={['super_admin', 'org_admin']}>
        <div>Admin Content</div>
      </PrivateRoute>,
      { preloadedState: mockAuthState(mockSuperAdmin) }
    );

    expect(screen.getByText('Admin Content')).toBeInTheDocument();
  });

  test('allows access when allowedRoles is not specified', () => {
    renderWithProviders(
      <PrivateRoute>
        <div>Any Authenticated User</div>
      </PrivateRoute>,
      { preloadedState: mockAuthState(mockOrgUser) }
    );

    expect(screen.getByText('Any Authenticated User')).toBeInTheDocument();
  });
});
