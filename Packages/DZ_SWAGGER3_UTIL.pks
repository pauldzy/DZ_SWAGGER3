CREATE OR REPLACE PACKAGE dz_swagger3_util
AUTHID DEFINER
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION get_guid
   RETURN VARCHAR2;
   
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
   FUNCTION yamlq(
       p_input            IN  VARCHAR2
   ) RETURN VARCHAR2 DETERMINISTIC;
  
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION yaml_text(
       p_input            IN  VARCHAR2 
      ,p_pretty_print     IN  NUMBER DEFAULT 0
   ) RETURN VARCHAR2 DETERMINISTIC;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION yaml_text(
       p_input            IN  NUMBER 
      ,p_pretty_print     IN  NUMBER DEFAULT 0
   ) RETURN VARCHAR2 DETERMINISTIC;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION yaml_text(
       p_input            IN  BOOLEAN
      ,p_pretty_print     IN  NUMBER DEFAULT 0
   ) RETURN VARCHAR2 DETERMINISTIC;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION utl_url_escape(
       p_input_url        IN  VARCHAR2 CHARACTER SET ANY_CS
      ,p_escape_reserved  IN  VARCHAR2 DEFAULT NULL
      ,p_url_charset      IN  VARCHAR2 DEFAULT NULL
   )  RETURN VARCHAR2 CHARACTER SET p_input_url%CHARSET DETERMINISTIC;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION a_in_b(
       p_input_a          IN  VARCHAR2
      ,p_input_b          IN  dz_swagger3_string_vry
   ) RETURN VARCHAR2 DETERMINISTIC;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE conc(
       p_c                IN OUT NOCOPY CLOB
      ,p_v                IN OUT NOCOPY VARCHAR2
      ,p_in_c             IN  CLOB      DEFAULT NULL
      ,p_in_v             IN  VARCHAR2  DEFAULT NULL
      ,p_pretty_print     IN  INTEGER   DEFAULT NULL
      ,p_amount           IN  VARCHAR2  DEFAULT '   '
      ,p_initial_indent   IN  BOOLEAN   DEFAULT TRUE
      ,p_final_linefeed   IN  BOOLEAN   DEFAULT TRUE
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE fconc(
       p_c                IN OUT NOCOPY CLOB
      ,p_v                IN OUT NOCOPY VARCHAR2
   );
 
 END dz_swagger3_util;
/

GRANT EXECUTE ON dz_swagger3_util TO public;

