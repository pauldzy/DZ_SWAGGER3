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
      BEGIN
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
               ,p_object_order   => a.path_get_operation_order
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
               ,p_object_order   => a.path_put_operation_order
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
               ,p_object_order   => a.path_post_operation_order
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
               ,p_object_order   => a.path_delete_operation_order
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
               ,p_object_order   => a.path_options_operation_order
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
               ,p_object_order   => a.path_head_operation_order
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
               ,p_object_order   => a.path_patch_operation_order
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
               ,p_object_order   => a.path_trace_operation_order
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
         
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RAISE_APPLICATION_ERROR(
                -20001
               ,'path not found for path_id = ' || p_path_id || ' versionid ' || p_versionid
            );
            
         WHEN OTHERS
         THEN
            RAISE;
            
      END;

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
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
      ,p_xorder              IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output                 CLOB;
      clb_path_get_operation     CLOB;
      clb_path_put_operation     CLOB;      
      clb_path_post_operation    CLOB;
      clb_path_delete_operation  CLOB;
      clb_path_options_operation CLOB;
      clb_path_head_operation    CLOB;
      clb_path_patch_operation   CLOB;
      clb_path_trace_operation   CLOB;
      clb_path_servers           CLOB;
      clb_path_parameters        CLOB;
      str_identifier             VARCHAR2(4000 Char);
      int_inject_path_xorder     INTEGER;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------

      --------------------------------------------------------------------------
      -- Step 20
      -- Add the ref object for callbacks
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
         
         SELECT
         JSON_OBJECT(
            '$ref' VALUE '#/components/callbacks/' || str_identifier
         )
         INTO clb_output
         FROM dual;
      
      ELSE
      --------------------------------------------------------------------------
      -- Step 30
      -- Add get operation
      --------------------------------------------------------------------------
         IF  self.path_get_operation IS NOT NULL
         AND self.path_get_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT 
               a.operationtyp.toJSON( 
                   p_force_inline     => p_force_inline
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_xorder           => self.path_get_operation.object_order
               )
               INTO clb_path_get_operation
               FROM 
               dz_swagger3_xobjects a 
               WHERE 
                   a.object_type_id = self.path_get_operation.object_type_id
               AND a.object_id      = self.path_get_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_path_get_operation := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE_APPLICATION_ERROR(
                      -20001
                     ,SQLERRM || self.path_get_operation.object_id
                  );
                  
            END;

         END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Add put operation
      --------------------------------------------------------------------------
         IF  self.path_put_operation IS NOT NULL
         AND self.path_put_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT 
               a.operationtyp.toJSON( 
                   p_force_inline     => p_force_inline 
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_xorder           => self.path_put_operation.object_order
               )
               INTO clb_path_put_operation
               FROM 
               dz_swagger3_xobjects a 
               WHERE
                   a.object_type_id = self.path_put_operation.object_type_id
               AND a.object_id      = self.path_put_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_path_put_operation := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;

         END IF;

      --------------------------------------------------------------------------
      -- Step 50
      -- Add post operation
      --------------------------------------------------------------------------
         IF  self.path_post_operation IS NOT NULL
         AND self.path_post_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT 
               a.operationtyp.toJSON( 
                   p_force_inline     => p_force_inline 
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_xorder           => self.path_post_operation.object_order
               )
               INTO clb_path_post_operation
               FROM 
               dz_swagger3_xobjects a 
               WHERE
                   a.object_type_id = self.path_post_operation.object_type_id
               AND a.object_id      = self.path_post_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_path_post_operation := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;

         END IF;

      --------------------------------------------------------------------------
      -- Step 60
      -- Add delete operation
      --------------------------------------------------------------------------
         IF  self.path_delete_operation IS NOT NULL
         AND self.path_delete_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT 
               a.operationtyp.toJSON( 
                   p_force_inline     => p_force_inline 
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_xorder           => self.path_delete_operation.object_order
               )
               INTO clb_path_delete_operation
               FROM 
               dz_swagger3_xobjects a 
               WHERE
                   a.object_type_id = self.path_delete_operation.object_type_id
               AND a.object_id      = self.path_delete_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_path_delete_operation := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Add options operation
      --------------------------------------------------------------------------
         IF  self.path_options_operation IS NOT NULL
         AND self.path_options_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT 
               a.operationtyp.toJSON( 
                   p_force_inline     => p_force_inline 
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_xorder           => self.path_options_operation.object_order
               )
               INTO clb_path_options_operation
               FROM 
               dz_swagger3_xobjects a 
               WHERE
                   a.object_type_id = self.path_options_operation.object_type_id
               AND a.object_id      = self.path_options_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_path_options_operation := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Add head operation
      --------------------------------------------------------------------------
         IF  self.path_head_operation IS NOT NULL
         AND self.path_head_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT 
               a.operationtyp.toJSON( 
                   p_force_inline     => p_force_inline 
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_xorder           => self.path_head_operation.object_order
               )
               INTO clb_path_head_operation
               FROM 
               dz_swagger3_xobjects a 
               WHERE
                   a.object_type_id = self.path_head_operation.object_type_id
               AND a.object_id      = self.path_head_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_path_head_operation := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Add patch operation
      --------------------------------------------------------------------------
         IF  self.path_patch_operation IS NOT NULL
         AND self.path_patch_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT 
               a.operationtyp.toJSON( 
                   p_force_inline     => p_force_inline 
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_xorder           => self.path_patch_operation.object_order
               )
               INTO clb_path_patch_operation
               FROM 
               dz_swagger3_xobjects a 
               WHERE
                   a.object_type_id = self.path_patch_operation.object_type_id
               AND a.object_id      = self.path_patch_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_path_patch_operation := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Add trace operation
      --------------------------------------------------------------------------
         IF  self.path_trace_operation IS NOT NULL
         AND self.path_trace_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT 
               a.operationtyp.toJSON( 
                   p_force_inline     => p_force_inline 
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_xorder           => self.path_trace_operation.object_order
               )
               INTO clb_path_trace_operation
               FROM 
               dz_swagger3_xobjects a 
               WHERE
                   a.object_type_id = self.path_trace_operation.object_type_id
               AND a.object_id      = self.path_trace_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_path_trace_operation := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;

         END IF;

      --------------------------------------------------------------------------
      -- Step 110
      -- Add servers
      --------------------------------------------------------------------------
         IF  self.path_servers IS NOT NULL 
         AND self.path_servers.COUNT > 0
         THEN
            SELECT
            JSON_ARRAYAGG(
               a.servertyp.toJSON() FORMAT JSON
               ORDER BY b.object_order
               RETURNING CLOB
            )
            INTO clb_path_servers
            FROM
            dz_swagger3_xobjects a
            JOIN
            TABLE(self.path_servers) b
            ON
                a.object_type_id = b.object_type_id
            AND a.object_id      = b.object_id;
            
         END IF;

      --------------------------------------------------------------------------
      -- Step 120
      -- Add parameters
      --------------------------------------------------------------------------
         IF  self.path_parameters IS NOT NULL 
         AND self.path_parameters.COUNT > 0
         THEN
            SELECT
            JSON_ARRAYAGG(
               a.parametertyp.toJSON(
                   p_force_inline     => p_force_inline
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_reference_count  => a.reference_count
               ) FORMAT JSON
               ORDER BY b.object_order
               RETURNING CLOB
            )
            INTO clb_path_parameters
            FROM
            dz_swagger3_xobjects a
            JOIN
            TABLE(self.path_parameters) b
            ON
                a.object_type_id = b.object_type_id
            AND a.object_id      = b.object_id
            WHERE
            COALESCE(a.parametertyp.parameter_list_hidden,'FALSE') <> 'TRUE';
            
         END IF;
         
      --------------------------------------------------------------------------
      -- Step 130
      -- Add the left bracket
      --------------------------------------------------------------------------
         IF dz_swagger3_constants.c_inject_path_xorder
         THEN
            int_inject_path_xorder := 1;
            
         END IF;
         
         SELECT
         JSON_OBJECT(
             'summary'      VALUE self.path_summary
            ,'description'  VALUE self.path_description
            ,'get'          VALUE clb_path_get_operation     FORMAT JSON
            ,'put'          VALUE clb_path_put_operation     FORMAT JSON     
            ,'post'         VALUE clb_path_post_operation    FORMAT JSON
            ,'delete'       VALUE clb_path_delete_operation  FORMAT JSON
            ,'options'      VALUE clb_path_options_operation FORMAT JSON
            ,'head'         VALUE clb_path_head_operation    FORMAT JSON
            ,'patch'        VALUE clb_path_patch_operation   FORMAT JSON
            ,'trace'        VALUE clb_path_trace_operation   FORMAT JSON
            ,'servers'      VALUE clb_path_servers           FORMAT JSON
            ,'parameters'   VALUE clb_path_parameters        FORMAT JSON
            ,'x-order'      VALUE CASE
             WHEN int_inject_path_xorder = 1
             THEN
               p_xorder
             ELSE
               NULL
             END
            ABSENT ON NULL
            RETURNING CLOB
         )
         INTO clb_output
         FROM dual;

      END IF;

      --------------------------------------------------------------------------
      -- Step 140
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
END;
/

