USE yah_ini_dee;
GO

SELECT * FROM Property_Custodians;
GO

EXECUTE sp_Edit_Custodian
	'm.stoyanov@au.com', 1;
GO

SELECT * FROM Property_Custodians;
GO