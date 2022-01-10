SELECT 
    i.fill_factor, 
    i.* FROM sys.indexes i WITH (NOLOCK) 
INNER JOIN sys.objects o  WITH (NOLOCK) ON i.object_id = o.object_id 
WHERE o.type = 'U' 
    AND i.name IS NOT NULL 
    and i.fill_factor <> 80 
order by i.object_id