CREATE OR REPLACE TYPE dz_swagger3_info_license_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    license_name        VARCHAR2(255 Char)
   ,license_url         VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_info_license_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_info_license_typ(
       p_license_name     IN  VARCHAR2
      ,p_license_url      IN  VARCHAR2
   ) RETURN SELF AS RESULT

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION isNULL
    RETURN VARCHAR2
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
      p_force_inline         IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_info_license_typ TO public;

