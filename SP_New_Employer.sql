USE yah_ini_dee;
GO

CREATE OR ALTER PROCEDURE sp_New_Employer
	(
		@employerName NVARCHAR(200),
		@uic NVARCHAR(15),
		@city NVARCHAR(256),
		@seat NVARCHAR(200),
		@empEmail NVARCHAR(100),
		@custFirstName NVARCHAR(50),
		@custMiddleName NVARCHAR(50),
		@custSurname NVARCHAR(50),
		@custEgn NVARCHAR(10),
		@custPhone NVARCHAR(10),
		@custEmail NVARCHAR(100),
		@contFirstName NVARCHAR(50),
		@contMiddleName NVARCHAR(50),
		@contSurname NVARCHAR(50),
		@contPhone NVARCHAR(10),
		@contEmail NVARCHAR(100),
		@password NVARCHAR(50),
		@msg NVARCHAR(MAX) = NULL OUTPUT
	)
AS
	BEGIN TRY
		EXECUTE dbo.sp_New_Custodian
			@custFirstName,
			@custMiddleName,
			@custSurname,
			@custEgn,
			@custPhone,
			@custEmail
		EXECUTE dbo.sp_New_Contact
			@contFirstName,
			@contMiddleName,
			@contSurname,
			@contPhone,
			@contEmail
		INSERT INTO dbo.Employers(
					[Employer_Name],
					[UIC],
					[Custodian_ID],
					[City_ID],
					[Registered_Seat],
					[Contact_ID])
		VALUES (@employerName,
				@uic,
				dbo.udf_Check_Custodian(CONCAT_WS(' ', @custFirstName, @custMiddleName, @custSurname), @custEgn),
				dbo.udf_Check_City(@city),
				@seat,
				dbo.udf_Check_Contact(CONCAT_WS(' ', @contFirstName, @contMiddleName, @contSurname), @contPhone)
				)
		SET @msg = 'Работодателят е добавен успешно'
		PRINT @msg
		DECLARE @id INT;
		SET @id = (SELECT TOP(1) ID FROM Employers ORDER BY ID DESC)
		EXECUTE dbo.sp_New_login
			@empEmail,
			@password,
			0,
			@id
	END TRY
	BEGIN CATCH
		SET @msg = ERROR_MESSAGE()
		PRINT @msg
	END CATCH
GO