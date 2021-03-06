USE [EightHundred]
GO
/****** Object:  View [dbo].[vRPT_MembershipInfo]    Script Date: 04/04/2012 21:45:21 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vRpt_MembershipInfo]'))
DROP VIEW [dbo].[vRpt_MembershipInfo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vRpt_MembershipInfo]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vRpt_MembershipInfo]
AS
SELECT     dbo.vRpt_Membership.MembershipID, dbo.vRpt_Customer.CustomerID, dbo.vRpt_Customer.CustomerName, dbo.vRpt_Customer.Email, 
                      dbo.vRpt_Customer.PrimaryPhone, dbo.vRpt_Customer.CellPhone, dbo.vRpt_Customer.BillToAddress, dbo.vRpt_Customer.BillToCity, dbo.vRpt_Customer.BillToState, 
                      dbo.vRpt_Customer.BillToPostalCode, dbo.vRpt_Customer.BillToCountry, dbo.vRpt_Membership.MemberTypeID, dbo.vRpt_Membership.MemberType, 
                      dbo.vRpt_Membership.MembershipStartDate, dbo.vRpt_Membership.MembershipEndDate, dbo.vRpt_Membership.req_TotalInspectionsPerYear, 
                      dbo.vRpt_Membership.CountOfInspections, dbo.vRpt_Membership.LastDateInspected, dbo.vRpt_Membership.LastCustomerVisit, 
                      dbo.vRpt_Membership.CountCustomerVisits, dbo.vRpt_Customer.JobCount, dbo.vRpt_Customer.TotalSales, dbo.vRpt_Customer.AverageJob, 
                      dbo.vRpt_Customer.Payments, dbo.vRpt_Customer.Balance, dbo.vRpt_Membership.ClientID
FROM         dbo.vRpt_Customer INNER JOIN
                      dbo.vRpt_Membership ON dbo.vRpt_Customer.CustomerID = dbo.vRpt_Membership.billtoCustomerID
'
GO
