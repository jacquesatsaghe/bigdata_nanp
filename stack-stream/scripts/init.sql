CREATE DATABASE db_tickets;

\c db_tickets

CREATE SCHEMA IF NOT EXISTS test;

-- DROP TABLE db_tickets.test.utilisateurs CASCADE;

CREATE TABLE IF NOT EXISTS db_tickets.test.utilisateurs (
    id SERIAL PRIMARY KEY,              -- Identifiant auto-incrémenté et clé primaire
    nom VARCHAR(100) NOT NULL,          -- Texte limité à 100 caractères, obligatoire
    email VARCHAR(255),
    date_inscription DATE DEFAULT CURRENT_DATE, -- Valeur par défaut (date du jour)
    genre VARCHAR(10) CHECK (genre IN ('M', 'F')),
    val1 INTEGER CHECK (val1 >= 0) NOT NULL,
    val2 REAL
);

-- SOME INSERT

INSERT INTO db_tickets.test.utilisateurs (nom, email, genre, val1, val2) VALUES 
('Jean Dupont', 'jean@email.com', 'M', 17, 15.4),
('Lucie Terre', 'lucie@email.com', 'F', 14, 17.4),
('Marc Fox', 'marc@email.com', 'M', 18, 6.9),
('Paul Dupont', 'paul@email.com', 'M', 13, 13.1),
('Cathy Terre', 'cathy@email.com', 'F', 16, 11.7),
('Marie Fox', 'marie@email.com', 'F', 19, 16.9);
