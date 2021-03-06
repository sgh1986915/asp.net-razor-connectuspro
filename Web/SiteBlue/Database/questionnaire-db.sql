USE [DB_29195_applicants]
GO
/****** Object:  Table [dbo].[Status]    Script Date: 09/15/2011 23:22:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Status](
	[StatusId] [int] IDENTITY(1,1) NOT NULL,
	[StatusName] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](255) NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_Status] PRIMARY KEY CLUSTERED 
(
	[StatusId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Questionnaires]    Script Date: 09/15/2011 23:22:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Questionnaires](
	[QuestionnaireId] [bigint] IDENTITY(1,1) NOT NULL,
	[UserId] [uniqueidentifier] NULL,
	[StatusId] [int] NULL,
	[CreationDate] [datetime] NULL,
	[LastModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_Questionnaire_QuestionnaireId] PRIMARY KEY CLUSTERED 
(
	[QuestionnaireId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Technicians]    Script Date: 09/15/2011 23:22:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Technicians](
	[TechnicianId] [bigint] IDENTITY(1,1) NOT NULL,
	[QuestionnaireId] [bigint] NOT NULL,
	[TechnicianName] [nvarchar](50) NOT NULL,
	[HomeAddress] [nvarchar](255) NULL,
	[City] [nvarchar](50) NULL,
	[State] [nvarchar](50) NULL,
	[ZipCode] [nvarchar](10) NULL,
	[EmailAddress] [nvarchar](255) NULL,
	[EmergencyContact] [nvarchar](50) NULL,
	[EmergencyPhone] [nvarchar](20) NULL,
	[PlumbingHvac] [nvarchar](255) NULL,
	[IndustryLicenses] [nvarchar](255) NULL,
	[Training] [nvarchar](255) NULL,
 CONSTRAINT [PK_Technician_TechnicianId] PRIMARY KEY CLUSTERED 
(
	[TechnicianId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ServiceCenters]    Script Date: 09/15/2011 23:22:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServiceCenters](
	[ServiceCenterId] [bigint] IDENTITY(1,1) NOT NULL,
	[QuestionnaireId] [bigint] NOT NULL,
	[CompanyName] [nvarchar](255) NULL,
	[OperationDaysHours] [nvarchar](255) NULL,
	[AvailableTechnicians] [nvarchar](255) NULL,
	[ServiceTripCharges] [nvarchar](255) NULL,
	[ExtraCharges] [nvarchar](255) NULL,
	[SpecialDiscounts] [nvarchar](255) NULL,
	[CurrentMarketing] [nvarchar](255) NULL,
	[SalesPeople] [nvarchar](255) NULL,
	[ZipCodes] [nvarchar](255) NULL,
	[CardsSignature] [nvarchar](255) NULL,
 CONSTRAINT [PK_ServiceCenter_ServiceCenterId] PRIMARY KEY CLUSTERED 
(
	[ServiceCenterId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContactInformations]    Script Date: 09/15/2011 23:22:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContactInformations](
	[ContactInformationId] [bigint] IDENTITY(1,1) NOT NULL,
	[QuestionnaireId] [bigint] NOT NULL,
	[Name] [nvarchar](50) NULL,
	[Title] [nvarchar](50) NULL,
	[WorkAddress] [nvarchar](255) NULL,
	[WorkCity] [nvarchar](50) NULL,
	[WorkState] [nvarchar](10) NULL,
	[WorkZipCode] [nvarchar](10) NULL,
	[EmailAddress] [nvarchar](255) NULL,
	[HomeAddress] [nvarchar](255) NULL,
	[HomeCity] [nvarchar](50) NULL,
	[HomeState] [nvarchar](10) NULL,
	[HomeZipCode] [nvarchar](10) NULL,
	[HomePhone] [nvarchar](20) NULL,
	[CellPhone] [nvarchar](20) NULL,
 CONSTRAINT [PK_ContactInformation_ContactInformationId] PRIMARY KEY CLUSTERED 
(
	[ContactInformationId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AccountingUsageSurveys]    Script Date: 09/15/2011 23:22:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AccountingUsageSurveys](
	[AccountingUsageSurveyId] [bigint] IDENTITY(1,1) NOT NULL,
	[QuestionnaireId] [bigint] NOT NULL,
	[AccountingProgramUsed] [nvarchar](255) NULL,
	[AccountingProgramTime] [nvarchar](255) NULL,
	[LastCompletedMonth] [nvarchar](255) NULL,
 CONSTRAINT [PK_AccountingUsageSurvey_AccountingUsageSurveyId] PRIMARY KEY CLUSTERED 
(
	[AccountingUsageSurveyId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Plumbings]    Script Date: 09/15/2011 23:22:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Plumbings](
	[PlumbingId] [bigint] IDENTITY(1,1) NOT NULL,
	[TechnicianId] [bigint] NOT NULL,
	[BD_diagnosisRepair] [int] NULL,
	[BD_TestCertify] [int] NULL,
	[SD_DiagnosisRepair] [int] NULL,
	[SF_RepairReplace] [int] NULL,
	[OF_ReplaceRepair] [int] NULL,
	[SinkReplacement] [int] NULL,
	[TO_RepairReplace] [int] NULL,
	[UR_RepairReplace] [int] NULL,
	[ShowerPanReplacement] [int] NULL,
	[DS_DiagnosisRepair] [int] NULL,
	[TSD_DiagnosisRepair] [int] NULL,
	[TSF_DiagnosisRepair] [int] NULL,
	[GL_Installation] [int] NULL,
	[GL_DiagnosisRepair] [int] NULL,
	[WH_Installation] [int] NULL,
	[WH_DiagnosisRepair] [int] NULL,
	[KD_RepairReplace] [int] NULL,
	[DWL_RepairReplace] [int] NULL,
	[SL_DiagnosisRepair] [int] NULL,
	[WL_DiagnosisRepair] [int] NULL,
	[MGL_Installation] [int] NULL,
	[MGL_DiagnosisRepair] [int] NULL,
	[WWP_RepairReplace] [int] NULL,
	[SWP_RepairReplace] [int] NULL,
	[SUP_RepairReplace] [int] NULL,
	[WP_DiagnosisRepair] [int] NULL,
	[SL_RepairReplace] [int] NULL,
	[HO_RePipe] [int] NULL,
	[WFS_Installation] [int] NULL,
	[WFS_DiagnosisRepair] [int] NULL,
	[DC_InspectDiagnosis] [int] NULL,
 CONSTRAINT [FK_Plumbing_PlumbingId] PRIMARY KEY CLUSTERED 
(
	[PlumbingId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [FK_Plumbing_TechnicianId] ON [dbo].[Plumbings] 
(
	[TechnicianId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Hvacs]    Script Date: 09/15/2011 23:22:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Hvacs](
	[HvacId] [bigint] IDENTITY(1,1) NOT NULL,
	[TechnicianId] [bigint] NOT NULL,
	[ACU_DiagnosisRepair] [int] NULL,
	[ACS_AnnualMaintenance] [int] NULL,
	[ACU_CleanCoil] [int] NULL,
	[IACU_Installation] [int] NULL,
	[OACU_Installation] [int] NULL,
	[DH_DiagnosisRepair] [int] NULL,
	[DH_Installation] [int] NULL,
	[HS_ReplaceFilters] [int] NULL,
	[HP_DiagnosisRepair] [int] NULL,
	[HP_Installation] [int] NULL,
	[BO_AnnualMaintenance] [int] NULL,
	[BO_Installation] [int] NULL,
	[BO_Repair] [int] NULL,
	[BO_PumpRepair] [int] NULL,
	[BO_LowWaterCutOff] [int] NULL,
	[FR_AnnualMaintenance] [int] NULL,
	[FR_Installation] [int] NULL,
	[FR_Repair] [int] NULL,
	[EAC_DiagnosisRepair] [int] NULL,
	[EAC_Installation] [int] NULL,
	[UVL_Replace] [int] NULL,
 CONSTRAINT [PK_Hvac_HvacId] PRIMARY KEY CLUSTERED 
(
	[HvacId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [FK_Hvac_TechnicianId] ON [dbo].[Hvacs] 
(
	[TechnicianId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  ForeignKey [FK_AccountingUsageSurvey_Questionnaire]    Script Date: 09/15/2011 23:22:43 ******/
ALTER TABLE [dbo].[AccountingUsageSurveys]  WITH CHECK ADD  CONSTRAINT [FK_AccountingUsageSurvey_Questionnaire] FOREIGN KEY([QuestionnaireId])
REFERENCES [dbo].[Questionnaires] ([QuestionnaireId])
GO
ALTER TABLE [dbo].[AccountingUsageSurveys] CHECK CONSTRAINT [FK_AccountingUsageSurvey_Questionnaire]
GO
/****** Object:  ForeignKey [FK_ContactInformation_Questionnaire]    Script Date: 09/15/2011 23:22:43 ******/
ALTER TABLE [dbo].[ContactInformations]  WITH CHECK ADD  CONSTRAINT [FK_ContactInformation_Questionnaire] FOREIGN KEY([QuestionnaireId])
REFERENCES [dbo].[Questionnaires] ([QuestionnaireId])
GO
ALTER TABLE [dbo].[ContactInformations] CHECK CONSTRAINT [FK_ContactInformation_Questionnaire]
GO
/****** Object:  ForeignKey [FK_Hvac_Technician]    Script Date: 09/15/2011 23:22:43 ******/
ALTER TABLE [dbo].[Hvacs]  WITH CHECK ADD  CONSTRAINT [FK_Hvac_Technician] FOREIGN KEY([TechnicianId])
REFERENCES [dbo].[Technicians] ([TechnicianId])
GO
ALTER TABLE [dbo].[Hvacs] CHECK CONSTRAINT [FK_Hvac_Technician]
GO
/****** Object:  ForeignKey [FK_Plumbing_Technician]    Script Date: 09/15/2011 23:22:43 ******/
ALTER TABLE [dbo].[Plumbings]  WITH CHECK ADD  CONSTRAINT [FK_Plumbing_Technician] FOREIGN KEY([TechnicianId])
REFERENCES [dbo].[Technicians] ([TechnicianId])
GO
ALTER TABLE [dbo].[Plumbings] CHECK CONSTRAINT [FK_Plumbing_Technician]
GO
/****** Object:  ForeignKey [FK_Questionnaire_Status]    Script Date: 09/15/2011 23:22:43 ******/
ALTER TABLE [dbo].[Questionnaires]  WITH CHECK ADD  CONSTRAINT [FK_Questionnaire_Status] FOREIGN KEY([StatusId])
REFERENCES [dbo].[Status] ([StatusId])
GO
ALTER TABLE [dbo].[Questionnaires] CHECK CONSTRAINT [FK_Questionnaire_Status]
GO
/****** Object:  ForeignKey [FK_ServiceCenter_Questionnaire]    Script Date: 09/15/2011 23:22:43 ******/
ALTER TABLE [dbo].[ServiceCenters]  WITH CHECK ADD  CONSTRAINT [FK_ServiceCenter_Questionnaire] FOREIGN KEY([QuestionnaireId])
REFERENCES [dbo].[Questionnaires] ([QuestionnaireId])
GO
ALTER TABLE [dbo].[ServiceCenters] CHECK CONSTRAINT [FK_ServiceCenter_Questionnaire]
GO
/****** Object:  ForeignKey [FK_Technician_Questionnaire]    Script Date: 09/15/2011 23:22:43 ******/
ALTER TABLE [dbo].[Technicians]  WITH CHECK ADD  CONSTRAINT [FK_Technician_Questionnaire] FOREIGN KEY([QuestionnaireId])
REFERENCES [dbo].[Questionnaires] ([QuestionnaireId])
GO
ALTER TABLE [dbo].[Technicians] CHECK CONSTRAINT [FK_Technician_Questionnaire]
GO
