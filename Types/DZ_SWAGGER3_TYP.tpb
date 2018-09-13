CREATE OR REPLACE TYPE BODY dz_swagger3_typ
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_typ
   RETURN SELF AS RESULT
   AS
   BEGIN
      RETURN;

   END dz_swagger3_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_typ(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2 DEFAULT NULL
      ,p_versionid           IN  VARCHAR2 DEFAULT NULL
   ) RETURN SELF AS RESULT
   AS
      str_doc_id        VARCHAR2(4000 Char) := p_doc_id;
      str_group_id      VARCHAR2(4000 Char) := p_group_id;
      str_versionid     VARCHAR2(40 Char)   := p_versionid;

   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF str_group_id IS NULL
      THEN
         str_group_id := str_doc_id;

      END IF;

      --------------------------------------------------------------------------
      -- Step 20     
      -- Determine the default version if not provided
      --------------------------------------------------------------------------
      IF str_versionid IS NULL
      THEN
         BEGIN
            SELECT
            a.versionid
            INTO str_versionid
            FROM
            dz_swagger3_vers a
            WHERE
                a.is_default = 'TRUE'
            AND rownum <= 1;

         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               RAISE;

         END;

      END IF;

      --------------------------------------------------------------------------
      -- Step 30
      -- Load the info object
      --------------------------------------------------------------------------
      self.info := dz_swagger3_info(
          p_doc_id    => str_doc_id
         ,p_versionid => str_versionid
      );
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Load the servers
      --------------------------------------------------------------------------
      self.servers      := dz_swagger3_server_list();
      self.paths        := dz_swagger3_path_list();
      self.components   := dz_swagger3_components();
      self.security     := dz_swagger3_security_req_list();
      self.tags         := dz_swagger3_tag_list();
      self.externalDocs := NULL;

      RETURN;

   END dz_swagger3_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_typ(
       p_info                IN  dz_swagger3_info
      ,p_servers             IN  dz_swagger3_server_list
      ,p_paths               IN  dz_swagger3_path_list
      ,p_components          IN  dz_swagger3_components
      ,p_security            IN  dz_swagger3_security_req_list
      ,p_tags                IN  dz_swagger3_tag_list
      ,p_externalDocs        IN  dz_swagger3_extrdocs_typ
   ) RETURN SELF AS RESULT
   AS

   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------

      --------------------------------------------------------------------------
      -- Step 20
      -- Load the object
      --------------------------------------------------------------------------
      self.info                := p_info;
      self.servers             := p_servers;
      self.paths               := p_paths;
      self.components          := p_components;
      self.security            := p_security;
      self.tags                := p_tags;
      self.externalDocs        := p_externalDocs;

      RETURN;      

   END dz_swagger3_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION paths_keys
   RETURN MDSYS.SDO_STRING2_ARRAY
   AS
      int_index  PLS_INTEGER;
      ary_output MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
      IF self.paths IS NULL
      OR self.paths.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := MDSYS.SDO_STRING2_ARRAY();
      FOR i IN 1 .. self.paths.COUNT
      LOOP
         ary_output(int_index) := self.paths(i).hash_key;
      
      END LOOP;
      
      RETURN ary_output;
   
   END paths_keys;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
      p_pretty_print      IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
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
      -- Add the left bracket
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output := dz_json_util.pretty('{',NULL);
         str_pad := '';

      ELSE
         clb_output := dz_json_util.pretty('{',-1);
         str_pad := ' ';

      END IF;
      
      str_pad1 := str_pad;

      --------------------------------------------------------------------------
      -- Step 30
      -- Add base attributes
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.value2json(
             'openapi'
            ,dz_swagger3_constants.c_openapi_version
            ,p_pretty_print + 1
         )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';

      --------------------------------------------------------------------------
      -- Step 40
      -- Add info object
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.formatted2json(
              'info'
             ,self.info.toJSON(p_pretty_print + 1)
             ,p_pretty_print + 1
          )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add servers
      --------------------------------------------------------------------------
      IF self.servers IS NULL 
      OR self.servers.COUNT = 0
      THEN
         clb_hash := 'null';
         
      ELSE
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('[',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('[',-1);
            
         END IF;
      
         FOR i IN 1 .. servers.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || self.servers(i).toJSON(
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
         
      END IF;
         
      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.formatted2json(
              'servers'
             ,clb_hash
             ,p_pretty_print + 1
          )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add paths
      --------------------------------------------------------------------------
      IF self.paths IS NULL 
      OR self.paths.COUNT = 0
      THEN
         clb_hash := 'null';
         
      ELSE
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('{',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('{',-1);
            
         END IF;

         ary_keys := self.paths_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || dz_json_main.value2json(
                   ary_keys(i)
                  ,self.paths(i).toJSON(
                     p_pretty_print => p_pretty_print + 1
                   )
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad2 := ',';
         
         END LOOP;
         
         clb_hash := clb_hash || dz_json_util.pretty(
             '}'
            ,p_pretty_print + 1,NULL,NULL
         );
         
      END IF;
         
      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.formatted2json(
              'paths'
             ,clb_hash
             ,p_pretty_print + 1
          )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Add get operation
      --------------------------------------------------------------------------
      IF self.components IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'components'
               ,self.components.toJSON(p_pretty_print + 1)
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;

      --------------------------------------------------------------------------
      -- Step 80
      -- Add security
      --------------------------------------------------------------------------
      IF self.security IS NULL 
      OR self.security.COUNT = 0
      THEN
         clb_hash := 'null';
         
      ELSE
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('[',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('[',-1);
            
         END IF;
      
         FOR i IN 1 .. security.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || self.security(i).toJSON(
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
         
      END IF;
         
      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.formatted2json(
              'security'
             ,clb_hash
             ,p_pretty_print + 1
          )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';

      --------------------------------------------------------------------------
      -- Step 90
      -- Add tags
      --------------------------------------------------------------------------
      IF self.tags IS NULL 
      OR self.tags.COUNT = 0
      THEN
         clb_hash := 'null';
         
      ELSE
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('[',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('[',-1);
            
         END IF;
      
         FOR i IN 1 .. tags.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || self.tags(i).toJSON(
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
         
      END IF;
         
      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.formatted2json(
              'tags'
             ,clb_hash
             ,p_pretty_print + 1
          )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Add externalDocs
      --------------------------------------------------------------------------
      IF self.externalDocs IS NULL
      THEN
         clb_hash := 'null';
         
      ELSE
         clb_hash := self.externalDocs.toJSON(p_pretty_print + 1);

      END IF;
      
      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.formatted2json(
             'externalDocs'
            ,clb_hash
            ,p_pretty_print + 1
         )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );

      --------------------------------------------------------------------------
      -- Step 120
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toJSON;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
      p_pretty_print        IN  INTEGER DEFAULT 0
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
      -- Write the yaml
      --------------------------------------------------------------------------
      clb_output := dz_json_util.pretty_str(
          '---'
         ,p_pretty_print
         ,'  '
      ) || dz_json_util.pretty_str(
          'openapi: ' || dz_swagger3_util.yaml_text(
             dz_swagger3_constants.c_openapi_version
            ,p_pretty_print
          )
         ,p_pretty_print
         ,'  '
      );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the info object
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty_str(
          'info: '
         ,p_pretty_print
         ,'  '
      ) || self.info.toYAML(p_pretty_print + 1);

      --------------------------------------------------------------------------
      -- Step 40
      -- Write the server array
      --------------------------------------------------------------------------
      IF self.servers IS NULL 
      OR self.servers.COUNT = 0
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'servers: null'
            ,p_pretty_print + 1
            ,'  '
         );
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'servers: '
            ,p_pretty_print + 1
            ,'  '
         );
         
         FOR i IN 1 .. self.servers.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '- '
               ,p_pretty_print + 1
               ,'  '
            ) || self.servers(i).toYAML(
               p_pretty_print + 1
            );
            
         END LOOP;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 50
      -- Do the paths
      --------------------------------------------------------------------------
      IF self.paths IS NULL 
      OR self.paths.COUNT = 0
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'paths: null'
            ,p_pretty_print
            ,'  '
         );
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'paths: '
            ,p_pretty_print
            ,'  '
         );

         ary_keys := self.paths_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty_str(
                '"' || self.paths(i).hash_key || '": '
               ,p_pretty_print + 1
               ,'  '
            ) || self.paths(i).toYAML(p_pretty_print + 2);

         END LOOP;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 60
      -- Write the components operation
      --------------------------------------------------------------------------
      IF self.components IS NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'components: null'
            ,p_pretty_print
            ,'  '
         );
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'components: ' 
            ,p_pretty_print
            ,'  '
         ) || self.components.toYAML(
            p_pretty_print + 1
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Write the security array
      --------------------------------------------------------------------------
      IF self.security IS NULL 
      OR self.security.COUNT = 0
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'security: null'
            ,p_pretty_print
            ,'  '
         );
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'security: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. self.security.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '- '
               ,p_pretty_print + 1
               ,'  '
            ) || self.security(i).toYAML(
               p_pretty_print + 2
            );
            
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Write the tags array
      --------------------------------------------------------------------------
      IF self.tags IS NULL 
      OR self.tags.COUNT = 0
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'tags: null'
            ,p_pretty_print
            ,'  '
         );
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'tags: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. self.tags.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '- '
               ,p_pretty_print + 1
               ,'  '
            ) || self.tags(i).toYAML(
               p_pretty_print + 2
            );
            
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Write the externalDocs
      --------------------------------------------------------------------------
      IF self.externalDocs IS NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'externalDocs: null'
            ,p_pretty_print
            ,'  '
         );
      
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'externalDocs: ' 
            ,p_pretty_print
            ,'  '
         ) || self.externalDocs.toYAML(
            p_pretty_print + 1
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toYAML;

END;
/
