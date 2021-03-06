USE [EightHundred]
GO
/****** Object:  UserDefinedFunction [dbo].[XmlEncode]    Script Date: 03/30/2012 13:12:30 ******/
DROP FUNCTION [dbo].[XmlEncode]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[XmlEncode]
(
	@Text AS VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
BEGIN
	RETURN 
		REPLACE(REPLACE(REPLACE(REPLACE(@Text, '&','and'), '<','&lt;'), '>','&gt;'), '"', '&quot;')
END
GO
