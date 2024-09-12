#  Hospital-Database-Management-System

* I designed, developed and implemented a robust database to efficiently streamline hospital operations.

#  Step 1: Data modelling
* I designed a relational database for all patient-related information. I created a conceptual model of the database using Entity Relational diagram to identify the 10 entities and their relationships. 

Having One patient associated to many appointments, bills, medical records, room patient assignments, and patient staff interactions. (one-to-many).

One room to many room patient assignments. (one-to-many).

Many room patient assignments to one patient and one room (many-to-one).

One bill to one patient and many payments (one-to-many). 

Many payments to one bill (many-to-one).

One department to many staff (one-to-many).

one staff to one department, many medical records, appointments, and patient staff interactions (one-to-many).

One medical record to one patient and one staff (one-to-one).

One appointment to one patient and one staff (one-to-one).

One patient and one staff (many-to-one).



![alt text](<Screenshot 2024-05-31 061134.png>)

* I translated the conceptual model of the database using the relational schema, adding the attributes, Primary key, Foreign key, and Unique constraint on the email attribute in the staff and patient entities

![alt text](<Screenshot 2024-05-31 064441.png>)

* I designed the pysical structure of the database. Created the tables and specifying the data type and sizes of the attributes. Added some database management system features which includes, Stored Procedures,Trigger,View,Event and  normalization was done up to the 3rd normal form. 

![alt text](<Screenshot 2024-05-31 065236.png>)

# Step 2: Data analysis
* I retrieved the data from the database, to answer the questions relevant.
* I created VIEWS, a virtual table from patients, appointments, departments, and staff tables named “appointmentschedule” for easy access to patients' appointment times and staff they are scheduled to see.

![alt text](<Screenshot 2024-09-12 045948-1.png>)

* 

 


