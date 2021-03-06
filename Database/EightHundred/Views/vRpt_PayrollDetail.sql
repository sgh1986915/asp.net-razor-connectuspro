USE [EightHundred]
GO
/****** Object:  View [dbo].[vRpt_PayrollDetail]    Script Date: 04/04/2012 21:45:21 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vRpt_PayrollDetail]'))
DROP VIEW [dbo].[vRpt_PayrollDetail]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vRpt_PayrollDetail]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[vRpt_PayrollDetail]
AS
SELECT 
	pd.[PayrollDetailID]
	,pd.[PayrollID]
	,pd.[EmployeeID]
	,pd.[WeeklySalary]
	,pd.[RegularHours]
	,pd.[RegularRate]
	,pd.[RegularPay]
	,pd.[OTHours]
	,pd.[OTRate]
	,pd.[OTPay]
	,pd.[CommissionParts]
	,pd.[CommissionLabor]
	,[CommissionSpifs] = ROUND( SUM(ISNULL(jp.TotalCommissionSpifs, 0)) , 2)
	,[TotalCommission] = ROUND( SUM(ISNULL(jp.TotalCommissionPartsAndLabor, 0)) , 2)
	,pd.[SundayHours]
	,pd.[MondayHours]
	,pd.[TuesdayHours]
	,pd.[WednesdayHours]
	,pd.[ThursdayHours]
	,pd.[FridayHours]
	,pd.[SaturdayHours]
	,[JobCount] = SUM(CASE WHEN jp.JobPayrollID IS NULL THEN 0 ELSE 1 END)
	,pd.[Adjustment]
	,pd.[AdjustmentReason]
	,pd.[CommissionRateHour]
	,[CommissionOTMultiplier] = 
			CASE WHEN pd.RegularHours + pd.OTHours = 0 THEN 0 
				ELSE ROUND(
							SUM(ISNULL(jp.TotalCommissionPartsAndLabor, 0)) -- Total Comission
							/ (pd.RegularHours + pd.OTHours)
							, 2)
			END
	,[OTAdditCommission] =
			pd.CommissionRateHour * pd.OTHours *	
			CASE WHEN pd.RegularHours + pd.OTHours = 0 THEN 0 -- CommissionOTMultiplier
				ELSE SUM(ISNULL(jp.TotalCommissionPartsAndLabor, 0)) -- Total Comission
							/ (pd.RegularHours + pd.OTHours)
			END
	,[GrossPay] = pd.WeeklySalary + pd.RegularPay + pd.OTPay
					+ ROUND( SUM(ISNULL(jp.TotalCommissionPartsAndLabor, 0)) , 2)	-- TotalCommission
					+ ROUND( SUM(ISNULL(jp.TotalCommissionSpifs, 0)) , 2)			-- CommissionSpifs
					+	(															-- OTAdditCommission
							pd.CommissionRateHour * pd.OTHours *	
							CASE WHEN pd.RegularHours + pd.OTHours = 0 THEN 0 -- CommissionOTMultiplier
								ELSE SUM(ISNULL(jp.TotalCommissionPartsAndLabor, 0)) -- Total Comission
										/ (pd.RegularHours + pd.OTHours)
							END
						)

	,pd.[TimeStamp]
	,pr.LockDate
  FROM [dbo].[tbl_PayrollDetails] pd
		INNER JOIN dbo.tbl_Payroll pr ON pd.PayrollID = pr.PayrollID
		LEFT JOIN dbo.tbl_Job_Payroll jp ON pr.PayrollID = jp.PayrollID
											AND pd.EmployeeID = jp.ServiceProID
WHERE (1 = 1)
GROUP BY
	pd.[PayrollDetailID]
	,pd.[PayrollID]
	,pd.[EmployeeID]
	,pd.[WeeklySalary]
	,pd.[RegularHours]
	,pd.[RegularRate]
	,pd.[RegularPay]
	,pd.[OTHours]
	,pd.[OTRate]
	,pd.[OTPay]
	,pd.[CommissionParts]
	,pd.[CommissionLabor]
	,pd.[GrossPay]
	,pd.[SundayHours]
	,pd.[MondayHours]
	,pd.[TuesdayHours]
	,pd.[WednesdayHours]
	,pd.[ThursdayHours]
	,pd.[FridayHours]
	,pd.[SaturdayHours]
	,pd.[Adjustment]
	,pd.[AdjustmentReason]
	,pd.[CommissionOTMultiplier]
	,pd.[CommissionRateHour]
	,pd.[TimeStamp]
	,pr.LockDate


'
GO
