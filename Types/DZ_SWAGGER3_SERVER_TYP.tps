CREATE OR REPLACE TYPE dz_swagger3_server_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    server_url          VARCHAR2(255 Char)
   ,server_description  VARCHAR2(4000 Char)
   ,server_variables    dz_swagger3_server_var_list
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_server_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_server_typ(
       p_server_url         IN  VARCHAR2
      ,p_server_description IN  VARCHAR2
      ,p_server_variables   IN  dz_swagger3_server_var_list
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION isNULL
    RETURN VARCHAR2
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
      p_pretty_print        IN  NUMBER   DEFAULT NULL
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
      p_pretty_print        IN  NUMBER   DEFAULT 0
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_server_typ TO public;

