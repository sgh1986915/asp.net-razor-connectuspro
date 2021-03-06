USE [EightHundred]
GO
/****** Object:  StoredProcedure [dbo].[SaveImageToDisk]    Script Date: 03/30/2012 13:12:29 ******/
DROP PROCEDURE [dbo].[SaveImageToDisk]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SaveImageToDisk]
	@JobID INT,
	@OutputPath VARCHAR(100),
	@AcceptedByWritten BIT OUTPUT,
	@AuthorizationWritten BIT OUTPUT
	
AS
BEGIN
	DECLARE @ObjectToken INT
	DECLARE @AcceptedBy VARBINARY(MAX),
			@AuthorizationToStart VARBINARY(MAX),
			@Path VARCHAR(100)
	
	BEGIN TRY	
	
		SELECT	
				@AcceptedBy = CAST(AcceptedBy AS VARBINARY(MAX)),
				@AuthorizationToStart = CAST(AuthorizationToStart AS VARBINARY(MAX))
		FROM dbo.tbl_Job (NOLOCK)
		WHERE JobID = @JobID
		
		IF @AcceptedBy IS NOT NULL BEGIN
			SET @AcceptedByWritten = 1
			SET @Path = @OutputPath + CAST(@JobID AS VARCHAR(50)) + '_Accepted.jpg'
			EXEC sp_OACreate 'ADODB.Stream', @ObjectToken OUTPUT
			EXEC sp_OASetProperty @ObjectToken, 'Type', 1
			EXEC sp_OAMethod @ObjectToken, 'Open'
			EXEC sp_OAMethod @ObjectToken, 'Write', NULL,@AcceptedBy
			EXEC sp_OAMethod @ObjectToken, 'SaveToFile', NULL,@Path , 2
			EXEC sp_OAMethod @ObjectToken, 'Close'
			EXEC sp_OADestroy @ObjectToken	
		END	
			
		IF @AuthorizationToStart IS NOT NULL BEGIN
			SET @AuthorizationWritten = 1
			SET @Path = @OutputPath + CAST(@JobID AS VARCHAR(50)) + '_Signature.jpg'
			EXEC sp_OACreate 'ADODB.Stream', @ObjectToken OUTPUT
			EXEC sp_OASetProperty @ObjectToken, 'Type', 1
			EXEC sp_OAMethod @ObjectToken, 'Open'
			EXEC sp_OAMethod @ObjectToken, 'Write', NULL,@AuthorizationToStart
			EXEC sp_OAMethod @ObjectToken, 'SaveToFile', NULL,@Path , 2
			EXEC sp_OAMethod @ObjectToken, 'Close'
			EXEC sp_OADestroy @ObjectToken	
		END	
			
	END TRY
	BEGIN CATCH
		SELECT ERROR_LINE(),ERROR_MESSAGE() 
	END CATCH
END
GO
