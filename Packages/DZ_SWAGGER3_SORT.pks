CREATE OR REPLACE PACKAGE dz_swagger3_sort
AUTHID DEFINER
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION schemas(
       p_input        IN  dz_swagger3_schema_nf_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   ) RETURN dz_swagger3_schema_nf_list;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION responses(
       p_input        IN  dz_swagger3_response_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   ) RETURN dz_swagger3_response_list;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION examples(
       p_input        IN  dz_swagger3_example_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   ) RETURN dz_swagger3_example_list;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION parameters(
       p_input        IN  dz_swagger3_parameter_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   ) RETURN dz_swagger3_parameter_list;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION requestBodies(
       p_input        IN  dz_swagger3_requestBody_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   ) RETURN dz_swagger3_requestBody_list;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION headers(
       p_input        IN  dz_swagger3_header_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   ) RETURN dz_swagger3_header_list;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION securitySchemes(
       p_input        IN  dz_swagger3_securitySchem_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   ) RETURN dz_swagger3_securitySchem_list;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION links(
       p_input        IN  dz_swagger3_link_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   ) RETURN dz_swagger3_link_list;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION callbacks(
       p_input        IN  dz_swagger3_callback_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   ) RETURN dz_swagger3_callback_list;

 END dz_swagger3_sort;
/

GRANT EXECUTE ON dz_swagger3_sort TO public;

