CREATE OR REPLACE TYPE BODY dz_swagger3_jsonobject_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_jsonobject_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_jsonobject_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_jsonobject_typ(
       p_object_key          IN  VARCHAR2
      ,p_object_value        IN  CLOB
      ,p_object_order        IN  INTEGER
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.object_key       := p_object_key;
      self.object_value     := p_object_value;
      self.object_order     := p_object_order;
      
      RETURN; 
      
   END dz_swagger3_jsonobject_typ;
   
END;
/

