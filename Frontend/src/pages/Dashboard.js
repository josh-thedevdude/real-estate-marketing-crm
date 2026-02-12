import React, { useState, useEffect } from 'react';
import { useSelector } from 'react-redux';
import { isSuperAdmin, isOrgAdmin } from '../utils/permissions';
import dashboardService from '../services/dashboardService';
import Card from '../components/Card';
import './pages_css/Dashboard.css';

const Dashboard = () => {
  const { user } = useSelector((state) => state.auth);
  const [stats, setStats] = useState({
    organizations: 0,
    admins: 0,
    users: 0,
    total_users: 0,
    contacts: 0,
    audiences: 0,
    campaigns: 0,
    imports: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDashboardStats();
  }, [user]);

  const fetchDashboardStats = async () => {
    setLoading(true);
    try {
      const data = await dashboardService.getStats();
      setStats(data);
    } catch (err) {
      console.error('Error fetching dashboard stats:', err);
    } finally {
      setLoading(false);
    }
  };

  const renderSuperAdminDashboard = () => (
    <div className="dashboard">
      <h1 className="page-title">Super Admin Dashboard</h1>
      <div className="dashboard-grid">
        <Card title="Organizations">
          <div className="stat-card">
            <div className="stat-value">{loading ? '...' : stats.organizations || 0}</div>
            <div className="stat-label">Total Organizations</div>
          </div>
        </Card>
        <Card title="Admins">
          <div className="stat-card">
            <div className="stat-value">{loading ? '...' : stats.admins || 0}</div>
            <div className="stat-label">Total Admins</div>
          </div>
        </Card>
        <Card title="Users">
          <div className="stat-card">
            <div className="stat-value">{loading ? '...' : stats.users || 0}</div>
            <div className="stat-label">Total Users</div>
          </div>
        </Card>
        {/* <Card title="All Users">
          <div className="stat-card">
            <div className="stat-value">{loading ? '...' : stats.total_users || 0}</div>
            <div className="stat-label">Total (Admins + Users)</div>
          </div>
        </Card> */}
      </div>
      <Card title="Quick Actions" className="mt-4">
        <div className="quick-actions">
          <a href="/organizations" className="action-link">Manage Organizations</a>
          <a href="/users" className="action-link">Manage Users</a>
        </div>
      </Card>
    </div>
  );

  const renderOrgAdminDashboard = () => (
    <div className="dashboard">
      <h1 className="page-title">Organization Admin Dashboard</h1>
      <div className="dashboard-grid">
        <Card title="Users">
          <div className="stat-card">
            <div className="stat-value">{loading ? '...' : stats.users || 0}</div>
            <div className="stat-label">Organization Users</div>
          </div>
        </Card>
        <Card title="Contacts">
          <div className="stat-card">
            <div className="stat-value">{loading ? '...' : stats.contacts || 0}</div>
            <div className="stat-label">Total Contacts</div>
          </div>
        </Card>
        <Card title="Audiences">
          <div className="stat-card">
            <div className="stat-value">{loading ? '...' : stats.audiences || 0}</div>
            <div className="stat-label">Total Audiences</div>
          </div>
        </Card>
        <Card title="Imports">
          <div className="stat-card">
            <div className="stat-value">{loading ? '...' : stats.imports || 0}</div>
            <div className="stat-label">Recent Imports</div>
          </div>
        </Card>
      </div>
      <Card title="Quick Actions" className="mt-4">
        <div className="quick-actions">
          <a href="/users" className="action-link">Manage Users</a>
          <a href="/contacts" className="action-link">Manage Contacts</a>
          <a href="/audiences" className="action-link">Manage Audiences</a>
        </div>
      </Card>
    </div>
  );

  const renderUserDashboard = () => (
    <div className="dashboard">
      <h1 className="page-title">User Dashboard</h1>
      <div className="dashboard-grid">
        <Card title="Contacts">
          <div className="stat-card">
            <div className="stat-value">{loading ? '...' : stats.contacts || 0}</div>
            <div className="stat-label">Total Contacts</div>
          </div>
        </Card>
        <Card title="Audiences">
          <div className="stat-card">
            <div className="stat-value">{loading ? '...' : stats.audiences || 0}</div>
            <div className="stat-label">Total Audiences</div>
          </div>
        </Card>
      </div>
      <Card title="Quick Actions" className="mt-4">
        <div className="quick-actions">
          <a href="/contacts" className="action-link">View Contacts</a>
          <a href="/audiences" className="action-link">View Audiences</a>
        </div>
      </Card>
    </div>
  );

  if (isSuperAdmin(user)) return renderSuperAdminDashboard();
  if (isOrgAdmin(user)) return renderOrgAdminDashboard();
  return renderUserDashboard();
};

export default Dashboard;
