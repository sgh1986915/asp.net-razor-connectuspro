USE [EightHundred]
GO
/****** Object:  View [dbo].[View_PB_LaborpricePerSectionID]    Script Date: 03/30/2012 13:12:11 ******/
DROP VIEW [dbo].[View_PB_LaborpricePerSectionID]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_PB_LaborpricePerSectionID]
AS
SELECT DISTINCT 
                      dbo.tbl_PB_Section.SectionID, dbo.tbl_PB_Parts.PartID, dbo.tbl_PB_MasterParts.PartName, 1.1705 AS LaborPrice, dbo.tbl_PB_Parts.PartCost, 
                      dbo.tbl_PB_Parts.PartStdPrice, dbo.tbl_PB_Parts.PartMemberPrice, dbo.tbl_PB_Parts.PartAddonStdPrice, dbo.tbl_PB_Parts.PartAddonMemberPrice
FROM         dbo.tbl_PB_JobCodes INNER JOIN
                      dbo.tbl_PB_JobCodes_Details ON dbo.tbl_PB_JobCodes.JobCodeID = dbo.tbl_PB_JobCodes_Details.JobCodeID INNER JOIN
                      dbo.tbl_PB_Parts ON dbo.tbl_PB_JobCodes_Details.PartID = dbo.tbl_PB_Parts.PartID INNER JOIN
                      dbo.tbl_PB_MasterParts ON dbo.tbl_PB_Parts.MasterPartID = dbo.tbl_PB_MasterParts.MasterPartID INNER JOIN
                      dbo.tbl_PB_SubSection ON dbo.tbl_PB_JobCodes.SubSectionID = dbo.tbl_PB_SubSection.SubsectionID INNER JOIN
                      dbo.tbl_PB_Section ON dbo.tbl_PB_SubSection.SectionID = dbo.tbl_PB_Section.SectionID
GROUP BY dbo.tbl_PB_JobCodes.JobCodeID, dbo.tbl_PB_MasterParts.PartCodeID, dbo.tbl_PB_Parts.PartID, dbo.tbl_PB_Parts.PartCost, dbo.tbl_PB_Parts.PartStdPrice, 
                      dbo.tbl_PB_Parts.PartMemberPrice, dbo.tbl_PB_Parts.PartAddonStdPrice, dbo.tbl_PB_Parts.PartAddonMemberPrice, dbo.tbl_PB_MasterParts.PartName, 
                      dbo.tbl_PB_Section.SectionID
HAVING      (dbo.tbl_PB_MasterParts.PartCodeID = 'LA')
GO
