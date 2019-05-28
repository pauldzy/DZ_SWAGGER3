CREATE OR REPLACE TYPE dz_swagger3_encoding_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    encoding_id            VARCHAR2(255 Char)
   ,encoding_contentType   VARCHAR2(255 Char)
   ,encoding_headers       dz_swagger3_object_vry --dz_swagger3_header_list
   ,encoding_style         VARCHAR2(255 Char)
   ,encoding_explode       VARCHAR2(5 Char)
   ,encoding_allowReserved VARCHAR2(5 Char)
   ,versionid              VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_encoding_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_encoding_typ(
       p_encoding_id            IN  VARCHAR2
      ,p_versionid              IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE traverse
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print           IN  INTEGER   DEFAULT NULL
      ,p_force_inline           IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id               IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print           IN  INTEGER   DEFAULT 0
      ,p_initial_indent         IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed         IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline           IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id               IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_encoding_typ TO public;

