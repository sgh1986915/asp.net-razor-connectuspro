USE [EightHundred]
GO
/****** Object:  StoredProcedure [dbo].[GetTimeCardByTechnician]    Script Date: 03/30/2012 13:12:26 ******/
DROP PROCEDURE [dbo].[GetTimeCardByTechnician]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Tejas Shah
-- Create date: 2012-01-29
-- Description:	
-- =============================================
--GetTimeCardByTechnician '1/1/2011','11/08/2011', 141
CREATE PROCEDURE [dbo].[GetTimeCardByTechnician]
	@StartDate	DATETIME,
	@EndDate	DATETIME,
	@ServiceProID	INT
AS
BEGIN
	SET NOCOUNT ON;

	;with cteTravel as(
		SELECT	j.JobID,
				c.CustomeriD,
				h.StatusDateChanged AS StatusDateChanged,
				CAST(h.StatusDateChanged AS DATE) AS StatusDate,
				s.Status,
				ROW_NUMBER() OVER(PARTITION BY j.JobID, CAST(h.StatusDateChanged AS DATE)  ORDER BY h.StatusDateChanged) As RowID
		FROM	tbl_job j
		INNER JOIN tbl_Customer c ON c.CustomerID = j.CustomeriD
		INNER JOIN tbl_Job_Status_History h ON h.JobID = j.JobID
		INNER JOIN tbl_job_status s ON s.StatusID = h.StatusID
		WHERE s.Status = 'Travel'
		AND j.ServiceProID = @ServiceProID
		AND h.StatusDateChanged BETWEEN @StartDate AND @EndDate
	), cteTravelUpto as(
		SELECT	j.JobID,
				c.CustomeriD,
				c.CustomerName,
				h.StatusDateChanged  AS StatusDateChanged,
				t.Status,
				s.Status AS StatusChangedTo,
				t.StatusDateChanged As TravelStatusDateChanged,
				t.StatusDate,
				CAST((DATEDIFF(mi, t.StatusDateChanged, h.StatusDateChanged )) / 60.0 AS NUMERIC(18,2)) As Hours,
				ROW_NUMBER() OVER(PARTITION BY j.JobID, CAST(h.StatusDateChanged AS DATE)  ORDER BY h.StatusDateChanged) As RowID
		FROM	tbl_job j
		INNER JOIN tbl_Customer c ON c.CustomerID = j.CustomeriD
		INNER JOIN tbl_Job_Status_History h ON h.JobID = j.JobID
		INNER JOIN tbl_job_status s ON s.StatusID = h.StatusID
		INNER JOIN cteTravel t ON j.JobID = t.JobID	
			AND CAST(h.StatusDateChanged AS DATE) = t.StatusDate
			AND h.StatusDateChanged > t.StatusDateChanged
			AND t.RowID = 1
		WHERE s.Status <> 'Travel'
		AND j.ServiceProID = @ServiceProID
		AND h.StatusDateChanged BETWEEN @StartDate AND @EndDate
	), cteTravelHours as(
			SELECT 
				JobID,
				StatusDate,
				--CustomerID,
				CustomerName,
				--TravelStatusDateChanged AS TravelStart,
				--StatusDateChanged AS TravelEnd,
				Status,
				--StatusChangedTo,
				Hours,
				1 AS Type
			FROM cteTravelUpto
			WHERE RowID=1
	), cteWork as(
		SELECT	j.JobID,
				c.CustomeriD,
				h.StatusDateChanged AS StatusDateChanged,
				CAST(h.StatusDateChanged AS DATE) AS StatusDate,
				s.Status,
				ROW_NUMBER() OVER(PARTITION BY j.JobID, CAST(h.StatusDateChanged AS DATE)  ORDER BY h.StatusDateChanged) As RowID
		FROM	tbl_job j
		INNER JOIN tbl_Customer c ON c.CustomerID = j.CustomeriD
		INNER JOIN tbl_Job_Status_History h ON h.JobID = j.JobID
		INNER JOIN tbl_job_status s ON s.StatusID = h.StatusID
		WHERE s.Status = 'Active'
		AND j.ServiceProID = @ServiceProID
		AND h.StatusDateChanged BETWEEN @StartDate AND @EndDate	
	), cteWorkUpto as(
		SELECT	j.JobID,
				c.CustomeriD,
				c.CustomerName,
				h.StatusDateChanged  AS StatusDateChanged,
				t.Status,
				s.Status AS StatusChangedTo,
				t.StatusDateChanged As TravelStatusDateChanged,
				t.StatusDate,
				CAST((DATEDIFF(mi, t.StatusDateChanged, h.StatusDateChanged )) / 60.0 AS NUMERIC(18,2)) As Hours,
				ROW_NUMBER() OVER(PARTITION BY j.JobID, CAST(h.StatusDateChanged AS DATE)  ORDER BY h.StatusDateChanged) As RowID,
				0 AS Type
		FROM	tbl_job j
		INNER JOIN tbl_Customer c ON c.CustomerID = j.CustomeriD
		INNER JOIN tbl_Job_Status_History h ON h.JobID = j.JobID
		INNER JOIN tbl_job_status s ON s.StatusID = h.StatusID
		INNER JOIN cteWork t ON j.JobID = t.JobID	
			AND CAST(h.StatusDateChanged AS DATE) = t.StatusDate
			AND h.StatusDateChanged > t.StatusDateChanged
			AND t.RowID = 1
		WHERE s.Status NOT IN('Active','Wrap Up')
		AND j.ServiceProID = @ServiceProID
		AND h.StatusDateChanged BETWEEN @StartDate AND @EndDate
	)
	SELECT	JobID,
			StatusDate,
			--CustomerID,
			--CustomerName,
			--TravelStatusDateChanged AS TravelStart,
			--StatusDateChanged AS TravelEnd,
			CustomerName AS Status,
			--StatusChangedTo,
			Hours,
			Type
	FROM cteWorkUpto
	WHERE RowID=1
	UNION ALL
	SELECT	JobID,
			StatusDate,
			--CustomerID,
			--CustomerName,
			--TravelStatusDateChanged AS TravelStart,
			--StatusDateChanged AS TravelEnd,
			Status,
			--StatusChangedTo,
			Hours,
			Type
	FROM cteTravelHours
	ORDER BY JobID, StatusDate, TYPE
			
	--SELECT	c.CustomeriD,
	--		LTRIM(c.CustomerName) AS CustomerName,
	--		CAST(h.StatusDateChanged AS SMALLDATETIME) AS StatusDateChanged,
	--		s.Status
	--		,h1.StatusDateChanged,
	--		s1.Status
	--FROM	tbl_job j
	--INNER JOIN tbl_Customer c ON c.CustomerID = j.CustomeriD
	--INNER JOIN tbl_Job_Status_History h ON h.JobID = j.JobID
	--INNER JOIN tbl_job_status s ON s.StatusID = h.StatusID
	--LEFT JOIN tbl_Job_Status_History h1 ON h1.JobID = h.JobID
	--	AND h1.StatusID=3
	--	AND CAST(h.StatusDateChanged AS DATE) = CAST(h1.StatusDateChanged AS DATE)
	--	AND h.StatusDateChanged > h1.StatusDateChanged
	--	AND h.StatusID = 4
	--LEFT JOIN tbl_job_status s1 ON s1.StatusID = h1.StatusID
	--WHERE	j.ServiceProID = @ServiceProID
	--AND		h.StatusDateChanged BETWEEN @StartDate AND @EndDate
	--ORDER BY h.JObID, h.StatusDateChanged	DESC
END
GO
