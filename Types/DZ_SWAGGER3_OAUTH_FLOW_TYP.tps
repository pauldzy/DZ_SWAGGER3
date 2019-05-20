CREATE OR REPLACE TYPE dz_swagger3_oauth_flow_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    oauth_authorizationUrl       VARCHAR2(255 Char)
   ,oauth_tokenUrl               VARCHAR2(255 Char)
   ,oauth_refreshUrl             VARCHAR2(255 Char)
   ,oauth_scopes                 MDSYS.SDO_STRING2_ARRAY --dz_swagger3_string_hash_list
   ,versionid                    VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_oauth_flow_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_oauth_flow_typ(
       p_oauth_authorizationUrl  IN  VARCHAR2
      ,p_oauth_tokenUrl          IN  VARCHAR2
      ,p_oauth_refreshUrl        IN  VARCHAR2
      ,p_oauth_scopes            IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_string_hash_list
   ) RETURN SELF AS RESULT
   
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

GRANT EXECUTE ON dz_swagger3_oauth_flow_typ TO public;

