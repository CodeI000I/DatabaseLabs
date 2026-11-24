USE Lab5DB;
GO

CREATE SCHEMA LabSchema;
GO
ALTER SCHEMA LabSchema TRANSFER dbo.Player;
GO

--тест
SELECT name, schema_id FROM sys.schemas WHERE name = 'LabSchema'
SELECT OBJECT_SCHEMA_NAME(OBJECT_ID('LabSchema.Player')) AS SchemaName;
GO

ALTER SCHEMA dbo TRANSFER LabSchema.Player;
GO
DROP SCHEMA LabSchema;
GO

--тест
SELECT name, schema_id FROM sys.schemas WHERE name = 'LabSchema'
SELECT OBJECT_SCHEMA_NAME(OBJECT_ID('Player')) AS SchemaName;
GO