-- Eliminar la base de datos si existe para empezar desde cero
DROP DATABASE IF EXISTS menu1;

-- Crear la base de datos
CREATE DATABASE menu1;
USE menu1;

-- Crear tabla de usuarios
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(64) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Crear tabla de menú
CREATE TABLE menu_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insertar usuario administrador
DELETE FROM users WHERE username = 'admin';
INSERT INTO users (username, password, email, is_admin)
VALUES ('admin', SHA2('admin123', 256), 'admin@restaurant.com', TRUE);

-- Verificar que el usuario se creó correctamente
SELECT * FROM users WHERE username = 'admin';

-- Insertar elementos de menú de ejemplo
INSERT INTO menu_items (name, price, category) VALUES
('Ensalada César', 8.99, 'Entradas'),
('Pizza Margarita', 12.99, 'Platos Fuertes'),
('Limonada', 3.99, 'Bebidas'),
('Tiramisú', 6.99, 'Postres'); 