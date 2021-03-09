CREATE OR REPLACE TYPE dz_swagger3_server_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    server_url          VARCHAR2(255 Char)
   ,server_description  VARCHAR2(4000 Char)
   ,server_variables    dz_swagger3_object_vry --dz_swagger3_server_var_list
   ,versionid           VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_server_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_server_typ(
       p_server_id           IN  VARCHAR2
      ,p_versionid           IN  VARCHAR2 DEFAULT NULL
   ) RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE traverse
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON
    RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_server_typ TO public;

