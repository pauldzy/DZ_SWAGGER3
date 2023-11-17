create or replace TYPE dz_swagger3_jsonobject_agg FORCE
AUTHID DEFINER 
AS OBJECT (
    jsonobject_vry        dz_swagger3_jsonobject_vry
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_jsonobject_agg
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_jsonobject_agg(
       p_jsonobject_vry      IN  dz_swagger3_jsonobject_vry
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON
    RETURN CLOB
   
);
/

GRANT EXECUTE ON dz_swagger3_jsonobject_agg TO public;

