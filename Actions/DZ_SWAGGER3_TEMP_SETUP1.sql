BEGIN

   EXECUTE IMMEDIATE 'DROP TABLE dz_swagger3_xrelates';
   EXECUTE IMMEDIATE 'DROP TABLE dz_swagger3_xobjects';
   
EXCEPTION
   WHEN OTHERS
   THEN
      NULL;

END;
/

