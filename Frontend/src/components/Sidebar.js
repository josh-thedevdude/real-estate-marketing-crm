import React, { useState, useEffect } from 'react';
import { NavLink } from 'react-router-dom';
import { useSelector } from 'react-redux';
import { isSuperAdmin, isOrgAdmin } from '../utils/permissions';
import './components_css/Sidebar.css';

const Sidebar = () => {
  const { user } = useSelector((state) => state.auth);
  const [isOpen, setIsOpen] = useState(false);
  const [isMobile, setIsMobile] = useState(window.innerWidth <= 768);

  useEffect(() => {
    const handleResize = () => {
      setIsMobile(window.innerWidth <= 768);
      if (window.innerWidth > 768) {
        setIsOpen(false);
      }
    };

    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  const toggleSidebar = () => {
    setIsOpen(!isOpen);
  };

  const closeSidebar = () => {
    if (isMobile) {
      setIsOpen(false);
    }
  };

  const superAdminLinks = [
    { path: '/dashboard', label: 'Dashboard', icon: '📊' },
    { path: '/organizations', label: 'Organizations', icon: '🏢' },
    { path: '/users', label: 'Users', icon: '👥' },
    // { path: '/contacts', label: 'Contacts', icon: '📇' },
    // { path: '/audiences', label: 'Audiences', icon: '🎯' },
    // { path: '/campaigns', label: 'Campaigns', icon: '📧' },
    // { path: '/import-logs', label: 'Import Logs', icon: '📥' },
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
    { path: '/import-logs', label: 'Import Logs', icon: '📥' },
  ];

  const getLinks = () => {
    if (isSuperAdmin(user)) return superAdminLinks;
    if (isOrgAdmin(user)) return orgAdminLinks;
    return userLinks;
  };

  const links = getLinks();

  return (
    <>
      {/* Mobile Menu Button */}
      {isMobile && (
        <button className="mobile-menu-btn" onClick={toggleSidebar} aria-label="Toggle menu">
          <span className={`hamburger ${isOpen ? 'open' : ''}`}>
            <span></span>
            <span></span>
            <span></span>
          </span>
        </button>
      )}

      {/* Overlay */}
      {isMobile && isOpen && (
        <div className="sidebar-overlay" onClick={closeSidebar}></div>
      )}

      {/* Sidebar */}
      <aside className={`sidebar ${isOpen ? 'open' : ''}`}>
        <div className="sidebar-brand">
          <h2>Real Estate CRM</h2>
          {isMobile && (
            <button className="sidebar-close" onClick={closeSidebar} aria-label="Close menu">
              ✕
            </button>
          )}
        </div>
        <nav className="sidebar-nav">
          {links.map((link) => (
            <NavLink
              key={link.path}
              to={link.path}
              className={({ isActive }) =>
                `sidebar-link ${isActive ? 'active' : ''}`
              }
              onClick={closeSidebar}
            >
              <span className="sidebar-icon">{link.icon}</span>
              <span className="sidebar-label">{link.label}</span>
            </NavLink>
          ))}
        </nav>
      </aside>
    </>
  );
};

export default Sidebar;
