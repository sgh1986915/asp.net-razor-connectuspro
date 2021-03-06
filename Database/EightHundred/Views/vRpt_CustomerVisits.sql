USE [EightHundred]
GO
/****** Object:  View [dbo].[vRpt_CustomerVisits]    Script Date: 03/30/2012 13:12:12 ******/
DROP VIEW [dbo].[vRpt_CustomerVisits]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRpt_CustomerVisits]
AS
SELECT     j.CustomerID, COUNT(1) AS CountJobs, MAX(CASE WHEN j.CallCompleted > GETDATE() THEN NULL ELSE j.CallCompleted END) AS [LastVisit]
FROM         dbo.vRpt_Job j
GROUP BY j.CustomerID
GO
