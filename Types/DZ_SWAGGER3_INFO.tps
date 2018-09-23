CREATE OR REPLACE TYPE dz_swagger3_info FORCE
AUTHID DEFINER 
AS OBJECT (
    info_title           VARCHAR2(255 Char)
   ,info_description     VARCHAR2(4000 Char)
   ,info_termsofservice  VARCHAR2(255 Char)
   ,info_contact         dz_swagger3_info_contact
   ,info_license         dz_swagger3_info_license
   ,info_version         VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_info 
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_info(
       p_doc_id         IN  VARCHAR2
      ,p_versionid      IN  VARCHAR2
   ) RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_info(
       p_info_title          IN  VARCHAR2
      ,p_info_description    IN  VARCHAR2
      ,p_info_termsofservice IN  VARCHAR2
      ,p_info_contact        IN  dz_swagger3_info_contact
      ,p_info_license        IN  dz_swagger3_info_license
      ,p_info_version        IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION isNULL
    RETURN VARCHAR2
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
      p_pretty_print         IN  INTEGER   DEFAULT NULL
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

GRANT EXECUTE ON dz_swagger3_info TO public;

