CREATE OR REPLACE TYPE dz_swagger3_string_hash_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    hash_key            VARCHAR2(255 Char)
   ,string_value        VARCHAR2(4000 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_link_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_link_typ(
       p_hash_key           IN  VARCHAR2
      ,p_string_value       IN  VARCHAR2
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

GRANT EXECUTE ON dz_swagger3_string_hash_typ TO public;

