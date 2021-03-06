USE [EightHundred]
GO
/****** Object:  View [dbo].[View_CustomerID_CountJobLocation]    Script Date: 03/30/2012 13:12:10 ******/
DROP VIEW [dbo].[View_CustomerID_CountJobLocation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_CustomerID_CountJobLocation]
AS
SELECT     dbo.tbl_Customer.CustomerID, COUNT(dbo.tbl_Locations.LocationID) AS CountBillTo
FROM         dbo.tbl_Customer INNER JOIN
                      dbo.tbl_Locations ON dbo.tbl_Customer.CustomerID = dbo.tbl_Locations.ActvieCustomerID
GROUP BY dbo.tbl_Customer.CustomerID
GO
