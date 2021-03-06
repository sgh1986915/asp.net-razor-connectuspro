USE [EightHundred]
GO
/****** Object:  View [dbo].[View_JobTaskPartDetails]    Script Date: 03/30/2012 13:12:11 ******/
DROP VIEW [dbo].[View_JobTaskPartDetails]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_JobTaskPartDetails]
AS
SELECT     dbo.tbl_Job.JobID, dbo.tbl_Job_Tasks.JobCode, dbo.tbl_Job_Tasks.JobCodeDescription, dbo.tbl_Job_Tasks.Quantity AS TaskQty, 
                      dbo.tbl_Job_Tasks.Price AS TaskUnitPrice, dbo.tbl_Job_Tasks.Cost AS TaskUnitCost, dbo.tbl_Job_Tasks.AccountCode, dbo.tbl_Job_Task_Parts.PartCode, 
                      dbo.tbl_Job_Task_Parts.PartName, dbo.tbl_Job_Task_Parts.Cost AS PartUnitCost, dbo.tbl_Job_Task_Parts.Price AS PartUnitPrice, 
                      dbo.tbl_Job_Task_Parts.Quantity AS PartQty
FROM         dbo.tbl_Job INNER JOIN
                      dbo.tbl_Job_Tasks ON dbo.tbl_Job.JobID = dbo.tbl_Job_Tasks.JobID INNER JOIN
                      dbo.tbl_Job_Task_Parts ON dbo.tbl_Job_Tasks.JobTaskID = dbo.tbl_Job_Task_Parts.JobTaskID
GO