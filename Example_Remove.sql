USE yah_ini_dee;
GO

SELECT * FROM Applications
WHERE Student_ID = 8;
GO

SELECT * FROM Advertisements
WHERE ID IN (5,11);
GO

SELECT * FROM Students
WHERE ID IN (7,8,9);

EXECUTE sp_Remove_Student
	'd.krastev@au.com', '0550105029'
GO

SELECT * FROM Students
WHERE ID IN (7,8,9);
GO

SELECT * FROM Applications
WHERE ID IN (19,20,21,22);
GO

SELECT * FROM Advertisements
WHERE ID IN (5,11);
GO