CREATE OR REPLACE PACKAGE dz_swagger3_validate
AUTHID DEFINER
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   /*
   Constant: c_default_validators
   */
   c_default_validators CONSTANT VARCHAR2(4000 Char) := '{"tests":["plsql"]}';

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION request_validate(
       p_doc     IN  CLOB
      ,p_options IN  VARCHAR2
   ) RETURN CLOB;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION plsql_validate(
      p_doc    IN  CLOB
   ) RETURN CLOB;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION swagger_badge_validate(
      p_doc    IN  CLOB
   ) RETURN CLOB;
      
END dz_swagger3_validate;
/

GRANT EXECUTE ON dz_swagger3_validate TO public;

