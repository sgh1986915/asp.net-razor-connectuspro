/*
   Server: conn952.gearhost.us.com
   Database: EightHundred
   Application: 

   Description:
   - Change column types in table tbl_HVAC_ConfigSystems SEER and AFUE from int to float with copy data into changed table 
*/
USE [EightHundred]

BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tbl_HVAC_ConfigSystems
	DROP CONSTRAINT FK_tbl_HVAC_ConfigSystemstbl_HVAC_SystemType
GO
ALTER TABLE dbo.tbl_HVAC_SystemType SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.tbl_HVAC_ConfigSystems
	DROP CONSTRAINT FK_tbl_HVAC_ConfigSystemstbl_HVAC_ConfigsApp
GO
ALTER TABLE dbo.tbl_HVAC_ConfigsApp SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.Tmp_tbl_HVAC_ConfigSystems
	(
	ConfigID int NOT NULL,
	SystemID int NOT NULL,
	OrderNum nvarchar(MAX) NOT NULL,
	SEER float(53) NULL,
	AFUE float(53) NULL
	)  ON [PRIMARY]
	 TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE dbo.Tmp_tbl_HVAC_ConfigSystems SET (LOCK_ESCALATION = TABLE)
GO
IF EXISTS(SELECT * FROM dbo.tbl_HVAC_ConfigSystems)
	 EXEC('INSERT INTO dbo.Tmp_tbl_HVAC_ConfigSystems (ConfigID, SystemID, OrderNum, SEER, AFUE)
		SELECT ConfigID, SystemID, OrderNum, CONVERT(float(53), SEER), CONVERT(float(53), AFUE) FROM dbo.tbl_HVAC_ConfigSystems WITH (HOLDLOCK TABLOCKX)')
GO
DROP TABLE dbo.tbl_HVAC_ConfigSystems
GO
EXECUTE sp_rename N'dbo.Tmp_tbl_HVAC_ConfigSystems', N'tbl_HVAC_ConfigSystems', 'OBJECT' 
GO
ALTER TABLE dbo.tbl_HVAC_ConfigSystems ADD CONSTRAINT
	PK_tbl_HVAC_ConfigSystems PRIMARY KEY CLUSTERED 
	(
	ConfigID,
	SystemID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.tbl_HVAC_ConfigSystems WITH NOCHECK ADD CONSTRAINT
	FK_tbl_HVAC_ConfigSystemstbl_HVAC_ConfigsApp FOREIGN KEY
	(
	ConfigID
	) REFERENCES dbo.tbl_HVAC_ConfigsApp
	(
	ConfigID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.tbl_HVAC_ConfigSystems WITH NOCHECK ADD CONSTRAINT
	FK_tbl_HVAC_ConfigSystemstbl_HVAC_SystemType FOREIGN KEY
	(
	SystemID
	) REFERENCES dbo.tbl_HVAC_SystemType
	(
	SystemTypeID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
