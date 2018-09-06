CREATE OR REPLACE TYPE dz_swagger3_components FORCE
AUTHID DEFINER 
AS OBJECT (
    schemas             dz_swagger3_schema_map
   ,responses           dz_swagger3_response_map
   ,parameters          dz_swagger3_parameter_map
   ,examples            dz_swagger3_example_map
   ,requestBodies       dz_swagger3_requestBody_map
   ,headers             dz_swagger3_header_map
   ,securitySchemes     dz_swagger3_securityScheme_map
   ,links               dz_swagger3_link_map
   ,callbacks           dz_swagger3_callback_map
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_components
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_components(
       p_description      IN  VARCHAR2
      ,p_url              IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION isNULL
    RETURN VARCHAR2
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
      p_pretty_print      IN  NUMBER   DEFAULT NULL
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
      p_pretty_print      IN  NUMBER   DEFAULT 0
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_components TO public;

