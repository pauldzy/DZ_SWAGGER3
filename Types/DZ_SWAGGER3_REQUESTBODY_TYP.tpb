CREATE OR REPLACE TYPE BODY dz_swagger3_requestbody_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_requestbody_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_requestbody_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_requestbody_typ(
       p_requestbody_id          IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Pull the object information
      -------------------------------------------------------------------------- 
      BEGIN
         SELECT
         dz_swagger3_requestbody_typ(
             p_hash_key                 => p_requestbody_id
            ,p_requestbody_id           => p_requestbody_id
            ,p_requestbody_description  => a.requestbody_description
            ,p_requestBody_force_inline => a.requestBody_force_inline
            ,p_requestbody_content      => NULL
            ,p_requestbody_required     => a.requestbody_required
         )
         INTO SELF
         FROM
         dz_swagger3_requestbody a
         WHERE
             a.versionid      = p_versionid
         AND a.requestbody_id = p_requestbody_id;
         
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN;
            
         WHEN OTHERS
         THEN
            RAISE;
            
      END;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Collect the media content
      -------------------------------------------------------------------------- 
      SELECT
      dz_swagger3_media_typ(
          p_media_id              => b.media_id
         ,p_media_type            => a.media_type
         ,p_versionid             => p_versionid
      )
      BULK COLLECT INTO self.requestbody_content
      FROM
      dz_swagger3_media_parent_map a
      JOIN
      dz_swagger3_media b
      ON
          a.versionid  = b.versionid
      AND a.media_id   = b.media_id
      WHERE
          a.versionid = p_versionid
      AND a.parent_id = p_requestbody_id;
      
      --------------------------------------------------------------------------
      -- Step 
      -- Return the completed object
      --------------------------------------------------------------------------   
      RETURN; 
   
   END dz_swagger3_requestbody_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_requestbody_typ(
       p_requestbody_id          IN  VARCHAR2
      ,p_media_type              IN  VARCHAR2
      ,p_parameters              IN  dz_swagger3_parameter_list
   ) RETURN SELF AS RESULT
   AS
      int_counter PLS_INTEGER;
      obj_schema  dz_swagger3_schema_typ;
      
   BEGIN
   
      self.hash_key            := p_requestbody_id;
      self.requestbody_id      := p_requestbody_id;
      
      self.requestbody_content := dz_swagger3_media_list();
      self.requestbody_content.EXTEND();
      
      self.requestbody_content(1) := dz_swagger3_media_typ();
      self.requestbody_content(1).hash_key := p_media_type;
      
      self.requestbody_content(1).media_schema := dz_swagger3_schema_typ();
      self.requestbody_content(1).media_schema.schema_id := p_requestbody_id || '.Schema';
      self.requestbody_content(1).media_schema.schema_type := 'object';
      self.requestbody_content(1).media_schema.schema_properties := dz_swagger3_schema_nf_list();
      self.requestbody_content(1).media_schema.schema_properties.EXTEND(p_parameters.COUNT);
      
      FOR i IN 1 .. p_parameters.COUNT
      LOOP
         obj_schema := dz_swagger3_schema_typ(
             p_schema_id               => p_parameters(i).parameter_schema.schema_id
            ,p_schema_title            => p_parameters(i).parameter_schema.schema_title
            ,p_schema_type             => p_parameters(i).parameter_schema.schema_type
            ,p_schema_description      => p_parameters(i).parameter_schema.schema_description
            ,p_schema_format           => p_parameters(i).parameter_schema.schema_format
            ,p_schema_nullable         => p_parameters(i).parameter_schema.schema_nullable
            ,p_schema_discriminator    => p_parameters(i).parameter_schema.schema_discriminator
            ,p_schema_readonly         => p_parameters(i).parameter_schema.schema_readonly
            ,p_schema_writeonly        => p_parameters(i).parameter_schema.schema_writeonly
            ,p_schema_externalDocs     => p_parameters(i).parameter_schema.schema_externalDocs
            ,p_schema_example_string   => p_parameters(i).parameter_schema.schema_example_string
            ,p_schema_example_number   => p_parameters(i).parameter_schema.schema_example_number
            ,p_schema_deprecated       => p_parameters(i).parameter_schema.schema_deprecated
            ,p_schema_default_string   => p_parameters(i).parameter_schema.schema_default_string
            ,p_schema_default_number   => p_parameters(i).parameter_schema.schema_default_number
            ,p_schema_multipleOf       => p_parameters(i).parameter_schema.schema_multipleOf
            ,p_schema_minimum          => p_parameters(i).parameter_schema.schema_minimum
            ,p_schema_exclusiveMinimum => p_parameters(i).parameter_schema.schema_exclusiveMinimum
            ,p_schema_maximum          => p_parameters(i).parameter_schema.schema_maximum
            ,p_schema_exclusiveMaximum => p_parameters(i).parameter_schema.schema_exclusiveMaximum
            ,p_schema_minLength        => p_parameters(i).parameter_schema.schema_minLength
            ,p_schema_maxLength        => p_parameters(i).parameter_schema.schema_maxLength
            ,p_schema_pattern          => p_parameters(i).parameter_schema.schema_pattern
            ,p_schema_minItems         => p_parameters(i).parameter_schema.schema_minItems 
            ,p_schema_maxItems         => p_parameters(i).parameter_schema.schema_maxItems
            ,p_schema_uniqueItems      => p_parameters(i).parameter_schema.schema_uniqueItems
            ,p_schema_minProperties    => p_parameters(i).parameter_schema.schema_minProperties
            ,p_schema_maxProperties    => p_parameters(i).parameter_schema.schema_maxProperties
            ,p_xml_name                => p_parameters(i).parameter_schema.xml_name
            ,p_xml_namespace           => p_parameters(i).parameter_schema.xml_namespace
            ,p_xml_prefix              => p_parameters(i).parameter_schema.xml_prefix
            ,p_xml_attribute           => p_parameters(i).parameter_schema.xml_attribute
            ,p_xml_wrapped             => p_parameters(i).parameter_schema.xml_wrapped
            ,p_schema_items_schema     => p_parameters(i).parameter_schema.schema_items_schema
            ,p_schema_properties       => p_parameters(i).parameter_schema.schema_properties
            ,p_schema_enum_string      => p_parameters(i).parameter_schema.schema_enum_string
            ,p_schema_enum_number      => p_parameters(i).parameter_schema.schema_enum_number
            ,p_schema_force_inline     => p_parameters(i).parameter_schema.schema_force_inline
            ,p_property_list_hidden    => p_parameters(i).parameter_schema.property_list_hidden
            ,p_combine_schemas         => p_parameters(i).parameter_schema.combine_schemas
            ,p_not_schema              => p_parameters(i).parameter_schema.not_schema
         );
         
         obj_schema.hash_key              := p_parameters(i).parameter_name;
         obj_schema.schema_description    := p_parameters(i).parameter_description;
         obj_schema.schema_required       := p_parameters(i).parameter_required;
         obj_schema.schema_deprecated     := p_parameters(i).parameter_deprecated;
         obj_schema.schema_example_string := p_parameters(i).parameter_example_string;
         obj_schema.schema_example_number := p_parameters(i).parameter_example_number;

         self.requestbody_content(1).media_schema.schema_properties(i) := obj_schema;
         
      END LOOP;
      
      RETURN;
      
   END dz_swagger3_requestbody_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_requestbody_typ(
       p_hash_key                 IN  VARCHAR2
      ,p_requestbody_id           IN  VARCHAR2
      ,p_requestbody_description  IN  VARCHAR2
      ,p_requestBody_force_inline IN  VARCHAR2
      ,p_requestbody_content      IN  dz_swagger3_media_list
      ,p_requestbody_required     IN  VARCHAR2
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.hash_key                 := p_hash_key;
      self.requestbody_id           := p_requestbody_id;
      self.requestbody_description  := p_requestbody_description;
      self.requestBody_force_inline := p_requestBody_force_inline;
      self.requestbody_content      := p_requestbody_content;
      self.requestbody_required     := p_requestbody_required;
      
      RETURN; 
      
   END dz_swagger3_requestbody_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION isNULL
   RETURN VARCHAR2
   AS
   BEGIN
   
      IF self.requestbody_description IS NOT NULL
      OR self.requestbody_content     IS NOT NULL
      OR self.requestbody_required    IS NOT NULL
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
   MEMBER FUNCTION doRef
   RETURN VARCHAR2
   AS
   BEGIN
      
      IF self.requestBody_force_inline = 'TRUE'
      THEN
         RETURN 'FALSE';
         
      END IF;
      
      RETURN 'TRUE';
      
   END doRef;
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   MEMBER FUNCTION unique_schemas
   RETURN dz_swagger3_schema_nf_list
   AS
      ary_results   dz_swagger3_schema_nf_list;
      ary_working   dz_swagger3_schema_nf_list;
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
      IF self.requestbody_content IS NOT NULL
      AND self.requestbody_content.COUNT > 0
      THEN
         FOR i IN 1 .. self.requestbody_content.COUNT
         LOOP
            ary_working := self.requestbody_content(i).unique_schemas();
            
            FOR j IN 1 .. ary_working.COUNT
            LOOP
               IF dz_swagger3_util.a_in_b(
                   ary_working(j).schema_id
                  ,ary_x
               ) = 'FALSE'
               THEN
                  ary_results.EXTEND();
                  ary_results(int_results) := ary_working(j);
                  int_results := int_results + 1;
                  
                  ary_x.EXTEND();
                  ary_x(int_x) := ary_working(j).schema_id;
                  int_x := int_x + 1;
                  
               END IF;
               
            END LOOP;
            
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Return what we got
      --------------------------------------------------------------------------
      RETURN ary_results;

   END unique_schemas;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION requestbody_content_keys
   RETURN MDSYS.SDO_STRING2_ARRAY
   AS
      int_index  PLS_INTEGER;
      ary_output MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
      IF self.requestbody_content IS NULL
      OR self.requestbody_content.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := MDSYS.SDO_STRING2_ARRAY();
      FOR i IN 1 .. self.requestbody_content.COUNT
      LOOP
         ary_output.EXTEND();
         ary_output(int_index) := self.requestbody_content(i).hash_key;
         int_index := int_index + 1;
      
      END LOOP;
      
      RETURN ary_output;
   
   END requestbody_content_keys;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
   BEGIN
   
      IF self.doREF() = 'TRUE'
      THEN
         RETURN toJSON_ref(
             p_pretty_print  => p_pretty_print
         );
   
      ELSE
         RETURN toJSON_schema(
             p_pretty_print  => p_pretty_print
         );
      
      END IF;
   
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON_schema(
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
      -- Add optional description
      --------------------------------------------------------------------------
      IF self.requestbody_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'description'
               ,self.requestbody_description
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
      IF  self.requestbody_content IS NULL 
      AND self.requestbody_content.COUNT = 0
      THEN
         clb_hash := 'null';
         
      ELSE
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('{',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('{',-1);
            
         END IF;
      
         ary_keys := self.requestbody_content_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || ary_keys(i) || '":' || str_pad || self.requestbody_content(i).toJSON(
                  p_pretty_print => p_pretty_print + 2
                )
               ,p_pretty_print + 2
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
              'content'
             ,clb_hash
             ,p_pretty_print + 1
          )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional required
      --------------------------------------------------------------------------
      IF self.requestbody_required IS NOT NULL
      THEN
         IF LOWER(self.requestbody_required) = 'true'
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
           
   END toJSON_schema;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON_ref(
       p_pretty_print     IN  INTEGER   DEFAULT NULL
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
         str_pad     := '';
         
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
            ,'#/components/requestBodies/' || self.requestbody_id
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
   ) RETURN CLOB
   AS      
   BEGIN
   
      IF self.doRef() = 'TRUE'
      THEN
         RETURN self.toYAML_ref(
             p_pretty_print    => p_pretty_print
            ,p_initial_indent  => p_initial_indent
            ,p_final_linefeed  => p_final_linefeed
         );
         
      ELSE
         RETURN self.toYAML_schema(
             p_pretty_print    => p_pretty_print
            ,p_initial_indent  => p_initial_indent
            ,p_final_linefeed  => p_final_linefeed
         );
      
      END IF;
   
   END toYAML;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML_schema(
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
      -- Write the yaml description
      --------------------------------------------------------------------------
      IF self.requestbody_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'description: ' || dz_swagger3_util.yaml_text(
                self.requestbody_description
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 30
      -- Write the yaml media content
      --------------------------------------------------------------------------
      IF  self.requestbody_content IS NOT NULL 
      AND self.requestbody_content.COUNT > 0
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'content: '
            ,p_pretty_print + 1
            ,'  '
         );
         
         ary_keys := self.requestbody_content_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '''' || ary_keys(i) || ''': '
               ,p_pretty_print + 2
               ,'  '
            ) || self.requestbody_content(i).toYAML(
               p_pretty_print + 3
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the yaml required boolean
      --------------------------------------------------------------------------
      IF self.requestbody_required IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'required: ' || LOWER(self.requestbody_required)
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
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
      
   END toYAML_schema;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML_ref(
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
      -- Write the yaml description
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty_str(
          '$ref: ' || dz_swagger3_util.yaml_text(
             '#/components/requestBodies/' || self.requestbody_id
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

