CREATE OR REPLACE TYPE dz_swagger3_server_var_typ FORCE
AUTHID DEFINER
AS OBJECT (
    server_var_id       VARCHAR2(255 Char)
   ,server_var_name     VARCHAR2(255 Char)
   ,enum                dz_swagger3_string_vry
   ,default_value       VARCHAR2(255 Char)
   ,description         VARCHAR2(4000 Char)
   ,versionid           VARCHAR2(255 Char)

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_server_var_typ
    RETURN SELF AS RESULT

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_server_var_typ(
       p_server_var_id      IN  VARCHAR2
      ,p_versionid          IN  VARCHAR2
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

GRANT EXECUTE ON dz_swagger3_server_var_typ TO public;

