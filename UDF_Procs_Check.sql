USE yah_ini_dee;
GO

--връщаща ID на град по името му
CREATE OR ALTER FUNCTION udf_Check_City(@name NVARCHAR(254))
RETURNS INT AS
BEGIN
	DECLARE @id INT;
	SET @id = (SELECT ID FROM Cities WHERE Name= @name)
	RETURN @id
END
GO

--връщаща ID на училище по част от името му
CREATE OR ALTER FUNCTION udf_Check_School(@name NVARCHAR(254))
RETURNS INT AS
BEGIN
	DECLARE @id INT;
	SET @id = (SELECT ID FROM Schools WHERE Name LIKE CONCAT('%', @name, '%'))
	RETURN @id
END
GO

--връща ID на отговорно лице по имена и ЕГН
CREATE OR ALTER FUNCTION udf_Check_Custodian(@name NVARCHAR(256), @egn NVARCHAR(10))
RETURNS INT AS
BEGIN
	DECLARE @id INT;
	SET @id = (SELECT ID FROM Property_Custodians
				WHERE CONCAT_WS(' ', First_Name, Middle_Name, Surname) = @name
				AND EGN = @egn)
	RETURN @id
END
GO

--връща ID на лице за контакт по имена и телефонен номер
CREATE OR ALTER FUNCTION udf_Check_Contact(@name NVARCHAR(256), @phone NVARCHAR(10))
RETURNS INT AS
BEGIN
	DECLARE @id INT;
	SET @id = (SELECT ID FROM Contact_People
				WHERE CONCAT_WS(' ', First_Name, Middle_Name, Surname) = @name
				AND Phone = @phone)
	RETURN @id
END
GO