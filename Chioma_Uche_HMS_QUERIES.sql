-- 1. What are the top four diagnoses treated in the hospital
SELECT diagnosis, COUNT(*) AS total_number
FROM medicalrecords
GROUP BY diagnosis 
ORDER BY total_number DESC
LIMIT 4;


-- 2. Which room type is frequently occupied in the hospital by patients?
SELECT room_type, 
COUNT(*) AS frequently_occupied
FROM Rooms AS r
JOIN Room_patient_assignment AS rpa
ON r.room_id = rpa.room_id
GROUP BY r.room_type
ORDER BY room_type DESC
LIMIT 1;


-- 3. Who are the patients that have outstanding balances on their bills?

SELECT p.first_name, p.last_name, b.balance_remaining
FROM Patients AS p
INNER JOIN Bills AS b
ON p.patient_id = b.patient_id
WHERE b.balance_remaining > 0;



-- 4. Which staff members have the most interactions with patients?
SELECT s.staff_id, s.first_name, s.last_name, 
COUNT(*) AS interaction_count
FROM Patient_staff_interaction AS Psi
JOIN Staff AS s
ON Psi.staff_id = s.staff_id
GROUP BY s.staff_id
ORDER BY interaction_count DESC;


--  5. Find the departments having the at least 5 number of 'hypertension' patients?
 SELECT  dep_name, 
 COUNT(*) AS hyper_patients
 FROM Departments AS d
 JOIN Staff AS s
 ON d.dep_id = s.dep_id
 JOIN Medicalrecords AS md
 ON md.staff_id = s.staff_id
 WHERE md.diagnosis = 'Hypertension'
 GROUP BY dep_name
 HAVING hyper_patients >= 5;

 
 -- 6. Find patients who have been assigned to a private room more than 1 times.
SELECT p.first_name, p.last_name,
COUNT(*) AS number_of_assignment
FROM Patients AS p
JOIN Room_patient_assignment AS rpa
ON rpa.patient_id = p.patient_id
WHERE p.patient_id IN
	(SELECT patient_id
	FROM Rooms AS r
	JOIN Room_patient_assignment AS a
	ON r.room_id = a.room_id
	WHERE room_type = 'Private')
GROUP BY p.first_name, p.last_name
HAVING number_of_assignment > 1;


 -- 7. What is average total cost of bills for patients who have occupied a room, with an average cost per patient between £1000 and £1700
SELECT p.first_name, p.last_name, ROUND(AVG(total_cost),2) AS Average_cost
FROM Patients AS p
JOIN Room_patient_assignment AS rpa
ON p.patient_id = rpa.patient_id
JOIN Bills AS b
ON b.patient_id = rpa.patient_id
WHERE p.patient_id IN 
	(SELECT ps.patient_id
	FROM Patients AS ps 
	JOIN Room_patient_assignment AS ra
	ON ps.patient_id = ra.patient_id) 
GROUP BY p.first_name, p.last_name
HAVING Average_cost BETWEEN 1000 and 1700;


-- 8.  Create views for appointment schedule
CREATE VIEW appointmentschedule AS
SELECT 
	p.first_name AS patient_first_name, 
    p.last_name AS patient_last_name, 
    a.date, a.time, 
    a.purpose, 
    s.first_name AS staff_first_name, 
    s.last_name AS staff_last_name, 
    d.dep_name
	FROM Patients AS p
	JOIN Appointments AS a
	ON p.patient_id = a.patient_id
	JOIN Staff AS s
	ON a.staff_id = s.staff_id
	JOIN Departments AS d
	ON s.dep_id = d.dep_id;
    
SELECT * FROM appointmentschedule;


-- 9. Write a function that calculates the age based on the dob (stored function).
    -- today's year - year from the date of birth = age in year
    -- if the birth month is > the current month, then we have not reached the birth month
    -- if the birth month is equal to the current date, then check the day
    -- if the birth day  is greater than the current day, then the patient isn't completely a year older.
    -- So age = age-1

DELIMITER //
CREATE FUNCTION age_calculation(dob DATE) 
RETURNS INT READS SQL DATA
BEGIN
DECLARE today DATE;
DECLARE age INT;
SET today = CURRENT_DATE();
SET age = YEAR(today) - YEAR(dob);

IF (MONTH(dob) > MONTH(today)) 
OR (MONTH(dob) = MONTH(today)) 
AND DAY(dob) > DAY(today) THEN
	SET age = age-1;
END IF;

RETURN age;

END//

-- implementation of the stored function that have been created. 
   -- Find patients aged 40 and above
   
SELECT first_name, last_name, dob, age_calculation(dob) AS age
FROM Patients
WHERE age_calculation(dob) >= 40; 


-- 10. Stored Procedures (to add payment)
   --  record a new payment towards a bill, automatically adjusting the balance remaining and updating the payment status. 

DELIMITER //
CREATE PROCEDURE AddingPayment(
    IN p_bill_id INT,
    IN p_payment_amount DECIMAL(10,2)
)
BEGIN
    DECLARE v_total_cost DECIMAL(10,2);
    DECLARE v_balance_remaining DECIMAL(10,2);
    DECLARE new_status VARCHAR(30);
    
    -- Check if there are any previous payments for this bill
    
    DECLARE total_payments DECIMAL(10,2);
    SELECT IFNULL(SUM(payment_amount), 0) INTO total_payments 
    FROM Payments 
    WHERE bill_id = p_bill_id;
    
    -- Retrieve current bill details
    
    SELECT total_cost, balance_remaining INTO v_total_cost, v_balance_remaining 
    FROM Bills 
    WHERE bills_id = p_bill_id;
    
    -- Calculate new balance
    
    SET v_balance_remaining = v_balance_remaining - p_payment_amount;
    
    -- Determine new payment status
    
    IF v_balance_remaining = 0 THEN
        SET new_status = 'Fully Paid';
    ELSEIF total_payments = 0 AND p_payment_amount > 0 THEN
        SET new_status = 'Partial Payment';
    ELSEIF total_payments = 0 AND p_payment_amount = 0 THEN
        SET new_status = 'No Payment';
    ELSE
        SET new_status = 'Partial Payment';
    END IF;
    
    -- Update bill with new balance and status
    
    UPDATE Bills 
    SET balance_remaining = v_balance_remaining, payment_status = new_status 
    WHERE bills_id = p_bill_id;
    
    -- Insert new payment record only if payment amount is greater than 0
    
    IF p_payment_amount > 0 THEN
        INSERT INTO Payments (bill_id, payment_amount, payment_date) VALUES (p_bill_id, p_payment_amount, CURRENT_DATE());
    END IF;
END//

DELIMITER ;

-- Calling/ testing the stored procedure
 CALL AddingPayment(7, 100);
 
 
 SELECT * FROM Bills;
 
 SELECT *
 FROM Bills AS b
 JOIN Payments AS p
 ON b.bills_id = p.bill_id
 WHERE bills_id = 7;
 
 
-- 11. Triggers (to prevent double appointments booking)
   --  call before I insert booking. 
   --  check if there is already an appointment for the same staff, date and time.
   --  if there is an existing appointment, prevent new appointement entry.
 
DELIMITER //
CREATE TRIGGER PreventDoubleBooking
BEFORE INSERT ON appointments
FOR EACH ROW
BEGIN
	-- check if there is already an appointment for the same staff, date and time.
    DECLARE existingAppointment INT;
    SET existingAppointment = ( SELECT COUNT(*)
								FROM appointments
                                WHERE staff_id = NEW.staff_id
									AND date = NEW.date
                                    AND time = NEW.time 
                                    );
                                    
	-- If there is an existing appointment, prevent new appointement entry.
    
	IF existingAppointment > 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This staff is not available at this date and time';
	END IF;
END//

DELIMITER ;

 -- test the trigger logic
 
INSERT INTO Appointments (patient_id, staff_id, date, time, purpose) 
VALUES (33, 42, '2023-03-12', '14:00:00', 'Follow-up');

-- 12. EVENTS (Patient's follow-up schedule)
DELIMITER //

CREATE EVENT IF NOT EXISTS ScheduleFollowUp
ON SCHEDULE EVERY 1 DAY
DO 
BEGIN
    -- Insert follow-up appointments for patients
    INSERT INTO Appointments(patient_id, staff_id, date, time, purpose)
    SELECT patient_id, 
        -- Select a staff member from the same department as the patient's last treatment
        (SELECT s.staff_id
         FROM Staff AS s
         WHERE s.dep_id = (
             SELECT dep_id
             FROM MedicalRecords AS mr
             JOIN Staff s ON mr.staff_id = s.staff_id
             WHERE mr.patient_id = rpa.patient_id
             ORDER BY mr.visit_date DESC
             LIMIT 1)
         ORDER BY RAND()
         LIMIT 1),
        CURRENT_DATE() + INTERVAL 1 MONTH AS follow_up_date, 
        '10:00:00', 
        'Scheduled Follow-Up'
    FROM room_patient_assignment AS rpa
    WHERE 
        -- Assuming release_date indicates when the treatment was completed
        rpa.release_date < CURRENT_DATE() AND
        rpa.release_date > CURRENT_DATE() - INTERVAL 7 DAY AND
        NOT EXISTS (
            -- Check if a follow-up appointment is already scheduled
            SELECT appointment_id
            FROM Appointments AS a
            WHERE a.patient_id = rpa.patient_id AND a.date > CURRENT_DATE()
            )
        GROUP BY rpa.patient_id;    

END//

DELIMITER ;

SELECT * FROM Appointments;

