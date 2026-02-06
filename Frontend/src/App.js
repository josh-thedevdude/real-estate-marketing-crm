import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { Provider } from 'react-redux';
import store from './store';
import PrivateRoute from './components/PrivateRoute';
import Layout from './components/Layout';
import Login from './pages/Login';
import AcceptInvitation from './pages/AcceptInvitation';
import Dashboard from './pages/Dashboard';
import Organizations from './pages/Organizations';
import Users from './pages/Users';
import Contacts from './pages/Contacts';
import Audiences from './pages/Audiences';
import Campaigns from './pages/Campaigns';
import ImportLogs from './pages/ImportLogs';
import Unauthorized from './pages/Unauthorized';
import { ROLES } from './utils/constants';
import './styles/index.css';

function App() {
  return (
    <Provider store={store}>
      <Router>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route path="/accept-invitation" element={<AcceptInvitation />} />
          <Route path="/unauthorized" element={<Unauthorized />} />
          
          <Route
            path="/dashboard"
            element={
              <PrivateRoute>
                <Layout>
                  <Dashboard />
                </Layout>
              </PrivateRoute>
            }
          />
          
          <Route
            path="/organizations"
            element={
              <PrivateRoute requiredRoles={[ROLES.SUPER_ADMIN]}>
                <Layout>
                  <Organizations />
                </Layout>
              </PrivateRoute>
            }
          />
          
          <Route
            path="/users"
            element={
              <PrivateRoute requiredRoles={[ROLES.SUPER_ADMIN, ROLES.ORG_ADMIN]}>
                <Layout>
                  <Users />
                </Layout>
              </PrivateRoute>
            }
          />
          
          <Route
            path="/contacts"
            element={
              <PrivateRoute>
                <Layout>
                  <Contacts />
                </Layout>
              </PrivateRoute>
            }
          />
          
          <Route
            path="/audiences"
            element={
              <PrivateRoute>
                <Layout>
                  <Audiences />
                </Layout>
              </PrivateRoute>
            }
          />
          
          <Route
            path="/campaigns"
            element={
              <PrivateRoute>
                <Layout>
                  <Campaigns />
                </Layout>
              </PrivateRoute>
            }
          />
          
          <Route
            path="/import-logs"
            element={
              <PrivateRoute>
                <Layout>
                  <ImportLogs />
                </Layout>
              </PrivateRoute>
            }
          />
          
          <Route path="/" element={<Navigate to="/dashboard" replace />} />
          <Route path="*" element={<Navigate to="/dashboard" replace />} />
        </Routes>
      </Router>
    </Provider>
  );
}

export default App;
