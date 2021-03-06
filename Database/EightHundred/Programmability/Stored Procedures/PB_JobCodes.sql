USE [EightHundred]
GO
/****** Object:  StoredProcedure [dbo].[PB_JobCodes]    Script Date: 03/30/2012 13:12:28 ******/
DROP PROCEDURE [dbo].[PB_JobCodes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--PB_JobCodes 56, 96
CREATE PROC [dbo].[PB_JobCodes]
	@PriceBookID INT,
	@NewPriceBookID INT	
AS
BEGIN
	
	
	BEGIN TRY
		
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
		
		
		BEGIN TRAN
	
		--Copy Sections
		INSERT INTO [dbo].[tbl_PB_JobCodes]
           ([SubSectionID]
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
			nss.SubSectionID 
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
		  INNER JOIN tbl_PB_Section s ON s.SectionID = ss.SectionID
			AND s.PriceBookID = @PriceBookID 
		  
		  INNER JOIN tbl_PB_SubSection nss ON nss.SubsectionName = ss.SubsectionName
		  INNER JOIN tbl_PB_Section ns ON ns.SectionID = nss.SectionID
			AND ns.SectionName = s.SectionName
			AND ns.PriceBookID = @NewPriceBookID
		
		
			
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK TRAN
		
		DECLARE @msg VARCHAR(MAX)
		SELECT @msg = ERROR_MESSAGE()
		
		RAISERROR('Error occured in PB_JobCodes, %s', 1, 16, @msg)
			
	END CATCH
END
GO
