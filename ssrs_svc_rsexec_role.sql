USE [master]
GO
CREATE USER [NT AUTHORITY\NETWORK SERVICE] FOR LOGIN [NT AUTHORITY\NETWORK SERVICE]
GO
USE [master]
GO
ALTER ROLE [RSExecRole] ADD MEMBER [NT AUTHORITY\NETWORK SERVICE]
GO
USE [msdb]
GO
CREATE USER [NT AUTHORITY\NETWORK SERVICE] FOR LOGIN [NT AUTHORITY\NETWORK SERVICE]
GO
USE [msdb]
GO
ALTER ROLE [RSExecRole] ADD MEMBER [NT AUTHORITY\NETWORK SERVICE]
GO
USE [msdb]
GO
ALTER ROLE [SQLAgentOperatorRole] ADD MEMBER [NT AUTHORITY\NETWORK SERVICE]
GO
USE [msdb]
GO
ALTER ROLE [SQLAgentReaderRole] ADD MEMBER [NT AUTHORITY\NETWORK SERVICE]
GO
USE [msdb]
GO
ALTER ROLE [SQLAgentUserRole] ADD MEMBER [NT AUTHORITY\NETWORK SERVICE]
GO
USE [ReportServer]
GO
CREATE USER [NT AUTHORITY\NETWORK SERVICE] FOR LOGIN [NT AUTHORITY\NETWORK SERVICE]
GO
USE [ReportServer]
GO
ALTER ROLE [db_owner] ADD MEMBER [NT AUTHORITY\NETWORK SERVICE]
GO
USE [ReportServer]
GO
ALTER ROLE [RSExecRole] ADD MEMBER [NT AUTHORITY\NETWORK SERVICE]
GO
USE [ReportServerTempDB]
GO
CREATE USER [NT AUTHORITY\NETWORK SERVICE] FOR LOGIN [NT AUTHORITY\NETWORK SERVICE]
GO
USE [ReportServerTempDB]
GO
ALTER ROLE [db_owner] ADD MEMBER [NT AUTHORITY\NETWORK SERVICE]
GO
USE [ReportServerTempDB]
GO
ALTER ROLE [RSExecRole] ADD MEMBER [NT AUTHORITY\NETWORK SERVICE]
GO