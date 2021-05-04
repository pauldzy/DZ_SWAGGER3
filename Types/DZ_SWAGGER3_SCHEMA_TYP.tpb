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
      --dbms_output.put_line('schema: ' || p_schema_id);
      self.versionid := p_versionid;

      --------------------------------------------------------------------------
      -- Step 20
      -- Load the easy items using constructor
      --------------------------------------------------------------------------
      BEGIN
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
         
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RAISE_APPLICATION_ERROR(
                -20001
               ,'Model missing schema record for schema_id ' || p_schema_id || ' in version ' || p_versionid
            );
         
         WHEN OTHERS
         THEN
            RAISE;
            
      END;

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
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
      ,p_jsonschema          IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_xorder              IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      str_jsonschema                 VARCHAR2(4000 Char) := UPPER(p_jsonschema);
      clb_output                     CLOB;
      clb_combine_schemas            CLOB;
      int_combine_schemas            PLS_INTEGER;
      clb_schema_externalDocs        CLOB;
      clb_schema_items_schema        CLOB;
      clb_schema_properties          CLOB;
      clb_schema_prop_required       CLOB;
      clb_xml                        CLOB;
      str_object_key                 VARCHAR2(255 Char);
      str_identifier                 VARCHAR2(255 Char);
      int_schema_enum_string         PLS_INTEGER;
      int_schema_enum_number         PLS_INTEGER;
      boo_is_not                     BOOLEAN;
      int_inject_property_xorder     INTEGER;
      
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
      -- Branch if needed for combines
      --------------------------------------------------------------------------
      IF  self.combine_schemas IS NOT NULL
      AND self.combine_schemas.COUNT > 0
      THEN
         boo_is_not := FALSE;
         
         SELECT
          a.cnt
         ,a.object_key
         INTO
          int_combine_schemas
         ,str_object_key 
         FROM (
            SELECT
             ROW_NUMBER() OVER(ORDER BY bb.object_order) AS rown
            ,COUNT(*)     OVER(ORDER BY bb.object_order) AS cnt
            ,bb.object_key
            FROM
            dz_swagger3_xobjects aa
            JOIN
            TABLE(self.combine_schemas) bb
            ON
                aa.object_type_id = bb.object_type_id
            AND aa.object_id      = bb.object_id
         ) a
         WHERE
         a.rown = 1; 
          
         IF int_combine_schemas = 1 AND str_object_key = 'not'
         THEN
            boo_is_not := TRUE;
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- branch for the NOT scenario
      --------------------------------------------------------------------------
         IF boo_is_not
         THEN
            SELECT
            a.schematyp.toJSON(
                p_force_inline     => p_force_inline
               ,p_short_id         => p_short_id
               ,p_identifier       => a.object_id
               ,p_short_identifier => a.short_id
               ,p_reference_count  => a.reference_count
               ,p_jsonschema       => str_jsonschema
            )
            INTO clb_combine_schemas
            FROM
            dz_swagger3_xobjects a
            JOIN
            TABLE(self.combine_schemas) b
            ON
                a.object_type_id = b.object_type_id
            AND a.object_id      = b.object_id; 
         
            SELECT
            JSON_OBJECT(
                'type'         VALUE self.schema_type
               ,'not'          VALUE clb_combine_schemas FORMAT JSON 
               ABSENT ON NULL
               RETURNING CLOB
            )
            INTO clb_output
            FROM dual;
         
         ELSE
            SELECT
            JSON_ARRAYAGG(
               a.schematyp.toJSON(
                   p_force_inline     => p_force_inline
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_reference_count  => a.reference_count
                  ,p_jsonschema       => str_jsonschema
               ) FORMAT JSON
               ORDER BY b.object_order
               RETURNING CLOB
            )
            INTO clb_combine_schemas
            FROM
            dz_swagger3_xobjects a
            JOIN
            TABLE(self.combine_schemas) b
            ON
                a.object_type_id = b.object_type_id
            AND a.object_id      = b.object_id; 
            
            SELECT
            JSON_OBJECT(
                'type'         VALUE self.schema_type
               ,str_object_key VALUE clb_combine_schemas FORMAT JSON 
               ABSENT ON NULL
               RETURNING CLOB
            )
            INTO clb_output
            FROM dual;
   
         END IF;
      
      ELSE
      --------------------------------------------------------------------------
      -- Step 40
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
            
            SELECT
            JSON_OBJECT(
               '$ref' VALUE '#/components/schemas/' || str_identifier
            )
            INTO clb_output
            FROM dual;
            
         ELSE
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional externalDocs
      --------------------------------------------------------------------------
            IF  self.schema_externalDocs IS NOT NULL
            AND str_jsonschema <> 'TRUE'
            THEN
               BEGIN
                  SELECT
                  a.extrdocstyp.toJSON()
                  INTO clb_schema_externalDocs
                  FROM
                  dz_swagger3_xobjects a
                  WHERE
                      a.object_type_id = self.schema_externalDocs.object_type_id 
                  AND a.object_id      = self.schema_externalDocs.object_id;
               
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     clb_schema_externalDocs := NULL;
                     
                  WHEN OTHERS
                  THEN
                     RAISE;
                     
               END;

            END IF;
            
      --------------------------------------------------------------------------
      -- Step 60
      -- Add schema items
      --------------------------------------------------------------------------
            IF self.schema_items_schema IS NOT NULL
            THEN
               BEGIN
                  SELECT
                  a.schematyp.toJSON(
                      p_force_inline     => p_force_inline
                     ,p_short_id         => p_short_id
                     ,p_identifier       => a.object_id
                     ,p_short_identifier => a.short_id
                     ,p_reference_count  => a.reference_count
                     ,p_jsonschema       => str_jsonschema
                  )
                  INTO clb_schema_items_schema
                  FROM
                  dz_swagger3_xobjects a
                  WHERE
                      a.object_type_id = self.schema_items_schema.object_type_id
                  AND a.object_id      = self.schema_items_schema.object_id;
               
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     clb_schema_items_schema := NULL;
                     
                  WHEN OTHERS
                  THEN
                     RAISE;
                     
               END;

            END IF;
            
      --------------------------------------------------------------------------
      -- Step 70
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
                  clb_xml := dz_swagger3_xml_typ(
                      p_xml_name       => self.xml_name
                     ,p_xml_namespace  => self.xml_namespace
                     ,p_xml_prefix     => self.xml_prefix
                     ,p_xml_attribute  => self.xml_attribute
                     ,p_xml_wrapped    => self.xml_wrapped
                  ).toJSON();
                  
               END IF;
               
            END IF;
            
      -------------------------------------------------------------------------
      -- Step 80
      -- Add parameters
      -------------------------------------------------------------------------
            IF  self.schema_properties IS NOT NULL 
            AND self.schema_properties.COUNT > 0
            THEN
               SELECT
               JSON_OBJECTAGG(
                  b.object_key VALUE a.schematyp.toJSON(
                      p_force_inline     => p_force_inline
                     ,p_short_id         => p_short_id
                     ,p_identifier       => a.object_id
                     ,p_short_identifier => a.short_id
                     ,p_reference_count  => a.reference_count
                     ,p_jsonschema       => str_jsonschema
                     ,p_xorder           => b.object_order
                  ) FORMAT JSON
                  RETURNING CLOB
               )
               INTO clb_schema_properties
               FROM
               dz_swagger3_xobjects a
               JOIN
               TABLE(self.schema_properties) b
               ON
                   a.object_type_id = b.object_type_id
               AND a.object_id      = b.object_id
               WHERE
               COALESCE(a.schematyp.property_list_hidden,'FALSE') <> 'TRUE'; 
               
               SELECT
               JSON_ARRAYAGG(
                  b.object_key
                  ORDER BY b.object_order
                  RETURNING CLOB
               )
               INTO clb_schema_prop_required
               FROM
               dz_swagger3_xobjects a
               JOIN
               TABLE(self.schema_properties) b
               ON
                   a.object_type_id = b.object_type_id
               AND a.object_id      = b.object_id
               WHERE
               COALESCE(a.schematyp.property_list_hidden,'FALSE') <> 'TRUE'
               AND b.object_required = 'TRUE'; 

            END IF;
       
      --------------------------------------------------------------------------
      -- Step 90
      -- Create the object
      --------------------------------------------------------------------------
            IF self.schema_enum_string IS NOT NULL
            THEN
               int_schema_enum_string := self.schema_enum_string.COUNT;
            
            ELSE
               int_schema_enum_string := 0;
               
            END IF;
            
            IF self.schema_enum_number IS NOT NULL
            THEN
               int_schema_enum_number := self.schema_enum_number.COUNT;
               
            ELSE
               int_schema_enum_number := 0;

            END IF;
            
            IF dz_swagger3_constants.c_inject_property_xorder
            THEN
               int_inject_property_xorder := 1;
               
            END IF;

            IF  self.schema_example_string IS NOT NULL
            AND str_jsonschema <> 'TRUE'
            THEN
               IF  str_jsonschema = 'TRUE'
               AND self.schema_nullable = 'TRUE'
               THEN
                  SELECT
                  JSON_OBJECT(
                      '$schema'       VALUE CASE
                        WHEN LOWER(self.inject_jsonschema) = 'true'
                        THEN
                           'http://json-schema.org/draft-04/schema#'
                        ELSE
                           NULL
                        END
                     ,'type'          VALUE JSON_ARRAY(self.schema_type,'null') FORMAT JSON
                     ,'title'         VALUE self.schema_title
                     ,'description'   VALUE self.schema_description
                     ,'format'        VALUE self.schema_format
                     ,'enum'          VALUE CASE
                        WHEN int_schema_enum_string > 0
                        THEN
                           (SELECT JSON_ARRAYAGG(column_value) FROM TABLE(self.schema_enum_string))
                        WHEN int_schema_enum_number > 0
                        THEN
                           (SELECT JSON_ARRAYAGG(column_value) FROM TABLE(self.schema_enum_number))
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'nullable'      VALUE CASE
                        WHEN self.schema_nullable IS NOT NULL
                        AND str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_nullable) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_nullable) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'discriminator' VALUE CASE
                        WHEN self.schema_discriminator IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           self.schema_discriminator
                        ELSE
                           NULL
                        END
                     ,'readOnly'      VALUE CASE
                        WHEN self.schema_readOnly IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_readOnly) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_readOnly) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'writeOnly'     VALUE CASE
                        WHEN self.schema_writeOnly IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_writeOnly) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_writeOnly) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'maxItems'      VALUE self.schema_maxItems
                     ,'minItems'      VALUE self.schema_minItems
                     ,'maxProperties' VALUE self.schema_maxProperties
                     ,'minProperties' VALUE self.schema_minProperties
                     ,'externalDocs'  VALUE clb_schema_externalDocs   FORMAT JSON
                     ,'example'       VALUE self.schema_example_string
                     ,'deprecated'    VALUE CASE
                        WHEN LOWER(self.schema_deprecated) = 'true'
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           'true'
                        WHEN LOWER(self.schema_deprecated) = 'false'
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           'false'
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'items'         VALUE clb_schema_items_schema   FORMAT JSON
                     ,'xml'           VALUE clb_xml                   FORMAT JSON
                     ,'properties'    VALUE clb_schema_properties     FORMAT JSON
                     ,'required'      VALUE clb_schema_prop_required  FORMAT JSON
                     ,'x-order'       VALUE CASE
                      WHEN int_inject_property_xorder = 1
                      THEN
                        p_xorder
                      ELSE
                        NULL
                      END
                     ABSENT ON NULL
                     RETURNING CLOB
                  )
                  INTO clb_output
                  FROM dual;
                  
               ELSE
                  SELECT
                  JSON_OBJECT(
                      '$schema'       VALUE CASE
                        WHEN LOWER(self.inject_jsonschema) = 'true'
                        THEN
                           'http://json-schema.org/draft-04/schema#'
                        ELSE
                           NULL
                        END
                     ,'type'          VALUE self.schema_type
                     ,'title'         VALUE self.schema_title
                     ,'description'   VALUE self.schema_description
                     ,'format'        VALUE self.schema_format
                     ,'enum'          VALUE CASE
                        WHEN int_schema_enum_string > 0
                        THEN
                           (SELECT JSON_ARRAYAGG(column_value) FROM TABLE(self.schema_enum_string))
                        WHEN int_schema_enum_number > 0
                        THEN
                           (SELECT JSON_ARRAYAGG(column_value) FROM TABLE(self.schema_enum_number))
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'nullable'      VALUE CASE
                        WHEN self.schema_nullable IS NOT NULL
                        AND str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_nullable) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_nullable) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'discriminator' VALUE CASE
                        WHEN self.schema_discriminator IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           self.schema_discriminator
                        ELSE
                           NULL
                        END
                     ,'readOnly'      VALUE CASE
                        WHEN self.schema_readOnly IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_readOnly) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_readOnly) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'writeOnly'     VALUE CASE
                        WHEN self.schema_writeOnly IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_writeOnly) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_writeOnly) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'maxItems'      VALUE self.schema_maxItems
                     ,'minItems'      VALUE self.schema_minItems
                     ,'maxProperties' VALUE self.schema_maxProperties
                     ,'minProperties' VALUE self.schema_minProperties
                     ,'externalDocs'  VALUE clb_schema_externalDocs   FORMAT JSON
                     ,'example'       VALUE self.schema_example_string
                     ,'deprecated'    VALUE CASE
                        WHEN LOWER(self.schema_deprecated) = 'true'
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           'true'
                        WHEN LOWER(self.schema_deprecated) = 'false'
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           'false'
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'items'         VALUE clb_schema_items_schema   FORMAT JSON
                     ,'xml'           VALUE clb_xml                   FORMAT JSON
                     ,'properties'    VALUE clb_schema_properties     FORMAT JSON
                     ,'required'      VALUE clb_schema_prop_required  FORMAT JSON
                     ,'x-order'       VALUE CASE
                      WHEN int_inject_property_xorder = 1
                      THEN
                        p_xorder
                      ELSE
                        NULL
                      END
                     ABSENT ON NULL
                     RETURNING CLOB
                  )
                  INTO clb_output
                  FROM dual;
               
               END IF;
               
            ELSIF self.schema_example_number IS NOT NULL
            AND   str_jsonschema <> 'TRUE'
            THEN
            
               IF  str_jsonschema = 'TRUE'
               AND self.schema_nullable = 'TRUE'
               THEN
                  SELECT
                  JSON_OBJECT(
                      '$schema'       VALUE CASE
                        WHEN LOWER(self.inject_jsonschema) = 'true'
                        THEN
                           'http://json-schema.org/draft-04/schema#'
                        ELSE
                           NULL
                        END
                     ,'type'          VALUE JSON_ARRAY(self.schema_type,'null') FORMAT JSON
                     ,'title'         VALUE self.schema_title
                     ,'description'   VALUE self.schema_description
                     ,'format'        VALUE self.schema_format
                     ,'enum'          VALUE CASE
                        WHEN int_schema_enum_string > 0
                        THEN
                           (SELECT JSON_ARRAYAGG(column_value) FROM TABLE(self.schema_enum_string))
                        WHEN int_schema_enum_number > 0
                        THEN
                           (SELECT JSON_ARRAYAGG(column_value) FROM TABLE(self.schema_enum_number))
                        ELSE
                           NULL
                        END
                     ,'nullable'      VALUE CASE
                        WHEN self.schema_nullable IS NOT NULL
                        AND str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_nullable) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_nullable) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'discriminator' VALUE CASE
                        WHEN self.schema_discriminator IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           self.schema_discriminator
                        ELSE
                           NULL
                        END
                     ,'readOnly'      VALUE CASE
                        WHEN self.schema_readOnly IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_readOnly) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_readOnly) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'writeOnly'     VALUE CASE
                        WHEN self.schema_writeOnly IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_writeOnly) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_writeOnly) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'maxItems'      VALUE self.schema_maxItems
                     ,'minItems'      VALUE self.schema_minItems
                     ,'maxProperties' VALUE self.schema_maxProperties
                     ,'minProperties' VALUE self.schema_minProperties
                     ,'externalDocs'  VALUE clb_schema_externalDocs   FORMAT JSON
                     ,'example'       VALUE self.schema_example_number
                     ,'deprecated'    VALUE CASE
                        WHEN LOWER(self.schema_deprecated) = 'true'
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           'true'
                        WHEN LOWER(self.schema_deprecated) = 'false'
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           'false'
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'items'         VALUE clb_schema_items_schema   FORMAT JSON
                     ,'xml'           VALUE clb_xml                   FORMAT JSON
                     ,'properties'    VALUE clb_schema_properties     FORMAT JSON
                     ,'required'      VALUE clb_schema_prop_required  FORMAT JSON
                     ,'x-order'       VALUE CASE
                      WHEN int_inject_property_xorder = 1
                      THEN
                        p_xorder
                      ELSE
                        NULL
                      END
                     ABSENT ON NULL
                     RETURNING CLOB
                  )
                  INTO clb_output
                  FROM dual;
                  
               ELSE
                  SELECT
                  JSON_OBJECT(
                      '$schema'       VALUE CASE
                        WHEN LOWER(self.inject_jsonschema) = 'true'
                        THEN
                           'http://json-schema.org/draft-04/schema#'
                        ELSE
                           NULL
                        END
                     ,'type'          VALUE self.schema_type
                     ,'title'         VALUE self.schema_title
                     ,'description'   VALUE self.schema_description
                     ,'format'        VALUE self.schema_format
                     ,'enum'          VALUE CASE
                        WHEN int_schema_enum_string > 0
                        THEN
                           (SELECT JSON_ARRAYAGG(column_value) FROM TABLE(self.schema_enum_string))
                        WHEN int_schema_enum_number > 0
                        THEN
                           (SELECT JSON_ARRAYAGG(column_value) FROM TABLE(self.schema_enum_number))
                        ELSE
                           NULL
                        END
                     ,'nullable'      VALUE CASE
                        WHEN self.schema_nullable IS NOT NULL
                        AND str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_nullable) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_nullable) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'discriminator' VALUE CASE
                        WHEN self.schema_discriminator IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           self.schema_discriminator
                        ELSE
                           NULL
                        END
                     ,'readOnly'      VALUE CASE
                        WHEN self.schema_readOnly IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_readOnly) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_readOnly) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'writeOnly'     VALUE CASE
                        WHEN self.schema_writeOnly IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_writeOnly) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_writeOnly) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'maxItems'      VALUE self.schema_maxItems
                     ,'minItems'      VALUE self.schema_minItems
                     ,'maxProperties' VALUE self.schema_maxProperties
                     ,'minProperties' VALUE self.schema_minProperties
                     ,'externalDocs'  VALUE clb_schema_externalDocs   FORMAT JSON
                     ,'example'       VALUE self.schema_example_number
                     ,'deprecated'    VALUE CASE
                        WHEN LOWER(self.schema_deprecated) = 'true'
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           'true'
                        WHEN LOWER(self.schema_deprecated) = 'false'
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           'false'
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'items'         VALUE clb_schema_items_schema   FORMAT JSON
                     ,'xml'           VALUE clb_xml                   FORMAT JSON
                     ,'properties'    VALUE clb_schema_properties     FORMAT JSON
                     ,'required'      VALUE clb_schema_prop_required  FORMAT JSON
                     ,'x-order'       VALUE CASE
                      WHEN int_inject_property_xorder = 1
                      THEN
                        p_xorder
                      ELSE
                        NULL
                      END
                     ABSENT ON NULL
                     RETURNING CLOB
                  )
                  INTO clb_output
                  FROM dual;
               
               END IF;
               
            ELSE
               IF  str_jsonschema = 'TRUE'
               AND self.schema_nullable = 'TRUE'
               THEN
                  SELECT
                  JSON_OBJECT(
                      '$schema'       VALUE CASE
                        WHEN LOWER(self.inject_jsonschema) = 'true'
                        THEN
                           'http://json-schema.org/draft-04/schema#'
                        ELSE
                           NULL
                        END
                     ,'type'          VALUE JSON_ARRAY(self.schema_type,'null') FORMAT JSON
                     ,'title'         VALUE self.schema_title
                     ,'description'   VALUE self.schema_description
                     ,'format'        VALUE self.schema_format
                     ,'enum'          VALUE CASE
                        WHEN int_schema_enum_string > 0
                        THEN
                           (SELECT JSON_ARRAYAGG(column_value) FROM TABLE(self.schema_enum_string))
                        WHEN int_schema_enum_number > 0
                        THEN
                           (SELECT JSON_ARRAYAGG(column_value) FROM TABLE(self.schema_enum_number))
                        ELSE
                           NULL
                        END
                     ,'nullable'      VALUE CASE
                        WHEN self.schema_nullable IS NOT NULL
                        AND str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_nullable) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_nullable) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'discriminator' VALUE CASE
                        WHEN self.schema_discriminator IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           self.schema_discriminator
                        ELSE
                           NULL
                        END
                     ,'readOnly'      VALUE CASE
                        WHEN self.schema_readOnly IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_readOnly) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_readOnly) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'writeOnly'     VALUE CASE
                        WHEN self.schema_writeOnly IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_writeOnly) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_writeOnly) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'maxItems'      VALUE self.schema_maxItems
                     ,'minItems'      VALUE self.schema_minItems
                     ,'maxProperties' VALUE self.schema_maxProperties
                     ,'minProperties' VALUE self.schema_minProperties
                     ,'externalDocs'  VALUE clb_schema_externalDocs   FORMAT JSON
                     ,'deprecated'    VALUE CASE
                        WHEN LOWER(self.schema_deprecated) = 'true'
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           'true'
                        WHEN LOWER(self.schema_deprecated) = 'false'
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           'false'
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'items'         VALUE clb_schema_items_schema   FORMAT JSON
                     ,'xml'           VALUE clb_xml                   FORMAT JSON
                     ,'properties'    VALUE clb_schema_properties     FORMAT JSON
                     ,'required'      VALUE clb_schema_prop_required  FORMAT JSON
                     ,'x-order'       VALUE CASE
                      WHEN int_inject_property_xorder = 1
                      THEN
                        p_xorder
                      ELSE
                        NULL
                      END
                     ABSENT ON NULL
                     RETURNING CLOB
                  )
                  INTO clb_output
                  FROM dual;
            
               ELSE
                  SELECT
                  JSON_OBJECT(
                      '$schema'       VALUE CASE
                        WHEN LOWER(self.inject_jsonschema) = 'true'
                        THEN
                           'http://json-schema.org/draft-04/schema#'
                        ELSE
                           NULL
                        END
                     ,'type'          VALUE self.schema_type
                     ,'title'         VALUE self.schema_title
                     ,'description'   VALUE self.schema_description
                     ,'format'        VALUE self.schema_format
                     ,'enum'          VALUE CASE
                        WHEN int_schema_enum_string > 0
                        THEN
                           (SELECT JSON_ARRAYAGG(column_value) FROM TABLE(self.schema_enum_string))
                        WHEN int_schema_enum_number > 0
                        THEN
                           (SELECT JSON_ARRAYAGG(column_value) FROM TABLE(self.schema_enum_number))
                        ELSE
                           NULL
                        END
                     ,'nullable'      VALUE CASE
                        WHEN self.schema_nullable IS NOT NULL
                        AND str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_nullable) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_nullable) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'discriminator' VALUE CASE
                        WHEN self.schema_discriminator IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           self.schema_discriminator
                        ELSE
                           NULL
                        END
                     ,'readOnly'      VALUE CASE
                        WHEN self.schema_readOnly IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_readOnly) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_readOnly) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'writeOnly'     VALUE CASE
                        WHEN self.schema_writeOnly IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_writeOnly) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_writeOnly) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'maxItems'      VALUE self.schema_maxItems
                     ,'minItems'      VALUE self.schema_minItems
                     ,'maxProperties' VALUE self.schema_maxProperties
                     ,'minProperties' VALUE self.schema_minProperties
                     ,'externalDocs'  VALUE clb_schema_externalDocs   FORMAT JSON
                     ,'deprecated'    VALUE CASE
                        WHEN LOWER(self.schema_deprecated) = 'true'
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           'true'
                        WHEN LOWER(self.schema_deprecated) = 'false'
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           'false'
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'items'         VALUE clb_schema_items_schema   FORMAT JSON
                     ,'xml'           VALUE clb_xml                   FORMAT JSON
                     ,'properties'    VALUE clb_schema_properties     FORMAT JSON
                     ,'required'      VALUE clb_schema_prop_required  FORMAT JSON
                     ,'x-order'       VALUE CASE
                      WHEN int_inject_property_xorder = 1
                      THEN
                        p_xorder
                      ELSE
                        NULL
                      END
                     ABSENT ON NULL
                     RETURNING CLOB
                  )
                  INTO clb_output
                  FROM dual;
                  
               END IF;
               
            END IF;
            
         END IF;
            
      END IF;

      --------------------------------------------------------------------------
      -- Step 100
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toMockJSON(
       p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output                     CLOB;
      str_identifier                 VARCHAR2(255 Char);
      str_combine_type               VARCHAR2(255 Char);
      str_combine_target             VARCHAR2(255 Char);
      
      FUNCTION esc(
         pin IN VARCHAR2
      ) RETURN VARCHAR2
      AS
         pout VARCHAR2(32000);
      BEGIN
         SELECT
         JSON_OBJECT('a' VALUE pin)
         INTO pout
         FROM dual;
         
         pout := REGEXP_REPLACE(pout,'^\{"a"\:','');
         pout := REGEXP_REPLACE(pout,'\}$','');
         
         RETURN pout;
         
      END esc;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Determine item identifier
      --------------------------------------------------------------------------
      IF p_short_id = 'TRUE'
      THEN
         str_identifier := p_short_identifier;
         
      ELSE
         str_identifier := p_identifier;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Branch if needed for combines
      --------------------------------------------------------------------------
      IF  self.combine_schemas IS NOT NULL
      AND self.combine_schemas.COUNT > 0
      THEN
         SELECT
          a.object_type_id
         ,a.object_id
         INTO
          str_combine_type
         ,str_combine_target
         FROM (
            SELECT
             bb.object_type_id
            ,bb.object_id
            FROM
            dz_swagger3_xobjects aa
            JOIN
            TABLE(self.combine_schemas) bb
            ON
                aa.object_type_id = bb.object_type_id
            AND aa.object_id      = bb.object_id
            ORDER BY
            bb.object_order 
         ) a
         WHERE
         ROWNUM <= 1;
         
         SELECT
         a.schematyp.toMockJSON(
             p_short_id         => p_short_id
            ,p_identifier       => a.object_id
            ,p_short_identifier => a.short_id
         )
         INTO clb_output
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = str_combine_type
         AND a.object_id = str_combine_target;
            
      ELSE
         IF self.schema_category = 'scalar'
         THEN
            IF self.schema_type IN ('number','integer')
            THEN
               IF self.schema_example_number IS NULL
               THEN
                  clb_output := '0';
                   
               ELSE
                  clb_output := TO_CHAR(self.schema_example_number);
                  
               END IF;
            
            ELSE
               IF self.schema_example_string IS NULL
               THEN
                  IF self.schema_format = 'date'
                  THEN
                     clb_output := esc('2013-12-25');
                     
                  ELSE
                     clb_output := esc('string');
                  
                  END IF;
                   
               ELSE
                  clb_output :=  esc(self.schema_example_string);
                  
               END IF;
            
            END IF;
         
         ELSIF self.schema_category = 'array'
         THEN
            SELECT
            JSON_ARRAY(
               a.schematyp.toMockJSON(
                   p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
               ) FORMAT JSON
               RETURNING CLOB
            )
            INTO clb_output
            FROM
            dz_swagger3_xobjects a
            WHERE
                a.object_type_id = self.schema_items_schema.object_type_id
            AND a.object_id      = self.schema_items_schema.object_id;
            
         ELSIF self.schema_category IN ('combine','object')
         THEN
            SELECT
            JSON_OBJECTAGG(
               b.object_key VALUE a.schematyp.toMockJSON(
                   p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
               ) FORMAT JSON
               RETURNING CLOB
            )
            INTO clb_output
            FROM
            dz_swagger3_xobjects a
            JOIN
            TABLE(self.schema_properties) b
            ON
                a.object_type_id = b.object_type_id
            AND a.object_id      = b.object_id
            WHERE
            COALESCE(a.schematyp.property_list_hidden,'FALSE') <> 'TRUE';
         
         END IF;
         
      END IF;
      
      RETURN clb_output;
      
   END toMockJSON;
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toMockXML(
       p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_temp                        CLOB;
      clb_output                      CLOB;
      str_identifier                  VARCHAR2(255 Char);
      str_combine_type                VARCHAR2(255 Char);
      str_combine_target              VARCHAR2(255 Char);
      ary_ids                         dz_swagger3_string_vry;
      ary_keys                        dz_swagger3_string_vry;
      ary_clob                        dz_swagger3_clob_vry;
      str_object_name_start           VARCHAR2(255 Char);
      str_object_name_stop            VARCHAR2(255 Char);
      ary_self_schema_type            dz_swagger3_string_vry;
      ary_self_xml_name               dz_swagger3_string_vry;
      ary_self_xml_wrapped            dz_swagger3_string_vry;
      ary_self_xml_namespace          dz_swagger3_string_vry;
      ary_self_xml_prefix             dz_swagger3_string_vry;
      ary_self_xml_attribute          dz_swagger3_string_vry;
      ary_self_properties             dz_swagger3_object_vry;
      str_child_key                   VARCHAR2(4000);
      str_child_xml_name              VARCHAR2(4000);
      str_child_xml_namespace         VARCHAR2(4000);
      str_child_xml_prefix            VARCHAR2(4000);
      str_child_xml_attribute         VARCHAR2(4000);
      str_child_schema_example_str    VARCHAR2(4000);
      str_child_schema_example_num    VARCHAR2(4000);
      str_child_attributes            VARCHAR2(32000);
      
   BEGIN
   
      IF p_short_id = 'TRUE'
      THEN
         str_identifier := p_short_identifier;
         
      ELSE
         str_identifier := p_identifier;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Branch if needed for combines
      --------------------------------------------------------------------------
      IF  self.combine_schemas IS NOT NULL
      AND self.combine_schemas.COUNT > 0
      THEN
         SELECT
          a.object_type_id
         ,a.object_id
         INTO
          str_combine_type
         ,str_combine_target
         FROM (
            SELECT
             bb.object_type_id
            ,bb.object_id
            FROM
            dz_swagger3_xobjects aa
            JOIN
            TABLE(self.combine_schemas) bb
            ON
                aa.object_type_id = bb.object_type_id
            AND aa.object_id      = bb.object_id
            ORDER BY
            bb.object_order 
         ) a
         WHERE
         ROWNUM <= 1;
         
         SELECT
         a.schematyp.toMockXML(
             p_short_id         => p_short_id
            ,p_identifier       => a.object_id
            ,p_short_identifier => a.short_id
         )
         INTO clb_output
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = str_combine_type
         AND a.object_id = str_combine_target;
      
      ELSE
         IF self.schema_category = 'scalar'
         THEN
            IF self.schema_type IN ('number','integer')
            THEN
               IF self.schema_example_number IS NULL
               THEN
                  clb_output := '0';
                   
               ELSE
                  clb_output := TO_CHAR(self.schema_example_number);
                  
               END IF;
            
            ELSE
               IF self.schema_example_string IS NULL
               THEN
                  IF self.schema_format = 'date'
                  THEN
                     clb_output := '2013-12-25';
                     
                  ELSE
                     clb_output := 'string';
                  
                  END IF;
                   
               ELSE
                  clb_output :=  DBMS_XMLGEN.CONVERT(self.schema_example_string);
                  
               END IF;
            
            END IF;
         
         ELSIF self.schema_category = 'array'
         THEN
            SELECT
             a.schematyp.xml_name
            ,a.schematyp.xml_prefix
            ,a.schematyp.xml_namespace
            ,a.schematyp.toMockXML(
                p_short_id         => p_short_id
               ,p_identifier       => a.object_id
               ,p_short_identifier => a.short_id
            )
            ,a.schematyp.schema_properties
            INTO 
             str_child_xml_name
            ,str_child_xml_prefix
            ,str_child_xml_namespace
            ,clb_temp
            ,ary_self_properties
            FROM
            dz_swagger3_xobjects a
            WHERE
                a.object_type_id = self.schema_items_schema.object_type_id
            AND a.object_id      = self.schema_items_schema.object_id;
            
            IF str_child_xml_name IS NOT NULL
            THEN
               str_object_name_start := str_child_xml_name;
               str_object_name_stop := str_child_xml_name;
               
            ELSE
               str_object_name_start := self.schema_items_schema.object_id;
               str_object_name_stop  := self.schema_items_schema.object_id;

            END IF;
            
            IF str_child_xml_prefix IS NOT NULL
            THEN
               str_object_name_start := str_child_xml_prefix || ':' || str_object_name_start;
               str_object_name_stop  := str_child_xml_prefix || ':' || str_object_name_stop;
               
            END IF;
            
            IF str_child_xml_namespace IS NOT NULL
            THEN
               IF str_child_xml_prefix IS NOT NULL
               THEN
                  str_object_name_start := str_object_name_start 
                     || ' xmlns:' || str_child_xml_prefix
                     || '="' || str_child_xml_namespace || '"';
                     
               ELSE
                  str_object_name_start := str_object_name_start 
                     || ' xmlns="' || str_child_xml_namespace || '"';
                     
               END IF;
               
            END IF;
            
            str_child_attributes := '';
            FOR j IN 1 .. ary_self_properties.COUNT
            LOOP
               SELECT
                a.object_id
               ,a.schematyp.xml_name
               ,a.schematyp.xml_prefix
               ,a.schematyp.xml_attribute
               ,a.schematyp.schema_example_string
               ,TO_CHAR(a.schematyp.schema_example_number)
               INTO
                str_child_key
               ,str_child_xml_name
               ,str_child_xml_prefix
               ,str_child_xml_attribute
               ,str_child_schema_example_str
               ,str_child_schema_example_num
               FROM
               dz_swagger3_xobjects a
               WHERE
                   a.object_type_id = 'schematyp'
               AND a.object_id = ary_self_properties(j).object_id;

               IF str_child_xml_attribute = 'TRUE'
               THEN               
                  IF str_child_xml_name IS NOT NULL
                  THEN
                     str_child_xml_name := str_child_xml_name;
                     
                  ELSE
                     str_child_xml_name := str_child_key;
                  
                  END IF;
                     
                  IF str_child_xml_prefix IS NOT NULL
                  THEN
                     str_child_xml_name := str_child_xml_prefix || ':' || str_child_xml_name;
                     
                  END IF;
                  
                  str_child_attributes := str_child_attributes 
                     || ' ' || str_child_xml_name || '="'
                     || DBMS_XMLGEN.CONVERT(
                        COALESCE(str_child_schema_example_str,str_child_schema_example_num,'string')
                     ) || '"';
                     
               END IF;
               
            END LOOP;
            
            clb_output := '<'  || str_object_name_start || str_child_attributes || '>'
                       || clb_temp
                       || '</' || str_object_name_stop || '>';
            
         ELSIF self.schema_category IN ('combine','object')
         THEN
            SELECT
             b.object_id
            ,b.object_key
            ,a.schematyp.toMockXML(
                p_short_id         => p_short_id
               ,p_identifier       => a.object_id
               ,p_short_identifier => a.short_id
            )
            ,a.schematyp.schema_type
            ,a.schematyp.xml_name
            ,a.schematyp.xml_wrapped
            ,a.schematyp.xml_namespace
            ,a.schematyp.xml_prefix
            ,a.schematyp.xml_attribute
            BULK COLLECT INTO
             ary_ids
            ,ary_keys
            ,ary_clob
            ,ary_self_schema_type
            ,ary_self_xml_name
            ,ary_self_xml_wrapped
            ,ary_self_xml_namespace
            ,ary_self_xml_prefix
            ,ary_self_xml_attribute
            FROM
            dz_swagger3_xobjects a
            JOIN
            TABLE(self.schema_properties) b
            ON
                a.object_type_id = b.object_type_id
            AND a.object_id      = b.object_id
            WHERE
            COALESCE(a.schematyp.property_list_hidden,'FALSE') <> 'TRUE';

            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               IF ary_self_xml_attribute(i) IS NULL
               OR ary_self_xml_attribute(i) != 'TRUE'
               THEN
                  IF  ary_self_schema_type(i) = 'array'
                  AND ary_self_xml_name(i) IS NOT NULL
                  AND ary_self_xml_wrapped(i) = 'TRUE'
                  THEN
                     str_object_name_start := ary_self_xml_name(i);
                     str_object_name_stop  := ary_self_xml_name(i);
                     
                  ELSE
                     str_object_name_start := ary_keys(i);
                     str_object_name_stop  := ary_keys(i);
                                 
                  END IF;
                  
                  IF ary_self_xml_prefix(i) IS NOT NULL
                  THEN
                     str_object_name_start := ary_self_xml_prefix(i) || ':' || str_object_name_start;
                     str_object_name_stop  := ary_self_xml_prefix(i) || ':' || str_object_name_stop;
                     
                  END IF;
                  
                  IF ary_self_xml_namespace(i) IS NOT NULL
                  THEN
                     IF ary_self_xml_prefix(i) IS NOT NULL
                     THEN
                        str_object_name_start := str_object_name_start 
                           || ' xmlns:' || ary_self_xml_prefix(i)
                           || '="' || ary_self_xml_namespace(i) || '"';
                           
                     ELSE
                        str_object_name_start := str_object_name_start 
                           || ' xmlns="' || ary_self_xml_namespace(i) || '"';
                           
                     END IF;
                     
                  END IF;
                  
                  SELECT
                  a.schematyp.schema_properties
                  INTO
                  ary_self_properties
                  FROM
                  dz_swagger3_xobjects a
                  WHERE
                      a.object_id = ary_ids(i)
                  AND a.object_type_id = 'schematyp';
                  
                  str_child_attributes := '';
                  FOR j IN 1 .. ary_self_properties.COUNT
                  LOOP
                     SELECT
                      a.object_id
                     ,a.schematyp.xml_name
                     ,a.schematyp.xml_prefix
                     ,a.schematyp.xml_attribute
                     ,a.schematyp.schema_example_string
                     ,TO_CHAR(a.schematyp.schema_example_number)
                     INTO
                      str_child_key
                     ,str_child_xml_name
                     ,str_child_xml_prefix
                     ,str_child_xml_attribute
                     ,str_child_schema_example_str
                     ,str_child_schema_example_num
                     FROM
                     dz_swagger3_xobjects a
                     WHERE
                         a.object_type_id = 'schematyp'
                     AND a.object_id = ary_self_properties(j).object_id;

                     IF str_child_xml_attribute = 'TRUE'
                     THEN
                     
                        IF str_child_xml_name IS NOT NULL
                        THEN
                           str_child_xml_name := str_child_xml_name;
                           
                        ELSE
                           str_child_xml_name := str_child_key;
                        
                        END IF;
                           
                        IF str_child_xml_prefix IS NOT NULL
                        THEN
                           str_child_xml_name := str_child_xml_prefix || ':' || str_child_xml_name;
                           
                        END IF;
                        
                        str_child_attributes := str_child_attributes 
                           || ' ' || str_child_xml_name || '="'
                           || DBMS_XMLGEN.CONVERT(
                              COALESCE(str_child_schema_example_str,str_child_schema_example_num,'string')
                           ) || '"';
                           
                     END IF;
                     
                  END LOOP;

                  clb_output := clb_output
                             || '<'  || str_object_name_start || str_child_attributes || '>'
                             || ary_clob(i)
                             || '</' || str_object_name_stop || '>';
                             
               END IF;

            END LOOP;

         END IF;
         
      END IF;
      
      RETURN clb_output;
      
   END toMockXML;
   
END;
/

