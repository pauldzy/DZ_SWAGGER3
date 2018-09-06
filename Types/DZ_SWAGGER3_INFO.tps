CREATE OR REPLACE TYPE dz_swagger3_info FORCE
AUTHID DEFINER 
AS OBJECT (
    title              VARCHAR2(255 Char)
   ,description        VARCHAR2(4000 Char)
   ,termsofservice     VARCHAR2(255 Char)
   ,contact            dz_swagger3_info_contact
   ,license            dz_swagger3_info_license
   ,version            VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_info 
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_info(
       p_title          IN  VARCHAR2
      ,p_description    IN  VARCHAR2
      ,p_termsofservice IN  VARCHAR2
      ,p_contact        IN  dz_swagger3_info_contact
      ,p_license        IN  dz_swagger3_info_license
      ,p_version        IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION isNULL
    RETURN VARCHAR2
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
      p_pretty_print         IN  NUMBER   DEFAULT NULL
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
      p_pretty_print         IN  NUMBER   DEFAULT 0
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_info TO public;

