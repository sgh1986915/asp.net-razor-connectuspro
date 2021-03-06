USE [EightHundred]
GO
/****** Object:  StoredProcedure [dbo].[ApplyMarkup]    Script Date: 03/30/2012 13:12:26 ******/
DROP PROCEDURE [dbo].[ApplyMarkup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ApplyMarkup] 
( @Level INT --0 = PriceBook, 1 = Section, 2 = SubSection, 3 = Task
, @LevelId INT --Id of level parameter.  If level = 1 then this should be a section id.
, @MarkupAsPercentage INT
, @MarkupMasterPartId INT) AS

DECLARE @Markups TABLE 
	(MarkupDetailID INT,
	JobCodeID INT,
	PartStdPrice MONEY,
	PartMemberPrice MONEY,
	PartAddonStdPrice MONEY,
	PartAddonMemberPrice MONEY)

DECLARE @MarkupFactor DECIMAL(10,4)
SET @MarkupFactor = CONVERT(DECIMAL, @MarkupAsPercentage) / 100;

DECLARE @PriceBookID INT
SELECT @PriceBookID = PriceBookID
	FROM tbl_PB_JobCodes jc
	INNER JOIN tbl_PB_SubSection ss
	ON jc.SubSectionID = ss.SubsectionID
	INNER JOIN tbl_PB_Section s
	ON s.SectionID = ss.SectionID
	WHERE ((@Level = 0 AND s.PriceBookID = @LevelId) OR
		  (@Level = 1 AND s.SectionID = @LevelId) OR
		  (@Level = 2 AND ss.SubsectionID = @LevelId) OR
		  (@Level = 3 AND jc.JobCodeID = @LevelId))
	GROUP BY s.PriceBookID

PRINT 'Begin Calculating for price book ' + CONVERT(VARCHAR, @PriceBookID)

DECLARE @PriceBookMarkupPartId INT
SELECT @PriceBookMarkupPartId = PartId FROM tbl_PB_Parts WHERE PriceBookID = @PriceBookId AND MasterPartID = @MarkupMasterPartId;


SET NOCOUNT ON

BEGIN TRY;

	WITH [ToUpdate] AS
	(
	SELECT jc.JobCodeId
	FROM tbl_PB_JobCodes jc
	INNER JOIN tbl_PB_SubSection ss
	ON jc.SubSectionID = ss.SubsectionID
	INNER JOIN tbl_PB_Section s
	ON s.SectionID = ss.SectionID
	WHERE ((@Level = 0 AND s.PriceBookID = @LevelId) OR
		  (@Level = 1 AND s.SectionID = @LevelId) OR
		  (@Level = 2 AND ss.SubsectionID = @LevelId) OR
		  (@Level = 3 AND jc.JobCodeID = @LevelId))
	GROUP BY jc.JobCodeID
	)
	, [ExistingMarkupParts] AS
	(
		SELECT jcd.JobCodeID, jcd.JobCodeDetailsID, jc.SubSectionID
		FROM [ToUpdate] u
		INNER JOIN tbl_PB_JobCodes_Details jcd
		ON u.JobCodeId = jcd.JobCodeID AND jcd.PartID = @PriceBookMarkupPartId
		INNER JOIN tbl_PB_JobCodes jc
		ON jc.JobCodeID = jcd.JobCodeID
	)
	, [AdjustmentParts] AS
	(
		SELECT jobs.JobCodeID 
			 , e.SubSectionID
			 , e.JobCodeDetailsID as [MarkupDetailID]
		FROM [ToUpdate] jobs
		LEFT JOIN [ExistingMarkupParts] e
		ON jobs.JobCodeID = e.JobCodeID
		GROUP BY e.SubSectionID, jobs.JobCodeID, e.JobCodeDetailsID
	)

	INSERT INTO @Markups
		SELECT ap.MarkupDetailID
		, ap.JobCodeID
		, SUM(jcd.PartStdPrice * @MarkupFactor) AS PartStdPrice
		, SUM(jcd.PartMemberPrice * @MarkupFactor) AS PartMemberPrice
		, SUM(jcd.PartAddonStdPrice * @MarkupFactor) AS PartAddonStdPrice
		, SUM(jcd.PartAddonMemberPrice * @MarkupFactor) AS PartAddonMemberPrice
		 FROM [AdjustmentParts] ap
		 INNER JOIN tbl_PB_JobCodes_Details jcd
		 ON ap.JobCodeID = jcd.JobCodeID
		 -- markup off of base cost or off of current cost including any existing adjustment?
		 --INNER JOIN tbl_PB_Parts p
		 --ON p.PartID = jcd.PartID AND p.MasterPartID <> @MarkupPartId 
		 GROUP BY ap.SubsectionID, ap.JobCodeID, ap.MarkupDetailID

	SET NOCOUNT OFF

	BEGIN TRAN

	PRINT 'Updating Existing Adjustment Parts'
	UPDATE jcd
	SET 
		jcd.PartStdPrice = jcd.PartStdPrice + u.PartStdPrice
		, jcd.PartMemberPrice = jcd.PartMemberPrice + u.PartMemberPrice
		, jcd.PartAddonStdPrice = jcd.PartAddonStdPrice + u.PartAddonStdPrice
		, jcd.PartAddonMemberPrice = jcd.PartAddonMemberPrice + u.PartAddonMemberPrice
	FROM tbl_PB_JobCodes_Details jcd
	INNER JOIN @Markups u
	ON jcd.JobCodeDetailsID = u.MarkupDetailID
	WHERE u.PartStdPrice <> 0 
		OR u.PartMemberPrice <> 0 
		OR u.PartAddonStdPrice <> 0 
		OR u.PartAddonMemberPrice <> 0

	PRINT 'Creating New Adjustment Parts'
	INSERT INTO tbl_PB_JobCodes_Details(JobCodeID
			, ManualPricingYN, PartAddonMemberPrice, PartAddonStdPrice
			, PartCost, PartID, PartMemberPrice, PartStdPrice, Qty)
	SELECT JobCodeID, 0, PartAddonMemberPrice, PartAddonStdPrice
		  , 0, @PriceBookMarkupPartId, PartMemberPrice, PartStdPrice, 1 FROM @Markups
	WHERE MarkupDetailID IS NULL
	AND (PartStdPrice <> 0 
		OR PartMemberPrice <> 0 
		OR PartAddonStdPrice <> 0 
		OR PartAddonMemberPrice <> 0)

	PRINT 'Recalculating totals for all jobs in price book.';
	WITH [NewJobCodeTotals] AS
	(
		SELECT jc.JobCodeID
		, SUM(ISNULL(jcd.PartStdPrice,0)) AS JobStdPrice
		, SUM(ISNULL(jcd.PartMemberPrice, 0)) AS JobMemberPrice
		, SUM(ISNULL(jcd.PartAddonStdPrice, 0)) AS JobAddOnStdPrice
		, SUM(ISNULL(jcd.PartAddOnMemberPrice, 0)) AS JobAddonMemberPrice
		 FROM tbl_PB_JobCodes jc
		 INNER JOIN tbl_PB_SubSection ss
		 ON jc.SubSectionID = ss.SubsectionID
		 INNER JOIN tbl_PB_Section s
		 ON s.SectionID = ss.SectionID AND s.PriceBookID = @PriceBookId
		 LEFT JOIN tbl_PB_JobCodes_Details jcd
		 ON jcd.JobCodeID = jc.JobCodeID
		GROUP BY jc.JobCodeID
	)
	UPDATE jc
	SET 
		jc.JobStdPrice = nt.JobStdPrice
		, jc.JobMemberPrice = nt.JobMemberPrice
		, jc.JobAddonStdPrice = nt.JobAddOnStdPrice
		, jc.JobAddonMemberPrice = nt.JobAddonMemberPrice
	FROM tbl_PB_JobCodes jc
	INNER JOIN NewJobCodeTotals nt
	ON jc.JobCodeID = nt.JobCodeID
	WHERE nt.JobStdPrice <> jc.JobStdPrice
	OR nt.JobMemberPrice <> jc.JobMemberPrice
	OR nt.JobAddOnStdPrice <> jc.JobAddonStdPrice
	OR nt.JobAddonMemberPrice <> jc.JobAddonMemberPrice

	COMMIT TRAN
	
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN
	DECLARE @msg VARCHAR(MAX)
	SET @msg = ERROR_MESSAGE()
		
	RAISERROR('Error occured applying markup to price book tree: %s', 1, 16, @msg)
END CATCH
GO
