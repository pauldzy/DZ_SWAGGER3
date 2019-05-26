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
      cb            CLOB;
      v2            VARCHAR2(32000);
      
      str_pad       VARCHAR2(1 Char);
      str_pad1      VARCHAR2(1 Char);
      str_pad2      VARCHAR2(1 Char);
      str_pad3      VARCHAR2(1 Char);
      clb_tmp       CLOB;
      ary_keys      MDSYS.SDO_STRING2_ARRAY;
      
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
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => dz_json_util.pretty('{',NULL)
         );

      ELSE
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => dz_json_util.pretty('{',-1)
         );
         str_pad     := ' ';

      END IF;
      
      str_pad1 := str_pad;

      --------------------------------------------------------------------------
      -- Step 30
      -- Add base attributes
      --------------------------------------------------------------------------
      dz_swagger3_util.conc(
          p_c    => cb
         ,p_v    => v2
         ,p_in_c => NULL
         ,p_in_v => dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'openapi'
               ,dz_swagger3_constants.c_openapi_version
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         )
      );
      str_pad1 := ',';

      --------------------------------------------------------------------------
      -- Step 40
      -- Add info object
      --------------------------------------------------------------------------
      dz_swagger3_util.conc(
          p_c    => cb
         ,p_v    => v2
         ,p_in_c => dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                 'info'
                ,self.info.toJSON(
                   p_pretty_print   => p_pretty_print + 1
                  ,p_force_inline   => p_force_inline
                )
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
          )
         ,p_in_v => NULL
      );
      str_pad1 := ',';

      --------------------------------------------------------------------------
      -- Step 50
      -- Add servers
      --------------------------------------------------------------------------
      IF  self.servers IS NOT NULL 
      AND self.servers.COUNT > 0
      THEN
         SELECT 
         a.servertyp.toJSON(
             p_pretty_print   => p_pretty_print + 2 
            ,p_force_inline   => p_force_inline
            ,p_short_id       => p_short_id
         )
         BULK COLLECT INTO ary_clb
         FROM
         dz_swagger3_xobjects a 
         JOIN 
         TABLE(self.servers) b 
         ON 
             a.object_type_id = b.object_type_id 
         AND a.object_id      = b.object_id 
         ORDER BY b.object_order;
         
         IF ary_clb IS NULL
         OR ary_clb.COUNT = 0
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty(
                   str_pad1 || '"servers":' || str_pad || 'null'
                  ,p_pretty_print + 1
                )
            );
            str_pad1 := ',';
         
         ELSE        
            str_pad2 := str_pad;
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty(str_pad1 || '"servers":' || str_pad || '[',p_pretty_print + 1)
            );
               
            FOR i IN 1 .. ary_clb.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => dz_json_util.pretty(
                      str_pad2 || ary_clb(i)
                     ,p_pretty_print + 2
                  )
                  ,p_in_v => NULL
               );
               str_pad2 := ',';
            
            END LOOP;
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty(
                   ']'
                  ,p_pretty_print + 1
               )
            );
            
            str_pad1 := ',';
            
         END IF;
         
      END IF;
  
      --------------------------------------------------------------------------
      -- Step 60
      -- Add paths
      --------------------------------------------------------------------------
      IF self.paths IS NULL 
      OR self.paths.COUNT = 0
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => dz_json_util.pretty(
                str_pad1 || '"paths":' || str_pad || '{}'
               ,p_pretty_print + 1
             )
         );
         str_pad1 := ',';

      ELSE
         SELECT
          a.pathtyp.toJSON(
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
         TABLE(self.paths) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id
         ORDER BY b.object_order;
         
         IF ary_clb IS NULL
         OR ary_clb.COUNT = 0
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty(
                   str_pad1 || '"paths":' || str_pad || 'null'
                  ,p_pretty_print + 1
                )
            );
            str_pad1 := ',';
         
         ELSE         
            str_pad2 := str_pad;
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty(str_pad1 || '"paths":' || str_pad || '{',p_pretty_print + 1)
            );

            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => dz_json_util.pretty(
                      str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                     ,p_pretty_print + 2
                  )
                  ,p_in_v => NULL
               );
               str_pad2 := ',';
            
            END LOOP;
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty(
                   '}'
                  ,p_pretty_print + 1
               )
            );
            
            str_pad1 := ',';
            
         END IF;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 70
      -- Add components subobject
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      OR self.paths IS NULL
      OR self.paths.COUNT = 0
      THEN
         NULL;

      ELSE
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => dz_json_util.pretty(str_pad1 || '"components":' || str_pad || '{',p_pretty_print + 1)
         );
         
         str_pad2 := str_pad;      

      --------------------------------------------------------------------------
      -- Step 80
      -- Add schemas components map
      --------------------------------------------------------------------------
         SELECT 
          a.schematyp.toJSON( 
             p_pretty_print   => p_pretty_print + 3 
            ,p_force_inline   => 'FALSE'
            ,p_short_id       => p_short_id
          ) 
         ,CASE 
          WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
          THEN 
            a.short_id 
          ELSE 
            a.object_id 
          END 
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         FROM 
         dz_swagger3_xobjects a 
         WHERE 
             a.object_type_id = 'schematyp'
         AND a.reference_count > 1 
         AND COALESCE(a.schematyp.property_list_hidden,'FALSE') <> 'TRUE'
         ORDER BY a.object_id; 
            
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty(str_pad2 || '"schemas":' || str_pad || '{',p_pretty_print + 2)
            );
            
            str_pad3 := str_pad;
         
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => dz_json_util.pretty(
                      str_pad3 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                     ,p_pretty_print + 3
                  )
                  ,p_in_v => NULL
               );
               str_pad3 := ',';
            
            END LOOP;
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty(
                   '}'
                  ,p_pretty_print + 2
               )
            );
            
            str_pad2 := ',';
            
         END IF;

      --------------------------------------------------------------------------
      -- Step 90
      -- Add responses components map
      --------------------------------------------------------------------------
         SELECT
          a.responsetyp.toJSON(
             p_pretty_print   => p_pretty_print + 3
            ,p_force_inline   => 'FALSE'
            ,p_short_id       => p_short_id
          )
         ,CASE 
          WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
          THEN
            a.short_id
          ELSE
            a.object_id
          END
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         FROM
         dz_swagger3_xobjects a
         WHERE 
             a.object_type_id = 'responsetyp'
         AND a.reference_count > 1 
         ORDER BY a.object_id;
            
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN          
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty(str_pad2 || '"responses":' || str_pad || '{',p_pretty_print + 2)
            );
            
            str_pad3 := str_pad;
         
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => dz_json_util.pretty(
                      str_pad3 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                     ,p_pretty_print + 3
                  )
                  ,p_in_v => NULL
               );
               str_pad3 := ',';
            
            END LOOP;
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty(
                   '}'
                  ,p_pretty_print + 2
               )
            );
            
            str_pad2 := ',';
            
         END IF;
         
      --------------------------------------------------------------------------
      -- Step 100
      -- Add parameters components map
      --------------------------------------------------------------------------
         SELECT
          a.parametertyp.toJSON(
             p_pretty_print   => p_pretty_print + 3
            ,p_force_inline   => 'FALSE'
            ,p_short_id       => p_short_id
          )
         ,CASE
          WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
          THEN
            a.short_id
          ELSE
            a.object_id
          END
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'parametertyp'
         AND a.reference_count > 1
         AND COALESCE(a.parametertyp.parameter_list_hidden,'FALSE') <> 'TRUE'
         ORDER BY a.object_id;
            
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty(str_pad2 || '"parameters":' || str_pad || '{',p_pretty_print + 2)
            );
            
            str_pad3 := str_pad;
         
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => dz_json_util.pretty(
                      str_pad3 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                     ,p_pretty_print + 3
                  )
                  ,p_in_v => NULL
               );
               str_pad3 := ',';
            
            END LOOP;
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty(
                   '}'
                  ,p_pretty_print + 2
               )
            );
            
            str_pad2 := ',';
               
         END IF;
         
      --------------------------------------------------------------------------
      -- Step 110
      -- Add examples components map
      --------------------------------------------------------------------------
         SELECT
          a.exampletyp.toJSON( 
             p_pretty_print   => p_pretty_print + 3
            ,p_force_inline   => 'FALSE'
            ,p_short_id       => p_short_id
          )
         ,CASE
          WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
          THEN
            a.short_id
          ELSE
            a.object_id
          END
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'exampletyp'
         AND a.reference_count > 1
         ORDER BY a.object_id;
            
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty(str_pad2 || '"examples":' || str_pad || '{',p_pretty_print + 2)
            );
            
            str_pad3 := str_pad;
         
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => dz_json_util.pretty(
                      str_pad3 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                     ,p_pretty_print + 3
                  )
                  ,p_in_v => NULL
               );
               str_pad3 := ',';
            
            END LOOP;
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty(
                   '}'
                  ,p_pretty_print + 2
               )
            );
            
            str_pad2 := ',';
            
         END IF;
         
      --------------------------------------------------------------------------
      -- Step 120
      -- Add requestBodies components map
      --------------------------------------------------------------------------
         SELECT
          a.requestbodytyp.toJSON(
             p_pretty_print   => p_pretty_print + 3
            ,p_force_inline   => 'FALSE'
            ,p_short_id       => p_short_id
          )
         ,CASE
          WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
          THEN
            a.short_id
          ELSE
            a.object_id
          END
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'requestbodytyp'
         AND a.reference_count > 1
         ORDER BY a.object_id;

         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty(str_pad2 || '"requestBodies":' || str_pad || '{',p_pretty_print + 2)
            );
            
            str_pad3 := str_pad;
         
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => dz_json_util.pretty(
                      str_pad3 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                     ,p_pretty_print + 3
                  )
                  ,p_in_v => NULL
               );
               str_pad3 := ',';
            
            END LOOP;
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty(
                   '}'
                  ,p_pretty_print + 2
               )
            );
            
            str_pad2 := ',';
               
         END IF;
         
      --------------------------------------------------------------------------
      -- Step 130
      -- Add headers components map
      --------------------------------------------------------------------------
         SELECT
          a.headertyp.toJSON(
             p_pretty_print   => p_pretty_print + 3
            ,p_force_inline   => 'FALSE'
            ,p_short_id       => p_short_id
          )
         ,CASE
          WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
          THEN
            a.short_id
          ELSE
            a.object_id
          END
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'headertyp'
         AND a.reference_count > 1
         ORDER BY a.object_id;
            
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty(str_pad2 || '"headers":' || str_pad || '{',p_pretty_print + 2)
            );
            
            str_pad3 := str_pad;
         
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => dz_json_util.pretty(
                      str_pad3 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                     ,p_pretty_print + 3
                  )
                  ,p_in_v => NULL
               );
               str_pad3 := ',';
            
            END LOOP;
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty(
                   '}'
                  ,p_pretty_print + 2
               )
            );
            
            str_pad2 := ',';
             
         END IF;
         
      --------------------------------------------------------------------------
      -- Step 140
      -- Add security scheme components map
      --------------------------------------------------------------------------
         SELECT
          a.securityschemetyp.toJSON(
             p_pretty_print   => p_pretty_print + 3
            ,p_force_inline   => 'FALSE'
            ,p_short_id       => p_short_id
          )
         ,CASE
          WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
          THEN
            a.short_id
          ELSE
            a.object_id
          END
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'securityschemetyp'
         AND a.reference_count > 1
         ORDER BY a.object_id;
            
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty(str_pad2 || '"securitySchemes":' || str_pad || '{',p_pretty_print + 2)
            );
            
            str_pad3 := str_pad;
         
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => dz_json_util.pretty(
                      str_pad3 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                     ,p_pretty_print + 3
                  )
                  ,p_in_v => NULL
               );
               str_pad3 := ',';
            
            END LOOP;
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty(
                   '}'
                  ,p_pretty_print + 2
               )
            );
            
            str_pad2 := ',';
               
         END IF;
         
      --------------------------------------------------------------------------
      -- Step 150
      -- Add links components map
      --------------------------------------------------------------------------
         SELECT
          a.linktyp.toJSON(
             p_pretty_print   => p_pretty_print + 3
            ,p_force_inline   => 'FALSE'
            ,p_short_id       => p_short_id
          )
         ,CASE
          WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
          THEN
            a.short_id
          ELSE
            a.object_id
          END
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'linktyp'
         AND a.reference_count > 1
         ORDER BY a.object_id;
            
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty(str_pad2 || '"links":' || str_pad || '{',p_pretty_print + 2)
            );
            
            str_pad3 := str_pad;
         
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => dz_json_util.pretty(
                      str_pad3 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                     ,p_pretty_print + 3
                  )
                  ,p_in_v => NULL
               );
               str_pad3 := ',';
            
            END LOOP;
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty(
                   '}'
                  ,p_pretty_print + 2
               )
            );
            
            str_pad2 := ',';
               
         END IF;
         
      --------------------------------------------------------------------------
      -- Step 160
      -- Add callbacks components map
      --------------------------------------------------------------------------
         SELECT
          a.pathtyp.toJSON(
             p_pretty_print   => p_pretty_print + 3
            ,p_force_inline   => 'FALSE'
            ,p_short_id       => p_short_id
          )
         ,CASE
          WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
          THEN
            a.short_id
          ELSE
            a.object_id
          END
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'callbacktyp'
         AND a.reference_count > 1
         ORDER BY a.object_id;
            
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty(str_pad2 || '"callbacks":' || str_pad || '{',p_pretty_print + 2)
            );
            
            str_pad3 := str_pad;
         
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => dz_json_util.pretty(
                      str_pad3 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                     ,p_pretty_print + 3
                  )
                  ,p_in_v => NULL
               );
               str_pad3 := ',';
            
            END LOOP;
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty(
                   '}'
                  ,p_pretty_print + 2
               )
            );
            
            str_pad2 := ',';
               
         END IF;
         
      --------------------------------------------------------------------------
      -- Step 170
      -- Close out the components
      --------------------------------------------------------------------------  
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => dz_json_util.pretty(
                '}'
               ,p_pretty_print + 1
            )
         );
            
         str_pad1 := ',';
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 180
      -- Add security
      --------------------------------------------------------------------------
      IF  self.security IS NOT NULL 
      AND self.security.COUNT > 0
      THEN
         SELECT 
         a.securityreqtyp.toJSON( 
            p_pretty_print   => p_pretty_print + 2 
           ,p_force_inline   => p_force_inline 
           ,p_short_id       => p_short_id
         ) 
         BULK COLLECT INTO ary_clb
         FROM 
         dz_swagger3_xobjects a 
         JOIN 
         TABLE(self.security) b 
         ON 
             a.object_type_id = b.object_type_id 
         AND a.object_id      = b.object_id 
         ORDER BY b.object_order;
         
         IF  ary_clb IS NOT NULL
         AND ary_clb.COUNT > 0
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty(str_pad1 || '"security":' || str_pad || '[',p_pretty_print + 1)
            );
            
            str_pad2 := str_pad;
               
            FOR i IN 1 .. ary_clb.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => dz_json_util.pretty(
                      str_pad2 || ary_clb(i)
                     ,p_pretty_print + 2
                  )
                  ,p_in_v => NULL
               );
               str_pad2 := ',';
            
            END LOOP;
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty(
                   ']'
                  ,p_pretty_print + 1
               )
            );
            
            str_pad1 := ',';
            
         END IF;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 190
      -- Add tags
      --------------------------------------------------------------------------
      SELECT
      a.tagtyp.toJSON(
         p_pretty_print   => p_pretty_print + 2
        ,p_force_inline   => p_force_inline
        ,p_short_id       => p_short_id
      )
      BULK COLLECT INTO ary_clb
      FROM
      dz_swagger3_xobjects a 
      WHERE 
          a.object_type_id = 'tagtyp'
      AND (
            a.tagtyp.tag_description IS NOT NULL
         OR a.tagtyp.tag_externaldocs IS NOT NULL 
      ) 
      ORDER BY a.object_id;
      
      IF  ary_clb IS NOT NULL
      AND ary_clb.COUNT > 0
      THEN  
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => dz_json_util.pretty(str_pad1 || '"tags":' || str_pad || '[',p_pretty_print + 1)
         );
         
         str_pad2 := str_pad;
            
         FOR i IN 1 .. ary_clb.COUNT
         LOOP
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => dz_json_util.pretty(
                   str_pad2 || ary_clb(i)
                  ,p_pretty_print + 2
               )
               ,p_in_v => NULL
            );
            str_pad2 := ',';
         
         END LOOP;
         
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => dz_json_util.pretty(
                ']'
               ,p_pretty_print + 1
            )
         );
         
         str_pad1 := ',';
      
      END IF;

      --------------------------------------------------------------------------
      -- Step 200
      -- Add externalDocs
      --------------------------------------------------------------------------
      IF self.externalDocs IS NOT NULL
      THEN
         BEGIN
            SELECT
            a.extrdocstyp.toJSON(
               p_pretty_print   => p_pretty_print + 1
              ,p_force_inline   => p_force_inline
              ,p_short_id       => p_short_id
            ) 
            INTO clb_tmp
            FROM
            dz_swagger3_xobjects a
            WHERE 
                a.object_type_id = self.externalDocs.object_type_id 
            AND a.object_id      = self.externalDocs.object_id; 
         
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
            ,p_in_c => dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                   'externalDocs'
                  ,clb_tmp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            )
            ,p_in_v => NULL
         );
         str_pad1 := ',';

      END IF;

      --------------------------------------------------------------------------
      -- Step 210
      -- Add the left bracket
      --------------------------------------------------------------------------
      dz_swagger3_util.conc(
          p_c    => cb
         ,p_v    => v2
         ,p_in_c => NULL
         ,p_in_v => dz_json_util.pretty(
             '}'
            ,p_pretty_print,NULL,NULL
         )
      );

      --------------------------------------------------------------------------
      -- Step 220
      -- Cough it out
      --------------------------------------------------------------------------
      dz_swagger3_util.fconc(
          p_c    => cb
         ,p_v    => v2
      );
      
      RETURN cb;

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
      cb            CLOB;
      v2            VARCHAR2(32000);
      
      ary_keys      MDSYS.SDO_STRING2_ARRAY;
      clb_tmp       CLOB;
      
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
      dz_swagger3_util.conc(
          p_c    => cb
         ,p_v    => v2
         ,p_in_c => NULL
         ,p_in_v => dz_json_util.pretty_str(
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
         )
      );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the info object
      --------------------------------------------------------------------------
      IF self.info IS NOT NULL
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => dz_json_util.pretty_str(
                'info: '
               ,p_pretty_print
               ,'  '
             ) 
         );
         
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => self.info.toYAML(
                p_pretty_print   => p_pretty_print + 1
               ,p_force_inline   => p_force_inline
             )
            ,p_in_v => NULL
         );
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Write the server array
      --------------------------------------------------------------------------
      IF  self.servers IS NOT NULL 
      AND self.servers.COUNT > 0
      THEN
         SELECT
         a.servertyp.toYAML(
             p_pretty_print   => p_pretty_print + 2
            ,p_initial_indent => 'FALSE'
            ,p_force_inline   => p_force_inline
            ,p_short_id       => p_short_id
         )
         BULK COLLECT INTO ary_clb
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.servers) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id
         ORDER BY b.object_order;
         
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => dz_json_util.pretty_str(
                'servers: '
               ,p_pretty_print
               ,'  '
            )
         );
         
         FOR i IN 1 .. ary_clb.COUNT
         LOOP
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty_str(
                   '- '
                  ,p_pretty_print + 1
                  ,'  '
                  ,NULL
                )
            );
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => ary_clb(i)
               ,p_in_v => NULL
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
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => dz_json_util.pretty_str(
                'paths: {}'
               ,p_pretty_print
               ,'  '
            )
         );
         
      ELSE
         SELECT
          a.pathtyp.toYAML(
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
         TABLE(self.paths) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id
         ORDER BY b.object_order;
         
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => dz_json_util.pretty_str(
                'paths: '
               ,p_pretty_print
               ,'  '
            )
         );
         
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty_str(
                   dz_swagger3_util.yamlq(ary_keys(i)) || ': '
                  ,p_pretty_print + 1
                  ,'  '
                )
            );
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => ary_clb(i)
               ,p_in_v => NULL
            );

         END LOOP;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 60
      -- Write the components operation
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      OR self.paths IS NULL 
      OR self.paths.COUNT = 0
      THEN
         NULL;
         
      ELSE
      --------------------------------------------------------------------------
      -- Step 70
      -- Write the component schemas
      --------------------------------------------------------------------------
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => dz_json_util.pretty_str(
                'components: '
               ,p_pretty_print
               ,'  '
            )
         );
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Write the component schemas
      --------------------------------------------------------------------------
         SELECT
          a.schematyp.toYAML(
             p_pretty_print   => p_pretty_print + 3
            ,p_force_inline   => 'FALSE'
            ,p_short_id       => p_short_id
         )
         ,CASE
          WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
          THEN
            a.short_id
          ELSE
            a.object_id
          END
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'schematyp'
         AND a.reference_count > 1
         AND COALESCE(a.schematyp.property_list_hidden,'FALSE') <> 'TRUE'
         ORDER BY a.object_id;

         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty_str(
                   'schemas: '
                  ,p_pretty_print + 1
                  ,'  '
               )
            );
         
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v => dz_json_util.pretty_str(
                      dz_swagger3_util.yamlq(ary_keys(i)) || ': '
                     ,p_pretty_print + 2
                     ,'  '
                   )
               );
               
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => ary_clb(i)
                  ,p_in_v => NULL
               );
            
            END LOOP;
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Write the component responses
      --------------------------------------------------------------------------
         SELECT
          a.responsetyp.toYAML(
             p_pretty_print   => p_pretty_print + 3
            ,p_force_inline   => 'FALSE'
            ,p_short_id       => p_short_id
          )
         ,CASE
          WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
          THEN
            a.short_id
          ELSE
            a.object_id
          END
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'responsetyp'
         AND a.reference_count > 1
         ORDER BY a.object_id;
            
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN          
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty_str(
                   'responses: '
                  ,p_pretty_print + 1
                  ,'  '
               )
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v => dz_json_util.pretty_str(
                      dz_swagger3_util.yamlq(ary_keys(i)) || ': '
                     ,p_pretty_print + 2
                     ,'  '
                   )
               );
               
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => ary_clb(i)
                  ,p_in_v => NULL
               );
            
            END LOOP;
              
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Write the component parameters
      --------------------------------------------------------------------------
         SELECT
          a.parametertyp.toYAML(
             p_pretty_print   => p_pretty_print + 3
            ,p_force_inline   => 'FALSE'
            ,p_short_id       => p_short_id
          )
         ,CASE
          WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
           THEN
            a.short_id
          ELSE
            a.object_id
          END
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'parametertyp'
         AND a.reference_count > 1
         AND COALESCE(a.parametertyp.parameter_list_hidden,'FALSE') <> 'TRUE'
         ORDER BY a.object_id;
            
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty_str(
                   'parameters: '
                  ,p_pretty_print + 1
                  ,'  '
               )
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v => dz_json_util.pretty_str(
                      dz_swagger3_util.yamlq(ary_keys(i)) || ': '
                     ,p_pretty_print + 2
                     ,'  '
                   )
               );
               
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => ary_clb(i)
                  ,p_in_v => NULL
               );
            
            END LOOP;
               
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Write the component examples
      --------------------------------------------------------------------------
         SELECT
          a.exampletyp.toYAML(
             p_pretty_print   => p_pretty_print + 3
            ,p_force_inline   => 'FALSE'
            ,p_short_id       => p_short_id
          )
         ,CASE
          WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
          THEN
            a.short_id
          ELSE
            a.object_id
          END
         BULK COLLECT INTO 
         ary_clb
         ,ary_keys
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'exampletyp'
         AND a.reference_count > 1
         ORDER BY a.object_id;
            
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty_str(
                   'examples: '
                  ,p_pretty_print + 1
                  ,'  '
               )
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v => dz_json_util.pretty_str(
                      dz_swagger3_util.yamlq(ary_keys(i)) || ': '
                     ,p_pretty_print + 2
                     ,'  '
                   )
               );
               
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => ary_clb(i)
                  ,p_in_v => NULL
               );
            
            END LOOP;
              
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Write the component requestBodies
      --------------------------------------------------------------------------
         SELECT
          a.requestbodytyp.toYAML(
             p_pretty_print   => p_pretty_print + 3
            ,p_force_inline   => 'FALSE'
           ,p_short_id        => p_short_id
          )
         ,CASE
          WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
          THEN
            a.short_id
          ELSE
            a.object_id
          END
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'requestbodytyp'
         AND a.reference_count > 1
         ORDER BY a.object_id;
            
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty_str(
                   'requestBodies: '
                  ,p_pretty_print + 1
                  ,'  '
               )
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v => dz_json_util.pretty_str(
                      dz_swagger3_util.yamlq(ary_keys(i)) || ': '
                     ,p_pretty_print + 2
                     ,'  '
                   )
               );
               
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => ary_clb(i)
                  ,p_in_v => NULL
               );
            
            END LOOP;
               
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 130
      -- Write the component headers
      --------------------------------------------------------------------------
         SELECT
          a.headertyp.toYAML(
             p_pretty_print   => p_pretty_print + 3
            ,p_force_inline   => 'FALSE'
            ,p_short_id       => p_short_id
          )
         ,CASE
          WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
          THEN
            a.short_id
          ELSE
            a.object_id
          END
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'headertyp'
         AND a.reference_count > 1
         ORDER BY a.object_id;
            
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty_str(
                   'headers: '
                  ,p_pretty_print + 1
                  ,'  '
               )
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v => dz_json_util.pretty_str(
                      dz_swagger3_util.yamlq(ary_keys(i)) || ': '
                     ,p_pretty_print + 2
                     ,'  '
                   )
               );
               
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => ary_clb(i)
                  ,p_in_v => NULL
               );
            
            END LOOP;
               
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 140
      -- Write the component securitySchemes
      --------------------------------------------------------------------------
         SELECT
          a.securityschemetyp.toYAML(
             p_pretty_print   => p_pretty_print + 3
            ,p_force_inline   => 'FALSE'
            ,p_short_id       => p_short_id
          )
         ,CASE
          WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
          THEN
            a.short_id
          ELSE
            a.object_id
          END
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'securityschemetyp'
         AND a.reference_count > 1
         ORDER BY a.object_id;
            
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty_str(
                   'securitySchemes: '
                  ,p_pretty_print + 1
                  ,'  '
               )
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v => dz_json_util.pretty_str(
                      dz_swagger3_util.yamlq(ary_keys(i)) || ': '
                     ,p_pretty_print + 2
                     ,'  '
                   )
               );
               
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => ary_clb(i)
                  ,p_in_v => NULL
               );
            
            END LOOP;
               
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 150
      -- Write the component links
      --------------------------------------------------------------------------
         SELECT
          a.linktyp.toYAML(
             p_pretty_print   => p_pretty_print + 3
            ,p_force_inline   => 'FALSE'
            ,p_short_id       => p_short_id
          )
         ,CASE
          WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
          THEN
            a.short_id
          ELSE
            a.object_id
          END
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'linktyp'
         AND a.reference_count > 1
         ORDER BY a.object_id;
            
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty_str(
                   'links: '
                  ,p_pretty_print + 1
                  ,'  '
               )
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v => dz_json_util.pretty_str(
                      dz_swagger3_util.yamlq(ary_keys(i)) || ': '
                     ,p_pretty_print + 2
                     ,'  '
                   )
               );
               
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => ary_clb(i)
                  ,p_in_v => NULL
               );
            
            END LOOP;

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 160
      -- Write the component callbacks
      --------------------------------------------------------------------------
         SELECT
          a.pathtyp.toYAML(
             p_pretty_print   => p_pretty_print + 3
            ,p_force_inline   => 'FALSE'
            ,p_short_id       => p_short_id
          )
         ,CASE
          WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
          THEN
            a.short_id
          ELSE
            a.object_id
          END
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'callbacktyp'
         AND a.reference_count > 1
         ORDER BY a.object_id;
            
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty_str(
                   'callbacks: '
                  ,p_pretty_print + 1
                  ,'  '
               )
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v => dz_json_util.pretty_str(
                      dz_swagger3_util.yamlq(ary_keys(i)) || ': '
                     ,p_pretty_print + 2
                     ,'  '
                   )
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
      -- Step 170
      -- Write the security array
      --------------------------------------------------------------------------
      IF  self.security IS NOT NULL 
      AND self.security.COUNT > 0
      THEN
         SELECT
         a.securityreqtyp.toYAML(
             p_pretty_print   => p_pretty_print + 2
            ,p_initial_indent => 'FALSE'
            ,p_force_inline   => p_force_inline
            ,p_short_id       => p_short_id
         )
         BULK COLLECT INTO ary_clb
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.security) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id
         ORDER BY b.object_order;

         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => dz_json_util.pretty_str(
                'security: '
               ,p_pretty_print
               ,'  '
            )
         );
         
         FOR i IN 1 .. ary_clb.COUNT
         LOOP
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v =>  dz_json_util.pretty_str(
                   '- '
                  ,p_pretty_print
                  ,'  '
                  ,NULL
                )
            );
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => ary_clb(i)
               ,p_in_v => NULL
            );
            
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 180
      -- Write the tags array
      --------------------------------------------------------------------------
      SELECT
      a.tagtyp.toYAML(
          p_pretty_print   => p_pretty_print + 2
         ,p_initial_indent => 'FALSE'
         ,p_force_inline   => p_force_inline
         ,p_short_id       => p_short_id
      )
      BULK COLLECT INTO ary_clb
      FROM
      dz_swagger3_xobjects a
      WHERE
          a.object_type_id = 'tagtyp'
      AND (
            a.tagtyp.tag_description IS NOT NULL
         OR a.tagtyp.tag_externaldocs IS NOT NULL
      )
      ORDER BY a.object_id;
      
      IF  ary_clb IS NOT NULL
      AND ary_clb.COUNT > 0
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => dz_json_util.pretty_str(
                'tags: '
               ,p_pretty_print
               ,'  '
            )
         );
         
         FOR i IN 1 .. ary_clb.COUNT
         LOOP
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v =>  dz_json_util.pretty_str(
                   '- '
                  ,p_pretty_print + 1
                  ,'  '
                  ,NULL
                )
            );
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => ary_clb(i)
               ,p_in_v => NULL
            );
            
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 190
      -- Write the externalDocs
      --------------------------------------------------------------------------
      IF self.externalDocs IS NOT NULL
      THEN
         BEGIN
            SELECT
            a.extrdocstyp.toYAML(
                p_pretty_print   => p_pretty_print + 1
               ,p_force_inline   => p_force_inline
               ,p_short_id       => p_short_id
            ) 
            INTO clb_tmp
            FROM
            dz_swagger3_xobjects a
            WHERE
                a.object_type_id = self.externalDocs.object_type_id
            AND a.object_id      = self.externalDocs.object_id;
           
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
            ,p_in_v => dz_json_util.pretty_str(
                'externalDocs: '
               ,p_pretty_print
               ,'  '
            )
         );
         
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => clb_tmp
            ,p_in_v => NULL
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 200
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

