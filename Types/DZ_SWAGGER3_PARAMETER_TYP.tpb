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
            '$ref' VALUE '#/components/parameters/' || dz_swagger3_util.utl_url_escape(
               str_identifier
            )
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
               ,'examples'        VALUE clb_parameter_examples     FORMAT JSON
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
               ,'examples'        VALUE clb_parameter_examples     FORMAT JSON
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
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      cb               CLOB;
      v2               VARCHAR2(32000);
      
      ary_keys         dz_swagger3_string_vry;
      clb_tmp          CLOB;
      str_identifier   VARCHAR2(255 Char);
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
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
         
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => '$ref: ' || dz_swagger3_util.yaml_text(
               '#/components/parameters/' || str_identifier
             )
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );
  
      ELSE
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the mandatory parameter name
      --------------------------------------------------------------------------
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => 'name: ' || dz_swagger3_util.yaml_text(
                self.parameter_name
               ,p_pretty_print
             )
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the mandatory parameter in attribute
      --------------------------------------------------------------------------
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => 'in: ' || dz_swagger3_util.yaml_text(
                self.parameter_in
               ,p_pretty_print
             )
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the optional description attribute
      --------------------------------------------------------------------------
         IF self.parameter_description IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'description: ' || dz_swagger3_util.yaml_text(
                   self.parameter_description
                  ,p_pretty_print
                )
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional required attribute
      --------------------------------------------------------------------------
         IF self.parameter_required IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'required: ' || LOWER(self.parameter_required)
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the optional deprecated attribute
      --------------------------------------------------------------------------
         IF self.parameter_deprecated IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'deprecated: ' || LOWER(self.parameter_deprecated)
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the optional allowEmptyValue attribute
      --------------------------------------------------------------------------
         IF self.parameter_allowEmptyValue IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'allowEmptyValue: ' || LOWER(self.parameter_allowEmptyValue)
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Write the optional style attribute
      --------------------------------------------------------------------------
         IF self.parameter_style IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'style: ' || dz_swagger3_util.yaml_text(
                   self.parameter_style
                  ,p_pretty_print
                )
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Write the optional explode attribute
      --------------------------------------------------------------------------
         IF self.parameter_explode IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'explode: ' || LOWER(self.parameter_explode)
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Write the optional allowReserved attribute
      --------------------------------------------------------------------------
         IF self.parameter_allowReserved IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'allowReserved: ' || LOWER(self.parameter_allowReserved)
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Write the optional schema subobject
      --------------------------------------------------------------------------
         IF  self.parameter_schema IS NOT NULL
         AND self.parameter_schema.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT
               a.schematyp.toYAML(
                   p_pretty_print     => p_pretty_print + 1
                  ,p_force_inline     => p_force_inline
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_reference_count  => a.reference_count
               )
               INTO clb_tmp
               FROM
               dz_swagger3_xobjects a
               WHERE
                   a.object_type_id = self.parameter_schema.object_type_id
               AND a.object_id      = self.parameter_schema.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;

            END;
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'schema: '
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => clb_tmp
               ,p_in_v => NULL
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Write the optional examples map
      --------------------------------------------------------------------------
         IF  self.parameter_examples IS NOT NULL 
         AND self.parameter_examples.COUNT > 0
         THEN
            SELECT
             a.exampletyp.toYAML(
                p_pretty_print     => p_pretty_print + 2
               ,p_force_inline     => p_force_inline
               ,p_short_id         => p_short_id
               ,p_identifier       => a.object_id
               ,p_short_identifier => a.short_id
               ,p_reference_count  => a.reference_count
             )
            ,b.object_key
            BULK COLLECT INTO 
             ary_clb
            ,ary_keys
            FROM
            dz_swagger3_xobjects a
            JOIN
            TABLE(self.parameter_examples) b
            ON
                a.object_type_id = b.object_type_id
            AND a.object_id      = b.object_id
            ORDER BY b.object_order; 
            
            IF  ary_keys IS NOT NULL
            AND ary_keys.COUNT > 0
            THEN
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v => 'examples: '
                  ,p_pretty_print => p_pretty_print
                  ,p_amount       => '  '
               );
               
               FOR i IN 1 .. ary_keys.COUNT
               LOOP
                  dz_swagger3_util.conc(
                      p_c    => cb
                     ,p_v    => v2
                     ,p_in_c => NULL
                     ,p_in_v => dz_swagger3_util.yamlq(ary_keys(i)) || ': '
                     ,p_pretty_print => p_pretty_print + 1
                     ,p_amount       => '  '
                  );
                  
                  dz_swagger3_util.conc(
                      p_c    => cb
                     ,p_v    => v2
                     ,p_in_c => ary_clb(i)
                     ,p_in_v => NULL
                  );
               
               END LOOP;
                  
            END IF;
         
         ELSE
      --------------------------------------------------------------------------
      -- Step 100
      -- Write the optional examples values
      --------------------------------------------------------------------------
            IF self.parameter_example_string IS NOT NULL
            THEN
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v => 'example: ' || dz_swagger3_util.yaml_text(
                      self.parameter_example_string
                     ,p_pretty_print
                   )
                  ,p_pretty_print => p_pretty_print
                  ,p_amount       => '  '
               );
               
            ELSIF self.parameter_example_number IS NOT NULL
            THEN
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v => 'example: ' || dz_swagger3_util.yaml_text(
                      self.parameter_example_number
                     ,p_pretty_print
                   )
                  ,p_pretty_print => p_pretty_print
                  ,p_amount       => '  '
               );
               
            END IF;
      
         END IF;
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Cough it out without final line feed
      --------------------------------------------------------------------------
      dz_swagger3_util.fconc(
          p_c    => cb
         ,p_v    => v2
      );
      
      IF p_initial_indent = 'FALSE'
      THEN
         cb := REGEXP_REPLACE(cb,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         cb := REGEXP_REPLACE(cb,CHR(10) || '$','');
         
      END IF;
               
      RETURN cb;
      
   END toYAML;
   
END;
/

