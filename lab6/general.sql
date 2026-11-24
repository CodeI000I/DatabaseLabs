CREATE DATABASE Lab6DB
ON PRIMARY (
    NAME = 'Lab6DB_data',
    FILENAME = '/var/opt/mssql/data/Lab6DB.mdf',
    SIZE = 10MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 5MB
)
LOG ON (
    NAME = 'Lab6DB_log',
    FILENAME = '/var/opt/mssql/data/Lab6DB.ldf',
    SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB
);
GO
USE Lab6DB;
GO


-- 1
CREATE TABLE dbo.World (
    WorldID SMALLINT NOT NULL IDENTITY(1,1)
    CONSTRAINT World_PK PRIMARY KEY,

    WorldName VARCHAR(64) NOT NULL
    CONSTRAINT World_WorldName_AK UNIQUE,

    Seed BIGINT NOT NULL
);
GO

-- SCOPE_IDENTITY - текущая сессия и область видимости, не реагирует на тригеры
-- @@identity - текущая сессия и любая облать видимости, включая тригеры 
-- ident-current - конкретная таблица


INSERT INTO dbo.World (WorldName, Seed) VALUES ('world', -4172144997902289642);
SELECT SCOPE_IDENTITY(), @@IDENTITY, IDENT_CURRENT('dbo.World');
GO
SELECT SCOPE_IDENTITY(), @@IDENTITY, IDENT_CURRENT('dbo.World');
INSERT INTO dbo.World (WorldName, Seed) VALUES ('world_nether', -4172144997902289642);

INSERT INTO dbo.World (WorldName, Seed) VALUES ('world_the_end', -4172144997902289642), ('creative', 1234567890);
SELECT SCOPE_IDENTITY(), @@IDENTITY, IDENT_CURRENT('dbo.World');
GO
SELECT WorldID, WorldName FROM dbo.World ORDER BY WorldID;


-- 2

ALTER TABLE dbo.World ADD
    GameMode TINYINT NOT NULL
    CONSTRAINT World_GameMode_DF DEFAULT(0)
    CONSTRAINT World_GameMode_CK CHECK(GameMode BETWEEN 0 AND 3),

    BorderSize INT NOT NULL
    CONSTRAINT World_BorderSize_DF DEFAULT(59999968)
    CONSTRAINT World_BorderSize_CK CHECK(BorderSize BETWEEN 1 AND 59999968),

    Dimension TINYINT NOT NULL
    CONSTRAINT World_Dimension_DF DEFAULT(0)
    CONSTRAINT World_Dimension_CK CHECK(Dimension BETWEEN 0 AND 2);
GO


-- 3
CREATE TABLE dbo.Player (
    PlayerUUID UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL
    CONSTRAINT Player_PK PRIMARY KEY
    CONSTRAINT Player_PlayerUUID_DF DEFAULT (NEWID()),

    Username VARCHAR(16) NOT NULL
    CONSTRAINT Player_Username_CK CHECK (LEN(Username) BETWEEN 3 AND 16 AND (Username COLLATE Latin1_General_100_BIN2) NOT LIKE '%[^A-Za-z0-9_]%'),

    FirstSeenAt DATETIME2(0) NOT NULL
    CONSTRAINT Player_FirstSeenAt_DF DEFAULT (SYSUTCDATETIME()),

    LastSeenAt DATETIME2(0) NOT NULL
    CONSTRAINT Player_LastSeenAt_DF DEFAULT (SYSUTCDATETIME()),

    RoleID TINYINT NOT NULL
    CONSTRAINT Player_RoleID_DF DEFAULT (1),

    CONSTRAINT Player_LastSeenAt_CK CHECK (LastSeenAt >= FirstSeenAt)
);
GO



-- 4
CREATE SEQUENCE dbo.RoleSeq AS TINYINT 
    START WITH 1 
    INCREMENT BY 1 
    MINVALUE 1 MAXVALUE 255 
    NO CYCLE -- после достижения 255 останавливаемся 
    NO CACHE; -- каждый вызов next value пишет в журнал транзакций и на диск

GO
CREATE TABLE dbo.Role (
    RoleID TINYINT NOT NULL 
    CONSTRAINT Role_PK PRIMARY KEY 
    CONSTRAINT Role_RoleID_DF DEFAULT (NEXT VALUE FOR dbo.RoleSeq),
    
    RoleName VARCHAR(32) NOT NULL 
    CONSTRAINT Role_RoleName_AK UNIQUE,
    
    RolePriority SMALLINT NOT NULL 
    CONSTRAINT Role_RolePriority_AK UNIQUE 
    CONSTRAINT Role_RolePriority_CK CHECK (RolePriority >= 0),
    
    ChatPrefix NVARCHAR(32) NOT NULL
);
GO

SELECT
    name,
    CAST(start_value     AS TINYINT) AS start_value,
    CAST(increment       AS TINYINT) AS increment,
    CAST(minimum_value   AS TINYINT) AS minimum_value,
    CAST(maximum_value   AS TINYINT) AS maximum_value,
    is_cycling 
FROM sys.sequences;
GO

SELECT name, definition FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID('dbo.Role');
GO


-- 5
INSERT INTO dbo.Role (RoleName, RolePriority, ChatPrefix)
VALUES ('User', 0, '[User]'), ('Admin', 10, '[Admin]');

INSERT INTO dbo.Player (Username, RoleID) VALUES ('alice', 1);
INSERT INTO dbo.Player (Username, RoleID) VALUES ('bob', 2);


-- no action
ALTER TABLE dbo.Player ADD CONSTRAINT Player_RoleID_FK
    FOREIGN KEY (RoleID) REFERENCES dbo.Role (RoleID)
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION;

DELETE FROM dbo.Role WHERE RoleID = 2;
ALTER TABLE dbo.Player DROP CONSTRAINT Player_RoleID_FK;

-- ошибка и ничего не изменилось


--cascade
ALTER TABLE dbo.Player ADD CONSTRAINT Player_RoleID_FK
    FOREIGN KEY (RoleID) REFERENCES dbo.Role (RoleID)
    ON DELETE CASCADE 
    ON UPDATE CASCADE;

DELETE FROM dbo.Role WHERE RoleID = 2;
SELECT Username, RoleID FROM dbo.Player;
ALTER TABLE dbo.Player DROP CONSTRAINT Player_RoleID_FK;
INSERT INTO dbo.Player (Username, RoleID) VALUES ('bob', 1);

-- удалился боб как админ, вернули как пользователя, админа как роли нет


--set null
ALTER TABLE dbo.Player DROP CONSTRAINT Player_RoleID_DF;
ALTER TABLE dbo.Player ALTER COLUMN RoleID TINYINT NULL;
ALTER TABLE dbo.Player ADD CONSTRAINT Player_RoleID_FK
    FOREIGN KEY (RoleID) REFERENCES dbo.Role (RoleID)
    ON DELETE SET NULL 
    ON UPDATE SET NULL;

UPDATE dbo.Role SET RoleID = 2 WHERE RoleID = 1;  -- user.roleid = 2
SELECT Username, RoleID FROM dbo.Player;          
ALTER TABLE dbo.Player DROP CONSTRAINT Player_RoleID_FK;

UPDATE dbo.Player SET RoleID = 2 WHERE RoleID IS NULL;   
ALTER TABLE dbo.Player ALTER COLUMN RoleID TINYINT NOT NULL;
ALTER TABLE dbo.Player ADD CONSTRAINT Player_RoleID_DF DEFAULT (2) FOR RoleID;

INSERT INTO dbo.Role (RoleName, RolePriority, ChatPrefix)
VALUES ('Admin', 10, '[Admin]');
UPDATE dbo.Player SET RoleID = 3 WHERE Username = 'bob';

-- хотели обновить боба и алису до админов (которых нет), их роли стали нул, затем вернулись как пользователи с roleid=2,
-- вернули админа как роль с roleid=3 и сделали боба админов

--set def
ALTER TABLE dbo.Player ADD CONSTRAINT Player_RoleID_FK
    FOREIGN KEY (RoleID) REFERENCES dbo.Role (RoleID)
    ON DELETE SET DEFAULT 
    ON UPDATE SET DEFAULT;

DELETE FROM dbo.Role WHERE RoleID = 3;   
SELECT Username, RoleID FROM dbo.Player; 
ALTER TABLE dbo.Player DROP CONSTRAINT Player_RoleID_FK;

-- удалили роль админа, боб стал по умолчанию пользователем c roleid=2