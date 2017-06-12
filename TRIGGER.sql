CREATE TRIGGER TRG_AUD_PROCEDURE
on  database
FOR CREATE_procedure, ALTER_procedure, DROP_procedure, CREATE_TABLE, ALTER_TABLE, DROP_TABLE
AS
begin
    set nocount on;

    DECLARE @EventData      xml
    SET @EventData=EVENTDATA()

    INSERT INTO AUD_PROCEDURE
            (st_objeto, st_comando,st_database,st_evento)
        SELECT
			o.Name,
			m.definition,
			@EventData.value('(/EVENT_INSTANCE/DatabaseName)[1]', 'varchar(256)'),
			@EventData.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(100)')
            FROM sys.objects                 o
            INNER JOIN sys.sql_modules   m ON o.object_id=m.object_id
            WHERE o.Name=@EventData.value('(/EVENT_INSTANCE/ObjectName)[1]', 'nvarchar(max)')
end
GO
