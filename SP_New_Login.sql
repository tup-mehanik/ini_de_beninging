USE yah_ini_dee;
GO

CREATE OR ALTER PROCEDURE sp_New_Login
	(
		@email NVARCHAR(100),
		@password NVARCHAR(50),
		@type BINARY(1),
		@id INT,
		@msg NVARCHAR(MAX) = NULL OUTPUT
	)
AS
	BEGIN TRY
		INSERT INTO dbo.Login_Data(
			[Email],
			[Password],
			[Type],
			[Link_ID])
		VALUES (@email,
				@password,
				@type,
				@id)
		SET @msg = 'Профилът е добавен успешно'
		PRINT @msg
	END TRY
	BEGIN CATCH
		SET @msg = ERROR_MESSAGE()
		PRINT @msg
	END CATCH
GO