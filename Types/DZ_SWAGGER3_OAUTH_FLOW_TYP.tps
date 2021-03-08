CREATE OR REPLACE TYPE dz_swagger3_oauth_flow_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    oauth_flow_id                VARCHAR2(255 Char)
   ,oauth_flow_authorizationUrl  VARCHAR2(255 Char)
   ,oauth_flow_tokenUrl          VARCHAR2(255 Char)
   ,oauth_flow_refreshUrl        VARCHAR2(255 Char)
   ,oauth_flow_scope_names       dz_swagger3_string_vry
   ,oauth_flow_scope_desc        dz_swagger3_string_vry
   ,versionid                    VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_oauth_flow_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_oauth_flow_typ(
       p_oauth_flow_id           IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON
    RETURN CLOB

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_oauth_flow_typ TO public;

