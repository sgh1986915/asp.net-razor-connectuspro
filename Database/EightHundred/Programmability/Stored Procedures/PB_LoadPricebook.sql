USE [EightHundred]
GO
/****** Object:  StoredProcedure [dbo].[PB_LoadPricebook]    Script Date: 03/30/2012 13:12:28 ******/
DROP PROCEDURE [dbo].[PB_LoadPricebook]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--PB_CopySection 56, 96
CREATE PROC [dbo].[PB_LoadPricebook]
AS
BEGIN
BEGIN TRAN
DECLARE @LastPriceBook INT
DECLARE @LastSection INT
DECLARE @LastSubSection INT
DECLARE @LastJob INT
DECLARE @LastTaskDetail INT
DECLARE @LastPart INT
DECLARE @LastMasterPart INT

DECLARE @PriceBooks TABLE([PriceBookID] [int],
	[FranchiseID] [int],
	[ConceptID] [int],
	[EffectiveDate] [smalldatetime],
	[BookName] [varchar](50),
	[BookComments] [text],
	[ActiveBookYN] [bit],
	[MemberPricePercent] [float])
DECLARE @Sections TABLE(ID INT, PriceBookID INT, SectionName VARCHAR(50))
DECLARE @SubSections TABLE(ID INT, SectionID INT, SubSectionName VARCHAR(50))
DECLARE @Jobs TABLE(ID INT, TreeID INT, SubSectionID INT, JobCode VARCHAR(10), JobCodeDescription VARCHAR(100), JobCost MONEY, JobStdPrice MONEY, JobMembePrice MONEY, JobAddonStdPrice MONEY, JobAddonMemberPrice MONEY, ResAccountCode VARCHAR(5), ComAccountCode VARCHAR(5))
DECLARE @TaskDetails TABLE(ID INT, JobCodeID INT, PartID INT, Qty MONEY, PartCost MONEY, PartStdPrice MONEY, PartMemberPrice MONEY, PartAddonStdPrice MONEY, PartAddonMemberPrice MONEY)
DECLARE @MasterParts TABLE([MasterPartID] INT, [ConceptID] INT
				, FranchiseID INT
				, PartCode VARCHAR(25)
				, PartCodeID CHAR(2)
				, PartCost MONEY
				, PartName VARCHAR(100)
				, VendorPartID VARCHAR(20))
DECLARE @PriceBookParts TABLE(
	[ID] [int],
	[PriceBookID] [int] ,
	[MasterPartID] [int] ,
	[PartCost] [money] ,
	[PartStdPrice] [money] ,
	[PartMemberPrice] [money] ,
	[PartAddonStdPrice] [money] ,
	[PartAddonMemberPrice] [money] ,
	[Markup] [float])

SELECT @LastSection = MAX(SectionID) FROM tbl_PB_Section
SELECT @LastSubSection = MAX(SubSectionID) FROM tbl_PB_SubSection
SELECT @LastJob = MAX(JobCodeID) FROM tbl_PB_JobCodes
SELECT @LastPriceBook = MAX(PriceBookID) FROM tbl_PriceBook
SELECT @LastTaskDetail = MAX(JobCodeDetailsID) FROM tbl_PB_JobCodes_Details
SELECT @LastPart = MAX(PartID) FROM tbl_PB_Parts
SELECT @LastMasterPart = MAX(MasterPartID) FROM tbl_PB_MasterParts

INSERT INTO @PriceBooks(PriceBookID, FranchiseID, BookName, ConceptID, EffectiveDate, ActiveBookYN, MemberPricePercent)
SELECT ROW_NUMBER() OVER(ORDER BY BookName) + @LastPriceBook
	, CompanyCodeID
	, BookName
	, 1
	, GETDATE()
	, 1
	, 15
FROM tbl_PBU_Tree
GROUP BY CompanyCodeID, BookName

INSERT INTO @Sections
SELECT ROW_NUMBER() OVER(ORDER BY t.SectionName) + @LastSection
	 , p.PriceBookID
	 , t.SectionName
FROM tbl_PBU_Tree t
INNER JOIN @PriceBooks p
ON t.BookName = p.BookName AND t.CompanyCodeID = p.FranchiseID
GROUP BY p.PriceBookID, SectionName

INSERT INTO @SubSections
SELECT ROW_NUMBER() OVER(ORDER BY SubSectionName) + @LastSubSection
	 , s.ID AS [SectionID]
	 , SubSectionName
FROM tbl_PBU_Tree t
INNER JOIN @PriceBooks p
ON t.BookName = p.BookName AND t.CompanyCodeID = p.FranchiseID
INNER JOIN @Sections s
ON t.SectionName = s.SectionName
GROUP BY s.ID, SubSectionName

INSERT INTO @Jobs
SELECT ROW_NUMBER() OVER(ORDER BY JobCode) + @LastJob
	 , t.TreeID AS [TreeID]
	 , ss.ID AS [SubSectionID]
	 , JobCode
	 , JobCodeDescription
	 , JobCost
	 , JobStdPrice
	 , JobMemberPrice
	 , JobAddonStdPrice
	 , JobAddonMemberPrice
	 , ResAccountCode
	 , ComAccountCode
FROM tbl_PBU_Tree t
INNER JOIN @PriceBooks p
ON t.BookName = p.BookName AND t.CompanyCodeID = p.FranchiseID
INNER JOIN @SubSections ss
ON t.SubSectionName = ss.SubSectionName;

INSERT INTO @MasterParts
SELECT ROW_NUMBER() OVER (ORDER BY p.PartCodeID) + @LastMasterPart AS [MasterPartID]
				, 1 AS [ConceptID]
				, pb.FranchiseID
				, p.PartCode
				, p.PartCodeID
				, MIN(p.PartCost)
				, p.PartName
				, p.VendorPartID
FROM tbl_PBU_Det_NewParts_ManualPrices p
INNER JOIN tbl_PBU_Tree t ON p.TreeID = t.TreeID
INNER JOIN @PriceBooks pb ON t.BookName = pb.BookName AND t.CompanyCodeID = pb.FranchiseID
GROUP BY pb.FranchiseID, p.PartCode, p.PartCodeID, p.PartName, p.VendorPartID

;WITH [allPriceBookParts] AS
(
	SELECT t.JobCode, p.MasterPartID, p.Qty, p.PartStdPrice, p.PartMemberPrice, p.PartAddonPrice, p.PartAddonMemberPrice
	FROM tbl_PBU_Det_MasterParts_ManualPrices p
	INNER JOIN tbl_PBU_Tree t
	ON p.TreeID = t.TreeID
	UNION ALL
	SELECT t.JobCode, mp.MasterPartID, p.Qty, p.PartStdPrice, p.PartMemberPrice, p.PartAddonPrice, p.PartAddonMemberPrice
	FROM tbl_PBU_Det_NewParts_ManualPrices p
	INNER JOIN tbl_PBU_Tree t
	ON p.TreeID = t.TreeID
	INNER JOIN @MasterParts mp
	ON p.PartCode = mp.PartCode 
		AND p.PartCodeID = mp.PartCodeID 
		AND p.VendorPartID = mp.VendorPartID 
		AND p.PartCost = mp.PartCost 
		AND p.PartName = mp.PartName
)
, [allMasterParts] AS
(
	SELECT MasterPartID, FranchiseID, PartCost FROM tbl_PB_MasterParts
	UNION ALL
	SELECT MasterPartID, FranchiseID, PartCost FROM @MasterParts
)

INSERT INTO @PriceBookParts(ID, Markup, MasterPartID, PartAddonMemberPrice, PartAddonStdPrice, PartCost, PartMemberPrice, PartStdPrice, PriceBookID)
SELECT ROW_NUMBER() OVER (ORDER BY MIN(p.JobCode)) + @LastPart AS [PartID]
	, MIN(mu.Markup) AS [Markup]
	, p.MasterPartID
	, MIN(ISNULL(p.PartAddonMemberPrice, mp.PartCost * p.Qty * mu.Markup * (100-pb.MemberPricePercent)/100)) AS PartAddonMemberPrice
	, MIN(ISNULL(p.PartAddonPrice, mp.PartCost * p.Qty * mu.Markup)) AS PartAddonPrice
	, MIN(mp.PartCost) AS PartCost
	, MIN(ISNULL(p.PartMemberPrice, mp.PartCost * p.Qty * mu.Markup * (100-pb.MemberPricePercent)/100)) AS PartMemberPrice
	, MIN(ISNULL(p.PartStdPrice, mp.PartCost * p.Qty * mu.Markup)) AS PartStdPrice
	, pb.PriceBookID
FROM [allPriceBookParts] p
INNER JOIN [allMasterParts] mp
ON mp.MasterPartID = p.MasterPartID
INNER JOIN @PriceBooks pb
ON mp.FranchiseID = pb.FranchiseID
INNER JOIN tbl_PB_Markup mu
ON mp.PartCost >= mu.Lowerbound AND mp.PartCost <= mu.Upperbound
GROUP BY pb.PriceBookID, p.MasterPartID, mp.PartCost

;WITH [allTaskDetails] AS
(
	SELECT t.JobCode, t.Treeid, t.JobCodeDescription, MasterPartID, Qty, PartStdPrice, PartMemberPrice, PartAddonPrice, PartAddonMemberPrice
	FROM tbl_PBU_Det_MasterParts_ManualPrices p
	INNER JOIN tbl_PBU_Tree t
	ON p.TreeID = t.TreeID
	UNION ALL
	SELECT t.JobCode, t.treeid, t.JobCodeDescription, mp.MasterPartID, p.Qty, p.PartStdPrice, p.PartMemberPrice, p.PartAddonPrice, p.PartAddonMemberPrice
	FROM tbl_PBU_Det_NewParts_ManualPrices p
	INNER JOIN tbl_PBU_Tree t
	ON p.TreeID = t.TreeID
	INNER JOIN @MasterParts mp
	ON p.PartCode = mp.PartCode 
		AND p.PartCodeID = mp.PartCodeID 
		AND p.VendorPartID = mp.VendorPartID 
		AND p.PartCost = mp.PartCost 
		AND p.PartName = mp.PartName
)

INSERT INTO @TaskDetails(ID, JobCodeID, PartID, Qty, PartCost, PartStdPrice, PartMemberPrice, PartAddonStdPrice, PartAddonMemberPrice)
SELECT ROW_NUMBER() OVER(ORDER BY atd.JobCode) + @LastTaskDetail
	 , j.ID as [JobCodeID]
	 , p.ID AS [PartID]
	 , atd.Qty AS [Qty]
	 , p.PartCost
	 , ISNULL(atd.PartStdPrice, p.PartStdPrice)
	 , ISNULL(atd.PartMemberPrice, p.PartMemberPrice)
	 , ISNULL(atd.PartAddonPrice, p.PartAddonStdPrice)
	 , ISNULL(atd.PartAddonMemberPrice, p.PartAddonMemberPrice)
FROM [allTaskDetails] atd
INNER JOIN @Jobs j
ON j.JobCode = atd.JobCode and j.JobCodeDescription = atd.JobCodeDescription
INNER JOIN tbl_PBU_Tree t
ON j.TreeID = t.TreeID and atd.TreeID = t.TreeID
INNER JOIN @PriceBooks pb 
ON t.BookName = pb.BookName AND t.CompanyCodeID = pb.FranchiseID
INNER JOIN @PriceBookParts p
ON p.MasterPartID = atd.MasterPartID

----Check for duplicate parts on a task.
--SELECT JobCodeID, PartID, COUNT(1) FROM @TaskDetails
--group by JobCodeID, PartID
--having COUNT(1) > 1

--select * from @Jobs
--where ID in (258545, 258552)

SET IDENTITY_INSERT tbl_PriceBook ON
INSERT INTO tbl_PriceBook(ActiveBookYN, BookComments, BookName, ConceptID, EffectiveDate, FranchiseID, MemberPricePercent, PriceBookID)
SELECT ActiveBookYN, BookComments, BookName, ConceptID, EffectiveDate, FranchiseID, MemberPricePercent, PriceBookID
FROM @PriceBooks
SET IDENTITY_INSERT tbl_PriceBook OFF

SET IDENTITY_INSERT tbl_PB_Section ON
INSERT INTO tbl_PB_Section(ActiveYN, MFlag, PriceBookID, SectionID, SectionName)
SELECT 1, 0, PriceBookID, ID, SectionName
FROM @Sections
SET IDENTITY_INSERT tbl_PB_Section OFF

SET IDENTITY_INSERT tbl_PB_SubSection ON
INSERT INTO tbl_PB_SubSection(ActiveYN, MFlag, SectionID, SubSectionName, SubsectionID)
SELECT 1, 0, SectionID, SubSectionName, ID
FROM @SubSections
SET IDENTITY_INSERT tbl_PB_SubSection OFF

SET IDENTITY_INSERT tbl_PB_JobCodes ON
INSERT INTO tbl_PB_JobCodes( ActiveYN, ComAccountCode, JobAddonMemberPrice, JobAddonStdPrice, JobCode, JobCodeDescription, JobCodeID, JobCost, JobMemberPrice, JobStdPrice, MFlag, ManualPricingYN, ResAccountCode, SubSectionID)
SELECT 1, j.ComAccountCode, j.JobAddonMemberPrice, j.JobAddonStdPrice, j.JobCode, j.JobCodeDescription, j.ID, j.JobCost, j.JobMembePrice, j.JobStdPrice, 0, 0, j.ResAccountCode, j.SubSectionID
FROM @Jobs j
SET IDENTITY_INSERT tbl_PB_JobCodes OFF

SET IDENTITY_INSERT tbl_PB_MasterParts ON
INSERT INTO tbl_PB_MasterParts(ActiveYN, ConceptID, FranchiseID, MasterPartID, PartCode, PartCodeID, PartCost, PartName, VendorPartID)
SELECT 1, 1, m.FranchiseID, m.MasterPartID, m.PartCode, m.PartCodeID, m.PartCost, m.PartName, m.VendorPartID
FROM @MasterParts m
SET IDENTITY_INSERT tbl_PB_MasterParts OFF

SET IDENTITY_INSERT tbl_PB_Parts ON
INSERT INTO tbl_PB_Parts(Markup, MasterPartID, PartAddonMemberPrice, PartAddonStdPrice, PartCost, PartID, PartMemberPrice, PartStdPrice, PriceBookID)
SELECT Markup, MasterPartID, PartAddonMemberPrice, PartAddonStdPrice, PartCost, ID, PartMemberPrice, PartStdPrice, PriceBookID FROM
@PriceBookParts
SET IDENTITY_INSERT tbl_PB_Parts OFF

select td.PartID,td.JobCodeID, MIN(jc.JobCode), MAX(jc.JobCode), COUNT(1) from @TaskDetails td
inner join tbl_pb_jobcodes jc
on td.jobcodeid = jc.jobcodeid
inner join tbl_pb_parts p
on p.PartID = td.PartID
inner join tbl_PB_MasterParts mp
on p.MasterPartID = mp.MasterPartID
group by td.PartID,td.JobCodeID
HAVING COUNT(1) > 1

SET IDENTITY_INSERT tbl_PB_JobCodes_Details ON
INSERT INTO tbl_PB_JobCodes_Details(JobCodeDetailsID, JobCodeID, ManualPricingYN, PartAddonMemberPrice, PartAddonStdPrice, PartCost, PartID, PartMemberPrice, PartStdPrice, Qty)
SELECT ID, JobCodeID, 0, PartAddonMemberPrice, PartAddonStdPrice, PartCost, PartID, PartMemberPrice, PartStdPrice, Qty
FROM @TaskDetails
SET IDENTITY_INSERT tbl_PB_JobCodes_Details OFF

-- insert standard extra part for pricebook adjustments
INSERT INTO [tbl_PB_Parts]
           ([PriceBookID]
           ,[MasterPartID]
           ,[PartCost]
           ,[PartStdPrice]
           ,[PartMemberPrice]
           ,[PartAddonStdPrice]
           ,[PartAddonMemberPrice]
           ,[Markup])
     VALUES
           ( @LastPriceBook + 1
           , 5350
           , 0
           , 0
           , 0
           , 0
           , 0
           , 0)


--;WITH [DefaultPricing] AS
--(
	
--)

--select * From @PriceBooks
--select * From @Sections
--select * From @SubSections
--select * From @Jobs
--select * from @MasterParts
--select * from @PriceBookParts
--select * From @TaskDetails

COMMIT TRAN

END
GO
