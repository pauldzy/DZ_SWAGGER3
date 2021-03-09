CREATE OR REPLACE TYPE dz_swagger3_extrdocs_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    externaldoc_id          VARCHAR2(255 Char)
   ,externaldoc_description VARCHAR2(4000 Char)
   ,externaldoc_url         VARCHAR2(255 Char)
   ,versionid               VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_extrdocs_typ
    RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_extrdocs_typ(
       p_externaldoc_id          IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
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

GRANT EXECUTE ON dz_swagger3_extrdocs_typ TO public;

