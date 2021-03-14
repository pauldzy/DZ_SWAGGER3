CREATE OR REPLACE TYPE BODY dz_swagger3_header_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_header_typ
   RETURN SELF AS RESULT 
   AS
   BEGIN 
      RETURN; 
      
   END dz_swagger3_header_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_header_typ(
       p_header_id               IN  VARCHAR2
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
      -- Pull the attributes
      --------------------------------------------------------------------------
      SELECT
       a.header_id
      ,a.header_description
      ,a.header_required
      ,a.header_deprecated
      ,a.header_allowEmptyValue
      ,a.header_style
      ,a.header_explode
      ,a.header_allowReserved
      ,dz_swagger3_object_typ(
          p_object_id         => a.header_schema_id
         ,p_object_type_id    => 'schematyp'
         ,p_object_required   => 'TRUE'
       )
      ,a.header_example_string
      ,a.header_example_number
      INTO
       self.header_id
      ,self.header_description
      ,self.header_required
      ,self.header_deprecated
      ,self.header_allowEmptyValue
      ,self.header_style
      ,self.header_explode
      ,self.header_allowReserved
      ,self.header_schema
      ,self.header_example_string
      ,self.header_example_number
      FROM
      dz_swagger3_header a
      WHERE
          a.versionid = p_versionid
      AND a.header_id = p_header_id;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Pull the examples
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id      => a.example_id
         ,p_object_type_id => 'exampletyp'
         ,p_object_order   => a.example_order
      )
      BULK COLLECT INTO self.header_examples
      FROM
      dz_swagger3_parent_example_map a
      WHERE
          a.parent_id = p_header_id
      AND a.versionid = p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Return then object
      --------------------------------------------------------------------------
      RETURN; 
      
   END dz_swagger3_header_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Traverse the schema
      --------------------------------------------------------------------------
      IF  self.header_schema IS NOT NULL
      AND self.header_schema.object_id IS NOT NULL
      THEN
         dz_swagger3_loader.schematyp(
             p_parent_id    => self.header_id
            ,p_children_ids => dz_swagger3_object_vry(self.header_schema)
            ,p_versionid    => self.versionid
         );
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Traverse the examples
      --------------------------------------------------------------------------
      IF  self.header_examples IS NOT NULL
      AND self.header_examples.COUNT > 0
      THEN
         dz_swagger3_loader.headertyp(
             p_parent_id    => self.header_id
            ,p_children_ids => self.header_examples
            ,p_versionid    => self.versionid
         );
      
      END IF;
      
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
      clb_output          CLOB;
      str_identifier      VARCHAR2(4000 Char);
      clb_header_examples CLOB;
      clb_header_schema   CLOB;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build refs
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
            '$ref' VALUE '#/components/headers/' || str_identifier
         )
         INTO clb_output
         FROM dual;
      
      ELSE
      --------------------------------------------------------------------------
      -- Step 30
      -- Generate optional header examples
      --------------------------------------------------------------------------
         IF  self.header_examples IS NOT NULL 
         AND self.header_examples.COUNT > 0
         THEN
            SELECT
            JSON_OBJECTAGG(
               b.object_key VALUE a.exampletyp.toJSON(
                   p_force_inline     => p_force_inline
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_reference_count  => a.reference_count
               ) FORMAT JSON
               ABSENT ON NULL
               RETURNING CLOB
            )
            INTO clb_header_examples
            FROM
            dz_swagger3_xobjects a
            JOIN
            TABLE(self.header_examples) b
            ON
                a.object_type_id = b.object_type_id
            AND a.object_id      = b.object_id; 

         END IF;
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional header schema
      --------------------------------------------------------------------------
         IF self.header_schema IS NOT NULL
         THEN
            BEGIN
               SELECT
               a.schematyp.toJSON(
                   p_force_inline     => p_force_inline
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_reference_count  => a.reference_count
               )
               INTO clb_header_schema
               FROM
               dz_swagger3_xobjects a
               WHERE
                   a.object_type_id = self.header_schema.object_type_id
               AND a.object_id      = self.header_schema.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_header_schema := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;

         END IF;
         
      --------------------------------------------------------------------------
      -- Step 50
      -- Build the output object
      --------------------------------------------------------------------------
         IF self.header_example_string IS NOT NULL
         THEN
            SELECT
            JSON_OBJECT(
                'description'     VALUE self.header_description
               ,'required'        VALUE CASE
                  WHEN LOWER(self.header_required) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_required) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'deprecated'      VALUE CASE
                  WHEN LOWER(self.header_deprecated) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_deprecated) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'allowEmptyValue' VALUE CASE
                  WHEN LOWER(self.header_allowEmptyValue) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_allowEmptyValue) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'style'            VALUE self.header_style
               ,'explode'          VALUE CASE
                  WHEN LOWER(self.header_explode) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_explode) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'allowReserved'    VALUE CASE
                  WHEN LOWER(self.header_allowReserved) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_allowReserved) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'schema'           VALUE clb_header_schema      FORMAT JSON
               ,'example'          VALUE self.header_example_string
               ABSENT ON NULL
               RETURNING CLOB
            )
            INTO clb_output
            FROM dual;
            
         ELSIF self.header_example_number IS NOT NULL
         THEN
            SELECT
            JSON_OBJECT(
                'description'     VALUE self.header_description
               ,'required'        VALUE CASE
                  WHEN LOWER(self.header_required) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_required) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'deprecated'      VALUE CASE
                  WHEN LOWER(self.header_deprecated) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_deprecated) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'allowEmptyValue' VALUE CASE
                  WHEN LOWER(self.header_allowEmptyValue) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_allowEmptyValue) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'style'            VALUE self.header_style
               ,'explode'          VALUE CASE
                  WHEN LOWER(self.header_explode) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_explode) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'allowReserved'    VALUE CASE
                  WHEN LOWER(self.header_allowReserved) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_allowReserved) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'schema'           VALUE clb_header_schema      FORMAT JSON
               ,'example'          VALUE self.header_example_number
               ABSENT ON NULL
               RETURNING CLOB
            )
            INTO clb_output
            FROM dual;
            
         ELSE
            SELECT
            JSON_OBJECT(
                'description'     VALUE self.header_description
               ,'required'        VALUE CASE
                  WHEN LOWER(self.header_required) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_required) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'deprecated'      VALUE CASE
                  WHEN LOWER(self.header_deprecated) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_deprecated) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'allowEmptyValue' VALUE CASE
                  WHEN LOWER(self.header_allowEmptyValue) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_allowEmptyValue) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'style'            VALUE self.header_style
               ,'explode'          VALUE CASE
                  WHEN LOWER(self.header_explode) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_explode) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'allowReserved'    VALUE CASE
                  WHEN LOWER(self.header_allowReserved) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_allowReserved) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'schema'           VALUE clb_header_schema      FORMAT JSON
               ,'examples'         VALUE clb_header_examples    FORMAT JSON
               ABSENT ON NULL
               RETURNING CLOB
            )
            INTO clb_output
            FROM dual;
            
         END IF;

      END IF;

      --------------------------------------------------------------------------
      -- Step 60
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toJSON;
   
END;
/

