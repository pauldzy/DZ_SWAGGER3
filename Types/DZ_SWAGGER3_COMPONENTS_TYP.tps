CREATE OR REPLACE TYPE dz_swagger3_components_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    components_schemas          MDSYS.SDO_STRING2_ARRAY --dz_swagger3_schema_nf_list
   ,components_responses        MDSYS.SDO_STRING2_ARRAY --dz_swagger3_response_list
   ,components_parameters       MDSYS.SDO_STRING2_ARRAY --dz_swagger3_parameter_list
   ,components_examples         MDSYS.SDO_STRING2_ARRAY --dz_swagger3_example_list
   ,components_requestBodies    MDSYS.SDO_STRING2_ARRAY --dz_swagger3_requestBody_list
   ,components_headers          MDSYS.SDO_STRING2_ARRAY --dz_swagger3_header_list
   ,components_securitySchemes  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_securitySchem_list
   ,components_links            MDSYS.SDO_STRING2_ARRAY --dz_swagger3_link_list
   ,components_callbacks        MDSYS.SDO_STRING2_ARRAY --dz_swagger3_callback_list
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_components_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_components_typ(
      p_versionid                     IN  VARCHAR2
   ) RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_components_typ(
       p_components_schemas           IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_schema_nf_list
      ,p_components_responses         IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_response_list
      ,p_components_parameters        IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_parameter_list
      ,p_components_examples          IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_example_list
      ,p_components_requestBodies     IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_requestBody_list
      ,p_components_headers           IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_header_list
      ,p_components_securitySchemes   IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_securitySchem_list
      ,p_components_links             IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_link_list
      ,p_components_callbacks         IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_callback_list
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE load_components_schemas(
       SELF        IN OUT NOCOPY dz_swagger3_components_typ
      ,p_versionid IN VARCHAR2
    )
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE load_components_responses(
       SELF        IN OUT NOCOPY dz_swagger3_components_typ
      ,p_versionid IN VARCHAR2
    )
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE load_components_parameters(
       SELF        IN OUT NOCOPY dz_swagger3_components_typ
      ,p_versionid IN VARCHAR2
    )
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE load_components_examples(
       SELF        IN OUT NOCOPY dz_swagger3_components_typ
      ,p_versionid IN VARCHAR2
    )
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE load_components_requestBodies(
       SELF        IN OUT NOCOPY dz_swagger3_components_typ
      ,p_versionid IN VARCHAR2
    )
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE load_components_headers(
       SELF        IN OUT NOCOPY dz_swagger3_components_typ
      ,p_versionid IN VARCHAR2
    )
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE load_components_securityScheme(
       SELF        IN OUT NOCOPY dz_swagger3_components_typ
      ,p_versionid IN VARCHAR2
    )
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE load_components_links(
       SELF        IN OUT NOCOPY dz_swagger3_components_typ
      ,p_versionid IN VARCHAR2
    )
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE load_components_callbacks(
       SELF        IN OUT NOCOPY dz_swagger3_components_typ
      ,p_versionid IN VARCHAR2
    )
    
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

GRANT EXECUTE ON dz_swagger3_components_typ TO public;

