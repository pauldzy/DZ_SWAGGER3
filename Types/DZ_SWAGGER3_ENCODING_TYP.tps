CREATE OR REPLACE TYPE dz_swagger3_encoding_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    hash_key               VARCHAR2(255 Char)
   ,encoding_contentType   VARCHAR2(255 Char)
   ,encoding_headers       dz_swagger3_header_list
   ,encoding_style         VARCHAR2(255 Char)
   ,encoding_explode       VARCHAR2(5 Char)
   ,encoding_allowReserved VARCHAR2(5 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_encoding_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_encoding_typ(
       p_hash_key               IN  VARCHAR2
      ,p_encoding_contentType   IN  VARCHAR2
      ,p_encoding_headers       IN  dz_swagger3_header_list
      ,p_encoding_style         IN  VARCHAR2
      ,p_encoding_explode       IN  VARCHAR2
      ,p_encoding_allowReserved IN  VARCHAR2
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

GRANT EXECUTE ON dz_swagger3_encoding_typ TO public;

