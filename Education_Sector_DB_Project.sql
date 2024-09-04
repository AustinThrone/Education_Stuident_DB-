


--EducationStuidentDB

--CREATE DATABASE <DATABASE NAME>
CREATE DATABASE EducationStuidentDB_1

---STUDENT TABLE
CREATE TABLE Stu_dent (StudentID NVARCHAR(5) PRIMARY KEY, StudentName nvarchar(50) not null, Age int not null, ClassID NVARCHAR(5) not null, StateID NVARCHAR(5) NOT NULL)
INSERT INTO Stu_dent(StudentID, StudentName, Age, ClassID, StateID)
VALUES ('S01', 'Alice Brown',16, '1', '101'),
      ('S02','Bob White', 17, '2', '102'),
	  ('S03', 'Charlie Black', 17, '3', '103'),
	  ('S04', 'Daisy Green', 16, '4', '104'),
	  ('S05', 'Edward Blue', 14, '1', '105'),
	  ('S06', 'Fiona Red', 15, '2', '106'),
	  ('S07', 'George Yellow', 18, '3', '107'),
	  ('S08', 'Hannah Purple', 16, '4', '108'),
	  ('S09', 'Ian Orangen', 17, '1', '109'),
	  ('S10', 'Jane Grey', 14, '2', '110')
	  SELECT * FROM Stu_dent

--Class master table
CREATE TABLE Class_Master (ClassID NVARCHAR(50) PRIMARY KEY, ClassName nvarchar(50) not null, TeacherID NVARCHAR(5) NOT NULL)
INSERT INTO Class_Master (ClassID, ClassName, TeacherID)
VALUES ( '1', '10th', 'T01'),
       ( '2', '9th', 'T02'),
	   ( '3', '11th', 'T03'),
	   ( '4', '12th', 'T04')
	   SELECT * FROM Class_Master


--TeacherMaster

CREATE TABLE Teacher_Master (TeacherID NVARCHAR(5) PRIMARY KEY, TeacherName nvarchar(50) not null, Subject nvarchar(50) not null)
insert into Teacher_Master( TeacherID, TeacherName, Subject)
VALUES ('T01', 'Mr.Johnson', 'Mathematics'),
       ( 'T02', 'Ms.Smith', 'Science'),
	   ( 'T03', 'Mr.Williams', 'English'),
	   ( 'T04', 'Ms.Brown', 'History')
	   SELECT * FROM Teacher_Master



	   --STATEMASTER
CREATE TABLE StateMaster_1( StateID NVARCHAR(5) PRIMARY KEY, StateName nvarchar(50) not null)
INSERT INTO StateMaster_1(StateID, StateName)
VALUES ( '101', 'Lagos'),
        ( '102', 'Abuja'),
		( '103', 'Kano'),
		( '104', 'Delta'),
		( '105', 'Ido'),
		( '106', 'Ibada'),
		( '107', 'Enugu'),
		( '108', 'Kaduna'),
		( '109', 'Ogun'),
		( '110', 'Anambra')
		SELECT * FROM StateMaster_1


		
-- Fetch students with the same age:

SELECT * 
FROM Stu_dent 
WHERE Age IN (
  SELECT Age 
  FROM Stu_dent 
  GROUP BY Age 
  HAVING COUNT(Age) > 1
)


--Find the second youngest student and their class and teacher:

WITH RankedStudent AS (
  SELECT 
    S.StudentName, 
    S.Age, 
    C.ClassName, 
    T.TeacherName, 
    ROW_NUMBER() OVER (ORDER BY S.Age ASC) AS rowNum
  FROM 
    Stu_dent S
  INNER JOIN 
    Class_Master C ON S.ClassID = C.ClassID
  INNER JOIN 
    Teacher_Master T ON C.TeacherID = T.TeacherID
)
SELECT 
  StudentName, 
  Age, 
  ClassName, 
  TeacherName
FROM 
  RankedStudent
WHERE 
  rowNum = 2


--Get the maximum age per class and the student name:

WITH RankedStudent AS (
  SELECT 
    S.StudentName, 
    S.Age, 
    C.ClassName, 
    ROW_NUMBER() OVER (PARTITION BY C.ClassName ORDER BY S.Age DESC) AS rowNum
  FROM 
    Stu_dent S
  INNER JOIN 
    Class_Master C ON S.ClassID = C.ClassID
)
SELECT 
  StudentName, 
  Age, 
  ClassName
FROM 
  RankedStudent
WHERE 
  rowNum = 1


-- Teacher-wise count of students sorted by count in descending order:

SELECT 
  T.TeacherName, 
  COUNT(S.StudentID) AS CountOfStudents
FROM 
  Stu_dent S
INNER JOIN 
  Class_Master C ON S.ClassID = C.ClassID
INNER JOIN 
  Teacher_Master T ON C.TeacherID = T.TeacherID
GROUP BY 
  T.TeacherName
ORDER BY 
  CountOfStudents DESC


--Fetch only the first name from the StudentName and append the age:

SELECT 
  CONCAT(LEFT(S.StudentName, CHARINDEX(' ', S.StudentName)
  - 1), '_', S.Age) AS FirstName_Age
FROM 
  Stu_dent S


--Fetch students with odd ages:

SELECT * 
FROM Stu_dent 
WHERE Age % 2 <> 0


--Create a view to fetch student details with an age greater than 15:

CREATE VIEW VW_StudentDetails AS 
SELECT * 
FROM Stu_dent 
WHERE Age > 15



--Create a procedure to update the student's age by 1 year where the class is '10th Grade' and the teacher is not 'Mr. Johnson':

CREATE PROCEDURE SP_UpdateStudentAge 
AS
BEGIN
  UPDATE S
  SET S.Age = S.Age + 1
  FROM Stu_dent S
  INNER JOIN Class_Master C ON S.ClassID = C.ClassID
  INNER JOIN Teacher_Master T ON C.TeacherID = T.TeacherID
  WHERE C.ClassName = '10th' AND T.TeacherName <> 'Mr.Johnson'
END
GO
EXEC SP_UpdateStudentAge


--Create a stored procedure to fetch student details along with their class,
--teacher, and state, including error handling:

CREATE PROCEDURE SP_GetStudentDetails 
AS
BEGIN
  BEGIN TRY
    SELECT 
      S.StudentID, 
      S.StudentName, 
      S.Age, 
      C.ClassName, 
      T.TeacherName, 
      SM.StateName
    FROM 
      Stu_dent S
    INNER JOIN 
      Class_Master C ON S.ClassID = C.ClassID
    INNER JOIN 
      Teacher_Master T ON C.TeacherID = T.TeacherID
    INNER JOIN 
      StateMaster_1 SM ON S.StateID = SM.StateID
  END TRY
  BEGIN CATCH
    DECLARE @ErrorMessage nvarchar(4000)
    SET @ErrorMessage = ERROR_MESSAGE()
    RAISERROR (@ErrorMessage, 16, 1)
  END CATCH
END
GO
EXEC SP_GetStudentDetails


