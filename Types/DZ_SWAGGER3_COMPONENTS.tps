CREATE OR REPLACE TYPE dz_swagger3_components FORCE
AUTHID DEFINER 
AS OBJECT (
    schemas             dz_swagger3_schema_list
   ,responses           dz_swagger3_response_list
   ,parameters          dz_swagger3_parameter_list
   ,examples            dz_swagger3_example_list
   ,requestBodies       dz_swagger3_requestBody_list
   ,headers             dz_swagger3_header_list
   ,securitySchemes     dz_swagger3_securitySchem_list
   ,links               dz_swagger3_link_list
   ,callbacks           dz_swagger3_callback_list
   
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

