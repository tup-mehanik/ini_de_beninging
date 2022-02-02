USE yah_ini_dee;
GO

--������� �� ����� �� ��������� ����
CREATE OR ALTER PROCEDURE sp_Edit_Name
	(
		@firstName NVARCHAR(50),
		@middleName NVARCHAR(50),
		@surname NVARCHAR(50),
		@email NVARCHAR(100)
	)
AS
	BEGIN
		UPDATE Property_Custodians
		SET First_Name = @firstName,
            Middle_Name = @middleName,
			Surname = @surname
		WHERE  Email = @email
	END
GO

--����������� �� ��� �� ��������� ����
CREATE OR ALTER PROCEDURE sp_Edit_Egn
	(
		@egn NVARCHAR(10),
		@email NVARCHAR(100)
	)
AS
	BEGIN
		UPDATE Property_Custodians
		SET EGN = @egn
		WHERE  Email = @email
	END
GO

--����������� �� �������� �� ��������� ����
CREATE OR ALTER PROCEDURE sp_Edit_Contacts
	(
		@phone NVARCHAR(10),
		@email NVARCHAR(100),
		@newEmail NVARCHAR(100)
	)
AS
	BEGIN
		UPDATE Property_Custodians
		SET Phone = @phone,
		Email = @newEmail
		WHERE  Email = @email
	END
GO

--����������� �� �����
CREATE OR ALTER PROCEDURE sp_Edit_Custodian
	(
		@email NVARCHAR(100),
		@type INT,
		@msg NVARCHAR(MAX) = NULL OUTPUT
	)
AS
	IF @type = 1
	BEGIN
		EXECUTE sp_Edit_Name
		'������', '�������', '��������',
		@email
		SET @msg = '������� �� ������ �� ���������� �������'
		PRINT @msg
	END

	IF @type = 2
	BEGIN
		EXECUTE sp_Edit_Egn
			'8903113849',
			@email
		SET @msg = '��� �� ������ � ���������� �������'
		PRINT @msg
	END

	IF @type = 3
	BEGIN
		EXECUTE sp_Edit_Contacts
			'0887319345',
			@email, 'b.martinov@au.com'
		SET @msg = '���������� �� ������ �� ���������� �������'
		PRINT @msg
	END
GO