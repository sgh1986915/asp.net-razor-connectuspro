USE [EightHundred]
GO
/****** Object:  View [dbo].[View_JobTaskAccounting]    Script Date: 03/30/2012 13:12:11 ******/
DROP VIEW [dbo].[View_JobTaskAccounting]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_JobTaskAccounting]
AS
SELECT     TOP (100) PERCENT dbo.View_JobTaskPartDetails.JobID, dbo.View_JobInfo.ClientID, dbo.View_JobTaskPartDetails.AccountCode, 
                      dbo.View_JobInfo.BusinessType, SUM(dbo.View_JobTaskPartDetails.TaskQty * dbo.View_JobTaskPartDetails.TaskUnitCost) AS TaskCost, 
                      SUM(dbo.View_JobTaskPartDetails.TaskQty * dbo.View_JobTaskPartDetails.TaskUnitPrice) AS taskprice, j.CallCompleted, j.LockedYN, dbo.View_JobInfo.ServiceName, 
                      j.StatusID
FROM         dbo.tbl_Job AS j INNER JOIN
                      dbo.View_JobInfo ON j.JobID = dbo.View_JobInfo.TicketNumber INNER JOIN
                      dbo.View_JobTaskPartDetails ON dbo.View_JobInfo.TicketNumber = dbo.View_JobTaskPartDetails.JobID
GROUP BY dbo.View_JobInfo.ClientID, dbo.View_JobTaskPartDetails.AccountCode, dbo.View_JobInfo.BusinessType, dbo.View_JobTaskPartDetails.JobID, j.CallCompleted, 
                      j.FranchiseID, j.LockedYN, dbo.View_JobInfo.ServiceName, j.StatusID
HAVING      (j.StatusID = 6) OR
                      (j.StatusID = 7)
ORDER BY dbo.View_JobTaskPartDetails.JobID DESC
GO
GO
