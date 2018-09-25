CREATE OR REPLACE TYPE BODY dz_swagger3_media_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_media_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_media_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_media_typ(
       p_media_id                IN  VARCHAR2
      ,p_media_type              IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS 
   BEGIN
   
      BEGIN
         SELECT
         dz_swagger3_media_typ(
             p_hash_key              => p_media_type
            ,p_media_schema          => dz_swagger3_schema_typ(
                p_hash_key              => NULL
               ,p_schema_id             => a.media_schema_id
               ,p_required              => NULL
               ,p_versionid             => p_versionid
             )
            ,p_media_example_string  => a.media_example_string
            ,p_media_example_number  => a.media_example_number
            ,p_media_examples        => NULL
            ,p_media_encoding        => NULL
         )
         INTO SELF
         FROM
         dz_swagger3_media a
         WHERE
             a.versionid = p_versionid
         AND a.media_id  = p_media_id;
         
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN;
            
         WHEN OTHERS
         THEN
            RAISE;
            
      END;
   
      RETURN; 
      
   END dz_swagger3_media_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_media_typ(
       p_hash_key                IN  VARCHAR2
      ,p_media_schema            IN  dz_swagger3_schema_typ
      ,p_media_example_string    IN  VARCHAR2
      ,p_media_example_number    IN  NUMBER
      ,p_media_examples          IN  dz_swagger3_example_list
      ,p_media_encoding          IN  dz_swagger3_encoding_list
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.hash_key                := p_hash_key;
      self.media_schema            := p_media_schema;
      self.media_example_string    := p_media_example_string;
      self.media_example_number    := p_media_example_number;
      self.media_examples          := p_media_examples;
      self.media_encoding          := p_media_encoding;
      
      RETURN; 
      
   END dz_swagger3_media_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION isNULL
   RETURN VARCHAR2
   AS
   BEGIN
   
      IF self.hash_key     IS NOT NULL
      OR self.media_schema IS NOT NULL
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
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   MEMBER FUNCTION unique_schemas
   RETURN dz_swagger3_schema_nf_list
   AS
      ary_results   dz_swagger3_schema_nf_list;
      ary_working   dz_swagger3_schema_nf_list;
      obj_schema    dz_swagger3_schema_typ;
      int_results   PLS_INTEGER;
      ary_x         MDSYS.SDO_STRING2_ARRAY;
      int_x         PLS_INTEGER;
   
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Setup for the harvest
      --------------------------------------------------------------------------
      int_results := 1;
      ary_results := dz_swagger3_schema_nf_list();
      int_x       := 1;
      ary_x       := MDSYS.SDO_STRING2_ARRAY();
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Pull the schema from the items
      --------------------------------------------------------------------------
      IF self.media_schema IS NOT NULL
      AND self.media_schema.isNULL() = 'FALSE'
      THEN
         IF self.media_schema.doRef() = 'TRUE'
         THEN
            ary_working := self.media_schema.unique_schemas();
            
            FOR j IN 1 .. ary_working.COUNT
            LOOP
               IF dz_swagger3_util.a_in_b(
                   ary_working(j).schema_id
                  ,ary_x
               ) = 'FALSE'
               THEN
                  ary_results.EXTEND();
                  obj_schema := TREAT(ary_working(j) AS dz_swagger3_schema_typ);
                  ary_results(int_results) := dz_swagger3_schema_typ(
                      p_schema_id               => obj_schema.schema_id
                     ,p_schema_title            => obj_schema.schema_title
                     ,p_schema_type             => obj_schema.schema_type
                     ,p_schema_description      => obj_schema.schema_description
                     ,p_schema_format           => obj_schema.schema_format
                     ,p_schema_nullable         => obj_schema.schema_nullable
                     ,p_schema_discriminator    => obj_schema.schema_discriminator
                     ,p_schema_readonly         => obj_schema.schema_readonly
                     ,p_schema_writeonly        => obj_schema.schema_writeonly
                     ,p_schema_externalDocs     => obj_schema.schema_externalDocs
                     ,p_schema_example_string   => obj_schema.schema_example_string
                     ,p_schema_example_number   => obj_schema.schema_example_number
                     ,p_schema_deprecated       => obj_schema.schema_deprecated
                     ,p_schema_default_string   => obj_schema.schema_default_string
                     ,p_schema_default_number   => obj_schema.schema_default_number
                     ,p_schema_multipleOf       => obj_schema.schema_multipleOf
                     ,p_schema_minimum          => obj_schema.schema_minimum
                     ,p_schema_exclusiveMinimum => obj_schema.schema_exclusiveMinimum
                     ,p_schema_maximum          => obj_schema.schema_maximum
                     ,p_schema_exclusiveMaximum => obj_schema.schema_exclusiveMaximum
                     ,p_schema_minLength        => obj_schema.schema_minLength
                     ,p_schema_maxLength        => obj_schema.schema_maxLength
                     ,p_schema_pattern          => obj_schema.schema_pattern
                     ,p_schema_minItems         => obj_schema.schema_minItems
                     ,p_schema_maxItems         => obj_schema.schema_maxItems
                     ,p_schema_uniqueItems      => obj_schema.schema_uniqueItems
                     ,p_schema_minProperties    => obj_schema.schema_minProperties
                     ,p_schema_maxProperties    => obj_schema.schema_maxProperties
                     ,p_xml_name                => obj_schema.xml_name
                     ,p_xml_namespace           => obj_schema.xml_namespace
                     ,p_xml_prefix              => obj_schema.xml_prefix
                     ,p_xml_attribute           => obj_schema.xml_attribute
                     ,p_xml_wrapped             => obj_schema.xml_wrapped
                     ,p_schema_items_schema     => obj_schema.schema_items_schema
                     ,p_schema_properties       => obj_schema.schema_properties
                     ,p_schema_force_inline     => obj_schema.schema_force_inline
                     ,p_combine_schemas         => obj_schema.combine_schemas
                     ,p_not_schema              => obj_schema.not_schema
                  );
                  int_results := int_results + 1;
                  
                  ary_x.EXTEND();
                  ary_x(int_x) := ary_working(j).schema_id;
                  int_x := int_x + 1;

               END IF;
               
            END LOOP;

            IF dz_swagger3_util.a_in_b(
                self.media_schema.schema_id
               ,ary_x
            ) = 'FALSE'
            THEN
               ary_results.EXTEND();
               ary_results(int_results) := dz_swagger3_schema_typ(
                   p_schema_id               => self.media_schema.schema_id
                  ,p_schema_title            => self.media_schema.schema_title
                  ,p_schema_type             => self.media_schema.schema_type
                  ,p_schema_description      => self.media_schema.schema_description
                  ,p_schema_format           => self.media_schema.schema_format
                  ,p_schema_nullable         => self.media_schema.schema_nullable
                  ,p_schema_discriminator    => self.media_schema.schema_discriminator
                  ,p_schema_readonly         => self.media_schema.schema_readonly
                  ,p_schema_writeonly        => self.media_schema.schema_writeonly
                  ,p_schema_externalDocs     => self.media_schema.schema_externalDocs
                  ,p_schema_example_string   => self.media_schema.schema_example_string
                  ,p_schema_example_number   => self.media_schema.schema_example_number
                  ,p_schema_deprecated       => self.media_schema.schema_deprecated
                  ,p_schema_default_string   => self.media_schema.schema_default_string
                  ,p_schema_default_number   => self.media_schema.schema_default_number
                  ,p_schema_multipleOf       => self.media_schema.schema_multipleOf
                  ,p_schema_minimum          => self.media_schema.schema_minimum
                  ,p_schema_exclusiveMinimum => self.media_schema.schema_exclusiveMinimum
                  ,p_schema_maximum          => self.media_schema.schema_maximum
                  ,p_schema_exclusiveMaximum => self.media_schema.schema_exclusiveMaximum
                  ,p_schema_minLength        => self.media_schema.schema_minLength
                  ,p_schema_maxLength        => self.media_schema.schema_maxLength
                  ,p_schema_pattern          => self.media_schema.schema_pattern
                  ,p_schema_minItems         => self.media_schema.schema_minItems
                  ,p_schema_maxItems         => self.media_schema.schema_maxItems
                  ,p_schema_uniqueItems      => self.media_schema.schema_uniqueItems
                  ,p_schema_minProperties    => self.media_schema.schema_minProperties
                  ,p_schema_maxProperties    => self.media_schema.schema_maxProperties
                  ,p_xml_name                => self.media_schema.xml_name
                  ,p_xml_namespace           => self.media_schema.xml_namespace
                  ,p_xml_prefix              => self.media_schema.xml_prefix
                  ,p_xml_attribute           => self.media_schema.xml_attribute
                  ,p_xml_wrapped             => self.media_schema.xml_wrapped
                  ,p_schema_items_schema     => self.media_schema.schema_items_schema
                  ,p_schema_properties       => self.media_schema.schema_properties
                  ,p_schema_force_inline     => self.media_schema.schema_force_inline
                  ,p_combine_schemas         => self.media_schema.combine_schemas
                  ,p_not_schema              => self.media_schema.not_schema
               );
               int_results := int_results + 1;
               
               ary_x.EXTEND();
               ary_x(int_x) := self.media_schema.schema_id;
               int_x := int_x + 1;
     
            END IF;

         END IF;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 30
      -- Return what we got
      --------------------------------------------------------------------------
      RETURN ary_results;

   END unique_schemas;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION media_examples_keys
   RETURN MDSYS.SDO_STRING2_ARRAY
   AS
      int_index  PLS_INTEGER;
      ary_output MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
      IF self.media_examples IS NULL
      OR self.media_examples.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := MDSYS.SDO_STRING2_ARRAY();
      FOR i IN 1 .. self.media_examples.COUNT
      LOOP
         ary_output.EXTEND();
         ary_output(int_index) := self.media_examples(i).hash_key;
         int_index := int_index + 1;
         
      END LOOP;
      
      RETURN ary_output;
   
   END media_examples_keys;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION media_encoding_keys
   RETURN MDSYS.SDO_STRING2_ARRAY
   AS
      int_index  PLS_INTEGER;
      ary_output MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
      IF self.media_encoding IS NULL
      OR self.media_encoding.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := MDSYS.SDO_STRING2_ARRAY();
      FOR i IN 1 .. self.media_encoding.COUNT
      LOOP
         ary_output.EXTEND();
         ary_output(int_index) := self.media_encoding(i).hash_key;
         int_index := int_index + 1;
         
      END LOOP;
      
      RETURN ary_output;
   
   END media_encoding_keys;
   
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
      
      str_pad1 := str_pad;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add schema object
      --------------------------------------------------------------------------
      IF self.media_schema IS NULL
      OR self.media_schema.isNULL() = 'TRUE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'schema'
               ,CAST(NULL AS NUMBER)
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      ELSE
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'schema'
               ,self.media_schema.toJSON(p_pretty_print + 1)
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional example
      --------------------------------------------------------------------------
      IF self.media_example_string IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'example'
               ,self.media_example_string
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      ELSIF self.media_example_number IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'example'
               ,self.media_example_number
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Add optional examples map
      --------------------------------------------------------------------------
      IF self.media_examples IS NULL 
      OR self.media_examples.COUNT = 0
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
      
      
         ary_keys := self.media_examples_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || ary_keys(i) || '":' || str_pad || self.media_examples(i).toJSON(
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
      -- Step 120
      -- Add optional encoding map
      --------------------------------------------------------------------------
      IF self.media_encoding IS NULL 
      OR self.media_encoding.COUNT = 0
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
      
         ary_keys := self.media_encoding_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || ary_keys(i) || '":' || str_pad || self.media_encoding(i).toJSON(
                  p_pretty_print => p_pretty_print + 1
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
                 'encoding'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
 
      --------------------------------------------------------------------------
      -- Step 60
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 70
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
      -- Write the yaml schema object
      --------------------------------------------------------------------------
      IF self.media_schema IS NULL
      OR self.media_schema.isNULL() = 'TRUE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             'schema: ' 
            ,p_pretty_print
            ,'  '
         );
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'schema: ' 
            ,p_pretty_print
            ,'  '
         ) || self.media_schema.toYAML(
            p_pretty_print + 1
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the yaml example item
      --------------------------------------------------------------------------
      IF self.media_example_string IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'example: ' || dz_swagger_util.yaml_text(
                self.media_example_string
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      ELSIF self.media_example_number IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'example: ' || dz_swagger_util.yaml_text(
                self.media_example_number
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the optional variables map
      --------------------------------------------------------------------------
      IF  self.media_examples IS NOT NULL 
      AND self.media_examples.COUNT > 0
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'examples: '
            ,p_pretty_print + 1
            ,'  '
         );
         
         ary_keys := self.media_examples_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '''' || ary_keys(i) || ''': '
               ,p_pretty_print + 2
               ,'  '
            ) || self.media_examples(i).toYAML(
               p_pretty_print + 3
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the optional variables map
      --------------------------------------------------------------------------
      IF  self.media_encoding IS NOT NULL 
      AND self.media_encoding.COUNT > 0
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'encoding: '
            ,p_pretty_print + 1
            ,'  '
         );
         
         ary_keys := self.media_encoding_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '''' || ary_keys(i) || ''': '
               ,p_pretty_print + 2
               ,'  '
            ) || self.media_encoding(i).toYAML(
               p_pretty_print + 3
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
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
      
   END toYAML;
   
END;
/

