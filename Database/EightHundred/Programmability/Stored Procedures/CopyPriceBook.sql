USE [EightHundred]
GO
/****** Object:  StoredProcedure [dbo].[CopyPriceBook]    Script Date: 03/30/2012 13:12:26 ******/
DROP PROCEDURE [dbo].[CopyPriceBook]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--CopyPriceBook 53, 89
CREATE PROC [dbo].[CopyPriceBook]
	@PriceBookID INT,
	@NewPriceBookID INT
AS
BEGIN
	
	DECLARE @MaxSectionID INT, @MaxSubSectionID INT, @MaxJobCodeID INT, @MaxJobCodeDetailID INT, @MaxPartID INT
	SELECT  @MaxSectionID = 0,
			@MaxSubSectionID = 0,
			@MaxJobCodeID = 0,
			@MaxJobCodeDetailID=0,
			@MaxPartID=0

	DECLARE @Mappings TABLE(
			MapType VARCHAR(20),
			OldKey INT,
			NewKey INT
	)
	
	DECLARE @Val TABLE(
			MapType VARCHAR(20),
			OldCount INT,
			NewCount INT
	)
	
	INSERT INTO @Val(MapType,OldCount,NewCount) VALUES('Part',NULL,NULL)
	INSERT INTO @Val(MapType,OldCount,NewCount) VALUES('Section',NULL,NULL)
	INSERT INTO @Val(MapType,OldCount,NewCount) VALUES('SubSection',NULL,NULL)
	INSERT INTO @Val(MapType,OldCount,NewCount) VALUES('JobCode',NULL,NULL)
	INSERT INTO @Val(MapType,OldCount,NewCount) VALUES('JobCodeDetail',NULL,NULL)
	
	BEGIN TRY
		SET NOCOUNT ON
		IF EXISTS(
			SELECT	s.SectionID
			FROM	tbl_PB_Section s
			WHERE	s.PriceBookID = @NewPriceBookID		
				) BEGIN
			RAISERROR('Section already exists for New Price Book', 1, 16)	
			RETURN
		END		
	
		IF EXISTS(
			SELECT	s.SectionID
			FROM	tbl_PB_SubSection ss
			INNER JOIN tbl_PB_Section s ON ss.SectionID = s.SectionID
			WHERE	s.PriceBookID = @NewPriceBookID		
				) BEGIN
			RAISERROR('Sub Section already exists for New Price Book', 1, 16)	
			RETURN
		END		
		
		IF EXISTS(
			SELECT	s.SectionID
			FROM	tbl_PB_JobCodes j	
			INNER JOIN tbl_PB_SubSection ss ON j.SubSectionID = ss.SubsectionID
			INNER JOIN tbl_PB_Section s ON ss.SectionID = s.SectionID
			WHERE	s.PriceBookID = @NewPriceBookID		
				) BEGIN
			RAISERROR('Job Codes already exists for New Price Book', 1, 16)	
			RETURN
		END		
		
		IF EXISTS(
			SELECT	s.SectionID
			FROM	tbl_PB_JobCodes_Details jd
			INNER JOIN tbl_PB_JobCodes j ON j.JobCodeID = jd.JobCodeID
			INNER JOIN tbl_PB_SubSection ss ON j.SubSectionID = ss.SubsectionID
			INNER JOIN tbl_PB_Section s ON ss.SectionID = s.SectionID
			WHERE	s.PriceBookID = @NewPriceBookID		
				) BEGIN
			RAISERROR('Job Details already exists for New Price Book', 1, 16)	
			RETURN
		END		
		SET NOCOUNT OFF
		
		BEGIN TRAN
	
/****************************Store Max Values******************************************/

		SELECT	@MaxPartID = MAX(PartID) FROM tbl_PB_Parts
		SELECT	@MaxSectionID = MAX(SectionID) FROM	tbl_PB_Section
		SELECT	@MaxSubSectionID = MAX(SubSectionID) FROM tbl_PB_SubSection
		SELECT	@MaxJobCodeID = MAX(jobCodeID) FROM	tbl_PB_JobCodes
		SELECT	@MaxJobCodeDetailID = MAX(JobCodeDetailsID) FROM tbl_PB_JobCodes_Details

/***************************Create old/new key mappings*****************************/			
PRINT 'Loading part mappings'
		INSERT INTO @Mappings(MapType, OldKey, NewKey)
		SELECT 'Part', PartID, @MaxPartID + ROW_NUMBER() OVER(ORDER BY PartID) AS NewKey
		FROM tbl_PB_Parts WHERE PriceBookID = @PriceBookID
UPDATE @Val SET OldCount = @@ROWCOUNT WHERE MapType = 'Part'

PRINT 'Loading section mappings'
		INSERT INTO @Mappings(MapType, OldKey, NewKey)
		SELECT 'Section', SectionId, @MaxSectionID + ROW_NUMBER() OVER(ORDER BY SectionID) AS NewKey
		FROM tbl_PB_Section WHERE PriceBookID = @PriceBookID
UPDATE @Val SET OldCount = @@ROWCOUNT WHERE MapType = 'Section'

PRINT 'Loading subsection mappings'
		INSERT INTO @Mappings(MapType, OldKey, NewKey)
		SELECT 'SubSection', ss.SubSectionId, @MaxSubSectionID + ROW_NUMBER() OVER(ORDER BY ss.SubSectionID) AS NewKey
		FROM tbl_PB_SubSection ss
		INNER JOIN tbl_PB_Section s
		ON ss.SectionID = s.SectionID AND s.PriceBookID = @PriceBookID
UPDATE @Val SET OldCount = @@ROWCOUNT WHERE MapType = 'SubSection'
		
PRINT 'Loading job code mappings'
		INSERT INTO @Mappings(MapType, OldKey, NewKey)
		SELECT 'JobCode', jc.JobCodeID, @MaxJobCodeID + ROW_NUMBER() OVER(ORDER BY jc.JobCodeId) AS NewKey
		FROM tbl_PB_JobCodes jc
		INNER JOIN tbl_PB_SubSection ss
		ON jc.SubSectionID = ss.SubsectionID
		INNER JOIN tbl_PB_Section s
		ON ss.SectionID = s.SectionID AND s.PriceBookID = @PriceBookID
UPDATE @Val SET OldCount = @@ROWCOUNT WHERE MapType = 'JobCode'

PRINT 'Loading job code detail mappings'	
		INSERT INTO @Mappings(MapType, OldKey, NewKey)
		SELECT 'JobCodeDetail', jcd.JobCodeDetailsID, @MaxJobCodeDetailID + ROW_NUMBER() OVER(ORDER BY jcd.JobCodeDetailsID) AS NewKey
		FROM tbl_PB_JobCodes_Details jcd
		INNER JOIN tbl_PB_JobCodes jc
		ON jcd.JobCodeID = jc.JobCodeID
		INNER JOIN tbl_PB_SubSection ss
		ON jc.SubSectionID = ss.SubsectionID
		INNER JOIN tbl_PB_Section s
		ON ss.SectionID = s.SectionID AND s.PriceBookID = @PriceBookID
UPDATE @Val SET OldCount = @@ROWCOUNT WHERE MapType = 'JobCodeDetail'

/*****************************Copy Parts************************************/
PRINT 'Copying Parts'
		SET IDENTITY_INSERT [tbl_PB_Parts] ON
		INSERT INTO [dbo].[tbl_PB_Parts](
			  Markup
			, MasterPartID
			, PartAddonMemberPrice
			, PartAddonStdPrice
			, PartCost
			, PartID
			, PartMemberPrice
			, PartStdPrice
			, PriceBookID)
		SELECT p.Markup
			, p.MasterPartID
			, p.PartAddonMemberPrice
			, p.PartAddonStdPrice
			, p.PartCost
			, mappings.NewKey AS [PartID]
			, p.PartMemberPrice
			, p.PartStdPrice
			, @NewPriceBookID AS PriceBookID
          FROM tbl_PB_Parts p 
          INNER JOIN @Mappings mappings 
          ON p.PartID = mappings.OldKey AND mappings.MapType = 'Part'
          WHERE p.PriceBookID  = @PriceBookID 
         UPDATE @Val SET NewCount = @@ROWCOUNT WHERE MapType = 'Part'
          SET IDENTITY_INSERT [tbl_PB_Parts] OFF
			
/*****************************Copy Sections************************************/
PRINT 'Copying Sections'
		SET IDENTITY_INSERT [tbl_PB_Section] ON
		INSERT INTO [dbo].[tbl_PB_Section](
			[SectionID]
           ,[PriceBookID]
           ,[SectionName]
           ,[ActiveYN]
           ,[MFlag])
		SELECT
			mappings.NewKey AS [SectionID]
		   ,@NewPriceBookID AS PriceBookID
           ,s.[SectionName]
           ,s.[ActiveYN]
           ,s.[MFlag] 
          FROM tbl_PB_Section s 
          INNER JOIN @Mappings mappings 
          ON s.SectionID = mappings.OldKey AND mappings.MapType = 'Section'
          WHERE s.PriceBookID  = @PriceBookID 
          UPDATE @Val SET NewCount = @@ROWCOUNT WHERE MapType = 'Section'
		SET IDENTITY_INSERT [tbl_PB_Section] OFF
		
/*****************************Copy SubSections************************************/
PRINT 'Copying SubSections'		
		SET IDENTITY_INSERT [tbl_PB_SubSection] ON
		INSERT INTO tbl_PB_SubSection(
			[SubsectionID]
           ,[SectionID]
           ,[SubSectionName]
           ,[ActiveYN]
           ,[MFlag]
		)
		SELECT
			ssMappings.NewKey AS [SubSectionID]
           ,sMappings.NewKey AS [SectionID]
           ,ss.[SubSectionName]
           ,ss.[ActiveYN]
           ,ss.[MFlag]
		  FROM tbl_PB_SubSection ss
		  INNER JOIN @Mappings ssMappings ON ssMappings.MapType = 'SubSection' AND ssMappings.OldKey = ss.SubsectionID
		  INNER JOIN tbl_PB_Section s ON ss.SectionID = s.SectionID
		  INNER JOIN @Mappings sMappings ON sMappings.MapType = 'Section' AND sMappings.OldKey = s.SectionID
		  UPDATE @Val SET NewCount = @@ROWCOUNT WHERE MapType = 'SubSection'
		SET IDENTITY_INSERT [tbl_PB_SubSection] OFF
		
/*****************************Copy Job Codes************************************/
PRINT 'Copying Job Codes'	
		SET IDENTITY_INSERT [tbl_PB_JobCodes] ON
		INSERT INTO [dbo].[tbl_PB_JobCodes]
           ([JobCodeID]
           ,[SubSectionID]
           ,[ManualPricingYN]
           ,[ActiveYN]
           ,[JobCode]
           ,[JobCodeDescription]
           ,[JobCost]
           ,[JobStdPrice]
           ,[JobMemberPrice]
           ,[JobAddonStdPrice]
           ,[JobAddonMemberPrice]
           ,[ResAccountCode]
           ,[ComAccountCode]
           ,[MFlag]
          )
		SELECT
			jcMappings.NewKey AS JobCodeId
           ,ssMappings.NewKey AS SubSectionID 
           ,j.ManualPricingYN
           ,j.ActiveYN
           ,j.JobCode
           ,j.JobCodeDescription
           ,j.JobCost
           ,j.JobStdPrice
           ,j.JobMemberPrice
           ,j.JobAddonStdPrice
           ,j.JobAddonMemberPrice
           ,j.ResAccountCode
           ,j.ComAccountCode
           ,j.MFlag 
		  FROM tbl_PB_JobCodes j
		  INNER JOIN tbl_PB_SubSection ss ON ss.SubsectionID = j.SubSectionID
		  INNER JOIN tbl_PB_Section s ON ss.SectionID = s.SectionID
		  AND s.PriceBookID = @PriceBookID
		  INNER JOIN @Mappings ssMappings ON ssMappings.MapType = 'SubSection' AND ssMappings.OldKey = ss.SubsectionID
		  INNER JOIN @Mappings jcMappings ON jcMappings.MapType = 'JobCode' AND jcMappings.OldKey = j.JobCodeID
		  UPDATE @Val SET NewCount = @@ROWCOUNT WHERE MapType = 'JobCode'
		  SET IDENTITY_INSERT [tbl_PB_JobCodes] OFF
		  
/*****************************Copy Job Code Details************************************/
PRINT 'Copying Job Code Details'	
		SET IDENTITY_INSERT [tbl_PB_JobCodes_Details] ON
		INSERT INTO [dbo].[tbl_PB_JobCodes_Details](
			[JobCodeDetailsID]
           ,[JobCodeID]
           ,[PartID]
           ,[Qty]
           ,[ManualPricingYN]
           ,[PartCost]
           ,[PartStdPrice]
           ,[PartMemberPrice]
           ,[PartAddonStdPrice]
           ,[PartAddonMemberPrice]		
          )
		SELECT		
			jcdMappings.NewKey [JobCodeDetailsID]
           ,jcMappings.NewKey AS [JobCodeID]
           ,pMappings.NewKey AS PartID
           ,jd.[Qty]
           ,jd.[ManualPricingYN]
           ,jd.[PartCost]
           ,jd.[PartStdPrice]
           ,jd.[PartMemberPrice]
           ,jd.[PartAddonStdPrice]
           ,jd.[PartAddonMemberPrice]
		FROM	tbl_PB_JobCodes_Details jd
		INNER JOIN tbl_PB_JobCodes j ON j.JobCodeID = jd.JobCodeID
		INNER JOIN tbl_PB_SubSection ss ON ss.SubSectionID = j.SubSectionID
		INNER JOIN tbl_PB_Section s ON ss.SectionID = s.SectionID AND s.PriceBookID = @PriceBookID
		INNER JOIN @Mappings pMappings ON pMappings.MapType = 'Part' AND pMappings.OldKey = jd.PartID
		INNER JOIN @Mappings jcdMappings ON jcdMappings.MapType = 'JobCodeDetail' AND jcdMappings.OldKey = jd.JobCodeDetailsID
		INNER JOIN @Mappings jcMappings ON jcMappings.MapType = 'JobCode' AND jcMappings.OldKey = jd.JobCodeID
		UPDATE @Val SET NewCount = @@ROWCOUNT WHERE MapType = 'JobCodeDetail'
		SET IDENTITY_INSERT [tbl_PB_JobCodes_Details] OFF

		IF EXISTS(SELECT 1 FROM @Val WHERE OldCount <> NewCount)
		BEGIN
			ROLLBACK TRAN
			RAISERROR('Validation of copy process failed.  The source price book may be corrupt.', 16, 1)
		END
		ELSE
		BEGIN
			PRINT 'Success'
			COMMIT TRAN;
		END
			
		
	END TRY
	BEGIN CATCH
	
		/***************************Ensure Disable Identity Insert**************************/
		SET IDENTITY_INSERT [tbl_PB_Parts] OFF
		SET IDENTITY_INSERT [tbl_PB_Section] OFF
		SET IDENTITY_INSERT [tbl_PB_SubSection] OFF
		SET IDENTITY_INSERT [tbl_PB_JobCodes] OFF
		SET IDENTITY_INSERT [tbl_PB_JobCodes_Details] OFF
		
		IF @@TRANCOUNT > 0 
		BEGIN
			ROLLBACK TRAN
			PRINT 'Rolled back'
		END
		
		DECLARE @msg VARCHAR(MAX)
		SELECT @msg = ERROR_MESSAGE()
		
		RAISERROR('Error occured in CopyPriceBook: %s', 16, 1, @msg)
			
	END CATCH
END
GO
