CREATE OR REPLACE TYPE dz_swagger3_oauth_flow_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    oauth_authorizationUrl       VARCHAR2(255 Char)
   ,oauth_tokenUrl               VARCHAR2(255 Char)
   ,oauth_refreshUrl             VARCHAR2(255 Char)
   ,oauth_scopes                 MDSYS.SDO_STRING2_ARRAY --dz_swagger3_string_hash_list
   
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
   ,MEMBER FUNCTION oauth_scopes_keys
    RETURN MDSYS.SDO_STRING2_ARRAY
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,STATIC PROCEDURE loader(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  MDSYS.SDO_STRING2_ARRAY
      ,p_versionid           IN  VARCHAR2
   )

);
/

GRANT EXECUTE ON dz_swagger3_oauth_flow_typ TO public;

