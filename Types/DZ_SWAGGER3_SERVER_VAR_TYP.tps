CREATE OR REPLACE TYPE dz_swagger3_server_var_typ FORCE
AUTHID DEFINER
AS OBJECT (
    hash_key            VARCHAR2(255 Char)
   ,enum                MDSYS.SDO_STRING2_ARRAY
   ,default_value       VARCHAR2(255 Char)
   ,description         VARCHAR2(4000 Char)

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_server_var_typ
    RETURN SELF AS RESULT

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_server_var_typ(
       p_hash_key           IN  VARCHAR2
      ,p_enum               IN  MDSYS.SDO_STRING2_ARRAY
      ,p_default_value      IN  VARCHAR2
      ,p_description        IN  VARCHAR2
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
      p_pretty_print        IN  INTEGER   DEFAULT NULL
    ) RETURN CLOB

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
      p_pretty_print        IN  INTEGER   DEFAULT 0
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_server_var_typ TO public;

