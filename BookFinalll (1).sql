


IF OBJECT_ID('Books_Raw', 'U') IS NOT NULL
    DROP TABLE Books_Raw;
GO

CREATE TABLE Books_Raw (
    Line NVARCHAR(MAX)  -- ???? ??? ???? ???
);
GO

-- ?????? ???????
IF OBJECT_ID('Books', 'U') IS NOT NULL
    DROP TABLE Books;
GO

CREATE TABLE Books (
    BookID INT IDENTITY(1,1) PRIMARY KEY,
    BookTitle NVARCHAR(500),
    Price FLOAT NULL,
    Availability INT NULL,
    Rating INT NULL,
    ImageURL NVARCHAR(1000),
    BookLink NVARCHAR(1000),
    Category NVARCHAR(255),
    BookTitle_Cleaned NVARCHAR(500),
    Price_Normalized FLOAT NULL,
    Category_Encoded FLOAT NULL
);
GO

-- ????? ???????? (???? ?????????? , )
INSERT INTO Books (BookTitle, Price, Availability, Rating, ImageURL, BookLink, Category, BookTitle_Cleaned, Price_Normalized, Category_Encoded)
SELECT
    PARSENAME(REPLACE(Line, ',', '.'), 11),           -- BookTitle
    TRY_CAST(PARSENAME(REPLACE(Line, ',', '.'), 10) AS FLOAT), -- Price
    TRY_CAST(PARSENAME(REPLACE(Line, ',', '.'), 9) AS INT),    -- Availability
    TRY_CAST(PARSENAME(REPLACE(Line, ',', '.'), 8) AS INT),    -- Rating
    PARSENAME(REPLACE(Line, ',', '.'), 7),            -- ImageURL
    PARSENAME(REPLACE(Line, ',', '.'), 6),            -- BookLink
    PARSENAME(REPLACE(Line, ',', '.'), 5),            -- Category
    PARSENAME(REPLACE(Line, ',', '.'), 4),            -- BookTitle_Cleaned
    TRY_CAST(PARSENAME(REPLACE(Line, ',', '.'), 3) AS FLOAT), -- Price_Normalized
    TRY_CAST(PARSENAME(REPLACE(Line, ',', '.'), 2) AS FLOAT)  -- Category_Encoded
FROM Books_Raw;
GO

---- ??????
SELECT TOP 20 * FROM Books;





-- ???? 1: ????? Ad Hoc Distributed Queries (??? ????? ??)
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;

-- ???? 2: ????? ?????? ??????? ?????? ?? CSV
-- (Books_Final ?????? ?????? ?????????)
SELECT 
    BookTitle,
    Price,
    Availability,
    Rating,
    ImageURL,
    BookLink,
    Category,
    BookTitle_Cleaned,
    Price_Normalized,
    Category_Encoded
INTO Books_Final
FROM OPENROWSET(
    BULK 'C:\Book_multisources_clean.csv',
    FORMAT = 'CSV',
    FIRSTROW = 2,
    CODEPAGE = '65001'
) AS Data;
GO

-- ??????
SELECT TOP 20 * FROM Books_Final;


-- ???? 3: ??????? ??? 20 ?? ??????
SELECT TOP 20 * FROM Books_Final;



-- 1. ???? ???? ???????
IF OBJECT_ID('Books_Staging', 'U') IS NOT NULL
    DROP TABLE Books_Staging;
GO

CREATE TABLE Books_Staging (
    BookTitle NVARCHAR(500),
    Price NVARCHAR(50),
    Availability NVARCHAR(50),
    Rating NVARCHAR(50),
    ImageURL NVARCHAR(1000),
    BookLink NVARCHAR(1000),
    Category NVARCHAR(255),
    BookTitle_Cleaned NVARCHAR(500),
    Price_Normalized NVARCHAR(50),
    Category_Encoded NVARCHAR(50)
);
GO

-- 2. ??????? ??????
BULK INSERT Books_Staging
FROM 'C:\Book_multisources_clean.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);
GO

-- 3. ?????? ???????
IF OBJECT_ID('Books_Final', 'U') IS NOT NULL
    DROP TABLE Books_Final;
GO

CREATE TABLE Books_Final (
    BookID INT IDENTITY(1,1) PRIMARY KEY,
    BookTitle NVARCHAR(500),
    Price FLOAT NULL,
    Availability INT NULL,
    Rating INT NULL,
    ImageURL NVARCHAR(1000),
    BookLink NVARCHAR(1000),
    Category NVARCHAR(255),
    BookTitle_Cleaned NVARCHAR(500),
    Price_Normalized FLOAT NULL,
    Category_Encoded FLOAT NULL
);
GO

-- 4. ??????? ?? ?????? ??????? ?????
INSERT INTO Books_Final (BookTitle, Price, Availability, Rating, ImageURL, BookLink, Category, BookTitle_Cleaned, Price_Normalized, Category_Encoded)
SELECT 
    BookTitle,
    TRY_CAST(Price AS FLOAT),
    TRY_CAST(Availability AS INT),
    TRY_CAST(Rating AS INT),
    ImageURL,
    BookLink,
    Category,
    BookTitle_Cleaned,
    TRY_CAST(Price_Normalized AS FLOAT),
    TRY_CAST(Category_Encoded AS FLOAT)
FROM Books_Staging;
GO

-- 5. ??????
SELECT TOP 20 * FROM Books_Final;
CREATE DATABASE BOOK;
GO
USE BOOK;
GO
SELECT TOP 20 * 
FROM Books_Final;


