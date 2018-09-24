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
      SELECT
      dz_swagger3_media_typ(
          p_media_id              => b.media_id
         ,p_media_type            => a.media_type
         ,p_versionid             => p_versionid
      )
      BULK COLLECT INTO self.response_content
      FROM
      dz_swagger3_media_parent_map a
      JOIN
      dz_swagger3_media b
      ON
          a.versionid  = b.versionid
      AND a.media_id   = b.media_id
      WHERE
          a.versionid = p_versionid
      AND a.parent_id = p_response_id;
      
      --------------------------------------------------------------------------
      -- Step 
      -- Return the completed object
      --------------------------------------------------------------------------   
      RETURN; 
      
   END dz_swagger3_response_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_response_typ(
       p_hash_key                IN  VARCHAR2
      ,p_response_id             IN  VARCHAR2
      ,p_response_description    IN  VARCHAR2
      ,p_response_headers        IN  dz_swagger3_header_list
      ,p_response_content        IN  dz_swagger3_media_list
      ,p_response_links          IN  dz_swagger3_link_list
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.hash_key                := p_hash_key;
      self.response_id             := p_response_id;
      self.response_description    := p_response_description;
      self.response_headers        := p_response_headers;
      self.response_content        := p_response_content;
      self.response_links          := p_response_links;
      
      RETURN; 
      
   END dz_swagger3_response_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION isNULL
   RETURN VARCHAR2
   AS
   BEGIN
   
      IF self.hash_key IS NOT NULL
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
      IF self.response_content IS NOT NULL
      AND self.response_content.COUNT > 0
      THEN
         FOR i IN 1  .. self.response_content.COUNT
         LOOP
            ary_working := self.response_content(i).unique_schemas();
            
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
   MEMBER FUNCTION response_headers_keys
   RETURN MDSYS.SDO_STRING2_ARRAY
   AS
      int_index  PLS_INTEGER;
      ary_output MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
      IF self.response_headers IS NULL
      OR self.response_headers.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := MDSYS.SDO_STRING2_ARRAY();
      FOR i IN 1 .. self.response_headers.COUNT
      LOOP
         ary_output.EXTEND();
         ary_output(int_index) := self.response_headers(i).hash_key;
         int_index := int_index + 1;
         
      END LOOP;
      
      RETURN ary_output;
   
   END response_headers_keys;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION response_content_keys
   RETURN MDSYS.SDO_STRING2_ARRAY
   AS
      int_index  PLS_INTEGER;
      ary_output MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
      IF self.response_content IS NULL
      OR self.response_content.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := MDSYS.SDO_STRING2_ARRAY();
      FOR i IN 1 .. self.response_content.COUNT
      LOOP
         ary_output.EXTEND();
         ary_output(int_index) := self.response_content(i).hash_key;
         int_index := int_index + 1;
         
      END LOOP;
      
      RETURN ary_output;
   
   END response_content_keys;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION response_links_keys
   RETURN MDSYS.SDO_STRING2_ARRAY
   AS
      int_index  PLS_INTEGER;
      ary_output MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
      IF self.response_links IS NULL
      OR self.response_links.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := MDSYS.SDO_STRING2_ARRAY();
      FOR i IN 1 .. self.response_links.COUNT
      LOOP
         ary_output.EXTEND();
         ary_output(int_index) := self.response_links(i).hash_key;
         int_index := int_index + 1;
         
      END LOOP;
      
      RETURN ary_output;
   
   END response_links_keys;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
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
      -- Add optional variables map
      --------------------------------------------------------------------------
      IF self.response_headers IS NULL 
      OR self.response_headers.COUNT = 0
      THEN
         NULL;
         
      ELSE
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('{',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('{',-1);
            
         END IF;
      
         ary_keys := self.response_headers_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || ary_keys(i) || '":' || str_pad || self.response_headers(i).toJSON(
                  p_pretty_print => p_pretty_print + 2
                )
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
      -- Add optional variables map
      --------------------------------------------------------------------------
      IF self.response_content IS NULL 
      OR self.response_content.COUNT = 0
      THEN
         NULL;
         
      ELSE
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('{',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('{',-1);
            
         END IF;
      
         ary_keys := self.response_content_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || ary_keys(i) || '":' || str_pad || self.response_content(i).toJSON(
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
      IF self.response_links IS NULL 
      OR self.response_links.COUNT = 0
      THEN
         NULL;
         
      ELSE
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('{',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('{',-1);
            
         END IF;
      
         ary_keys := self.response_links_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || ary_keys(i) || '":' || str_pad || self.response_links(i).toJSON(
                  p_pretty_print => p_pretty_print + 2
                )
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
      -- Add the ref
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.value2json(
             '$ref'
            ,'#/components/responses/' || self.response_id
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
      IF self.response_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'description: ' || dz_swagger_util.yaml_text(
                self.response_description
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional variables map
      --------------------------------------------------------------------------
      IF  self.response_headers IS NOT NULL 
      AND self.response_headers.COUNT > 0
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'headers: '
            ,p_pretty_print
            ,'  '
         );
         
         ary_keys := self.response_headers_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '''' || ary_keys(i) || ''': '
               ,p_pretty_print + 1
               ,'  '
            ) || self.response_headers(i).toYAML(
               p_pretty_print + 2
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the optional variables map
      --------------------------------------------------------------------------
      IF  self.response_content IS NOT NULL 
      AND self.response_content.COUNT > 0
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'content: '
            ,p_pretty_print
            ,'  '
         );
         
         ary_keys := self.response_content_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '''' || ary_keys(i) || ''': '
               ,p_pretty_print + 1
               ,'  '
            ) || self.response_content(i).toYAML(
               p_pretty_print + 2
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the optional variables map
      --------------------------------------------------------------------------
      IF  self.response_links IS NOT NULL 
      AND self.response_links.COUNT > 0
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'links: '
            ,p_pretty_print
            ,'  '
         );
         
         ary_keys := self.response_links_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '''' || ary_keys(i) || ''': '
               ,p_pretty_print + 1
               ,'  '
            ) || self.response_links(i).toYAML(
               p_pretty_print + 2
            );
         
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
       p_pretty_print        IN  INTEGER   DEFAULT 0
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
             '#/components/responses/' || self.response_id
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

