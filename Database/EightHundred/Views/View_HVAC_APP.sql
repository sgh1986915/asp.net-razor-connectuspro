USE [EightHundred]
GO
/****** Object:  View [dbo].[View_HVAC_APP]    Script Date: 03/30/2012 13:12:10 ******/
DROP VIEW [dbo].[View_HVAC_APP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_HVAC_APP]
AS
SELECT DISTINCT 
                      tbl_PriceBook.PriceBookID, tbl_PB_JobCodes.JobCode, tbl_PB_JobCodes.JobCodeDescription, tbl_PB_JobCodes.JobStdPrice, 
                      tbl_PB_JobCodes.ResAccountCode, tbl_PB_JobCodes.JobCodeID
FROM         eighthundred..tbl_PB_JobCodes INNER JOIN
                      eighthundred..tbl_PB_SubSection ON tbl_PB_JobCodes.SubSectionID = tbl_PB_SubSection.SubsectionID INNER JOIN
                      eighthundred..tbl_PB_Section ON tbl_PB_SubSection.SectionID = tbl_PB_Section.SectionID INNER JOIN
                      eighthundred..tbl_PriceBook ON tbl_PB_Section.PriceBookID = tbl_PriceBook.PriceBookID
GROUP BY tbl_PB_JobCodes.JobCodeID, tbl_PriceBook.PriceBookID, tbl_PB_JobCodes.JobCode, tbl_PB_JobCodes.JobCodeDescription, 
                      tbl_PB_JobCodes.JobStdPrice, tbl_PB_JobCodes.ResAccountCode
GO
