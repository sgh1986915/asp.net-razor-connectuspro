USE [EightHundred]
GO
/****** Object:  View [dbo].[vRpt_Membership]    Script Date: 04/04/2012 21:45:21 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vRpt_Membership]'))
DROP VIEW [dbo].[vRpt_Membership]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vRpt_Membership]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vRpt_Membership]
AS
SELECT     TOP (100) PERCENT cm.MemberID AS MembershipID, cm.CustomerID AS billtoCustomerID, cm.FranchiseID AS ClientID, 
                      dbo.vRpt_MembershipInspections.ClientID AS InspectionClientID, cm.MemberTypeID, dbo.tbl_Member_Type.MemberType, cm.StartDate AS MembershipStartDate, 
                      cm.EndDate AS MembershipEndDate, ISNULL(dbo.VPartial_Membertype_PlumbingInspectionTemplate.PlumbingInspectionPerAnnum, 0) 
                      AS req_PlumbingInspectionsPerYear, ISNULL(dbo.VPartial_MemberType_WaterHeaterFlusingTemplate.WaterHeaterFlushingPerAnnum, 0) 
                      AS req_WaterHeaterFlushingsPerYear, ISNULL(dbo.VPartial_Membertype_ACTuneUpTemplate.HeatingCoolingTuneUpPerAnnum, 0) AS req_ACTuneUpsPerYear, 
                      ISNULL(dbo.VPartial_Membertype_PlumbingInspectionTemplate.PlumbingInspectionPerAnnum, 0) 
                      + ISNULL(dbo.VPartial_MemberType_WaterHeaterFlusingTemplate.WaterHeaterFlushingPerAnnum, 0) 
                      + ISNULL(dbo.VPartial_Membertype_ACTuneUpTemplate.HeatingCoolingTuneUpPerAnnum, 0) AS req_TotalInspectionsPerYear, 
                      COUNT(dbo.vRpt_MembershipInspections.JobID) AS CountOfInspections, ISNULL(dbo.VPartial_Membertype_ACTuneUpTemplate.HeatingCoolingTuneUpPerAnnum, 0) 
                      AS bal_ACTuneUpsPerYear, MAX(dbo.vRpt_MembershipInspections.CallCompleted) AS LastDateInspected, ISNULL(dbo.vRpt_CustomerVisits.CountJobs, 0) 
                      AS CountCustomerVisits, dbo.vRpt_CustomerVisits.LastVisit AS LastCustomerVisit
FROM         dbo.tbl_Customer_Members AS cm LEFT OUTER JOIN
                      dbo.tbl_Member_Type ON cm.MemberTypeID = dbo.tbl_Member_Type.MemberTypeID LEFT OUTER JOIN
                      dbo.vRpt_CustomerVisits ON cm.CustomerID = dbo.vRpt_CustomerVisits.CustomerID LEFT OUTER JOIN
                      dbo.vRpt_MembershipInspections ON cm.CustomerID = dbo.vRpt_MembershipInspections.CustomerID LEFT OUTER JOIN
                      dbo.VPartial_Membertype_PlumbingInspectionTemplate ON 
                      cm.MemberTypeID = dbo.VPartial_Membertype_PlumbingInspectionTemplate.MemberTypeID LEFT OUTER JOIN
                      dbo.VPartial_MemberType_WaterHeaterFlusingTemplate ON 
                      cm.MemberTypeID = dbo.VPartial_MemberType_WaterHeaterFlusingTemplate.MemberTypeID LEFT OUTER JOIN
                      dbo.VPartial_Membertype_ACTuneUpTemplate ON cm.MemberTypeID = dbo.VPartial_Membertype_ACTuneUpTemplate.MemberTypeID
GROUP BY cm.MemberID, cm.CustomerID, cm.FranchiseID, dbo.vRpt_MembershipInspections.ClientID, cm.MemberTypeID, cm.StartDate, cm.EndDate, 
                      ISNULL(dbo.VPartial_Membertype_PlumbingInspectionTemplate.PlumbingInspectionPerAnnum, 0), 
                      ISNULL(dbo.VPartial_MemberType_WaterHeaterFlusingTemplate.WaterHeaterFlushingPerAnnum, 0), 
                      ISNULL(dbo.VPartial_Membertype_ACTuneUpTemplate.HeatingCoolingTuneUpPerAnnum, 0), 
                      ISNULL(dbo.VPartial_Membertype_PlumbingInspectionTemplate.PlumbingInspectionPerAnnum, 0) 
                      + ISNULL(dbo.VPartial_MemberType_WaterHeaterFlusingTemplate.WaterHeaterFlushingPerAnnum, 0) 
                      + ISNULL(dbo.VPartial_Membertype_ACTuneUpTemplate.HeatingCoolingTuneUpPerAnnum, 0), dbo.vRpt_CustomerVisits.CountJobs, 
                      dbo.vRpt_CustomerVisits.LastVisit, dbo.tbl_Member_Type.MemberType
ORDER BY billtoCustomerID
'
GO
