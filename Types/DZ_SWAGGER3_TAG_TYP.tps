CREATE OR REPLACE TYPE dz_swagger3_tag_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    tag_name            VARCHAR2(255 Char)
   ,tag_description     VARCHAR2(4000 Char)
   ,tag_externalDocs    dz_swagger3_extrdocs_typ
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_tag_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_tag_typ(
       p_tag_name           IN  VARCHAR2
      ,p_tag_description    IN  VARCHAR2
      ,p_tag_externalDocs   IN  dz_swagger3_extrdocs_typ
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION isNULL
    RETURN VARCHAR2
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
      p_pretty_print      IN  NUMBER   DEFAULT NULL
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
      p_pretty_print      IN  NUMBER   DEFAULT 0
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_tag_typ TO public;

