CREATE OR REPLACE TYPE dz_swagger3_info_contact_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    contact_name        VARCHAR2(255 Char)
   ,contact_url         VARCHAR2(255 Char)
   ,contact_email       VARCHAR2(255 Char)

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_info_contact_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_info_contact_typ(
       p_contact_name        IN  VARCHAR2
      ,p_contact_url         IN  VARCHAR2
      ,p_contact_email       IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION isNULL
    RETURN VARCHAR2
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON
    RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_info_contact_typ TO public;

