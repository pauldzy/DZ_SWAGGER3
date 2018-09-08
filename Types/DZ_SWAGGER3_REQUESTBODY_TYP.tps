CREATE OR REPLACE TYPE dz_swagger3_requestbody_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    hash_key                 VARCHAR2(255 Char)
   ,requestbody_description  VARCHAR2(4000 Char)
   ,requestbody_content      dz_swagger3_media_list
   ,requestbody_required     VARCHAR2(5 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_requestbody_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_requestbody_typ(
       p_hash_key                IN  VARCHAR2
      ,p_requestbody_description IN  VARCHAR2
      ,p_requestbody_content     IN  dz_swagger3_media_list
      ,p_requestbody_required    IN  VARCHAR2
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
      p_pretty_print      IN  INTEGER   DEFAULT NULL
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
      p_pretty_print      IN  INTEGER   DEFAULT 0
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_requestbody_typ TO public;

