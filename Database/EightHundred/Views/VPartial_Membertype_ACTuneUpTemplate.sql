USE [EightHundred]
GO
/****** Object:  View [dbo].[VPartial_Membertype_ACTuneUpTemplate]    Script Date: 04/04/2012 21:45:21 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[VPartial_Membertype_ACTuneUpTemplate]'))
DROP VIEW [dbo].[VPartial_Membertype_ACTuneUpTemplate]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[VPartial_Membertype_ACTuneUpTemplate]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[VPartial_Membertype_ACTuneUpTemplate]
AS
SELECT     dbo.tbl_MemberType_VisitsTypes.MemberTypeID, 12 / vistype1.VisitFrequency AS HeatingCoolingTuneUpPerAnnum
FROM         dbo.tbl_MemberType_VisitsTypes INNER JOIN
                      dbo.tbl_VisitType AS vistype1 ON dbo.tbl_MemberType_VisitsTypes.VisitTypeID = vistype1.VisitTypeID AND vistype1.VisitTypeID = 3
'
GO
