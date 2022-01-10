-- Vanlig SELECT 
DECLARE @filnamn NVARCHAR(255) = 'C:\aaaa.txt' 
DECLARE @cmd1 NVARCHAR(500) = 'bcp "SELECT rådata2 FROM Compare.dbo.Rådata2" queryout "' + @filnamn + '" -c -C 65001 -t \t -r \n -S localhost -T' 
EXEC xp_cmdshell @cmd1 
GO 
  
-- Dump av hel tabell 
DECLARE @filnamn NVARCHAR(255) = 'C:\aaaa.txt' 
DECLARE @cmd2 NVARCHAR(500) = 'bcp Compare.dbo.Rådata2 out "' + @filnamn + '" -c -C 65001 -t \t -r \n -S localhost -T' 
EXEC xp_cmdshell @cmd2 
GO 
  
-- Med hjälp av tillfällig procedur 
CREATE PROCEDURE dbo.atgregergerge AS  
SELECT r.Rådata2 FROM Rådata2 r 
GO 
  
DECLARE @filnamn NVARCHAR(255) = 'C:\aaaa.txt' 
DECLARE @cmd NVARCHAR(500) = 'bcp "exec Compare.dbo.atgregergerge" queryout "' + @filnamn + '" -c -C 65001 -t \t -r \n -S localhost -T' 
EXEC xp_cmdshell @cmd 
  
DROP PROCEDURE dbo.atgregergerge 
  
GO