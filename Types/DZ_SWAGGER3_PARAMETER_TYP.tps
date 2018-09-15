CREATE OR REPLACE TYPE dz_swagger3_parameter_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    hash_key                   VARCHAR2(255 Char)
   ,parameter_id               VARCHAR2(255 Char)
   ,parameter_name             VARCHAR2(255 Char)
   ,parameter_in               VARCHAR2(255 Char)
   ,parameter_description      VARCHAR2(4000 Char)
   ,parameter_required         VARCHAR2(5 Char)
   ,parameter_deprecated       VARCHAR2(5 Char)
   ,parameter_allowEmptyValue  VARCHAR2(5 Char)
   ,parameter_style            VARCHAR2(255 Char)
   ,parameter_explode          VARCHAR2(5 Char)
   ,parameter_allowReserved    VARCHAR2(5 Char)
   ,parameter_schema           dz_swagger3_schema_typ
   ,parameter_example_string   VARCHAR2(255 Char)
   ,parameter_example_number   NUMBER
   ,parameter_examples         dz_swagger3_example_list
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_parameter_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_parameter_typ(
       p_hash_key                  IN  VARCHAR2
      ,p_parameter_id              IN  VARCHAR2
      ,p_parameter_name            IN  VARCHAR2
      ,p_parameter_in              IN  VARCHAR2
      ,p_parameter_description     IN  VARCHAR2
      ,p_parameter_required        IN  VARCHAR2
      ,p_parameter_deprecated      IN  VARCHAR2
      ,p_parameter_allowEmptyValue IN  VARCHAR2
      ,p_parameter_style           IN  VARCHAR2
      ,p_parameter_explode         IN  VARCHAR2
      ,p_parameter_allowReserved   IN  VARCHAR2
      ,p_parameter_schema          IN  dz_swagger3_schema_typ
      ,p_parameter_example_string  IN  VARCHAR2
      ,p_parameter_example_number  IN  NUMBER
      ,p_parameter_examples        IN  dz_swagger3_example_list
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION key
    RETURN VARCHAR2
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION isNULL
    RETURN VARCHAR2
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION parameter_examples_keys
    RETURN MDSYS.SDO_STRING2_ARRAY
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
      p_pretty_print      IN  INTEGER   DEFAULT NULL
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print      IN  INTEGER   DEFAULT 0
      ,p_initial_indent    IN  VARCHAR2  DEFAULT 'TRUE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_parameter_typ TO public;

