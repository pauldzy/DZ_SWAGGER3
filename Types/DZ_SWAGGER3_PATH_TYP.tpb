CREATE OR REPLACE TYPE BODY dz_swagger3_path_typ
AS 

   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_path_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_path_typ;
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_path_typ(
       p_path_id                 IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS 
   BEGIN 
   
      -------------------------------------------------------------------------
      -- Step 10
      -- Load the path object and operations
      -------------------------------------------------------------------------
      BEGIN
         SELECT
         dz_swagger3_path_typ(
             p_hash_key               => a.path_endpoint
            ,p_path_summary           => a.path_summary
            ,p_path_description       => a.path_description
            ,p_path_get_operation     => dz_swagger3_operation_typ(
            
             )
            ,p_path_put_operation     => dz_swagger3_operation_typ(
            
             )
            ,p_path_post_operation    => dz_swagger3_operation_typ(
            
             )
            ,p_path_delete_operation  => dz_swagger3_operation_typ(
            
             )
            ,p_path_options_operation => dz_swagger3_operation_typ(
            
             )
            ,p_path_head_operation    => dz_swagger3_operation_typ(
            
             )
            ,p_path_patch_operation   => dz_swagger3_operation_typ(
            
             )
            ,p_path_trace_operation   => dz_swagger3_operation_typ(
            
             )
            ,p_path_servers           => NULL
            ,p_path_parameters        => NULL
         )
         INTO SELF
         FROM
         dz_swagger3_path a
         WHERE
             a.versionid = p_versionid
         AND a.path_id   = p_path_id;
         
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN;
             
         WHEN OTHERS
         THEN
            RAISE;
            
      END;
      
      RETURN; 
      
   END dz_swagger3_path_typ;

   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_path_typ(
       p_hash_key                IN  VARCHAR2
      ,p_path_summary            IN  VARCHAR2
      ,p_path_description        IN  VARCHAR2
      ,p_path_get_operation      IN  dz_swagger3_operation_typ
      ,p_path_put_operation      IN  dz_swagger3_operation_typ
      ,p_path_post_operation     IN  dz_swagger3_operation_typ
      ,p_path_delete_operation   IN  dz_swagger3_operation_typ
      ,p_path_options_operation  IN  dz_swagger3_operation_typ
      ,p_path_head_operation     IN  dz_swagger3_operation_typ
      ,p_path_patch_operation    IN  dz_swagger3_operation_typ
      ,p_path_trace_operation    IN  dz_swagger3_operation_typ
      ,p_path_servers            IN  dz_swagger3_server_list
      ,p_path_parameters         IN  dz_swagger3_parameter_list
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.hash_key                := p_hash_key;
      self.path_summary            := p_path_summary;
      self.path_description        := p_path_description;
      self.path_get_operation      := p_path_get_operation;
      self.path_put_operation      := p_path_put_operation;
      self.path_post_operation     := p_path_post_operation;
      self.path_delete_operation   := p_path_delete_operation;
      self.path_options_operation  := p_path_options_operation;
      self.path_head_operation     := p_path_head_operation;
      self.path_patch_operation    := p_path_patch_operation;
      self.path_trace_operation    := p_path_trace_operation;
      self.path_servers            := p_path_servers;
      self.path_parameters         := p_path_parameters;
      
      RETURN; 
      
   END dz_swagger3_path_typ;
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
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
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   MEMBER FUNCTION key
   RETURN VARCHAR2
   AS
   BEGIN
      RETURN self.hash_key;
      
   END key;
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   MEMBER FUNCTION path_parameters_keys
   RETURN MDSYS.SDO_STRING2_ARRAY
   AS
      int_index  PLS_INTEGER;
      ary_output MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
      IF self.path_parameters IS NULL
      OR self.path_parameters.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := MDSYS.SDO_STRING2_ARRAY();
      FOR i IN 1 .. self.path_parameters.COUNT
      LOOP
         ary_output(int_index) := self.path_parameters(i).hash_key;
      
      END LOOP;
      
      RETURN ary_output;
   
   END path_parameters_keys;
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_hash         CLOB;
      
   BEGIN
      
      -------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      -------------------------------------------------------------------------
      
      -------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      -------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         str_pad     := '';
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;
      
      str_pad1 := str_pad;
      
      -------------------------------------------------------------------------
      -- Step 30
      -- Add path summary
      -------------------------------------------------------------------------
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
      
      -------------------------------------------------------------------------
      -- Step 40
      -- Add path description 
      -------------------------------------------------------------------------
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
      
      -------------------------------------------------------------------------
      -- Step 50
      -- Add get operation
      -------------------------------------------------------------------------
      IF  self.path_get_operation IS NOT NULL
      AND self.path_get_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'get'
               ,self.path_get_operation.toJSON(p_pretty_print + 1)
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      -------------------------------------------------------------------------
      -- Step 60
      -- Add put operation
      -------------------------------------------------------------------------
      IF  self.path_put_operation IS NOT NULL
      AND self.path_put_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'put'
               ,self.path_put_operation.toJSON(p_pretty_print + 1)
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      -------------------------------------------------------------------------
      -- Step 70
      -- Add post operation
      -------------------------------------------------------------------------
      IF  self.path_post_operation IS NOT NULL
      AND self.path_post_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'post'
               ,self.path_post_operation.toJSON(p_pretty_print + 1)
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      -------------------------------------------------------------------------
      -- Step 80
      -- Add delete operation
      -------------------------------------------------------------------------
      IF  self.path_delete_operation IS NOT NULL
      AND self.path_delete_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'delete'
               ,self.path_delete_operation.toJSON(p_pretty_print + 1)
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      -------------------------------------------------------------------------
      -- Step 90
      -- Add options operation
      -------------------------------------------------------------------------
      IF  self.path_options_operation IS NOT NULL
      AND self.path_options_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'options'
               ,self.path_options_operation.toJSON(p_pretty_print + 1)
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      -------------------------------------------------------------------------
      -- Step 100
      -- Add head operation
      -------------------------------------------------------------------------
      IF  self.path_head_operation IS NOT NULL
      AND self.path_head_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'head'
               ,self.path_head_operation.toJSON(p_pretty_print + 1)
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      -------------------------------------------------------------------------
      -- Step 110
      -- Add patch operation
      -------------------------------------------------------------------------
      IF  self.path_patch_operation IS NOT NULL
      AND self.path_patch_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'patch'
               ,self.path_patch_operation.toJSON(p_pretty_print + 1)
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      -------------------------------------------------------------------------
      -- Step 120
      -- Add trace operation
      -------------------------------------------------------------------------
      IF  self.path_trace_operation IS NOT NULL
      AND self.path_trace_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'trace'
               ,self.path_trace_operation.toJSON(p_pretty_print + 1)
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      -------------------------------------------------------------------------
      -- Step 130
      -- Add servers
      -------------------------------------------------------------------------
      IF  self.path_servers IS NULL 
      AND self.path_servers.COUNT = 0
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
      
         FOR i IN 1 .. path_servers.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || self.path_servers(i).toJSON(
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
      
      -------------------------------------------------------------------------
      -- Step 140
      -- Add parameters
      -------------------------------------------------------------------------
      IF  self.path_parameters IS NULL 
      AND self.path_parameters.COUNT = 0
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
      
      
         ary_keys := self.path_parameters_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || dz_json_main.value2json(
                   ary_keys(i)
                  ,self.path_parameters(i).toJSON(
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
              'parameters'
             ,clb_hash
             ,p_pretty_print + 1
          )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';
 
      -------------------------------------------------------------------------
      -- Step 150
      -- Add the left bracket
      -------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      -------------------------------------------------------------------------
      -- Step 160
      -- Cough it out
      -------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
      p_pretty_print      IN  INTEGER   DEFAULT 0
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
   
      -------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      -------------------------------------------------------------------------
      
      -------------------------------------------------------------------------
      -- Step 20
      -- Write the summary
      -------------------------------------------------------------------------
      IF self.path_summary IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'summary: ' || dz_swagger_util.yaml_text(
                self.path_summary
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      -------------------------------------------------------------------------
      -- Step 30
      -- Write the description
      -------------------------------------------------------------------------
      IF self.path_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'description: ' || dz_swagger_util.yaml_text(
                self.path_description
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      -------------------------------------------------------------------------
      -- Step 40
      -- Write the get operation
      -------------------------------------------------------------------------
      IF self.path_get_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'get: ' 
            ,p_pretty_print
            ,'  '
         ) || self.path_get_operation.toYAML(
            p_pretty_print + 1
         );
         
      END IF;
      
      -------------------------------------------------------------------------
      -- Step 50
      -- Write the get operation
      -------------------------------------------------------------------------
      IF self.path_put_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'put: ' 
            ,p_pretty_print
            ,'  '
         ) || self.path_put_operation.toYAML(
            p_pretty_print + 1
         );
         
      END IF;
      
      -------------------------------------------------------------------------
      -- Step 60
      -- Write the post operation
      -------------------------------------------------------------------------
      IF self.path_post_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'post: ' 
            ,p_pretty_print
            ,'  '
         ) || self.path_post_operation.toYAML(
            p_pretty_print + 1
         );
         
      END IF;
      
      -------------------------------------------------------------------------
      -- Step 70
      -- Write the delete operation
      -------------------------------------------------------------------------
      IF self.path_delete_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'delete: ' 
            ,p_pretty_print
            ,'  '
         ) || self.path_delete_operation.toYAML(
            p_pretty_print + 1
         );
         
      END IF;
      
      -------------------------------------------------------------------------
      -- Step 80
      -- Write the options operation
      -------------------------------------------------------------------------
      IF self.path_options_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'options: ' 
            ,p_pretty_print
            ,'  '
         ) || self.path_options_operation.toYAML(
            p_pretty_print + 1
         );
         
      END IF;
      
      -------------------------------------------------------------------------
      -- Step 90
      -- Write the head operation
      -------------------------------------------------------------------------
      IF self.path_head_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'head: ' 
            ,p_pretty_print
            ,'  '
         ) || self.path_head_operation.toYAML(
            p_pretty_print + 1
         );
         
      END IF;
      
      -------------------------------------------------------------------------
      -- Step 100
      -- Write the patch operation
      -------------------------------------------------------------------------
      IF self.path_patch_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'patch: ' 
            ,p_pretty_print
            ,'  '
         ) || self.path_patch_operation.toYAML(
            p_pretty_print + 1
         );
         
      END IF;
      
      -------------------------------------------------------------------------
      -- Step 110
      -- Write the trace operation
      -------------------------------------------------------------------------
      IF self.path_trace_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'trace: ' 
            ,p_pretty_print
            ,'  '
         ) || self.path_trace_operation.toYAML(
            p_pretty_print + 1
         );
         
      END IF;
      
      -------------------------------------------------------------------------
      -- Step 120
      -- Write the server array
      -------------------------------------------------------------------------
      IF  self.path_servers IS NOT NULL 
      AND self.path_servers.COUNT > 0
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'servers: '
            ,p_pretty_print + 1
            ,'  '
         );
         
         FOR i IN 1 .. self.path_servers.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '- '
               ,p_pretty_print + 1
               ,'  '
            ) || self.path_servers(i).toYAML(
               p_pretty_print + 1
            );
            
         END LOOP;
         
      END IF;
      
      -------------------------------------------------------------------------
      -- Step 130
      -- Write the parameters map
      -------------------------------------------------------------------------
      IF  self.path_parameters IS NULL 
      AND self.path_parameters.COUNT = 0
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'parameters: '
            ,p_pretty_print + 1
            ,'  '
         );
         
         ary_keys := self.path_parameters_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '''' || ary_keys(i) || ''': '
               ,p_pretty_print + 2
               ,'  '
            ) || self.path_parameters(i).toYAML(
               p_pretty_print + 3
            );
         
         END LOOP;
         
      END IF;
      
      -------------------------------------------------------------------------
      -- Step 60
      -- Cough it out 
      -------------------------------------------------------------------------
      RETURN clb_output;
      
   END toYAML;
   
END;
/

