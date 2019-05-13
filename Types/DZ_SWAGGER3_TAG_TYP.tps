CREATE OR REPLACE TYPE dz_swagger3_tag_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    tag_id              VARCHAR2(255 Char)
   ,tag_name            VARCHAR2(255 Char)
   ,tag_description     VARCHAR2(4000 Char)
   ,tag_externalDocs    VARCHAR2(40 Char) --dz_swagger3_extrdocs_typ
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_tag_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_tag_typ(
       p_tag_id             IN  VARCHAR2
      ,p_tag_name           IN  VARCHAR2
      ,p_tag_description    IN  VARCHAR2
      ,p_tag_externalDocs   IN  VARCHAR2 --dz_swagger3_extrdocs_typ
      ,p_load_components    IN  VARCHAR2 DEFAULT 'TRUE'
   ) RETURN SELF AS RESULT
   
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

GRANT EXECUTE ON dz_swagger3_tag_typ TO public;

