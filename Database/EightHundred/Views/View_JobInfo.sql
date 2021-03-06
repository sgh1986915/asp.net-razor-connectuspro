USE [eighthundred]
GO
/****** Object:  View [dbo].[View_JobInfo]    Script Date: 03/30/2012 11:38:55 ******/
DROP VIEW [dbo].[View_JobInfo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_JobInfo]
AS
SELECT  j.JobID AS TicketNumber
	, COALESCE(j.CallCompleted, j.InvoicedDate, [ScheduleEnd]) AS CallCompleted
	, s.[StatusID]
	, s.[Status]
	, svc.ServiceID
	, svc.ServiceName
	, j.TotalSales
	, j.TaxAmount
	, j.SubTotal
	, CASE WHEN tr.TaxDescription IS NULL THEN (CASE WHEN j.taxamount = 0 THEN 'No Tax' 
												ELSE 'Unspecified Tax' END) 
		   ELSE tr.TaxDescription END AS TaxDescription
	, bt.BusinessTypeID
	, bt.BusinessType
    , CASE  WHEN c.CustomerName IS NULL AND c.CompanyName IS NULL THEN 'UNKNOWN CUSTOMER'
			WHEN c.CustomerName IS NULL OR LTRIM(c.CustomerName) = '' THEN c.companyname 
			WHEN c.companyname IS NULL OR LTRIM(c.companyname) = '' THEN c.customername 
			ELSE c.companyname + ' - ' + c.customername END AS CustomerName
    , l.[Address] AS JobAddress
    , l.City AS JobCity
    , l.[State] AS JobState
    , l.PostalCode AS JobPostalCode
    , j.FranchiseID AS ClientID
    , j.JobPriorityID
    , pr.JobPriority
    , j.ServiceProID
    , j.Balance
FROM dbo.tbl_Job AS j
	INNER JOIN dbo.tbl_Job_Status AS s ON j.StatusID = s.StatusID
	INNER JOIN dbo.tbl_Customer AS c ON j.CustomerID = c.CustomerID 
	INNER JOIN dbo.tbl_Locations AS l ON j.LocationID = l.LocationID 
	INNER JOIN dbo.tbl_Customer_BusinessType AS bt ON j.BusinessTypeID = bt.BusinessTypeID
	INNER JOIN dbo.tbl_Job_Priority pr ON pr.JobPriorityID = j.JobPriorityID
	LEFT JOIN dbo.tbl_Services AS svc ON j.ServiceID = svc.ServiceID
	LEFT JOIN dbo.tbl_TaxRates AS tr ON j.TaxAuthorityID = tr.TaxRateID
GO
