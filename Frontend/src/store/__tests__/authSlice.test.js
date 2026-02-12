import authReducer, {
  loginStart,
  loginSuccess,
  loginFailure,
  logout,
  updateUser,
} from './authSlice';

describe('authSlice', () => {
  const initialState = {
    user: null,
    token: null,
    isAuthenticated: false,
    loading: false,
    error: null,
  };

  test('should return initial state', () => {
    expect(authReducer(undefined, { type: 'unknown' })).toEqual(initialState);
  });

  describe('loginStart', () => {
    test('sets loading to true and clears error', () => {
      const state = authReducer(initialState, loginStart());
      expect(state.loading).toBe(true);
      expect(state.error).toBe(null);
    });
  });

  describe('loginSuccess', () => {
    test('sets user, token, isAuthenticated, and clears loading', () => {
      const user = {
        id: 1,
        email: 'test@example.com',
        role: 'super_admin',
      };
      
      const state = authReducer(
        { ...initialState, loading: true },
        loginSuccess(user)
      );
      
      expect(state.user).toEqual(user);
      expect(state.isAuthenticated).toBe(true);
      expect(state.loading).toBe(false);
      expect(state.error).toBe(null);
    });
  });

  describe('loginFailure', () => {
    test('sets error message and clears loading', () => {
      const errorMessage = 'Invalid credentials';
      const state = authReducer(
        { ...initialState, loading: true },
        loginFailure(errorMessage)
      );
      
      expect(state.error).toBe(errorMessage);
      expect(state.loading).toBe(false);
      expect(state.isAuthenticated).toBe(false);
    });
  });

  describe('logout', () => {
    test('resets state to initial values', () => {
      const authenticatedState = {
        user: { id: 1, email: 'test@example.com' },
        token: 'mock-token',
        isAuthenticated: true,
        loading: false,
        error: null,
      };
      
      const state = authReducer(authenticatedState, logout());
      expect(state).toEqual(initialState);
    });
  });

  describe('updateUser', () => {
    test('updates user data', () => {
      const authenticatedState = {
        ...initialState,
        user: { id: 1, email: 'old@example.com', role: 'org_user' },
        isAuthenticated: true,
      };
      
      const updatedUser = { id: 1, email: 'new@example.com', role: 'org_admin' };
      const state = authReducer(authenticatedState, updateUser(updatedUser));
      
      expect(state.user).toEqual(updatedUser);
      expect(state.isAuthenticated).toBe(true);
    });
  });
});
