
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

-- docker exec -it sql-lab /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "<iu9_student>" -C
-- docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=<iu9_student>" -p 1433:1433 --name sql-lab -d mcr.microsoft.com/mssql/server:2022-latest