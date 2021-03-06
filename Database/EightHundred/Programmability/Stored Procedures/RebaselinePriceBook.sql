USE [EightHundred]
GO
/****** Object:  StoredProcedure [dbo].[RebaselinePriceBook]    Script Date: 03/30/2012 13:12:28 ******/
DROP PROCEDURE [dbo].[RebaselinePriceBook]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RebaselinePriceBook](@PriceBookID INT)
AS

UPDATE jcd
SET PartStdPrice = jcd.partcost * m.Markup * jcd.Qty
, PartMemberPrice = jcd.partcost * m.Markup  * jcd.Qty* (1-ISNULL(r.Memberdiscountrate/100, 0))
, PartAddonStdPrice = jcd.partcost * jcd.Qty * m.Markup
, PartAddonMemberPrice = jcd.partcost * jcd.Qty * m.Markup * (1-ISNULL(r.Memberdiscountrate/100, 0))
FROM tbl_pb_jobcodes_details jcd
INNER JOIN tbl_PB_JobCodes jc
ON jcd.JobCodeID = jc.JobCodeID
INNER JOIN tbl_PB_SubSection ss
ON ss.SubSectionID = jc.SubSectionID
INNER JOIN tbl_PB_Section s
ON s.SectionID = ss.SectionID
INNER JOIN tbl_pb_markup m
ON m.LowerBound <= jcd.PartCost AND m.UpperBound >= jcd.PartCost
LEFT JOIN tbl_pricebook_rates r
ON r.pricebookid = s.pricebookid
WHERE s.pricebookid = @PriceBookID
AND (PartStdPrice <> jcd.partcost * m.Markup * jcd.Qty
	 OR PartMemberPrice <> jcd.partcost * m.Markup * jcd.Qty * (1-ISNULL(r.Memberdiscountrate/100, 0))
	 OR PartAddonStdPrice <> jcd.partcost * m.Markup * jcd.Qty
	 OR PartAddonMemberPrice <> jcd.partcost * m.Markup * jcd.Qty * (1-ISNULL(r.Memberdiscountrate/100, 0)))

EXEC PB_RecalculatePrices @PriceBookID
GO
