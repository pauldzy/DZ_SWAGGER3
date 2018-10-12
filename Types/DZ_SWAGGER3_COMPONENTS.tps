CREATE OR REPLACE TYPE dz_swagger3_components FORCE
AUTHID DEFINER 
AS OBJECT (
    components_schemas          dz_swagger3_schema_nf_list
   ,components_responses        dz_swagger3_response_list
   ,components_parameters       dz_swagger3_parameter_list
   ,components_examples         dz_swagger3_example_list
   ,components_requestBodies    dz_swagger3_requestBody_list
   ,components_headers          dz_swagger3_header_list
   ,components_securitySchemes  dz_swagger3_securitySchem_list
   ,components_links            dz_swagger3_link_list
   ,components_callbacks        dz_swagger3_callback_list
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_components
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_components(
       p_components_schemas           IN  dz_swagger3_schema_nf_list
      ,p_components_responses         IN  dz_swagger3_response_list
      ,p_components_parameters        IN  dz_swagger3_parameter_list
      ,p_components_examples          IN  dz_swagger3_example_list
      ,p_components_requestBodies     IN  dz_swagger3_requestBody_list
      ,p_components_headers           IN  dz_swagger3_header_list
      ,p_components_securitySchemes   IN  dz_swagger3_securitySchem_list
      ,p_components_links             IN  dz_swagger3_link_list
      ,p_components_callbacks         IN  dz_swagger3_callback_list
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION get_components_schemas
    RETURN dz_swagger3_schema_nf_list
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION get_components_responses
    RETURN dz_swagger3_response_list
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION get_components_parameters
    RETURN dz_swagger3_parameter_list
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION get_components_examples
    RETURN dz_swagger3_example_list
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION get_components_requestBodies
    RETURN dz_swagger3_requestBody_list
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION get_components_headers
    RETURN dz_swagger3_header_list
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION get_components_securitySchemes
    RETURN dz_swagger3_securitySchem_list
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION get_components_links
    RETURN dz_swagger3_link_list
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION get_components_callbacks
    RETURN dz_swagger3_callback_list
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION isNULL
    RETURN VARCHAR2
    
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

);
/

GRANT EXECUTE ON dz_swagger3_components TO public;

