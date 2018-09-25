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
       p_hash_key                IN  VARCHAR2
      ,p_schema_id               IN  VARCHAR2
      ,p_required                IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
      str_items_schema_id  VARCHAR2(255 Char);
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Load the easy items using constructor
      --------------------------------------------------------------------------
      BEGIN
         SELECT
          dz_swagger3_schema_typ(
             p_schema_id               => a.schema_id
            ,p_schema_title            => a.schema_title
            ,p_schema_type             => a.schema_type
            ,p_schema_description      => a.schema_description
            ,p_schema_format           => a.schema_format
            ,p_schema_nullable         => a.schema_nullable
            ,p_schema_discriminator    => a.schema_discriminator
            ,p_schema_readonly         => a.schema_readonly
            ,p_schema_writeonly        => a.schema_writeonly
            ,p_schema_externalDocs     => dz_swagger3_extrdocs_typ(
                p_externaldoc_id          => a.schema_externaldocs_id
               ,p_versionid               => p_versionid
             )
            ,p_schema_example_string   => a.schema_example_string
            ,p_schema_example_number   => a.schema_example_number
            ,p_schema_deprecated       => a.schema_deprecated 
            ,p_schema_default_string   => a.schema_default_string
            ,p_schema_default_number   => a.schema_default_number
            ,p_schema_multipleOf       => a.schema_multipleOf
            ,p_schema_minimum          => a.schema_minimum
            ,p_schema_exclusiveMinimum => a.schema_exclusiveMinimum
            ,p_schema_maximum          => a.schema_maximum 
            ,p_schema_exclusiveMaximum => a.schema_exclusiveMaximum
            ,p_schema_minLength        => a.schema_minLength
            ,p_schema_maxLength        => a.schema_maxLength
            ,p_schema_pattern          => a.schema_pattern
            ,p_schema_minItems         => a.schema_minItems
            ,p_schema_maxItems         => a.schema_maxItems
            ,p_schema_uniqueItems      => a.schema_uniqueItems 
            ,p_schema_minProperties    => a.schema_minProperties
            ,p_schema_maxProperties    => a.schema_maxProperties
            ,p_xml_name                => a.xml_name
            ,p_xml_namespace           => a.xml_namespace
            ,p_xml_prefix              => a.xml_prefix
            ,p_xml_attribute           => a.xml_attribute
            ,p_xml_wrapped             => a.xml_wrapped
          )
         ,a.schema_items_schema_id
         INTO
          SELF
         ,str_items_schema_id
         FROM
         dz_swagger3_schema a
         WHERE
             a.versionid = p_versionid
         AND a.schema_id = p_schema_id;
      
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
      -- Add hash key and required flag
      --------------------------------------------------------------------------
      self.hash_key        := p_hash_key;
      self.schema_required := p_required;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Process object definitions for remaining schema types
      --------------------------------------------------------------------------
      IF self.schema_type = 'object'
      THEN
         self.addProperties(
            p_versionid  => p_versionid
         );
      
      ELSIF self.schema_type = 'array'
      AND str_items_schema_id IS NOT NULL
      THEN
         self.addItemsSchema(
             p_items_schema_id => str_items_schema_id
            ,p_versionid       => p_versionid
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Return completed object
      --------------------------------------------------------------------------
      RETURN;
      
   END dz_swagger3_schema_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
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
      -----
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

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
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
      ,p_schema_items_schema     IN  dz_swagger3_schema_typ_nf
      ,p_schema_properties       IN  dz_swagger3_schema_nf_list
      ,p_schema_scalar           IN  VARCHAR2
      ,p_combine_schemas         IN  dz_swagger3_schema_nf_list
      ,p_not_schema              IN  dz_swagger3_schema_typ_nf
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
      self.schema_items_schema     := p_schema_items_schema;
      self.schema_properties       := p_schema_properties;
      self.schema_scalar           := p_schema_scalar;
      self.combine_schemas         := p_combine_schemas;
      self.not_schema              := p_not_schema;
      
      RETURN; 
      
   END dz_swagger3_schema_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE addItemsSchema(
       SELF               IN  OUT NOCOPY dz_swagger3_schema_typ
      ,p_items_schema_id  IN  VARCHAR2
      ,p_versionid        IN  VARCHAR2
   )
   AS
   BEGIN
      
      self.schema_items_schema := dz_swagger3_schema_typ(
          p_hash_key        => NULL
         ,p_schema_id       => p_items_schema_id
         ,p_required        => NULL
         ,p_versionid       => p_versionid 
      );
   
   END addItemsSchema;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE addProperties(
       SELF         IN  OUT NOCOPY dz_swagger3_schema_typ
      ,p_versionid  IN  VARCHAR2
   )
   AS
   BEGIN
      
      SELECT
      dz_swagger3_schema_typ(
          p_hash_key        => a.property_name
         ,p_schema_id       => a.property_schema_id 
         ,p_required        => a.property_required
         ,p_versionid       => p_versionid 
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
      AND a.parent_schema_id = self.schema_id
      ORDER BY
      a.property_order;      
   
   END addProperties;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE prune(
       SELF                  IN  OUT NOCOPY dz_swagger3_schema_typ
   )
   AS
   BEGIN
      
      IF self.schema_items_schema IS NOT NULL
      AND self.schema_items_schema.doRef() = 'TRUE'
      THEN
         NULL; --self.schema_items_schema := NULL;

      END IF;
      
      IF self.not_schema IS NOT NULL
      AND self.not_schema.doRef() = 'TRUE'
      THEN
         NULL; --self.not_schema := NULL;

      END IF;
      
   END prune;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   OVERRIDING MEMBER FUNCTION isNULL
   RETURN VARCHAR2
   AS
   BEGIN
      IF self.schema_id IS NOT NULL
      OR self.schema_type IS NOT NULL
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
      RETURN self.schema_id;
      
   END key;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   OVERRIDING MEMBER FUNCTION doRef
   RETURN VARCHAR2
   AS
   BEGIN
   
      IF self.schema_type = 'object'
      THEN
         RETURN 'TRUE';
         
      ELSE
         RETURN 'FALSE';
      
      END IF;
      
   END doRef;
   
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
      -- Pull the schemas from the properties
      --------------------------------------------------------------------------
      IF self.schema_properties IS NOT NULL
      AND self.schema_properties.COUNT > 0
      THEN
         FOR i IN 1 .. self.schema_properties.COUNT
         LOOP
            ary_working := TREAT(
               self.schema_properties(i) AS dz_swagger3_schema_typ
            ).unique_schemas();

            FOR j IN 1 .. ary_working.COUNT
            LOOP
               obj_schema := TREAT(ary_working(j) AS dz_swagger3_schema_typ);
               
               IF obj_schema.doRef() = 'TRUE'
               THEN
                  IF dz_swagger3_util.a_in_b(
                      obj_schema.schema_id
                     ,ary_x
                  ) = 'FALSE'
                  THEN
                     ary_results.EXTEND();
                     obj_schema.prune();
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
                        ,p_schema_scalar           => obj_schema.schema_scalar
                        ,p_combine_schemas         => obj_schema.combine_schemas
                        ,p_not_schema              => obj_schema.not_schema
                     );

                     int_results := int_results + 1;
                     
                     ary_x.EXTEND();
                     ary_x(int_x) := ary_working(j).schema_id;
                     int_x := int_x + 1;

                  END IF;
                  
               END IF;
               
            END LOOP;
               
            IF self.schema_properties(i).doRef() = 'TRUE'
            THEN
               IF dz_swagger3_util.a_in_b(
                   self.schema_properties(i).schema_id
                  ,ary_x
               ) = 'FALSE'
               THEN
                  ary_results.EXTEND();
                  obj_schema := TREAT(self.schema_properties(i) AS dz_swagger3_schema_typ);
                  obj_schema.prune();
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
                     ,p_schema_scalar           => obj_schema.schema_scalar
                     ,p_combine_schemas         => obj_schema.combine_schemas
                     ,p_not_schema              => obj_schema.not_schema
                  );
                  int_results := int_results + 1;
                  
                  ary_x.EXTEND();
                  ary_x(int_x) := self.schema_properties(i).schema_id;
                  int_x := int_x + 1;

               END IF;
               
            END IF;
            
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Pull the schema from the items
      --------------------------------------------------------------------------
      IF self.schema_items_schema IS NOT NULL
      AND self.schema_items_schema.isNULL() = 'FALSE'
      THEN
         ary_working := TREAT(
            self.schema_items_schema AS dz_swagger3_schema_typ
         ).unique_schemas();

         FOR j IN 1 .. ary_working.COUNT
         LOOP
            obj_schema := TREAT(ary_working(j) AS dz_swagger3_schema_typ);
            
            IF obj_schema.doRef() = 'TRUE'
            THEN            
               IF dz_swagger3_util.a_in_b(
                   obj_schema.schema_id
                  ,ary_x
               ) = 'FALSE'
               THEN
                  ary_results.EXTEND();
                  obj_schema.prune();
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
                     ,p_schema_scalar           => obj_schema.schema_scalar
                     ,p_combine_schemas         => obj_schema.combine_schemas
                     ,p_not_schema              => obj_schema.not_schema
                  );
                  int_results := int_results + 1;
                  
                  ary_x.EXTEND();
                  ary_x(int_x) := ary_working(j).schema_id;
                  int_x := int_x + 1;

               END IF;
               
            END IF;
      
         END LOOP;
         
         IF self.schema_items_schema.doRef() = 'TRUE'
         THEN
            IF dz_swagger3_util.a_in_b(
                self.schema_items_schema.schema_id
               ,ary_x
            ) = 'FALSE'
            THEN
               ary_results.EXTEND();
               obj_schema := TREAT(self.schema_items_schema AS dz_swagger3_schema_typ);
               obj_schema.prune();
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
                  ,p_schema_scalar           => obj_schema.schema_scalar
                  ,p_combine_schemas         => obj_schema.combine_schemas
                  ,p_not_schema              => obj_schema.not_schema
               );
               int_results := int_results + 1;
               
               ary_x.EXTEND();
               ary_x(int_x) := self.schema_items_schema.schema_id;
               int_x := int_x + 1;

            END IF;
            
         END IF;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Pull the schemas from the combines
      --------------------------------------------------------------------------
      IF self.combine_schemas IS NOT NULL
      AND self.combine_schemas.COUNT > 0
      THEN
         FOR i IN 1 .. self.combine_schemas.COUNT
         LOOP
            IF self.combine_schemas(i).doRef() = 'TRUE'
            THEN
               IF dz_swagger3_util.a_in_b(
                   self.combine_schemas(i).schema_id
                  ,ary_x
               ) = 'FALSE'
               THEN
                  ary_results.EXTEND();
                  obj_schema := TREAT(self.combine_schemas(i) AS dz_swagger3_schema_typ);
                  obj_schema.prune();
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
                     ,p_schema_scalar           => obj_schema.schema_scalar
                     ,p_combine_schemas         => obj_schema.combine_schemas
                     ,p_not_schema              => obj_schema.not_schema
                  );
                  int_results := int_results + 1;
                  
                  ary_x.EXTEND();
                  ary_x(int_x) := self.combine_schemas(i).schema_id;
                  int_x := int_x + 1;
                  
               END IF;
               
            END IF;
            
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Pull the schema from the items
      --------------------------------------------------------------------------
      IF self.not_schema IS NOT NULL
      AND self.not_schema.isNULL() = 'FALSE'
      THEN
         ary_working := TREAT(
            self.not_schema AS dz_swagger3_schema_typ
         ).unique_schemas();

         FOR j IN 1 .. ary_working.COUNT
         LOOP
            obj_schema := TREAT(ary_working(j) AS dz_swagger3_schema_typ);
            
            IF obj_schema.doRef() = 'TRUE'
            THEN
               IF dz_swagger3_util.a_in_b(
                   obj_schema.schema_id
                  ,ary_x
               ) = 'FALSE'
               THEN
                  ary_results.EXTEND();
                  obj_schema.prune();
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
                     ,p_schema_scalar           => obj_schema.schema_scalar
                     ,p_combine_schemas         => obj_schema.combine_schemas
                     ,p_not_schema              => obj_schema.not_schema
                  );
                  int_results := int_results + 1;
                  
                  ary_x.EXTEND();
                  ary_x(int_x) := ary_working(j).schema_id;
                  int_x := int_x + 1;

               END IF;
               
            END IF;
      
         END LOOP;      

         IF self.not_schema.doRef() = 'TRUE'
         THEN
            IF dz_swagger3_util.a_in_b(
                self.not_schema.schema_id
               ,ary_x
            ) = 'FALSE'
            THEN
               ary_results.EXTEND();
               obj_schema := TREAT(self.not_schema AS dz_swagger3_schema_typ);
               obj_schema.prune();
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
                  ,p_schema_scalar           => obj_schema.schema_scalar
                  ,p_combine_schemas         => obj_schema.combine_schemas
                  ,p_not_schema              => obj_schema.not_schema
               );
               
               ary_x.EXTEND();
               ary_x(int_x) := self.not_schema.schema_id;
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
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   MEMBER FUNCTION schema_properties_keys
   RETURN MDSYS.SDO_STRING2_ARRAY
   AS
      int_index  PLS_INTEGER;
      ary_output MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
      IF self.schema_properties IS NULL
      OR self.schema_properties.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := MDSYS.SDO_STRING2_ARRAY();
      FOR i IN 1 .. self.schema_properties.COUNT
      LOOP
         ary_output.EXTEND();
         ary_output(int_index) := self.schema_properties(i).hash_key;
         int_index := int_index + 1;
      
      END LOOP;
      
      RETURN ary_output;
   
   END schema_properties_keys;
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   OVERRIDING MEMBER FUNCTION toJSON(
       p_pretty_print      IN  INTEGER  DEFAULT NULL
      ,p_jsonschema        IN  VARCHAR2 DEFAULT 'FALSE' 
   ) RETURN CLOB
   AS
   BEGIN
   
      IF self.hash_key IN ('anyOf','allOf','oneOf')
      THEN
         RETURN self.toJSON_combine(
             p_pretty_print   => p_pretty_print
            ,p_jsonschema     => p_jsonschema
         );
         
      ELSIF self.hash_key = 'not'
      THEN
         RETURN self.toJSON_not(
             p_pretty_print   => p_pretty_print
            ,p_jsonschema     => p_jsonschema
         );
         
      ELSE
         IF self.doRef() = 'TRUE'
         THEN
            RETURN self.toJSON_ref(
                p_pretty_print   => p_pretty_print
               ,p_jsonschema     => p_jsonschema
            );

         ELSE
            RETURN self.toJSON_schema(
                p_pretty_print   => p_pretty_print
               ,p_jsonschema     => p_jsonschema
            );
            
         END IF;
         
      END IF;
      
   END toJSON;
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   OVERRIDING MEMBER FUNCTION toJSON_schema(
       p_pretty_print      IN  INTEGER  DEFAULT NULL
      ,p_jsonschema        IN  VARCHAR2 DEFAULT 'FALSE' 
   ) RETURN CLOB
   AS
      str_jsonschema   VARCHAR2(4000 Char) := UPPER(p_jsonschema);
      clb_output       CLOB;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_hash         CLOB;
      int_counter      PLS_INTEGER;
      ary_required     MDSYS.SDO_STRING2_ARRAY;
      boo_temp         BOOLEAN;
      
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
         str_pad  := '';
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad  := ' ';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add base attributes
      --------------------------------------------------------------------------
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
      
      --------------------------------------------------------------------------
      -- Step 40
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
      -- Step 50
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
      -- Step 60
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
      -- Step 70
      -- Add optional description object
      --------------------------------------------------------------------------
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
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Add optional description object
      --------------------------------------------------------------------------
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
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Add optional description object
      --------------------------------------------------------------------------
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
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Add optional description object
      --------------------------------------------------------------------------
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
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Add optional externalDocs
      --------------------------------------------------------------------------
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
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Add optional description object
      --------------------------------------------------------------------------
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
      
      --------------------------------------------------------------------------
      -- Step 130
      -- Add optional description object
      --------------------------------------------------------------------------
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
      
      --------------------------------------------------------------------------
      -- Step 140
      -- Add schema items
      --------------------------------------------------------------------------
      IF  self.schema_items_schema IS NOT NULL
      AND self.schema_items_schema.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'items'
               ,self.schema_items_schema.toJSON(p_pretty_print + 1)
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 150
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
      -- Step 160
      -- Add parameters
      -------------------------------------------------------------------------
      IF self.schema_properties IS NULL 
      OR self.schema_properties.COUNT = 0
      THEN
         NULL;
         
      ELSE
         str_pad2 := str_pad;
         ary_required := MDSYS.SDO_STRING2_ARRAY();
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('{',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('{',-1);
            
         END IF;
      
      
         ary_keys := self.schema_properties_keys();
      
         int_counter := 1;
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || ary_keys(i) || '":' || str_pad || self.schema_properties(i).toJSON(
                  p_pretty_print => p_pretty_print + 2
                )
               ,p_pretty_print + 2
            );
            str_pad2 := ',';
            
            IF self.schema_properties(i).schema_required = 'TRUE'
            THEN
               ary_required.EXTEND();
               ary_required(int_counter) := self.schema_properties(i).hash_key;
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
      -- Step 170
      -- Add required array
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

      --------------------------------------------------------------------------
      -- Step 180
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 190
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON_schema;
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   OVERRIDING MEMBER FUNCTION toJSON_ref(
       p_pretty_print      IN  INTEGER  DEFAULT NULL
      ,p_jsonschema        IN  VARCHAR2 DEFAULT 'FALSE' 
   ) RETURN CLOB
   AS
      str_jsonschema   VARCHAR2(4000 Char) := UPPER(p_jsonschema);
      clb_output       CLOB;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      
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
         str_pad  := '';
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad  := ' ';
         
      END IF;
      
      str_pad1 := str_pad;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add base attributes
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.value2json(
             '$ref'
            ,'#/components/schemas/' || self.schema_id
            ,p_pretty_print + 1
         )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';
      
      --------------------------------------------------------------------------
      -- Step 180
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 190
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON_ref;
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   OVERRIDING MEMBER FUNCTION toJSON_combine(
       p_pretty_print      IN  INTEGER  DEFAULT NULL
      ,p_jsonschema        IN  VARCHAR2 DEFAULT 'FALSE' 
   ) RETURN CLOB
   AS
      str_jsonschema   VARCHAR2(4000 Char) := UPPER(p_jsonschema);
      clb_output       CLOB;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_hash         CLOB;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         str_pad  := '';
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad  := ' ';
         
      END IF;
      
      str_pad1 := str_pad;
      
      --------------------------------------------------------------------------
      -- Step 20
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
      -- Step 40
      -- Add the left bracket
      --------------------------------------------------------------------------
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
             str_pad2 || self.combine_schemas(i).toJSON(
               p_pretty_print => p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad2 := ',';
      
      END LOOP;
      
      clb_hash := clb_hash || dz_json_util.pretty(
          ']'
         ,p_pretty_print + 1,NULL,NULL
      );
      
      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.formatted2json(
              self.hash_key
             ,clb_hash
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
      
   END toJSON_combine;
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   OVERRIDING MEMBER FUNCTION toJSON_not(
       p_pretty_print      IN  INTEGER  DEFAULT NULL
      ,p_jsonschema        IN  VARCHAR2 DEFAULT 'FALSE' 
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         str_pad  := '';
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad  := ' ';
         
      END IF;
      
      str_pad1 := str_pad;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Add not schema item
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
      -- Step 20
      -- Add not schema item
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          str_pad || dz_json_main.formatted2json(
             'not'
            ,self.not_schema.toJSON(p_pretty_print + 1)
            ,p_pretty_print + 1
         )
         ,p_pretty_print + 1
      );
      str_pad := ',';
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
      
   END toJSON_not;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   OVERRIDING MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
   ) RETURN CLOB
   AS
   BEGIN
      IF self.hash_key IN ('anyOf','allOf','oneOf')
      THEN
         RETURN self.toYAML_combine(
             p_pretty_print    => p_pretty_print
            ,p_initial_indent  => p_initial_indent
            ,p_final_linefeed  => p_final_linefeed
         );
         
         
      ELSIF self.hash_key = 'not'
      THEN
         RETURN self.toYAML_not(
             p_pretty_print    => p_pretty_print
            ,p_initial_indent  => p_initial_indent
            ,p_final_linefeed  => p_final_linefeed
         );
         
         
      ELSE
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
         
      END IF;
      
   END toYAML;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   OVERRIDING MEMBER FUNCTION toYAML_schema(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
   ) RETURN CLOB
   AS
      clb_output       CLOB := '';
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      ary_required     MDSYS.SDO_STRING2_ARRAY;
      int_counter      PLS_INTEGER;
      boo_check        BOOLEAN;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Do the type element
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty_str(
          'type: ' || self.schema_type
         ,p_pretty_print
         ,'  '
      );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional title object
      --------------------------------------------------------------------------
      IF self.schema_title IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'title: ' || self.schema_title
            ,p_pretty_print
            ,'  '
         );
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional description object
      --------------------------------------------------------------------------
      IF self.schema_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'description: ' || dz_swagger_util.yaml_text(
                self.schema_description
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional description object
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
      -- Step 60
      -- Add optional description object
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
      -- Step 70
      -- Add optional description object
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
      -- Step 80
      -- Add optional description object
      --------------------------------------------------------------------------
      IF self.schema_readonly IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'readonly: ' || LOWER(self.schema_readonly)
            ,p_pretty_print
            ,'  '
         );
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Add optional description object
      --------------------------------------------------------------------------
      IF self.schema_writeonly IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'writeonly: ' || LOWER(self.schema_writeonly)
            ,p_pretty_print
            ,'  '
         );
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Write the optional externalDocs object
      --------------------------------------------------------------------------
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
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Add optional description object
      --------------------------------------------------------------------------
      IF self.schema_example_string IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'example: ' || self.schema_example_string
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
      -- Step 120
      -- Add optional description object
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
      -- Step 130
      -- Write the optional externalDocs object
      --------------------------------------------------------------------------
      IF  self.schema_items_schema IS NOT NULL
      AND self.schema_items_schema.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'items: ' 
            ,p_pretty_print
            ,'  '
         ) || self.schema_items_schema.toYAML(
            p_pretty_print + 1
         );
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 140
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
      -- Step 150
      -- Write the properties map
      -------------------------------------------------------------------------
      IF  self.schema_properties IS NOT NULL 
      AND self.schema_properties.COUNT > 0
      THEN
         boo_check    := FALSE;
         int_counter  := 1;
         ary_required := MDSYS.SDO_STRING2_ARRAY();
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'properties: '
            ,p_pretty_print
            ,'  '
         );
         
         ary_keys := self.schema_properties_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '''' || ary_keys(i) || ''': '
               ,p_pretty_print + 1
               ,'  '
            ) || self.schema_properties(i).toYAML(
               p_pretty_print + 2
            );
            
            IF self.schema_properties(i).schema_required = 'TRUE'
            THEN
               ary_required.EXTEND();
               ary_required(int_counter) := self.schema_properties(i).hash_key;
               int_counter := int_counter + 1;
               boo_check   := TRUE;

            END IF;
         
         END LOOP;
         
      --------------------------------------------------------------------------
      -- Step 160
      -- Add requirements array
      --------------------------------------------------------------------------
         IF boo_check
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'required: '
               ,p_pretty_print
               ,'  '
            );
            
            FOR i IN 1 .. ary_required.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty_str(
                   '- ' || ary_required(i)
                  ,p_pretty_print + 1
                  ,'  '
               );
               
            END LOOP;
            
         END IF;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 170
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
      
   END toYAML_schema;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   OVERRIDING MEMBER FUNCTION toYAML_ref(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
   ) RETURN CLOB
   AS
      clb_output       CLOB := '';
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Do the type element
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty_str(
          '$ref: ' || dz_swagger3_util.yaml_text(
             '#/components/schemas/' || self.schema_id
            ,p_pretty_print
         )
         ,p_pretty_print
         ,'  '
      );

      --------------------------------------------------------------------------
      -- Step 30
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
      
   END toYAML_ref;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   OVERRIDING MEMBER FUNCTION toYAML_combine(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
   ) RETURN CLOB
   AS
   BEGIN
      RETURN NULL;
      
   END toYAML_combine;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   OVERRIDING MEMBER FUNCTION toYAML_not(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
   ) RETURN CLOB
   AS
   BEGIN
      RETURN NULL;
      
   END toYAML_not;
   
END;
/

