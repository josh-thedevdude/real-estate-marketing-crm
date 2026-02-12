import React from 'react';
import { screen, fireEvent } from '@testing-library/react';
import { renderWithProviders } from '../utils/test-utils';
import Button from './Button';

describe('Button Component', () => {
  test('renders button with children text', () => {
    renderWithProviders(<Button>Click Me</Button>);
    expect(screen.getByRole('button', { name: 'Click Me' })).toBeInTheDocument();
  });

  test('calls onClick handler when clicked', () => {
    const handleClick = jest.fn();
    renderWithProviders(<Button onClick={handleClick}>Click Me</Button>);
    
    fireEvent.click(screen.getByRole('button'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  test('applies primary variant class', () => {
    renderWithProviders(<Button variant="primary">Primary</Button>);
    expect(screen.getByRole('button')).toHaveClass('btn-primary');
  });

  test('applies secondary variant class', () => {
    renderWithProviders(<Button variant="secondary">Secondary</Button>);
    expect(screen.getByRole('button')).toHaveClass('btn-secondary');
  });

  test('applies danger variant class', () => {
    renderWithProviders(<Button variant="danger">Delete</Button>);
    expect(screen.getByRole('button')).toHaveClass('btn-danger');
  });

  test('disables button when disabled prop is true', () => {
    renderWithProviders(<Button disabled>Disabled</Button>);
    expect(screen.getByRole('button')).toBeDisabled();
  });

  test('does not call onClick when button is disabled', () => {
    const handleClick = jest.fn();
    renderWithProviders(
      <Button onClick={handleClick} disabled>
        Disabled
      </Button>
    );
    
    fireEvent.click(screen.getByRole('button'));
    expect(handleClick).not.toHaveBeenCalled();
  });

  test('applies fullWidth class when fullWidth prop is true', () => {
    renderWithProviders(<Button fullWidth>Full Width</Button>);
    expect(screen.getByRole('button')).toHaveClass('btn-full-width');
  });

  test('renders as submit type when type="submit"', () => {
    renderWithProviders(<Button type="submit">Submit</Button>);
    expect(screen.getByRole('button')).toHaveAttribute('type', 'submit');
  });

  test('applies custom className', () => {
    renderWithProviders(<Button className="custom-class">Custom</Button>);
    expect(screen.getByRole('button')).toHaveClass('custom-class');
  });
});
