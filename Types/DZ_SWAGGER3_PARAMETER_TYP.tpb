CREATE OR REPLACE TYPE BODY dz_swagger3_parameter_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_parameter_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_parameter_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_parameter_typ(
       p_parameter_id              IN  VARCHAR2
      ,p_versionid                 IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS      
   BEGIN

      --------------------------------------------------------------------------
      -- Step 10 
      -- Initialize the object
      --------------------------------------------------------------------------
      --dbms_output.put_line('parameter: ' || p_parameter_id);
      self.versionid := p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 20 
      -- Load the parameter self and schema id
      --------------------------------------------------------------------------
      BEGIN
         SELECT
          a.parameter_id
         ,a.parameter_name
         ,a.parameter_in
         ,a.parameter_description
         ,a.parameter_required
         ,a.parameter_deprecated
         ,a.parameter_allowEmptyValue
         ,a.parameter_style
         ,a.parameter_explode
         ,a.parameter_allowReserved
         ,CASE
          WHEN a.parameter_schema_id IS NOT NULL
          THEN
            dz_swagger3_object_typ(
                p_object_id      => a.parameter_schema_id
               ,p_object_type_id => 'schematyp'
            )
          ELSE
            NULL
          END
         ,a.parameter_example_string
         ,a.parameter_example_number
         ,a.parameter_force_inline
         ,a.parameter_list_hidden
         INTO
          self.parameter_id
         ,self.parameter_name
         ,self.parameter_in
         ,self.parameter_description
         ,self.parameter_required
         ,self.parameter_deprecated
         ,self.parameter_allowEmptyValue
         ,self.parameter_style
         ,self.parameter_explode
         ,self.parameter_allowReserved
         ,self.parameter_schema
         ,self.parameter_example_string
         ,self.parameter_example_number
         ,self.parameter_force_inline
         ,self.parameter_list_hidden
         FROM
         dz_swagger3_parameter a
         WHERE
             a.versionid    = p_versionid
         AND a.parameter_id = p_parameter_id;

      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RAISE_APPLICATION_ERROR(
                -20001
               ,'Missing parameter ' || p_parameter_id
            );
            
         WHEN OTHERS
         THEN
            RAISE;
            
      END;
      
      --------------------------------------------------------------------------
      -- Step 30 
      -- Load any example ids
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id      => a.example_id
         ,p_object_type_id => 'exampletyp'
         ,p_object_key     => a.example_name
         ,p_object_order   => a.example_order
      )
      BULK COLLECT INTO self.parameter_examples
      FROM
      dz_swagger3_parent_example_map a
      WHERE
          a.parent_id = p_parameter_id
      AND a.versionid = p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 40 
      -- Return the object
      --------------------------------------------------------------------------
      RETURN;

   END;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Load the parameter schema
      --------------------------------------------------------------------------
      dz_swagger3_loader.schematyp(
          p_parent_id    => self.parameter_id
         ,p_children_ids => dz_swagger3_object_vry(self.parameter_schema)
         ,p_versionid    => self.versionid
      );
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Load the examples
      --------------------------------------------------------------------------
      IF  self.parameter_examples IS NOT NULL
      AND self.parameter_examples.COUNT > 0
      THEN
         dz_swagger3_loader.exampletyp(
             p_parent_id    => self.parameter_id
            ,p_children_ids => self.parameter_examples
            ,p_versionid    => self.versionid
         );
         
      END IF;  

   END traverse;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_force_inline              IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id                  IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier                IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count           IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output             CLOB;
      str_identifier         VARCHAR2(4000 Char);
      clb_parameter_schema   CLOB;
      clb_parameter_examples CLOB;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Add the ref object
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
            '$ref' VALUE '#/components/parameters/' || str_identifier
         )
         INTO clb_output
         FROM dual;
      
      ELSE
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional schema attribute
      --------------------------------------------------------------------------
         IF self.parameter_schema IS NOT NULL
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
               INTO clb_parameter_schema
               FROM
               dz_swagger3_xobjects a
               WHERE
                   a.object_type_id = self.parameter_schema.object_type_id
               AND a.object_id      = self.parameter_schema.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_parameter_schema := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;

         END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional variables map
      --------------------------------------------------------------------------
         IF  self.parameter_examples IS NOT NULL 
         AND self.parameter_examples.COUNT > 0
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
               RETURNING CLOB
            )
            INTO clb_parameter_examples
            FROM
            dz_swagger3_xobjects a
            JOIN
            TABLE(self.parameter_examples) b
            ON
                a.object_type_id = b.object_type_id
            AND a.object_id      = b.object_id
            ORDER BY b.object_order;
 
         END IF;
         
      --------------------------------------------------------------------------
      -- Step 50
      -- Build the object
      --------------------------------------------------------------------------
         IF self.parameter_example_string IS NOT NULL
         THEN 
            SELECT
            JSON_OBJECT(
                'name'            VALUE self.parameter_name
               ,'in'              VALUE self.parameter_in
               ,'description'     VALUE self.parameter_description
               ,'required'        VALUE CASE
                  WHEN LOWER(self.parameter_required) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_required) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'deprecated'      VALUE CASE
                  WHEN LOWER(self.parameter_deprecated) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_deprecated) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'allowEmptyValue' VALUE CASE
                  WHEN LOWER(self.parameter_allowEmptyValue) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_allowEmptyValue) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'style'           VALUE self.parameter_style
               ,'explode'         VALUE CASE
                  WHEN LOWER(self.parameter_explode) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_explode) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'allowReserved'   VALUE CASE
                  WHEN LOWER(self.parameter_allowReserved) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_allowReserved) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'schema'          VALUE clb_parameter_schema       FORMAT JSON
               ,'example'         VALUE self.parameter_example_string
               ABSENT ON NULL
               RETURNING CLOB
            )
            INTO clb_output
            FROM dual;
            
         ELSIF self.parameter_example_number IS NOT NULL
         THEN
            SELECT
            JSON_OBJECT(
                'name'            VALUE self.parameter_name
               ,'in'              VALUE self.parameter_in
               ,'description'     VALUE self.parameter_description
               ,'required'        VALUE CASE
                  WHEN LOWER(self.parameter_required) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_required) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'deprecated'      VALUE CASE
                  WHEN LOWER(self.parameter_deprecated) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_deprecated) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'allowEmptyValue' VALUE CASE
                  WHEN LOWER(self.parameter_allowEmptyValue) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_allowEmptyValue) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'style'           VALUE self.parameter_style
               ,'explode'         VALUE CASE
                  WHEN LOWER(self.parameter_explode) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_explode) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'allowReserved'   VALUE CASE
                  WHEN LOWER(self.parameter_allowReserved) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_allowReserved) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'schema'          VALUE clb_parameter_schema       FORMAT JSON
               ,'example'         VALUE self.parameter_example_number
               ABSENT ON NULL
               RETURNING CLOB
            )
            INTO clb_output
            FROM dual;
            
         ELSE
            SELECT
            JSON_OBJECT(
                'name'            VALUE self.parameter_name
               ,'in'              VALUE self.parameter_in
               ,'description'     VALUE self.parameter_description
               ,'required'        VALUE CASE
                  WHEN LOWER(self.parameter_required) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_required) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'deprecated'      VALUE CASE
                  WHEN LOWER(self.parameter_deprecated) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_deprecated) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'allowEmptyValue' VALUE CASE
                  WHEN LOWER(self.parameter_allowEmptyValue) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_allowEmptyValue) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'style'           VALUE self.parameter_style
               ,'explode'         VALUE CASE
                  WHEN LOWER(self.parameter_explode) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_explode) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'allowReserved'   VALUE CASE
                  WHEN LOWER(self.parameter_allowReserved) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_allowReserved) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'schema'          VALUE clb_parameter_schema       FORMAT JSON
               ,'examples'        VALUE clb_parameter_examples     FORMAT JSON
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

