CREATE OR REPLACE TYPE dz_swagger3_securityScheme_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    securityscheme_id            VARCHAR2(255 Char)
   ,securityscheme_fullname      VARCHAR2(255 Char)
   ,securityscheme_type          VARCHAR2(255 Char)
   ,securityscheme_description   VARCHAR2(255 Char)
   ,securityscheme_name          VARCHAR2(255 Char)
   ,securityscheme_in            VARCHAR2(255 Char)
   ,securityscheme_scheme        VARCHAR2(255 Char)
   ,securityscheme_bearerFormat  VARCHAR2(255 Char)
   ,oauth_flow_implicit          dz_swagger3_oauth_flow_typ
   ,oauth_flow_password          dz_swagger3_oauth_flow_typ
   ,oauth_flow_clientCredentials dz_swagger3_oauth_flow_typ
   ,oauth_flow_authorizationCode dz_swagger3_oauth_flow_typ
   ,securityscheme_openIdConUrl  VARCHAR2(255 Char)
   ,versionid                    VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_securityScheme_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_securityScheme_typ(
       p_securityscheme_id       IN  VARCHAR2
      ,p_securityscheme_fullname IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON
    RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON_req(
      p_oauth_scope_flows       IN  VARCHAR2  DEFAULT NULL
    ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_securityScheme_typ TO public;

