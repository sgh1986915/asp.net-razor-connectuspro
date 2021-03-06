USE [EightHundred]
GO
/****** Object:  StoredProcedure [dbo].[RecalculateTree]    Script Date: 03/30/2012 13:12:28 ******/
DROP PROCEDURE [dbo].[RecalculateTree]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RecalculateTree] 
( @Level INT --0 = PriceBook, 1 = Section, 2 = SubSection, 3 = Task
, @LevelId INT --Id of level parameter.  If level = 1 then this should be a section id.
) AS

DECLARE @MarkupAsPercentage INT
SET @MarkupAsPercentage = 0

DECLARE @MarkupMasterPartId INT
SET @MarkupMasterPartId = 5350

EXEC [dbo].[ApplyMarkup] @Level, @LevelId, @MarkupAsPercentage, @MarkupMasterPartId
GO
