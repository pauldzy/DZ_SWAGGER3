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
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional summary
      --------------------------------------------------------------------------
      str_pad1 := str_pad;
      IF self.header_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'description'
               ,self.header_description
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
      IF self.header_required IS NOT NULL
      THEN
         IF LOWER(self.header_required) = 'true'
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
      IF self.header_deprecated IS NOT NULL
      THEN
         IF LOWER(self.header_deprecated) = 'true'
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
      IF self.header_allowEmptyValue IS NOT NULL
      THEN
         IF LOWER(self.header_allowEmptyValue) = 'true'
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
      IF self.header_style IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'style'
               ,self.header_style
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
      IF self.header_explode IS NOT NULL
      THEN
         IF LOWER(self.header_explode) = 'true'
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
      IF self.header_allowReserved IS NOT NULL
      THEN
         IF LOWER(self.header_allowReserved) = 'true'
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
      IF self.header_schema IS NOT NULL
      THEN
         BEGIN
            EXECUTE IMMEDIATE
               'SELECT '
            || 'a.schematyp.toJSON( '
            || '    p_pretty_print   => :p01 + 1 '
            || '   ,p_force_inline   => :p02 '
            || '   ,p_short_id       => :p03 '
            || ') '
            || 'FROM '
            || 'dz_swagger3_xobjects a '
            || 'WHERE '
            || '    a.object_type_id = :p04 '
            || 'AND a.object_id      = :p05 '
            INTO clb_tmp
            USING 
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.header_schema.object_type_id
            ,self.header_schema.object_id;
            
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
      IF self.header_example_string IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'example'
               ,self.header_example_string
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      ELSIF self.header_example_number IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'example'
               ,self.header_example_number
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
      IF  self.header_examples IS NOT NULL 
      AND self.header_examples.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.exampletyp.toJSON( '
         || '    p_pretty_print   => :p01 + 2 '
         || '   ,p_force_inline   => :p02 '
         || '   ,p_short_id       => :p03 '
         || ' ) '
         || ',b.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p04) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      = b.object_id '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.header_examples; 
         
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
         
      END IF;
         
      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.formatted2json(
              'examples'
             ,clb_hash
             ,p_pretty_print + 1
          )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';
 
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
   MEMBER FUNCTION toJSON_ref(
       p_identifier          IN  VARCHAR2
      ,p_pretty_print        IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      
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
      -- Step 30
      -- Add optional description
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.value2json(
             '$ref'
            ,'#/components/headers/' || p_identifier
            ,p_pretty_print + 1
         )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';

      --------------------------------------------------------------------------
      -- Step 40
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON_ref;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_tmp          CLOB;
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml summary
      --------------------------------------------------------------------------
      IF self.header_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'description: ' || dz_swagger3_util.yaml_text(
                self.header_description
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
      IF self.header_required IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'required: ' || LOWER(self.header_required)
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the optional license url
      --------------------------------------------------------------------------
      IF self.header_deprecated IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'deprecated: ' || LOWER(self.header_deprecated)
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the optional license url
      --------------------------------------------------------------------------
      IF self.header_allowEmptyValue IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'allowEmptyValue: ' || LOWER(self.header_allowEmptyValue)
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Write the yaml summary
      --------------------------------------------------------------------------
      IF self.header_style IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'style: ' || dz_swagger3_util.yaml_text(
                self.header_style
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
      IF self.header_explode IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'explode: ' || LOWER(self.header_explode)
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Write the optional license url
      --------------------------------------------------------------------------
      IF self.header_allowReserved IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'allowReserved: ' || LOWER(self.header_allowReserved)
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Write the optional info license object
      --------------------------------------------------------------------------
      IF self.header_schema IS NOT NULL
      THEN
         BEGIN
            EXECUTE IMMEDIATE
               'SELECT '
            || 'a.schematyp.toYAML( '
            || '    p_pretty_print   => :p01 + 1 '
            || '   ,p_force_inline   => :p02 '
            || '   ,p_short_id       => :p03 '
            || ') '
            || 'FROM '
            || 'dz_swagger3_xobjects a '
            || 'WHERE '
            || '    a.object_type_id = :p04 '
            || 'AND a.object_id      = :p05 '
            INTO clb_tmp
            USING 
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.header_schema.object_type_id
            ,self.header_schema.object_id;
            
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
      -- Write the optional value
      --------------------------------------------------------------------------
      IF self.header_example_string IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'example: ' || dz_swagger3_util.yaml_text(
                self.header_example_string
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      ELSIF self.header_example_number IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'example: ' || dz_swagger3_util.yaml_text(
                self.header_example_number
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
      IF  self.header_examples IS NULL 
      AND self.header_examples.COUNT = 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.exampletyp.toYAML( '
         || '    p_pretty_print   => :p01 + 2 '
         || '   ,p_force_inline   => :p02 '
         || '   ,p_short_id       => :p03 '
         || ' ) '
         || ',b.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p01) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      = b.object_id '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.header_examples;
      
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
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML_ref(
       p_identifier          IN  VARCHAR2
      ,p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
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
      -- Write the yaml description
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty_str(
          '$ref: ' || dz_swagger3_util.yaml_text(
             '#/components/headers/' || p_identifier
            ,p_pretty_print
         )
         ,p_pretty_print
         ,'  '
      );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Cough it out 
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
      
   END toYAML_ref;
   
END;
/

