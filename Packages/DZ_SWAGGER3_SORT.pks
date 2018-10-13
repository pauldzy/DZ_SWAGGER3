CREATE OR REPLACE PACKAGE dz_swagger3_sort
AUTHID DEFINER
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE schemas(
       p_input        IN OUT NOCOPY dz_swagger3_schema_nf_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE responses(
       p_input        IN OUT NOCOPY dz_swagger3_response_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE examples(
       p_input        IN OUT NOCOPY dz_swagger3_example_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE parameters(
       p_input        IN OUT NOCOPY dz_swagger3_parameter_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE requestBodies(
       p_input        IN OUT NOCOPY dz_swagger3_requestBody_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE headers(
       p_input        IN OUT NOCOPY dz_swagger3_header_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE securitySchemes(
       p_input        IN OUT NOCOPY dz_swagger3_securitySchem_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE links(
       p_input        IN OUT NOCOPY dz_swagger3_link_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE callbacks(
       p_input        IN OUT NOCOPY dz_swagger3_callback_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   );

 END dz_swagger3_sort;
/

GRANT EXECUTE ON dz_swagger3_sort TO public;

