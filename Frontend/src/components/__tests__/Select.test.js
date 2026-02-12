import React from 'react';
import { screen, fireEvent } from '@testing-library/react';
import { renderWithProviders } from '../utils/test-utils';
import Select from './Select';

describe('Select Component', () => {
  const mockOptions = [
    { value: 'option1', label: 'Option 1' },
    { value: 'option2', label: 'Option 2' },
    { value: 'option3', label: 'Option 3' },
  ];

  test('renders select field with label', () => {
    renderWithProviders(
      <Select
        label="Choose Option"
        name="option"
        value=""
        onChange={() => {}}
        options={mockOptions}
      />
    );

    expect(screen.getByLabelText('Choose Option')).toBeInTheDocument();
  });

  test('displays required asterisk when required prop is true', () => {
    renderWithProviders(
      <Select
        label="Choose Option"
        name="option"
        value=""
        onChange={() => {}}
        options={mockOptions}
        required
      />
    );

    expect(screen.getByText('*')).toHaveClass('required');
  });

  test('renders all options', () => {
    renderWithProviders(
      <Select
        label="Choose Option"
        name="option"
        value=""
        onChange={() => {}}
        options={mockOptions}
      />
    );

    expect(screen.getByText('Option 1')).toBeInTheDocument();
    expect(screen.getByText('Option 2')).toBeInTheDocument();
    expect(screen.getByText('Option 3')).toBeInTheDocument();
  });

  test('displays placeholder option', () => {
    renderWithProviders(
      <Select
        label="Choose Option"
        name="option"
        value=""
        onChange={() => {}}
        options={mockOptions}
        placeholder="Select something"
      />
    );

    expect(screen.getByText('Select something')).toBeInTheDocument();
  });

  test('calls onChange when selection changes', () => {
    const handleChange = jest.fn();
    renderWithProviders(
      <Select
        label="Choose Option"
        name="option"
        value=""
        onChange={handleChange}
        options={mockOptions}
      />
    );

    const select = screen.getByLabelText('Choose Option');
    fireEvent.change(select, { target: { value: 'option2' } });

    expect(handleChange).toHaveBeenCalled();
  });

  test('displays selected value', () => {
    renderWithProviders(
      <Select
        label="Choose Option"
        name="option"
        value="option2"
        onChange={() => {}}
        options={mockOptions}
      />
    );

    const select = screen.getByLabelText('Choose Option');
    expect(select).toHaveValue('option2');
  });

  test('disables select when disabled prop is true', () => {
    renderWithProviders(
      <Select
        label="Choose Option"
        name="option"
        value=""
        onChange={() => {}}
        options={mockOptions}
        disabled
      />
    );

    expect(screen.getByLabelText('Choose Option')).toBeDisabled();
  });

  test('displays error message when error prop is provided', () => {
    renderWithProviders(
      <Select
        label="Choose Option"
        name="option"
        value=""
        onChange={() => {}}
        options={mockOptions}
        error="This field is required"
      />
    );

    expect(screen.getByText('This field is required')).toHaveClass('error-message');
  });

  test('applies error class when error exists', () => {
    renderWithProviders(
      <Select
        label="Choose Option"
        name="option"
        value=""
        onChange={() => {}}
        options={mockOptions}
        error="Error"
      />
    );

    expect(screen.getByLabelText('Choose Option')).toHaveClass('select-error');
  });
});
