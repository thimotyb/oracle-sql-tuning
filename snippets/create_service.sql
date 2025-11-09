-- come SYSDBA
SHOW CON_NAME;                            -- verifica dove sei
ALTER SESSION SET CONTAINER = pdb1;       -- sostituisci con la tua PDB

BEGIN
  dbms_service.create_service(
    service_name => 'MYTRACER',             -- nome interno del service
    network_name => 'MYTRACER'              -- nome visibile al listener/TNS
  );
END;
/
EXEC dbms_service.start_service('MYTRACER');
ALTER PLUGGABLE DATABASE SAVE STATE;      -- riavvio: il service riparte
