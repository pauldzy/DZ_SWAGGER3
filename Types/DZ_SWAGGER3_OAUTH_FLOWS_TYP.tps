CREATE OR REPLACE TYPE dz_swagger3_oauth_flows_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    flows_implicit             dz_swagger3_oauth_flow_typ
   ,flows_password             dz_swagger3_oauth_flow_typ
   ,flows_clientCredentials    dz_swagger3_oauth_flow_typ
   ,flows_authorizationCode    dz_swagger3_oauth_flow_typ
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_oauth_flows_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_oauth_flows_typ(
       p_flows_implicit          IN  dz_swagger3_oauth_flow_typ
      ,p_flows_password          IN  dz_swagger3_oauth_flow_typ
      ,p_flows_clientCredentials IN  dz_swagger3_oauth_flow_typ
      ,p_flows_authorizationCode IN  dz_swagger3_oauth_flow_typ
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
      p_pretty_print         IN  INTEGER   DEFAULT NULL
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_oauth_flows_typ TO public;

