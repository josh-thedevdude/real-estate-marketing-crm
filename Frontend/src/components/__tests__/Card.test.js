import React from 'react';
import { screen } from '@testing-library/react';
import { renderWithProviders } from '../utils/test-utils';
import Card from './Card';

describe('Card Component', () => {
  test('renders children content', () => {
    renderWithProviders(
      <Card>
        <div>Card Content</div>
      </Card>
    );

    expect(screen.getByText('Card Content')).toBeInTheDocument();
  });

  test('applies custom className', () => {
    const { container } = renderWithProviders(
      <Card className="custom-card">
        <div>Content</div>
      </Card>
    );

    const card = container.firstChild;
    expect(card).toHaveClass('card');
    expect(card).toHaveClass('custom-card');
  });

  test('applies custom styles', () => {
    const customStyle = { backgroundColor: 'red', padding: '20px' };
    const { container } = renderWithProviders(
      <Card style={customStyle}>
        <div>Content</div>
      </Card>
    );

    const card = container.firstChild;
    expect(card).toHaveStyle('background-color: red');
    expect(card).toHaveStyle('padding: 20px');
  });

  test('renders multiple children', () => {
    renderWithProviders(
      <Card>
        <h2>Title</h2>
        <p>Description</p>
        <button>Action</button>
      </Card>
    );

    expect(screen.getByText('Title')).toBeInTheDocument();
    expect(screen.getByText('Description')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Action' })).toBeInTheDocument();
  });
});
