USE [EightHundred]
GO
/****** Object:  View [dbo].[vRpt_Payment]    Script Date: 04/04/2012 21:45:21 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vRpt_Payment]'))
DROP VIEW [dbo].[vRpt_Payment]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vRpt_Payment]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vRpt_Payment] AS
SELECT 
	p.PaymentID
	, p.PaymentDate
	, p.PaymentTypeID
	, pt.PaymentType
	, p.CheckNumber
	, p.DepositStatus
	, p.DepositID
	, p.DriversLicNUm
	, p.JobID
	, p.ErrorFlag
	, p.FranchiseID
FROM tbl_Payments p
INNER JOIN tbl_Job j
ON p.JobID = j.JobID
LEFT JOIN tbl_Payment_Types pt
ON p.PaymentTypeID = pt.PaymentTypeId
'
GO
