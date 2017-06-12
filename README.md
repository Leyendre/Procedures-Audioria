**TABLA**
-----
Creo una tabla  donde se registraran las modificaciones de los procedimientos almacenados.

    CREATE TABLE [dbo].[AUD_PROCEDURE](
    	dt_fecha SMALLDATETIME NOT NULL,
    	st_database NVARCHAR(256) NOT NULL,
    	st_evento NVARCHAR(100) NOT NULL,
    	st_objeto NVARCHAR(256) NOT NULL,
    	st_comando NVARCHAR(MAX) NOT NULL,
    	st_usuario NVARCHAR(100) NOT NULL
    )
    
    GO
    
    SET ANSI_PADDING OFF
    GO
    
    ALTER TABLE [dbo].[AUD_PROCEDURE] ADD  CONSTRAINT [DF__AUD_PROCEDURE_USUARIO]  DEFAULT SUBSTRING(system_user, PATINDEX('%\%', system_user)+1, len(system_user)-PATINDEX('%\%', system_user)) FOR [st_usuario]
    GO
    
    ALTER TABLE [dbo].[AUD_PROCEDURE] ADD  CONSTRAINT [DF__AUD_PROCEDURE_FECHA_MOD]  DEFAULT CAST(GETDATE() AS SMALLDATETIME)  FOR [dt_fecha]
    
    GO


----------

**TRIGGER**
-------

Con el siguiente trigger que se ejecutara en los siguientes eventos

**TABLAS : **

 - create 
 - alter 
 - drop
 
**PROCEDURES : **

 - create
 - alter 
 - drop

----------


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

----------

**SELECT**
------

Para obtener los datos de la tabla con formato, utilizo el siguiente select

    IF EXISTS (SELECT * FROM sysobjects WHERE name='AUD_PROCEDURE' and xtype='U')
    DECLARE @MigraCursor CURSOR;
    DECLARE @Procedure NVARCHAR(MAX);
    BEGIN
        SET @MigraCursor = CURSOR FOR
        select st_comando from AUD_PROCEDURE     
        OPEN @MigraCursor 
        FETCH NEXT FROM @MigraCursor 
        INTO @Procedure
        WHILE @@FETCH_STATUS = 0
        BEGIN
    		print @Procedure
          FETCH NEXT FROM @MigraCursor 
          INTO @Procedure 
        END; 
        CLOSE @MigraCursor ;
        DEALLOCATE @MigraCursor;
    END;


----------


este tutorial esta basado en la informacion obtenida de la [siguiente publicacion](http://www.sqlbook.com/sql-server/using-ddl-triggers-in-sql-server-to-audit-database-objects/)

y el siguiente hilo de [stack overflow](https://stackoverflow.com/questions/1521598/how-to-get-procedure-text-before-alter-from-ddl-trigger)
