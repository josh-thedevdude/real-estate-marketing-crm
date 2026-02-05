import React from 'react';
import './Button.css';

const Button = ({
  children,
  onClick,
  type = 'button',
  variant = 'primary',
  size = 'medium',
  disabled = false,
  fullWidth = false,
  className = '',
}) => {
  const getButtonClass = () => {
    let classes = ['btn', `btn-${variant}`, `btn-${size}`];
    if (fullWidth) classes.push('btn-full');
    if (disabled) classes.push('btn-disabled');
    if (className) classes.push(className);
    return classes.join(' ');
  };

  return (
    <button
      type={type}
      className={getButtonClass()}
      onClick={onClick}
      disabled={disabled}
    >
      {children}
    </button>
  );
};

export default Button;
