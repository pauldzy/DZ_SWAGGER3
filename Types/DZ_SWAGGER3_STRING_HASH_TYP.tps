CREATE OR REPLACE TYPE dz_swagger3_string_hash_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    hash_key            VARCHAR2(255 Char)
   ,string_value        VARCHAR2(4000 Char)
   ,versionid           VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_string_hash_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_string_hash_typ(
       p_hash_key           IN  VARCHAR2
      ,p_string_value       IN  VARCHAR2
      ,p_versionid          IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE traverse
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_string_hash_typ TO public;

