USE [EightHundred]
GO
/****** Object:  StoredProcedure [dbo].[DeletePriceBook]    Script Date: 03/30/2012 13:12:26 ******/
DROP PROCEDURE [dbo].[DeletePriceBook]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[DeletePriceBook] 
	@PriceBookID INT 
AS
BEGIN
	BEGIN TRY
		BEGIN TRAN
		
			DELETE jcd
			FROM tbl_PB_JobCodes_Details jcd
			INNER JOIN tbl_PB_JobCodes jc
			ON jcd.JobCodeID = jc.JobCodeID
			INNER JOIN tbl_PB_SubSection ss
			ON ss.SubSectionId = jc.SubSectionID
			INNER JOIN tbl_PB_Section s
			ON s.SectionID = ss.SectionID
			WHERE s.PriceBookID = @PriceBookID

			DELETE jcd
			FROM tbl_PB_JobCodes_Details jcd
			INNER JOIN tbl_PB_JobCodes jc
			ON jcd.JobCodeID = jc.JobCodeID
			INNER JOIN tbl_PB_SubSection ss
			ON ss.SubSectionId = jc.SubSectionID
			INNER JOIN tbl_PB_Section s
			ON s.SectionID = ss.SectionID
			LEFT JOIN tbl_PB_Parts p
			ON jcd.partid = p.partid and p.pricebookid <> @PriceBookID
			WHERE s.PriceBookID = @PriceBookID OR p.partid IS NULL

			DELETE jc
			FROM tbl_PB_JobCodes jc
			INNER JOIN tbl_PB_SubSection ss
			ON ss.SubSectionId = jc.SubSectionID
			INNER JOIN tbl_PB_Section s
			ON s.SectionID = ss.SectionID
			WHERE s.PriceBookID = @PriceBookID

			DELETE ss
			FROM tbl_PB_SubSection ss
			INNER JOIN tbl_PB_Section s
			ON s.SectionID = ss.SectionID
			WHERE s.PriceBookID = @PriceBookID

			DELETE s
			FROM tbl_PB_Section s
			WHERE s.PriceBookID = @PriceBookID

			DELETE FROM tbl_PB_Parts WHERE PriceBookID = @PriceBookID
			DELETE FROM tbl_PriceBook WHERE PriceBookID = @PriceBookID
			
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK TRAN
		
		DECLARE @msg VARCHAR(MAX)
		SELECT @msg = ERROR_MESSAGE()
		
		RAISERROR('Error occured in tbl_PriceBook, %s', 1, 16, @msg)
			
	END CATCH
END
GO
