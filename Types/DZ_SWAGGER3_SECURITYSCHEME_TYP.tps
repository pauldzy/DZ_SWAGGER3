CREATE OR REPLACE TYPE dz_swagger3_securityScheme_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    hash_key                VARCHAR2(255 Char)
   ,scheme_id               VARCHAR2(255 Char)
   ,scheme_type             VARCHAR2(255 Char)
   ,scheme_description      VARCHAR2(255 Char)
   ,scheme_name             VARCHAR2(255 Char)
   ,scheme_in               VARCHAR2(255 Char)
   ,scheme_auth             VARCHAR2(255 Char)
   ,scheme_bearerFormat     VARCHAR2(255 Char)
   ,scheme_flows            dz_swagger3_oauth_flows_typ
   ,scheme_openIdConnectUrl VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_securityScheme_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_securityScheme_typ(
       p_hash_key                IN  VARCHAR2
      ,p_scheme_id               IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
      ,p_load_components         IN  VARCHAR2 DEFAULT 'TRUE'
      ,p_ref_brake               IN  VARCHAR2 DEFAULT 'FALSE'
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_securityScheme_typ(
       p_hash_key                IN  VARCHAR2
      ,p_scheme_id               IN  VARCHAR2
      ,p_scheme_type             IN  VARCHAR2
      ,p_scheme_description      IN  VARCHAR2
      ,p_scheme_name             IN  VARCHAR2
      ,p_scheme_in               IN  VARCHAR2
      ,p_scheme_auth             IN  VARCHAR2
      ,p_scheme_bearerFormat     IN  VARCHAR2
      ,p_scheme_flows            IN  dz_swagger3_oauth_flows_typ
      ,p_scheme_openIdConnectUrl IN  VARCHAR2
      ,p_load_components         IN  VARCHAR2 DEFAULT 'TRUE'
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
   ,MEMBER FUNCTION doRef
    RETURN VARCHAR2
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON_schema(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON_ref(
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
   ,MEMBER FUNCTION toYAML_schema(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML_ref(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_securityScheme_typ TO public;

