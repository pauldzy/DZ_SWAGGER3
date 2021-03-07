CREATE OR REPLACE TYPE dz_swagger3_xml_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    xml_name            VARCHAR2(255 Char)
   ,xml_namespace       VARCHAR2(2000 Char)
   ,xml_prefix          VARCHAR2(255 Char)
   ,xml_attribute       VARCHAR2(5 Char)
   ,xml_wrapped         VARCHAR2(5 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_xml_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_xml_typ(
       p_xml_name            IN  VARCHAR2 DEFAULT NULL
      ,p_xml_namespace       IN  VARCHAR2 DEFAULT NULL
      ,p_xml_prefix          IN  VARCHAR2 DEFAULT NULL
      ,p_xml_attribute       IN  VARCHAR2 DEFAULT NULL
      ,p_xml_wrapped         IN  VARCHAR2 DEFAULT NULL
   ) RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON
    RETURN CLOB
    
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

GRANT EXECUTE ON dz_swagger3_xml_typ TO public;

