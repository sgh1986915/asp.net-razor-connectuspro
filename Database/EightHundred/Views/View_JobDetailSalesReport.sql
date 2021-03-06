USE [eighthundred]
GO

/****** Object:  View [dbo].[View_JobDetailSalesReport]    Script Date: 04/04/2012 21:59:41 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[View_JobDetailSalesReport]'))
DROP VIEW [dbo].[View_JobDetailSalesReport]
GO

USE [eighthundred]
GO

/****** Object:  View [dbo].[View_JobDetailSalesReport]    Script Date: 04/04/2012 21:59:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[View_JobDetailSalesReport]
AS
SELECT     dbo.View_JobInfo.TicketNumber, dbo.View_JobInfo.CallCompleted, dbo.View_JobInfo.Status, dbo.View_JobInfo.ServiceName, dbo.View_JobInfo.BusinessType, 
                      dbo.View_JobInfo.CustomerName, dbo.View_JobInfo.JobAddress, dbo.View_JobInfo.JobCity, dbo.View_JobInfo.JobState, dbo.View_JobInfo.JobPostalCode, 
                      dbo.View_JobInfo.SubTotal, dbo.View_JobInfo.TaxDescription, dbo.View_JobInfo.TaxAmount, dbo.View_JobInfo.TotalSales, dbo.View_JobTaskPartDetails.JobCode, 
                      dbo.View_JobTaskPartDetails.JobCodeDescription, dbo.View_JobTaskPartDetails.AccountCode, dbo.View_JobTaskPartDetails.TaskQty, 
                      dbo.View_JobTaskPartDetails.TaskUnitCost, dbo.View_JobTaskPartDetails.TaskQty * dbo.View_JobTaskPartDetails.TaskUnitCost AS TaskCost, 
                      dbo.View_JobTaskPartDetails.TaskUnitPrice, dbo.View_JobTaskPartDetails.TaskQty * dbo.View_JobTaskPartDetails.TaskUnitPrice AS TaskPrice, 
                      dbo.View_JobTaskPartDetails.PartName, dbo.View_JobTaskPartDetails.PartCode, dbo.View_JobTaskPartDetails.PartQty, dbo.View_JobTaskPartDetails.PartUnitCost, 
                      dbo.View_JobTaskPartDetails.PartQty * dbo.View_JobTaskPartDetails.PartUnitCost AS PartCost, dbo.View_JobTaskPartDetails.PartUnitPrice, 
                      dbo.View_JobTaskPartDetails.PartQty * dbo.View_JobTaskPartDetails.PartUnitPrice AS PartPrice, dbo.View_JobInfo.ClientID
FROM         dbo.View_JobInfo LEFT OUTER JOIN
                      dbo.View_JobTaskPartDetails ON dbo.View_JobInfo.TicketNumber = dbo.View_JobTaskPartDetails.JobID

GO