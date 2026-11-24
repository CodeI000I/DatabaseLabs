
CREATE DATABASE Lab5DB
ON PRIMARY (
    NAME = 'Lab5DB_data',
    FILENAME = '/var/opt/mssql/data/Lab5DB.mdf',
    SIZE = 10MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 5MB
)

LOG ON (
    NAME = 'Lab5DB_log',
    FILENAME = '/var/opt/mssql/data/Lab5DB.ldf',
    SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB
);

GO
USE Lab5DB;
GO
CREATE TABLE dbo.Player (
    PlayerUUID UNIQUEIDENTIFIER NOT NULL 
    CONSTRAINT Player_PK PRIMARY KEY,

    Username VARCHAR(16) NOT NULL
    CONSTRAINT Player_Username_CK CHECK (
        LEN(Username) BETWEEN 3 AND 16
        AND (Username COLLATE Latin1_General_100_BIN2) NOT LIKE '%[^A-Za-z0-9_]%'
    ),

    FirstSeenAt DATETIME2(0) NOT NULL
    CONSTRAINT Player_FirstSeenAt_DF DEFAULT (SYSUTCDATETIME()),

    LastSeenAt DATETIME2(0) NOT NULL
    CONSTRAINT Player_LastSeenAt_DF DEFAULT (SYSUTCDATETIME()),

    RoleID TINYINT NOT NULL
    CONSTRAINT Player_RoleID_DF DEFAULT (1),
    -- CONSTRAINT Player_RoleID_FK FOREIGN KEY (RoleID) REFERENCES dbo.Role(RoleID)
    CONSTRAINT Player_LastSeenAt_CK CHECK (LastSeenAt >= FirstSeenAt)
);
GO
-- тест

SELECT name, create_date FROM sys.databases WHERE name = 'Lab5DB';
GO

SELECT name, create_date FROM sys.tables WHERE name = 'Player';
GO

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


CREATE TABLE dbo.World (
    WorldID SMALLINT NOT NULL IDENTITY(1,1)
    CONSTRAINT World_PK PRIMARY KEY,

    WorldName VARCHAR(64) NOT NULL
    CONSTRAINT World_WorldName_AK UNIQUE,   

    Seed BIGINT NOT NULL,

    GameMode TINYINT NOT NULL
    CONSTRAINT World_GameMode_DF DEFAULT(0)
    CONSTRAINT World_GameMode_CK CHECK(GameMode BETWEEN 0 AND 3),

    BorderSize INT NOT NULL
    CONSTRAINT World_BorderSize_DF DEFAULT(59999968)
    CONSTRAINT World_BorderSize_CK CHECK(BorderSize BETWEEN 1 AND 59999968),

    Dimension TINYINT NOT NULL
    CONSTRAINT World_Dimension_DF DEFAULT(0)
    CONSTRAINT World_Dimension_CK CHECK(Dimension BETWEEN 0 AND 2)
);

-- тест
SELECT name, create_date FROM sys.tables WHERE name = 'World';
GO


DROP TABLE dbo.World;
GO
ALTER DATABASE Lab5DB MODIFY FILEGROUP [PRIMARY] DEFAULT;
GO
ALTER DATABASE Lab5DB REMOVE FILE Lab5FG_additional;
GO
ALTER DATABASE Lab5DB REMOVE FILEGROUP Lab5FG;
GO


--тест
SELECT name, create_date FROM sys.tables WHERE name = 'World';
GO
SELECT name, data_space_id, is_default FROM sys.filegroups WHERE name = 'Lab5FG';
GO
SELECT name, type_desc FROM sys.database_files WHERE name = 'Lab5FG_additional';
GO

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