-- ========== DDL ==========
CREATE TABLE IF NOT EXISTS lockers (
    locker_number INT PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS membership_plans (
    plan_name VARCHAR(100) PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS trainers (
    trainer_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    specialty VARCHAR(255),
    years_of_experience INT CHECK (years_of_experience >= 0)
);

CREATE TABLE IF NOT EXISTS members (
    member_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    email VARCHAR(255) UNIQUE,
    start_date DATE NOT NULL DEFAULT CURRENT_DATE,
    plan_name VARCHAR(100) NOT NULL REFERENCES membership_plans(plan_name) ON UPDATE CASCADE ON DELETE RESTRICT,
    locker_number INT UNIQUE REFERENCES lockers(locker_number) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS classes (
    class_name VARCHAR(100) PRIMARY KEY,
    scheduled_time TIMESTAMP NOT NULL,
    duration INT NOT NULL CHECK (duration > 0),          -- minutes
    max_capacity INT NOT NULL CHECK (max_capacity > 0),
    trainer_id INT NOT NULL REFERENCES trainers(trainer_id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS bookings (
    member_id INT NOT NULL REFERENCES members(member_id) ON DELETE CASCADE,
    class_name VARCHAR(100) NOT NULL REFERENCES classes(class_name) ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (member_id, class_name)
);

-- ========== DML ==========
INSERT INTO lockers (locker_number) VALUES (101),(102),(103),(104),(105);

INSERT INTO membership_plans (plan_name) VALUES ('Basic'),('Premium'),('VIP');

INSERT INTO trainers (name, specialty, years_of_experience) VALUES
('Karim',  'Yoga',     8),
('Laila',  'Cardio',   5),
('Hassan', 'Strength', 12),
('Dina',   'Pilates',  3);

INSERT INTO members (name, phone_number, email, start_date, plan_name, locker_number) VALUES
('Ahmed',  '01011111111', 'ahmed@mail.com',  '2026-01-10', 'Basic',   101),
('Mona',   '01022222222', 'mona@mail.com',   '2026-02-15', 'Premium', 102),
('Omar',   '01033333333', 'omar@mail.com',   '2026-03-01', 'VIP',     103),
('Salma',  '01044444444', 'salma@mail.com',  '2026-03-20', 'Basic',   NULL),
('Youssef','01055555555', 'youssef@mail.com','2026-04-05', 'Premium', NULL),
('Nada',   '01066666666', 'nada@mail.com',   '2026-05-12', 'VIP',     104);

INSERT INTO classes (class_name, scheduled_time, duration, max_capacity, trainer_id) VALUES
('Morning Yoga',   '2026-10-10 08:00', 60, 15, 1),
('HIIT Cardio',    '2026-10-10 18:00', 45, 3,  2),
('Power Lifting',  '2026-10-11 17:00', 90, 10, 3),
('Pilates Basics', '2026-10-12 10:00', 50, 12, 4),
('Evening Yoga',   '2026-10-12 19:00', 60, 15, 1);

INSERT INTO bookings (member_id, class_name) VALUES
(1,'Morning Yoga'),(1,'HIIT Cardio'),
(2,'Morning Yoga'),(2,'HIIT Cardio'),(2,'Power Lifting'),
(3,'HIIT Cardio'),(3,'Power Lifting'),
(4,'Pilates Basics'),
(6,'Morning Yoga');

-- ========== DQL ==========
SELECT m.member_id, m.name, m.plan_name, l.locker_number
FROM members m
LEFT JOIN lockers l ON l.locker_number = m.locker_number
ORDER BY m.member_id;

-- 2
SELECT p.plan_name, COUNT(m.member_id) AS member_count
FROM membership_plans p
LEFT JOIN members m ON m.plan_name = p.plan_name
GROUP BY p.plan_name
ORDER BY member_count DESC;

-- 3
SELECT c.class_name, c.scheduled_time, c.duration, t.name AS trainer, t.specialty
FROM classes c
JOIN trainers t ON t.trainer_id = c.trainer_id
ORDER BY c.scheduled_time;

-- 4
SELECT c.class_name, c.max_capacity,
       COUNT(b.member_id) AS booked,
       c.max_capacity - COUNT(b.member_id) AS spots_left,
       (COUNT(b.member_id) >= c.max_capacity) AS is_full
FROM classes c
LEFT JOIN bookings b ON b.class_name = c.class_name
GROUP BY c.class_name, c.max_capacity
ORDER BY spots_left;

-- 5
SELECT m.name, COUNT(b.class_name) AS classes_booked,
       STRING_AGG(b.class_name, ', ' ORDER BY b.class_name) AS classes
FROM members m
JOIN bookings b ON b.member_id = m.member_id
GROUP BY m.member_id, m.name
HAVING COUNT(b.class_name) >= 2
ORDER BY classes_booked DESC;x