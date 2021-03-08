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
      SELECT
      dz_swagger3_object_typ(
          p_object_id        => a.securityScheme_id
         ,p_object_type_id   => 'securityschemetyp'
         ,p_object_key       => a.securityScheme_name
         ,p_object_attribute => a.oauth_flow_scopes
         ,p_object_order     => a.securityScheme_order
      )
      BULK COLLECT INTO self.security 
      FROM
      dz_swagger3_parent_secschm_map a
      WHERE
          a.versionid = str_versionid
      AND a.parent_id = str_doc_id;
      
      IF self.security.COUNT > 0
      THEN
         dz_swagger3_loader.securitySchemetyp(
             p_parent_id    => 'root'
            ,p_children_ids => self.security 
            ,p_versionid    => str_versionid
         );
         
      END IF;

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
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output              CLOB;
      clb_servers             CLOB;
      clb_paths               CLOB;
      clb_schemas             CLOB;
      clb_responses           CLOB;
      clb_parameters          CLOB;
      clb_examples            CLOB;
      clb_requestbodies       CLOB;
      clb_headers             CLOB;
      clb_securitySchemes     CLOB;
      clb_links               CLOB;
      clb_callbacks           CLOB;
      clb_security            CLOB;
      clb_tags                CLOB;
      clb_externalDocs        CLOB;
      
   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------

      --------------------------------------------------------------------------
      -- Step 20
      -- Add servers
      --------------------------------------------------------------------------
      IF  self.servers IS NOT NULL 
      AND self.servers.COUNT > 0
      THEN
         SELECT 
         JSON_ARRAYAGG(
            a.servertyp.toJSON()
            RETURNING CLOB
         )
         INTO clb_servers
         FROM
         dz_swagger3_xobjects a 
         JOIN 
         TABLE(self.servers) b 
         ON 
             a.object_type_id = b.object_type_id 
         AND a.object_id      = b.object_id 
         ORDER BY b.object_order;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add paths
      --------------------------------------------------------------------------
      IF self.paths IS NOT NULL 
      OR self.paths.COUNT > 0
      THEN
         SELECT
         JSON_OBJECTAGG(
            b.object_key VALUE a.pathtyp.toJSON(
                p_force_inline   => p_force_inline
               ,p_short_id       => p_short_id
            )
            RETURNING CLOB
         )
         INTO clb_paths 
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.paths) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id
         ORDER BY b.object_order;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Add schemas components map
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      OR self.paths IS NULL
      OR self.paths.COUNT = 0
      THEN
         NULL;

      ELSE
         SELECT
         JSON_OBJECTAGG(
            CASE 
            WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
            THEN 
               a.short_id 
            ELSE 
               a.object_id 
            END VALUE a.schematyp.toJSON( 
                p_force_inline   => 'FALSE'
               ,p_short_id       => p_short_id
            ) FORMAT JSON 
            RETURNING CLOB
         )
         INTO clb_schemas
         FROM 
         dz_swagger3_xobjects a 
         WHERE 
             a.object_type_id = 'schematyp'
         AND a.reference_count > 1 
         AND COALESCE(a.schematyp.property_list_hidden,'FALSE') <> 'TRUE'
         ORDER BY a.object_id; 
         
         SELECT
         JSON_OBJECTAGG(
            CASE 
            WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
            THEN
               a.short_id
            ELSE
               a.object_id
            END VALUE a.responsetyp.toJSON(
                p_force_inline   => 'FALSE'
               ,p_short_id       => p_short_id
            ) FORMAT JSON
            RETURNING CLOB
         )
         INTO clb_responses
         FROM
         dz_swagger3_xobjects a
         WHERE 
             a.object_type_id = 'responsetyp'
         AND a.reference_count > 1 
         ORDER BY a.object_id;
         
         SELECT
         JSON_OBJECTAGG(
            CASE
            WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
            THEN
               a.short_id
            ELSE
               a.object_id
            END VALUE a.parametertyp.toJSON(
                p_force_inline   => 'FALSE'
               ,p_short_id       => p_short_id
            ) FORMAT JSON
            RETURNING CLOB
         )
         INTO clb_parameters 
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'parametertyp'
         AND a.reference_count > 1
         AND COALESCE(a.parametertyp.parameter_list_hidden,'FALSE') <> 'TRUE'
         ORDER BY a.object_id;
            
         SELECT
         JSON_OBJECTAGG(
            CASE
            WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
            THEN
               a.short_id
            ELSE
               a.object_id
            END VALUE a.exampletyp.toJSON( 
                p_force_inline   => 'FALSE'
               ,p_short_id       => p_short_id
            ) FORMAT JSON
            RETURNING CLOB
         )
         INTO clb_examples
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'exampletyp'
         AND a.reference_count > 1
         ORDER BY a.object_id;
         
         SELECT
         JSON_OBJECTAGG(
            CASE
            WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
            THEN
               a.short_id
            ELSE
               a.object_id
            END VALUE a.requestbodytyp.toJSON(
                p_force_inline   => 'FALSE'
               ,p_short_id       => p_short_id
            ) FORMAT JSON
            RETURNING CLOB
         )
         INTO clb_requestbodies
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'requestbodytyp'
         AND a.reference_count > 1
         ORDER BY a.object_id;

         SELECT
         JSON_OBJECTAGG(
            CASE
            WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
            THEN
               a.short_id
            ELSE
               a.object_id
            END VALUE a.headertyp.toJSON(
                p_force_inline   => 'FALSE'
               ,p_short_id       => p_short_id
            ) FORMAT JSON
            RETURNING CLOB
         )
         INTO clb_headers
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'headertyp'
         AND a.reference_count > 1
         ORDER BY a.object_id;
            
         SELECT
         JSON_OBJECTAGG(
            a.securityschemetyp.securityscheme_fullname VALUE a.securityschemetyp.toJSON() FORMAT JSON
            RETURNING CLOB
         )
         INTO clb_securitySchemes
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'securityschemetyp'
         ORDER BY a.object_id;
            
         SELECT
         JSON_OBJECTAGG(
            CASE
            WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
            THEN
               a.short_id
            ELSE
               a.object_id
            END VALUE a.linktyp.toJSON(
                p_force_inline   => 'FALSE'
               ,p_short_id       => p_short_id
            ) FORMAT JSON
            RETURNING CLOB
         )
         INTO clb_links
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'linktyp'
         AND a.reference_count > 1
         ORDER BY a.object_id;
            
         SELECT
         JSON_OBJECTAGG(
            CASE
            WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
            THEN
               a.short_id
            ELSE
               a.object_id
            END VALUE a.pathtyp.toJSON(
                p_force_inline   => 'FALSE'
               ,p_short_id       => p_short_id
            ) FORMAT JSON
            RETURNING CLOB
         )
         INTO clb_callbacks
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'callbacktyp'
         AND a.reference_count > 1
         ORDER BY a.object_id;
            
            
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add security
      --------------------------------------------------------------------------
      IF  self.security IS NOT NULL 
      AND self.security.COUNT > 0
      THEN
         SELECT 
         JSON_ARRAYAGG(
            a.securityschemetyp.toJSON_req( 
               p_oauth_scope_flows => b.object_attribute
            ) FORMAT JSON
            RETURNING CLOB
         )
         INTO clb_security
         FROM 
         dz_swagger3_xobjects a 
         JOIN 
         TABLE(self.security) b 
         ON 
             a.object_type_id = b.object_type_id 
         AND a.object_id      = b.object_id 
         ORDER BY b.object_order;

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add tags
      --------------------------------------------------------------------------
      SELECT
      JSON_ARRAYAGG(
         a.tagtyp.toJSON() FORMAT JSON
         RETURNING CLOB
      )
      INTO clb_tags
      FROM
      dz_swagger3_xobjects a 
      WHERE 
          a.object_type_id = 'tagtyp'
      AND (
            a.tagtyp.tag_description IS NOT NULL
         OR a.tagtyp.tag_externaldocs IS NOT NULL 
      ) 
      ORDER BY a.object_id;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Add externalDocs
      --------------------------------------------------------------------------
      IF self.externalDocs IS NOT NULL
      THEN
         BEGIN
            SELECT
            a.extrdocstyp.toJSON() 
            INTO clb_externalDocs
            FROM
            dz_swagger3_xobjects a
            WHERE 
                a.object_type_id = self.externalDocs.object_type_id 
            AND a.object_id      = self.externalDocs.object_id; 
         
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_externalDocs := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;

      END IF;


      --------------------------------------------------------------------------
      -- Step 80
      -- Build the object
      --------------------------------------------------------------------------
      SELECT
      JSON_OBJECT(
          'openapi'       VALUE dz_swagger3_constants.c_openapi_version
         ,'info'          VALUE self.info.toJSON(
            p_force_inline => p_force_inline
          )                                               FORMAT JSON
         ,'servers'       VALUE clb_servers               FORMAT JSON
         ,'paths'         VALUE clb_paths                 FORMAT JSON
         ,'components'    VALUE JSON_OBJECT(
             'schemas'         VALUE clb_schemas         FORMAT JSON
            ,'responses'       VALUE clb_responses       FORMAT JSON
            ,'parameters'      VALUE clb_parameters      FORMAT JSON
            ,'examples'        VALUE clb_examples        FORMAT JSON
            ,'requestBodies'   VALUE clb_requestBodies   FORMAT JSON
            ,'headers'         VALUE clb_headers         FORMAT JSON
            ,'securitySchemes' VALUE clb_securitySchemes FORMAT JSON
            ,'links'           VALUE clb_links           FORMAT JSON
            ,'callbacks'       VALUE clb_callbacks       FORMAT JSON
            ABSENT ON NULL
            RETURNING CLOB
          )
         ,'security'      VALUE clb_security              FORMAT JSON
         ,'tags'          VALUE clb_tags                  FORMAT JSON
         ,'externalDocs'  VALUE clb_externalDocs          FORMAT JSON
         ABSENT ON NULL
         RETURNING CLOB        
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
      cb            CLOB;
      v2            VARCHAR2(32000);
      
      ary_keys      dz_swagger3_string_vry;
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
         ,p_in_v => '---'
         ,p_pretty_print => p_pretty_print
         ,p_amount       => '  '
      );
      
      dz_swagger3_util.conc(
          p_c    => cb
         ,p_v    => v2
         ,p_in_c => NULL
         ,p_in_v => 'openapi: ' || dz_swagger3_util.yaml_text(
             dz_swagger3_constants.c_openapi_version
            ,p_pretty_print
          )
         ,p_pretty_print => p_pretty_print
         ,p_amount       => '  '
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
            ,p_in_v => 'info: '
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  ' 
         );
         
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => self.info.toYAML(
                p_pretty_print      => p_pretty_print + 1
               ,p_final_linefeed    => 'FALSE'
               ,p_force_inline      => p_force_inline
             )
            ,p_in_v => NULL
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
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
             p_pretty_print      => p_pretty_print + 2
            ,p_initial_indent    => 'FALSE'
            ,p_final_linefeed    => 'FALSE'
            ,p_force_inline      => p_force_inline
            ,p_short_id          => p_short_id
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
            ,p_in_v => 'servers: '
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );
         
         FOR i IN 1 .. ary_clb.COUNT
         LOOP
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v =>  '- '
               ,p_pretty_print => p_pretty_print + 1
               ,p_amount       => '  '
               ,p_final_linefeed => FALSE
            );
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => ary_clb(i)
               ,p_in_v => NULL
               ,p_pretty_print => p_pretty_print + 1
               ,p_amount       => '  '
               ,p_initial_indent => FALSE
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
            ,p_in_v =>  'paths: {}'
            ,p_pretty_print => p_pretty_print 
            ,p_amount       => '  '
         );
         
      ELSE
         SELECT
          a.pathtyp.toYAML(
             p_pretty_print      => p_pretty_print + 2
            ,p_force_inline      => p_force_inline
            ,p_short_id          => p_short_id
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
            ,p_in_v => 'paths: '
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
            ,p_in_v => 'components: '
            ,p_pretty_print => p_pretty_print 
            ,p_amount       => '  '
         );
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Write the component schemas
      --------------------------------------------------------------------------
         SELECT
          a.schematyp.toYAML(
             p_pretty_print      => p_pretty_print + 3
            ,p_force_inline      => 'FALSE'
            ,p_short_id          => p_short_id
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
               ,p_in_v => 'schemas: '
               ,p_pretty_print => p_pretty_print + 1
               ,p_amount       => '  '
            );
         
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v => dz_swagger3_util.yamlq(ary_keys(i)) || ': '
                  ,p_pretty_print => p_pretty_print + 2
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
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Write the component responses
      --------------------------------------------------------------------------
         SELECT
          a.responsetyp.toYAML(
             p_pretty_print      => p_pretty_print + 3
            ,p_force_inline      => 'FALSE'
            ,p_short_id          => p_short_id
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
               ,p_in_v => 'responses: '
               ,p_pretty_print => p_pretty_print + 1
               ,p_amount       => '  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v => dz_swagger3_util.yamlq(ary_keys(i)) || ': '
                  ,p_pretty_print => p_pretty_print + 2
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
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Write the component parameters
      --------------------------------------------------------------------------
         SELECT
          a.parametertyp.toYAML(
             p_pretty_print      => p_pretty_print + 3
            ,p_force_inline      => 'FALSE'
            ,p_short_id          => p_short_id
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
               ,p_in_v => 'parameters: '
               ,p_pretty_print => p_pretty_print + 1
               ,p_amount       => '  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v => dz_swagger3_util.yamlq(ary_keys(i)) || ': '
                  ,p_pretty_print => p_pretty_print + 2
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
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Write the component examples
      --------------------------------------------------------------------------
         SELECT
          a.exampletyp.toYAML(
             p_pretty_print      => p_pretty_print + 3
            ,p_force_inline      => 'FALSE'
            ,p_short_id          => p_short_id
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
               ,p_in_v => 'examples: '
               ,p_pretty_print => p_pretty_print + 1
               ,p_amount       => '  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v => dz_swagger3_util.yamlq(ary_keys(i)) || ': '
                  ,p_pretty_print => p_pretty_print + 2
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
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Write the component requestBodies
      --------------------------------------------------------------------------
         SELECT
          a.requestbodytyp.toYAML(
             p_pretty_print      => p_pretty_print + 3
            ,p_force_inline      => 'FALSE'
            ,p_short_id           => p_short_id
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
               ,p_in_v => 'requestBodies: '
               ,p_pretty_print => p_pretty_print + 1
               ,p_amount       => '  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v => dz_swagger3_util.yamlq(ary_keys(i)) || ': '
                  ,p_pretty_print => p_pretty_print + 2
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
      
      --------------------------------------------------------------------------
      -- Step 130
      -- Write the component headers
      --------------------------------------------------------------------------
         SELECT
          a.headertyp.toYAML(
             p_pretty_print      => p_pretty_print + 3
            ,p_force_inline      => 'FALSE'
            ,p_short_id          => p_short_id
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
               ,p_in_v => 'headers: '
               ,p_pretty_print => p_pretty_print + 1
               ,p_amount       => '  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v => dz_swagger3_util.yamlq(ary_keys(i)) || ': '
                  ,p_pretty_print => p_pretty_print + 2
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
      
      --------------------------------------------------------------------------
      -- Step 140
      -- Write the component securitySchemes
      --------------------------------------------------------------------------
         SELECT
          a.securityschemetyp.toYAML(
            p_pretty_print      => p_pretty_print + 3
          )
         ,a.securityschemetyp.securityscheme_fullname
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'securityschemetyp'
         ORDER BY a.object_id;
            
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'securitySchemes: '
               ,p_pretty_print => p_pretty_print + 1
               ,p_amount       => '  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v => dz_swagger3_util.yamlq(ary_keys(i)) || ': '
                  ,p_pretty_print => p_pretty_print + 2
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
      
      --------------------------------------------------------------------------
      -- Step 150
      -- Write the component links
      --------------------------------------------------------------------------
         SELECT
          a.linktyp.toYAML(
             p_pretty_print      => p_pretty_print + 3
            ,p_force_inline      => 'FALSE'
            ,p_short_id          => p_short_id
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
               ,p_in_v => 'links: '
               ,p_pretty_print => p_pretty_print + 1
               ,p_amount       => '  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v => dz_swagger3_util.yamlq(ary_keys(i)) || ': '
                  ,p_pretty_print => p_pretty_print + 2
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
      
      --------------------------------------------------------------------------
      -- Step 160
      -- Write the component callbacks
      --------------------------------------------------------------------------
         SELECT
          a.pathtyp.toYAML(
             p_pretty_print      => p_pretty_print + 3
            ,p_force_inline      => 'FALSE'
            ,p_short_id          => p_short_id
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
               ,p_in_v => 'callbacks: '
               ,p_pretty_print => p_pretty_print + 1
               ,p_amount       => '  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v => dz_swagger3_util.yamlq(ary_keys(i)) || ': '
                  ,p_pretty_print => p_pretty_print + 2
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
      -- Step 170
      -- Write the security array
      --------------------------------------------------------------------------
      IF  self.security IS NOT NULL 
      AND self.security.COUNT > 0
      THEN
         SELECT
         a.securityschemetyp.toYAML_req(
             p_pretty_print      => p_pretty_print + 1
            ,p_initial_indent    => 'FALSE'
            ,p_oauth_scope_flows => b.object_attribute
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
            ,p_in_v => 'security: '
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );
         
         FOR i IN 1 .. ary_clb.COUNT
         LOOP
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v =>  '- '
               ,p_pretty_print => p_pretty_print + 1
               ,p_amount       => '  '
               ,p_final_linefeed => FALSE
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
            ,p_in_v => 'tags: '
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );
         
         FOR i IN 1 .. ary_clb.COUNT
         LOOP
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v =>  '- '
               ,p_pretty_print => p_pretty_print + 1
               ,p_amount       => '  '
               ,p_final_linefeed => FALSE
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
            ,p_in_v => 'externalDocs: '
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

