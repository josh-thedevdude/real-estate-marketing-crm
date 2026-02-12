import React, { useState, useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { useDispatch } from 'react-redux';
import userService from '../services/userService';
import { loginSuccess } from '../store/authSlice';
import Input from '../components/Input';
import Button from '../components/Button';
import './pages_css/Login.css';

const AcceptInvitation = () => {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const dispatch = useDispatch();
  
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [token, setToken] = useState('');

  useEffect(() => {
    const invitationToken = searchParams.get('token');
    if (!invitationToken) {
      setError('Invalid invitation link');
    } else {
      setToken(invitationToken);
    }
  }, [searchParams]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');

    // Validation
    if (password.length < 8) {
      setError('Password must be at least 8 characters long');
      return;
    }

    if (password.length > 15) {
      setError('Password must be maximum 15 characters long');
      return;
    }

    if (password !== confirmPassword) {
      setError('Passwords do not match');
      return;
    }

    setLoading(true);

    try {
      const response = await userService.acceptInvitation({
        invitation_token: token,
        password: password,
      });

      // Store token and user info
      localStorage.setItem('token', response.token);
      localStorage.setItem('user', JSON.stringify(response.user));

      // Update Redux store
      dispatch(loginSuccess({
        user: response.user,
        token: response.token,
      }));

      // Redirect to dashboard
      navigate('/dashboard');
    } catch (err) {
      setError(err.response?.data?.error || 'Failed to accept invitation');
    } finally {
      setLoading(false);
    }
  };

  if (!token) {
    return (
      <div className="login-container">
        <div className="login-card">
          <h1 className="login-title">Invalid Invitation</h1>
          <p className="error-alert" style={{ marginTop: '1rem' }}>
            This invitation link is invalid or expired.
          </p>
          <Button onClick={() => navigate('/login')} variant="primary" style={{ marginTop: '1rem' }}>
            Go to Login
          </Button>
        </div>
      </div>
    );
  }

  return (
    <div className="login-container">
      <div className="login-card">
        <h1 className="login-title">Accept Invitation</h1>
        <p style={{ textAlign: 'center', color: '#6b7280', marginBottom: '2rem' }}>
          Set your password to activate your account
        </p>

        <form onSubmit={handleSubmit}>
          {error && <div className="error-alert">{error}</div>}

          <Input
            label="New Password"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="Enter your password (8-15 characters)"
            pattern="(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,15}"
            title="Password must be 8-15 characters and include at least one uppercase letter, one lowercase letter, and one digit"
            minLength={8}
            maxLength={15}
            required
          />

          <Input
            label="Confirm Password"
            type="password"
            value={confirmPassword}
            onChange={(e) => setConfirmPassword(e.target.value)}
            placeholder="Confirm your password"
            required
          />

          <div style={{ fontSize: '0.875rem', color: '#6b7280', marginBottom: '1rem' }}>
            <p style={{ margin: '0.25rem 0' }}>Password requirements:</p>
            <ul style={{ margin: '0.5rem 0', paddingLeft: '1.5rem' }}>
              <li>Minimum 8 characters, maximum 15 characters</li>
              <li>At least one uppercase letter (A-Z)</li>
              <li>At least one lowercase letter (a-z)</li>
              <li>At least one digit (0-9)</li>
            </ul>
          </div>

          <Button
            type="submit"
            variant="primary"
            fullWidth
            disabled={loading}
          >
            {loading ? 'Processing...' : 'Set Password & Login'}
          </Button>
        </form>
      </div>
    </div>
  );
};

export default AcceptInvitation;
