﻿SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE id=OBJECT_ID('tempdb..#tmpErrors')) DROP TABLE #tmpErrors
GO
CREATE TABLE #tmpErrors (Error int)
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
GO
BEGIN TRANSACTION
GO
PRINT N'Dropping foreign keys from [dbo].[tbl_Job_Payroll]'
GO
ALTER TABLE [dbo].[tbl_Job_Payroll] DROP CONSTRAINT[FK_JOBPAYROLL_FRANCHISE]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[tbl_Job_Payroll]'
GO
ALTER TABLE [dbo].[tbl_Job_Payroll] ADD
[AmountForCommission] [money] NOT NULL CONSTRAINT [JOBPAYROLL_AMOUNTFORCOMMISSION_DEFAULT] DEFAULT ((0.0)),
[TotalCommissionPartsAndLabor] [money] NOT NULL CONSTRAINT [JOBPAYROLL_TOTALCOMMISSIONPARTSANDLABOR_DEFAULT] DEFAULT ((0.0)),
[TotalCommission] [money] NOT NULL CONSTRAINT [JOBPAYROLL_TOTALCOMMISSION_DEFAULT] DEFAULT ((0.0))
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
IF EXISTS (SELECT * FROM #tmpErrors) ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT>0 BEGIN
PRINT 'The database update succeeded'
COMMIT TRANSACTION
END
ELSE PRINT 'The database update failed'
GO
DROP TABLE #tmpErrors
GO