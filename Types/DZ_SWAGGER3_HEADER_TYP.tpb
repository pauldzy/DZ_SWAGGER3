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
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      cb               CLOB;
      v2               VARCHAR2(32000);
      
      boo_temp         BOOLEAN;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_tmp          CLOB;
      str_identifier   VARCHAR2(255 Char);
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => dz_json_util.pretty('{',NULL)
         );

      ELSE
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => dz_json_util.pretty('{',-1)
         );
         str_pad     := ' ';

      END IF;
      str_pad1 := str_pad;

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
            ,p_in_v => str_pad1 || dz_json_main.value2json(
                '$ref'
               ,'#/components/headers/' || dz_swagger3_util.utl_url_escape(
                  str_identifier
                )
               ,p_pretty_print + 1
            )
            ,p_pretty_print => p_pretty_print + 1
         );
         str_pad1 := ',';
      
      ELSE
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional summary
      --------------------------------------------------------------------------
         IF self.header_description IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => str_pad1 || dz_json_main.value2json(
                   'description'
                  ,self.header_description
                  ,p_pretty_print + 1
                )
               ,p_pretty_print => p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional description 
      --------------------------------------------------------------------------
         IF self.header_required IS NOT NULL
         THEN
            IF LOWER(self.header_required) = 'true'
            THEN
               boo_temp := TRUE;
               
            ELSE
               boo_temp := FALSE;
               
            END IF;
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => str_pad1 || dz_json_main.value2json(
                   'required'
                  ,boo_temp
                  ,p_pretty_print + 1
                )
               ,p_pretty_print => p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
         
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional description 
      --------------------------------------------------------------------------
         IF self.header_deprecated IS NOT NULL
         THEN
            IF LOWER(self.header_deprecated) = 'true'
            THEN
               boo_temp := TRUE;
               
            ELSE
               boo_temp := FALSE;
               
            END IF;
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => str_pad1 || dz_json_main.value2json(
                   'deprecated'
                  ,boo_temp
                  ,p_pretty_print + 1
                )
               ,p_pretty_print => p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add optional description 
      --------------------------------------------------------------------------
         IF self.header_allowEmptyValue IS NOT NULL
         THEN
            IF LOWER(self.header_allowEmptyValue) = 'true'
            THEN
               boo_temp := TRUE;
               
            ELSE
               boo_temp := FALSE;
               
            END IF;
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => str_pad1 || dz_json_main.value2json(
                   'allowEmptyValue'
                  ,boo_temp
                  ,p_pretty_print + 1
                )
               ,p_pretty_print => p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Add optional value
      --------------------------------------------------------------------------
         IF self.header_style IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => str_pad1 || dz_json_main.value2json(
                   'style'
                  ,self.header_style
                  ,p_pretty_print + 1
                )
               ,p_pretty_print => p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Add optional description 
      --------------------------------------------------------------------------
         IF self.header_explode IS NOT NULL
         THEN
            IF LOWER(self.header_explode) = 'true'
            THEN
               boo_temp := TRUE;
               
            ELSE
               boo_temp := FALSE;
               
            END IF;
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => str_pad1 || dz_json_main.value2json(
                   'explode'
                  ,boo_temp
                  ,p_pretty_print + 1
                )
               ,p_pretty_print => p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Add optional description 
      --------------------------------------------------------------------------
         IF self.header_allowReserved IS NOT NULL
         THEN
            IF LOWER(self.header_allowReserved) = 'true'
            THEN
               boo_temp := TRUE;
               
            ELSE
               boo_temp := FALSE;
               
            END IF;
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => str_pad1 || dz_json_main.value2json(
                   'allowReserved'
                  ,boo_temp
                  ,p_pretty_print + 1
                )
               ,p_pretty_print => p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Add optional externalValue
      --------------------------------------------------------------------------
         IF self.header_schema IS NOT NULL
         THEN
            BEGIN
               SELECT
               a.schematyp.toJSON(
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
                   a.object_type_id = self.header_schema.object_type_id
               AND a.object_id      = self.header_schema.object_id;
               
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
               ,p_in_v => str_pad1 || '"schema":' || str_pad
               ,p_pretty_print => p_pretty_print + 1
               ,p_final_linefeed => FALSE
            );
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => clb_tmp
               ,p_in_v => NULL
               ,p_pretty_print => p_pretty_print + 1
               ,p_initial_indent => FALSE
            );
            
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Add optional example
      --------------------------------------------------------------------------
         IF self.header_example_string IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => str_pad1 || dz_json_main.value2json(
                   'example'
                  ,self.header_example_string
                  ,p_pretty_print + 1
                )
               ,p_pretty_print => p_pretty_print + 1
            );
            str_pad1 := ',';

         ELSIF self.header_example_number IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => str_pad1 || dz_json_main.value2json(
                   'example'
                  ,self.header_example_number
                  ,p_pretty_print + 1
                )
               ,p_pretty_print => p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Add optional variables map
      --------------------------------------------------------------------------
         IF  self.header_examples IS NOT NULL 
         AND self.header_examples.COUNT > 0
         THEN
            SELECT
             a.exampletyp.toJSON(
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
            TABLE(self.header_examples) b
            ON
                a.object_type_id = b.object_type_id
            AND a.object_id      = b.object_id
            ORDER BY b.object_order; 
            
            str_pad2 := str_pad;
         
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => str_pad1 || '"examples":' || str_pad || '{'
               ,p_pretty_print => p_pretty_print + 1
            );
         
            FOR i IN 1 .. ary_clb.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v => str_pad2 || '"' || ary_keys(i) || '":' || str_pad
                  ,p_pretty_print   => p_pretty_print + 2
                  ,p_final_linefeed => FALSE
               );
               
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => ary_clb(i)
                  ,p_in_v => NULL
                  ,p_pretty_print   => p_pretty_print + 2
                  ,p_initial_indent => FALSE
               );
               
               str_pad2 := ',';
            
            END LOOP;
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => '}'
               ,p_pretty_print => p_pretty_print + 1
            );

            str_pad1 := ',';
         
         END IF;
 
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 130
      -- Add the left bracket
      --------------------------------------------------------------------------
      dz_swagger3_util.conc(
          p_c    => cb
         ,p_v    => v2
         ,p_in_c => NULL
         ,p_in_v => '}'
         ,p_pretty_print   => p_pretty_print
         ,p_final_linefeed => FALSE
      );

      --------------------------------------------------------------------------
      -- Step 140
      -- Cough it out
      --------------------------------------------------------------------------
      dz_swagger3_util.fconc(
          p_c    => cb
         ,p_v    => v2
      );
      
      RETURN cb;
           
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
      
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
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
               '#/components/headers/' || str_identifier
             )
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );
         
      ELSE
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml summary
      --------------------------------------------------------------------------
         IF self.header_description IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'description: ' || dz_swagger3_util.yaml_text(
                   self.header_description
                  ,p_pretty_print
                )
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional license url
      --------------------------------------------------------------------------
         IF self.header_required IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'required: ' || LOWER(self.header_required)
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the optional license url
      --------------------------------------------------------------------------
         IF self.header_deprecated IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'deprecated: ' || LOWER(self.header_deprecated)
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the optional license url
      --------------------------------------------------------------------------
         IF self.header_allowEmptyValue IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'allowEmptyValue: ' || LOWER(self.header_allowEmptyValue)
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Write the yaml summary
      --------------------------------------------------------------------------
         IF self.header_style IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'style: ' || dz_swagger3_util.yaml_text(
                   self.header_style
                  ,p_pretty_print
                )
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Write the optional license url
      --------------------------------------------------------------------------
         IF self.header_explode IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'explode: ' || LOWER(self.header_explode)
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Write the optional license url
      --------------------------------------------------------------------------
         IF self.header_allowReserved IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'allowReserved: ' || LOWER(self.header_allowReserved)
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Write the optional info license object
      --------------------------------------------------------------------------
         IF self.header_schema IS NOT NULL
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
                   a.object_type_id = self.header_schema.object_type_id
               AND a.object_id      = self.header_schema.object_id;
               
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
      -- Write the optional value
      --------------------------------------------------------------------------
         IF self.header_example_string IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'example: ' || dz_swagger3_util.yaml_text(
                   self.header_example_string
                  ,p_pretty_print
                )
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );
            
         ELSIF self.header_example_number IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'example: ' || TO_CHAR(self.header_example_number)
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Write the optional variables map
      --------------------------------------------------------------------------
         IF  self.header_examples IS NULL 
         AND self.header_examples.COUNT = 0
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
            TABLE(self.header_examples) b
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

