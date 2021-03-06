
SET NUMERIC_ROUNDABORT OFF
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
PRINT N'Dropping foreign keys from [dbo].[tbl_HVAC_Answers]'
GO
ALTER TABLE [dbo].[tbl_HVAC_Answers] DROP CONSTRAINT[FK_tbl_HVAC_Answers_tbl_HVAC_Questions]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping foreign keys from [dbo].[tbl_HVAC_ConfigQuestions]'
GO
ALTER TABLE [dbo].[tbl_HVAC_ConfigQuestions] DROP CONSTRAINT[FK_tbl_HVAC_ConfigQuestions_tbl_HVAC_Questions]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[tbl_HVAC_Questions]'
GO
ALTER TABLE [dbo].[tbl_HVAC_Questions] DROP CONSTRAINT [PK__tbl_HVAC__0DC06F8C246854D6]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[tbl_HVAC_AccessoryQuestions]'
GO
CREATE TABLE [dbo].[tbl_HVAC_AccessoryQuestions]
(
[QuestionID] [int] NOT NULL
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK_tbl_HVAC_AccessoryQuestions] on [dbo].[tbl_HVAC_AccessoryQuestions]'
GO
ALTER TABLE [dbo].[tbl_HVAC_AccessoryQuestions] ADD CONSTRAINT [PK_tbl_HVAC_AccessoryQuestions] PRIMARY KEY CLUSTERED  ([QuestionID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[tbl_HVAC_AccessoryButtonsAndAnswers]'
GO
CREATE TABLE [dbo].[tbl_HVAC_AccessoryButtonsAndAnswers]
(
[ButtonID] [int] NOT NULL IDENTITY(1, 1),
[ConfigID] [int] NOT NULL,
[QuestionID] [int] NOT NULL,
[btnText] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Message] [nvarchar] (110) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DataAnswer] [bit] NULL
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK_tbl_HVAC_AccessoryButtonsAndAnswers] on [dbo].[tbl_HVAC_AccessoryButtonsAndAnswers]'
GO
ALTER TABLE [dbo].[tbl_HVAC_AccessoryButtonsAndAnswers] ADD CONSTRAINT [PK_tbl_HVAC_AccessoryButtonsAndAnswers] PRIMARY KEY CLUSTERED  ([ButtonID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Rebuilding [dbo].[tbl_HVAC_Questions]'
GO
CREATE TABLE [dbo].[tmp_rg_xx_tbl_HVAC_Questions]
(
[QuestionID] [int] NOT NULL IDENTITY(1, 1),
[QuestionText] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ConfigID] [int] NULL
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
SET IDENTITY_INSERT [dbo].[tmp_rg_xx_tbl_HVAC_Questions] ON
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
INSERT INTO [dbo].[tmp_rg_xx_tbl_HVAC_Questions]([QuestionID], [QuestionText]) SELECT [QuestionID], [QuestionText] FROM [dbo].[tbl_HVAC_Questions]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
SET IDENTITY_INSERT [dbo].[tmp_rg_xx_tbl_HVAC_Questions] OFF
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
DROP TABLE [dbo].[tbl_HVAC_Questions]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
EXEC sp_rename N'[dbo].[tmp_rg_xx_tbl_HVAC_Questions]', N'tbl_HVAC_Questions'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK__tbl_HVAC__0DC06F8C246854D6] on [dbo].[tbl_HVAC_Questions]'
GO
ALTER TABLE [dbo].[tbl_HVAC_Questions] ADD CONSTRAINT [PK__tbl_HVAC__0DC06F8C246854D6] PRIMARY KEY CLUSTERED  ([QuestionID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[tbl_HVAC_ConfigGuaranteeTexts]'
GO
ALTER TABLE [dbo].[tbl_HVAC_ConfigGuaranteeTexts] ADD
[btnAgreeText] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[btnDisagreeText] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MessageAgree] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MessageDisagree] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [dbo].[tbl_HVAC_Answers]'
GO
ALTER TABLE [dbo].[tbl_HVAC_Answers] WITH NOCHECK  ADD CONSTRAINT [FK_tbl_HVAC_Answers_tbl_HVAC_Questions] FOREIGN KEY ([QuestionID]) REFERENCES [dbo].[tbl_HVAC_Questions] ([QuestionID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [dbo].[tbl_HVAC_ConfigQuestions]'
GO
ALTER TABLE [dbo].[tbl_HVAC_ConfigQuestions] WITH NOCHECK  ADD CONSTRAINT [FK_tbl_HVAC_ConfigQuestions_tbl_HVAC_Questions] FOREIGN KEY ([QuestionID]) REFERENCES [dbo].[tbl_HVAC_Questions] ([QuestionID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [dbo].[tbl_HVAC_AccessoryButtonsAndAnswers]'
GO
ALTER TABLE [dbo].[tbl_HVAC_AccessoryButtonsAndAnswers] ADD CONSTRAINT [FK_tbl_HVAC_AccessoryButtonsAndAnswers_tbl_HVAC_ConfigsApp1] FOREIGN KEY ([ConfigID]) REFERENCES [dbo].[tbl_HVAC_ConfigsApp] ([ConfigID])
ALTER TABLE [dbo].[tbl_HVAC_AccessoryButtonsAndAnswers] ADD CONSTRAINT [FK_tbl_HVAC_AccessoryButtonsAndAnswers_tbl_HVAC_AccessoryQuestions1] FOREIGN KEY ([QuestionID]) REFERENCES [dbo].[tbl_HVAC_AccessoryQuestions] ([QuestionID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [dbo].[tbl_HVAC_AccessoryQuestions]'
GO
ALTER TABLE [dbo].[tbl_HVAC_AccessoryQuestions] ADD CONSTRAINT [FK_tbl_HVAC_AccessoryQuestions_tbl_HVAC_Questions] FOREIGN KEY ([QuestionID]) REFERENCES [dbo].[tbl_HVAC_Questions] ([QuestionID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [dbo].[tbl_HVAC_Guarantees]'
GO
ALTER TABLE [dbo].[tbl_HVAC_Guarantees] ADD CONSTRAINT [FK_tbl_HVAC_Guarantees_tbl_HVAC_Questions] FOREIGN KEY ([GuaranteeID]) REFERENCES [dbo].[tbl_HVAC_Questions] ([QuestionID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [dbo].[tbl_HVAC_Questions]'
GO
ALTER TABLE [dbo].[tbl_HVAC_Questions] ADD CONSTRAINT [FK_tbl_HVAC_Questions_tbl_HVAC_ConfigsApp] FOREIGN KEY ([ConfigID]) REFERENCES [dbo].[tbl_HVAC_ConfigsApp] ([ConfigID])
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
