CREATE OR REPLACE TYPE dz_swagger3_media_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    hash_key                 VARCHAR2(255 Char)
   ,media_schema             dz_swagger3_schema_typ
   ,media_example_string     VARCHAR2(4000 Char)
   ,media_example_number     NUMBER
   ,media_examples           dz_swagger3_example_list
   ,media_encoding           dz_swagger3_encoding_list
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_media_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_media_typ(
       p_media_id                IN  VARCHAR2
      ,p_media_type              IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_media_typ(
       p_hash_key                IN  VARCHAR2
      ,p_media_schema            IN  dz_swagger3_schema_typ
      ,p_media_example_string    IN  VARCHAR2
      ,p_media_example_number    IN  NUMBER
      ,p_media_examples          IN  dz_swagger3_example_list
      ,p_media_encoding          IN  dz_swagger3_encoding_list
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION isNULL
    RETURN VARCHAR2
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION key
    RETURN VARCHAR2
    
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   ,MEMBER FUNCTION unique_schemas
    RETURN dz_swagger3_schema_nf_list
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION media_examples_keys
    RETURN MDSYS.SDO_STRING2_ARRAY
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION media_encoding_keys
    RETURN MDSYS.SDO_STRING2_ARRAY
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
      p_pretty_print      IN  INTEGER   DEFAULT NULL
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_media_typ TO public;

