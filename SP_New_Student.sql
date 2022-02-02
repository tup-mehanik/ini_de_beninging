USE yah_ini_dee;
GO

CREATE OR ALTER PROCEDURE sp_New_Student
	(
		@firstName NVARCHAR(50),
		@middleName NVARCHAR(50),
		@surname NVARCHAR(50),
		@egn NVARCHAR(10),
		@phone NVARCHAR(10),
		@email NVARCHAR(100),
		@city NVARCHAR(256),
		@address NVARCHAR(256),
		@school NVARCHAR(256),
		@password NVARCHAR(50),
		@msg NVARCHAR(MAX) = NULL OUTPUT
	)
AS
	BEGIN TRY
		INSERT INTO dbo.Students(
					[First_Name],
					[Middle_Name],
					[Surname],
					[EGN],
					[Phone],
					[Email],
					[City_ID],
					[Address],
					[School_ID])
		VALUES (@firstName,
				@middleName,
				@surname,
				@egn,
				@phone,
				@email,
				dbo.udf_Check_City(@city),
				@address,
				dbo.udf_Check_School(@school))
		SET @msg = 'Ученикът е добавен успешно'
		PRINT @msg
		DECLARE @id INT;
		SET @id = (SELECT TOP(1) ID FROM Students ORDER BY ID DESC)
		EXECUTE dbo.sp_New_login
			@email,
			@password,
			0,
			@id
	END TRY
	BEGIN CATCH
		SET @msg = ERROR_MESSAGE()
		PRINT @msg
	END CATCH
GO

EXECUTE dbo.sp_New_Student
		'Теодора', 'Николаева', 'Маринова',
		'0542173499',
		'0856127836',
		't.marinova@au.com',
		'София', 'кв. Манастирски ливади, бл. 20, ап. 17',
		'Богоров',
		'qwb373791dxb'