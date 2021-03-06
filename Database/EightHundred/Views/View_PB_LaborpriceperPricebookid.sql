USE [EightHundred]
GO

/****** Object:  View [dbo].[View_PB_LaborpriceperPricebookid]    Script Date: 04/04/2012 21:10:20 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[View_PB_LaborpriceperPricebookid]'))
DROP VIEW [dbo].[View_PB_LaborpriceperPricebookid]
GO

USE [EightHundred]
GO

/****** Object:  View [dbo].[View_PB_LaborpriceperPricebookid]    Script Date: 04/04/2012 21:10:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[View_PB_LaborpriceperPricebookid]
AS
SELECT DISTINCT 
                      dbo.tbl_PriceBook.PriceBookID, dbo.tbl_PB_Parts.PartID, dbo.tbl_PB_MasterParts.PartName, 1.7501 AS LaborPrice, dbo.tbl_PB_Parts.PartCost, 
                      dbo.tbl_PB_Parts.PartStdPrice, dbo.tbl_PB_Parts.PartMemberPrice, dbo.tbl_PB_Parts.PartAddonStdPrice, dbo.tbl_PB_Parts.PartAddonMemberPrice
FROM         dbo.tbl_PB_JobCodes INNER JOIN
                      dbo.tbl_PB_JobCodes_Details ON dbo.tbl_PB_JobCodes.JobCodeID = dbo.tbl_PB_JobCodes_Details.JobCodeID INNER JOIN
                      dbo.tbl_PB_Parts ON dbo.tbl_PB_JobCodes_Details.PartID = dbo.tbl_PB_Parts.PartID INNER JOIN
                      dbo.tbl_PB_MasterParts ON dbo.tbl_PB_Parts.MasterPartID = dbo.tbl_PB_MasterParts.MasterPartID INNER JOIN
                      dbo.tbl_PB_SubSection ON dbo.tbl_PB_JobCodes.SubSectionID = dbo.tbl_PB_SubSection.SubsectionID INNER JOIN
                      dbo.tbl_PB_Section ON dbo.tbl_PB_SubSection.SectionID = dbo.tbl_PB_Section.SectionID INNER JOIN
                      dbo.tbl_PriceBook ON dbo.tbl_PB_Section.PriceBookID = dbo.tbl_PriceBook.PriceBookID
GROUP BY dbo.tbl_PB_JobCodes.JobCodeID, dbo.tbl_PB_MasterParts.PartCodeID, dbo.tbl_PB_Parts.PartID, dbo.tbl_PB_Parts.PartCost, dbo.tbl_PB_Parts.PartStdPrice, 
                      dbo.tbl_PB_Parts.PartMemberPrice, dbo.tbl_PB_Parts.PartAddonStdPrice, dbo.tbl_PB_Parts.PartAddonMemberPrice, dbo.tbl_PB_MasterParts.PartName, 
                      dbo.tbl_PriceBook.PriceBookID
HAVING      (dbo.tbl_PB_MasterParts.PartCodeID = 'LA') OR
                      (dbo.tbl_PB_MasterParts.PartCodeID = 'LD') OR
                      (dbo.tbl_PB_MasterParts.PartCodeID = 'LJ') OR
                      (dbo.tbl_PB_MasterParts.PartCodeID = 'LH')

GO