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
   
      BEGIN
         SELECT
         dz_swagger3_parameter_typ(
             p_hash_key                  => a.parameter_name
            ,p_parameter_id              => a.parameter_id
            ,p_parameter_name            => a.parameter_name
            ,p_parameter_in              => a.parameter_in
            ,p_parameter_description     => a.parameter_description
            ,p_parameter_required        => a.parameter_required
            ,p_parameter_deprecated      => a.parameter_deprecated
            ,p_parameter_allowEmptyValue => a.parameter_allowEmptyValue
            ,p_parameter_style           => a.parameter_style
            ,p_parameter_explode         => a.parameter_explode
            ,p_parameter_allowReserved   => a.parameter_allowReserved
            ,p_parameter_schema          => dz_swagger3_schema_typ(
                p_schema_id                 => a.parameter_schema_id
               ,p_versionid                 => p_versionid
             )
            ,p_parameter_example_string  => a.parameter_example_string
            ,p_parameter_example_number  => a.parameter_example_number
            ,p_parameter_examples        => NULL
         )
         INTO SELF
         FROM
         dz_swagger3_parameter a
         WHERE
             a.versionid    = p_versionid
         AND a.parameter_id = p_parameter_id;

      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN;
            
         WHEN OTHERS
         THEN
            RAISE;
            
      END;
      
      RETURN;
      
   END;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_parameter_typ(
       p_hash_key                  IN  VARCHAR2
      ,p_parameter_id              IN  VARCHAR2
      ,p_parameter_name            IN  VARCHAR2
      ,p_parameter_in              IN  VARCHAR2
      ,p_parameter_description     IN  VARCHAR2
      ,p_parameter_required        IN  VARCHAR2
      ,p_parameter_deprecated      IN  VARCHAR2
      ,p_parameter_allowEmptyValue IN  VARCHAR2
      ,p_parameter_style           IN  VARCHAR2
      ,p_parameter_explode         IN  VARCHAR2
      ,p_parameter_allowReserved   IN  VARCHAR2
      ,p_parameter_schema          IN  dz_swagger3_schema_typ
      ,p_parameter_example_string  IN  VARCHAR2
      ,p_parameter_example_number  IN  NUMBER
      ,p_parameter_examples        IN  dz_swagger3_example_list
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.hash_key                  := p_hash_key;
      self.parameter_id              := p_parameter_id;
      self.parameter_name            := p_parameter_name;
      self.parameter_in              := p_parameter_in;
      self.parameter_description     := p_parameter_description;
      self.parameter_required        := p_parameter_required;
      self.parameter_deprecated      := p_parameter_deprecated;
      self.parameter_allowEmptyValue := p_parameter_allowEmptyValue;
      self.parameter_style           := p_parameter_style;
      self.parameter_explode         := p_parameter_explode;
      self.parameter_allowReserved   := p_parameter_allowReserved;
      self.parameter_schema          := p_parameter_schema;
      self.parameter_example_string  := p_parameter_example_string;
      self.parameter_example_number  := p_parameter_example_number;
      self.parameter_examples        := p_parameter_examples;
      
      RETURN; 
      
   END dz_swagger3_parameter_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION isNULL
   RETURN VARCHAR2
   AS
   BEGIN
   
      IF self.hash_key IS NOT NULL
      THEN
         RETURN 'FALSE';
         
      ELSE
         RETURN 'TRUE';
         
      END IF;
   
   END isNULL;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION key
   RETURN VARCHAR2
   AS
   BEGIN
      RETURN self.hash_key;
      
   END key;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION parameter_examples_keys
   RETURN MDSYS.SDO_STRING2_ARRAY
   AS
      int_index  PLS_INTEGER;
      ary_output MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
      IF self.parameter_examples IS NULL
      OR self.parameter_examples.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := MDSYS.SDO_STRING2_ARRAY();
      FOR i IN 1 .. self.parameter_examples.COUNT
      LOOP
         ary_output.EXTEND();
         ary_output(int_index) := self.parameter_examples(i).hash_key;
         int_index := int_index + 1;
      
      END LOOP;
      
      RETURN ary_output;
   
   END parameter_examples_keys;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      boo_temp         BOOLEAN;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_hash         CLOB;
      
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
         str_pad     := '';
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional summary
      --------------------------------------------------------------------------
      str_pad1 := str_pad;
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
      -- Add optional summary
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
      -- Add optional summary
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
      -- Add optional description 
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
      -- Add optional description 
      --------------------------------------------------------------------------
      IF self.parameter_deprecated IS NOT NULL
      THEN
         IF LOWER(self.parameter_deprecated) = 'true'
         THEN
            boo_temp := TRUE;
            
         ELSE
            boo_temp := FALSE;
            
         END IF;
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'deprecated'
               ,boo_temp
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
      THEN
         IF LOWER(self.parameter_allowEmptyValue) = 'true'
         THEN
            boo_temp := TRUE;
            
         ELSE
            boo_temp := FALSE;
            
         END IF;
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'allowEmptyValue'
               ,boo_temp
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
      -- Add optional description 
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
      -- Add optional description 
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
      -- Add optional externalValue
      --------------------------------------------------------------------------
      IF self.parameter_schema IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'schema'
               ,self.parameter_schema.toJSON(p_pretty_print + 1)
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
      IF self.parameter_examples IS NULL 
      OR self.parameter_examples.COUNT = 0
      THEN
         NULL;
         
      ELSE
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('{',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('{',-1);
            
         END IF;
      
      
         ary_keys := self.parameter_examples_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || ary_keys(i) || '":' || str_pad || self.parameter_examples(i).toJSON(
                  p_pretty_print => p_pretty_print + 2
                )
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
       p_pretty_print      IN  INTEGER   DEFAULT 0
      ,p_initial_indent    IN  VARCHAR2  DEFAULT 'TRUE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml summary
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
      -- Write the yaml summary
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
      -- Write the yaml summary
      --------------------------------------------------------------------------
      IF self.parameter_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'description: ' || dz_swagger3_util.yaml_text(
                self.parameter_description
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional license url
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
      -- Write the optional license url
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
      -- Write the optional license url
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
      -- Write the yaml summary
      --------------------------------------------------------------------------
      IF self.parameter_style IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'style: ' || dz_swagger_util.yaml_text(
                self.parameter_style
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Write the optional license url
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
      -- Write the optional license url
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
      -- Write the optional info license object
      --------------------------------------------------------------------------
      IF  self.parameter_schema IS NOT NULL
      AND self.parameter_schema.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'schema: '
            ,p_pretty_print
            ,'  '
         ) || self.parameter_schema.toYAML(
            p_pretty_print + 1
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Write the optional value
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
      -- Write the optional variables map
      --------------------------------------------------------------------------
      IF  self.parameter_examples IS NOT NULL 
      AND self.parameter_examples.COUNT > 0
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'examples: '
            ,p_pretty_print + 1
            ,'  '
         );
         
         ary_keys := self.parameter_examples_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '''' || ary_keys(i) || ''': '
               ,p_pretty_print + 2
               ,'  '
            ) || self.parameter_examples(i).toYAML(
               p_pretty_print + 3
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Cough it out without final line feed
      --------------------------------------------------------------------------
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');
       
      END IF;
         
      RETURN REGEXP_REPLACE(clb_output,CHR(10) || '$','');
      
   END toYAML;
   
END;
/

