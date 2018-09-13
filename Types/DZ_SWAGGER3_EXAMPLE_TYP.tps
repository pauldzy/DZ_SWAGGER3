CREATE OR REPLACE TYPE dz_swagger3_example_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    hash_key              VARCHAR2(255 Char)
   ,example_summary       VARCHAR2(255 Char)
   ,example_description   VARCHAR2(4000 Char)
   ,example_value_string  VARCHAR2(255 Char)
   ,example_value_number  NUMBER
   ,example_externalValue VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_example_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_example_typ(
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

GRANT EXECUTE ON dz_swagger3_example_typ TO public;
