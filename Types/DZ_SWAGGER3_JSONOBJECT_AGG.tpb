CREATE OR REPLACE TYPE BODY dz_swagger3_jsonobject_agg
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_jsonobject_agg
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_jsonobject_agg;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_jsonobject_agg(
       p_jsonobject_vry         IN  dz_swagger3_jsonobject_vry
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.jsonobject_vry      := p_jsonobject_vry;
      
      RETURN; 
      
   END dz_swagger3_jsonobject_agg;
   
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
      clb_output := '';
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the object
      --------------------------------------------------------------------------
      FOR rec IN (
         SELECT
         *
         FROM
         TABLE(self.jsonobject_vry) a
         ORDER BY
         a.object_order
      )
      LOOP
         IF clb_output IS NULL
         THEN
            clb_output := clb_output || '{';
            
         ELSE
            clb_output := clb_output || ',';
         
         END IF;
         
         clb_output := clb_output || '"' || rec.object_key || '":' || rec.object_value;
         
      END LOOP;
      
      clb_output := clb_output || '}';

      --------------------------------------------------------------------------
      -- Step 30
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toJSON;
   
END;
/

