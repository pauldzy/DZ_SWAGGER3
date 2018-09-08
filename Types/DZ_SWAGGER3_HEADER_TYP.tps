CREATE OR REPLACE TYPE dz_swagger3_header_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    hash_key                VARCHAR2(255 Char)
   ,header_description      VARCHAR2(4000 Char)
   ,header_required         VARCHAR2(5 Char)
   ,header_deprecated       VARCHAR2(5 Char)
   ,header_allowEmptyValue  VARCHAR2(5 Char)
   ,header_style            VARCHAR2(255 Char)
   ,header_explode          VARCHAR2(5 Char)
   ,header_allowReserved    VARCHAR2(5 Char)
   ,header_schema           dz_swagger3_schema_typ
   ,header_example_string   VARCHAR2(255 Char)
   ,header_example_number   NUMBER
   ,header_examples         dz_swagger3_example_list
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_header_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_header_typ(
       p_hash_key              IN  VARCHAR2
      ,p_example_summary       IN  VARCHAR2
      ,p_example_description   IN  VARCHAR2
      ,p_example_value_string  IN  VARCHAR2
      ,p_example_value_number  IN  NUMBER
      ,p_example_externalValue IN  VARCHAR2
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
   ,MEMBER FUNCTION toJSON(
      p_pretty_print      IN  INTEGER   DEFAULT NULL
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
      p_pretty_print      IN  INTEGER   DEFAULT 0
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_header_typ TO public;

