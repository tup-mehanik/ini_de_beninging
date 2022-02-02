USE yah_ini_dee;
GO

CREATE OR ALTER PROCEDURE sp_New_Contact
	(
		@firstName NVARCHAR(50),
		@middleName NVARCHAR(50),
		@surname NVARCHAR(50),
		@phone NVARCHAR(10),
		@email NVARCHAR(100),
		@msg NVARCHAR(MAX) = NULL OUTPUT
	)
AS
	BEGIN TRY
		INSERT INTO dbo.Contact_People(
					[First_Name],
					[Middle_Name],
					[Surname],
					[Phone],
					[Email])
		VALUES (@firstName,
				@middleName,
				@surname,
				@phone,
				@email)
		SET @msg = 'Лицето за контакт е добавено успешно'
		PRINT @msg
	END TRY
	BEGIN CATCH
		SET @msg = ERROR_MESSAGE()
		PRINT @msg
	END CATCH
GO