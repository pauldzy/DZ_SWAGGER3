CREATE OR REPLACE TYPE BODY dz_swagger3_object_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_object_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_object_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_object_typ(
       p_object_id          IN  VARCHAR2
      ,p_object_type_id     IN  VARCHAR2
      ,p_object_subtype     IN  VARCHAR2 DEFAULT NULL
      ,p_object_attribute   IN  VARCHAR2 DEFAULT NULL
      ,p_object_key         IN  VARCHAR2 DEFAULT NULL
      ,p_object_hidden      IN  VARCHAR2 DEFAULT NULL
      ,p_object_required    IN  VARCHAR2 DEFAULT NULL
      ,p_object_order       IN  INTEGER  DEFAULT 10
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.object_id        := p_object_id;
      self.object_type_id   := p_object_type_id;
      self.object_subtype   := p_object_subtype;
      self.object_attribute := p_object_attribute;
      self.object_key       := p_object_key;
      self.object_hidden    := p_object_hidden;
      self.object_required  := p_object_required;
      self.object_order     := p_object_order;
      
      RETURN; 
      
   END dz_swagger3_object_typ;
   
END;
/

