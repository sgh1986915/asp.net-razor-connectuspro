USE [EightHundred]
GO
/****** Object:  StoredProcedure [dbo].[GetXMLByLocation]    Script Date: 03/30/2012 13:12:27 ******/
DROP PROCEDURE [dbo].[GetXMLByLocation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--GetXMLByLocation @LocationID=271, @Folder='C:\Tejas'
CREATE PROC [dbo].[GetXMLByLocation]
	@LocationID INT,
	@Folder VARCHAR(2000)
AS
BEGIN
	DECLARE @XML VARCHAR(MAX), 
			@DispatchMessage VARCHAR(MAX),
			@Contents VARCHAR(MAX),
			@HomeGuard VARCHAR(MAX),
			@Diagnostics VARCHAR(MAX),
			@JobRecommendations VARCHAR(MAX),
			@JobPayments VARCHAR(MAX),
			@JobStatus VARCHAR(MAX),
			@JobTasks VARCHAR(MAX),
			@Locations VARCHAR(MAX)
			
	DECLARE @li  INT;
	DECLARE @lv  VARCHAR(MAX);			
	DECLARE @FileName Varchar(MAX);
	
	--Create tbl_HomeGuard_Results.xml
	SELECT	@FileName = 'tbl_HomeGuard_Results.xml',
			@HomeGuard = 
				(	
					SELECT	r.FranchiseID,
							r.LocationID,
							(
								SELECT	dbo.XmlEncode(h.HGSection) AS HomeGuardSection
										,(
											SELECT	dbo.XmlEncode(h1.PBSection) AS PBSection,
													dbo.XmlEncode(h1.PBSubsection) AS PBSubsection,
													dbo.XmlEncode(h1.HGTestItem) AS HGTestItem,
													r1.Result
											FROM	tbl_HomeGuard h1 
											INNER JOIN tbl_HomeGuard_Results r1  ON r1.HomeGuardID = h1.HomeGuardID
											WHERE r1.locationid= @LocationID
											AND h1.HGSection = h.HGSection
											ORDER BY h1.PBSection,
													h1.PBSubsection,
													h1.HGTestItem
											FOR XML PATH('Item'), TYPE
										)
								FROM	tbl_HomeGuard h 
								INNER JOIN tbl_HomeGuard_Results r  ON r.HomeGuardID = h.HomeGuardID
								WHERE r.locationid= @LocationID
								GROUP BY h.HGSection
								ORDER BY h.HGSection
								FOR XML PATH(''), ROOT('Section'), TYPE
							)
					FROM tbl_HomeGuard_Results r 
					WHERE r.locationid= @LocationID
					GROUP BY 
						r.FranchiseID, 
						r.LocationID	
					ORDER BY 1
					FOR XML PATH(''), ROOT('HomeGuardResults')
				)
	
	EXEC dbo.WriteStringToFile 
		@pv_path        = @Folder,
		@pv_filename    = @FileName,
		@pv_data        = @HomeGuard,
		@pi_result_code = @li OUTPUT,
		@pv_result_msg  = @lv OUTPUT;
		
	SELECT @Contents = '<contents>' + '<file>' + @FileName + '</file>'
	
	/* tbl_Job_Diagnostics.xml */
	SELECT	@FileName = 'tbl_Job_Diagnostics.xml',
			@Diagnostics = (
				SELECT  DISTINCT j.FranchiseID,
						j.LocationID,
						ISNULL(CAST(j.Diagnostics AS VARCHAR(MAX)),'') AS Diagnostics
				FROM	tbl_Job j (NOLOCK)
				WHERE	j.LocationID = @LocationID
				--AND NULLIF(CAST(j.Diagnostics AS Varchar(max)),'') IS NOT NULL
				FOR XML PATH(''), ROOT('Job_Diagnostics')
			)
	
	EXEC dbo.WriteStringToFile 
		@pv_path        = @Folder,
		@pv_filename    = @FileName,
		@pv_data        = @Diagnostics,
		@pi_result_code = @li OUTPUT,
		@pv_result_msg  = @lv OUTPUT;
	
	SELECT @Contents = @Contents + '<file>' + @FileName + '</file>'
	
	/* tbl_Job_Recommendations.xml */
	SELECT  @FileName = 'tbl_Job_Recommendations.xml',
			@JobRecommendations = (
					SELECT  DISTINCT j.FranchiseID,
							j.LocationID,
							ISNULL(CAST(j.Recommendations AS Varchar(max)),'') AS Recommendations
					FROM	tbl_Job j (NOLOCK)
					WHERE	j.LocationID = @LocationID
					--AND NULLIF(CAST(j.Recommendations AS Varchar(max)),'') IS NOT NULL
					FOR XML PATH(''), ROOT('Job_Recommendations')
					)

	EXEC dbo.WriteStringToFile 
		@pv_path        = @Folder,
		@pv_filename    = @FileName,
		@pv_data        = @JobRecommendations,
		@pi_result_code = @li OUTPUT,
		@pv_result_msg  = @lv OUTPUT;
	
	SELECT @Contents = @Contents + '<file>' + @FileName + '</file>'
	
	/* tbl_Job_Payments.xml */
	SELECT  @FileName = 'tbl_Job_Payments.xml',
			@JobPayments = CAST(
				(
				SELECT	job.FranchiseID,
						job.LocationID,
						'' AS Warranty,
						(
							CASE 
								WHEN NOT EXISTS(
										SELECT p.JobID
										from tbl_Payments p (NOLOCK)
										INNER JOIN tbl_job j (NOLOCK) ON p.JobID = j.JobID
										WHERE j.LocationID= @LocationID
								) THEN 
									'<tbl_JobPayments>
										<FranchiseID>20</FranchiseID>
										<LocationID>60186</LocationID>
										<Warranty />
										<Payments>
											<Item>
												<PayType />
												<PayAmount />
												<PayAuth />
												<LockedYN />
											</Item>
											<Item>
												<PayType />
												<PayAmount />
												<PayAuth />
												<LockedYN />
											</Item>
										</Payments>
									</tbl_JobPayments>'
								WHEN	(
										SELECT COUNT(DISTINCT p.PaymentID)
										from tbl_Payments p (NOLOCK)
										INNER JOIN tbl_job j (NOLOCK) ON p.JobID = j.JobID
										WHERE j.LocationID= @LocationID
										) = 1 
									THEN 	
										(
											SELECT	PayType,
													PayAmount,
													PayAuth,
													LockedYN
											FROM	
												(
												SELECT	CAST(p.PaymentTypeID AS VARCHAR(MAX)) AS PayType,
														CAST(p.PaymentAmount AS VARCHAR(MAX)) AS PayAmount,
														'' AS PayAuth,
														'' AS LockedYN
												FROM	tbl_Payments p
												INNER JOIN tbl_job j (NOLOCK) ON p.JobID = j.JobID
												WHERE	j.LocationID = job.LocationID
												UNION ALL
												SELECT	'' AS PayType,
														'' AS PayAmount,
														'' AS PayAuth,
														'' AS LockedYN
												) x
											FOR XML PATH('Item'), ROOT('Payments'), TYPE
										)
							ELSE 
								(
									SELECT	p.PaymentTypeID AS PayType,
											p.PaymentAmount AS PayAmount,
											'' AS PayAuth,
											'' AS LockedYN
									FROM	tbl_Payments p
									INNER JOIN tbl_job j (NOLOCK) ON p.JobID = j.JobID
									WHERE	j.LocationID = job.LocationID
									FOR XML PATH('Item'), ROOT('Payments'), TYPE
								)			
							END			
					)
				FROM tbl_job job 
				WHERE job.LocationID = @LocationID
				GROUP BY job.LocationID, job.FranchiseID
				FOR XML PATH(''), ROOT('tbl_JobPayments'), TYPE
			) AS VARCHAR(MAX))
	
	EXEC dbo.WriteStringToFile 
		@pv_path        = @Folder,
		@pv_filename    = @FileName,
		@pv_data        = @JobPayments,
		@pi_result_code = @li OUTPUT,
		@pv_result_msg  = @lv OUTPUT;
	
	SELECT @Contents = @Contents + '<file>' + @FileName + '</file>'
	
	/* tbl_JobStatus.xml */
	SELECT  @FileName = 'tbl_JobStatus.xml',
			@JobStatus = CAST(
				(SELECT	j.FranchiseID,
					j.LocationID,
					js.Status,
					ROW_NUMBER()OVER(ORDER BY j.JobID) AS SequenceID, 
					jt.JobType,
					j.CallReason AS JobDescription,
					'No' As EstimateYN,
					'' AS [Message]
			FROM tbl_Job j
			INNER JOIN tbl_Job_Type jt ON j.JobTypeID = jt.JobTypeID
			INNER JOIN tbl_Job_Status js ON js.StatusID = j.StatusID
			WHERE LocationID=@LocationID
			FOR XML PATH('tbl_JobStatus'), ROOT('Root')
				)
			 AS VARCHAR(MAX))
	
	EXEC dbo.WriteStringToFile 
		@pv_path        = @Folder,
		@pv_filename    = @FileName,
		@pv_data        = @JobStatus,
		@pi_result_code = @li OUTPUT,
		@pv_result_msg  = @lv OUTPUT;
	
	SELECT @Contents = @Contents + '<file>' + @FileName + '</file>'
	
	
	--INSERT INTO @Sections(SectionID, SectionName)
	--SELECT s.sectionID, REPLACE(s.SectionName,' ','_')
	--FROM tbl_PB_Section s 
	--WHERE s.PriceBookID = @PriceBookID
	--AND s.ActiveYN = 1
	--ORDER BY s.SectionName
	
	--DECLARE @inc INT, @cnt INT
	--SELECT	@inc = 1,
	--		@cnt = COUNT(*) FROM @Sections
			
	--WHILE @inc <= @cnt BEGIN
	--	SELECT @XML = NULL 
		
	--	SELECT	@SectionID = SectionID,
	--			@SectionName = SectionName
	--	FROM	@Sections
	--	WHERE	AutoID =@inc
		
	--	EXEC GetXMLByPriceBookBySection 
	--			@PriceBookID = @PriceBookID, 
	--			@SectionID = @SectionID,
	--			@XML = @XML OUT
         
 --        -- Code To Write XML to File Starts				
	--	 -- Declare variables
		
	--		SET @FileName = 'tbl_PriceBook_'+ REPLACE(@SectionName,'&','and') + '.XML'
			
	--		SELECT @Contents = @Contents + '<file>' + REPLACE(@FileName,'&','and') + '</file>'
			
	--		-- Call routine to
	--		EXEC dbo.WriteStringToFile @pv_path        = @Folder,
	--								   @pv_filename    = @FileName,
	--								   @pv_data        = @XML,
	--								   @pi_result_code = @li OUTPUT,
	--								   @pv_result_msg  = @lv OUTPUT;

	--		--SELECT @li, @lv;
 --           -- Code To Write XML to File Ends	
		
	--	--SELECT @SectionName, @XML, DATALENGTH(@XML)
		
	--	SET @inc = @inc + 1
	--END
	
	SELECT @FileName = 'contents.xml'
	SELECT @Contents = @Contents + '</contents>'
	
	EXEC dbo.WriteStringToFile 
		@pv_path        = @Folder,
		@pv_filename    = @FileName,
		@pv_data        = @Contents,
		@pi_result_code = @li OUTPUT,
		@pv_result_msg  = @lv OUTPUT;
		
END
GO
