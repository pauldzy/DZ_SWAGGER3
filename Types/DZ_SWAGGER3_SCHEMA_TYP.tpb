CREATE OR REPLACE TYPE BODY dz_swagger3_schema_typ
AS 
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_schema_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_schema_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_schema_typ(
       p_schema_id               IN  VARCHAR2
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
      -- Load the easy items using constructor
      --------------------------------------------------------------------------
      SELECT
       a.schema_id
      ,a.schema_category
      ,a.schema_title
      ,a.schema_type
      ,a.schema_description
      ,a.schema_format
      ,a.schema_nullable
      ,a.schema_discriminator
      ,a.schema_readonly
      ,a.schema_writeonly
      ,CASE
       WHEN a.schema_externaldocs_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id => a.schema_externaldocs_id
            ,p_object_type_id => 'extrdocstyp'
         )
       ELSE
         NULL
       END
      ,a.schema_example_string
      ,a.schema_example_number
      ,a.schema_deprecated
      ,CASE
       WHEN a.schema_items_schema_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id      => a.schema_items_schema_id
            ,p_object_type_id => 'schematyp'
         )
       ELSE
         NULL
       END
      ,a.schema_default_string
      ,a.schema_default_number
      ,a.schema_multipleOf
      ,a.schema_minimum
      ,a.schema_exclusiveMinimum
      ,a.schema_maximum 
      ,a.schema_exclusiveMaximum
      ,a.schema_minLength
      ,a.schema_maxLength
      ,a.schema_pattern
      ,a.schema_minItems
      ,a.schema_maxItems
      ,a.schema_uniqueItems 
      ,a.schema_minProperties
      ,a.schema_maxProperties
      ,a.xml_name
      ,a.xml_namespace
      ,a.xml_prefix
      ,a.xml_attribute
      ,a.xml_wrapped
      ,a.schema_force_inline
      ,a.property_list_hidden
      INTO
       self.schema_id
      ,self.schema_category
      ,self.schema_title
      ,self.schema_type
      ,self.schema_description
      ,self.schema_format
      ,self.schema_nullable
      ,self.schema_discriminator
      ,self.schema_readonly
      ,self.schema_writeonly
      ,self.schema_externaldocs
      ,self.schema_example_string
      ,self.schema_example_number
      ,self.schema_deprecated
      ,self.schema_items_schema
      ,self.schema_default_string
      ,self.schema_default_number
      ,self.schema_multipleOf
      ,self.schema_minimum
      ,self.schema_exclusiveMinimum
      ,self.schema_maximum 
      ,self.schema_exclusiveMaximum
      ,self.schema_minLength
      ,self.schema_maxLength
      ,self.schema_pattern
      ,self.schema_minItems
      ,self.schema_maxItems
      ,self.schema_uniqueItems 
      ,self.schema_minProperties
      ,self.schema_maxProperties
      ,self.xml_name
      ,self.xml_namespace
      ,self.xml_prefix
      ,self.xml_attribute
      ,self.xml_wrapped
      ,self.schema_force_inline
      ,self.property_list_hidden
      FROM
      dz_swagger3_schema a
      WHERE
          a.versionid = p_versionid
      AND a.schema_id = p_schema_id;

      --------------------------------------------------------------------------
      -- Step 30
      -- Collect the enumerations
      --------------------------------------------------------------------------
      SELECT
      a.enum_string
      BULK COLLECT INTO
      self.schema_enum_string
      FROM
      dz_swagger3_schema_enum_map a
      WHERE
          a.versionid = p_versionid
      AND a.schema_id = p_schema_id
      AND a.enum_string IS NOT NULL
      ORDER BY
      a.enum_order;
      
      SELECT
      a.enum_number
      BULK COLLECT INTO
      self.schema_enum_number
      FROM
      dz_swagger3_schema_enum_map a
      WHERE
          a.versionid = p_versionid
      AND a.schema_id = p_schema_id
      AND a.enum_number IS NOT NULL
      ORDER BY
      a.enum_order;

      --------------------------------------------------------------------------
      -- Step 40
      -- Load the schema properties
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id           => a.property_schema_id 
         ,p_object_type_id      => 'schematyp'
         ,p_object_key          => a.property_name
         ,p_object_required     => a.property_required
         ,p_object_force_inline => b.schema_force_inline
         ,p_object_order        => a.property_order
      )
      BULK COLLECT INTO self.schema_properties
      FROM
      dz_swagger3_schema_prop_map a
      JOIN
      dz_swagger3_schema b
      ON
          a.versionid          = b.versionid
      AND a.property_schema_id = b.schema_id
      WHERE
          a.versionid        = p_versionid
      AND a.parent_schema_id = self.schema_id;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Load the schema combines
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id      => a.combine_schema_id
         ,p_object_type_id => 'schematyp'
         ,p_object_key     => a.combine_keyword
         ,p_object_order   => a.combine_order
      )
      BULK COLLECT INTO self.combine_schemas
      FROM
      dz_swagger3_schema_combine_map a
      WHERE
          a.versionid         = p_versionid
      AND a.schema_id         = self.schema_id;  

      --------------------------------------------------------------------------
      -- Step 60
      -- Return completed object
      --------------------------------------------------------------------------
      RETURN;
      
   END dz_swagger3_schema_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_schema_typ(
       p_schema_id                IN  VARCHAR2
      ,p_parameters               IN  dz_swagger3_object_vry
      ,p_versionid                IN  VARCHAR2
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
      -- Load the bare array to hold the parameter derived schema object
      --------------------------------------------------------------------------
      self.schema_id           := p_schema_id;
      self.schema_type         := 'object';
      self.schema_category     := 'object';
      self.schema_nullable     := 'FALSE';

      --------------------------------------------------------------------------
      -- Step 30
      -- Load the items on the schema object as properties
      --------------------------------------------------------------------------
      self.schema_properties := dz_swagger3_object_vry();
      self.schema_properties.EXTEND(p_parameters.COUNT);

      FOR i IN 1 .. p_parameters.COUNT
      LOOP
         self.schema_properties(i) := dz_swagger3_object_typ(
             p_object_id        => 'rb.' || p_parameters(i).object_id
            ,p_object_type_id   => 'schematyp'
            ,p_object_key       => p_parameters(i).object_key
            ,p_object_subtype   => 'emulated_item'
            ,p_object_attribute => p_parameters(i).object_id
            ,p_object_required  => p_parameters(i).object_required
            ,p_object_order     => p_parameters(i).object_order
         );
         
      END LOOP;

      --------------------------------------------------------------------------
      -- Step 50
      -- Return completed object
      --------------------------------------------------------------------------
      RETURN;
      
   END dz_swagger3_schema_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_schema_typ(
       p_schema_id                IN  VARCHAR2
      ,p_emulated_parameter_id    IN  VARCHAR2
      ,p_versionid                IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
      str_inner_schema_id VARCHAR2(255 Char);

   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Initialize the object
      --------------------------------------------------------------------------
      self.versionid := p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Load the bare array to hold the parameter derived schema object
      --------------------------------------------------------------------------
      self.schema_id := p_schema_id;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Load the parameter details to emulate
      --------------------------------------------------------------------------
      SELECT
       a.parameter_schema_id
      ,a.parameter_name || ' rb'
      ,a.parameter_description
      ,a.parameter_required
      ,a.parameter_example_string
      ,a.parameter_example_number
      ,a.parameter_list_hidden
      INTO
       str_inner_schema_id
      ,self.schema_title
      ,self.schema_description
      ,self.schema_required
      ,self.schema_example_string
      ,self.schema_example_number
      ,self.property_list_hidden
      FROM
      dz_swagger3_parameter a
      WHERE
          a.parameter_id = p_emulated_parameter_id
      AND a.versionid    = p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Load the easy items using constructor
      --------------------------------------------------------------------------
      SELECT
       a.schema_category
      ,a.schema_type
      ,a.schema_format
      ,a.schema_default_string
      ,a.schema_default_number
      ,a.schema_multipleOf
      ,a.schema_minimum
      ,a.schema_exclusiveMinimum
      ,a.schema_maximum 
      ,a.schema_exclusiveMaximum
      ,a.schema_minLength
      ,a.schema_maxLength
      ,a.schema_pattern
      ,a.schema_minItems
      ,a.schema_maxItems
      ,a.schema_uniqueItems 
      ,a.schema_minProperties
      ,a.schema_maxProperties
      INTO
       self.schema_category
      ,self.schema_type
      ,self.schema_format
      ,self.schema_default_string
      ,self.schema_default_number
      ,self.schema_multipleOf
      ,self.schema_minimum
      ,self.schema_exclusiveMinimum
      ,self.schema_maximum 
      ,self.schema_exclusiveMaximum
      ,self.schema_minLength
      ,self.schema_maxLength
      ,self.schema_pattern
      ,self.schema_minItems
      ,self.schema_maxItems
      ,self.schema_uniqueItems 
      ,self.schema_minProperties
      ,self.schema_maxProperties
      FROM
      dz_swagger3_schema a
      WHERE
          a.versionid = p_versionid
      AND a.schema_id = str_inner_schema_id;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Collect the enumerations
      --------------------------------------------------------------------------
      SELECT
      a.enum_string
      BULK COLLECT INTO
      self.schema_enum_string
      FROM
      dz_swagger3_schema_enum_map a
      WHERE
          a.versionid = p_versionid
      AND a.schema_id = str_inner_schema_id
      AND a.enum_string IS NOT NULL
      ORDER BY
      a.enum_order;
      
      SELECT
      a.enum_number
      BULK COLLECT INTO
      self.schema_enum_number
      FROM
      dz_swagger3_schema_enum_map a
      WHERE
          a.versionid = p_versionid
      AND a.schema_id = str_inner_schema_id
      AND a.enum_number IS NOT NULL
      ORDER BY
      a.enum_order;
   
      --------------------------------------------------------------------------
      -- Step 60
      -- Return completed object
      --------------------------------------------------------------------------
      RETURN;
      
   END dz_swagger3_schema_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Load the external docs
      --------------------------------------------------------------------------
      IF self.schema_externalDocs IS NOT NULL
      THEN
         dz_swagger3_loader.extrdocstyp(
             p_parent_id    => self.schema_id
            ,p_children_ids => dz_swagger3_object_vry(self.schema_externalDocs)
            ,p_versionid    => self.versionid
         );
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Load the items schema
      --------------------------------------------------------------------------
      IF self.schema_items_schema IS NOT NULL
      THEN
         dz_swagger3_loader.schematyp(
             p_parent_id    => self.schema_id
            ,p_children_ids => dz_swagger3_object_vry(self.schema_items_schema)
            ,p_versionid    => self.versionid
         );
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Load the properties schemas
      --------------------------------------------------------------------------
      IF  self.schema_properties IS NOT NULL
      AND self.schema_properties.COUNT > 0
      THEN
         dz_swagger3_loader.schematyp(
             p_parent_id    => self.schema_id
            ,p_children_ids => self.schema_properties
            ,p_versionid    => self.versionid
         );
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Load the combine schemas
      --------------------------------------------------------------------------
      IF  self.combine_schemas IS NOT NULL
      AND self.combine_schemas.COUNT > 0
      THEN
         dz_swagger3_loader.schematyp(
             p_parent_id    => self.schema_id
            ,p_children_ids => self.combine_schemas
            ,p_versionid    => self.versionid
         );
         
      END IF;

   END traverse;
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
      ,p_jsonschema          IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      str_jsonschema   VARCHAR2(4000 Char) := UPPER(p_jsonschema);
      clb_output       CLOB;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_items        MDSYS.SDO_STRING2_ARRAY;
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      ary_required     MDSYS.SDO_STRING2_ARRAY;
      clb_hash         CLOB;
      clb_tmp          CLOB;
      int_counter      PLS_INTEGER;
      boo_temp         BOOLEAN;
      str_identifier   VARCHAR2(255 Char);
      boo_is_not       BOOLEAN := FALSE;
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      IF str_jsonschema IS NULL
      OR str_jsonschema NOT IN ('TRUE','FALSE')
      THEN
         str_jsonschema := 'FALSE';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad  := ' ';
         
      END IF;
      
      str_pad1 := str_pad;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Branch if needed for combines
      --------------------------------------------------------------------------
      IF  self.combine_schemas IS NOT NULL
      AND self.combine_schemas.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.schematyp.toJSON( '
         || '    p_pretty_print     => :p01 + 2 '
         || '   ,p_force_inline     => :p02 '
         || '   ,p_short_id         => :p03 '
         || '   ,p_identifier       => a.object_id '
         || '   ,p_short_identifier => a.short_id '
         || '   ,p_reference_count  => a.reference_count '
         || '   ,p_jsonschema       => :p04 '
         || ' ) '
         || ',b.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p05) b '
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
         ,p_jsonschema
         ,self.combine_schemas; 
          
         IF ary_keys.COUNT = 1 AND ary_keys(1) = 'not'
         THEN
            boo_is_not := TRUE;
         
         END IF;
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add base attributes
      --------------------------------------------------------------------------
         IF self.schema_type IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'type'
                  ,self.schema_type
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add the left bracket
      --------------------------------------------------------------------------
         IF boo_is_not
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad || dz_json_main.formatted2json(
                   'not'
                  ,ary_clb(1)
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad := ',';
         
         ELSE
            str_pad2 := str_pad;
               
            IF p_pretty_print IS NULL
            THEN
               clb_hash := dz_json_util.pretty('[',NULL);
               
            ELSE
               clb_hash := dz_json_util.pretty('[',-1);
               
            END IF;
         
            FOR i IN 1 .. combine_schemas.COUNT
            LOOP
               clb_hash := clb_hash || dz_json_util.pretty(
                   str_pad2 || ary_clb(i)
                  ,p_pretty_print + 2
               );
               str_pad2 := ',';
            
            END LOOP;
            
            clb_hash := clb_hash || dz_json_util.pretty(
                ']'
               ,p_pretty_print + 1,NULL,NULL
            );
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                    ary_keys(1)
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
      
      ELSE
      --------------------------------------------------------------------------
      -- Step 60
      -- Branch if needed for ref
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
                  ,'#/components/schemas/' || dz_swagger3_util.utl_url_escape(
                     str_identifier
                   )
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         ELSE
      --------------------------------------------------------------------------
      -- Step 70
      -- Add optional title object
      --------------------------------------------------------------------------
            IF self.inject_jsonschema = 'TRUE'
            THEN
               clb_output := clb_output || dz_json_util.pretty(
                   str_pad1 || dz_json_main.value2json(
                      '$schema'
                     ,'http://json-schema.org/draft-04/schema#'
                     ,p_pretty_print + 1
                  )
                  ,p_pretty_print + 1
               );
               str_pad1 := ',';
            
            END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Add base attributes
      --------------------------------------------------------------------------
            IF str_jsonschema = 'TRUE'
            AND self.schema_nullable = 'TRUE'
            THEN
               clb_output := clb_output || dz_json_util.pretty(
                   str_pad1 || dz_json_main.value2json(
                      'type'
                     ,MDSYS.SDO_STRING2_ARRAY(self.schema_type,'null')
                     ,p_pretty_print + 1
                  )
                  ,p_pretty_print + 1
               );
               str_pad1 := ',';
            
            ELSE
               clb_output := clb_output || dz_json_util.pretty(
                   str_pad1 || dz_json_main.value2json(
                      'type'
                     ,self.schema_type
                     ,p_pretty_print + 1
                  )
                  ,p_pretty_print + 1
               );
               str_pad1 := ',';
            
            END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Add optional title object
      --------------------------------------------------------------------------
            IF self.schema_title IS NOT NULL
            THEN
               clb_output := clb_output || dz_json_util.pretty(
                   str_pad1 || dz_json_main.value2json(
                      'title'
                     ,self.schema_title
                     ,p_pretty_print + 1
                  )
                  ,p_pretty_print + 1
               );
               str_pad1 := ',';
            
            END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Add optional description object
      --------------------------------------------------------------------------
            IF self.schema_description IS NOT NULL
            THEN
               clb_output := clb_output || dz_json_util.pretty(
                   str_pad1 || dz_json_main.value2json(
                      'description'
                     ,self.schema_description
                     ,p_pretty_print + 1
                  )
                  ,p_pretty_print + 1
               );
               str_pad1 := ',';
            
            END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Add optional description object
      --------------------------------------------------------------------------
            IF self.schema_format IS NOT NULL
            THEN
               clb_output := clb_output || dz_json_util.pretty(
                   str_pad1 || dz_json_main.value2json(
                      'format'
                     ,self.schema_format
                     ,p_pretty_print + 1
                  )
                  ,p_pretty_print + 1
               );
               str_pad1 := ',';
            
            END IF;
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Add optional enum array
      --------------------------------------------------------------------------
            IF  self.schema_enum_string IS NOT NULL
            AND self.schema_enum_string.COUNT > 0
            THEN
               clb_output := clb_output || dz_json_util.pretty(
                   str_pad1 || dz_json_main.value2json(
                      'enum'
                     ,self.schema_enum_string
                     ,p_pretty_print + 1
                  )
                  ,p_pretty_print + 1
               );
               str_pad1 := ',';
            
            ELSIF  self.schema_enum_number IS NOT NULL
            AND self.schema_enum_number.COUNT > 0
            THEN
               clb_output := clb_output || dz_json_util.pretty(
                   str_pad1 || dz_json_main.value2json(
                      'enum'
                     ,self.schema_enum_number
                     ,p_pretty_print + 1
                  )
                  ,p_pretty_print + 1
               );
               str_pad1 := ',';
            
            END IF;
      
      --------------------------------------------------------------------------
      -- Step 130
      -- Add optional description object
      --------------------------------------------------------------------------
            IF  self.schema_nullable IS NOT NULL
            AND str_jsonschema <> 'TRUE'
            THEN
               IF LOWER(self.schema_nullable) = 'true'
               THEN
                  boo_temp := TRUE;
                  
               ELSE
                  boo_temp := FALSE;
               
               END IF;
            
               clb_output := clb_output || dz_json_util.pretty(
                   str_pad1 || dz_json_main.value2json(
                      'nullable'
                     ,boo_temp
                     ,p_pretty_print + 1
                  )
                  ,p_pretty_print + 1
               );
               str_pad1 := ',';
            
            END IF;
      
      --------------------------------------------------------------------------
      -- Step 140
      -- Add optional description object
      --------------------------------------------------------------------------
            IF self.schema_discriminator IS NOT NULL
            AND str_jsonschema <> 'TRUE'
            THEN
               clb_output := clb_output || dz_json_util.pretty(
                   str_pad1 || dz_json_main.value2json(
                      'discriminator'
                     ,self.schema_discriminator
                     ,p_pretty_print + 1
                  )
                  ,p_pretty_print + 1
               );
               str_pad1 := ',';
            
            END IF;
      
      --------------------------------------------------------------------------
      -- Step 150
      -- Add optional readOnly and writeOnly attributes
      --------------------------------------------------------------------------
            IF self.schema_readOnly IS NOT NULL
            AND str_jsonschema <> 'TRUE'
            THEN
               IF LOWER(self.schema_readOnly) = 'true'
               THEN
                  boo_temp := TRUE;
                  
               ELSE
                  boo_temp := FALSE;
               
               END IF;
            
               clb_output := clb_output || dz_json_util.pretty(
                   str_pad1 || dz_json_main.value2json(
                      'readOnly'
                     ,boo_temp
                     ,p_pretty_print + 1
                  )
                  ,p_pretty_print + 1
               );
               str_pad1 := ',';
            
            END IF;
            
            IF self.schema_writeOnly IS NOT NULL
            AND str_jsonschema <> 'TRUE'
            THEN
               IF LOWER(self.schema_writeOnly) = 'true'
               THEN
                  boo_temp := TRUE;
                  
               ELSE
                  boo_temp := FALSE;
               
               END IF;
            
               clb_output := clb_output || dz_json_util.pretty(
                   str_pad1 || dz_json_main.value2json(
                      'writeOnly'
                     ,boo_temp
                     ,p_pretty_print + 1
                  )
                  ,p_pretty_print + 1
               );
               str_pad1 := ',';
            
            END IF;
      
      --------------------------------------------------------------------------
      -- Step 160
      -- Add optional minItems and MaxItems attribute
      --------------------------------------------------------------------------
            IF self.schema_maxItems IS NOT NULL
            THEN
               clb_output := clb_output || dz_json_util.pretty(
                   str_pad1 || dz_json_main.value2json(
                      'maxItems'
                     ,self.schema_maxItems
                     ,p_pretty_print + 1
                  )
                  ,p_pretty_print + 1
               );
               str_pad1 := ',';
            
            END IF;
            
            IF self.schema_minItems IS NOT NULL
            THEN
               clb_output := clb_output || dz_json_util.pretty(
                   str_pad1 || dz_json_main.value2json(
                      'minItems'
                     ,self.schema_minItems
                     ,p_pretty_print + 1
                  )
                  ,p_pretty_print + 1
               );
               str_pad1 := ',';
            
            END IF;
      
      --------------------------------------------------------------------------
      -- Step 170
      -- Add optional minProperties and MaxProperties attribute
      --------------------------------------------------------------------------
            IF self.schema_maxProperties IS NOT NULL
            THEN
               clb_output := clb_output || dz_json_util.pretty(
                   str_pad1 || dz_json_main.value2json(
                      'maxProperties'
                     ,self.schema_maxProperties
                     ,p_pretty_print + 1
                  )
                  ,p_pretty_print + 1
               );
               str_pad1 := ',';
            
            END IF;
            
            IF self.schema_minProperties IS NOT NULL
            THEN
               clb_output := clb_output || dz_json_util.pretty(
                   str_pad1 || dz_json_main.value2json(
                      'minProperties'
                     ,self.schema_minProperties
                     ,p_pretty_print + 1
                  )
                  ,p_pretty_print + 1
               );
               str_pad1 := ',';
            
            END IF;
      
      --------------------------------------------------------------------------
      -- Step 180
      -- Add optional externalDocs
      --------------------------------------------------------------------------
            IF  self.schema_externalDocs IS NOT NULL
            AND str_jsonschema <> 'TRUE'
            THEN
               BEGIN
                  EXECUTE IMMEDIATE
                     'SELECT '
                  || 'a.extrdocstyp.toJSON( '
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
                  ,self.schema_externalDocs.object_type_id 
                  ,self.schema_externalDocs.object_id;
               
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     clb_tmp := NULL;
                     
                  WHEN OTHERS
                  THEN
                     RAISE;
                     
               END; 
            
               clb_output := clb_output || dz_json_util.pretty(
                   str_pad || dz_json_main.formatted2json(
                      'externalDocs'
                     ,clb_tmp
                     ,p_pretty_print + 1
                  )
                  ,p_pretty_print + 1
               );
               str_pad := ',';

            END IF;
      
      --------------------------------------------------------------------------
      -- Step 190
      -- Add optional example scalars
      --------------------------------------------------------------------------
            IF self.schema_example_string IS NOT NULL
            AND str_jsonschema <> 'TRUE'
            THEN
               clb_output := clb_output || dz_json_util.pretty(
                   str_pad1 || dz_json_main.value2json(
                      'example'
                     ,self.schema_example_string
                     ,p_pretty_print + 1
                  )
                  ,p_pretty_print + 1
               );
               str_pad1 := ',';
            
            ELSIF self.schema_example_number IS NOT NULL
            AND str_jsonschema <> 'TRUE'
            THEN
               clb_output := clb_output || dz_json_util.pretty(
                   str_pad1 || dz_json_main.value2json(
                      'example'
                     ,self.schema_example_number
                     ,p_pretty_print + 1
                  )
                  ,p_pretty_print + 1
               );
               str_pad1 := ',';
            
            END IF;
      
      --------------------------------------------------------------------------
      -- Step 200
      -- Add optional deprecated object
      --------------------------------------------------------------------------
            IF  LOWER(self.schema_deprecated) = 'true'
            AND str_jsonschema <> 'TRUE'
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
      -- Step 210
      -- Add schema items
      --------------------------------------------------------------------------
            IF self.schema_items_schema IS NOT NULL
            THEN
               BEGIN
                  EXECUTE IMMEDIATE
                     'SELECT '
                  || 'a.schematyp.toJSON( '
                  || '    p_pretty_print     => :p01 + 1 '
                  || '   ,p_force_inline     => :p02 '
                  || '   ,p_short_id         => :p03 '
                  || '   ,p_identifier       => a.object_id '
                  || '   ,p_short_identifier => a.short_id '
                  || '   ,p_reference_count  => a.reference_count '
                  || ') '
                  || 'FROM '
                  || 'dz_swagger3_xobjects a '
                  || 'WHERE '
                  || '    a.object_type_id = :p04 '
                  || 'AND a.object_id      = :p05 '
                  INTO 
                  clb_tmp
                  USING
                   p_pretty_print
                  ,p_force_inline
                  ,p_short_id
                  ,self.schema_items_schema.object_type_id
                  ,self.schema_items_schema.object_id;
               
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
                      'items'
                     ,clb_tmp
                     ,p_pretty_print + 1
                  )
                  ,p_pretty_print + 1
               );
               str_pad1 := ',';

            END IF;
      
      --------------------------------------------------------------------------
      -- Step 220
      -- Add optional xml object
      --------------------------------------------------------------------------
            IF str_jsonschema = 'FALSE'
            THEN
               IF self.xml_name      IS NOT NULL
               OR self.xml_namespace IS NOT NULL
               OR self.xml_prefix    IS NOT NULL
               OR self.xml_attribute IS NOT NULL
               OR self.xml_wrapped   IS NOT NULL
               THEN
                  clb_output := clb_output || dz_json_util.pretty(
                      str_pad1 || dz_json_main.formatted2json(
                         'xml'
                        ,dz_swagger3_xml_typ(
                            p_xml_name       => self.xml_name
                           ,p_xml_namespace  => self.xml_namespace
                           ,p_xml_prefix     => self.xml_prefix
                           ,p_xml_attribute  => self.xml_attribute
                           ,p_xml_wrapped    => self.xml_wrapped
                         ).toJSON(
                            p_pretty_print   => p_pretty_print + 1
                           ,p_force_inline   => p_force_inline
                         )
                        ,p_pretty_print + 1
                      )
                     ,p_pretty_print + 1
                  );
                  str_pad1 := ',';
                  
               END IF;
               
            END IF;
      
      -------------------------------------------------------------------------
      -- Step 230
      -- Add parameters
      -------------------------------------------------------------------------
            IF  self.schema_properties IS NOT NULL 
            AND self.schema_properties.COUNT > 0
            THEN
               EXECUTE IMMEDIATE
                  'SELECT '
               || ' a.schematyp.toJSON( '
               || '    p_pretty_print     => :p01 + 2 '
               || '   ,p_force_inline     => :p02 '
               || '   ,p_short_id         => :p03 '
               || '   ,p_identifier       => a.object_id '
               || '   ,p_short_identifier => a.short_id '
               || '   ,p_reference_count  => a.reference_count '
               || ' ) '
               || ',b.object_key '
               || ',b.object_required '
               || 'FROM '
               || 'dz_swagger3_xobjects a '
               || 'JOIN '
               || 'TABLE(:p04) b '
               || 'ON '
               || '    a.object_type_id = b.object_type_id '
               || 'AND a.object_id      = b.object_id '
               || 'WHERE '
               || 'COALESCE(a.schematyp.property_list_hidden,''FALSE'') <> ''TRUE'' '
               || 'ORDER BY b.object_order '
               BULK COLLECT INTO 
                ary_clb
               ,ary_keys
               ,ary_required
               USING
                p_pretty_print
               ,p_force_inline
               ,p_short_id
               ,self.schema_properties; 

               str_pad2 := str_pad;
               ary_items := MDSYS.SDO_STRING2_ARRAY();
               
               IF p_pretty_print IS NULL
               THEN
                  clb_hash := dz_json_util.pretty('{',NULL);
                  
               ELSE
                  clb_hash := dz_json_util.pretty('{',-1);
                  
               END IF;

               int_counter := 1;
               FOR i IN 1 .. ary_keys.COUNT
               LOOP
                  clb_hash := clb_hash || dz_json_util.pretty(
                      str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                     ,p_pretty_print + 2
                  );
                  str_pad2 := ',';
                  
                  IF ary_required(i) = 'TRUE'
                  THEN
                     ary_items.EXTEND();
                     ary_items(int_counter) := ary_keys(i);
                     int_counter := int_counter + 1;

                  END IF;
               
               END LOOP;
               
               clb_hash := clb_hash || dz_json_util.pretty(
                   '}'
                  ,p_pretty_print + 1,NULL,NULL
               );
               
               clb_output := clb_output || dz_json_util.pretty(
                   str_pad1 || dz_json_main.formatted2json(
                       'properties'
                      ,clb_hash
                      ,p_pretty_print + 1
                   )
                  ,p_pretty_print + 1
               );
               str_pad1 := ',';
         
      -------------------------------------------------------------------------
      -- Step 240
      -- Add required array
      -------------------------------------------------------------------------
               IF ary_items IS NOT NULL
               AND ary_items.COUNT > 0
               THEN
                  clb_output := clb_output || dz_json_util.pretty(
                      str_pad1 || dz_json_main.value2json(
                         'required'
                        ,ary_items
                        ,p_pretty_print + 1
                     )
                     ,p_pretty_print + 1
                  );
                  str_pad1 := ',';
               
               END IF;
               
            END IF;
            
         END IF;
            
      END IF;

      --------------------------------------------------------------------------
      -- Step 250
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 260
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
      ary_items        MDSYS.SDO_STRING2_ARRAY;
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      ary_required     MDSYS.SDO_STRING2_ARRAY;
      clb_hash         CLOB;
      clb_tmp          CLOB;
      int_counter      PLS_INTEGER;
      boo_check        BOOLEAN;
      str_identifier   VARCHAR2(255 Char);
      boo_is_not       BOOLEAN := FALSE;
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Branch if needed for combines
      --------------------------------------------------------------------------
      IF  self.combine_schemas IS NOT NULL
      AND self.combine_schemas.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.schematyp.toYAML( '
         || '    p_pretty_print     => :p01 + 2 '
         || '   ,p_initial_indent   => ''FALSE'' '
         || '   ,p_final_linefeed   => ''FALSE'' '
         || '   ,p_force_inline     => :p02 '
         || '   ,p_short_id         => :p03 '
         || '   ,p_identifier       => a.object_id '
         || '   ,p_short_identifier => a.short_id '
         || '   ,p_reference_count  => a.reference_count '
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
         ,self.combine_schemas;
            
         IF ary_keys.COUNT = 1 AND ary_keys(1) = 'not'
         THEN
            boo_is_not := TRUE;
         
         END IF;
         
      --------------------------------------------------------------------------
      -- Step 30
      -- Do the type element
      --------------------------------------------------------------------------
         IF self.schema_type IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'type: ' || self.schema_type
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Do the not combine schema array
      --------------------------------------------------------------------------
         IF boo_is_not 
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'not: ' 
               ,p_pretty_print
               ,'  '
            ) || ary_clb(1);
         
         ELSE 
            clb_output := clb_output || dz_json_util.pretty_str(
                ary_keys(1) || ': '
               ,p_pretty_print
               ,'  '
            );
         
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   '- ' || ary_clb(i)
                  ,p_pretty_print + 1
                  ,'  '
               );
               
            END LOOP;
            
         END IF;
      
      ELSE
      --------------------------------------------------------------------------
      -- Step 50
      -- Branch if needed for ref
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
                   '#/components/schemas/' || str_identifier
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         ELSE
      --------------------------------------------------------------------------
      -- Step 60
      -- Do the type element
      --------------------------------------------------------------------------
            clb_output := clb_output || dz_json_util.pretty_str(
                'type: ' || self.schema_type
               ,p_pretty_print
               ,'  '
            );
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Add optional title object
      --------------------------------------------------------------------------
            IF self.schema_title IS NOT NULL
            THEN
               clb_output := clb_output || dz_json_util.pretty_str(
                   'title: ' || dz_swagger3_util.yamlq(self.schema_title)
                  ,p_pretty_print
                  ,'  '
               );
            
            END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Add optional description object
      --------------------------------------------------------------------------
            IF self.schema_description IS NOT NULL
            THEN
               clb_output := clb_output || dz_json_util.pretty_str(
                   'description: ' || dz_swagger3_util.yaml_text(
                      REGEXP_REPLACE(self.schema_description,CHR(10) || '$','')
                     ,p_pretty_print
                  )
                  ,p_pretty_print
                  ,'  '
               );
            
            END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Add optional format attribute
      --------------------------------------------------------------------------
            IF self.schema_format IS NOT NULL
            THEN
               clb_output := clb_output || dz_json_util.pretty_str(
                   'format: ' || self.schema_format
                  ,p_pretty_print
                  ,'  '
               );
            
            END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Add optional nullable attribute
      --------------------------------------------------------------------------
            IF self.schema_nullable IS NOT NULL
            THEN
               clb_output := clb_output || dz_json_util.pretty_str(
                   'nullable: ' || LOWER(self.schema_nullable)
                  ,p_pretty_print
                  ,'  '
               );
            
            END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Add optional enum array
      --------------------------------------------------------------------------
            IF  self.schema_enum_string IS NOT NULL
            AND self.schema_enum_string.COUNT > 0
            THEN
               clb_output := clb_output || dz_json_util.pretty_str(
                   'enum: '
                  ,p_pretty_print
                  ,'  '
               );
               
               FOR i IN 1 .. self.schema_enum_string.COUNT
               LOOP
                  clb_output := clb_output || dz_json_util.pretty_str(
                      '- ' || dz_swagger3_util.yamlq(self.schema_enum_string(i))
                     ,p_pretty_print + 1
                     ,'  '
                  );
                  
               END LOOP;
            
            ELSIF  self.schema_enum_number IS NOT NULL
            AND self.schema_enum_number.COUNT > 0
            THEN
               clb_output := clb_output || dz_json_util.pretty_str(
                   'enum: '
                  ,p_pretty_print
                  ,'  '
               );
               
               FOR i IN 1 .. self.schema_enum_number.COUNT
               LOOP
                  clb_output := clb_output || dz_json_util.pretty_str(
                      '- ' || self.schema_enum_number(i)
                     ,p_pretty_print + 1
                     ,'  '
                  );
                  
               END LOOP;
            
            END IF;
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Add optional discriminator attribute
      --------------------------------------------------------------------------
            IF self.schema_discriminator IS NOT NULL
            THEN
               clb_output := clb_output || dz_json_util.pretty_str(
                   'discriminator: ' || self.schema_discriminator
                  ,p_pretty_print
                  ,'  '
               );
            
            END IF;
      
      --------------------------------------------------------------------------
      -- Step 130
      -- Add optional readonly and writeonly booleans
      --------------------------------------------------------------------------
            IF self.schema_readOnly IS NOT NULL
            THEN
               clb_output := clb_output || dz_json_util.pretty_str(
                   'readOnly: ' || LOWER(self.schema_readOnly)
                  ,p_pretty_print
                  ,'  '
               );
            
            END IF;
            
            IF self.schema_writeOnly IS NOT NULL
            THEN
               clb_output := clb_output || dz_json_util.pretty_str(
                   'writeOnly: ' || LOWER(self.schema_writeOnly)
                  ,p_pretty_print
                  ,'  '
               );
            
            END IF;
      
      --------------------------------------------------------------------------
      -- Step 140
      -- Add optional maxitems and minitems
      --------------------------------------------------------------------------
            IF self.schema_minItems IS NOT NULL
            THEN
               clb_output := clb_output || dz_json_util.pretty_str(
                   'minItems: ' || self.schema_minItems
                  ,p_pretty_print
                  ,'  '
               );
            
            END IF;
            
            IF self.schema_maxItems IS NOT NULL
            THEN
               clb_output := clb_output || dz_json_util.pretty_str(
                   'maxItems: ' || self.schema_maxItems
                  ,p_pretty_print
                  ,'  '
               );
            
            END IF;
      
      --------------------------------------------------------------------------
      -- Step 150
      -- Add optional maxProperties and minProperties
      --------------------------------------------------------------------------
            IF self.schema_minProperties IS NOT NULL
            THEN
               clb_output := clb_output || dz_json_util.pretty_str(
                   'minProperties: ' || self.schema_minProperties
                  ,p_pretty_print
                  ,'  '
               );
            
            END IF;
            
            IF self.schema_maxProperties IS NOT NULL
            THEN
               clb_output := clb_output || dz_json_util.pretty_str(
                   'maxProperties: ' || self.schema_maxProperties
                  ,p_pretty_print
                  ,'  '
               );
            
            END IF;
      
      --------------------------------------------------------------------------
      -- Step 160
      -- Write the optional externalDocs object
      --------------------------------------------------------------------------
            IF  self.schema_externalDocs IS NOT NULL
            AND self.schema_externalDocs.object_id IS NOT NULL
            THEN
               BEGIN
                  EXECUTE IMMEDIATE
                     'SELECT '
                  || 'a.extrdocstyp.toYAML( '
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
                  ,self.schema_externalDocs.object_type_id
                  ,self.schema_externalDocs.object_id; 
               
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     clb_tmp := NULL;
                     
                  WHEN OTHERS
                  THEN
                     RAISE;
                     
               END;
            
               clb_output := clb_output || dz_json_util.pretty_str(
                   'externalDocs: ' 
                  ,p_pretty_print
                  ,'  '
               ) || clb_tmp;
               
            END IF;
      
      --------------------------------------------------------------------------
      -- Step 170
      -- Add optional description object
      --------------------------------------------------------------------------
            IF self.schema_example_string IS NOT NULL
            THEN
               clb_output := clb_output || dz_json_util.pretty_str(
                   'example: ' || dz_swagger3_util.yamlq(self.schema_example_string)
                  ,p_pretty_print
                  ,'  '
               );
            
            ELSIF self.schema_example_number IS NOT NULL
            THEN
               clb_output := clb_output || dz_json_util.pretty_str(
                   'example: ' || self.schema_example_number
                  ,p_pretty_print
                  ,'  '
               );
            
            END IF;
      
      --------------------------------------------------------------------------
      -- Step 180
      -- Add optional deprecated flag
      --------------------------------------------------------------------------
            IF self.schema_deprecated IS NOT NULL
            THEN
               clb_output := clb_output || dz_json_util.pretty_str(
                   'deprecated: ' || LOWER(self.schema_deprecated)
                  ,p_pretty_print
                  ,'  '
               );
            
            END IF;
      
      --------------------------------------------------------------------------
      -- Step 190
      -- Write the optional externalDocs object
      --------------------------------------------------------------------------
            IF  self.schema_items_schema IS NOT NULL
            AND self.schema_items_schema.object_id IS NOT NULL
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
                      a.object_type_id = self.schema_items_schema.object_type_id
                  AND a.object_id      = self.schema_items_schema.object_id;
                  
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     clb_tmp := NULL;
                     
                  WHEN OTHERS
                  THEN
                     RAISE;
                     
               END;
            
               clb_output := clb_output || dz_json_util.pretty_str(
                   'items: ' 
                  ,p_pretty_print
                  ,'  '
               ) || clb_tmp;
               
            END IF;

      --------------------------------------------------------------------------
      -- Step 200
      -- Add optional xml object
      --------------------------------------------------------------------------
            IF self.xml_name      IS NOT NULL
            OR self.xml_namespace IS NOT NULL
            OR self.xml_prefix    IS NOT NULL
            OR self.xml_attribute IS NOT NULL
            OR self.xml_wrapped   IS NOT NULL
            THEN
               clb_output := clb_output || dz_json_util.pretty_str(
                   'xml: '
                  ,p_pretty_print
                  ,'  '
               ) || dz_swagger3_xml_typ(
                   p_xml_name      => self.xml_name
                  ,p_xml_namespace => self.xml_namespace
                  ,p_xml_prefix    => self.xml_prefix
                  ,p_xml_attribute => self.xml_attribute
                  ,p_xml_wrapped   => self.xml_wrapped
               ).toYAML(
                   p_pretty_print   => p_pretty_print + 1
                  ,p_force_inline   => p_force_inline
               );
            
            END IF;
      
      -------------------------------------------------------------------------
      -- Step 210
      -- Write the properties map
      -------------------------------------------------------------------------
            IF  self.schema_properties IS NOT NULL 
            AND self.schema_properties.COUNT > 0
            THEN
               EXECUTE IMMEDIATE
                  'SELECT '
               || ' a.schematyp.toYAML( '
               || '    p_pretty_print     => :p01 + 2 '
               || '   ,p_force_inline     => :p02 '
               || '   ,p_short_id         => :p03 '
               || '   ,p_identifier       => a.object_id '
               || '   ,p_short_identifier => a.short_id '
               || '   ,p_reference_count  => a.reference_count '
               || ' ) '
               || ',b.object_key '
               || ',b.object_required '
               || 'FROM '
               || 'dz_swagger3_xobjects a '
               || 'JOIN '
               || 'TABLE(:p04) b '
               || 'ON '
               || '    a.object_type_id = b.object_type_id '
               || 'AND a.object_id      = b.object_id '
               || 'WHERE '
               || 'COALESCE(a.schematyp.property_list_hidden,''FALSE'') <> ''TRUE'' '
               || 'ORDER BY b.object_order '
               BULK COLLECT INTO 
                ary_clb
               ,ary_keys
               ,ary_required
               USING
                p_pretty_print
               ,p_force_inline
               ,p_short_id
               ,self.schema_properties;          
               
               boo_check    := FALSE;
               int_counter  := 1;
               ary_items    := MDSYS.SDO_STRING2_ARRAY();
               
               clb_output := clb_output || dz_json_util.pretty_str(
                   'properties: '
                  ,p_pretty_print
                  ,'  '
               );

               FOR i IN 1 .. ary_keys.COUNT
               LOOP
                  clb_output := clb_output || dz_json_util.pretty(
                      dz_swagger3_util.yamlq(ary_keys(i)) || ': '
                     ,p_pretty_print + 1
                     ,'  '
                  ) || ary_clb(i);
                  
                  IF ary_required(i) = 'TRUE'
                  THEN
                     ary_items.EXTEND();
                     ary_items(int_counter) := ary_keys(i);
                     int_counter := int_counter + 1;
                     boo_check   := TRUE;

                  END IF;
               
               END LOOP;
         
      --------------------------------------------------------------------------
      -- Step 220
      -- Add requirements array
      --------------------------------------------------------------------------
               IF boo_check
               THEN
                  clb_output := clb_output || dz_json_util.pretty_str(
                      'required: '
                     ,p_pretty_print
                     ,'  '
                  );
                  
                  FOR i IN 1 .. ary_items.COUNT
                  LOOP
                     clb_output := clb_output || dz_json_util.pretty_str(
                         '- ' || dz_swagger3_util.yamlq(ary_items(i))
                        ,p_pretty_print + 1
                        ,'  '
                     );
                     
                  END LOOP;

               END IF;
               
            END IF;
            
         END IF;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 230
      -- Cough it out with adjustments as needed
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

