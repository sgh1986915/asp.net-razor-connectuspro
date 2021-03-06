USE [eighthundred]
GO

/****** Object:  View [dbo].[View_HVAC_APP_Parts]    Script Date: 05/02/2012 11:06:34 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[View_HVAC_APP_Parts]'))
DROP VIEW [dbo].[View_HVAC_APP_Parts]
GO

USE [eighthundred]
GO

/****** Object:  View [dbo].[View_HVAC_APP_Parts]    Script Date: 05/02/2012 11:06:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[View_HVAC_APP_Parts]
AS
SELECT DISTINCT 
                      tbl_PriceBook.PriceBookID, tbl_PB_JobCodes.JobCode, tbl_PB_Parts.MasterPartID, tbl_PB_JobCodes_Details.PartCost, tbl_PB_JobCodes_Details.PartStdPrice, 
                      tbl_PB_Parts.PartID, tbl_PB_MasterParts.PartCodeID, tbl_PB_MasterParts.PartName, tbl_PB_JobCodes_Details.Qty, 
                      tbl_PB_MasterParts.PartCode
FROM         eighthundred..tbl_PB_JobCodes INNER JOIN
                      eighthundred..tbl_PB_SubSection ON eighthundred..tbl_PB_JobCodes.SubSectionID = eighthundred..tbl_PB_SubSection.SubsectionID INNER JOIN
                      eighthundred..tbl_PB_Section ON eighthundred..tbl_PB_SubSection.SectionID = eighthundred..tbl_PB_Section.SectionID INNER JOIN
                      eighthundred..tbl_PriceBook ON eighthundred..tbl_PB_Section.PriceBookID = eighthundred..tbl_PriceBook.PriceBookID INNER JOIN
                      eighthundred..tbl_PB_JobCodes_Details ON eighthundred..tbl_PB_JobCodes.JobCodeID = eighthundred..tbl_PB_JobCodes_Details.JobCodeID INNER JOIN
                      eighthundred..tbl_PB_Parts ON eighthundred..tbl_PB_JobCodes_Details.PartID = eighthundred..tbl_PB_Parts.PartID INNER JOIN
                      eighthundred..tbl_PB_MasterParts ON eighthundred..tbl_PB_Parts.MasterPartID = eighthundred..tbl_PB_MasterParts.MasterPartID
GROUP BY tbl_PriceBook.PriceBookID, tbl_PB_JobCodes.JobCode, tbl_PB_Parts.PriceBookID, eighthundred..tbl_PB_Parts.MasterPartID, tbl_PB_JobCodes_Details.PartCost, 
                      tbl_PB_JobCodes_Details.PartStdPrice, tbl_PB_Parts.PartID, tbl_PB_MasterParts.PartCodeID, tbl_PB_MasterParts.PartName, tbl_PB_JobCodes_Details.Qty, 
                      tbl_PB_MasterParts.PartCode

GO


