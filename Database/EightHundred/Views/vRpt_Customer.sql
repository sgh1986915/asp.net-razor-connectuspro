USE [EightHundred]
GO
/****** Object:  View [dbo].[vRpt_Customer]    Script Date: 03/30/2012 13:12:12 ******/
DROP VIEW [dbo].[vRpt_Customer]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRpt_Customer]
AS
SELECT c.CustomerID
	, MIN(c.CustomerName) AS CustomerName
	, MIN(c.EMail) AS Email
	, MIN(ctP.PhoneNumber) AS PrimaryPhone
	, MIN(ctS.PhoneNumber) AS CellPhone
	, MIN(l.[Address]) AS BillToAddress
	, MIN(l.City) AS BillToCity
	, MIN(l.[State]) AS BillToState
	, MIN(l.[PostalCode]) AS BillToPostalCode
	, MIN(l.[Country]) AS BillToCountry
	, ISNULL(MAX(lv.LastVisit), '1/1/1900') AS LastVisit
	, ISNULL(MIN(ci.FranchiseID), -1) AS ClientID
	, ISNULL(COUNT(1), 0) AS [JobCount]
	, ISNULL(SUM(j.SubTotal), 0) AS [TotalSales]
	, CASE WHEN ISNULL(COUNT(1), 0) = 0 THEN 0 ELSE ISNULL(SUM(j.SubTotal) / COUNT(1), 0) END AS [AverageJob]
	, ISNULL(SUM(p.PaymentAmount),0) AS [Payments]
	, ISNULL(SUM(j.TotalSales) - SUM(p.PaymentAmount),0) AS [Balance]
FROM         dbo.tbl_Customer AS c 
INNER JOIN tbl_Locations l
	ON c.CustomerID = l.BilltoCustomerID AND l.BilltoCustomerID = c.CustomerID

LEFT JOIN dbo.tbl_Contacts AS ctP
	ON ctP.CustomerID = c.CustomerID  AND l.LocationID = ctP.LocationID AND ctP.PhoneTypeID = 2

LEFT JOIN dbo.tbl_Contacts AS ctS
	ON ctS.CustomerID = c.CustomerID  AND l.LocationID = ctS.LocationID AND ctS.PhoneTypeID = 4

LEFT JOIN [vRpt_CustomerVisits] lv
	ON c.CustomerID = lv.CustomerID

LEFT JOIN [tbl_Customer_Info] ci
	ON ci.CustomerID = c.CustomerID

LEFT JOIN vRpt_Job j
	ON c.CustomerID = j.customerID

LEFT JOIN tbl_Payments p 
	ON p.JobID = j.TicketNumber
GROUP BY c.CustomerID
GO
