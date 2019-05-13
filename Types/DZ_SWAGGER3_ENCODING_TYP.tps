CREATE OR REPLACE TYPE dz_swagger3_encoding_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    encoding_id            VARCHAR2(255 Char)
   ,encoding_contentType   VARCHAR2(255 Char)
   ,encoding_headers       MDSYS.SDO_STRING2_ARRAY --dz_swagger3_header_list
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
       p_encoding_id            IN  VARCHAR2
      ,p_encoding_contentType   IN  VARCHAR2
      ,p_encoding_headers       IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_header_list
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
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,STATIC PROCEDURE loader(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  MDSYS.SDO_STRING2_ARRAY
      ,p_versionid           IN  VARCHAR2
   )

);
/

GRANT EXECUTE ON dz_swagger3_encoding_typ TO public;

