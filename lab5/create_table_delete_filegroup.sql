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