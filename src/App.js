// src/App.js
import React, { useState } from 'react';
import './App.css';

function App() {
  // État pour stocker la liste des tâches
  const [todos, setTodos] = useState([]);
  // État pour le texte de la nouvelle tâche
  const [inputValue, setInputValue] = useState('');

  // Fonction pour ajouter une nouvelle tâche
  const addTodo = () => {
    if (inputValue.trim() !== '') {
      setTodos([...todos, { id: Date.now(), text: inputValue, completed: false }]);
      setInputValue(''); // Réinitialiser le champ
    }
  };

  // Fonction pour supprimer une tâche
  const deleteTodo = (id) => {
    setTodos(todos.filter(todo => todo.id !== id));
  };

  // Fonction pour marquer une tâche comme complétée
  const toggleComplete = (id) => {
    setTodos(todos.map(todo =>
      todo.id === id ? { ...todo, completed: !todo.completed } : todo
    ));
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>🚀 Todo App - CI/CD Demo</h1>
        <p>Application React avec Docker et GitHub Actions</p>
        
        {/* Section d'ajout de tâche */}
        <div className="input-container">
          <input
            type="text"
            value={inputValue}
            onChange={(e) => setInputValue(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && addTodo()}
            placeholder="Ajouter une nouvelle tâche..."
            className="todo-input"
          />
          <button onClick={addTodo} className="add-button">
            Ajouter
          </button>
        </div>

        {/* Liste des tâches */}
        <div className="todos-container">
          {todos.length === 0 ? (
            <p className="empty-message">Aucune tâche. Ajoutez-en une ! ✨</p>
          ) : (
            <ul className="todo-list">
              {todos.map(todo => (
                <li key={todo.id} className="todo-item">
                  <div className="todo-content">
                    <input
                      type="checkbox"
                      checked={todo.completed}
                      onChange={() => toggleComplete(todo.id)}
                      className="checkbox"
                    />
                    <span className={todo.completed ? 'completed' : ''}>
                      {todo.text}
                    </span>
                  </div>
                  <button
                    onClick={() => deleteTodo(todo.id)}
                    className="delete-button"
                  >
                    ❌
                  </button>
                </li>
              ))}
            </ul>
          )}
        </div>

        {/* Statistiques */}
        <div className="stats">
          <p>Total: {todos.length} | Complétées: {todos.filter(t => t.completed).length}</p>
        </div>
      </header>
    </div>
  );
}

export default App;