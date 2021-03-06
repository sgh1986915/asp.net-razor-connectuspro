USE [EightHundred]
GO
/****** Object:  StoredProcedure [dbo].[Report]    Script Date: 03/30/2012 13:12:29 ******/
DROP PROCEDURE [dbo].[Report]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Sunil Kumar>
-- Create date: <01-07-2012>
-- Description:	<This procedured is used to bind the report according to invoicedate>
-- =============================================
CREATE PROCEDURE  [dbo].[Report]
	(

	-- Add the parameters for the stored procedure here
	@FranchiseID int
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	    with a as
        (

            select  TotalSales ,JobID     from tbl_Job where InvoicedDate>GETDATE() and
            tbl_Job.Balance!=0 and tbl_Job.FranchiseID =@FranchiseID
         ),
         a1 as
         (
             select  TotalSales ,JobID    from tbl_Job where InvoicedDate <=GETDATE() and InvoicedDate>GETDATE()-30 and
             tbl_Job.Balance!=0 and tbl_Job.FranchiseID  =@FranchiseID
          ),
 
         a2 as
         (  
              select  tbl_Job.TotalSales ,tbl_Job.JobID     from tbl_Job where InvoicedDate <=GETDATE()-30 and InvoicedDate>GETDATE()-60 and
              tbl_Job.Balance!=0 and tbl_Job.FranchiseID  =@FranchiseID
          ),
 
         a3 as
         (  
              select  tbl_Job.TotalSales ,tbl_Job.JobID     from tbl_Job where InvoicedDate <=GETDATE()-60 and InvoicedDate>GETDATE()-90 and
              tbl_Job.Balance!=0 and tbl_Job.FranchiseID  =@FranchiseID
          ),
          a4 as
         (  
              select  tbl_Job.TotalSales ,tbl_Job.JobID     from tbl_Job where InvoicedDate <=GETDATE()-90  and
              tbl_Job.Balance!=0 and tbl_Job.FranchiseID  =@FranchiseID
          )
          select ISNULL(a.TotalSales,0.00) as CurrentDateAmount,
          ISNULL(a1.TotalSales,0.00)as CurrentDateAmount1,
          ISNULL(a2.TotalSales,0.00)as CurrentDateAmount2,
          ISNULL(a3.TotalSales,0.00)as CurrentDateAmount3,
          ISNULL(a4.TotalSales,0.00)as CurrentDateAmount4 from a
          full outer join a1 on a.JobID	=a1.JobID 
          full outer join a2 on a.JobID=a2.JobID  
          full outer join a3 on a.JobID=a3.JobID
          full outer join a4 on a.JobID=a4.JobID	
END
GO
