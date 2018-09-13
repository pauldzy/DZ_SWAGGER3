CREATE OR REPLACE TYPE dz_swagger3_components FORCE
AUTHID DEFINER 
AS OBJECT (
    components_schemas          dz_swagger3_schema_list
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
       p_components_schemas           IN  dz_swagger3_schema_list
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
   ,MEMBER FUNCTION components_schemas_keys
    RETURN MDSYS.SDO_STRING2_ARRAY
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION components_responses_keys
    RETURN MDSYS.SDO_STRING2_ARRAY
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION components_parameters_keys
    RETURN MDSYS.SDO_STRING2_ARRAY
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION components_examples_keys
    RETURN MDSYS.SDO_STRING2_ARRAY
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION components_requestBodies_keys
    RETURN MDSYS.SDO_STRING2_ARRAY
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION components_headers_keys
    RETURN MDSYS.SDO_STRING2_ARRAY
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION components_securityScheme_keys
    RETURN MDSYS.SDO_STRING2_ARRAY
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION components_links_keys
    RETURN MDSYS.SDO_STRING2_ARRAY
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION components_callbacks_keys
    RETURN MDSYS.SDO_STRING2_ARRAY
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION isNULL
    RETURN VARCHAR2
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
      p_pretty_print      IN  INTEGER  DEFAULT NULL
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
      p_pretty_print      IN  INTEGER  DEFAULT 0
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_components TO public;

