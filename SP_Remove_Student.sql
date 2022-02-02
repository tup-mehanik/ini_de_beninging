USE yah_ini_dee;
GO

--изтрива ученик и всички данни за него
CREATE OR ALTER PROCEDURE sp_Remove_Student
	(
		@email NVARCHAR(100),
		@egn NVARCHAR(10),
		@msg NVARCHAR(MAX) = NULL OUTPUT
	)
AS
	BEGIN 
		DELETE FROM Students
		WHERE EGN = @egn

		DELETE FROM Login_Data
		WHERE Email = @email
		
		SET @msg = 'ƒанните за ученика са премахнати успешно'
		PRINT @msg
	END
GO