CREATE OR REPLACE TYPE dz_swagger3_object_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    object_id           VARCHAR2(255 Char)
   ,object_type_id      VARCHAR2(255 Char)
   ,object_subtype      VARCHAR2(255 Char)
   ,object_attribute    VARCHAR2(255 Char)
   ,object_key          VARCHAR2(255 Char)
   ,object_hidden       VARCHAR2(5 Char)
   ,object_required     VARCHAR2(5 Char)
   ,object_force_inline VARCHAR2(5 Char)
   ,object_order        INTEGER
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_object_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_object_typ(
       p_object_id           IN  VARCHAR2
      ,p_object_type_id      IN  VARCHAR2
      ,p_object_subtype      IN  VARCHAR2 DEFAULT NULL
      ,p_object_attribute    IN  VARCHAR2 DEFAULT NULL
      ,p_object_key          IN  VARCHAR2 DEFAULT NULL
      ,p_object_hidden       IN  VARCHAR2 DEFAULT NULL
      ,p_object_required     IN  VARCHAR2 DEFAULT NULL
      ,p_object_force_inline IN  VARCHAR2 DEFAULT NULL
      ,p_object_order        IN  INTEGER  DEFAULT 10
   ) RETURN SELF AS RESULT

);
/

GRANT EXECUTE ON dz_swagger3_object_typ TO public;

