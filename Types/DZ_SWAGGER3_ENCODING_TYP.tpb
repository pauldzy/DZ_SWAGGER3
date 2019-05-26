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
      /*
      SELECT
      dz_swagger3_object_typ(
          p_object_id          => b.header_id
         ,p_object_type_id     => 'headertyp'
         ,p_object_key         => a.header_name
         ,p_object_order       => a.header_order
      )
      BULK COLLECT INTO self.encoding_headers 
      FROM
      dz_swagger3_response_headr_map a
      JOIN
      dz_swagger3_header b
      ON
          a.versionid   = b.versionid
      AND a.header_id   = b.header_id
      WHERE
          a.versionid   = p_versionid
      AND a.response_id = p_encoding_headers;
*/
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
      -- Add optional contentType
      --------------------------------------------------------------------------
      str_pad1 := str_pad;
      IF self.encoding_contentType IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'contentType'
               ,self.encoding_contentType
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional encoding headers
      --------------------------------------------------------------------------
      IF  self.encoding_headers IS NOT NULL 
      AND self.encoding_headers.COUNT > 0
      THEN
         SELECT
          a.headertyp.toJSON(
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
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                 'headers'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional encoding style
      --------------------------------------------------------------------------
      IF self.encoding_style IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'style'
               ,self.encoding_style
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add optional explode boolean
      --------------------------------------------------------------------------
      IF self.encoding_explode IS NOT NULL
      THEN
         IF LOWER(self.encoding_explode) = 'true'
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
      -- Step 70
      -- Add optional encoding allowReserved
      --------------------------------------------------------------------------
      IF self.encoding_allowReserved IS NOT NULL
      THEN
         IF LOWER(self.encoding_allowReserved) = 'true'
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
      -- Step 80
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
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
      clb_output       CLOB;
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      
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
         clb_output := clb_output || dz_json_util.pretty_str(
             'contentType: ' || dz_swagger3_util.yaml_text(
                self.encoding_contentType
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
      IF  self.encoding_headers IS NOT NULL 
      AND self.encoding_headers.COUNT > 0
      THEN
         SELECT
          a.headertyp.toYAML(
             p_pretty_print     => p_pretty_print + 3
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
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'headers: '
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
      -- Step 40
      -- Write the optional encoding style element
      --------------------------------------------------------------------------
      IF self.encoding_style IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'style: ' || dz_swagger3_util.yaml_text(
                self.encoding_style
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the optional encoding explode element
      --------------------------------------------------------------------------
      IF self.encoding_explode IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'explode: ' || LOWER(self.encoding_explode)
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Write the optional allowReserved element
      --------------------------------------------------------------------------
      IF self.encoding_allowReserved IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'allowReserved: ' || LOWER(self.encoding_allowReserved)
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
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
   
END;
/

