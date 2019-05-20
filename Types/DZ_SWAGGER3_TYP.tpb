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
      ,p_shorten_logic       IN  VARCHAR2 DEFAULT NULL
   ) RETURN SELF AS RESULT
   AS
      str_doc_id          VARCHAR2(255 Char) := p_doc_id;
      str_group_id        VARCHAR2(255 Char) := p_group_id;
      str_versionid       VARCHAR2(40 Char)  := p_versionid;
      str_externaldocs_id VARCHAR2(255 Char);

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
      ,CASE
       WHEN a.doc_externaldocs_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id      => a.doc_externaldocs_id
            ,p_object_type_id => 'extrdocstyp'
         )
       ELSE
         NULL
       END 
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
         dz_swagger3_loader.extrdocstyp(
             p_parent_id    => 'root'
            ,p_children_ids => dz_swagger3_object_vry(self.externalDocs)
            ,p_versionid    => str_versionid
         );
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Load the servers
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id      => a.server_id
         ,p_object_type_id => 'servertyp'
         ,p_object_order   => a.server_order
      )
      BULK COLLECT INTO self.servers
      FROM
      dz_swagger3_parent_server_map a
      WHERE
          a.versionid = str_versionid
      AND a.parent_id = str_doc_id;
      
      IF self.servers.COUNT > 0
      THEN
         dz_swagger3_loader.servertyp(
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
         dz_swagger3_object_typ(
             p_object_id      => b.path_id
            ,p_object_type_id => 'pathtyp'
            ,p_object_key     => b.path_endpoint
            ,p_object_order   => a.path_order
         )
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
         a.versionid = str_versionid;
         
      ELSE
         SELECT
         dz_swagger3_object_typ(
             p_object_id      => b.path_id
            ,p_object_type_id => 'pathtyp'
            ,p_object_key     => b.path_endpoint
            ,p_object_order   => a.path_order
         )
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
         AND a.group_id  = str_group_id;
         
      END IF;
      
      IF self.paths.COUNT > 0
      THEN
         dz_swagger3_loader.pathtyp(
             p_parent_id    => 'root'
            ,p_children_ids => self.paths
            ,p_versionid    => str_versionid
         );
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Load the security items
      --------------------------------------------------------------------------

      --------------------------------------------------------------------------
      -- Step 70
      -- Update the object list with reference count and shorty id
      --------------------------------------------------------------------------
      UPDATE dz_swagger3_xobjects a
      SET
       reference_count = (
         SELECT
         COUNT(*)
         FROM
         dz_swagger3_xrelates b
         WHERE
             b.child_object_id      = a.object_id
         AND b.child_object_type_id = a.object_type_id
       )
      ,short_id = 'x' || TO_CHAR(rownum);

      --------------------------------------------------------------------------
      -- Step 80
      -- Return the completed object
      --------------------------------------------------------------------------
      COMMIT;
      
      RETURN;

   END dz_swagger3_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
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
         || '  ,p_short_id       => :p03 '
         || ' ) '
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
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id
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
         || '  ,p_short_id       => :p03 '
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
      IF p_force_inline = 'TRUE'
      THEN
         NULL;

      ELSE
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'components'
               ,self.toJSON_components(
                   p_pretty_print   => p_pretty_print + 1
                  ,p_force_inline   => p_force_inline
                  ,p_short_id       => p_short_id
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
         || '  ,p_short_id       => :p03 '
         || ' ) '
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
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id
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
      EXECUTE IMMEDIATE
         'SELECT '
      || ' a.tagtyp.toJSON( '
      || '   p_pretty_print   => :p01 + 2 '
      || '  ,p_force_inline   => :p02 '
      || '  ,p_short_id       => :p03 '
      || ' ) '
      || 'FROM '
      || 'dz_swagger3_xobjects a '
      || 'WHERE '
      || '    a.object_type_id = ''tagtyp'' '
      || 'AND ( '
      || '      a.tagtyp.tag_description IS NOT NULL '  
      || '   OR a.tagtyp.tag_externaldocs IS NOT NULL '
      || ') '
      || 'ORDER BY a.object_id '
      BULK COLLECT INTO 
      ary_clb
      USING
       p_pretty_print
      ,p_force_inline
      ,p_short_id;
      
      IF  ary_clb IS NOT NULL
      AND ary_clb.COUNT > 0
      THEN  
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
         BEGIN
            EXECUTE IMMEDIATE
               'SELECT '
            || 'a.extrdocstyp.toJSON( '
            || '   p_pretty_print   => :p01 + 1 '
            || '  ,p_force_inline   => :p02 '
            || '  ,p_short_id       => :p03 '
            || ') FROM '
            || 'dz_swagger3_xobjects a '
            || 'WHERE '
            || '    a.object_type_id = :p04 '
            || 'AND a.object_id      = :p05 '
            INTO clb_tmp
            USING 
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.externalDocs.object_type_id
            ,self.externalDocs.object_id; 
         
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_tmp := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;

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
   MEMBER FUNCTION toJSON_components(
       p_pretty_print        IN  INTEGER  DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      clb_hash         CLOB;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      ary_hidden       MDSYS.SDO_STRING2_ARRAY;
      
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
      -- Add schemas map
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
      
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.schematyp.toJSON( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || '  ,p_short_id       => :p03 '
         || ' ) '
         || ',a.object_id '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''schematyp'' '
         || 'AND a.reference_count > 1 '
         || 'AND COALESCE(a.schematyp.property_list_hidden,''FALSE'') <> ''TRUE'' '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id; 
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
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
                    'schemas'
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Add responses map
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
      
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.responsetyp.toJSON( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || '  ,p_short_id       => :p03 '
         || ' ) '
         || ',a.object_id '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''responsetyp'' '
         || 'AND a.reference_count > 1 '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN          
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
                    'responses'
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 50
      -- Add parameters map
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
      
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.parametertyp.toJSON( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || '  ,p_short_id       => :p03 '
         || ' ) '
         || ',a.object_id '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''parametertyp'' '
         || 'AND a.reference_count > 1 '
         || 'AND COALESCE(a.parametertyp.parameter_list_hidden,''FALSE'') <> ''TRUE'' '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         ,ary_hidden
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
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
                    'parameters'
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 60
      -- Add examples map
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
      
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.exampletyp.toJSON( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || '  ,p_short_id       => :p03 '
         || ' ) '
         || ',a.object_id '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''exampletyp'' '
         || 'AND a.reference_count > 1 '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
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
                    'examples'
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 70
      -- Add requestBodies map
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
      
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.requestbodytyp.toJSON( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || '  ,p_short_id       => :p03 '
         || ' ) '
         || ',a.object_id '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''requestbodytyp'' '
         || 'AND a.reference_count > 1 '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id;

         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
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
                    'requestBodies'
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 80
      -- Add headers map
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
      
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.headertyp.toJSON( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || '  ,p_short_id       => :p03 '
         || ' ) '
         || ',a.object_id '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''headertyp'' '
         || 'AND a.reference_count > 1 '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
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
                    'headers'
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 90
      -- Add headers map
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
      
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.securityschemetyp.toJSON( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || '  ,p_short_id       => :p03 '
         || ' ) '
         || ',a.object_id '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''securityschemetyp'' '
         || 'AND a.reference_count > 1 '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
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
                    'securitySchemes'
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 100
      -- Add links map
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
      
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.linktyp.toJSON( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || '  ,p_short_id       => :p03 '
         || ' ) '
         || ',a.object_id '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''linktyp'' '
         || 'AND a.reference_count > 1 '
         || 'ORDER BY a.ordering_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
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
                    'links'
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 110
      -- Add callbacks map
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
      
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.pathtyp.toJSON( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || '  ,p_short_id       => :p03 '
         || ' ) '
         || ',a.object_id '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''pathtyp'' '
         || 'AND a.reference_count > 1 '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
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
                    'callbacks'
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 130
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON_components;

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
         || 'a.servertyp.toYAML( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_initial_indent => ''FALSE'' '
         || '  ,p_final_linefeed => ''FALSE'' '
         || '  ,p_force_inline   => :p02 '
         || '  ,p_short_id       => :p03 '
         || ') '
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
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.servers;
         
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
         || '  ,p_short_id       => :p03 '
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
      IF p_force_inline = 'TRUE'
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
         ) || self.toYAML_components(
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
         || '  ,p_short_id       => :p03 '
         || ' ) '
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
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id
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
      EXECUTE IMMEDIATE
         'SELECT '
      || ' a.tagtyp.toJSON( '
      || '   p_pretty_print   => :p01 + 2 '
      || '  ,p_force_inline   => :p02 '
      || '  ,p_short_id       => :p03 '
      || ' ) '
      || 'FROM '
      || 'dz_swagger3_xobjects a '
      || 'WHERE '
      || '    a.object_type_id = ''tagtyp'' '
      || 'AND ( '
      || '      a.tagtyp.tag_description IS NOT NULL '  
      || '   OR a.tagtyp.tag_externaldocs IS NOT NULL '
      || ') '
      || 'ORDER BY a.object_id '
      BULK COLLECT INTO 
      ary_clb
      USING
       p_pretty_print
      ,p_force_inline
      ,p_short_id;
      
      IF  ary_clb IS NOT NULL
      AND ary_clb.COUNT > 0
      THEN
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
         BEGIN
            EXECUTE IMMEDIATE
               'SELECT '
            || 'a.extrdocstyp.toYAML( '
            || '   p_pretty_print   => :p01 + 1 '
            || '  ,p_force_inline   => :p02 '
            || '  ,p_short_id       => :p03 '
            || ') FROM '
            || 'dz_swagger3_xobjects a '
            || 'WHERE '
            || '    a.object_type_id = :p04 '
            || 'AND a.object_id      = :p05 '
            INTO clb_tmp
            USING 
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.externalDocs.object_type_id
            ,self.externalDocs.object_id;
           
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_tmp := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;
         
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
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML_components(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      ary_hidden       MDSYS.SDO_STRING2_ARRAY;
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------

      --------------------------------------------------------------------------
      -- Step 20
      -- Write the component schemas
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;

      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.schematyp.toYAML( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || '  ,p_short_id       => :p03 '
         || ' ) '
         || ',a.object_id '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''schematyp'' '
         || 'AND a.reference_count > 1 '
         || 'AND COALESCE(a.schematyp.property_list_hidden,''FALSE'') <> ''TRUE'' '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id;

         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN         
            clb_output := clb_output || dz_json_util.pretty_str(
                'schemas: '
               ,p_pretty_print
               ,'  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   dz_swagger3_util.yamlq(
                      ary_keys(i)
                   ) || ': '
                  ,p_pretty_print + 1
                  ,'  '
               ) || ary_clb(i);
            
            END LOOP;
         
         END IF;

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the component responses
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.responsetyp.toYAML( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || '  ,p_short_id       => :p03 '
         || ' ) '
         || ',a.object_id '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''responsetyp'' '
         || 'AND a.reference_count > 1 '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN          
            clb_output := clb_output || dz_json_util.pretty_str(
                'responses: '
               ,p_pretty_print
               ,'  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   dz_swagger3_util.yamlq(
                     ary_keys(i)
                   ) || ': '
                  ,p_pretty_print + 1
                  ,'  '
               ) || ary_clb(i);
            
            END LOOP;
            
         END IF;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the component parameters
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.parametertyp.toYAML( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || '  ,p_short_id       => :p03 '
         || ' ) '
         || ',a.object_id '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''parametertyp'' '
         || 'AND a.reference_count > 1 '
         || 'AND COALESCE(a.parametertyp.parameter_list_hidden,''FALSE'') <> ''TRUE'' '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'parameters: '
               ,p_pretty_print
               ,'  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               IF ary_hidden(i) = 'TRUE'
               THEN
                  NULL;
                  
               ELSE
                  clb_output := clb_output || dz_json_util.pretty(
                      dz_swagger3_util.yamlq(
                        ary_keys(i)
                      ) || ': '
                     ,p_pretty_print + 1
                     ,'  '
                  ) || ary_clb(i);
                  
               END IF;
            
            END LOOP;
            
         END IF;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the component examples
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.exampletyp.toYAML( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || '  ,p_short_id       => :p03 '
         || ' ) '
         || ',a.object_id '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''exampletyp'' '
         || 'AND a.reference_count > 1 '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'examples: '
               ,p_pretty_print
               ,'  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   dz_swagger3_util.yamlq(
                     ary_keys(i)
                   ) || ': '
                  ,p_pretty_print + 1
                  ,'  '
               ) || ary_clb(i);
            
            END LOOP;
            
         END IF;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Write the component requestBodies
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.requestbodytyp.toYAML( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || '  ,p_short_id       => :p03 '
         || ' ) '
         || ',a.object_id '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''requestbodytyp'' '
         || 'AND a.reference_count > 1 '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'requestBodies: '
               ,p_pretty_print
               ,'  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   dz_swagger3_util.yamlq(
                     ary_keys(i)
                   ) || ': '
                  ,p_pretty_print + 1
                  ,'  '
               ) || ary_clb(i);
            
            END LOOP;
            
         END IF;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Write the component headers
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.headertyp.toYAML( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || '  ,p_short_id       => :p03 '
         || ' ) '
         || ',a.object_id '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''headertyp'' '
         || 'AND a.reference_count > 1 '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'headers: '
               ,p_pretty_print
               ,'  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   dz_swagger3_util.yamlq(
                     ary_keys(i)
                   ) || ': '
                  ,p_pretty_print + 1
                  ,'  '
               ) || ary_clb(i);
            
            END LOOP;
            
         END IF;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Write the component securitySchemes
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.securityschemetyp.toYAML( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || '  ,p_short_id       => :p03 '
         || ' ) '
         || ',a.object_id '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''securityschemetyp'' '
         || 'AND a.reference_count > 1 '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'securitySchemes: '
               ,p_pretty_print
               ,'  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   dz_swagger3_util.yamlq(
                     ary_keys(i)
                   ) || ': '
                  ,p_pretty_print + 1
                  ,'  '
               ) || ary_clb(i);
            
            END LOOP;
            
         END IF;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Write the component links
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.linktyp.toYAML( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || '  ,p_short_id       => :p03 '
         || ' ) '
         || ',a.object_id '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''linktyp'' '
         || 'AND a.reference_count > 1 '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'links: '
               ,p_pretty_print
               ,'  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   dz_swagger3_util.yamlq(
                     ary_keys(i)
                   ) || ': '
                  ,p_pretty_print + 1
                  ,'  '
               ) || ary_clb(i);
            
            END LOOP;

         END IF;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Write the component callbacks
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.pathtyp.toYAML( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || '  ,p_short_id       => :p03 '
         || ' ) '
         || ',a.object_id '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''pathtyp'' '
         || 'AND a.reference_count > 1 '
         || 'ORDER BY a.ordering_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'callbacks: '
               ,p_pretty_print
               ,'  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   dz_swagger3_util.yamlq(
                     ary_keys(i)
                   ) || ': '
                  ,p_pretty_print + 1
                  ,'  '
               ) || ary_clb(i);
            
            END LOOP;
            
         END IF;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
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
      
   END toYAML_components;

END;
/

