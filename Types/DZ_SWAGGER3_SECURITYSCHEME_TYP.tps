CREATE OR REPLACE TYPE dz_swagger3_securityScheme_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    securityscheme_id           VARCHAR2(255 Char)
   ,securityscheme_type         VARCHAR2(255 Char)
   ,securityscheme_description  VARCHAR2(255 Char)
   ,securityscheme_name         VARCHAR2(255 Char)
   ,securityscheme_in           VARCHAR2(255 Char)
   ,securityscheme_auth         VARCHAR2(255 Char)
   ,securityscheme_bearerFormat VARCHAR2(255 Char)
   ,securityscheme_flows        dz_swagger3_oauth_flows_typ
   ,securityscheme_openIdConUrl VARCHAR2(255 Char)
   ,versionid                   VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_securityScheme_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_securityScheme_typ(
       p_securityscheme_id   IN  VARCHAR2
      ,p_versionid           IN  VARCHAR2
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
   ,MEMBER FUNCTION toJSON_ref(
       p_identifier          IN  VARCHAR2
      ,p_pretty_print        IN  INTEGER   DEFAULT NULL
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
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML_ref(
       p_identifier          IN  VARCHAR2
      ,p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_securityScheme_typ TO public;

