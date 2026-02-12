import { render, screen } from '@testing-library/react';
import { Provider } from 'react-redux';
import { BrowserRouter } from 'react-router-dom';
import { configureStore } from '@reduxjs/toolkit';
import authReducer from '../store/authSlice';

// Test utility to render components with Redux and Router
export const renderWithProviders = (
  ui,
  {
    preloadedState = {},
    store = configureStore({
      reducer: { auth: authReducer },
      preloadedState,
    }),
    ...renderOptions
  } = {}
) => {
  const Wrapper = ({ children }) => (
    <Provider store={store}>
      <BrowserRouter>{children}</BrowserRouter>
    </Provider>
  );

  return { store, ...render(ui, { wrapper: Wrapper, ...renderOptions }) };
};

// Mock authenticated user
export const mockSuperAdmin = {
  id: 1,
  email: 'admin@test.com',
  role: 'super_admin',
};

export const mockOrgAdmin = {
  id: 2,
  email: 'orgadmin@test.com',
  role: 'org_admin',
  organization_id: 1,
};

export const mockOrgUser = {
  id: 3,
  email: 'user@test.com',
  role: 'org_user',
  organization_id: 1,
};

// Mock Redux state
export const mockAuthState = (user = null) => ({
  auth: {
    user,
    token: user ? 'mock-token-123' : null,
    isAuthenticated: !!user,
    loading: false,
    error: null,
  },
});
