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




-- Ejercicio 2 --

CREATE SCHEMA recursos_humanos;
SET search_path TO recursos_humanos;


CREATE TABLE IF NOT EXISTS Depart(
    id_departamento INT,
    nombre TEXT NOT NULL, 
    CONSTRAINT pk_id_departamento PRIMARY KEY (id_departamento),
    CONSTRAINT uq_nombre UNIQUE (nombre)
);

CREATE TABLE IF NOT EXISTS Emple(
    id_empleado INT,
    nombre VARCHAR NOT NULL,
    id_departamento INT,
    CONSTRAINT pk_id_empleado PRIMARY KEY (id_empleado),
    CONSTRAINT fk_id_departamento FOREIGN KEY (id_departamento)
    REFERENCES Depart(id_departamento)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);



-- Ejercicio 3 -- 

CREATE TABLE Alumnos (
    id_alumno INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);
CREATE TABLE Cursos (
    id_curso INT PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL
);


CREATE TABLE IF NOT EXISTS Inscripciones(
    id_alumno INT NOT NULL,
    id_curso INT NOT NULL,
    fecha_inscripcion DATE NOT NULL DEFAULT CURRENT_DATE,
    estado TEXT,
    CONSTRAINT ck_estado CHECK(
        estado IN ('pendiente', 'aceptada', 'rechazada')
    ),
    CONSTRAINT pk_id_alumno_curso PRIMARY KEY (id_alumno, id_curso),
    CONSTRAINT fk_id_alumno FOREIGN KEY (id_alumno) REFERENCES Alumnos(id_alumno)
    ON DELETE CASCADE,
    CONSTRAINT fk_id_curso FOREIGN KEY (id_curso) REFERENCES Cursos(id_curso)
    ON DELETE CASCADE
);



-- Ejercicio 4 --

CREATE TABLE misalumnos (
    id_alumno INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

ALTER TABLE misalumnos
ADD fecha_nacimiento DATE NOT NULL,
ADD edad INT CHECK(edad BETWEEN 18 AND 100),
ADD telefono VARCHAR(9) CHECK(telefono ~'^[67]\d{8}$');

CREATE INDEX ind_nombre ON misalumnos(nombre);