CREATE OR REPLACE TYPE dz_swagger3_header_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    hash_key                VARCHAR2(255 Char)
   ,header_id               VARCHAR2(255 Char)
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
       p_hash_key               IN  VARCHAR2
      ,p_header_id              IN  VARCHAR2
      ,p_header_description     IN  VARCHAR2
      ,p_header_required        IN  VARCHAR2
      ,p_header_deprecated      IN  VARCHAR2
      ,p_header_allowEmptyValue IN  VARCHAR2
      ,p_header_style           IN  VARCHAR2
      ,p_header_explode         IN  VARCHAR2
      ,p_header_allowReserved   IN  VARCHAR2
      ,p_header_schema          IN  dz_swagger3_schema_typ
      ,p_header_example_string  IN  VARCHAR2
      ,p_header_example_number  IN  NUMBER
      ,p_header_examples        IN  dz_swagger3_example_list
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
   ,MEMBER FUNCTION doRef
    RETURN VARCHAR2
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION header_examples_keys
    RETURN MDSYS.SDO_STRING2_ARRAY
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
      p_pretty_print      IN  INTEGER   DEFAULT NULL
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON_schema(
      p_pretty_print      IN  INTEGER   DEFAULT NULL
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON_ref(
      p_pretty_print      IN  INTEGER   DEFAULT NULL
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
   ) RETURN CLOB
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML_schema(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
   ) RETURN CLOB
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML_ref(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_header_typ TO public;

