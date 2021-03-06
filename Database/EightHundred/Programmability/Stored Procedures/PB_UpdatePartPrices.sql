USE [EightHundred]
GO
/****** Object:  StoredProcedure [dbo].[PB_UpdatePartPrices]    Script Date: 03/30/2012 13:12:28 ******/
DROP PROCEDURE [dbo].[PB_UpdatePartPrices]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PB_UpdatePartPrices] 
	@PriceBookId INT,
	@PartId INT,
	@PartCost MONEY,
	@StandardPrice MONEY = NULL,
	@AddOnPrice MONEY = NULL,
	@MemberPrice MONEY = NULL,
	@MemberAddOnPrice MONEY = NULL,
	@UpdatePriceForPriceBook BIT = 0
AS
BEGIN
	DECLARE @MemberDiscount INT
	SELECT @MemberDiscount = MemberDiscountRate FROM tbl_PriceBook_Rates WHERE PriceBookID = @PriceBookId
	
	IF @MemberDiscount IS NULL
		SET @MemberDiscount = 0
	
	DECLARE @IsLabor BIT
	
	IF EXISTS (SELECT 1 FROM tbl_PB_Parts p 
			 INNER JOIN tbl_PB_MasterParts mp
			 ON p.MasterPartID = mp.MasterPartID 
			 WHERE p.PartID = @PartID 
				AND mp.PartCodeID IN ('LA','LD','LH','LJ'))
		SET @IsLabor = 1
	ELSE 
		SET @IsLabor = 0

	UPDATE jcd
	SET 
		jcd.PartCost = @PartCost
		, jcd.PartStdPrice = ISNULL(@StandardPrice * ISNULL(jcd.Qty,0), @PartCost * ISNULL(jcd.Qty,0) * ISNULL(mu.Markup, 1))
		, jcd.PartAddonStdPrice = ISNULL(@AddOnPrice * ISNULL(jcd.Qty,0), @PartCost * ISNULL(jcd.Qty,0) * ISNULL(mu.Markup, 1))
		, jcd.PartMemberPrice = ISNULL(@MemberPrice * ISNULL(jcd.Qty,0), @PartCost * ISNULL(jcd.Qty,0) * ISNULL(mu.Markup, 1) * (100-@MemberDiscount)/100)
		, jcd.PartAddonMemberPrice = ISNULL(@MemberAddOnPrice * ISNULL(jcd.Qty,0), @PartCost * ISNULL(jcd.Qty,0) * ISNULL(mu.Markup, 1) * (100-@MemberDiscount)/100)
		, jcd.ManualPricingYN = 1
	--SELECT
	--	@PartCost AS PartCost,
	--	@MemberDiscount AS MemberDiscount,
	--	jcd.Qty AS Quantity,
	--	mu.Markup,
	--	ISNULL(@StandardPrice * ISNULL(jcd.Qty,0), @PartCost * ISNULL(jcd.Qty,0) * ISNULL(mu.Markup, 1)) AS StdPrice,
	--	ISNULL(@AddOnPrice * ISNULL(jcd.Qty,0), @PartCost * ISNULL(jcd.Qty,0) * ISNULL(mu.Markup, 1)) AS AddOn,
	--	ISNULL(@MemberPrice * ISNULL(jcd.Qty,0), @PartCost * ISNULL(jcd.Qty,0) * ISNULL(mu.Markup, 1) * (100-@MemberDiscount)/100) AS MemberStd,
	--	ISNULL(@MemberAddOnPrice * ISNULL(jcd.Qty,0), @PartCost * ISNULL(jcd.Qty,0) * ISNULL(mu.Markup, 1) * (100-@MemberDiscount)/100) AS MemberAddOn
	FROM tbl_PriceBook pb
		
	INNER JOIN tbl_PB_Section s
	ON pb.PriceBookID = s.PriceBookID
	
	INNER JOIN tbl_PB_SubSection ss
	ON s.SectionID = ss.SectionID
	
	INNER JOIN tbl_PB_JobCodes jc
	ON jc.SubSectionID = ss.SubsectionID
	
	INNER JOIN tbl_PB_JobCodes_Details jcd
	ON jc.JobCodeID = jcd.JobCodeID
	
	INNER JOIN tbl_PB_Parts p
	ON jcd.PartID = p.PartID
	
	INNER JOIN tbl_PB_MasterParts mp
	ON p.MasterPartID = mp.MasterPartID 
	
	LEFT JOIN tbl_PB_Markup mu
	ON mu.Lowerbound <= @PartCost 
		AND mu.Upperbound >= @PartCost AND @IsLabor = 0
	
	WHERE pb.PriceBookID = @PriceBookId
		AND p.PartID = @PartId
		
	IF @UpdatePriceForPriceBook = 1
	BEGIN
		UPDATE p
			SET p.PartCost = @PartCost
		, p.PartStdPrice = ISNULL(@StandardPrice, @PartCost * ISNULL(mu.Markup, 1))
		, p.PartAddonStdPrice = ISNULL(@AddOnPrice, @PartCost * ISNULL(mu.Markup, 1))
		, p.PartMemberPrice = ISNULL(@MemberPrice, @PartCost * ISNULL(mu.Markup, 1) * (100-@MemberDiscount)/100)
		, p.PartAddonMemberPrice = ISNULL(@MemberAddOnPrice, @PartCost * ISNULL(mu.Markup, 1) * (100-@MemberDiscount)/100)
		FROM tbl_PB_Parts p
		LEFT JOIN tbl_PB_Markup mu
		ON mu.Lowerbound <= @PartCost AND mu.Upperbound >= @PartCost AND @IsLabor = 0
		WHERE p.PartID = @PartId
	END
	
	EXEC PB_RecalculatePrices @PriceBookId
END
GO
