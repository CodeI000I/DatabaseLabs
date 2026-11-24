ALTER DATABASE Lab5DB ADD FILEGROUP Lab5FG;
GO
ALTER DATABASE Lab5DB ADD FILE (
    NAME = 'Lab5FG_additional',
    FILENAME = '/var/opt/mssql/data/Lab5FG_additional.ndf',
    SIZE = 5MB,
    MAXSIZE = 10MB,
    FILEGROWTH = 5MB
) TO FILEGROUP Lab5FG;
GO
ALTER DATABASE Lab5DB MODIFY FILEGROUP Lab5FG DEFAULT;
GO

--тест
USE Lab5DB;
GO
SELECT name, data_space_id, is_default FROM sys.filegroups WHERE name = 'Lab5FG';
GO
SELECT name, type_desc FROM sys.database_files WHERE name = 'Lab5FG_additional';
GO
