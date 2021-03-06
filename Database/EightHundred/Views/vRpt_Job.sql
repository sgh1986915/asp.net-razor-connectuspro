USE [eighthundred]
GO

/****** Object:  View [dbo].[vRpt_Job]    Script Date: 05/04/2012 09:11:48 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vRpt_Job]'))
DROP VIEW [dbo].[vRpt_Job]
GO

USE [eighthundred]
GO

/****** Object:  View [dbo].[vRpt_Job]    Script Date: 05/04/2012 09:11:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vRpt_Job]
AS
WITH [EstimateDates] AS
(
	SELECT JobID, MAX(EstimateDate) AS [EstimateDate] FROM tbl_Job_Estimates
	GROUP BY JobID
)
SELECT  j.JobID AS TicketNumber
	, j.CallCompleted
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
	, j.CustomerID
    , dbo.ResolveCustomerName(c.CustomerName, c.CompanyName) AS CustomerName
    , l.[Address] AS JobAddress
    , l.City AS JobCity
    , l.[State] AS JobState
    , l.PostalCode AS JobPostalCode
    , j.FranchiseID AS ClientID
    , j.JobPriorityID
    , pr.JobPriority
    , j.ServiceProID
    , j.Balance
    , j.CallSourceID AS [ReferralID]
    , r.ReferralType
    , e.EstimateDate
FROM dbo.tbl_Job AS j
	INNER JOIN dbo.tbl_Job_Status AS s ON j.StatusID = s.StatusID
	INNER JOIN dbo.tbl_Customer AS c ON j.CustomerID = c.CustomerID 
	INNER JOIN dbo.tbl_Locations AS l ON j.LocationID = l.LocationID 
	INNER JOIN dbo.tbl_Customer_BusinessType AS bt ON j.BusinessTypeID = bt.BusinessTypeID
	INNER JOIN dbo.tbl_Job_Priority pr ON pr.JobPriorityID = j.JobPriorityID
	LEFT JOIN dbo.tbl_Services AS svc ON j.ServiceID = svc.ServiceID
	LEFT JOIN dbo.tbl_TaxRates AS tr ON j.TaxAuthorityID = tr.TaxRateID
	LEFT JOIN dbo.tbl_Referral r ON r.referralID = j.CallSourceID AND r.FranchiseID = j.FranchiseID
	LEFT JOIN [EstimateDates] e ON e.JobID = j.JobID

GO


