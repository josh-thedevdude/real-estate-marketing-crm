import React from 'react';
import { NavLink } from 'react-router-dom';
import { useSelector } from 'react-redux';
import { isSuperAdmin, isOrgAdmin } from '../utils/permissions';
import './Sidebar.css';

const Sidebar = () => {
  const { user } = useSelector((state) => state.auth);

  const superAdminLinks = [
    { path: '/dashboard', label: 'Dashboard', icon: '📊' },
    { path: '/organizations', label: 'Organizations', icon: '🏢' },
    { path: '/users', label: 'Users', icon: '👥' },
    { path: '/contacts', label: 'Contacts', icon: '📇' },
    { path: '/audiences', label: 'Audiences', icon: '🎯' },
    { path: '/campaigns', label: 'Campaigns', icon: '📧' },
    { path: '/import-logs', label: 'Import Logs', icon: '📥' },
  ];

  const orgAdminLinks = [
    { path: '/dashboard', label: 'Dashboard', icon: '📊' },
    { path: '/users', label: 'Users', icon: '👥' },
    { path: '/contacts', label: 'Contacts', icon: '📇' },
    { path: '/audiences', label: 'Audiences', icon: '🎯' },
    { path: '/campaigns', label: 'Campaigns', icon: '📧' },
    { path: '/import-logs', label: 'Import Logs', icon: '📥' },
  ];

  const userLinks = [
    { path: '/dashboard', label: 'Dashboard', icon: '📊' },
    { path: '/contacts', label: 'Contacts', icon: '📇' },
    { path: '/audiences', label: 'Audiences', icon: '🎯' },
    { path: '/campaigns', label: 'Campaigns', icon: '📧' },
  ];

  const getLinks = () => {
    if (isSuperAdmin(user)) return superAdminLinks;
    if (isOrgAdmin(user)) return orgAdminLinks;
    return userLinks;
  };

  const links = getLinks();

  return (
    <aside className="sidebar">
      <div className="sidebar-brand">
        <h2>Real Estate CRM</h2>
      </div>
      <nav className="sidebar-nav">
        {links.map((link) => (
          <NavLink
            key={link.path}
            to={link.path}
            className={({ isActive }) =>
              `sidebar-link ${isActive ? 'active' : ''}`
            }
          >
            <span className="sidebar-icon">{link.icon}</span>
            <span className="sidebar-label">{link.label}</span>
          </NavLink>
        ))}
      </nav>
    </aside>
  );
};

export default Sidebar;
