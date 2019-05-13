CREATE OR REPLACE TYPE BODY dz_swagger3_typ
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_typ
   RETURN SELF AS RESULT
   AS
   BEGIN
      dz_swagger3_main.purge_component();
      RETURN;

   END dz_swagger3_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_typ(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2 DEFAULT NULL
      ,p_versionid           IN  VARCHAR2 DEFAULT NULL
      ,p_shorten_logic       IN  VARCHAR2 DEFAULT NULL
   ) RETURN SELF AS RESULT
   AS
      str_doc_id          VARCHAR2(255 Char) := p_doc_id;
      str_group_id        VARCHAR2(255 Char) := p_group_id;
      str_versionid       VARCHAR2(40 Char)  := p_versionid;
      str_externaldocs_id VARCHAR2(255 Char);
      ary_parameters      dz_swagger3_parameter_list;
      ary_responses       dz_swagger3_response_list;
      ary_requestbodies   dz_swagger3_requestBody_list;
      --ary_schemas         dz_swagger3_schema_list;
      ary_tags            dz_swagger3_tag_list;

   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      dz_swagger3_main.purge_xtemp();

      --------------------------------------------------------------------------
      -- Step 20     
      -- Determine the default version if not provided
      --------------------------------------------------------------------------
      dz_swagger3_main.startup_defaults(
          p_doc_id        => p_doc_id
         ,p_group_id      => p_group_id
         ,p_versionid     => p_versionid
         ,out_doc_id      => str_doc_id
         ,out_group_id    => str_group_id
         ,out_versionid   => str_versionid
      );

      --------------------------------------------------------------------------
      -- Step 30
      -- Load the info object and externalDocs object
      --------------------------------------------------------------------------
      SELECT
       dz_swagger3_info_typ(
          p_info_title          => a.info_title
         ,p_info_description    => a.info_description
         ,p_info_termsofservice => a.info_termsofservice
         ,p_info_contact        => dz_swagger3_info_contact_typ(
             p_contact_name  => a.info_contact_name
            ,p_contact_url   => a.info_contact_url
            ,p_contact_email => a.info_contact_email
          )
         ,p_info_license        => dz_swagger3_info_license_typ(
             p_license_name  => a.info_license_name
            ,p_license_url   => a.info_license_url
          )
         ,p_info_version        => a.info_version
       )
      ,a.doc_externaldocs_id
      INTO 
       self.info
      ,self.externalDocs
      FROM
      dz_swagger3_doc a
      WHERE
          a.versionid  = str_versionid
      AND a.doc_id     = str_doc_id;
      
      IF self.externalDocs IS NOT NULL
      THEN
         dz_swagger3_extrdocs_typ.loader(
             p_parent_id    => 'root'
            ,p_children_ids => MDSYS.SDO_STRING2_ARRAY(self.externalDocs)
            ,p_versionid    => str_versionid
         );
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Load the servers
      --------------------------------------------------------------------------
      SELECT
      a.server_id
      BULK COLLECT INTO self.servers
      FROM
      dz_swagger3_parent_server_map a
      WHERE
          a.versionid = str_versionid
      AND a.parent_id = str_doc_id;
      
      IF self.servers.COUNT > 0
      THEN
         dz_swagger3_server_typ.loader(
             p_parent_id    => 'root'
            ,p_children_ids => self.servers
            ,p_versionid    => str_versionid
         );
         
      END IF;


      --------------------------------------------------------------------------
      -- Step 50
      -- Load the paths account for MOA
      --------------------------------------------------------------------------
      IF str_group_id = 'MOA'
      THEN
         SELECT
         b.path_id
         BULK COLLECT INTO self.paths
         FROM (
            SELECT
             aa.path_id
            ,MAX(aa.path_order) AS path_order
            ,aa.versionid
            FROM
            dz_swagger3_group aa
            WHERE
            aa.versionid = str_versionid
            GROUP BY
             aa.path_id
            ,aa.versionid
         ) a
         JOIN
         dz_swagger3_path b
         ON
             a.versionid = b.versionid
         AND a.path_id   = b.path_id
         WHERE
         a.versionid = str_versionid
         ORDER BY
          a.path_order
         ,b.path_endpoint;
         
      ELSE
         SELECT
         b.path_id
         BULK COLLECT INTO self.paths
         FROM
         dz_swagger3_group a
         JOIN
         dz_swagger3_path b
         ON
             a.versionid = b.versionid
         AND a.path_id   = b.path_id
         WHERE
             a.versionid = str_versionid
         AND a.group_id  = str_group_id
         ORDER BY
          a.path_order
         ,b.path_endpoint;
         
      END IF;
      
      IF self.paths.COUNT > 0
      THEN
         dz_swagger3_path_typ.loader(
             p_parent_id    => 'root'
            ,p_children_ids => self.paths
            ,p_versionid    => str_versionid
         );
      
      END IF;
/* raise_application_error(-20001,'check');
      --------------------------------------------------------------------------
      -- Step 60
      -- Load the components in sorted by id order
      --------------------------------------------------------------------------
      self.components := dz_swagger3_components_typ(
         p_versionid  => str_versionid
      );

      --------------------------------------------------------------------------
      -- Step 70
      -- Load the security
      --------------------------------------------------------------------------
      self.security := dz_swagger3_security_req_list();
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Load the tags
      --------------------------------------------------------------------------
      SELECT 
      dz_swagger3_tag_typ(
          p_tag_id            => b.tag_id
         ,p_tag_name          => b.tag_name
         ,p_tag_description   => c.tag_description
         ,p_tag_externalDocs  => dz_swagger3_extrdocs_typ(
             p_externaldoc_id      => c.tag_externaldocs_id
            ,p_versionid           => str_versionid
          )
         ,p_load_components   => 'FALSE'
      )
      BULK COLLECT INTO self.tags
      FROM
      dz_swagger3_components a
      JOIN
      dz_swagger3_operation_tag_map b
      ON
      a.object_id = b.tag_id
      JOIN
      dz_swagger3_tag c
      ON
          b.versionid = c.versionid
      AND b.tag_id    = c.tag_id
      WHERE
          a.object_type = 'tag'
      AND b.versionid = str_versionid
      AND c.versionid = str_versionid
      ORDER BY
      a.object_id;

      --------------------------------------------------------------------------
      -- Step 90
      -- Update components with shortened names
      --------------------------------------------------------------------------
      dz_swagger3_main.add_short_names(
         p_shorten_logic => p_shorten_logic
      );
*/
      --------------------------------------------------------------------------
      -- Step 100
      -- Return the completed object
      --------------------------------------------------------------------------
      commit;
      RETURN;

   END dz_swagger3_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_typ(
       p_info                IN  dz_swagger3_info_typ
      ,p_servers             IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_server_list
      ,p_paths               IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_path_list
      ,p_components          IN  dz_swagger3_components_typ
      ,p_security            IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_security_req_list
      ,p_tags                IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_tag_list
      ,p_externalDocs        IN  VARCHAR2 --dz_swagger3_extrdocs_typ
   ) RETURN SELF AS RESULT
   AS

   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
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
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_hash         CLOB;
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
      -- Add the left bracket
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
             ,self.info.toJSON(
                p_pretty_print   => p_pretty_print + 1
               ,p_force_inline   => p_force_inline
             )
             ,p_pretty_print + 1
          )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';

      --------------------------------------------------------------------------
      -- Step 50
      -- Add servers
      --------------------------------------------------------------------------
      IF  self.servers IS NOT NULL 
      AND self.servers.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.servertyp.toJSON( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || ' ) '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''servertyp'' '
         || 'AND a.object_id IN (SELECT column_value FROM TABLE(:p03)) '
         || 'ORDER BY a.ordering_key '
         BULK COLLECT INTO 
         ary_clb
         USING
          p_pretty_print
         ,p_force_inline
         ,self.servers;
         
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('[',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('[',-1);
            
         END IF;
      
         FOR i IN 1 .. ary_clb.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || ary_clb(i)
               ,p_pretty_print + 2
            );
            str_pad2 := ',';
         
         END LOOP;
         
         clb_hash := clb_hash || dz_json_util.pretty(
             ']'
            ,p_pretty_print + 1,NULL,NULL
         );
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                 'servers'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
  
      --------------------------------------------------------------------------
      -- Step 60
      -- Add paths
      --------------------------------------------------------------------------
      IF  self.paths IS NOT NULL 
      AND self.paths.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.pathtyp.toJSON( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || ' ) '
         || ',a.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''pathtyp'' '
         || 'AND a.object_id IN (SELECT column_value FROM TABLE(:p03)) '
         || 'ORDER BY a.ordering_key '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,self.paths;
         
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
                 'paths'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 70
      -- Add components subobject
      --------------------------------------------------------------------------
      IF self.components IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'components'
               ,self.components.toJSON(
                   p_pretty_print   => p_pretty_print + 1
                  ,p_force_inline   => p_force_inline
               )
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
      IF  self.security IS NOT NULL 
      AND self.security.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.securitytyp.toJSON( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || ' ) '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''securitytyp'' '
         || 'AND a.object_id IN (SELECT column_value FROM TABLE(:p03)) '
         || 'ORDER BY a.ordering_key '
         BULK COLLECT INTO 
         ary_clb
         USING
          p_pretty_print
         ,p_force_inline
         ,self.security;
         
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('[',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('[',-1);
            
         END IF;
      
         FOR i IN 1 .. ary_clb.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || ary_clb(i)
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
                 'security'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 90
      -- Add tags
      --------------------------------------------------------------------------
      IF  self.tags IS NOT NULL 
      AND self.tags.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.tagtyp.toJSON( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || ' ) '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''tagtyp'' '
         || 'AND a.object_id IN (SELECT column_value FROM TABLE(:p03)) '
         || 'ORDER BY a.ordering_key '
         BULK COLLECT INTO 
         ary_clb
         USING
          p_pretty_print
         ,p_force_inline
         ,self.tags;
         
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('[',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('[',-1);
            
         END IF;
      
         FOR i IN 1 .. ary_clb.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || ary_clb(i)
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
                 'tags'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 100
      -- Add externalDocs
      --------------------------------------------------------------------------
      IF self.externalDocs IS NOT NULL
      THEN
         EXECUTE IMMEDIATE
            'SELECT a.extrdocstyp.toJSON( '
         || '   p_pretty_print   => :p01 + 1 '
         || '  ,p_force_inline   => :p02 '
         || ') FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''extrdocstyp'' '
         || 'AND a.object_id = :p03 '
         INTO clb_tmp
         USING 
          p_pretty_print
         ,p_force_inline
         ,self.externalDocs; 

         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'externalDocs'
               ,clb_tmp
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;

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
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
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
      IF self.info IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'info: '
            ,p_pretty_print
            ,'  '
         ) || self.info.toYAML(
             p_pretty_print   => p_pretty_print + 1
            ,p_force_inline   => p_force_inline
         );
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Write the server array
      --------------------------------------------------------------------------
      IF  self.servers IS NOT NULL 
      AND self.servers.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.servertyp.toYAML( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_initial_indent => ''FALSE'' '
         || '  ,p_final_linefeed => ''FALSE'' '
         || '  ,p_force_inline   => :p02 '
         || ' ) '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''servertyp'' '
         || 'AND a.object_id IN (SELECT column_value FROM TABLE(:p03)) '
         || 'ORDER BY a.ordering_key '
         BULK COLLECT INTO 
         ary_clb
         USING
          p_pretty_print
         ,p_force_inline
         ,self.tags;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'servers: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. ary_clb.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '- ' || ary_clb(i)
               ,p_pretty_print + 1
               ,'  '
            );
            
         END LOOP;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 50
      -- Do the paths
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty_str(
          'paths: '
         ,p_pretty_print
         ,'  '
      );
      
      IF  self.paths IS NOT NULL 
      AND self.paths.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.pathtyp.toYAML( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || ' ) '
         || ',a.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''pathtyp'' '
         || 'AND a.object_id IN (SELECT column_value FROM TABLE(:p03)) '
         || 'ORDER BY a.ordering_key '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,self.paths;
         
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty_str(
                dz_swagger3_util.yamlq(ary_keys(i)) || ': '
               ,p_pretty_print + 1
               ,'  '
            ) || ary_clb(i);

         END LOOP;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 60
      -- Write the components operation
      --------------------------------------------------------------------------
      IF self.components IS NULL
      OR self.components.isNULL() = 'TRUE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'components: {}' 
            ,p_pretty_print
            ,'  '
         );
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'components: ' 
            ,p_pretty_print
            ,'  '
         ) || self.components.toYAML(
             p_pretty_print   => p_pretty_print + 1
            ,p_force_inline   => p_force_inline
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Write the security array
      --------------------------------------------------------------------------
      IF  self.security IS NOT NULL 
      AND self.security.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.securitytyp.toYAML( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || ' ) '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''securitytyp'' '
         || 'AND a.object_id IN (SELECT column_value FROM TABLE(:p03)) '
         || 'ORDER BY a.ordering_key '
         BULK COLLECT INTO 
         ary_clb
         USING
          p_pretty_print
         ,p_force_inline
         ,self.security;

         clb_output := clb_output || dz_json_util.pretty_str(
             'security: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. ary_clb.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '- '
               ,p_pretty_print + 1
               ,'  '
            ) || ary_clb(i);
            
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Write the tags array
      --------------------------------------------------------------------------
      IF  self.tags IS NOT NULL 
      AND self.tags.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.tagtyp.toYAML( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || ' ) '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''tagtyp'' '
         || 'AND a.object_id IN (SELECT column_value FROM TABLE(:p03)) '
         || 'ORDER BY a.ordering_key '
         BULK COLLECT INTO 
         ary_clb
         USING
          p_pretty_print
         ,p_force_inline
         ,self.tags;

         clb_output := clb_output || dz_json_util.pretty_str(
             'tags: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. ary_clb.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '- '
               ,p_pretty_print + 1
               ,'  '
            ) || ary_clb(i);
            
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Write the externalDocs
      --------------------------------------------------------------------------
      IF self.externalDocs IS NOT NULL
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || 'a.extrdocstyp.toYAML( '
         || '   p_pretty_print   => :p01 + 1 '
         || '  ,p_force_inline   => :p02 '
         || ') FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''extrdocstyp'' '
         || 'AND a.object_id = :p03 '
         INTO clb_tmp
         USING 
          p_pretty_print
         ,p_force_inline
         ,self.externalDocs;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'externalDocs: ' 
            ,p_pretty_print
            ,'  '
         ) || clb_tmp;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
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

END;
/

