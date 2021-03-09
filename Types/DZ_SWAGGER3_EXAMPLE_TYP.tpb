CREATE OR REPLACE TYPE BODY dz_swagger3_example_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_example_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_example_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_example_typ(
       p_example_id              IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS 
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10 
      -- Initialize the object
      --------------------------------------------------------------------------
      self.versionid := p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 20 
      -- Load the example self
      --------------------------------------------------------------------------
      SELECT
       a.example_id
      ,a.example_summary
      ,a.example_description
      ,a.example_value_string
      ,a.example_value_number
      ,a.example_externalValue
      INTO
       self.example_id
      ,self.example_summary
      ,self.example_description
      ,self.example_value_string
      ,self.example_value_number
      ,self.example_externalValue
      FROM
      dz_swagger3_example a
      WHERE
          a.versionid = p_versionid
      AND a.example_id = p_example_id;
   
      --------------------------------------------------------------------------
      -- Step 30 
      -- Return the object
      --------------------------------------------------------------------------
      RETURN; 
      
   END dz_swagger3_example_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN
      NULL;
      
   END traverse;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_identifier   VARCHAR2(4000 Char);
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------

      --------------------------------------------------------------------------
      -- Step 20
      -- Add  the ref object
      --------------------------------------------------------------------------
      IF  COALESCE(p_force_inline,'FALSE') = 'FALSE'
      AND p_reference_count > 1
      THEN
         IF p_short_id = 'TRUE'
         THEN
            str_identifier := p_short_identifier;
            
         ELSE
            str_identifier := p_identifier;
            
         END IF;
         
         SELECT
         JSON_OBJECT(
            '$ref'   VALUE  '#/components/examples/' || dz_swagger3_util.utl_url_escape(
               str_identifier
            )
         )
         INTO clb_output
         FROM dual;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Or run it as usual
      --------------------------------------------------------------------------
      ELSE
         IF self.example_value_string IS NOT NULL
         THEN
            SELECT
            JSON_OBJECT(
                'summary'       VALUE self.example_summary
               ,'description'   VALUE self.example_description
               ,'value'         VALUE self.example_value_string
               ,'externalValue' VALUE self.example_externalValue 
               ABSENT ON NULL
               RETURNING CLOB
            )
            INTO clb_output
            FROM dual;

         ELSIF self.example_value_number IS NOT NULL
         THEN
            SELECT
            JSON_OBJECT(
                'summary'       VALUE self.example_summary
               ,'description'   VALUE self.example_description
               ,'value'         VALUE self.example_value_number
               ,'externalValue' VALUE self.example_externalValue 
               ABSENT ON NULL
               RETURNING CLOB
            )
            INTO clb_output
            FROM dual;
            
         ELSE
            SELECT
            JSON_OBJECT(
                'summary'       VALUE self.example_summary
               ,'description'   VALUE self.example_description
               ,'externalValue' VALUE self.example_externalValue 
               ABSENT ON NULL
               RETURNING CLOB
            )
            INTO clb_output
            FROM dual;
            
         END IF;
 
      END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toJSON;
   
END;
/

