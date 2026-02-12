import React from 'react';
import { screen, fireEvent } from '@testing-library/react';
import { renderWithProviders } from '../utils/test-utils';
import Input from './Input';

describe('Input Component', () => {
  test('renders input field with label', () => {
    renderWithProviders(
      <Input
        label="Email"
        name="email"
        value=""
        onChange={() => {}}
      />
    );
    
    expect(screen.getByLabelText('Email')).toBeInTheDocument();
  });

  test('displays required asterisk when required prop is true', () => {
    renderWithProviders(
      <Input
        label="Email"
        name="email"
        value=""
        onChange={() => {}}
        required
      />
    );
    
    expect(screen.getByText('*')).toHaveClass('required');
  });

  test('calls onChange handler when input value changes', () => {
    const handleChange = jest.fn();
    renderWithProviders(
      <Input
        label="Email"
        name="email"
        value=""
        onChange={handleChange}
      />
    );
    
    const input = screen.getByLabelText('Email');
    fireEvent.change(input, { target: { value: 'test@example.com' } });
    
    expect(handleChange).toHaveBeenCalled();
  });

  test('displays error message when error prop is provided', () => {
    renderWithProviders(
      <Input
        label="Email"
        name="email"
        value=""
        onChange={() => {}}
        error="Invalid email"
      />
    );
    
    expect(screen.getByText('Invalid email')).toHaveClass('error-message');
  });

  test('applies error class to input when error exists', () => {
    renderWithProviders(
      <Input
        label="Email"
        name="email"
        value=""
        onChange={() => {}}
        error="Invalid email"
      />
    );
    
    const input = screen.getByLabelText('Email');
    expect(input).toHaveClass('input-error');
  });

  test('disables input when disabled prop is true', () => {
    renderWithProviders(
      <Input
        label="Email"
        name="email"
        value=""
        onChange={() => {}}
        disabled
      />
    );
    
    const input = screen.getByLabelText('Email');
    expect(input).toBeDisabled();
  });

  test('renders with placeholder text', () => {
    renderWithProviders(
      <Input
        label="Email"
        name="email"
        value=""
        onChange={() => {}}
        placeholder="Enter your email"
      />
    );
    
    expect(screen.getByPlaceholderText('Enter your email')).toBeInTheDocument();
  });

  test('renders different input types', () => {
    const { rerender } = renderWithProviders(
      <Input
        label="Password"
        type="password"
        name="password"
        value=""
        onChange={() => {}}
      />
    );
    
    expect(screen.getByLabelText('Password')).toHaveAttribute('type', 'password');
    
    rerender(
      <Input
        label="Email"
        type="email"
        name="email"
        value=""
        onChange={() => {}}
      />
    );
    
    expect(screen.getByLabelText('Email')).toHaveAttribute('type', 'email');
  });
});
