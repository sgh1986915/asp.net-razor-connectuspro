USE [EightHundred]
GO

/****** Object:  StoredProcedure [dbo].[GetXMLByJob]    Script Date: 04/20/2012 12:16:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetXMLByJob]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[GetXMLByJob]
GO

USE [EightHundred]
GO

/****** Object:  StoredProcedure [dbo].[GetXMLByJob]    Script Date: 04/20/2012 12:16:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO














--GetXMLByJob_Tejas 16620, 'C:\Tejas'
CREATE PROC [dbo].[GetXMLByJob]
      @JobID INT,
      @Folder VARCHAR(2000)
AS
BEGIN

      DECLARE @isHVAC BIT
      DECLARE @canSend BIT
      SELECT @isHVAC = CASE 
                                    WHEN ServiceID = 10 THEN 1 
                                    ELSE 0 
                              END 
			, @canSend = CASE WHEN StatusID <> 6 AND StatusID <> 7 THEN 1 ELSE 0 END
      FROM tbl_Job 
      WHERE JobID = @JobID 

		IF @canSend = 0
		BEGIN
			RAISERROR('A job cannot be sent to tablet from a Closed or Completed status', 16, 1)
			RETURN
		END
	  	
	  	PRINT 'Still running...'

      IF @isHVAC = 0
      BEGIN
      
            DECLARE @cmd VARCHAR(2000),
                  @result INT
                  
                  SELECT @cmd = 'dir ' + @Folder

                  EXEC @result = master.dbo.xp_cmdshell @cmd, NO_OUTPUT
                  
                  IF @result <> 0
                  BEGIN
                        SELECT @cmd = 'mkdir ' + @Folder
                        EXEC master.dbo.xp_cmdshell @cmd, NO_OUTPUT
                  END
      
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
            
            DECLARE @PriceBookID INT

            SELECT @PriceBookID = t.PriceBookID 
            FROM tbl_Job j  
            INNER JOIN tbl_Franchise_Tablets t on j.ServiceProID = t.EmployeeID
            WHERE j.JobID = @JobID

            DECLARE @HasCustomHG BIT
            SET @HasCustomHG = 0
            IF EXISTS (SELECT 1 FROM tbl_HomeGuard h WHERE PriceBookID = @PriceBookID)
                  SET @HasCustomHG = 1;

            DECLARE @Path varchar(128) 
            SELECT      @Path = @Folder + '\', @FileName = 'contents.xml'

            DECLARE @objFSys int
            DECLARE @i int
            DECLARE @File varchar(1000)
            
            SELECT @File = @Path + @FileName
            EXEC sp_OACreate 'Scripting.FileSystemObject', @objFSys out
            EXEC sp_OAMethod @objFSys, 'FileExists', @i out, @File
            IF @I = 1 BEGIN
                  CREATE TABLE #tempfile (line VARCHAR(MAX))
                  EXEC ('bulk insert #tempfile from "' + @Path + '\' + @FileName + '"')
                  SELECT @Contents = Line FROM #tempfile
                  SELECT @Contents = REPLACE(@Contents,'</contents>','')
                  DROP TABLE #tempfile    
            END ELSE BEGIN
                  SELECT @Contents = '<contents>' 
                  SELECT @Contents = @Contents + '<file>' + @FileName + '</file>'
            END

      ;WITH [MergedHG] AS
      (
            SELECT hg.HomeGuardID, hg.HGSection, hg.PBSection, hg.PBSubSection, hg.HGTestITem, hg.PriceBookID
            FROM tbl_HomeGuard hg
            WHERE (@HasCustomHG = 0 AND hg.PriceBookID IS NULL) OR (@HasCustomHG = 1 AND hg.PriceBookID = @PriceBookID)
      )
      , [Results] AS
      (
            SELECT j.FranchiseID, j.LocationID, h.HGSection, h.HomeGuardID, h.PBSection, h.PBSubsection, h.HGTestItem, r.Result
            FROM tbl_HomeGuard_Results r 
            INNER JOIN [MergedHG] h ON r.HomeGuardID = h.HomeGuardID
            INNER JOIN tbl_Job j ON r.LocationID = j.LocationID
            WHERE j.JobID = @JobID
      )
            SELECT      @FileName = ltrim(str(@JobID) + '_tbl_HomeGuard_Results.xml'),
                        @HomeGuard = 
                              (     
                                    SELECT      j.FranchiseID,
                                                j.LocationID,
                                                (
                                                      SELECT      dbo.XmlEncode(h.HGSection) AS HomeGuardSection
                                                                  ,(
                                                                        SELECT      dbo.XmlEncode(h1.PBSection) AS PBSection,
                                                                                    dbo.XmlEncode(h1.PBSubsection) AS PBSubsection,
                                                                                    dbo.XmlEncode(h1.HGTestItem) AS HGTestItem,
                                                                                    dbo.XmlEncode(ISNULL(r2.Result, 2)) AS Result
                                                                        FROM  [MergedHG] h1
                                                                        LEFT JOIN [results] r2  ON r2.HomeGuardID = h1.HomeGuardID 
                                                                        WHERE h1.HGSection = h.HGSection
                                                                        ORDER BY h1.HGTestItem, 
                                                                                    h1.PBSection,
                                                                                    h1.PBSubsection
                                                                                    
                                                                        FOR XML PATH('Item'), TYPE
                                                                  )
                                                      FROM  MergedHG h
                                                      GROUP BY h.HGSection
                                                      ORDER BY MIN(h.HomeGuardId)
                                                      FOR XML PATH('Section'), TYPE
                                                )
                                    FROM tbl_Job j
                                    WHERE j.JobID = @JobID
                                    FOR XML PATH(''), ROOT('HomeGuardResults')
                              )
            
            SELECT @Contents = @Contents + '<file>' + @FileName + '</file>'
            
            EXEC dbo.WriteStringToFile 
                  @pv_path        = @Folder,
                  @pv_filename    = @FileName,
                  @pv_data        = @HomeGuard,
                  @pi_result_code = @li OUTPUT,
                  @pv_result_msg  = @lv OUTPUT;
            
            
            
                  
            
            
            /* tbl_Job_Diagnostics.xml */
            SELECT      @FileName = ltrim(str(@JobID) + '_tbl_Job_Diagnostics.xml'),
                        @Diagnostics = (
                              SELECT  DISTINCT j.FranchiseID,
                                          j.LocationID,
                                          ISNULL(CAST(j.Diagnostics AS VARCHAR(MAX)),'') AS Diagnostics
                              FROM  tbl_Job j (NOLOCK)
                              WHERE j.JobID = @JobID
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
            
            ;WITH [Members] AS
            (
				SELECT  CustomerID, max(cast(EndDate as varchar(12))) as Enddate  FROM tbl_Customer_Members group by CustomerID 
            )
            
            /* tbl_Locations.xml */
            SELECT  @FileName = ltrim(str(@JobID) + '_tbl_Locations.xml'),
                        @Locations = (SELECT    j.LocationID, 
                                                            j.CustomerID AS [BilltoCustomerID], 
                                                            l.Address, 
                                                            l.City, 
                                                            l.State, 
                                                            l.PostalCode, 
                                                            l.Country, 
                                                            CASE WHEN l.LocationName IS NULL OR LEN(LTRIM(l.LocationName)) = 0 THEN l.LocationCompany ELSE l.LocationName END AS [LocationName], 
                                                            l.LocationCompany, 
                                                            'Invoice Number: ' + cast(j.jobid as varchar(12))  as [LocationNotes], 
                                                            PrimaryPhone = Case ISNULL(CAST(M.CustomerID AS Varchar(max)),'False') when 'False' then 'Non Member' else  'Member - Expiration: ' + cast(Coalesce( m.enddate, 'Unknown') AS varchar(12))     END  ,
                                                            MemberYN =   Case ISNULL(CAST(M.CustomerID AS Varchar(max)),'False') when 'False' then 'False' else 'True' END,
                                                            ISNULL(c.EMail, ' ') as EMail, 
                                                            CASE WHEN f.FranchiseTypeID = 6 THEN f.MailCompany ELSE ISNULL(d.DBAName, ' ') END AS DBA,
                                                            COALESCE(f.MailAddress, ' ') as DBAAddress,
                                                            COALESCE(f.MailCity, ' ') + ', ' + COALESCE(f.MailState, ' ') + ' ' + COALESCE(f.MailPostal, ' ') as DBACityStZip,
                                                            CASE WHEN d.DBAID IS NOT NULL THEN 'http://69.24.66.83/fileutils/dbaimages/' + CONVERT(VARCHAR, d.DBAID, 1) + '_dbaimage.jpg' ELSE ' ' END as DBAURL
                                          FROM         tbl_Locations AS l 
                                          INNER JOIN tbl_Job AS j ON l.LocationID = j.LocationID
                                          INNER JOIN tbl_Franchise f ON f.FranchiseID = j.FranchiseID
                                          LEFT OUTER JOIN   [Members] M ON l.ActvieCustomerID = M.CustomerID
                                          LEFT JOIN tbl_Customer c on c.CustomerID = l.ActvieCustomerID
                                          LEFT JOIN tbl_Dispatch_DBA d on d.DBAID = j.AreaID
                                          WHERE     (j.JobID = @JobID)
                                          FOR XML PATH('Table'), ROOT('NewDataSet')
            )

            EXEC dbo.WriteStringToFile 
                  @pv_path        = @Folder,
                  @pv_filename    = @FileName,
                  @pv_data        = @Locations,
                  @pi_result_code = @li OUTPUT,
                  @pv_result_msg  = @lv OUTPUT;
            
            SELECT @Contents = @Contents + '<file>' + @FileName + '</file>'
                  
            /* tbl_Job_Recommendations.xml */
            SELECT  @FileName = ltrim(str(@JobID) + '_tbl_Job_Recommendations.xml'),
                        @JobRecommendations = (
                                    SELECT  DISTINCT j.FranchiseID,
                                                j.LocationID,
                                                ISNULL(CAST(j.Recommendations AS Varchar(max)),'') AS Recommendations
                                    FROM  tbl_Job j (NOLOCK)
                                    WHERE j.JobID = @JobID
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
            SELECT  @FileName = ltrim(str(@JobID) + '_tbl_JobPayments.xml'),
                        @JobPayments = CAST(
                              (
                              SELECT      job.FranchiseID,
                                          job.LocationID,
                                          '' AS Warranty,
                                          (
                                                CASE 
                                                      WHEN NOT EXISTS(
                                                                  SELECT p.JobID
                                                                  from tbl_Payments p (NOLOCK)
                                                                  WHERE p.JobID = job.JobID
                                                      ) THEN 
                                                            '<Payments>
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
                                                            '
                                                      WHEN  (
                                                                  SELECT COUNT(DISTINCT p.PaymentID)
                                                                  from tbl_Payments p (NOLOCK)
                                                                  WHERE p.JobID = job.JobID
                                                                  ) = 1 
                                                            THEN 
                                                                  (
                                                                        SELECT      PayType,
                                                                                    PayAmount,
                                                                                    PayAuth,
                                                                                    LockedYN
                                                                        FROM  
                                                                              (
                                                                              SELECT      CAST(ISNULL(pt.PaymentType,'UNKNOWN') AS VARCHAR(MAX)) AS PayType,
                                                                                          CAST(p.PaymentAmount AS VARCHAR(MAX)) AS PayAmount,
                                                                                          '' AS PayAuth,
                                                                                          'True' AS LockedYN
                                                                              FROM      tbl_Payments p
                                                                              LEFT JOIN tbl_Payment_Types pt
                                                                              ON p.PaymentTypeID = pt.PaymentTypeID
                                                                              WHERE p.JobID = job.JobID
                                                                              UNION ALL
                                                                              SELECT      '' AS PayType,
                                                                                          '' AS PayAmount,
                                                                                          '' AS PayAuth,
                                                                                          '' AS LockedYN
                                                                              ) x
                                                                        FOR XML PATH('Item'), ROOT('Payments'), TYPE
                                                                  )
                                                ELSE 
                                                      (
                                                            SELECT      ISNULL(pt.PaymentType,'UNKNOWN') AS PayType,
                                                                        p.PaymentAmount AS PayAmount,
                                                                        '' AS PayAuth,
                                                                        'True' AS LockedYN
                                                            FROM  tbl_Payments p
                                                            LEFT JOIN tbl_Payment_Types pt
                                                            ON p.PaymentTypeID = pt.PaymentTypeID
                                                            WHERE p.JobID = job.JobID
                                                            FOR XML PATH('Item'), ROOT('Payments'), TYPE
                                                      )                 
                                                END               
                                    )
                              FROM tbl_job job 
                              WHERE job.JobID = @JobID
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
            SELECT  @FileName = ltrim(str(@JobID) + '_tbl_JobStatus.xml'),
                        @JobStatus = CAST(
                              (SELECT     j.FranchiseID,
                                    j.LocationID,
                                    'Sent to Tablet' AS [Status], -- js.Status,
                                    ROW_NUMBER()OVER(ORDER BY j.JobID) AS SequenceID, 
                                    ' '  AS [JobType],
                                    j.CallReason AS JobDescription,
                                    'No' As EstimateYN,
                                    '' AS [Message]
                        FROM tbl_Job j
                        --left JOIN tbl_Job_Type jt ON j.JobTypeID = jt.JobTypeID
                        INNER JOIN tbl_Job_Status js ON js.StatusID = j.StatusID
                        WHERE j.JobID =@JobID
                        FOR XML PATH('tbl_JobStatus')
                              )
                        AS VARCHAR(MAX))
            
            EXEC dbo.WriteStringToFile 
                  @pv_path        = @Folder,
                  @pv_filename    = @FileName,
                  @pv_data        = @JobStatus,
                  @pi_result_code = @li OUTPUT,
                  @pv_result_msg  = @lv OUTPUT;
            
            SELECT @Contents = @Contents + '<file>' + @FileName + '</file>'
            
            DECLARE @RealTaskCount INT
            SELECT @RealTaskCount = COUNT(1) FROM tbl_Job_Tasks WHERE JobID = @JobID
            
            DECLARE @RealPartCount INT
            SELECT @RealPartCount = COUNT(1) FROM tbl_Job_Task_Parts jp INNER JOIN tbl_Job_Tasks jt ON jt.JobTaskID = jp.JobTaskID AND jt.JobID = @JobID
                  
            /* tbl_JobTasks.xml */
            ;WITH [thisiscrazytasks] AS
            (
                  SELECT  t.JobTaskID,
                              t.Quantity AS Qty,
                              t.JobCode AS TaskCode,
                              t.JobCodeDescription AS TaskDescription,
                              t.Price AS UnitPrice,
                              ( t.Price * t.Quantity ) AS LinePrice,
                              t.Price AS AdjustedPrice,
                              ISNULL(MIN(jc.JobMemberPrice), t.Price) AS HomeGuardPrice,
                              t.Price AS StandardPrice
                  FROM  tbl_job_tasks t 
                  LEFT JOIN dbo.tbl_PB_JobCodes jc
                  ON jc.JobCodeID = t.JobCodeID
                  WHERE t.JobID = @JobID
                  GROUP BY t.JobTaskID, t.JobCode, t.JobCodeDescription, t.Price, t.Quantity, t.MemberYN
                  UNION ALL
                  SELECT -1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                  UNION ALL
                  SELECT -2,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
            )
            , [thisiscrazyparts] AS
            (
                  SELECT  jp.JobTaskID, 
                              jp.Quantity As Qty,
                              PartCode AS PartCode,
                              PartName AS PartDescription,
                              ROUND(jp.Price, 2) AS UnitPrice,
                              ROUND((jp.Price * jp.Quantity), 2) AS LinePrice,
                              ROUND(ISNULL(jcd.PartMemberPrice, jp.Price), 2) AS HomeGuardPrice
                  FROM  tbl_Job_Task_Parts jp 
                  INNER JOIN tbl_Job_Tasks jt
                  ON jt.JobTaskID = jp.JobTaskID AND jt.JobID = @JobID
                  LEFT JOIN dbo.tbl_PB_JobCodes_Details jcd
                  ON jcd.JobCodeID = jt.JobCodeID AND jcd.PartID = jp.PartsID
                  UNION ALL
                  SELECT -1,NULL,NULL,NULL,NULL,NULL,NULL
                  UNION ALL
                  SELECT -2,NULL,NULL,NULL,NULL,NULL,NULL
                  UNION ALL
                  SELECT -1,NULL,NULL,NULL,NULL,NULL,NULL
                  UNION ALL
                  SELECT -2,NULL,NULL,NULL,NULL,NULL,NULL
            )
            SELECT  @FileName = ltrim(str(@JobID) + '_tbl_JobTasks.xml'),
                        @JobStatus = CAST(
                              (
                                    SELECT      j.FranchiseID,
                                    j.LocationID,
                                    TaxAmount AS TaxRate,
                                    '' AS TaxName,
                                    '' AS CouponCode,
                                    '' AS DiscountReason,
                                    (
                                          SELECT      t.Qty AS Qty,
                                                      t.TaskCode AS TaskCode,
                                                      t.TaskDescription AS TaskDescription,
                                                      CONVERT(DECIMAL(10,2), ROUND(t.UnitPrice, 2)) AS [UnitPrice],
                                                      CONVERT(DECIMAL(10,2), ROUND(t.LinePrice, 2)) AS [LinePrice],
                                                      CONVERT(DECIMAL(10,2), ROUND(t.AdjustedPrice, 2)) AS [AdjustedPrice],
                                                      CONVERT(DECIMAL(10,2), ROUND(t.HomeGuardPrice, 2)) AS [HomeGuardPrice],
                                                      CONVERT(DECIMAL(10,2), ROUND(t.StandardPrice, 2)) AS [StandardPrice],
                                                      (
                                                            SELECT  jp.Qty AS Qty,
                                                                        PartCode AS PartCode,
                                                                        PartDescription AS PartDescription,
                                                                        CONVERT(DECIMAL(10,2), ROUND(UnitPrice, 2)) AS UnitPrice,
                                                                        CONVERT(DECIMAL(10,2), ROUND(LinePrice, 2)) AS LinePrice,
                                                                        CONVERT(DECIMAL(10,2), ROUND(HomeGuardPrice, 2)) AS HomeGuardPrice
                                                            FROM  [thisiscrazyparts] jp
                                                            WHERE jp.JobTaskID = t.JobTaskID
                                                            FOR XML PATH('Part'), ROOT('Parts'), TYPE, ELEMENTS XSINIL            
                                                      )
                                          FROM  [thisiscrazytasks] t--tbl_job_tasks t 
                                          WHERE t.JobTaskID >= (CASE WHEN @RealTaskCount = 1 THEN -1 WHEN @RealTaskCount = 0 THEN -2 ELSE 1 END)
                                          FOR XML PATH('Task'), ROOT('Tasks'), TYPE, ELEMENTS XSINIL
                                          )
                                    from tbl_job j (NOLOCK)
                                    WHERE jobid=@JobID
                                    FOR XML PATH(''),ROOT('tbl_JobTasks')
                              )
                        AS VARCHAR(MAX))
            
            SET @JobStatus = REPLACE(REPLACE(@JobStatus,'xsi:nil="true"',''), 'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"','')
            
            EXEC dbo.WriteStringToFile 
                  @pv_path        = @Folder,
                  @pv_filename    = @FileName,
                  @pv_data        = @JobStatus,
                  @pi_result_code = @li OUTPUT,
                  @pv_result_msg  = @lv OUTPUT;
            
            SELECT @Contents = @Contents + '<file>' + @FileName + '</file>'
            
            DECLARE @AcceptedByWritten BIT
			DECLARE @AuthorizationWritten BIT
			
			SET @AcceptedByWritten = 0
			SET @AuthorizationWritten = 0
			
            EXEC SaveImageToDisk @JobID, @Path, @AcceptedByWritten OUTPUT, @AuthorizationWritten OUTPUT
                        
            IF @AcceptedByWritten = 1
				SET @Contents = @Contents + '<file>' + CONVERT(VARCHAR(50), @JobID) + '_Accepted.jpg</file>'
			
			IF @AuthorizationWritten = 1
				SET @Contents = @Contents + '<file>' + CONVERT(VARCHAR(50), @JobID) + '_Signature.jpg</file>'
            
            SELECT @FileName = 'contents.xml'
            SELECT @Contents = @Contents + '</contents>'
            
            EXEC dbo.WriteStringToFile 
                  @pv_path        = @Folder,
                  @pv_filename    = @FileName,
                  @pv_data        = @Contents,
                  @pi_result_code = @li OUTPUT,
                  @pv_result_msg  = @lv OUTPUT;

			
      END   
END



















GO


