USE [EightHundred]
GO
/****** Object:  StoredProcedure [dbo].[GetXMLByPriceBook]    Script Date: 03/30/2012 13:12:27 ******/
DROP PROCEDURE [dbo].[GetXMLByPriceBook]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--GetXMLByPriceBook 43, 'c:\Tejas'
CREATE PROC [dbo].[GetXMLByPriceBook]
	@PriceBookID INT,
	@Folder VARCHAR(2000)
AS
BEGIN
	DECLARE @Sections TABLE(AutoID INT IDENTITY, SectionID INT, SectionName VARCHAR(500))
	DECLARE @SectionID INT, @SectionName VARCHAR(500)
	DECLARE @FranchiseID INT
	DECLARE @XML VARCHAR(MAX), 
			@Contents VARCHAR(MAX),
			@Franchise VARCHAR(MAX),
			@Parts VARCHAR(MAX),
			@Messages VARCHAR(MAX),
			@Options VARCHAR(MAX),
			@DispatchMessage VARCHAR(MAX),
			@Taxes VARCHAR(MAX)
			
	DECLARE @li  INT;
	DECLARE @lv  VARCHAR(MAX);			
	DECLARE @FileName Varchar(MAX);
	
	SELECT	@FranchiseID = p.FranchiseID
	FROM	tbl_PriceBook p (NOLOCK)
	WHERE	p.PriceBookID = @PriceBookID
	
	--Create Franchise XML
	SELECT	@FileName = 'tbl_Franchise.xml',
			@Franchise = 
		(SELECT	FranchiseID,
				eighthundred.dbo.XmlEncode(ShipAddress) AS [Address],
				eighthundred.dbo.XmlEncode(ShipCity) AS City,
				eighthundred.dbo.XmlEncode(ShipState) As [State],
				eighthundred.dbo.XmlEncode(ShipPostal) AS PostalCode,
				eighthundred.dbo.XmlEncode(fc.CountryCode) As Country,
				eighthundred.dbo.XmlEncode(f.LegalName) As LocationName,
				eighthundred.dbo.XmlEncode(f.ShipCompany) AS LocationCompany,
				'' AS PrimaryPhone
		FROM tbl_Franchise f
		INNER JOIN tbl_Franchise_Country fc ON fc.CountryID = f.ShipCountryID
		where FranchiseID=@FranchiseID
		FOR XML PATH('Table'), ROOT('NewDataSet')
	)
	
	EXEC dbo.WriteStringToFile 
		@pv_path        = @Folder,
		@pv_filename    = @FileName,
		@pv_data        = @Franchise,
		@pi_result_code = @li OUTPUT,
		@pv_result_msg  = @lv OUTPUT;
		
	SELECT @Contents = '<contents>' + '<file>' + @FileName + '</file>'
	
	--Create Parts XML
	SELECT	@FileName = 'tbl_PriceBook_Parts.xml',
			@Parts = (SELECT	FranchiseID,
								(SELECT pc.PartCode AS [PartSection],
										(SELECT DISTINCT
										RTRIM(mp.PartCode) AS [PartCode],
										REPLACE(REPLACE(mp.PartName,',','-'),'&','and') AS [PartName],
										p.PartID AS [PartID],
										CONVERT(VARCHAR, p.PartMemberPrice, 1) AS [PartMemberPrice],
										CONVERT(VARCHAR, p.PartStdPrice, 1) AS [PartStdPrice],
										CONVERT(VARCHAR, p.PartAddonMemberPrice, 1) AS [PartAddonMemberPrice],
										CONVERT(VARCHAR, p.PartAddonStdPrice, 1) AS [PartAddonStdPrice],
										CONVERT(VARCHAR, p.PartCost, 1) AS [PartCost]
										FROM tbl_PB_Parts p
										INNER JOIN tbl_PB_MasterParts mp
										ON p.MasterPartID = mp.MasterPartID
										WHERE PriceBookID = @PriceBookID AND pc.PartCodeID = mp.PartCodeID
										ORDER BY PartID
										FOR XML PATH('Part'), TYPE)
								FROM tbl_PB_Parts_Codes pc
								INNER JOIN tbl_PB_MasterParts mp
								ON mp.PartCodeID = pc.PartCodeID
								INNER JOIN tbl_PB_Parts p
								ON mp.MasterPartID = p.MasterPartID
								WHERE p.PriceBookID = @PriceBookID AND pc.ActiveYN = 1
								GROUP BY pc.PartCode, pc.PartCodeID
								ORDER BY pc.PartCode
								FOR XML PATH('PartSection'), TYPE)
					FROM tbl_Franchise 
					WHERE FranchiseID = @FranchiseID
					FOR XML PATH(''), ROOT('PriceBookParts')
					)
	
	EXEC dbo.WriteStringToFile 
		@pv_path        = @Folder,
		@pv_filename    = @FileName,
		@pv_data        = @Parts,
		@pi_result_code = @li OUTPUT,
		@pv_result_msg  = @lv OUTPUT;
		
	SELECT @Contents = @Contents + '<file>' + @FileName + '</file>'
	
	--Create Messages XML
	SELECT	@FileName = 'tbl_Messages.xml',
			@Messages = CONVERT(VARCHAR(MAX), (SELECT FranchiseID AS [FranchiseID],
							   (
								SELECT	eighthundred.dbo.XmlEncode(DispatchMessage) AS [Message]
								FROM tbl_Dispatch_Messages	
								WHERE ActiveYN = 1
								ORDER BY DispatchMessage
								FOR XML PATH(''), ROOT('MessageSection'), TYPE
								)
						 FROM tbl_Franchise
						 WHERE FranchiseID = @FranchiseID
					     FOR XML PATH('Messages'), TYPE
						 ))
	
	EXEC dbo.WriteStringToFile 
		@pv_path        = @Folder,
		@pv_filename    = @FileName,
		@pv_data        = @Messages,
		@pi_result_code = @li OUTPUT,
		@pv_result_msg  = @lv OUTPUT;
		
	SELECT @Contents = @Contents + '<file>' + @FileName + '</file>'
	
	
	/* tbl_options.xml */
	SELECT	@FileName = 'tbl_Options.xml',
			@Options = '<Options>
							<ShowAllJobs>True</ShowAllJobs>
							<EnableIMsg>True</EnableIMsg>
						</Options>'
	
	EXEC dbo.WriteStringToFile 
		@pv_path        = @Folder,
		@pv_filename    = @FileName,
		@pv_data        = @Options,
		@pi_result_code = @li OUTPUT,
		@pv_result_msg  = @lv OUTPUT;
	
	SELECT @Contents = @Contents + '<file>' + @FileName + '</file>'
	
	/* tbl_DispatchMessage.xml */
	SELECT	@FileName = 'tbl_DispatchMessage.xml',
			@DispatchMessage = '<tbl_JobStatus>
									<FranchiseID>'+ CAST(@FranchiseID AS VARCHAR(10)) +'</FranchiseID>
									<LocationID>1</LocationID>
									<Status>Active</Status>
									<SequenceID>1</SequenceID>
									<JobType />
									<JobDescription />
									<EstimateYN>No</EstimateYN>
									<Message />
								</tbl_JobStatus>'
	
	EXEC dbo.WriteStringToFile 
		@pv_path        = @Folder,
		@pv_filename    = @FileName,
		@pv_data        = @DispatchMessage,
		@pi_result_code = @li OUTPUT,
		@pv_result_msg  = @lv OUTPUT;
	
	SELECT @Contents = @Contents + '<file>' + @FileName + '</file>'
	
	SELECT  @FileName = 'tbl_Taxes.xml',
			@Taxes = (
					SELECT	FranchiseID,
							(
								SELECT  eighthundred.dbo.XmlEncode(r1.TaxDescription) AS [TaxName],
										CAST(r1.LaborAmount AS NUMERIC(18,4)) AS 'TaxRate'
								FROM	tbl_TaxRates r1
								WHERE	r.FranchiseId = r1.FranchiseId
								FOR XML PATH('Tax'), ROOT('TaxSection'), TYPE
							)
					from tbl_TaxRates r
					where FranchiseID=@FranchiseID
					GROUP BY FranchiseID
					FOR XML PATH(''), ROOT('Taxes')
					)

	EXEC dbo.WriteStringToFile 
		@pv_path        = @Folder,
		@pv_filename    = @FileName,
		@pv_data        = @Taxes,
		@pi_result_code = @li OUTPUT,
		@pv_result_msg  = @lv OUTPUT;
	
	SELECT @Contents = @Contents + '<file>' + @FileName + '</file>'
	
	INSERT INTO @Sections(SectionID, SectionName)
	SELECT s.sectionID, REPLACE(REPLACE(s.SectionName,' ','_'),'/','-')
	FROM tbl_PB_Section s 
	WHERE s.PriceBookID = @PriceBookID
	AND s.ActiveYN = 1
	ORDER BY s.SectionName
	
	DECLARE @inc INT, @cnt INT
	SELECT	@inc = 1,
			@cnt = COUNT(*) FROM @Sections
			
	WHILE @inc <= @cnt BEGIN
		SELECT @XML = NULL 
		
		SELECT	@SectionID = SectionID,
				@SectionName = SectionName
		FROM	@Sections
		WHERE	AutoID =@inc
		
		EXEC GetXMLByPriceBookBySection
				@PriceBookID = @PriceBookID, 
				@SectionID = @SectionID,
				@XML = @XML OUT
         
         -- Code To Write XML to File Starts				
		 -- Declare variables
		
			SET @FileName = 'tbl_PriceBook_'+ REPLACE(REPLACE(@SectionName,'&','and'),',','-') + '.xml'
			
			SELECT @Contents = @Contents + '<file>' + REPLACE(@FileName,'&','and') + '</file>'
			
			-- Call routine to
			EXEC dbo.WriteStringToFile @pv_path        = @Folder,
									   @pv_filename    = @FileName,
									   @pv_data        = @XML,
									   @pi_result_code = @li OUTPUT,
									   @pv_result_msg  = @lv OUTPUT;

			--SELECT @li, @lv;
            -- Code To Write XML to File Ends	
		
		--SELECT @SectionName, @XML, DATALENGTH(@XML)
		
		SET @inc = @inc + 1
	END
	
	SELECT @FileName = 'contents.xml'
	SELECT @Contents = @Contents + '</contents>'
	
	EXEC dbo.WriteStringToFile 
		@pv_path        = @Folder,
		@pv_filename    = @FileName,
		@pv_data        = @Contents,
		@pi_result_code = @li OUTPUT,
		@pv_result_msg  = @lv OUTPUT;
	
	DECLARE @tablet VARCHAR(20)
	SET @tablet = REPLACE(@Folder, 'c:\800FTPSite\SentToiPadInit\', '')
	
	UPDATE eighthundred.dbo.tbl_franchise_tablets
	SET PriceBookID = @PriceBookID
	WHERE TabletNumber = @tablet
	
END
GO
