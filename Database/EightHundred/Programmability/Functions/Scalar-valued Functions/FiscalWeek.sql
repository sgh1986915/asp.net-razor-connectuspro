USE [EightHundred]
GO
/****** Object:  UserDefinedFunction [dbo].[FiscalWeek]    Script Date: 03/30/2012 13:12:30 ******/
DROP FUNCTION [dbo].[FiscalWeek]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[FiscalWeek] (@startMonth varchar(2), @myDate datetime)  
returns int  
as  
begin  
declare @firstWeek datetime  
declare @weekNum int  
declare @year int  
set @year = datepart(year, @myDate)+1  
--Get 4th day of month of next year, this will always be in week 1  
set @firstWeek = convert(datetime, str(@year)+@startMonth+'04', 102)  
--Retreat to beginning of week  
set @firstWeek = dateadd(day, (1-datepart(dw, @firstWeek)), @firstWeek)  
while @myDate < @firstWeek --Repeat the above steps but for previous year  
 begin  
  set @year = @year - 1  
  set @firstWeek = convert(datetime, str(@year)+@startMonth+'04', 102)  
  set @firstWeek = dateadd(day, (1-datepart(dw, @firstWeek)), @firstWeek)  
 end  
set @weekNum = (@year*100)+((datediff(day, @firstweek, @myDate)/7)+1)  
return @weekNum  
end
GO
