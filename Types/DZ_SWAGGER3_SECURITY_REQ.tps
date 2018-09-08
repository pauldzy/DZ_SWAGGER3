CREATE OR REPLACE TYPE dz_swagger3_security_req FORCE
AUTHID DEFINER 
AS OBJECT (
    hash_key            VARCHAR2(255 Char)
   ,scope_names         MDSYS.SDO_STRING2_ARRAY
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_security_req
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_security_req(
       p_hash_key           IN  VARCHAR2
      ,p_scope_names        IN  MDSYS.SDO_STRING2_ARRAY
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION key
    RETURN VARCHAR2
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION isNULL
    RETURN VARCHAR2
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
      p_pretty_print      IN  NUMBER   DEFAULT NULL
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
      p_pretty_print      IN  NUMBER   DEFAULT 0
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_security_req TO public;

