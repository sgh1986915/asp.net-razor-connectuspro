USE [EightHundred]
GO
/****** Object:  StoredProcedure [dbo].[PB_CopySubSection]    Script Date: 03/30/2012 13:12:27 ******/
DROP PROCEDURE [dbo].[PB_CopySubSection]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--PB_CopySubSection 56, 96
CREATE PROC [dbo].[PB_CopySubSection]
	@PriceBookID INT,
	@NewPriceBookID INT	
AS
BEGIN
	
	BEGIN TRY
		
		IF EXISTS(
			SELECT	s.SectionID
			FROM	tbl_PB_SubSection ss
			INNER JOIN tbl_PB_Section s ON ss.SectionID = s.SectionID
			WHERE	s.PriceBookID = @NewPriceBookID		
				) BEGIN
			RAISERROR('Sub Section already exists for New Price Book', 1, 16)	
			RETURN
		END	
		
		
		BEGIN TRAN
	
		--Copy Sections
		INSERT INTO tbl_PB_SubSection(
			[SectionID]
           ,[SubSectionName]
           ,[ActiveYN]
           ,[MFlag]
		)
		SELECT
			ns.SectionID
           ,ss.[SubSectionName]
           ,ss.[ActiveYN]
           ,ss.[MFlag]
		FROM tbl_PB_SubSection ss
		INNER JOIN tbl_PB_Section s ON ss.SectionID = s.SectionID 
			AND s.PriceBookID= @PriceBookID
		INNER JOIN tbl_PB_Section ns ON ns.SectionName = s.SectionName
				AND ns.PriceBookID=@NewPriceBookID
		 
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK TRAN
		
		DECLARE @msg VARCHAR(MAX)
		SELECT @msg = ERROR_MESSAGE()
		
		RAISERROR('Error occured in PB_CopySubSection, %s', 1, 16, @msg)
			
	END CATCH
END
GO
