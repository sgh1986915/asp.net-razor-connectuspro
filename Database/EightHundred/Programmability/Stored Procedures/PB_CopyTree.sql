USE [EightHundred]
GO
/****** Object:  StoredProcedure [dbo].[PB_CopyTree]    Script Date: 03/30/2012 13:12:27 ******/
DROP PROCEDURE [dbo].[PB_CopyTree]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--PB_CopyTree 56, 96
CREATE PROC [dbo].[PB_CopyTree]
	@PriceBookID INT,
	@NewPriceBookID INT	
AS
BEGIN
	
	BEGIN TRY
		BEGIN TRAN
		
			EXEC PB_CopySection
				@PriceBookID = @PriceBookID,
				@NewPriceBookID = @NewPriceBookID
				
			EXEC PB_CopySubSection
				@PriceBookID = @PriceBookID,
				@NewPriceBookID = @NewPriceBookID
				
			EXEC PB_JobCodes
				@PriceBookID = @PriceBookID,
				@NewPriceBookID = @NewPriceBookID
				
			EXEC PB_JobCodes_Details			
				@PriceBookID = @PriceBookID,
				@NewPriceBookID = @NewPriceBookID
				
	   COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK TRAN
		
		DECLARE @msg VARCHAR(MAX)
		SELECT @msg = ERROR_MESSAGE()
		
		RAISERROR('Error occured in PB_CopyTree, %s', 1, 16, @msg)
			
	END CATCH
END
GO
