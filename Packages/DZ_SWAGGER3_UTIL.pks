CREATE OR REPLACE PACKAGE dz_swagger3_util
AUTHID DEFINER
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION get_guid
   RETURN VARCHAR2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION safe_to_number(
       p_input            IN VARCHAR2
      ,p_null_replacement IN NUMBER DEFAULT NULL
   ) RETURN NUMBER;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION gz_split(
       p_str              IN  VARCHAR2
      ,p_regex            IN  VARCHAR2
      ,p_match            IN  VARCHAR2 DEFAULT NULL
      ,p_end              IN  NUMBER   DEFAULT 0
      ,p_trim             IN  VARCHAR2 DEFAULT 'FALSE'
   ) RETURN dz_swagger3_string_vry DETERMINISTIC;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE json2yaml(
       p_input            IN  CLOB
      ,p_output           IN OUT NOCOPY CLOB
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE json2yaml(
       p_input            IN  JSON_ELEMENT_T
      ,p_level            IN  NUMBER
      ,p_indent           IN  BOOLEAN
      ,p_output           IN OUT NOCOPY CLOB
   );
 
 END dz_swagger3_util;
/

GRANT EXECUTE ON dz_swagger3_util TO public;

