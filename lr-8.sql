CREATE TABLE врачи (
    id_врача SERIAL PRIMARY KEY,
    фамилия VARCHAR(50) NOT NULL,
    имя VARCHAR(50),
    отчество VARCHAR(50),
    специальность VARCHAR(100) NOT NULL,
    стоимость_приема DECIMAL(10, 2) NOT NULL,
    процент_отчислений DECIMAL(5, 2) NOT NULL CHECK (процент_отчислений BETWEEN 0 AND 100)
);

CREATE TABLE пациенты (
    id_пациента SERIAL PRIMARY KEY,
    фамилия VARCHAR(50) NOT NULL,
    имя VARCHAR(50),
    отчество VARCHAR(50),
    дата_рождения DATE,
    адрес TEXT
);

CREATE TABLE приемы (
    id_приема SERIAL PRIMARY KEY,
    id_врача INT REFERENCES врачи(id_врача),
    id_пациента INT REFERENCES пациенты(id_пациента),
    дата_приема DATE NOT NULL,
    стоимость_приема DECIMAL(10, 2) NOT NULL
);

CREATE TABLE платежи (
    id_платежа SERIAL PRIMARY KEY,
    id_приема INT REFERENCES приемы(id_приема),
    сумма DECIMAL(10, 2) NOT NULL,
    дата_оплаты TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE зарплаты_врачей (
    id_начисления SERIAL PRIMARY KEY,
    id_врача INT REFERENCES врачи(id_врача),
    id_приема INT REFERENCES приемы(id_приема),
    брутто_зарплата DECIMAL(10, 2),
    нетто_зарплата DECIMAL(10, 2)
);

CREATE OR REPLACE FUNCTION calculate_salary() RETURNS TRIGGER AS $$
BEGIN
    NEW.брутто_зарплата := (SELECT стоимость_приема FROM приемы WHERE id_приема = NEW.id_приема) * (SELECT процент_отчислений FROM врачи WHERE id_врача = NEW.id_врача) / 100;
    NEW.нетто_зарплата := NEW.брутто_зарплата - NEW.брутто_зарплата * 0.13;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calculate_salary
BEFORE INSERT ON зарплаты_врачей
FOR EACH ROW
EXECUTE FUNCTION calculate_salary();