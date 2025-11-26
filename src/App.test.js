// src/App.test.js
import { render, screen, fireEvent } from '@testing-library/react';
import App from './App';

// Test 1: Vérifier que l'application se charge correctement
test('renders todo app title', () => {
  render(<App />);
  const titleElement = screen.getByText(/Todo App - CI\/CD Demo/i);
  expect(titleElement).toBeInTheDocument();
});

// Test 2: Vérifier que l'input est présent
test('renders input field', () => {
  render(<App />);
  const inputElement = screen.getByPlaceholderText(/Ajouter une nouvelle tâche/i);
  expect(inputElement).toBeInTheDocument();
});

// Test 3: Vérifier qu'on peut ajouter une tâche
test('can add a new todo', () => {
  render(<App />);
  
  // Trouver l'input et le bouton
  const inputElement = screen.getByPlaceholderText(/Ajouter une nouvelle tâche/i);
  const buttonElement = screen.getByText(/Ajouter/i);
  
  // Ajouter du texte et cliquer
  fireEvent.change(inputElement, { target: { value: 'Nouvelle tâche test' } });
  fireEvent.click(buttonElement);
  
  // Vérifier que la tâche apparaît
  expect(screen.getByText(/Nouvelle tâche test/i)).toBeInTheDocument();
});

// Test 4: Vérifier le message quand il n'y a pas de tâches
test('shows empty message when no todos', () => {
  render(<App />);
  expect(screen.getByText(/Aucune tâche/i)).toBeInTheDocument();
});