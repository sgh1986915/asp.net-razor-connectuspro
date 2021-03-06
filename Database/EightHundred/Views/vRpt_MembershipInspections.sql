USE [EightHundred]
GO
/****** Object:  View [dbo].[vRpt_MembershipInspections]    Script Date: 04/04/2012 21:45:21 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vRpt_MembershipInspections]'))
DROP VIEW [dbo].[vRpt_MembershipInspections]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vRpt_MembershipInspections]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vRpt_MembershipInspections]
AS
SELECT     dbo.vRpt_JobDetail.JobID, dbo.vRpt_JobDetail.ClientID, dbo.vRpt_Job.CallCompleted, dbo.vRpt_Job.CustomerID
FROM         dbo.vRpt_JobDetail INNER JOIN
                      dbo.vRpt_Job ON dbo.vRpt_JobDetail.JobID = dbo.vRpt_Job.TicketNumber AND dbo.vRpt_JobDetail.ClientID = dbo.vRpt_Job.ClientID
WHERE     (dbo.vRpt_JobDetail.JobCode = ''A00100'') AND (dbo.vRpt_JobDetail.Amount = 0) OR
                      (dbo.vRpt_JobDetail.JobCode = ''A00200'') AND (dbo.vRpt_JobDetail.Amount = 0)
UNION 
SELECT  [TicketNumber] as Jobid
      ,[ClientID]
      ,[CallCompleted]
      ,[CustomerID]
  FROM [EightHundred].[dbo].[vRpt_Job]
  where [JobPriorityID] = 6 and (statusid = 6 or statusid = 7)
'
GO
