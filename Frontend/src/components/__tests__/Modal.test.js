import React from 'react';
import { screen, fireEvent } from '@testing-library/react';
import { renderWithProviders } from '../utils/test-utils';
import Modal from './Modal';

describe('Modal Component', () => {
  test('renders modal when isOpen is true', () => {
    renderWithProviders(
      <Modal isOpen={true} onClose={() => {}} title="Test Modal">
        <div>Modal Content</div>
      </Modal>
    );

    expect(screen.getByText('Test Modal')).toBeInTheDocument();
    expect(screen.getByText('Modal Content')).toBeInTheDocument();
  });

  test('does not render modal when isOpen is false', () => {
    renderWithProviders(
      <Modal isOpen={false} onClose={() => {}} title="Test Modal">
        <div>Modal Content</div>
      </Modal>
    );

    expect(screen.queryByText('Test Modal')).not.toBeInTheDocument();
  });

  test('calls onClose when close button is clicked', () => {
    const handleClose = jest.fn();
    renderWithProviders(
      <Modal isOpen={true} onClose={handleClose} title="Test Modal">
        <div>Content</div>
      </Modal>
    );

    const closeButton = screen.getByText('×');
    fireEvent.click(closeButton);
    expect(handleClose).toHaveBeenCalledTimes(1);
  });

  test('calls onClose when overlay is clicked', () => {
    const handleClose = jest.fn();
    renderWithProviders(
      <Modal isOpen={true} onClose={handleClose} title="Test Modal">
        <div>Content</div>
      </Modal>
    );

    const overlay = screen.getByRole('dialog').parentElement;
    fireEvent.click(overlay);
    expect(handleClose).toHaveBeenCalled();
  });

  test('does not call onClose when modal content is clicked', () => {
    const handleClose = jest.fn();
    renderWithProviders(
      <Modal isOpen={true} onClose={handleClose} title="Test Modal">
        <div>Content</div>
      </Modal>
    );

    const modalContent = screen.getByText('Content');
    fireEvent.click(modalContent);
    expect(handleClose).not.toHaveBeenCalled();
  });

  test('applies size class', () => {
    renderWithProviders(
      <Modal isOpen={true} onClose={() => {}} title="Large Modal" size="large">
        <div>Content</div>
      </Modal>
    );

    const modal = screen.getByRole('dialog');
    expect(modal).toHaveClass('modal-large');
  });
});
