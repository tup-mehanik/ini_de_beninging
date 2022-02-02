USE yah_ini_dee;
GO

CREATE OR ALTER PROCEDURE sp_New_Custodian
	(
		@firstName NVARCHAR(50),
		@middleName NVARCHAR(50),
		@surname NVARCHAR(50),
		@egn NVARCHAR(10),
		@phone NVARCHAR(10),
		@email NVARCHAR(100),
		@msg NVARCHAR(MAX) = NULL OUTPUT
	)
AS
	BEGIN TRY
		INSERT INTO dbo.Property_Custodians(
					[First_Name],
					[Middle_Name],
					[Surname],
					[EGN],
					[Phone],
					[Email])
		VALUES (@firstName,
				@middleName,
				@surname,
				@egn,
				@phone,
				@email)
		SET @msg = 'Отговорното лице е добавено успешно'
		PRINT @msg
	END TRY
	BEGIN CATCH
		SET @msg = ERROR_MESSAGE()
		PRINT @msg
	END CATCH
GO