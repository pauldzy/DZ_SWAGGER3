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
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      boo_temp         BOOLEAN;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_hash         CLOB;
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
         clb_output  := dz_json_util.pretty('{',NULL);
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;
      
      str_pad1 := str_pad;
      
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

         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                '$ref'
               ,'#/components/parameters/' || dz_swagger3_util.utl_url_escape(
                  str_identifier
                )
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
      
      ELSE
      --------------------------------------------------------------------------
      -- Step 30
      -- Add mandatory parameter name attribute
      --------------------------------------------------------------------------
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'name'
               ,self.parameter_name
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional in attribute
      --------------------------------------------------------------------------
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'in'
               ,self.parameter_in
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional description attribute
      --------------------------------------------------------------------------
         IF self.parameter_description IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'description'
                  ,self.parameter_description
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Add mandatory required flag
      --------------------------------------------------------------------------
         IF self.parameter_required IS NOT NULL
         THEN
            IF LOWER(self.parameter_required) = 'true'
            THEN
               boo_temp := TRUE;
               
            ELSE
               boo_temp := FALSE;
               
            END IF;
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'required'
                  ,boo_temp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional deprecated flag
      --------------------------------------------------------------------------
         IF  self.parameter_deprecated IS NOT NULL
         AND LOWER(self.parameter_deprecated) = 'true'
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'deprecated'
                  ,TRUE
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;

      --------------------------------------------------------------------------
      -- Step 60
      -- Add optional description 
      --------------------------------------------------------------------------
         IF self.parameter_allowEmptyValue IS NOT NULL
         AND LOWER(self.parameter_allowEmptyValue) = 'true'
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'allowEmptyValue'
                  ,TRUE
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Add optional value
      --------------------------------------------------------------------------
         IF self.parameter_style IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'style'
                  ,self.parameter_style
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Add optional explode attribute 
      --------------------------------------------------------------------------
         IF self.parameter_explode IS NOT NULL
         THEN
            IF LOWER(self.parameter_explode) = 'true'
            THEN
               boo_temp := TRUE;
               
            ELSE
               boo_temp := FALSE;
               
            END IF;
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'explode'
                  ,boo_temp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Add optional allowReserved attribute 
      --------------------------------------------------------------------------
         IF self.parameter_allowReserved IS NOT NULL
         THEN
            IF LOWER(self.parameter_allowReserved) = 'true'
            THEN
               boo_temp := TRUE;
               
            ELSE
               boo_temp := FALSE;
               
            END IF;
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'allowReserved'
                  ,boo_temp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;

      --------------------------------------------------------------------------
      -- Step 100
      -- Add optional schema attribute
      --------------------------------------------------------------------------
         IF self.parameter_schema IS NOT NULL
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

            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                   'schema'
                  ,clb_tmp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;

      --------------------------------------------------------------------------
      -- Step 110
      -- Add optional example
      --------------------------------------------------------------------------
         IF self.parameter_example_string IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'example'
                  ,self.parameter_example_string
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         ELSIF self.parameter_example_number IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'example'
                  ,self.parameter_example_number
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Add optional variables map
      --------------------------------------------------------------------------
         IF  self.parameter_examples IS NOT NULL 
         AND self.parameter_examples.COUNT > 0
         THEN
            SELECT
             a.exampletyp.toJSON(
                p_pretty_print     => p_pretty_print + 1
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
            
            str_pad2 := str_pad;
            
            IF p_pretty_print IS NULL
            THEN
               clb_hash := dz_json_util.pretty('{',NULL);
               
            ELSE
               clb_hash := dz_json_util.pretty('{',-1);
               
            END IF;

            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_hash := clb_hash || dz_json_util.pretty(
                   str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                  ,p_pretty_print + 1
               );
               str_pad2 := ',';
            
            END LOOP;
            
            clb_hash := clb_hash || dz_json_util.pretty(
                '}'
               ,p_pretty_print + 1,NULL,NULL
            );
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                    'examples'
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
      
      END IF;
      --------------------------------------------------------------------------
      -- Step 130
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 140
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
      clb_output       CLOB;
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
         
         clb_output := clb_output || dz_json_util.pretty_str(
             '$ref: ' || dz_swagger3_util.yaml_text(
                '#/components/parameters/' || str_identifier
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
  
      ELSE
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the mandatory parameter name
      --------------------------------------------------------------------------
         clb_output := clb_output || dz_json_util.pretty_str(
             'name: ' || dz_swagger3_util.yaml_text(
                self.parameter_name
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the mandatory parameter in attribute
      --------------------------------------------------------------------------
         clb_output := clb_output || dz_json_util.pretty_str(
             'in: ' || dz_swagger3_util.yaml_text(
                self.parameter_in
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the optional description attribute
      --------------------------------------------------------------------------
         IF self.parameter_description IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'description: ' || dz_swagger3_util.yaml_text(
                   REGEXP_REPLACE(
                      self.parameter_description
                     ,CHR(10) || '$'
                     ,'')
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional required attribute
      --------------------------------------------------------------------------
         IF self.parameter_required IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'required: ' || LOWER(self.parameter_required)
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the optional deprecated attribute
      --------------------------------------------------------------------------
         IF self.parameter_deprecated IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'deprecated: ' || LOWER(self.parameter_deprecated)
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the optional allowEmptyValue attribute
      --------------------------------------------------------------------------
         IF self.parameter_allowEmptyValue IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'allowEmptyValue: ' || LOWER(self.parameter_allowEmptyValue)
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Write the optional style attribute
      --------------------------------------------------------------------------
         IF self.parameter_style IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'style: ' || dz_swagger3_util.yaml_text(
                   self.parameter_style
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Write the optional explode attribute
      --------------------------------------------------------------------------
         IF self.parameter_explode IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'explode: ' || LOWER(self.parameter_explode)
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Write the optional allowReserved attribute
      --------------------------------------------------------------------------
         IF self.parameter_allowReserved IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'allowReserved: ' || LOWER(self.parameter_allowReserved)
               ,p_pretty_print
               ,'  '
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
            
            clb_output := clb_output || dz_json_util.pretty_str(
                'schema: '
               ,p_pretty_print
               ,'  '
            ) || clb_tmp;
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Write the optional examples values
      --------------------------------------------------------------------------
         IF self.parameter_example_string IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'example: ' || dz_swagger3_util.yaml_text(
                   self.parameter_example_string
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         ELSIF self.parameter_example_number IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'example: ' || dz_swagger3_util.yaml_text(
                   self.parameter_example_number
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Write the optional examples map
      --------------------------------------------------------------------------
         IF  self.parameter_examples IS NOT NULL 
         AND self.parameter_examples.COUNT > 0
         THEN
            SELECT
             a.exampletyp.toYAML(
                p_pretty_print     => p_pretty_print + 1
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
            
            clb_output := clb_output || dz_json_util.pretty_str(
                'examples: '
               ,p_pretty_print + 1
               ,'  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   '''' || ary_keys(i) || ''': '
                  ,p_pretty_print + 2
                  ,'  '
               ) || ary_clb(i);
            
            END LOOP;
            
         END IF;
      
      END IF;
      --------------------------------------------------------------------------
      -- Step 110
      -- Cough it out without final line feed
      --------------------------------------------------------------------------
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(10) || '$','');
         
      END IF;
               
      RETURN clb_output;
      
   END toYAML;
   
END;
/

