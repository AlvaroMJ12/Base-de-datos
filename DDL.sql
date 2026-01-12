CREATE TABLE IF NOT EXISTS Empleados (
    id_empleado SERIAL PRIMARY KEY,
    dni VARCHAR(9) UNIQUE NOT NULL CHECK
    (dni~'^[0-9]{8}[A-Z]$'), 
    nombre VARCHAR(100) NOT NULL, 
    salario DECIMAL(10, 2) NOT NULL CHECK-- DECIMAL(numeros totales, numero decimal) --
    (salario > 1000),
    fecha_contratacion DATE NOT NULL,
    departamento VARCHAR(50) DEFAULT 'Sin asignar',
    categoria TEXT CHECK
    (categoria IN ('junior', 'senior', 'manager')),
    activo BOOLEAN DEFAULT TRUE
);

CREATE SCHEMA recursos_humanos;
SET search_path TO recursos_humanos;


CREATE TABLE Depart IF NOT EXISTS(COMMENT
    id_departamento INT PRIMARY KEY,
    nombre TEXT UNIQUE NO NULL
);