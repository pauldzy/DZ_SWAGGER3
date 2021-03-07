CREATE OR REPLACE TYPE BODY dz_swagger3_encoding_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_encoding_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_encoding_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_encoding_typ(
       p_encoding_id            IN  VARCHAR2
      ,p_versionid              IN  VARCHAR2
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Set up the object
      --------------------------------------------------------------------------
      self.versionid := p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Pull the object information
      --------------------------------------------------------------------------
      SELECT
       a.encoding_id
      ,a.encoding_contentType
      ,a.encoding_style
      ,a.encoding_explode
      ,a.encoding_allowReserved
      INTO
       self.encoding_id
      ,self.encoding_contentType
      ,self.encoding_style 
      ,self.encoding_explode 
      ,self.encoding_allowReserved
      FROM
      dz_swagger3_encoding a
      WHERE
          a.versionid   = p_versionid
      AND a.encoding_id = p_encoding_id;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Collect the response headers
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id          => a.header_id
         ,p_object_type_id     => 'headertyp'
         ,p_object_key         => a.header_name
         ,p_object_order       => a.header_order
      )
      BULK COLLECT INTO self.encoding_headers 
      FROM
      dz_swagger3_parent_header_map a
      WHERE
          a.versionid  = p_versionid
      AND a.parent_id  = p_encoding_id;

      --------------------------------------------------------------------------
      -- Step 40
      -- Return the completed object
      --------------------------------------------------------------------------
      RETURN; 
      
   END dz_swagger3_encoding_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Load the external docs
      --------------------------------------------------------------------------
      IF  self.encoding_headers IS NOT NULL
      AND self.encoding_headers.COUNT > 0
      THEN
         dz_swagger3_loader.headertyp(
             p_parent_id    => self.encoding_id
            ,p_children_ids => self.encoding_headers
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
      clb_output           CLOB;
      clb_encoding_headers CLOB;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Add optional encoding headers
      --------------------------------------------------------------------------
      IF  self.encoding_headers IS NOT NULL 
      AND self.encoding_headers.COUNT > 0
      THEN
         SELECT
         JSON_ARRAYAGG(
            JSON_OBJECT(
                b.object_key VALUE a.headertyp.toJSON(
                   p_force_inline     => p_force_inline
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_reference_count  => a.reference_count
                ) FORMAT JSON
            )
         )
         INTO clb_encoding_headers
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.encoding_headers) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id
         ORDER BY b.object_order;

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the object
      --------------------------------------------------------------------------
      SELECT
      JSON_OBJECT(
          'contentType'         VALUE self.encoding_contentType ABSENT ON NULL
         ,'headers'             VALUE CASE
            WHEN self.encoding_headers IS NOT NULL 
            AND  self.encoding_headers.COUNT > 0
            THEN
               clb_encoding_headers FORMAT JSON
            ELSE
               NULL
            END                                                 ABSENT ON NULL
         ,'style'               VALUE self.encoding_style       ABSENT ON NULL
         ,'explode'             VALUE CASE
            WHEN LOWER(self.encoding_explode) = 'true'
            THEN
               TRUE
            WHEN LOWER(self.encoding_explode) = 'false'
            THEN
               FALSE
            ELSE
               NULL
            END                                                 ABSENT ON NULL
         ,'allowReserved'       VALUE CASE
            WHEN LOWER(self.encoding_allowReserved) = 'true'
            THEN
               TRUE
            WHEN LOWER(self.encoding_allowReserved) = 'false'
            THEN
               FALSE
            ELSE
               NULL
            END                                                 ABSENT ON NULL
      )
      INTO clb_output
      FROM dual;

      --------------------------------------------------------------------------
      -- Step 90
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
      IF self.encoding_contentType IS NOT NULL
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => 'contentType: ' || dz_swagger3_util.yaml_text(
                self.encoding_contentType
               ,p_pretty_print
             )
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional license url
      --------------------------------------------------------------------------
      IF  self.encoding_headers IS NOT NULL 
      AND self.encoding_headers.COUNT > 0
      THEN
         SELECT
          a.headertyp.toYAML(
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
         TABLE(self.encoding_headers) b
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
               ,p_in_v => 'headers: '
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
      -- Step 40
      -- Write the optional encoding style element
      --------------------------------------------------------------------------
      IF self.encoding_style IS NOT NULL
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => 'style: ' || dz_swagger3_util.yaml_text(
                self.encoding_style
               ,p_pretty_print
             )
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the optional encoding explode element
      --------------------------------------------------------------------------
      IF self.encoding_explode IS NOT NULL
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => 'explode: ' || LOWER(self.encoding_explode)
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Write the optional allowReserved element
      --------------------------------------------------------------------------
      IF self.encoding_allowReserved IS NOT NULL
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => 'allowReserved: ' || LOWER(self.encoding_allowReserved)
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Cough it out without final line feed
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

