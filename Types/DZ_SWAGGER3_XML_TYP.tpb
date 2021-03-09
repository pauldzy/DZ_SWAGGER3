CREATE OR REPLACE TYPE BODY dz_swagger3_xml_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_xml_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_xml_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_xml_typ(
       p_xml_name            IN  VARCHAR2 DEFAULT NULL
      ,p_xml_namespace       IN  VARCHAR2 DEFAULT NULL
      ,p_xml_prefix          IN  VARCHAR2 DEFAULT NULL
      ,p_xml_attribute       IN  VARCHAR2 DEFAULT NULL
      ,p_xml_wrapped         IN  VARCHAR2 DEFAULT NULL
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.xml_name         := p_xml_name;
      self.xml_namespace    := p_xml_namespace;
      self.xml_prefix       := p_xml_prefix;
      self.xml_attribute    := p_xml_attribute;
      self.xml_wrapped      := p_xml_wrapped;
      
      RETURN; 
      
   END dz_swagger3_xml_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON
   RETURN CLOB
   AS
      clb_output       CLOB;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the object
      --------------------------------------------------------------------------
      SELECT
      JSON_OBJECT(
          'name'         VALUE self.xml_name
         ,'namespace'    VALUE self.xml_namespace
         ,'prefix'       VALUE self.xml_prefix
         ,'attribute'    VALUE CASE
            WHEN LOWER(self.xml_attribute) = 'true'
            THEN
               'true'
            ELSE
               NULL
            END FORMAT JSON
         ,'wrapped'      VALUE CASE
            WHEN LOWER(self.xml_wrapped) = 'true'
            THEN
               'true'
            ELSE
               NULL
            END FORMAT JSON
         ABSENT ON NULL
         RETURNING CLOB
      )
      INTO clb_output
      FROM dual;

      --------------------------------------------------------------------------
      -- Step 30
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toJSON;
   
END;
/

