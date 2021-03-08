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
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Initialize the object
      --------------------------------------------------------------------------
      --dbms_output.put_line('media: ' || p_media_id);
      self.versionid := p_versionid;

      --------------------------------------------------------------------------
      -- Step 20
      -- Pull the object information
      --------------------------------------------------------------------------
      SELECT
       a.media_id
      ,dz_swagger3_object_typ(
          p_object_id      => a.media_schema_id
         ,p_object_type_id => 'schematyp'
       )
      ,a.media_example_string
      ,a.media_example_number
      INTO
       self.media_id
      ,self.media_schema
      ,self.media_example_string
      ,self.media_example_number
      FROM
      dz_swagger3_media a
      WHERE
          a.versionid = p_versionid
      AND a.media_id  = p_media_id;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Pull any examples
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id      => a.example_id
         ,p_object_type_id => 'exampletyp'
         ,p_object_key     => a.example_name
         ,p_object_order   => a.example_order
      )
      BULK COLLECT INTO self.media_examples
      FROM
      dz_swagger3_parent_example_map a
      WHERE
          a.versionid   = p_versionid
      AND a.parent_id   = p_media_id;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Pull any encodings
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id      => a.encoding_id
         ,p_object_type_id => 'encodingtyp'
         ,p_object_key     => a.encoding_name
         ,p_object_order   => a.encoding_order
      )
      BULK COLLECT INTO self.media_encoding
      FROM
      dz_swagger3_media_encoding_map a
      WHERE
          a.versionid   = p_versionid
      AND a.media_id   = p_media_id;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Return the completed object
      --------------------------------------------------------------------------
      RETURN; 
      
   END dz_swagger3_media_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_media_typ(
       p_media_id                 IN  VARCHAR2
      ,p_parameters               IN  dz_swagger3_object_vry --dz_swagger3_parameter_list
      ,p_versionid                IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Initialize the object
      --------------------------------------------------------------------------
      self.versionid    := p_versionid;

      --------------------------------------------------------------------------
      -- Step 20
      -- Emulate the post request body
      --------------------------------------------------------------------------
      self.media_id     := p_media_id;
      self.media_schema := dz_swagger3_object_typ(
          p_object_id      => 'sc.' || p_media_id
         ,p_object_type_id => 'schematyp'
         ,p_object_subtype => 'emulated'
      );
      self.media_emulated_parms := p_parameters;
      
      RETURN;
         
   END dz_swagger3_media_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Load the media schema
      --------------------------------------------------------------------------
      IF self.media_schema.object_subtype = 'emulated'
      THEN
         dz_swagger3_loader.schematyp_emulated(
             p_parent_id     => self.media_id
            ,p_child_id      => self.media_schema
            ,p_parameter_ids => self.media_emulated_parms
            ,p_versionid     => self.versionid
         );
         
      ELSE
         dz_swagger3_loader.schematyp(
             p_parent_id     => self.media_id
            ,p_children_ids  => dz_swagger3_object_vry(self.media_schema)
            ,p_versionid     => self.versionid
         );

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Load the examples
      --------------------------------------------------------------------------
      IF  self.media_examples IS NOT NULL
      AND self.media_examples.COUNT > 0
      THEN
         dz_swagger3_loader.exampletyp(
             p_parent_id    => self.media_id
            ,p_children_ids => self.media_examples
            ,p_versionid    => self.versionid
         );
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Load the encoding
      --------------------------------------------------------------------------
      IF  self.media_encoding IS NOT NULL
      AND self.media_encoding.COUNT > 0
      THEN
         dz_swagger3_loader.encodingtyp(
             p_parent_id    => self.media_id
            ,p_children_ids => self.media_encoding
            ,p_versionid    => self.versionid
         );
      
      END IF;

   END traverse;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output         CLOB;
      clb_media_schema   CLOB;
      clb_media_examples CLOB;
      clb_media_encoding CLOB;
      
   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Add schema object
      --------------------------------------------------------------------------
      IF  self.media_schema IS NOT NULL
      AND self.media_schema.object_id IS NOT NULL
      THEN
         BEGIN
            SELECT 
            a.schematyp.toJSON( 
                p_force_inline     => p_force_inline
               ,p_short_id         => p_short_id
               ,p_identifier       => a.object_id 
               ,p_short_identifier => a.short_id 
               ,p_reference_count  => a.reference_count 
            )
            INTO clb_media_schema
            FROM 
            dz_swagger3_xobjects a 
            WHERE 
                a.object_type_id = self.media_schema.object_type_id
            AND a.object_id      = self.media_schema.object_id; 
            
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_media_schema := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;

      END IF;
        
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional examples map
      --------------------------------------------------------------------------
      IF  self.media_examples IS NOT NULL 
      AND self.media_examples.COUNT > 0
      THEN
         SELECT
         JSON_OBJECTAGG(
            b.object_key VALUE a.exampletyp.toJSON(
                p_force_inline     => p_force_inline
               ,p_short_id         => p_short_id
               ,p_identifier       => a.object_id
               ,p_short_identifier => a.short_id
               ,p_reference_count  => a.reference_count
            ) FORMAT JSON
            RETURNING CLOB
         )
         INTO clb_media_examples
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.media_examples) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id
         ORDER BY b.object_order;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional encoding map
      --------------------------------------------------------------------------
      IF  self.media_encoding IS NOT NULL 
      AND self.media_encoding.COUNT > 0
      THEN
         SELECT
         JSON_OBJECTAGG(
            b.object_key VALUE a.encodingtyp.toJSON(
                p_force_inline   => p_force_inline
               ,p_short_id       => p_short_id
            ) FORMAT JSON
            RETURNING CLOB
         )
         INTO clb_media_encoding
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.media_encoding) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id
         ORDER BY b.object_order;

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Build the object
      --------------------------------------------------------------------------
      IF self.media_example_string IS NOT NULL
      THEN
         SELECT
         JSON_OBJECT(
             'schema'       VALUE clb_media_schema          FORMAT JSON
            ,'examples'     VALUE clb_media_examples        FORMAT JSON
            ,'example'      VALUE self.media_example_string
            ,'encoding'     VALUE clb_media_encoding        FORMAT JSON
            ABSENT ON NULL
            RETURNING CLOB
         )
         INTO clb_output
         FROM dual;
         
      ELSIF self.media_example_number IS NOT NULL
      THEN
         SELECT
         JSON_OBJECT(
             'schema'       VALUE clb_media_schema          FORMAT JSON
            ,'examples'     VALUE clb_media_examples        FORMAT JSON
            ,'example'      VALUE self.media_example_number
            ,'encoding'     VALUE clb_media_encoding        FORMAT JSON
            ABSENT ON NULL
            RETURNING CLOB
         )
         INTO clb_output
         FROM dual;
      
      ELSE
         SELECT
         JSON_OBJECT(
             'schema'       VALUE clb_media_schema          FORMAT JSON
            ,'examples'     VALUE clb_media_examples        FORMAT JSON
            ,'encoding'     VALUE clb_media_encoding        FORMAT JSON
            ABSENT ON NULL
            RETURNING CLOB
         )
         INTO clb_output
         FROM dual;
      
      END IF;

      --------------------------------------------------------------------------
      -- Step 60
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
   ) RETURN CLOB
   AS
      cb               CLOB;
      v2               VARCHAR2(32000);

      ary_keys         dz_swagger3_string_vry;
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
      -- Write the yaml schema object
      --------------------------------------------------------------------------
      IF self.media_schema IS NOT NULL
      AND self.media_schema.object_id IS NOT NULL
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
                a.object_type_id = self.media_schema.object_type_id
            AND a.object_id      = self.media_schema.object_id; 
            
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
      -- Step 30
      -- Write the optional variables map
      --------------------------------------------------------------------------
      IF  self.media_examples IS NOT NULL 
      AND self.media_examples.COUNT > 0
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
         TABLE(self.media_examples) b
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
         
      ELSE
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the yaml example item
      --------------------------------------------------------------------------
         IF self.media_example_string IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'example: ' || dz_swagger3_util.yaml_text(
                   self.media_example_string
                  ,p_pretty_print
                )
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );
            
         ELSIF self.media_example_number IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'example: ' || TO_CHAR(self.media_example_number)
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );
            
         END IF;
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the optional variables map
      --------------------------------------------------------------------------
      IF  self.media_encoding IS NOT NULL 
      AND self.media_encoding.COUNT > 0
      THEN
         SELECT
          a.encodingtyp.toYAML(
             p_pretty_print   => p_pretty_print + 2
            ,p_force_inline   => p_force_inline
            ,p_short_id       => p_short_id
          )
         ,b.object_key
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.media_encoding) b
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
               ,p_in_v => 'encoding: '
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
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Cough it out 
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

