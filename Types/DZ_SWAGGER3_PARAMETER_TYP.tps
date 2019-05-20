CREATE OR REPLACE TYPE dz_swagger3_parameter_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    parameter_id               VARCHAR2(255 Char)
   ,parameter_name             VARCHAR2(255 Char)
   ,parameter_in               VARCHAR2(255 Char)
   ,parameter_description      VARCHAR2(4000 Char)
   ,parameter_required         VARCHAR2(5 Char)
   ,parameter_deprecated       VARCHAR2(5 Char)
   ,parameter_allowEmptyValue  VARCHAR2(5 Char)
   ,parameter_style            VARCHAR2(255 Char)
   ,parameter_explode          VARCHAR2(5 Char)
   ,parameter_allowReserved    VARCHAR2(5 Char)
   ,parameter_schema           dz_swagger3_object_typ --dz_swagger3_schema_typ_nf
   ,parameter_example_string   VARCHAR2(255 Char)
   ,parameter_example_number   NUMBER
   ,parameter_examples         dz_swagger3_object_vry --dz_swagger3_example_list
   ,parameter_force_inline     VARCHAR2(5 Char)
   ,parameter_list_hidden      VARCHAR2(5 Char)
   ,parameter_requestbody_flag VARCHAR2(5 Char)
   ,versionid                  VARCHAR2(40 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_parameter_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_parameter_typ(
       p_parameter_id              IN  VARCHAR2
      ,p_versionid                 IN  VARCHAR2
   ) RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE traverse
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_parameter_typ TO public;

