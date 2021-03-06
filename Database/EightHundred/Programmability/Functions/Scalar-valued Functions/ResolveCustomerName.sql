USE [EightHundred]
GO
/****** Object:  UserDefinedFunction [dbo].[ResolveCustomerName]    Script Date: 03/30/2012 13:12:30 ******/
DROP FUNCTION [dbo].[ResolveCustomerName]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[ResolveCustomerName]
(
	-- Add the parameters for the function here
	@CustomerName VARCHAR(50),
	@CompanyName VARCHAR(50)
)
RETURNS VARCHAR(105)
AS
BEGIN
	RETURN CASE  WHEN @CustomerName IS NULL AND @CompanyName IS NULL THEN 'UNKNOWN CUSTOMER'
			WHEN @CustomerName IS NULL OR LTRIM(@CustomerName) = '' THEN @companyname 
			WHEN @companyname IS NULL OR LTRIM(@companyname) = '' THEN @customername 
			ELSE @companyname + ' - ' + @customername END

END
GO
