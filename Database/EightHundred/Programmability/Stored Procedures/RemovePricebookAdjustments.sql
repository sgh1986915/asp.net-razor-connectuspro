USE [EightHundred]
GO
/****** Object:  StoredProcedure [dbo].[RemovePricebookAdjustments]    Script Date: 03/30/2012 13:12:28 ******/
DROP PROCEDURE [dbo].[RemovePricebookAdjustments]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RemovePricebookAdjustments] 
(@PriceBookID INT) AS

WITH [AdjustmentMasterParts] AS
(
SELECT MasterPartID FROM tbl_pb_masterparts
WHERE PartCodeID = 'PA'
)

DELETE jcd
FROM tbl_PB_JobCodes_Details jcd
INNER JOIN tbl_PB_JobCodes jc
ON jcd.JobCodeID = jc.JobCodeID
INNER JOIN tbl_PB_SubSection ss
ON ss.SubSectionID = jc.SubSectionID
INNER JOIN tbl_PB_Section s
ON s.SectionID = ss.SectionID
INNER JOIN tbl_PB_Parts p
ON p.PartID = jcd.PartID
INNER JOIN [AdjustmentMasterParts] amp
ON amp.MasterPartID = p.MasterPartID
WHERE s.PriceBookID = @PriceBookID

EXEC PB_RecalculatePrices @PriceBookID
GO
