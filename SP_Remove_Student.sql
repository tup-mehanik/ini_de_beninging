USE yah_ini_dee;
GO

--������� ������ � ������ ����� �� ����
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
		
		SET @msg = '������� �� ������� �� ���������� �������'
		PRINT @msg
	END
GO