USE [EightHundred]
GO
/****** Object:  StoredProcedure [dbo].[PB_JobCodes_Details]    Script Date: 03/30/2012 13:12:28 ******/
DROP PROCEDURE [dbo].[PB_JobCodes_Details]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[PB_JobCodes_Details] 56, 96
CREATE PROC [dbo].[PB_JobCodes_Details]
	@PriceBookID INT,
	@NewPriceBookID INT	
AS
BEGIN
	
	

	BEGIN TRY
		
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
		
		
		BEGIN TRAN
	
		--Copy Sections
		INSERT INTO [dbo].[tbl_PB_JobCodes_Details](
			[JobCodeID]
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
			nj.[JobCodeID]
           ,jd.[PartID]
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
		INNER JOIN tbl_PB_Section s ON ss.SectionID = s.SectionID 
		AND S.PriceBookID=@PriceBookID
		
		inner join tbl_PB_JobCodes  nj On nj.JobCode=j.JobCode 
			and nj.JobCodeDescription=j.JobCodeDescription
		inner join tbl_PB_SubSection nss On nss.SubsectionID = nj.SubSectionID
			AND nss.SubSectionName=ss.SubSectionName
		inner join tbl_PB_Section ns On ns.SectionID=nss.SectionID
		   And ns.SectionName=s.SectionName
		   And ns.PriceBookID=@NewPriceBookID
		ORDER BY 1	
		 	
		 
		
		
			
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK TRAN
		
		DECLARE @msg VARCHAR(MAX)
		SELECT @msg = ERROR_MESSAGE()
		
		RAISERROR('Error occured in PB_JobCodes_Details, %s', 1, 16, @msg)
			
	END CATCH
END
GO
