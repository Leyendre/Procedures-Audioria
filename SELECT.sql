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