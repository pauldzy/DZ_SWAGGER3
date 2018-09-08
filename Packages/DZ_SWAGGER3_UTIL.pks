CREATE OR REPLACE PACKAGE dz_swagger3_util
AUTHID DEFINER
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION get_guid
   RETURN VARCHAR2;
  
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION yaml_text(
       p_input        IN  VARCHAR2 
      ,p_pretty_print IN  NUMBER DEFAULT 0
   ) RETURN VARCHAR2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION yaml_text(
       p_input        IN  NUMBER 
      ,p_pretty_print IN  NUMBER DEFAULT 0
   ) RETURN VARCHAR2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION yaml_text(
       p_input        IN  BOOLEAN
      ,p_pretty_print IN  NUMBER DEFAULT 0
   ) RETURN VARCHAR2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dzcondense(
       p_versionid    IN  VARCHAR2
      ,p_input        IN  VARCHAR2
   ) RETURN VARCHAR2 DETERMINISTIC;
 
 END dz_swagger3_util;
/

GRANT EXECUTE ON dz_swagger3_util TO public;

