CREATE OR REPLACE TYPE dz_swagger3_tag_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    tag_id              VARCHAR2(255 Char)
   ,tag_name            VARCHAR2(255 Char)
   ,tag_description     VARCHAR2(4000 Char)
   ,tag_externalDocs    dz_swagger3_object_typ --dz_swagger3_extrdocs_typ
   ,versionid           VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_tag_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_tag_typ(
       p_tag_id             IN  VARCHAR2
      ,p_versionid          IN  VARCHAR2
   ) RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE traverse
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON
    RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_tag_typ TO public;

