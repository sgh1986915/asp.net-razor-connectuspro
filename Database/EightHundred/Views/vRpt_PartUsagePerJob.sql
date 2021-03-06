USE [EightHundred]
GO
/****** Object:  View [dbo].[vRpt_PartUsagePerJob]    Script Date: 04/04/2012 21:45:21 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vRpt_PartUsagePerJob]'))
DROP VIEW [dbo].[vRpt_PartUsagePerJob]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vRpt_PartUsagePerJob]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vRpt_PartUsagePerJob]
AS
SELECT     dbo.vRpt_Job.TicketNumber, dbo.vRpt_Job.CallCompleted, dbo.vRpt_Job.Status, dbo.vRpt_Job.ServiceName, dbo.vRpt_Job.BusinessType, 
                      dbo.vRpt_Job.CustomerName, dbo.vRpt_Job.JobAddress, dbo.vRpt_Job.JobCity, dbo.vRpt_Job.JobState, dbo.vRpt_Job.JobPostalCode, dbo.vRpt_Job.ClientID, 
                      dbo.View_JobTaskPartDetails.JobCode, dbo.View_JobTaskPartDetails.TaskQty, dbo.View_JobTaskPartDetails.PartCode, dbo.View_JobTaskPartDetails.PartName, 
                      dbo.View_JobTaskPartDetails.PartQty, dbo.View_JobTaskPartDetails.PartQty * dbo.View_JobTaskPartDetails.PartUnitCost AS PartCost, 
                      dbo.View_JobTaskPartDetails.PartQty * dbo.View_JobTaskPartDetails.PartUnitCost AS PartTotalCost, dbo.View_JobTaskPartDetails.PartUnitPrice, 
                      dbo.View_JobTaskPartDetails.PartQty * dbo.View_JobTaskPartDetails.PartUnitPrice AS PartTotalPrice
FROM         dbo.vRpt_Job INNER JOIN
                      dbo.View_JobTaskPartDetails ON dbo.vRpt_Job.TicketNumber = dbo.View_JobTaskPartDetails.JobID
'
GO
