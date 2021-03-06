USE [EightHundred]
GO
/****** Object:  View [dbo].[View_CustomerID_CountCalls]    Script Date: 03/30/2012 13:12:10 ******/
DROP VIEW [dbo].[View_CustomerID_CountCalls]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_CustomerID_CountCalls]
AS
SELECT     dbo.tbl_Customer_Info.CustomerID, COUNT(dbo.tbl_Calls.CallID) AS CountCalls
FROM         dbo.tbl_Customer_Info INNER JOIN
                      dbo.tbl_Calls ON dbo.tbl_Customer_Info.CustomerID = dbo.tbl_Calls.CustomerID
GROUP BY dbo.tbl_Customer_Info.CustomerID
GO
