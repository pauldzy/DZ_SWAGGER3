CREATE OR REPLACE TYPE dz_swagger3_jsonobject_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    object_key          VARCHAR2(255 Char)
   ,object_value        CLOB
   ,object_order        INTEGER
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_jsonobject_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_jsonobject_typ(
       p_object_key          IN  VARCHAR2
      ,p_object_value        IN  CLOB
      ,p_object_order        IN  INTEGER
   ) RETURN SELF AS RESULT
   
);
/

GRANT EXECUTE ON dz_swagger3_jsonobject_typ TO public;

