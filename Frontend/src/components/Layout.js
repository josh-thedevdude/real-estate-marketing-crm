import React from 'react';
import Sidebar from './Sidebar';
import Header from './Header';
import './components_css/Layout.css';

const Layout = ({ children }) => {
  return (
    <div className="layout">
      <Sidebar />
      <div className="main-content">
        <Header />
        <main className="content">{children}</main>
      </div>
    </div>
  );
};

export default Layout;
