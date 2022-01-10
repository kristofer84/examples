SELECT 
    r.session_id as SPID, 
    r.wait_type, 
    r.command, 
    a.text AS Query, 
    r.start_time, 
    r.percent_complete, 
    dateadd(second,r.estimated_completion_time/1000, getdate()) as estimated_completion_time  
FROM sys.dm_exec_requests r 
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) a  
WHERE r.command in ('BACKUP DATABASE', 'RESTORE DATABASE', 'DBCCFILESCOMPACT') 