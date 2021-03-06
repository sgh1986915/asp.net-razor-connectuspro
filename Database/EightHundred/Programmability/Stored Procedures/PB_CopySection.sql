USE [EightHundred]
GO
/****** Object:  StoredProcedure [dbo].[PB_CopySection]    Script Date: 03/30/2012 13:12:27 ******/
DROP PROCEDURE [dbo].[PB_CopySection]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--PB_CopySection 56, 96
CREATE PROC [dbo].[PB_CopySection]
	@PriceBookID INT,
	@NewPriceBookID INT	
AS
BEGIN
	BEGIN TRY
		
		IF EXISTS(
			SELECT	s.SectionID
			FROM	tbl_PB_Section s
			WHERE	s.PriceBookID = @NewPriceBookID		
				) BEGIN
			RAISERROR('Section already exists for New Price Book', 1, 16)	
			RETURN
		END		
		
		
		BEGIN TRAN
	
		--Copy Sections
		INSERT INTO [dbo].[tbl_PB_Section](
			[PriceBookID]
           ,[SectionName]
           ,[ActiveYN]
           ,[MFlag])  	
		SELECT
			@NewPriceBookID
           ,s.[SectionName]
           ,s.[ActiveYN]
           ,s.[MFlag] 
          FROM tbl_PB_Section s 
          WHERE s.PriceBookID  = @PriceBookID 
		
		
			
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK TRAN
		
		DECLARE @msg VARCHAR(MAX)
		SELECT @msg = ERROR_MESSAGE()
		
		RAISERROR('Error occured in PB_CopySection, %s', 1, 16, @msg)
			
	END CATCH
END
GO
