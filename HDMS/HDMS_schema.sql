CREATE DATABASE hospital_management_system;

USE hospital_management_system;


CREATE TABLE Patients (
  patient_id INT PRIMARY KEY AUTO_INCREMENT,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50)  NOT NULL,
  dob DATE,
  gender VARCHAR(20),
  contact_number VARCHAR(50),
  email VARCHAR(50) UNIQUE,
  address VARCHAR(50),
  postcode VARCHAR(10)
);

CREATE TABLE Rooms(
room_id INT PRIMARY KEY AUTO_INCREMENT,
room_type VARCHAR(50)
);

ALTER TABLE Room_patient_assignment 
ADD CONSTRAINT FOREIGN KEY (room_id) REFERENCES Rooms(room_id);

CREATE TABLE Room_patient_assignment (
  room_pat_id INT PRIMARY KEY AUTO_INCREMENT,
  room_id INT,
  patient_id INT, 
  assign_date DATE,
  release_date DATE,
  FOREIGN KEY(patient_id) REFERENCES Patients(patient_id)
  
);

ALTER TABLE Bills
ADD CONSTRAINT FOREIGN KEY (Patient_id) REFERENCES Patients(Patient_id);

CREATE TABLE Bills (
  bills_id INT PRIMARY KEY AUTO_INCREMENT,
  patient_id INT, 
  total_cost DECIMAL(10,2),
  balance_remaining DECIMAL(10,2),
  payment_status VARCHAR(30),
  date_issued DATE
);

CREATE TABLE Payments (
  payment_id INT PRIMARY KEY AUTO_INCREMENT,
  bill_id INT, 
  payment_amount DECIMAL(10,2),
  payment_date DATE,
  FOREIGN KEY(bill_id) REFERENCES Bills(bills_id)
);

CREATE TABLE Departments (
  dep_id INT PRIMARY KEY AUTO_INCREMENT ,
  dep_name VARCHAR(50)
);


CREATE TABLE Staff (
  staff_id INT PRIMARY KEY AUTO_INCREMENT ,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  dep_id INT,
  staff_type VARCHAR(50),
  contact_num VARCHAR(50),
  email VARCHAR(50) UNIQUE,
  role VARCHAR(50),
  address VARCHAR(50),
  postcode VARCHAR(10),
  FOREIGN KEY(dep_id) REFERENCES Departments(dep_id)
);


CREATE TABLE Medicalrecords (
  medrecord_id INT PRIMARY KEY AUTO_INCREMENT,
  patient_id INT, 
  staff_id INT, 
  diagnosis VARCHAR(255),
  prescription VARCHAR(255),
  visit_date TIMESTAMP,
  treatment VARCHAR(255),
  FOREIGN KEY(staff_id) REFERENCES Staff(staff_id),
  FOREIGN KEY(patient_id) REFERENCES Patients(patient_id)
);
SELECT * FROM Medicalrecords;

DELETE FROM Medicalrecords
WHERE medrecord_id IN (8,40,47);

INSERT INTO Medicalrecords (medrecord_id, patient_id, staff_id, diagnosis, prescription, visit_date, treatment)
VALUES (8, 12, 7,'Pregnancy','Medicine7', '2023-08-18 20:05:00', 'Natural Birth' ),
		(40, 21, 38, 'Pregnancy','Medicine39', '2023-02-11 01:57:00', 'CS'),
        (47, 26, 41, 'Pregnancy','Medicine46', '2023-11-03 01:51:00', 'Natural Birth');

CREATE TABLE Appointments (
  appointment_id INT PRIMARY KEY AUTO_INCREMENT,
  patient_id INT NOT NULL,
  staff_id INT NOT NULL,
  date DATE NOT NULL,
  time TIME NOT NULL,
  purpose VARCHAR(255),
  FOREIGN KEY(staff_id) REFERENCES Staff(staff_id),
  FOREIGN KEY(patient_id) REFERENCES Patients(patient_id)
  );

CREATE TABLE Patient_staff_interaction (
  interaction_id INT PRIMARY KEY AUTO_INCREMENT,
  staff_id INT, 
  patient_id INT, 
  date TIMESTAMP,
  note VARCHAR(255),
  FOREIGN KEY(staff_id) REFERENCES Staff(staff_id),
  FOREIGN KEY(patient_id) REFERENCES Patients(patient_id)
);






