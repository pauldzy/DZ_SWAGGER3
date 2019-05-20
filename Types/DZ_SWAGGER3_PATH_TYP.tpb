CREATE OR REPLACE TYPE BODY dz_swagger3_path_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_path_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_path_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_path_typ(
       p_path_id                   IN  VARCHAR2
      ,p_versionid                 IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS   
   BEGIN 
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Initialize the object
      --------------------------------------------------------------------------
      self.versionid := p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Fetch component items
      --------------------------------------------------------------------------
      SELECT
       a.path_endpoint
      ,a.path_id
      ,a.path_summary
      ,a.path_description
      ,CASE
       WHEN a.path_get_operation_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id      => a.path_get_operation_id
            ,p_object_type_id => 'operationtyp'
            ,p_object_subtype => 'get'
         )
       ELSE
         NULL
       END
      ,CASE
       WHEN a.path_put_operation_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id      => a.path_put_operation_id
            ,p_object_type_id => 'operationtyp'
            ,p_object_subtype => 'put'
         )
       ELSE
         NULL
       END
      ,CASE
       WHEN a.path_post_operation_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id      => a.path_post_operation_id
            ,p_object_type_id => 'operationtyp'
            ,p_object_subtype => 'post'
         )
       ELSE
         NULL
       END
      ,CASE
       WHEN a.path_delete_operation_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id      => a.path_delete_operation_id
            ,p_object_type_id => 'operationtyp'
            ,p_object_subtype => 'delete'
         )
       ELSE
         NULL
       END
      ,CASE
       WHEN a.path_options_operation_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id      => a.path_options_operation_id
            ,p_object_type_id => 'operationtyp'
            ,p_object_subtype => 'options'
         )
       ELSE
         NULL
       END
      ,CASE
       WHEN a.path_head_operation_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id      => a.path_head_operation_id
            ,p_object_type_id => 'operationtyp'
            ,p_object_subtype => 'head'
         )
       ELSE
         NULL
       END
      ,CASE
       WHEN a.path_patch_operation_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id      => a.path_patch_operation_id
            ,p_object_type_id => 'operationtyp'
            ,p_object_subtype => 'patch'
         )
       ELSE
         NULL
       END
      ,CASE
       WHEN a.path_trace_operation_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id      => a.path_trace_operation_id
            ,p_object_type_id => 'operationtyp'
            ,p_object_subtype => 'trace'
         )
       ELSE
         NULL
       END
      INTO 
       self.path_endpoint
      ,self.path_id
      ,self.path_summary
      ,self.path_description
      ,self.path_get_operation
      ,self.path_put_operation
      ,self.path_post_operation
      ,self.path_delete_operation
      ,self.path_options_operation
      ,self.path_head_operation
      ,self.path_patch_operation
      ,self.path_trace_operation
      FROM
      dz_swagger3_path a
      WHERE
          a.versionid = p_versionid
      AND a.path_id   = p_path_id;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Load the server objects on this path
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id      => a.server_id
         ,p_object_type_id => 'servertyp'
         ,p_object_order   => a.server_order
      )
      BULK COLLECT INTO self.path_servers
      FROM
      dz_swagger3_parent_server_map a
      WHERE
          a.versionid = p_versionid
      AND a.parent_id = p_path_id;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Load the parameter objects on this path
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id      => a.parameter_id
         ,p_object_type_id => 'parametertyp'
         ,p_object_order   => b.parameter_order
      )
      BULK COLLECT INTO self.path_parameters
      FROM
      dz_swagger3_parameter a
      JOIN
      dz_swagger3_parent_parm_map b
      ON
          a.versionid = b.versionid
      AND a.parameter_id = b.parameter_id
      WHERE
          b.versionid = p_versionid
      AND b.parent_id = p_path_id;

      --------------------------------------------------------------------------
      -- Step 40
      -- Return the object
      --------------------------------------------------------------------------
      RETURN; 
      
   END dz_swagger3_path_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Load the operations
      --------------------------------------------------------------------------
      dz_swagger3_loader.operationtyp(
          p_parent_id    => self.path_id
         ,p_children_ids => dz_swagger3_object_vry(
             self.path_get_operation
            ,self.path_put_operation
            ,self.path_post_operation
            ,self.path_delete_operation
            ,self.path_options_operation
            ,self.path_head_operation
            ,self.path_patch_operation
            ,self.path_trace_operation
          )
         ,p_versionid    => self.versionid
      );
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Load the servers
      --------------------------------------------------------------------------
      IF  self.path_servers IS NOT NULL
      AND self.path_servers.COUNT > 0
      THEN
         dz_swagger3_loader.servertyp(
             p_parent_id    => self.path_id
            ,p_children_ids => self.path_servers
            ,p_versionid    => self.versionid
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Load the path parameters
      --------------------------------------------------------------------------
      IF  self.path_parameters IS NOT NULL
      AND self.path_parameters.COUNT > 0
      THEN
         dz_swagger3_loader.parametertyp(
             p_parent_id    => self.path_id
            ,p_children_ids => self.path_parameters
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
      -- Add path summary
      --------------------------------------------------------------------------
      IF self.path_summary IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'summary'
               ,self.path_summary
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Add path description 
      --------------------------------------------------------------------------
      IF self.path_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'description'
               ,self.path_description
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add get operation
      --------------------------------------------------------------------------
      IF  self.path_get_operation IS NOT NULL
      AND self.path_get_operation.object_id IS NOT NULL
      THEN
         BEGIN
            SELECT 
            a.operationtyp.toJSON( 
                p_pretty_print   => p_pretty_print + 1 
               ,p_force_inline   => p_force_inline 
               ,p_short_id       => p_short_id
            )
            INTO clb_tmp
            FROM 
            dz_swagger3_xobjects a 
            WHERE 
                a.object_type_id = self.path_get_operation.object_type_id
            AND a.object_id      = self.path_get_operation.object_id;
            
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_tmp := NULL;
               
            WHEN OTHERS
            THEN
               RAISE_APPLICATION_ERROR(
                   -20001
                  ,SQLERRM || self.path_get_operation.object_id
               );
               
         END;
      
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'get'
               ,clb_tmp
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;

      --------------------------------------------------------------------------
      -- Step 60
      -- Add put operation
      --------------------------------------------------------------------------
      IF  self.path_put_operation IS NOT NULL
      AND self.path_put_operation.object_id IS NOT NULL
      THEN
         BEGIN
            EXECUTE IMMEDIATE
               'SELECT '
            || 'a.operationtyp.toJSON( '
            || '    p_pretty_print   => :p01 + 1 '
            || '   ,p_force_inline   => :p02 '
            || '   ,p_short_id       => :p03 '
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
            ,self.path_put_operation.object_type_id
            ,self.path_put_operation.object_id;
            
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
                'put'
               ,clb_tmp
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;

      --------------------------------------------------------------------------
      -- Step 70
      -- Add post operation
      --------------------------------------------------------------------------
      IF  self.path_post_operation IS NOT NULL
      AND self.path_post_operation.object_id IS NOT NULL
      THEN
         BEGIN
            EXECUTE IMMEDIATE
               'SELECT '
            || 'a.operationtyp.toJSON( '
            || '    p_pretty_print   => :p01 + 1 '
            || '   ,p_force_inline   => :p02 '
            || '   ,p_short_id       => :p03 '
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
            ,self.path_post_operation.object_type_id
            ,self.path_post_operation.object_id;
            
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
                'post'
               ,clb_tmp
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;

      --------------------------------------------------------------------------
      -- Step 80
      -- Add delete operation
      --------------------------------------------------------------------------
      IF  self.path_delete_operation IS NOT NULL
      AND self.path_delete_operation.object_id IS NOT NULL
      THEN
         BEGIN
            EXECUTE IMMEDIATE
               'SELECT '
            || 'a.operationtyp.toJSON( '
            || '    p_pretty_print   => :p01 + 1 '
            || '   ,p_force_inline   => :p02 '
            || '   ,p_short_id       => :p03 '
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
            ,self.path_delete_operation.object_type_id
            ,self.path_delete_operation.object_id;
            
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
                'delete'
               ,clb_tmp
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Add options operation
      --------------------------------------------------------------------------
      IF  self.path_options_operation IS NOT NULL
      AND self.path_options_operation.object_id IS NOT NULL
      THEN
         BEGIN
            EXECUTE IMMEDIATE
               'SELECT '
            || 'a.operationtyp.toJSON( '
            || '    p_pretty_print   => :p01 + 1 '
            || '   ,p_force_inline   => :p02 '
            || '   ,p_short_id       => :p03 '
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
            ,self.path_options_operation.object_type_id
            ,self.path_options_operation.object_id;
            
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
                'options'
               ,clb_tmp
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Add head operation
      --------------------------------------------------------------------------
      IF  self.path_head_operation IS NOT NULL
      AND self.path_head_operation.object_id IS NOT NULL
      THEN
         BEGIN
            EXECUTE IMMEDIATE
               'SELECT '
            || 'a.operationtyp.toJSON( '
            || '    p_pretty_print   => :p01 + 1 '
            || '   ,p_force_inline   => :p02 '
            || '   ,p_short_id       => :p03 '
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
            ,self.path_head_operation.object_type_id
            ,self.path_head_operation.object_id;
            
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
                'head'
               ,clb_tmp
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Add patch operation
      --------------------------------------------------------------------------
      IF  self.path_patch_operation IS NOT NULL
      AND self.path_patch_operation.object_id IS NOT NULL
      THEN
         BEGIN
            EXECUTE IMMEDIATE
               'SELECT '
            || 'a.operationtyp.toJSON( '
            || '    p_pretty_print   => :p01 + 1 '
            || '   ,p_force_inline   => :p02 '
            || '   ,p_short_id       => :p03 '
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
            ,self.path_patch_operation.object_type_id
            ,self.path_patch_operation.object_id;
            
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
                'patch'
               ,clb_tmp
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Add trace operation
      --------------------------------------------------------------------------
      IF  self.path_trace_operation IS NOT NULL
      AND self.path_trace_operation.object_id IS NOT NULL
      THEN
         BEGIN
            EXECUTE IMMEDIATE
               'SELECT '
            || 'a.operationtyp.toJSON( '
            || '    p_pretty_print   => :p01 + 1 '
            || '   ,p_force_inline   => :p02 '
            || '   ,p_short_id       => :p03 '
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
            ,self.path_trace_operation.object_type_id
            ,self.path_trace_operation.object_id;
            
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
                'trace'
               ,clb_tmp
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;

      --------------------------------------------------------------------------
      -- Step 130
      -- Add servers
      --------------------------------------------------------------------------
      IF  self.path_servers IS NOT NULL 
      AND self.path_servers.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.servertyp.toJSON( '
         || '    p_pretty_print   => :p01 + 1 '
         || '   ,p_force_inline   => :p02 '
         || '   ,p_short_id       => :p03 '
         || ' ) '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p04) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      =  b.object_id '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO 
          ary_clb
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.path_servers;
         
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
                 'servers'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 140
      -- Add parameters
      --------------------------------------------------------------------------
      IF  self.path_parameters IS NOT NULL 
      AND self.path_parameters.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.parametertyp.toJSON_ref( '
         || '    p_pretty_print   => :p01 + 1 '
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
         || 'WHERE '
         || 'COALESCE(a.parametertyp.parameter_list_hidden,''FALSE'') <> ''TRUE'' '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.path_parameters;
         
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
                 'parameters'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 150
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 160
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
      -- Write the summary
      --------------------------------------------------------------------------
      IF self.path_summary IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'summary: ' || dz_swagger3_util.yaml_text(
                self.path_summary
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the description
      --------------------------------------------------------------------------
      IF self.path_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'description: ' || dz_swagger3_util.yaml_text(
                self.path_description
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Write the get operation
      --------------------------------------------------------------------------
      IF  self.path_get_operation IS NOT NULL
      AND self.path_get_operation.object_id IS NOT NULL
      THEN
         BEGIN
            EXECUTE IMMEDIATE
               'SELECT '
            || 'a.operationtyp.toYAML( '
            || '    p_pretty_print   => :p01 + 1 '
            || '   ,p_force_inline   => :p02 '
            || '   ,p_short_id       => :p03 '
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
            ,self.path_get_operation.object_type_id
            ,self.path_get_operation.object_id;
            
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_tmp := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;

         clb_output := clb_output || dz_json_util.pretty_str(
             'get: ' 
            ,p_pretty_print
            ,'  '
         ) || clb_tmp;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 50
      -- Write the get operation
      --------------------------------------------------------------------------
      IF  self.path_put_operation IS NOT NULL
      AND self.path_put_operation.object_id IS NOT NULL
      THEN
         BEGIN
            EXECUTE IMMEDIATE
               'SELECT '
            || 'a.operationtyp.toYAML( '
            || '    p_pretty_print   => :p01 + 1 '
            || '   ,p_force_inline   => :p02 '
            || '   ,p_short_id       => :p03 '
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
            ,self.path_put_operation.object_type_id
            ,self.path_put_operation.object_id;
            
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_tmp := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'put: ' 
            ,p_pretty_print
            ,'  '
         ) || clb_tmp;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 60
      -- Write the post operation
      --------------------------------------------------------------------------
      IF  self.path_post_operation IS NOT NULL
      AND self.path_post_operation.object_id IS NOT NULL
      THEN
         BEGIN
            EXECUTE IMMEDIATE
               'SELECT '
            || 'a.operationtyp.toYAML( '
            || '    p_pretty_print   => :p01 + 1 '
            || '   ,p_force_inline   => :p02 '
            || '   ,p_short_id       => :p03 '
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
            ,self.path_post_operation.object_type_id
            ,self.path_post_operation.object_id;
            
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_tmp := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'post: ' 
            ,p_pretty_print
            ,'  '
         ) || clb_tmp;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Write the delete operation
      --------------------------------------------------------------------------
      IF  self.path_delete_operation IS NOT NULL
      AND self.path_delete_operation.object_id IS NOT NULL
      THEN
         BEGIN
            EXECUTE IMMEDIATE
               'SELECT '
            || 'a.operationtyp.toYAML( '
            || '    p_pretty_print   => :p01 + 1 '
            || '   ,p_force_inline   => :p02 '
            || '   ,p_short_id       => :p03 '
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
            ,self.path_delete_operation.object_type_id
            ,self.path_delete_operation.object_id;
            
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_tmp := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'delete: ' 
            ,p_pretty_print
            ,'  '
         ) || clb_tmp;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Write the options operation
      --------------------------------------------------------------------------
      IF  self.path_options_operation IS NOT NULL
      AND self.path_options_operation.object_id IS NOT NULL
      THEN
         BEGIN
            EXECUTE IMMEDIATE
               'SELECT '
            || 'a.operationtyp.toYAML( '
            || '    p_pretty_print   => :p01 + 1 '
            || '   ,p_force_inline   => :p02 '
            || '   ,p_short_id       => :p03 '
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
            ,self.path_options_operation.object_type_id
            ,self.path_options_operation.object_id;
            
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_tmp := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'options: ' 
            ,p_pretty_print
            ,'  '
         ) || clb_tmp;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Write the head operation
      --------------------------------------------------------------------------
      IF  self.path_head_operation IS NOT NULL
      AND self.path_head_operation.object_id IS NOT NULL
      THEN
         BEGIN
            EXECUTE IMMEDIATE
               'SELECT '
            || 'a.operationtyp.toYAML( '
            || '    p_pretty_print   => :p01 + 1 '
            || '   ,p_force_inline   => :p02 '
            || '   ,p_short_id       => :p03 '
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
            ,self.path_head_operation.object_type_id
            ,self.path_head_operation.object_id;
            
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_tmp := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'head: ' 
            ,p_pretty_print
            ,'  '
         ) || clb_tmp;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Write the patch operation
      --------------------------------------------------------------------------
      IF  self.path_patch_operation IS NOT NULL
      AND self.path_patch_operation.object_id IS NOT NULL
      THEN
         BEGIN
            EXECUTE IMMEDIATE
               'SELECT '
            || 'a.operationtyp.toYAML( '
            || '    p_pretty_print   => :p01 + 1 '
            || '   ,p_force_inline   => :p02 '
            || '   ,p_short_id       => :p03 '
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
            ,self.path_patch_operation.object_type_id
            ,self.path_patch_operation.object_id;
            
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_tmp := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'patch: ' 
            ,p_pretty_print
            ,'  '
         ) || clb_tmp;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Write the trace operation
      --------------------------------------------------------------------------
      IF  self.path_trace_operation IS NOT NULL
      AND self.path_trace_operation.object_id IS NOT NULL
      THEN
         BEGIN
            EXECUTE IMMEDIATE
               'SELECT '
            || 'a.operationtyp.toYAML( '
            || '    p_pretty_print   => :p01 + 1 '
            || '   ,p_force_inline   => :p02 '
            || '   ,p_short_id       => :p03 '
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
            ,self.path_trace_operation.object_type_id
            ,self.path_trace_operation.object_id;
            
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_tmp := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'trace: ' 
            ,p_pretty_print
            ,'  '
         ) || clb_tmp;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Write the server array
      --------------------------------------------------------------------------
      IF  self.path_servers IS NOT NULL 
      AND self.path_servers.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || 'a.servertyp.toJSON( '
         || '    p_pretty_print   => :p01 + 1 '
         || '   ,p_force_inline   => :p02 '
         || '   ,p_short_id       => :p03 '
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
         ,self.path_servers;

         clb_output := clb_output || dz_json_util.pretty_str(
             'servers: '
            ,p_pretty_print + 1
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
      -- Step 130
      -- Write the parameters map
      --------------------------------------------------------------------------
      IF  self.path_parameters IS NOT NULL 
      AND self.path_parameters.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.parametertyp.toYAML( '
         || '    p_pretty_print   => :p01 + 1 '
         || '   ,p_force_inline   => :p02 '
         || '   ,p_short_id       => :p03 '
         || ' ) '
         || ',b.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p04) b '
         || 'ON '
         || 'a.object_type_id = b.object_type_id '
         || 'a.object_id      = b.object_id '
         || 'WHERE '
         || 'COALESCE(a.parametertyp.parameter_list_hidden,''FALSE'') <> ''TRUE'' '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.path_parameters;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'parameters: '
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
      -- Step 140
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

