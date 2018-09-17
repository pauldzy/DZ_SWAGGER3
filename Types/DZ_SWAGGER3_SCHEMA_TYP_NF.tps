CREATE OR REPLACE TYPE dz_swagger3_schema_typ_nf FORCE
AUTHID DEFINER 
AS OBJECT (

   ,dummy INTEGER
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_server_typ_nf
    RETURN SELF AS RESULT

) NOT FINAL;
/

GRANT EXECUTE ON dz_swagger3_schema_typ_nf TO public;

