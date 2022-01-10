------------------------------------------------------------- 
-- Olika typer av joins 
-- Se https://www.codeproject.com/KB/database/Visual_SQL_Joins/Visual_SQL_JOINS_orig.jpg 
------------------------------------------------------------- 
DECLARE @personer TABLE (PersonId INT, Namn NVARCHAR(20)) 
DECLARE @telefonnummer TABLE (PersonId INT, Telefonnummer NVARCHAR(20)) 
  
INSERT INTO @personer (PersonId, Namn) 
VALUES (1, 'Kalle'), (2, 'Lisa') 
  
INSERT INTO @telefonnummer (PersonId, Telefonnummer) 
VALUES (2, '08-123456'), (3, '09-8887777') 
  
-- LEFT JOIN 
SELECT * 
FROM @personer s0 
LEFT JOIN @telefonnummer s1 ON s0.PersonId = s1.PersonId 
  
-- RIGHT JOIN 
SELECT * 
FROM @personer s0 
RIGHT JOIN @telefonnummer s1 ON s0.PersonId = s1.PersonId 
  
-- INNER JOIN 
SELECT * 
FROM @personer s0 
INNER JOIN @telefonnummer s1 ON s0.PersonId = s1.PersonId 
  
-- FULL OUTER JOIN 
SELECT * 
FROM @personer s0 
FULL OUTER JOIN @telefonnummer s1 ON s0.PersonId = s1.PersonId 
  
-- CROSS JOIN (Cartesian product) 
SELECT * 
FROM @personer s0 
CROSS JOIN @telefonnummer s1 
  
  
------------------------------------------------------------- 
-- Placering av JOIN-villkor 
------------------------------------------------------------- 
DECLARE @i TABLE (n CHAR(1)) 
DECLARE @j TABLE (n CHAR(1)) 
  
INSERT INTO @i (n) VALUES ('A'), ('B'), ('C'), (NULL) 
INSERT INTO @j (n) VALUES ('B'), ('C'), ('D'), (NULL) 
  
-- Vanlig JOIN 
SELECT * 
FROM @i i 
LEFT JOIN @j j ON i.n = j.n 
  
-- IS NULL i WHERE 
SELECT * 
FROM @i i 
LEFT JOIN @j j ON i.n = j.n 
WHERE j.n IS NULL 
  
-- IS NULL i ON 
SELECT * 
FROM @i i 
LEFT JOIN @j j ON i.n = j.n AND j.n IS NULL 
  
  
------------------------------------------------------------- 
-- UNION, EXCEPT och INTERSECT (och ALL, ALL stöjds 
-- bara tillsammans med UNION i SQL Server) 
-- Se https://cf.ppt-online.org/files/slide/l/lmSqhVrJxEXL6MaORPWyItDAjKwU8uceHCvzpY/slide-10.jpg 
------------------------------------------------------------- 
DECLARE @t6_0 TABLE (värde0 NVARCHAR(255)) 
DECLARE @t6_1 TABLE (värde1 NVARCHAR(255)) 
  
INSERT INTO @t6_0 (värde0) VALUES ('AA'), ('BB') 
INSERT INTO @t6_1 (värde1) VALUES ('BB'), ('CC') 
  
--SELECT * FROM @t6_0 
--SELECT * FROM @t6_1 
  
-- Allt, fast bara en gång 
SELECT * FROM @t6_0 
UNION 
SELECT * FROM @t6_1 
  
-- Allt 
SELECT * FROM @t6_0 
UNION ALL 
SELECT * FROM @t6_1 
  
-- Allt i 0 förutom det som även finns i 1 
SELECT * FROM @t6_0 
EXCEPT 
SELECT * FROM @t6_1 
  
-- Värden som ligger i båda 
SELECT * FROM @t6_0 
INTERSECT 
SELECT * FROM @t6_1 
  
  
------------------------------------------------------------- 
-- Inserts 
------------------------------------------------------------- 
-- Values 
DECLARE @s2 TABLE (Värde NVARCHAR(20)) 
INSERT INTO @s2 (Värde) 
VALUES ('A'), ('B') 
  
-- Select 
DECLARE @s3 TABLE (Värde NVARCHAR(20)) 
INSERT INTO @s3 (Värde) 
SELECT Värde FROM @s2 WHERE Värde = 'A' 
  
SELECT * FROM @s3 
  
  
------------------------------------------------------------- 
-- Update och delete 
------------------------------------------------------------- 
-- Update 
DECLARE @u0 TABLE (Värde NVARCHAR(20), Uppdaterad BIT) 
DECLARE @u1 TABLE (Värde NVARCHAR(20)) 
  
INSERT INTO @u0 (Värde) 
VALUES ('A'), ('B') 
  
INSERT INTO @u1 (Värde) 
VALUES ('B'), ('C') 
  
UPDATE u0 
SET u0.Uppdaterad = 1 
FROM @u0 AS u0 
INNER JOIN @u1 AS u1 ON u0.Värde = u1.Värde 
  
SELECT * FROM @u0 
  
DELETE u1 
FROM @u0 AS u0 
INNER JOIN @u1 AS u1 ON u0.Värde = u1.Värde 
  
SELECT * FROM @u1 
  
  
------------------------------------------------------------- 
-- Temptabeller, tabellvariabler och variabler 
------------------------------------------------------------- 
-- Tabellvariabel, lever endast i en batch 
DECLARE @f0 TABLE (Värde NVARCHAR(20)) 
  
-- Lokal temptabell, kan endast när från denna session 
CREATE TABLE #f0 (Värde NVARCHAR(20)) 
  
-- Global temptabell, kan nås från andra sessioner men försvinner när denna session avslutas 
CREATE TABLE ##f0 (Värde NVARCHAR(20)) 
  
-- Det går att skapa en tabell från befintligt data 
SELECT * 
INTO #f1 
FROM @f0 
  
-- Städa alltid 
DROP TABLE #f0 
DROP TABLE ##f0 
DROP TABLE #f1 
  
-- Vanlig variabel 
DECLARE @nu DATETIME = GETDATE() 
SELECT CONVERT(NVARCHAR(16), @nu, 121) 
  
  
------------------------------------------------------------- 
-- Index 
------------------------------------------------------------- 
CREATE TABLE #I1 ( 
    Id INT IDENTITY(1,10), 
    Värde1 UNIQUEIDENTIFIER DEFAULT NEWSEQUENTIALID(), 
    Värde2 NVARCHAR(20), 
    Värde3 NVARCHAR(20)) 
  
INSERT INTO #I1 DEFAULT VALUES 
INSERT INTO #I1 DEFAULT VALUES 
INSERT INTO #I1 DEFAULT VALUES 
INSERT INTO #I1 DEFAULT VALUES 
INSERT INTO #I1 (Värde2, Värde3) VALUES ('A', 'A'), ('B', 'B') 
INSERT INTO #I1 (Värde2, Värde3) VALUES ('A', 'A'), ('B', 'B') 
  
SELECT * FROM #I1 
  
CREATE UNIQUE CLUSTERED INDEX #IX_I1_Id ON #I1 (Id) 
CREATE UNIQUE INDEX #IX_I1_Id2 ON #I1 (Värde1) 
  
CREATE INDEX #IX_I1_Värde ON #I1 (Värde2) INCLUDE (Värde3) WHERE Värde2 IS NOT NULL 
  
SELECT Värde1 FROM #I1 WHERE Värde2 = 'A' -- Clustered Index Scan (Är inte tillräckligt effektivt att leta i först indexet och sedan gå till tabellen jämför med att söka direkt i tabellen) 
SELECT Värde3 FROM #I1 WHERE Värde2 = 'A' -- Index Seek (eftersom vi valt include för Värde3) 
SELECT Id FROM #I1 WHERE Värde2 = 'A' -- Index Seek (eftersom PRIMARY KEY alltid är med i ett index) 
  
DROP TABLE #I1 
  
  
------------------------------------------------------------- 
-- Nycklar 
------------------------------------------------------------- 
USE tempdb 
BEGIN TRAN 
    CREATE TABLE dbo.n1 (Id INT IDENTITY(1,1) PRIMARY KEY) 
    CREATE TABLE dbo.n2 (fk_N1 INT REFERENCES dbo.n1(Id)) 
  
    INSERT INTO n1 DEFAULT VALUES 
    INSERT INTO n2 VALUES (1) 
  
    -- Drop i omvänd ordning eftersom n2 pekar på n1 
    DROP TABLE dbo.n2 
    DROP TABLE dbo.n1 
ROLLBACK 
  
  
------------------------------------------------------------- 
-- Alter table 
------------------------------------------------------------- 
BEGIN TRAN 
    CREATE TABLE #a1 (Id INT) 
    INSERT INTO #a1    (Id) VALUES (1), (2), (3) 
             
    -- Lägg till två kolumer 
    ALTER TABLE #a1 ADD Värde NVARCHAR(20) 
    ALTER TABLE #a1 ADD Värde2 NVARCHAR(20) NOT NULL DEFAULT 'A' 
  
    ALTER TABLE #a1 ALTER COLUMN Värde NVARCHAR(200) 
  
    SELECT * FROM #a1 
  
    -- Ta bort en kolumn 
    ALTER TABLE #a1 DROP COLUMN Id 
  
    SELECT * FROM #a1 
  
    DROP TABLE #a1 
ROLLBACK 
  
  
------------------------------------------------------------- 
-- Funktioner 
------------------------------------------------------------- 
DECLARE @dat1 DATE = '2016-02-06' 
SELECT @dat1 
  
SELECT DATEADD(YEAR, -1, @dat1) 
SELECT EOMONTH(@dat1) 
SELECT DATEADD(DAY, 1, EOMONTH(@dat1)) 
  
  
------------------------------------------------------------- 
-- Collation 
------------------------------------------------------------- 
DECLARE @c0 TABLE ( 
    VärdeCIAS NVARCHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS, -- case insensitive, accent sensitive 
    VärdeCSAS NVARCHAR(20) COLLATE SQL_Latin1_General_CP1_CS_AS, -- case sensitive, accent sensitive 
    VärdeCIAI NVARCHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AI) -- case insensitive, accent insensitive 
  
INSERT INTO @c0 (VärdeCSAS, VärdeCIAS, VärdeCIAI) 
VALUES ('å', 'å', 'å'), ('Å', 'Å', 'Å'), ('ä', 'ä', 'ä') 
  
SELECT * FROM @c0 c WHERE c.VärdeCIAS = 'Å' -- Både stora och små, endast Å 
SELECT * FROM @c0 c WHERE c.VärdeCSAS = 'Å' -- Endast stora, endast Å 
SELECT * FROM @c0 c WHERE c.VärdeCIAI = 'Å' -- Stora och små, alla varianter på A 
  
-- Går även att ange collation direkt vid fråga 
DECLARE @c1 TABLE (Värde NVARCHAR(20)) 
  
INSERT INTO @c1 (Värde) 
VALUES ('å'), ('Å'), ('ä') 
  
SELECT * FROM @c1 c WHERE c.Värde = 'Å' COLLATE SQL_Latin1_General_CP1_CS_AS -- Endast Å 
SELECT * FROM @c1 c WHERE c.Värde = 'Å' COLLATE SQL_Latin1_General_CP1_CI_AI -- Alla varianter på a och A 
  
-- För tabellvariabler används den collation som frågan körs i, för temptabeller så används tempdbs collation 
-- Se collation för olika databaser 
SELECT name, collation_name FROM sys.databases; 
  
  
------------------------------------------------------------- 
-- Transaktioner 
------------------------------------------------------------- 
DECLARE @tr1 TABLE (Värde NVARCHAR(20)) 
CREATE TABLE #tr1 (Värde NVARCHAR(20)) 
  
INSERT INTO @tr1 VALUES ('A') 
INSERT INTO #tr1 VALUES ('B') 
  
-- Värde från båda tabellerna 
SELECT * FROM @tr1 
UNION ALL 
SELECT * FROM #tr1 
  
BEGIN TRAN [Min transaktion] 
    UPDATE @tr1 SET Värde = 'A1' 
    UPDATE #tr1 SET Värde = 'B1' 
  
    -- Värden uppdaterade 
    SELECT * FROM @tr1 
    UNION ALL 
    SELECT * FROM #tr1 
  
-- Rullar tillbaks transaktionen 
-- COMMIT sparar transaktionen 
ROLLBACK 
  
-- Värde i #tr1 har rullats tillbaks 
SELECT * FROM @tr1 
UNION ALL 
SELECT * FROM #tr1 
  
-- Rensa 
DROP TABLE #tr1 
  
-- Det går att namnge transaktionen för enklare felsökning 
DECLARE @namn NVARCHAR(20) = 'Min transaktion' 
  
BEGIN TRAN @namn 
    SELECT * FROM sys.dm_tran_active_transactions 
COMMIT 
  
------------------------------------------------------------- 
-- Index på tabellvariabler 
------------------------------------------------------------- 
DECLARE @t0 TABLE ( 
    Värde1 INT, 
    Värde2 INT, 
    Värde3 INT, 
    PRIMARY KEY(Värde1, Värde2), -- Blir ett index 
    UNIQUE (Värde2), -- Kommer också att fungera som ett index 
    UNIQUE CLUSTERED (Värde3), -- Kommer blir ett klustrat index (det vill säga i den ordning som raderna är sorterade på disk) 
    INDEX IX_1 (Värde1, Värde2), -- Går att göra från SQL Server 2014 
    INDEX IX_2_filtrerat (Värde1, Värde2) WHERE Värde1 IS NOT NULL) -- Går att göra från SQL Server 2016 
  
------------------------------------------------------------- 
-- Computed column 
------------------------------------------------------------- 
DECLARE @t1 TABLE ( 
    Värde1 INT, 
    Värde2 INT, 
    Summa AS Värde1 + Värde2 PERSISTED, -- Persisted innebär att det beräknade värdet sparas när raden sparas, ger snabbare select 
    Produkt AS Värde1 * Värde2) -- Utan persisted så sparas inte det beräknade värdet utan räknas fram i vid selecten, ger snabbare insert 
  
INSERT INTO @t1 (Värde1, Värde2) VALUES (2,10), (5,3) 
SELECT * FROM @t1 
  
-- Det krävs att en computed column är persisted för att det ska gå att skapa ett index på den 
  
  
------------------------------------------------------------- 
-- SELECT från VALUES() 
------------------------------------------------------------- 
SELECT 
    tabell.kolumn1, 
    tabell.kolumn2 
FROM (VALUES (1, 2), (3, 4)) AS tabell(kolumn1, kolumn2) 
  
  
------------------------------------------------------------- 
-- CROSS APPLY, används för att ge flera rader från en rad 
------------------------------------------------------------- 
DECLARE @t2 TABLE (Id INT IDENTITY(1,1), Värde NVARCHAR(10), Värde2 NVARCHAR(10)) 
INSERT INTO @t2 (Värde, Värde2) VALUES ('v1', 'v2'), ('v3', 'v4') 
  
SELECT * FROM @t2 
  
SELECT 
    t.Id, 
    t.Värde, 
    t.Värde2, 
    tabell.kolumn1, 
    tabell.kolumn2 
FROM @t2 t 
CROSS APPLY (VALUES ('X', t.Värde), ('Y', t.Värde2)) AS tabell(kolumn1, kolumn2) 
  
  
------------------------------------------------------------- 
-- Aggregatfunktioner, ROW_NUMBER() och SUM() OVER() 
------------------------------------------------------------- 
DECLARE @t3 table (Datum DATE, BeloppTyp CHAR(1), Belopp INT) 
INSERT INTO @t3 (Datum, BeloppTyp, Belopp) 
VALUES 
    ('2017-01-01', 'A', 30), 
    ('2017-02-01', 'A', 5), 
    ('2017-06-01', 'A', 20), 
    ('2017-02-05', 'B', 5), 
    ('2017-03-01', 'B', 10), 
    ('2017-07-12', 'B', 20), 
    ('2017-06-15', 'C', 40), 
    ('2017-08-01', 'C', 20), 
    ('2017-09-20', 'C', 20), 
    ('2017-12-11', 'C', 10) 
  
SELECT 
    t.BeloppTyp, 
    t.Datum,     
    ROW_NUMBER() OVER(PARTITION BY t.BeloppTyp ORDER BY t.Datum) AS RadnummerGrupp, -- Radnummer per grupp 
    t.Belopp, 
    SUM(Belopp) OVER(PARTITION BY t.BeloppTyp ORDER BY t.Datum) AS AckSummaGrupp -- Ackumulerad summa per grupp, sortering enligt Id 
FROM @t3 t 
ORDER BY t.BeloppTyp, t.Datum 
  
  
------------------------------------------------------------- 
-- CTE (Common table expression) som använder andra CTEs 
------------------------------------------------------------- 
;WITH n1 AS (SELECT NULL AS n FROM (VALUES (0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) AS a(n)), -- SELECT * FROM n1 ger 10 rader med nollor 
n2 AS (SELECT NULL n FROM n1 a CROSS JOIN n1 b), -- Ger 10*10 rader med NULL 
n4 AS (SELECT NULL n FROM n2 a CROSS JOIN n2 b) -- Ger (10*10)*(10*10) rader med NULL 
  
,radnummer AS ( 
    SELECT 
        ROW_NUMBER() OVER(ORDER BY n) rownum -- Radnummer (sortering av NULL-värden med detta spelar ingen roll) 
    FROM n4) 
     
-- Alla datum under 2016 
SELECT DATEADD(DAY, rownum - 1, CAST('2016-01-01' AS DATE)) AS Datum 
FROM radnummer 
WHERE rownum BETWEEN 0 AND 366 
  
  
------------------------------------------------------------- 
-- LAG/LEAD, vi skapar här tre perioder utifrån fyra datum 
------------------------------------------------------------- 
DECLARE @t4 TABLE (Id INT IDENTITY(1,1), Dat DATE) 
INSERT INTO @t4 (Dat) VALUES ('2016-01-01'), ('2016-03-05'), ('2016-08-07'), ('2016-12-31') 
  
SELECT 
    a.Dat AS FromDat, 
    LEAD(a.Dat, 1) OVER(ORDER BY a.Dat) AS TomDat -- Dat-värdet från raden efter ", 1" innebär att vi går en rad framåt, LAG(xx, 1) hade gett värde från raden före 
FROM @t4 a 
  
;WITH perioder AS ( 
-- Vi använder datum och datum från raden efter (om det finns en rad efter) 
    SELECT 
        a.Dat AS FromDat, 
        LEAD(a.Dat, 1) OVER(ORDER BY Id) AS TomDat -- Dat-värdet från raden efter ", 1" innebär att vi går en rad framåt, LAG(xx, 1) hade gett värde från raden före 
    FROM @t4 a), 
  
fromDatJusterat AS ( 
-- Vi justerar TomDat 
    SELECT 
        IIF(ROW_NUMBER() OVER(ORDER BY FromDat) <> 1,    -- Om inte första raden 
            DATEADD(DAY, 1, a.FromDat),                    -- Öka på från-och-med-datumet med en dag 
            a.FromDat) AS FromDat,                        -- Annars använd FromDat 
        a.TomDat 
    FROM perioder a 
    WHERE a.TomDat IS NOT NULL), -- Vi är inte intresserade av sista raden (där TomDat är NULL), det sista datumet finns redan med på näst sista raden 
  
antalDagar AS ( 
-- Vi beräknar antal dagar per period 
    SELECT 
        a.FromDat, 
        a.TomDat, 
        DATEDIFF(DAY, a.FromDat, DATEADD(DAY, 1, a.TomDat)) AS PeriodDagar -- Lägg till en dag för att få inklusive första och sista 
    FROM fromDatJusterat a), -- Vi är inte intresserade av sista raden, det sista datumet finns redan med på näst sista raden 
  
antalDagarAck AS ( 
-- Vi beräknar antal dagar totalt 
    SELECT 
        a.FromDat, 
        a.TomDat, 
        a.PeriodDagar, 
        SUM(a.PeriodDagar) OVER(ORDER BY a.FromDat) DagarAck -- Dagar ackumulerat 
    FROM antalDagar a) 
  
SELECT * FROM antalDagarAck 
  
  
------------------------------------------------------------- 
-- OUTPUT 
------------------------------------------------------------- 
DECLARE @t5 TABLE (Id INT IDENTITY(1,1), Värde1 NVARCHAR(100)) 
DECLARE @output TABLE (Id INT, Värde1 NVARCHAR(100)) 
  
INSERT INTO @t5 
OUTPUT inserted.Id, inserted.Värde1 INTO @output (Id, Värde1) 
DEFAULT VALUES 
  
-- Rad utan värde, Id till output-tabell 
INSERT INTO @t5 (Värde1) 
OUTPUT inserted.Id, inserted.Värde1 INTO @output (Id, Värde1) 
VALUES ('v1') 
  
SELECT * FROM @output 
  
-- Output direkt 
UPDATE t 
SET t.Värde1 = 'v2' 
OUTPUT inserted.Värde1 AS NyttVärde, deleted.Värde1 AS BorttagetVärde 
FROM @t5 t 
WHERE t.Värde1 = 'v1' 
  
  
------------------------------------------------------------- 
-- XML 
------------------------------------------------------------- 
DECLARE @xmlvar XML 
  
;WITH xmlCTE AS ( 
    SELECT ( 
        SELECT 
            'attributText' AS [nivå4/@attribut1], -- <nivå4 attribut1="attributText" /> 
            'elementText5' AS [nivå4/nivå5], -- ger <nivå4><nivå5>elementText</nivå5></nivå4> -- Samma namn på nivå4 gör att elementet sammanfogas med ovanstående element 
            'elementText52' AS [nivå4/nivå52] -- ger <nivå4><nivå52>elementText</nivå52></nivå4> 
        FOR XML PATH('nivå3'), ROOT('nivå2'), TYPE) AS cteElementNamn) -- Ger <nivå2><nivå3>...</nivå3></nivå2> 
  
SELECT @xmlvar = ( 
    SELECT 
        x.cteElementNamn AS [nivå1], -- Ovanstående som <nivå1>...</nivå1> 
        'extraAttribut' AS [nivå1/nivå2Extra/@attribut2] -- Ger <nivå1><nivå2Extra attribut2="extraAttribut" /></nivå1> 
    FROM xmlCTE x 
    FOR XML PATH(''), ROOT('nivå0')) 
  
-- Blandade selects 
SELECT @xmlvar 
  
-- Funktioner 
SELECT 
    y.value('fn:local-name(..)', 'nvarchar(50)') rotNamn, 
    y.value('fn:local-name(.)', 'nvarchar(50)') elementNamn, 
    y.value('fn:upper-case(fn:local-name(.))', 'nvarchar(50)') elementNamn -- versaler 
FROM @xmlvar.nodes('/nivå0/nivå1') x(y) 
  
-- Olika nivåer 
SELECT 
    y.value('nivå2[1]/nivå3[1]/nivå4[1]/nivå5[1]', 'nvarchar(50)') elementVärde, 
    y.value('(nivå2[1]/nivå3[1]/nivå4[1]/nivå5[1]/text())[1]', 'nvarchar(50)') elementVärde -- Samma resultat men snabbare 
FROM @xmlvar.nodes('/nivå0/nivå1') x(y) 
  
-- CROSS APPLY 
SELECT 
    d.value('fn:local-name(.)', 'nvarchar(50)') elementNamn, 
    d.value('(text())[1]', 'nvarchar(50)') elementNamn2 
FROM @xmlvar.nodes('/nivå0/nivå1') AS nivå1(y) 
CROSS APPLY y.nodes('*/*/nivå4/*') AS n(d) 
  
  
------------------------------------------------------------- 
-- XML och JSON från tabeller 
------------------------------------------------------------- 
DECLARE @xpersoner TABLE (PersonId INT, Namn NVARCHAR(20)) 
INSERT INTO @xpersoner (PersonId, Namn) VALUES 
    (1, 'Lisa'), 
    (2, 'Kalle') 
  
DECLARE @xbelopp TABLE (PersonId INT, UtbetNr INT, Belopp INT) 
INSERT INTO @xbelopp (PersonId, UtbetNr, Belopp) VALUES 
    (1, 1, 200), 
    (1, 2, 300), 
    (1, 3, 400), 
    (2, 4, 50), 
    (2, 5, 60), 
    (2, 6, 70) 
  
-- XML 
SELECT 
    p.PersonId, 
    p.Namn, 
    ( 
        SELECT 
            t.UtbetNr, 
            t.Belopp 
        FROM @xbelopp t 
        WHERE t.PersonId = p.PersonId 
        FOR XML PATH ('Utbetalning'), ROOT('Utbetalningar'), TYPE 
    ) 
FROM @xpersoner p 
FOR XML PATH ('Person'), ROOT ('Personer') 
  
-- JSON 
SELECT 
    p.PersonId, 
    p.Namn, 
    ( 
        SELECT 
            t.UtbetNr AS [UtbetNr], 
            t.Belopp [Belopp] 
        FROM @xbelopp t 
        WHERE t.PersonId = p.PersonId 
        FOR JSON PATH 
    ) AS Utbetalning 
FROM @xpersoner p 
FOR JSON PATH, ROOT ('Person') 
  
  
------------------------------------------------------------- 
-- XSD 
------------------------------------------------------------- 
IF EXISTS (SELECT * FROM sys.xml_schema_collections WHERE name = 'XSD_Exempel_26DA0D8C') 
DROP XML SCHEMA COLLECTION dbo.XSD_Exempel_26DA0D8C 
GO 
  
-- Skapa XML-schema 
CREATE XML SCHEMA COLLECTION dbo.XSD_Exempel_26DA0D8C AS 
'<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema"> 
    <xs:element name="element1" type="xs:string"/> 
</xs:schema>' 
GO 
  
DECLARE @xmlMedSchema XML(dbo.XSD_Exempel_26DA0D8C) 
SELECT @xmlMedSchema = '<element1>hej</element1>' -- XML som passar schemat 
  
BEGIN TRY 
    SELECT @xmlMedSchema = '<fel>hej</fel>' -- Passar ej schemat, slänger ett fel 
END TRY 
BEGIN CATCH 
    PRINT 'Felaktig XML' 
END CATCH 
  
IF EXISTS (SELECT * FROM sys.xml_schema_collections WHERE name = 'XSD_Exempel_26DA0D8C') 
DROP XML SCHEMA COLLECTION dbo.XSD_Exempel_26DA0D8C 
GO 
  
  
------------------------------------------------------------- 
-- Query hints OPTION (RECOMPILE) 
------------------------------------------------------------- 
-- Tabell som vi gör select från 
DECLARE @s TABLE(Id INT NOT NULL PRIMARY KEY); 
  
-- n5 returnerar 10^5 rader 
;WITH n1 AS (SELECT NULL n FROM (VALUES (0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) a(n)), 
n2 AS (SELECT NULL n FROM n1 a CROSS JOIN n1 b), -- Ger 10*10 rader med NULL 
n5 AS (SELECT NULL n FROM n2 a CROSS JOIN n2 b CROSS JOIN n1 c) 
  
INSERT INTO @s (Id)    SELECT ROW_NUMBER() OVER (ORDER BY n.n) FROM n5 n 
  
DECLARE @s2 TABLE (Id INT) 
DECLARE @s3 TABLE (Id INT) 
  
-- Se skillnad i estimated number of rows 
DECLARE @start2 DATETIME = GETDATE() 
INSERT INTO @s3 (Id) 
    SELECT Id FROM @s 
SELECT 'Utan RECOMPILE', DATEDIFF(MILLISECOND, @start2, GETDATE()) 
  
DECLARE @start1 DATETIME = GETDATE() 
INSERT INTO @s2 (Id) 
    SELECT Id FROM @s 
    OPTION (RECOMPILE) 
SELECT 'Med RECOMPILE', DATEDIFF(MILLISECOND, @start1, GETDATE()) 
  
------------------------------------------------------------- 
-- MERGE 
------------------------------------------------------------- 
DECLARE @t7_0 TABLE (Id INT IDENTITY (1, 1), Värde NVARCHAR(255), A NVARCHAR(255)) 
DECLARE @t7_1 TABLE (Id INT IDENTITY (7, 1), Värde2 NVARCHAR(255), A NVARCHAR(255)) 
DECLARE @t7_output TABLE (Id_source INT, Id_target INT, Värde NVARCHAR(255), Värde2 NVARCHAR(255), Händelse NVARCHAR(255)) 
  
INSERT INTO @t7_0 (Värde) VALUES ('AA'), ('BB') 
INSERT INTO @t7_1 (Värde2) VALUES ('BB'), ('CC') 
  
;WITH source AS (SELECT * FROM @t7_0) 
MERGE 
INTO @t7_1 AS target 
USING source ON source.Värde = target.Värde2 
WHEN MATCHED THEN -- Uppdatera de som matchar (BB), fyller både inserted- och deleted-tabellerna 
    UPDATE 
    SET target.A = 'Uppdaterad' 
WHEN NOT MATCHED THEN -- Lägg till de som saknas som matchar (AA), fyller inserted-tabellen 
    INSERT (Värde2, A) 
    VALUES (source.Värde, 'Ny') 
WHEN NOT MATCHED BY SOURCE THEN DELETE -- Ta bort de som inte fanns i källan (CC), fyller deleted-tabellen 
OUTPUT source.Id, ISNULL(inserted.Id, deleted.Id), inserted.Värde2, deleted.Värde2, $action INTO @t7_output (Id_source, Id_target, Värde, Värde2, Händelse); 
  
SELECT * FROM @t7_0 
SELECT * FROM @t7_1 
SELECT * FROM @t7_output 
  
------------------------------------------------------------- 
-- Tömning av cache 
-- Se https://stackoverflow.com/a/382151/1398417 
------------------------------------------------------------- 
CHECKPOINT              -- Sparar alla modifierade sidor till disk 
DBCC DROPCLEANBUFFERS   -- Rensar minnet från alla sidor 
DBCC FREEPROCCACHE      -- Rensar procedurer från cache 
  
  
------------------------------------------------------------- 
-- Rensning av dubbletter med hjälp av CTE 
------------------------------------------------------------- 
DECLARE @d0 TABLE (Grupp NVARCHAR(255), ValidFrom DATE) 
  
INSERT INTO @d0 (Grupp, ValidFrom) VALUES 
    ('AA', '2017-01-01'), -- Denna vill vi ta bort 
    ('AA', '2017-06-01'), -- Denna vill vi ta bort 
    ('AA', '2018-01-01'), 
    ('BB', '2016-01-01'), 
    ('CC', '2013-01-01') 
  
SELECT * FROM @d0 
  
-- Vi vill ta bort allt utom de senaste värdena per grupp 
;WITH d AS ( 
    SELECT *, 
        ROW_NUMBER() OVER(PARTITION BY d.Grupp ORDER BY d.ValidFrom DESC) rownum 
    FROM @d0 d) 
DELETE FROM d WHERE d.rownum > 1 
  
SELECT * FROM @d0 
  
  
------------------------------------------------------------- 
-- Beräkning av PI med hjälp av Gregory-Leibniz serier 
-- PI = 4 * (1 - 1/3 + 1/5 - 1/7 + 1/9 ..) 
------------------------------------------------------------- 
  
;WITH n1 AS (SELECT NULL n FROM (VALUES (0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) a(n)) 
,n2 AS (SELECT NULL n FROM n1 a CROSS JOIN n1 b) -- Ger 10*10 rader med NULL 
,n5 AS (SELECT ROW_NUMBER() OVER (ORDER BY a.n) rownum FROM n2 a CROSS JOIN n2 b CROSS JOIN n1 c) 
,nx AS (SELECT rownum, CAST(IIF(rownum % 2 = 0, -1, 1) * (rownum * 2 - 1) AS DECIMAL(30,0)) AS num FROM n5) 
,accSum AS (SELECT rownum, SUM(4/num) OVER(ORDER BY rownum) as acc FROM nx) 
,rader AS ( 
    SELECT 
        a.acc as radvärde, 
        rownum, 
        (LAG(a.acc, 1) OVER(ORDER BY rownum) + a.acc) / 2 AS radvärdeAvg -- Använd närliggande rad för snitt av två rader (mer exakt), jämför diff och diffavg 
    FROM accSum a) 
  
SELECT 
    rownum, 
    radvärde, 
    ABS(PI()-radvärde) AS diff, 
    radvärdeAvg, 
    ABS(PI()-radvärdeAvg) AS diffavg FROM rader 
WHERE rownum IN (1E1, 1E2, 1E3, 1E4, 1E5) 
ORDER BY rownum 
  
-- Med rekursiv CTE (max 32767 rekursioner) 
;WITH piCalcRec AS ( 
    SELECT 
        1 as rownum, 
        CAST(1 AS DECIMAL(30,0)) AS num 
    UNION ALL 
    SELECT 
        rownum + 1, 
        CAST(IIF(rownum % 2 = 0, 1, -1) * ((rownum + 1) * 2 - 1) AS DECIMAL(30,0)) 
    FROM piCalcRec p 
    WHERE rownum < 32767) 
  
,summa AS ( 
    SELECT 
        p.*, 
        4*SUM(CAST(1/p.num AS DECIMAL(30,28))) OVER(ORDER BY rownum) AS summa 
    FROM piCalcRec p) 
  
,snitt AS ( 
    SELECT 
        s.rownum, 
        (LAG(s.summa, 1) OVER(ORDER BY rownum) + s.summa) / 2 AS pravg 
    FROM summa s) 
  
SELECT * 
FROM snitt 
WHERE rownum IN (1E1, 1E2, 1E3, 1E4, 32767) 
OPTION (MAXRECURSION 32767) 