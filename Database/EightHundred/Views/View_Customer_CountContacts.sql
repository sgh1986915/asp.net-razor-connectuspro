USE [EightHundred]
GO
/****** Object:  View [dbo].[View_Customer_CountContacts]    Script Date: 03/30/2012 13:12:10 ******/
DROP VIEW [dbo].[View_Customer_CountContacts]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_Customer_CountContacts]
AS
SELECT     dbo.tbl_Customer.CustomerID, COUNT(dbo.tbl_Contacts.ContactID) AS CountPhoneNumber
FROM         dbo.tbl_Contacts INNER JOIN
                      dbo.tbl_Customer ON dbo.tbl_Contacts.CustomerID = dbo.tbl_Customer.CustomerID
GROUP BY dbo.tbl_Customer.CustomerID
GO
