------------------------------------------------------------- 
-- Exempel där vi tar fram grupper som överlappar och glappar 
------------------------------------------------------------- 
  
DECLARE @t4 TABLE (Grupp NVARCHAR(1), DatFrom DATE, DatTom DATE) 
INSERT INTO @t4 (Grupp, DatFrom, DatTom) VALUES 
    ('A', '2016-01-01', '2016-03-04'), 
    ('A', '2016-03-05', '2016-04-01'), -- Glapp efter denna 
    ('A', '2016-08-07', '2017-01-01'), 
    ('B', '2016-01-01', '2016-03-04'), 
    ('B', '2016-03-05', '2016-08-06'), 
    ('B', '2016-08-07', '2017-01-01'), 
    ('C', '2016-01-01', '2016-03-04'), 
    ('C', '2016-03-05', '2016-08-08'), -- Överlappar 
    ('C', '2016-08-07', '2017-01-01') 
  
;WITH lead AS ( 
    SELECT 
        a.Grupp, 
        a.DatFrom, 
        a.DatTom, 
        LEAD(a.DatFrom, 1) OVER(PARTITION BY a.Grupp ORDER BY a.DatFrom) AS DatFromLead -- Dat-värdet från raden efter ", 1" innebär att vi går en rad framåt, LAG(xx, 1) hade gett värde från raden före 
    FROM @t4 a) 
  
,dd AS ( 
    SELECT 
        l.Grupp, 
        l.DatFrom, 
        l.DatTom, 
        l.DatFromLead, 
        DATEDIFF(DAY, l.DatTom, l.DatFromLead) dagar 
    FROM lead l) 
  
,glapp AS ( 
    SELECT 
        d.Grupp, 
        IIF(d.dagar > 1, 1, 0) AS Glapp, 
        IIF(d.dagar < 1, 1, 0) AS Överlapp, 
        d.DatTom 
    FROM dd d 
    WHERE d.dagar IS NOT NULL) 
  
,avvikelser AS ( 
    SELECT 
        a.Grupp, 
        SUM(a.Glapp) AS AntalGlapp, 
        SUM(a.Överlapp) AS AntalÖverlapp, 
        IIF(SUM(a.Glapp) = 0 AND SUM(a.Överlapp) = 0, 1, 0) AS IngaAvvikelser 
    FROM glapp a 
    GROUP BY a.Grupp) 
  
,sistaDat AS ( 
    SELECT 
        a.Grupp, 
        MAX(a.DatTom) MaxDat 
    FROM @t4 a 
    GROUP BY a.Grupp) 
  
SELECT * 
FROM avvikelser a 
INNER JOIN sistaDat s ON a.Grupp = s.Grupp