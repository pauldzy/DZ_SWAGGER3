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
      --dbms_output.put_line('path: ' || p_path_id);
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
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      cb               CLOB;
      v2               VARCHAR2(32000);
      
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_tmp          CLOB;
      str_identifier   VARCHAR2(255 Char);
      
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
      -- Add  the ref object for callbacks
      --------------------------------------------------------------------------
      IF  COALESCE(p_force_inline,'FALSE') = 'FALSE'
      AND p_reference_count > 1
      THEN
         IF p_short_id = 'TRUE'
         THEN
            str_identifier := p_short_identifier;
            
         ELSE
            str_identifier := p_identifier;
            
         END IF;

         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => str_pad1 || dz_json_main.value2json(
                '$ref'
               ,'#/components/callbacks/' || dz_swagger3_util.utl_url_escape(
                  str_identifier
                )
               ,p_pretty_print + 1
            )
            ,p_pretty_print => p_pretty_print + 1
         );
         str_pad1 := ',';
      
      ELSE
      --------------------------------------------------------------------------
      -- Step 40
      -- Add path summary
      --------------------------------------------------------------------------
         IF self.path_summary IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => str_pad1 || dz_json_main.value2json(
                   'summary'
                  ,self.path_summary
                  ,p_pretty_print + 1
                )
               ,p_pretty_print => p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add path description 
      --------------------------------------------------------------------------
         IF self.path_description IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => str_pad1 || dz_json_main.value2json(
                   'description'
                  ,self.path_description
                  ,p_pretty_print + 1
                )
               ,p_pretty_print => p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add get operation
      --------------------------------------------------------------------------
         IF  self.path_get_operation IS NOT NULL
         AND self.path_get_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT 
               a.operationtyp.toJSON( 
                   p_pretty_print     => p_pretty_print + 1 
                  ,p_force_inline     => p_force_inline 
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
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
         
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => str_pad1 || '"get":' || str_pad
               ,p_pretty_print => p_pretty_print + 1
               ,p_final_linefeed => FALSE
            );

            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => clb_tmp
               ,p_in_v => NULL
               ,p_pretty_print => p_pretty_print + 1
               ,p_initial_indent => FALSE
            );

            str_pad1 := ',';

         END IF;

      --------------------------------------------------------------------------
      -- Step 70
      -- Add put operation
      --------------------------------------------------------------------------
         IF  self.path_put_operation IS NOT NULL
         AND self.path_put_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT 
               a.operationtyp.toJSON( 
                   p_pretty_print     => p_pretty_print + 1 
                  ,p_force_inline     => p_force_inline 
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
               )
               INTO clb_tmp
               FROM 
               dz_swagger3_xobjects a 
               WHERE
                   a.object_type_id = self.path_put_operation.object_type_id
               AND a.object_id      = self.path_put_operation.object_id;
               
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
               ,p_in_v => str_pad1 || '"put":' || str_pad
               ,p_pretty_print => p_pretty_print + 1
               ,p_final_linefeed => FALSE
            );

            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => clb_tmp
               ,p_in_v => NULL
               ,p_pretty_print => p_pretty_print + 1
               ,p_initial_indent => FALSE
            );
            
            str_pad1 := ',';

         END IF;

      --------------------------------------------------------------------------
      -- Step 80
      -- Add post operation
      --------------------------------------------------------------------------
         IF  self.path_post_operation IS NOT NULL
         AND self.path_post_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT 
               a.operationtyp.toJSON( 
                   p_pretty_print     => p_pretty_print + 1 
                  ,p_force_inline     => p_force_inline 
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
               )
               INTO clb_tmp
               FROM 
               dz_swagger3_xobjects a 
               WHERE
                   a.object_type_id = self.path_post_operation.object_type_id
               AND a.object_id      = self.path_post_operation.object_id;
               
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
               ,p_in_v => str_pad1 || '"post":' || str_pad
               ,p_pretty_print => p_pretty_print + 1
               ,p_final_linefeed => FALSE
            );

            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => clb_tmp
               ,p_in_v => NULL
               ,p_pretty_print => p_pretty_print + 1
               ,p_initial_indent => FALSE
            );
            
            str_pad1 := ',';

         END IF;

      --------------------------------------------------------------------------
      -- Step 90
      -- Add delete operation
      --------------------------------------------------------------------------
         IF  self.path_delete_operation IS NOT NULL
         AND self.path_delete_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT 
               a.operationtyp.toJSON( 
                   p_pretty_print     => p_pretty_print + 1 
                  ,p_force_inline     => p_force_inline 
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
               )
               INTO clb_tmp
               FROM 
               dz_swagger3_xobjects a 
               WHERE
                   a.object_type_id = self.path_delete_operation.object_type_id
               AND a.object_id      = self.path_delete_operation.object_id;
               
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
               ,p_in_v => str_pad1 || '"delete":' || str_pad
               ,p_pretty_print => p_pretty_print + 1
               ,p_final_linefeed => FALSE
            );

            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => clb_tmp
               ,p_in_v => NULL
               ,p_pretty_print => p_pretty_print + 1
               ,p_initial_indent => FALSE
            );
            
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Add options operation
      --------------------------------------------------------------------------
         IF  self.path_options_operation IS NOT NULL
         AND self.path_options_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT 
               a.operationtyp.toJSON( 
                   p_pretty_print     => p_pretty_print + 1 
                  ,p_force_inline     => p_force_inline 
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
               )
               INTO clb_tmp
               FROM 
               dz_swagger3_xobjects a 
               WHERE
                   a.object_type_id = self.path_options_operation.object_type_id
               AND a.object_id      = self.path_options_operation.object_id;
               
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
               ,p_in_v => str_pad1 || '"options":' || str_pad
               ,p_pretty_print => p_pretty_print + 1
               ,p_final_linefeed => FALSE
            );

            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => clb_tmp
               ,p_in_v => NULL
               ,p_pretty_print => p_pretty_print + 1
               ,p_initial_indent => FALSE
            );
            
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Add head operation
      --------------------------------------------------------------------------
         IF  self.path_head_operation IS NOT NULL
         AND self.path_head_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT 
               a.operationtyp.toJSON( 
                   p_pretty_print     => p_pretty_print + 1 
                  ,p_force_inline     => p_force_inline 
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
               )
               INTO clb_tmp
               FROM 
               dz_swagger3_xobjects a 
               WHERE
                   a.object_type_id = self.path_head_operation.object_type_id
               AND a.object_id      = self.path_head_operation.object_id;
               
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
               ,p_in_v => str_pad1 || '"head":' || str_pad
               ,p_pretty_print => p_pretty_print + 1
               ,p_final_linefeed => FALSE
            );

            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => clb_tmp
               ,p_in_v => NULL
               ,p_pretty_print => p_pretty_print + 1
               ,p_initial_indent => FALSE
            );
            
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Add patch operation
      --------------------------------------------------------------------------
         IF  self.path_patch_operation IS NOT NULL
         AND self.path_patch_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT 
               a.operationtyp.toJSON( 
                   p_pretty_print     => p_pretty_print + 1 
                  ,p_force_inline     => p_force_inline 
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
               )
               INTO clb_tmp
               FROM 
               dz_swagger3_xobjects a 
               WHERE
                   a.object_type_id = self.path_patch_operation.object_type_id
               AND a.object_id      = self.path_patch_operation.object_id;
               
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
               ,p_in_v => str_pad1 || '"patch":' || str_pad
               ,p_pretty_print => p_pretty_print + 1
               ,p_final_linefeed => FALSE
            );

            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => clb_tmp
               ,p_in_v => NULL
               ,p_pretty_print => p_pretty_print + 1
               ,p_initial_indent => FALSE
            );
            
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 130
      -- Add trace operation
      --------------------------------------------------------------------------
         IF  self.path_trace_operation IS NOT NULL
         AND self.path_trace_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT 
               a.operationtyp.toJSON( 
                   p_pretty_print     => p_pretty_print + 1 
                  ,p_force_inline     => p_force_inline 
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
               )
               INTO clb_tmp
               FROM 
               dz_swagger3_xobjects a 
               WHERE
                   a.object_type_id = self.path_trace_operation.object_type_id
               AND a.object_id      = self.path_trace_operation.object_id;
               
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
               ,p_in_v => str_pad1 || '"trace":' || str_pad
               ,p_pretty_print => p_pretty_print + 1
               ,p_final_linefeed => FALSE
            );

            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => clb_tmp
               ,p_in_v => NULL
               ,p_pretty_print => p_pretty_print + 1
               ,p_initial_indent => FALSE
            );
            
            str_pad1 := ',';

         END IF;

      --------------------------------------------------------------------------
      -- Step 140
      -- Add servers
      --------------------------------------------------------------------------
         IF  self.path_servers IS NOT NULL 
         AND self.path_servers.COUNT > 0
         THEN
            SELECT
            a.servertyp.toJSON(
                p_pretty_print   => p_pretty_print + 1
               ,p_force_inline   => p_force_inline
               ,p_short_id       => p_short_id
            )
            BULK COLLECT INTO ary_clb
            FROM
            dz_swagger3_xobjects a
            JOIN
            TABLE(self.path_servers) b
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
                  ,p_in_v => str_pad1 || '"servers":' || str_pad || '['
                  ,p_pretty_print => p_pretty_print + 1
               );
            
               str_pad2 := str_pad;
            
               FOR i IN 1 .. ary_clb.COUNT
               LOOP
                  dz_swagger3_util.conc(
                      p_c    => cb
                     ,p_v    => v2
                     ,p_in_c => NULL
                     ,p_in_v => str_pad2
                     ,p_pretty_print => p_pretty_print + 2
                     ,p_final_linefeed => FALSE
                  );
                  
                  dz_swagger3_util.conc(
                      p_c    => cb
                     ,p_v    => v2
                     ,p_in_c => ary_clb(i)
                     ,p_in_v => NULL
                     ,p_pretty_print => p_pretty_print + 2
                     ,p_initial_indent => FALSE
                  );
                  
                  str_pad2 := ',';
               
               END LOOP;
               
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v => ']'
                  ,p_pretty_print => p_pretty_print + 1
               );   

               str_pad1 := ',';
               
            END IF;
            
         END IF;

      --------------------------------------------------------------------------
      -- Step 150
      -- Add parameters
      --------------------------------------------------------------------------
         IF  self.path_parameters IS NOT NULL 
         AND self.path_parameters.COUNT > 0
         THEN
            SELECT
             a.parametertyp.toJSON(
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
            TABLE(self.path_parameters) b
            ON
                a.object_type_id = b.object_type_id
            AND a.object_id      = b.object_id
            WHERE
            COALESCE(a.parametertyp.parameter_list_hidden,'FALSE') <> 'TRUE'
            ORDER BY b.object_order;
            
            IF  ary_keys IS NOT NULL
            AND ary_keys.COUNT > 0
            THEN
               str_pad2 := str_pad;
                          
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v => str_pad1 || '"parameters":' || str_pad || '['
                  ,p_pretty_print => p_pretty_print + 1
               );
            
               FOR i IN 1 .. ary_clb.COUNT
               LOOP
                  dz_swagger3_util.conc(
                      p_c    => cb
                     ,p_v    => v2
                     ,p_in_c => NULL
                     ,p_in_v => str_pad2
                     ,p_pretty_print => p_pretty_print + 2
                     ,p_final_linefeed => FALSE
                  );
                  
                  dz_swagger3_util.conc(
                      p_c    => cb
                     ,p_v    => v2
                     ,p_in_c => ary_clb(i)
                     ,p_in_v => NULL
                     ,p_pretty_print => p_pretty_print + 2
                     ,p_initial_indent => FALSE
                  );
                  
                  str_pad2 := ',';
               
               END LOOP;
               
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v => ']'
                  ,p_pretty_print => p_pretty_print + 1
               );   

               str_pad1 := ',';
               
            END IF;
            
         END IF;

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 160
      -- Add the left bracket
      --------------------------------------------------------------------------
      dz_swagger3_util.conc(
          p_c    => cb
         ,p_v    => v2
         ,p_in_c => NULL
         ,p_in_v => '}'
         ,p_pretty_print   => p_pretty_print
         ,p_final_linefeed => FALSE
      );

      --------------------------------------------------------------------------
      -- Step 170
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
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      cb               CLOB;
      v2               VARCHAR2(32000);

      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_tmp          CLOB;
      str_identifier   VARCHAR2(255 Char);
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      IF  COALESCE(p_force_inline,'FALSE') = 'FALSE'
      AND p_reference_count > 1
      THEN
         IF p_short_id = 'TRUE'
         THEN
            str_identifier := p_short_identifier;
            
         ELSE
            str_identifier := p_identifier;
            
         END IF;
         
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => '$ref: ' || dz_swagger3_util.yaml_text(
               '#/components/callbacks/' || str_identifier
             )
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );
  
      ELSE
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the summary
      --------------------------------------------------------------------------
         IF self.path_summary IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'summary: ' || dz_swagger3_util.yaml_text(
                   self.path_summary
                  ,p_pretty_print
                )
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the description
      --------------------------------------------------------------------------
         IF self.path_description IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'description: ' || dz_swagger3_util.yaml_text(
                   self.path_description
                  ,p_pretty_print
                )
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
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
               SELECT
               a.operationtyp.toYAML(
                   p_pretty_print     => p_pretty_print + 1
                  ,p_force_inline     => p_force_inline
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
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
                  RAISE;
                  
            END;

            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'get: '
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
      -- Step 50
      -- Write the get operation
      --------------------------------------------------------------------------
         IF  self.path_put_operation IS NOT NULL
         AND self.path_put_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT
               a.operationtyp.toYAML(
                   p_pretty_print     => p_pretty_print + 1
                  ,p_force_inline     => p_force_inline
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
               )
               INTO clb_tmp 
               FROM
               dz_swagger3_xobjects a
               WHERE
                   a.object_type_id = self.path_put_operation.object_type_id
               AND a.object_id      = self.path_put_operation.object_id;
               
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
               ,p_in_v => 'put: '
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
      -- Step 60
      -- Write the post operation
      --------------------------------------------------------------------------
         IF  self.path_post_operation IS NOT NULL
         AND self.path_post_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT
               a.operationtyp.toYAML(
                   p_pretty_print     => p_pretty_print + 1
                  ,p_force_inline     => p_force_inline
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
               )
               INTO clb_tmp 
               FROM
               dz_swagger3_xobjects a
               WHERE
                   a.object_type_id = self.path_post_operation.object_type_id
               AND a.object_id      = self.path_post_operation.object_id;
               
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
               ,p_in_v => 'post: '
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
      -- Step 70
      -- Write the delete operation
      --------------------------------------------------------------------------
         IF  self.path_delete_operation IS NOT NULL
         AND self.path_delete_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT
               a.operationtyp.toYAML(
                   p_pretty_print     => p_pretty_print + 1
                  ,p_force_inline     => p_force_inline
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
               )
               INTO clb_tmp 
               FROM
               dz_swagger3_xobjects a
               WHERE
                   a.object_type_id = self.path_delete_operation.object_type_id
               AND a.object_id      = self.path_delete_operation.object_id;
               
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
               ,p_in_v => 'delete: '
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
      -- Step 80
      -- Write the options operation
      --------------------------------------------------------------------------
         IF  self.path_options_operation IS NOT NULL
         AND self.path_options_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT
               a.operationtyp.toYAML(
                   p_pretty_print     => p_pretty_print + 1
                  ,p_force_inline     => p_force_inline
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
               )
               INTO clb_tmp 
               FROM
               dz_swagger3_xobjects a
               WHERE
                   a.object_type_id = self.path_options_operation.object_type_id
               AND a.object_id      = self.path_options_operation.object_id;
               
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
               ,p_in_v => 'options: '
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
      -- Step 90
      -- Write the head operation
      --------------------------------------------------------------------------
         IF  self.path_head_operation IS NOT NULL
         AND self.path_head_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT
               a.operationtyp.toYAML(
                   p_pretty_print     => p_pretty_print + 1
                  ,p_force_inline     => p_force_inline
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
               )
               INTO clb_tmp 
               FROM
               dz_swagger3_xobjects a
               WHERE
                   a.object_type_id = self.path_head_operation.object_type_id
               AND a.object_id      = self.path_head_operation.object_id;
               
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
               ,p_in_v => 'head: '
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
      -- Step 100
      -- Write the patch operation
      --------------------------------------------------------------------------
         IF  self.path_patch_operation IS NOT NULL
         AND self.path_patch_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT
               a.operationtyp.toYAML(
                   p_pretty_print     => p_pretty_print + 1
                  ,p_force_inline     => p_force_inline
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
               )
               INTO clb_tmp 
               FROM
               dz_swagger3_xobjects a
               WHERE
                   a.object_type_id = self.path_patch_operation.object_type_id
               AND a.object_id      = self.path_patch_operation.object_id;
               
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
               ,p_in_v => 'patch: '
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
      -- Step 110
      -- Write the trace operation
      --------------------------------------------------------------------------
         IF  self.path_trace_operation IS NOT NULL
         AND self.path_trace_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT
               a.operationtyp.toYAML(
                   p_pretty_print     => p_pretty_print + 1
                  ,p_force_inline     => p_force_inline
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
               )
               INTO clb_tmp 
               FROM
               dz_swagger3_xobjects a
               WHERE
                   a.object_type_id = self.path_trace_operation.object_type_id
               AND a.object_id      = self.path_trace_operation.object_id;
               
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
               ,p_in_v => 'trace: '
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
      -- Step 120
      -- Write the server array
      --------------------------------------------------------------------------
         IF  self.path_servers IS NOT NULL 
         AND self.path_servers.COUNT > 0
         THEN
            SELECT
            a.servertyp.toJSON(
                p_pretty_print   => p_pretty_print + 1
               ,p_force_inline   => p_force_inline
               ,p_short_id       => p_short_id
            )
            BULK COLLECT INTO ary_clb
            FROM
            dz_swagger3_xobjects a
            JOIN
            TABLE(self.path_servers) b
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
      -- Step 130
      -- Write the parameters map
      --------------------------------------------------------------------------
         IF  self.path_parameters IS NOT NULL 
         AND self.path_parameters.COUNT > 0
         THEN
            SELECT
             a.parametertyp.toYAML(
                p_pretty_print     => p_pretty_print + 1
               ,p_initial_indent   => 'FALSE'
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
            TABLE(self.path_parameters) b
            ON
                a.object_type_id = b.object_type_id
            AND a.object_id      = b.object_id
            WHERE
            COALESCE(a.parametertyp.parameter_list_hidden,'FALSE') <> 'TRUE'
            ORDER BY b.object_order;
            
            IF  ary_keys IS NOT NULL
            AND ary_keys.COUNT > 0
            THEN
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v => 'parameters: '
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
            
         END IF;
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 140
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

