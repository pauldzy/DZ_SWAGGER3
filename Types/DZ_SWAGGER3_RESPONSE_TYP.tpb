CREATE OR REPLACE TYPE BODY dz_swagger3_response_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_response_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_response_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_response_typ(
       p_response_id             IN  VARCHAR2
      ,p_response_code           IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
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
       a.response_id
      ,a.response_description
      INTO
       self.response_id
      ,self.response_description
      FROM
      dz_swagger3_response a
      WHERE
          a.versionid   = p_versionid
      AND a.response_id = p_response_id;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Collect the response headers
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id          => b.header_id
         ,p_object_type_id     => 'headertyp'
         ,p_object_key         => a.header_name
         ,p_object_order       => a.header_order
      )
      BULK COLLECT INTO self.response_headers
      FROM
      dz_swagger3_response_headr_map a
      JOIN
      dz_swagger3_header b
      ON
          a.versionid   = b.versionid
      AND a.header_id   = b.header_id
      WHERE
          a.versionid   = p_versionid
      AND a.response_id = p_response_id;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Collect the response media content
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id          => b.media_id
         ,p_object_type_id     => 'mediatyp'
         ,p_object_key         => a.media_type
         ,p_object_order       => a.media_order
      )
      BULK COLLECT INTO self.response_content
      FROM
      dz_swagger3_parent_media_map a
      JOIN
      dz_swagger3_media b
      ON
          a.versionid  = b.versionid
      AND a.media_id   = b.media_id
      WHERE
          a.versionid  = p_versionid
      AND a.parent_id  = p_response_id;

      --------------------------------------------------------------------------
      -- Step 50
      -- Collect the response links
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id          => b.link_id
         ,p_object_type_id     => 'linktyp'
         ,p_object_key         => a.link_name
         ,p_object_order       => a.link_order
      )
      BULK COLLECT INTO self.response_links
      FROM
      dz_swagger3_response_link_map a
      JOIN
      dz_swagger3_link b
      ON
          a.versionid   = b.versionid
      AND a.link_id     = b.link_id
      WHERE
          a.versionid   = p_versionid
      AND a.response_id = p_response_id;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Return the completed object
      --------------------------------------------------------------------------   
      RETURN; 
      
   END dz_swagger3_response_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Load the external docs
      --------------------------------------------------------------------------
      IF  self.response_headers IS NOT NULL
      AND self.response_headers.COUNT > 0
      THEN
         dz_swagger3_loader.headertyp(
             p_parent_id    => self.response_id
            ,p_children_ids => self.response_headers
            ,p_versionid    => self.versionid
         );
      
      END IF;

      --------------------------------------------------------------------------
      -- Step 20
      -- Load the properties schemas
      --------------------------------------------------------------------------
      IF  self.response_content IS NOT NULL
      AND self.response_content.COUNT > 0
      THEN
         dz_swagger3_loader.mediatyp(
             p_parent_id    => self.response_id
            ,p_children_ids => self.response_content
            ,p_versionid    => self.versionid
         );
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Load the combine schemas
      --------------------------------------------------------------------------
      IF  self.response_links IS NOT NULL
      AND self.response_links.COUNT > 0
      THEN
         dz_swagger3_loader.linktyp(
             p_parent_id    => self.response_id
            ,p_children_ids => self.response_links
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
      
      str_pad1 := str_pad;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional description 
      --------------------------------------------------------------------------
      IF self.response_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'description'
               ,self.response_description
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional headers
      --------------------------------------------------------------------------
      IF  self.response_headers IS NOT NULL 
      AND self.response_headers.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.headertyp.toJSON( '
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
         ,self.response_headers; 
         
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
      -- Add optional content objects
      --------------------------------------------------------------------------
      IF  self.response_content IS NOT NULL 
      AND self.response_content.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.mediatyp.toJSON( '
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
         ,self.response_content; 

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
               ,p_pretty_print + 2
            );
            str_pad2 := ',';
         
         END LOOP;
         
         clb_hash := clb_hash || dz_json_util.pretty(
             '}'
            ,p_pretty_print + 1,NULL,NULL
         );
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                 'content'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 60
      -- Add optional links map
      --------------------------------------------------------------------------
      IF  self.response_links IS NOT NULL 
      AND self.response_links.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.linktyp.toJSON( '
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
         ,self.response_links; 
         
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
                 'links'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 70
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 80
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
      -- Add the ref
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.value2json(
             '$ref'
            ,'#/components/responses/' || dz_swagger3_util.utl_url_escape(
               p_identifier
             )
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
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print         IN  INTEGER   DEFAULT 0
      ,p_initial_indent       IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed       IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline         IN  VARCHAR2  DEFAULT 'FALSE'
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
      -- Write the yaml description
      --------------------------------------------------------------------------
      IF self.response_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'description: ' || dz_swagger3_util.yaml_text(
                self.response_description
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional header object list
      --------------------------------------------------------------------------
      IF  self.response_headers IS NOT NULL 
      AND self.response_headers.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.headertyp.toYAML( '
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
         ,self.response_headers; 

         clb_output := clb_output || dz_json_util.pretty_str(
             'headers: '
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
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the optional content list
      --------------------------------------------------------------------------
      IF  self.response_content IS NOT NULL 
      AND self.response_content.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.mediatyp.toYAML( '
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
         ,self.response_content; 

         clb_output := clb_output || dz_json_util.pretty_str(
             'content: '
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
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the optional links list
      --------------------------------------------------------------------------
      IF  self.response_links IS NOT NULL 
      AND self.response_links.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.linktyp.toYAML( '
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
         ,self.response_links; 
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'links: '
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
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML_ref(
       p_identifier          IN  VARCHAR2
      ,p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      
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
             '#/components/responses/' || p_identifier
            ,p_pretty_print
         )
         ,p_pretty_print
         ,'  '
      );
      
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
      
   END toYAML_ref;

END;
/

