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
      ,p_load_components         IN  VARCHAR2 DEFAULT 'TRUE'
      ,p_ref_brake               IN  VARCHAR2 DEFAULT 'FALSE'
   ) RETURN SELF AS RESULT
   AS
      str_ref_brake VARCHAR2(255 Char) := p_ref_brake;
      
   BEGIN 
   /*
      --------------------------------------------------------------------------
      -- Step 10
      -- Pull the object information
      -------------------------------------------------------------------------- 
      BEGIN
         SELECT
         dz_swagger3_response_typ(
             p_hash_key              => p_response_code
            ,p_response_id           => a.response_id
            ,p_response_description  => a.response_description
            ,p_response_headers      => NULL
            ,p_response_content      => NULL
            ,p_response_links        => NULL
            ,p_load_components       => p_load_components 
         )
         INTO SELF
         FROM
         dz_swagger3_response a
         WHERE
             a.versionid   = p_versionid
         AND a.response_id = p_response_id;
         
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
      IF  p_ref_brake = 'TRUE'
      AND self.doREF() = 'TRUE'
      THEN
         NULL;
         
      ELSE
         IF str_ref_brake = 'FIRE'
         THEN
            str_ref_brake := 'TRUE';
            
         END IF;
         
         SELECT
         dz_swagger3_media_typ(
             p_media_id              => b.media_id
            ,p_media_type            => a.media_type
            ,p_versionid             => p_versionid
            ,p_ref_brake             => str_ref_brake
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
             a.versionid = p_versionid
         AND a.parent_id = p_response_id
         ORDER BY
          a.media_order
         ,a.media_type;

      END IF;
      */
      --------------------------------------------------------------------------
      -- Step 
      -- Return the completed object
      --------------------------------------------------------------------------   
      RETURN; 
      
   END dz_swagger3_response_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_response_typ(
       p_response_id             IN  VARCHAR2
      ,p_response_description    IN  VARCHAR2
      ,p_response_headers        IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_header_list
      ,p_response_content        IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_media_list
      ,p_response_links          IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_link_list
      ,p_load_components         IN  VARCHAR2 DEFAULT 'TRUE'
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.response_id             := p_response_id;
      self.response_description    := p_response_description;
      self.response_headers        := p_response_headers;
      self.response_content        := p_response_content;
      self.response_links          := p_response_links;
      /*
      --------------------------------------------------------------------------
      IF self.doREF() = 'TRUE'
      AND p_load_components = 'TRUE'
      THEN
         dz_swagger3_main.insert_component(
             p_object_id     => p_response_id
            ,p_object_type   => 'response'
            ,p_response_code => p_hash_key
         );
         
      END IF;
      */
      RETURN; 
      
   END dz_swagger3_response_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION isNULL
   RETURN VARCHAR2
   AS
   BEGIN
   
      IF self.response_id IS NOT NULL
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
      RETURN self.response_id;
      
   END key;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION doRef
   RETURN VARCHAR2
   AS
   BEGIN
      IF self.response_force_inline = 'TRUE'
      THEN
         RETURN 'FALSE';
         
      END IF;
      
      RETURN 'TRUE';
      
   END doRef;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print         IN  INTEGER   DEFAULT NULL
      ,p_force_inline         IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
   BEGIN
   
      IF  self.doREF() = 'TRUE'
      AND p_force_inline <> 'TRUE'
      THEN
         RETURN toJSON_ref(
             p_pretty_print  => p_pretty_print
            ,p_force_inline  => p_force_inline
         );
   
      ELSE
         RETURN toJSON_schema(
             p_pretty_print  => p_pretty_print
            ,p_force_inline  => p_force_inline
         );
      
      END IF;
      
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON_schema(
       p_pretty_print         IN  INTEGER   DEFAULT NULL
      ,p_force_inline         IN  VARCHAR2  DEFAULT 'FALSE'
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
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || ' ) '
         || ',a.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || 'a.object_id IN (SELECT column_name FROM TABLE(:p03)) '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
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
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || ' ) '
         || ',a.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || 'a.object_id IN (SELECT column_name FROM TABLE(:p03)) '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
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
      IF self.response_links IS NOT NULL 
      OR self.response_links.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.linktyp.toJSON( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || ' ) '
         || ',a.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || 'a.object_id IN (SELECT column_name FROM TABLE(:p03)) '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
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
           
   END toJSON_schema;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON_ref(
       p_pretty_print         IN  INTEGER   DEFAULT NULL
      ,p_force_inline         IN  VARCHAR2  DEFAULT 'FALSE'
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
      -- Add the ref
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.value2json(
             '$ref'
            ,'#/components/responses/' || dz_swagger3_util.utl_url_escape(
               dz_swagger3_main.short(
                   p_object_id   => self.response_id
                  ,p_object_type => 'response'
               )
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
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print         IN  INTEGER   DEFAULT 0
      ,p_initial_indent       IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed       IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline         IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS      
   BEGIN
   
      IF self.doRef() = 'TRUE'
      AND p_force_inline <> 'TRUE'
      THEN
         RETURN self.toYAML_ref(
             p_pretty_print    => p_pretty_print
            ,p_initial_indent  => p_initial_indent
            ,p_final_linefeed  => p_final_linefeed
            ,p_force_inline    => p_force_inline
         );
         
      ELSE
         RETURN self.toYAML_schema(
             p_pretty_print    => p_pretty_print
            ,p_initial_indent  => p_initial_indent
            ,p_final_linefeed  => p_final_linefeed
            ,p_force_inline    => p_force_inline
         );
      
      END IF;
   
   END toYAML;
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML_schema(
       p_pretty_print         IN  INTEGER   DEFAULT 0
      ,p_initial_indent       IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed       IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline         IN  VARCHAR2  DEFAULT 'FALSE'
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
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || ' ) '
         || ',a.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || 'a.object_id IN (SELECT column_name FROM TABLE(:p03)) '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
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
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || ' ) '
         || ',a.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || 'a.object_id IN (SELECT column_name FROM TABLE(:p03)) '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
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
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || ' ) '
         || ',a.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || 'a.object_id IN (SELECT column_name FROM TABLE(:p03)) '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
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
      
   END toYAML_schema;
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML_ref(
       p_pretty_print         IN  INTEGER   DEFAULT 0
      ,p_initial_indent       IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed       IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline         IN  VARCHAR2  DEFAULT 'FALSE'
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
             '#/components/responses/' || dz_swagger3_main.short(
                p_object_id   => self.response_id
               ,p_object_type => 'response'
             )
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
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   STATIC PROCEDURE loader(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  MDSYS.SDO_STRING2_ARRAY
      ,p_versionid           IN  VARCHAR2
   )
   AS
   BEGIN
   
      INSERT INTO dz_swagger3_xrelates(
          parent_object_id
         ,child_object_id
         ,child_object_type_id
      )
      SELECT
       p_parent_id
      ,a.column_value
      ,'extrdocs'
      FROM
      TABLE(p_children_ids) a;

      EXECUTE IMMEDIATE 
      'INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,extrdocstyp
          ,ordering_key
      )
      SELECT
       a.column_value
      ,''extrdocstyp''
      ,dz_swagger3_extrdocs_typ(
          p_externaldoc_id => a.column_value
         ,p_versionid      => :p01
       )
      ,10
      FROM 
      TABLE(:p02) a'
      USING p_versionid,p_children_ids;
      
      COMMIT;

   END;
   
END;
/

