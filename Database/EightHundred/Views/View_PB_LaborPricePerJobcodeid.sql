USE [EightHundred]
GO
/****** Object:  View [dbo].[View_PB_LaborPricePerJobcodeid]    Script Date: 03/30/2012 13:12:11 ******/
DROP VIEW [dbo].[View_PB_LaborPricePerJobcodeid]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_PB_LaborPricePerJobcodeid]
AS
WITH [taskSums] AS
(
	SELECT JobCodeID, SUM(PartStdPrice) AS [Total] FROM tbl_PB_JobCodes_Details
	GROUP BY JobCodeID
)
, [laborSums] AS
(
	SELECT jcd.JobCodeID, SUM(jcd.PartStdPrice) As [LaborTotal] FROM tbl_PB_JobCodes_Details jcd
	INNER JOIN tbl_PB_Parts p
	ON jcd.PartID = p.PartID
	INNER JOIN tbl_PB_MasterParts mp
	ON mp.MasterPartID = p.MasterPartID
	WHERE mp.PartCodeID IN ('LA','LD','LH','LJ')
	GROUP BY jcd.JobCodeID
)
SELECT
	  ts.JobCodeID
	, ROUND(ISNULL(CASE WHEN ts.Total <= ls.LaborTotal THEN 100 ELSE ls.LaborTotal / ts.Total * 100 END, 0), 2) AS [LaborPercentage]
FROM [taskSums] ts
LEFT JOIN [laborSums] ls
ON ls.JobCodeID = ts.JobCodeID
GO
