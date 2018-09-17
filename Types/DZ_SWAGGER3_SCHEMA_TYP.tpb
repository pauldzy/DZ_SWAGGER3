CREATE OR REPLACE TYPE BODY dz_swagger3_schema_typ
AS 

   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_schema_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_schema_typ;
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_schema_typ(
       p_schema_id            IN  VARCHAR2
      ,p_versionid            IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
   BEGIN
      
      -------------------------------------------------------------------------
      -- Step 10
      -- Skim off any non-object scalars
      -------------------------------------------------------------------------
      IF p_schema_id = 'string'
      THEN
          self.schema_scalar := 'string';
          RETURN;
          
      ELSIF p_schema_id = 'integer'
      THEN
          self.schema_scalar := 'integer';
          RETURN;
          
      END IF;
      
      -------------------------------------------------------------------------
      -- Step 20
      -- Process object definitions for remaining schema types
      -------------------------------------------------------------------------
   
   END dz_swagger3_schema_typ;

   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_schema_typ(
       p_schema_id               IN  VARCHAR2
      ,p_schema_title            IN  VARCHAR2
      ,p_schema_type             IN  VARCHAR2
      ,p_schema_description      IN  VARCHAR2
      ,p_schema_format           IN  VARCHAR2
      ,p_schema_nullable         IN  VARCHAR2
      ,p_schema_discriminator    IN  VARCHAR2
      ,p_schema_readonly         IN  VARCHAR2
      ,p_schema_writeonly        IN  VARCHAR2
      ,p_schema_externalDocs     IN  dz_swagger3_extrdocs_typ
      ,p_schema_example_string   IN  VARCHAR2
      ,p_schema_example_number   IN  NUMBER
      ,p_schema_deprecated       IN  VARCHAR2
      ,p_schema_items_schema     IN  dz_swagger3_schema_typ_nf
      ,p_schema_default_string   IN  VARCHAR2
      ,p_schema_default_number   IN  NUMBER 
      ,p_schema_multipleOf       IN  NUMBER 
      ,p_schema_minimum          IN  NUMBER 
      ,p_schema_exclusiveMinimum IN  VARCHAR2
      ,p_schema_maximum          IN  NUMBER 
      ,p_schema_exclusiveMaximum IN  VARCHAR2
      ,p_schema_minLength        IN  INTEGER 
      ,p_schema_maxLength        IN  INTEGER 
      ,p_schema_pattern          IN  VARCHAR2
      ,p_schema_minItems         IN  INTEGER 
      ,p_schema_maxItems         IN  INTEGER 
      ,p_schema_uniqueItems      IN  VARCHAR2 
      ,p_schema_minProperties    IN  INTEGER 
      ,p_schema_maxProperties    IN  INTEGER
      ,p_xml_name                IN  VARCHAR2
      ,p_xml_namespace           IN  VARCHAR2
      ,p_xml_prefix              IN  VARCHAR2
      ,p_xml_attribute           IN  VARCHAR2
      ,p_xml_wrapped             IN  VARCHAR2
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.schema_id               := p_schema_id;
      self.schema_title            := p_schema_title;
      self.schema_type             := p_schema_type;
      self.schema_description      := p_schema_description;
      self.schema_format           := p_schema_format;
      self.schema_nullable         := p_schema_nullable;
      self.schema_discriminator    := p_schema_discriminator;
      self.schema_readonly         := p_schema_readonly;
      self.schema_writeonly        := p_schema_writeonly;
      self.schema_externalDocs     := p_schema_externalDocs;
      self.schema_example_string   := p_schema_example_string;
      self.schema_deprecated       := p_schema_deprecated;
      self.schema_items_schema     := p_schema_items_schema;
      self.schema_default_string   := p_schema_default_string;
      self.schema_default_number   := p_schema_default_number;
      self.schema_multipleOf       := p_schema_multipleOf;
      self.schema_minimum          := p_schema_minimum;
      self.schema_exclusiveMinimum := p_schema_exclusiveMinimum;
      self.schema_maximum          := p_schema_maximum;
      self.schema_exclusiveMaximum := p_schema_exclusiveMaximum;
      self.schema_minLength        := p_schema_minLength;
      self.schema_maxLength        := p_schema_maxLength;
      self.schema_pattern          := p_schema_pattern;
      self.schema_minItems         := p_schema_minItems;
      self.schema_maxItems         := p_schema_maxItems;
      self.schema_uniqueItems      := p_schema_uniqueItems;
      self.schema_minProperties    := p_schema_minProperties;
      self.schema_maxProperties    := p_schema_maxProperties;
      self.xml_name                := p_xml_name;
      self.xml_namespace           := p_xml_namespace;
      self.xml_prefix              := p_xml_prefix;
      self.xml_attribute           := p_xml_attribute;
      self.xml_wrapped             := p_xml_wrapped;
      
      RETURN; 
      
   END dz_swagger3_schema_typ;
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   MEMBER FUNCTION isNULL
   RETURN VARCHAR2
   AS
   BEGIN
      IF self.schema_id IS NOT NULL
      OR self.schema_scalar IS NOT NULL
      THEN
         RETURN 'FALSE';
         
      ELSE
         RETURN 'TRUE';

      END IF;
      
   END isNULL;
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   MEMBER FUNCTION key
   RETURN VARCHAR2
   AS
   BEGIN
      RETURN self.schema_id;
      
   END key;
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print      IN  INTEGER  DEFAULT NULL
      ,p_jsonschema        IN  VARCHAR2 DEFAULT 'FALSE' 
   ) RETURN CLOB
   AS
      str_jsonschema   VARCHAR2(4000 Char) := UPPER(p_jsonschema);
      clb_output       CLOB;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_required     MDSYS.SDO_STRING2_ARRAY;
      int_counter      PLS_INTEGER;
      boo_temp         BOOLEAN;
      
   BEGIN
      
      -------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      -------------------------------------------------------------------------
      IF str_jsonschema IS NULL
      OR str_jsonschema NOT IN ('TRUE','FALSE')
      THEN
         str_jsonschema := 'FALSE';
         
      END IF;
      
      -------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      -------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         str_pad  := '';
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad  := ' ';
         
      END IF;
      
      -------------------------------------------------------------------------
      -- Step 30
      -- Add base attributes
      -------------------------------------------------------------------------
      str_pad1 := str_pad;
      
      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.value2json(
             'type'
            ,self.schema_type
            ,p_pretty_print + 1
         )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';
      
      -------------------------------------------------------------------------
      -- Step 40
      -- Add optional title object
      -------------------------------------------------------------------------
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
      
      -------------------------------------------------------------------------
      -- Step 50
      -- Add optional description object
      -------------------------------------------------------------------------
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
      
      -------------------------------------------------------------------------
      -- Step 60
      -- Add optional description object
      -------------------------------------------------------------------------
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
      
      -------------------------------------------------------------------------
      -- Step 70
      -- Add optional description object
      -------------------------------------------------------------------------
      IF self.schema_nullable IS NOT NULL
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
      
      -------------------------------------------------------------------------
      -- Step 80
      -- Add optional description object
      -------------------------------------------------------------------------
      IF self.schema_discriminator IS NOT NULL
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
      
      -------------------------------------------------------------------------
      -- Step 90
      -- Add optional description object
      -------------------------------------------------------------------------
      IF self.schema_readonly IS NOT NULL
      THEN
         IF LOWER(self.schema_readonly) = 'true'
         THEN
            boo_temp := TRUE;
            
         ELSE
            boo_temp := FALSE;
         
         END IF;
      
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'readonly'
               ,boo_temp
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
      
      END IF;
      
      -------------------------------------------------------------------------
      -- Step 100
      -- Add optional description object
      -------------------------------------------------------------------------
      IF self.schema_writeonly IS NOT NULL
      THEN
         IF LOWER(self.schema_writeonly) = 'true'
         THEN
            boo_temp := TRUE;
            
         ELSE
            boo_temp := FALSE;
         
         END IF;
      
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'writeonly'
               ,boo_temp
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
      
      END IF;
      
      -------------------------------------------------------------------------
      -- Step 110
      -- Add optional externalDocs
      -------------------------------------------------------------------------
      IF  self.schema_externalDocs IS NOT NULL
      AND self.schema_externalDocs.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.formatted2json(
                'externalDocs'
               ,self.schema_externalDocs.toJSON(p_pretty_print + 1)
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';

      END IF;
      
      -------------------------------------------------------------------------
      -- Step 120
      -- Add optional description object
      -------------------------------------------------------------------------
      IF self.schema_example_string IS NOT NULL
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
      
      -------------------------------------------------------------------------
      -- Step 130
      -- Add optional description object
      -------------------------------------------------------------------------
      IF self.schema_deprecated IS NOT NULL
      THEN
         IF LOWER(self.schema_deprecated) = 'true'
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
      
      -------------------------------------------------------------------------
      -- Step 140
      -- Add schema items
      -------------------------------------------------------------------------
      IF  self.schema_externalDocs IS NOT NULL
      AND self.schema_externalDocs.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.formatted2json(
                'items'
               ,self.schema_items.toJSON(p_pretty_print + 1)
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';

      END IF;
      
      -------------------------------------------------------------------------
      -- Step 140
      -- Add optional xml object
      -------------------------------------------------------------------------
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
                  ,dz_swagger_xml(
                      p_xml_name       => self.xml_name
                     ,p_xml_namespace  => self.xml_namespace
                     ,p_xml_prefix     => self.xml_prefix
                     ,p_xml_attribute  => self.xml_attribute
                     ,p_xml_wrapped    => self.xml_wrapped
                   ).toJSON(
                     p_pretty_print => p_pretty_print + 1
                   )
                  ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
         
      END IF;
  
      -------------------------------------------------------------------------
      -- Step 70
      -- Add properties
      -------------------------------------------------------------------------
      IF self.schema_properties IS NULL
      OR self.schema_properties.COUNT = 0
      THEN
         NULL;

      ELSE
         str_pad2 := str_pad;
         
         ary_required := MDSYS.SDO_STRING2_ARRAY();
         int_counter := 1;
      
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.fastname('properties',p_pretty_print) || '{'
            ,p_pretty_print + 1
         );
         
         FOR i IN 1 .. self.schema_properties.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                str_pad2 || self.schema_properties(i).toJSON(
                   p_pretty_print => p_pretty_print + 2
                  ,p_jsonschema   => str_jsonschema
                )
               ,p_pretty_print + 2
            );
            str_pad2 := ',';
            
            IF self.schema_properties(i).property_required = 'TRUE'
            THEN
               ary_required.EXTEND();
               ary_required(int_counter) := self.schema_properties(i).property;
               int_counter := int_counter + 1;

            END IF;
            
         END LOOP;

         clb_output := clb_output || dz_json_util.pretty(
             '}'
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      -------------------------------------------------------------------------
      -- Step 80
      -- Add properties required array
      -------------------------------------------------------------------------
         IF ary_required IS NOT NULL
         AND ary_required.COUNT > 0
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'required'
                  ,ary_required
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
         
         END IF;
      
      END IF;
        
      -------------------------------------------------------------------------
      -- Step 90
      -- Add the left bracket
      -------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      -------------------------------------------------------------------------
      -- Step 100
      -- Cough it out
      -------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print      IN  INTEGER  DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
   ) RETURN CLOB
   AS
      clb_output        CLOB;
      boo_required      BOOLEAN;
      boo_temp          BOOLEAN;
      
   BEGIN
      
      -------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      -------------------------------------------------------------------------
      
      -------------------------------------------------------------------------
      -- Step 20
      -- Do the type element
      -------------------------------------------------------------------------
      clb_output := dz_json_util.pretty_str(
          'type: ' || self.schema_type
         ,p_pretty_print
         ,'  '
      );
      
      -------------------------------------------------------------------------
      -- Step 30
      -- Add optional title object
      -------------------------------------------------------------------------
      IF self.schema_title IS NOT NULL
      THEN
         clb_output := dz_json_util.pretty_str(
             'title: ' || self.schema_title
            ,p_pretty_print
            ,'  '
         );
      
      END IF;
      
      -------------------------------------------------------------------------
      -- Step 40
      -- Add optional description object
      -------------------------------------------------------------------------
      IF self.schema_description IS NOT NULL
      THEN
         clb_output := dz_json_util.pretty_str(
             'description: ' || self.schema_description
            ,p_pretty_print
            ,'  '
         );
      
      END IF;
      
      -------------------------------------------------------------------------
      -- Step 40
      -- Add optional description object
      -------------------------------------------------------------------------
      IF self.schema_format IS NOT NULL
      THEN
         clb_output := dz_json_util.pretty_str(
             'format: ' || self.schema_format
            ,p_pretty_print
            ,'  '
         );
      
      END IF;
      
      -------------------------------------------------------------------------
      -- Step 40
      -- Add optional description object
      -------------------------------------------------------------------------
      IF self.schema_nullable IS NOT NULL
      THEN
         clb_output := dz_json_util.pretty_str(
             'nullable: ' || LOWER(self.schema_deprecated)
            ,p_pretty_print
            ,'  '
         );
      
      END IF;
      
      -------------------------------------------------------------------------
      -- Step 40
      -- Add optional description object
      -------------------------------------------------------------------------
      IF self.schema_discriminator IS NOT NULL
      THEN
         clb_output := dz_json_util.pretty_str(
             'discriminator: ' || self.schema_discriminator
            ,p_pretty_print
            ,'  '
         );
      
      END IF;
      
      -------------------------------------------------------------------------
      -- Step 40
      -- Add optional description object
      -------------------------------------------------------------------------
      IF self.schema_readonly IS NOT NULL
      THEN
         clb_output := dz_json_util.pretty_str(
             'readonly: ' || LOWER(self.schema_readonly)
            ,p_pretty_print
            ,'  '
         );
      
      END IF;
      
      -------------------------------------------------------------------------
      -- Step 40
      -- Add optional description object
      -------------------------------------------------------------------------
      IF self.schema_writeonly IS NOT NULL
      THEN
         clb_output := dz_json_util.pretty_str(
             'writeonly: ' || LOWER(self.schema_writeonly)
            ,p_pretty_print
            ,'  '
         );
      
      END IF;
      
      -------------------------------------------------------------------------
      -- Step 30
      -- Write the optional externalDocs object
      -------------------------------------------------------------------------
      IF  self.schema_externalDocs IS NOT NULL
      AND self.schema_externalDocs.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'externalDocs: ' 
            ,p_pretty_print
            ,'  '
         ) || self.schema_externalDocs.toYAML(
            p_pretty_print + 1
         );
         
      END IF;
      
      -------------------------------------------------------------------------
      -- Step 40
      -- Add optional description object
      -------------------------------------------------------------------------
      IF self.schema_example IS NOT NULL
      THEN
         clb_output := dz_json_util.pretty_str(
             'example: ' || self.schema_example
            ,p_pretty_print
            ,'  '
         );
      
      END IF;
      
      -------------------------------------------------------------------------
      -- Step 40
      -- Add optional description object
      -------------------------------------------------------------------------
      IF self.schema_deprecated IS NOT NULL
      THEN
         clb_output := dz_json_util.pretty_str(
             'deprecated: ' || LOWER(self.schema_deprecated)
            ,p_pretty_print
            ,'  '
         );
      
      END IF;

      -------------------------------------------------------------------------
      -- Step 50
      -- Add optional xml object
      -------------------------------------------------------------------------
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
         ) || dz_swagger3_xml(
             p_xml_name      => self.xml_name
            ,p_xml_namespace => self.xml_namespace
            ,p_xml_prefix    => self.xml_prefix
            ,p_xml_attribute => self.xml_attribute
            ,p_xml_wrapped   => self.xml_wrapped
         ).toYAML(
            p_pretty_print + 1
         );
      
      END IF; 
      
      -------------------------------------------------------------------------
      -- Step 60
      -- Add the properties
      -------------------------------------------------------------------------
      boo_required := FALSE;
      
      IF self.schema_properties IS NULL
      OR self.schema_properties.COUNT = 0
      THEN
         NULL;

      ELSE      
         clb_output := clb_output || dz_json_util.pretty_str(
             'properties: '
            ,p_pretty_print
            ,'  '
         );
          
         FOR i IN 1 .. self.schema_properties.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty_str(
                self.schema_properties(i).property || ': '
               ,p_pretty_print + 1
               ,'  '
            ) || self.schema_properties(i).toYAML(p_pretty_print + 1);
            
            IF self.schema_properties(i).property_required = 'TRUE'
            THEN
               boo_required := TRUE;
               
            END IF;
    
         END LOOP;
         
      -------------------------------------------------------------------------
      -- Step 70
      -- Add properties required array
      -------------------------------------------------------------------------
         IF boo_required
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'required: '
               ,p_pretty_print
               ,'  '
            );
            
            FOR i IN 1 .. self.schema_properties.COUNT
            LOOP
               IF self.schema_properties(i).property_required = 'TRUE'
               THEN
                  clb_output := clb_output || dz_json_util.pretty_str(
                      '- ' || self.schema_properties(i).property
                     ,p_pretty_print
                     ,'  '
                  );
                  
               END IF;
               
            END LOOP;
         
         END IF;
         
      END IF;
      
      -------------------------------------------------------------------------
      -- Step 70
      -- Cough it out with adjustments as needed
      -------------------------------------------------------------------------
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

