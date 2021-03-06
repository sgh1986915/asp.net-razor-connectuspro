USE [EightHundred]
GO

/****** Object:  View [dbo].[vRpt_Payroll]    Script Date: 04/15/2012 14:36:10 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vRpt_Payroll]'))
DROP VIEW [dbo].[vRpt_Payroll]
GO

USE [EightHundred]
GO

/****** Object:  View [dbo].[vRpt_Payroll]    Script Date: 04/15/2012 14:36:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vRpt_Payroll]
AS
	SELECT 
		pr.[PayrollID]
		,pr.[FranchiseID]
		,pr.[PayrollDate]
		,[LockedYN] = CONVERT(bit, CASE WHEN pr.LockDate IS NULL THEN 0 ELSE 1 END)
		,pr.LockDate
		,GrossPay = SUM(ISNULL(pd.GrossPay,0) ) 
	FROM
		[dbo].[tbl_Payroll] pr
		LEFT JOIN dbo.vRpt_PayrollDetail pd ON pr.PayrollID = pd.PayrollID
	WHERE (1 = 1)
GROUP BY
		pr.[PayrollID]
		,pr.[FranchiseID]
		,pr.[PayrollDate]
		,pr.LockDate


GO


