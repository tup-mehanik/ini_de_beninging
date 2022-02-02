USE yah_ini_dee;
GO

--������� ID �� ���� �� ����� ��
CREATE OR ALTER FUNCTION udf_Check_City(@name NVARCHAR(254))
RETURNS INT AS
BEGIN
	DECLARE @id INT;
	SET @id = (SELECT ID FROM Cities WHERE Name= @name)
	RETURN @id
END
GO

--������� ID �� ������� �� ���� �� ����� ��
CREATE OR ALTER FUNCTION udf_Check_School(@name NVARCHAR(254))
RETURNS INT AS
BEGIN
	DECLARE @id INT;
	SET @id = (SELECT ID FROM Schools WHERE Name LIKE CONCAT('%', @name, '%'))
	RETURN @id
END
GO

--����� ID �� ��������� ���� �� ����� � ���
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

--����� ID �� ���� �� ������� �� ����� � ��������� �����
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