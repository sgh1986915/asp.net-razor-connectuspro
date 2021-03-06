USE [eighthundred]
GO
/****** Object:  View [dbo].[View_CustNamePrimaryPhoneEmail]    Script Date: 03/30/2012 11:38:54 ******/
DROP VIEW [dbo].[View_CustNamePrimaryPhoneEmail]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_CustNamePrimaryPhoneEmail]
AS
SELECT DISTINCT c.CustomerID, ct.PhoneNumber AS PrimaryPhone, ct.ContactName, c.EMail
FROM         dbo.tbl_Contacts AS ct RIGHT OUTER JOIN
                      dbo.tbl_Customer AS c ON ct.CustomerID = c.CustomerID
WHERE     (ct.PhoneTypeID = 2)
GO
