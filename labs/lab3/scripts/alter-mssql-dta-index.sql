USE msdb;
GO

-- Check if the column is currently NOT NULL
-- Then alter it to allow NULLs so the INSERT stop failing
ALTER TABLE [dbo].[DTA_reports_index] 
ALTER COLUMN [FilterDefinition] [nvarchar](max) NULL;
GO