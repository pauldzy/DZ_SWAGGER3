CREATE OR REPLACE TYPE BODY dz_swagger3_callback_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_callback_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_callback_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_callback_typ(
       p_hash_key                IN  VARCHAR2
      ,p_callback_id             IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
      ,p_load_components         IN  VARCHAR2 DEFAULT 'TRUE'
      ,p_ref_brake               IN  VARCHAR2 DEFAULT 'FALSE'
   ) RETURN SELF AS RESULT
   AS
   BEGIN
   
      SELECT
      dz_swagger3_callback_typ(
          p_hash_key                => p_hash_key
         ,p_callback_id             => p_callback_id
         ,p_path_summary            => NULL
         ,p_path_description        => NULL
         ,p_path_get_operation      => NULL
         ,p_path_put_operation      => NULL
         ,p_path_post_operation     => NULL
         ,p_path_delete_operation   => NULL
         ,p_path_options_operation  => NULL
         ,p_path_head_operation     => NULL
         ,p_path_patch_operation    => NULL
         ,p_path_trace_operation    => NULL
         ,p_path_servers            => NULL
         ,p_path_parameters         => NULL
         ,p_load_components         => p_load_components
      )
      INTO SELF
      FROM
      dual;
      
      RETURN; 
      
   END dz_swagger3_callback_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_callback_typ(
       p_hash_key                IN  VARCHAR2
      ,p_callback_id             IN  VARCHAR2
      ,p_path_summary            IN  VARCHAR2
      ,p_path_description        IN  VARCHAR2
      ,p_path_get_operation      IN  dz_swagger3_cboperation_typ
      ,p_path_put_operation      IN  dz_swagger3_cboperation_typ
      ,p_path_post_operation     IN  dz_swagger3_cboperation_typ
      ,p_path_delete_operation   IN  dz_swagger3_cboperation_typ
      ,p_path_options_operation  IN  dz_swagger3_cboperation_typ
      ,p_path_head_operation     IN  dz_swagger3_cboperation_typ
      ,p_path_patch_operation    IN  dz_swagger3_cboperation_typ
      ,p_path_trace_operation    IN  dz_swagger3_cboperation_typ
      ,p_path_servers            IN  dz_swagger3_server_list
      ,p_path_parameters         IN  dz_swagger3_parameter_list
      ,p_load_components         IN  VARCHAR2 DEFAULT 'TRUE'
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.hash_key                := p_hash_key;
      self.callback_id             := p_callback_id;
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
      
      --------------------------------------------------------------------------
      IF self.doREF() = 'TRUE'
      AND p_load_components = 'TRUE'
      THEN
         dz_swagger3_main.insert_component(
             p_object_id     => p_callback_id
            ,p_object_type   => 'callback'
            ,p_response_code => p_hash_key
         );
         
      END IF;
      
      RETURN; 
      
   END dz_swagger3_callback_typ;
   
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
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION doRef
   RETURN VARCHAR2
   AS
   BEGIN
      RETURN 'TRUE';
      
   END doRef;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
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
         ary_output.EXTEND();
         ary_output(int_index) := self.path_parameters(i).hash_key;
         int_index := int_index + 1;
      
      END LOOP;
      
      RETURN ary_output;
   
   END path_parameters_keys;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
   BEGIN
   
      IF  self.doREF() = 'TRUE'
      AND p_force_inline <> 'TRUE'
      THEN
         RETURN toJSON_ref(
             p_pretty_print  => p_pretty_print
         );
   
      ELSE
         RETURN toJSON_schema(
             p_pretty_print  => p_pretty_print
         );
      
      END IF;
   
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON_schema(
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
      AND self.path_get_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'get'
               ,self.path_get_operation.toJSON(
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
      -- Step 60
      -- Add put operation
      --------------------------------------------------------------------------
      IF  self.path_put_operation IS NOT NULL
      AND self.path_put_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'put'
               ,self.path_put_operation.toJSON(
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
      -- Step 70
      -- Add post operation
      --------------------------------------------------------------------------
      IF  self.path_post_operation IS NOT NULL
      AND self.path_post_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'post'
               ,self.path_post_operation.toJSON(
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
      -- Add delete operation
      --------------------------------------------------------------------------
      IF  self.path_delete_operation IS NOT NULL
      AND self.path_delete_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'delete'
               ,self.path_delete_operation.toJSON(
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
      -- Step 90
      -- Add options operation
      --------------------------------------------------------------------------
      IF  self.path_options_operation IS NOT NULL
      AND self.path_options_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'options'
               ,self.path_options_operation.toJSON(
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
      -- Step 100
      -- Add head operation
      --------------------------------------------------------------------------
      IF  self.path_head_operation IS NOT NULL
      AND self.path_head_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'head'
               ,self.path_head_operation.toJSON(
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
      -- Step 110
      -- Add patch operation
      --------------------------------------------------------------------------
      IF  self.path_patch_operation IS NOT NULL
      AND self.path_patch_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'patch'
               ,self.path_patch_operation.toJSON(
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
      -- Step 120
      -- Add trace operation
      --------------------------------------------------------------------------
      IF  self.path_trace_operation IS NOT NULL
      AND self.path_trace_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'trace'
               ,self.path_trace_operation.toJSON(
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
      -- Step 130
      -- Add servers
      --------------------------------------------------------------------------
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
                   p_pretty_print   => p_pretty_print + 1
                  ,p_force_inline   => p_force_inline
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
      -- Step 140
      -- Add parameters
      --------------------------------------------------------------------------
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
                str_pad2 || '"' || ary_keys(i) || '":' || str_pad || self.path_parameters(i).toJSON(
                   p_pretty_print   => p_pretty_print + 2
                  ,p_force_inline   => p_force_inline
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
           
   END toJSON_schema;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON_ref(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
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
      -- Add optional description
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.value2json(
             '$ref'
            ,'#/components/callbacks/' || dz_swagger3_main.short(
                p_object_id   => self.callback_id
               ,p_object_type => 'callback'
             )
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
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS      
   BEGIN
   
      IF self.doRef() = 'TRUE'
      THEN
         RETURN self.toYAML_ref(
             p_pretty_print    => p_pretty_print
            ,p_initial_indent  => p_initial_indent
            ,p_final_linefeed  => p_final_linefeed
            ,p_force_inline    => p_force_inline
         );
         
      ELSE
         RETURN self.toYAML_schema(
             p_pretty_print    => p_pretty_print
            ,p_initial_indent  => p_initial_indent
            ,p_final_linefeed  => p_final_linefeed
            ,p_force_inline    => p_force_inline
         );
      
      END IF;
   
   END toYAML;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML_schema(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
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
      IF self.path_get_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'get: ' 
            ,p_pretty_print
            ,'  '
         ) || self.path_get_operation.toYAML(
             p_pretty_print   => p_pretty_print + 1
            ,p_force_inline   => p_force_inline
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the get operation
      --------------------------------------------------------------------------
      IF self.path_put_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'put: ' 
            ,p_pretty_print
            ,'  '
         ) || self.path_put_operation.toYAML(
             p_pretty_print   => p_pretty_print + 1
            ,p_force_inline   => p_force_inline
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Write the post operation
      --------------------------------------------------------------------------
      IF self.path_post_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'post: ' 
            ,p_pretty_print
            ,'  '
         ) || self.path_post_operation.toYAML(
             p_pretty_print   => p_pretty_print + 1
            ,p_force_inline   => p_force_inline
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Write the delete operation
      --------------------------------------------------------------------------
      IF self.path_delete_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'delete: ' 
            ,p_pretty_print
            ,'  '
         ) || self.path_delete_operation.toYAML(
             p_pretty_print   => p_pretty_print + 1
            ,p_force_inline   => p_force_inline
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Write the options operation
      --------------------------------------------------------------------------
      IF self.path_options_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'options: ' 
            ,p_pretty_print
            ,'  '
         ) || self.path_options_operation.toYAML(
             p_pretty_print   => p_pretty_print + 1
            ,p_force_inline   => p_force_inline
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Write the head operation
      --------------------------------------------------------------------------
      IF self.path_head_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'head: ' 
            ,p_pretty_print
            ,'  '
         ) || self.path_head_operation.toYAML(
             p_pretty_print   => p_pretty_print + 1
            ,p_force_inline   => p_force_inline
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Write the patch operation
      --------------------------------------------------------------------------
      IF self.path_patch_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'patch: ' 
            ,p_pretty_print
            ,'  '
         ) || self.path_patch_operation.toYAML(
             p_pretty_print   => p_pretty_print + 1
            ,p_force_inline   => p_force_inline
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Write the trace operation
      --------------------------------------------------------------------------
      IF self.path_trace_operation.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'trace: ' 
            ,p_pretty_print
            ,'  '
         ) || self.path_trace_operation.toYAML(
             p_pretty_print   => p_pretty_print + 1
            ,p_force_inline   => p_force_inline
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Write the server array
      --------------------------------------------------------------------------
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
                p_pretty_print   => p_pretty_print + 1
               ,p_force_inline   => p_force_inline
            );
            
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 130
      -- Write the parameters map
      --------------------------------------------------------------------------
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
                p_pretty_print   => p_pretty_print + 3
               ,p_force_inline   => p_force_inline
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
      
   END toYAML_schema;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML_ref(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
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
      clb_output := clb_output || dz_json_util.pretty_str(
          '$ref: ' || dz_swagger3_util.yaml_text(
             '#/components/callbacks/' || dz_swagger3_main.short(
                p_object_id   => self.callback_id
               ,p_object_type => 'callback'
             )
            ,p_pretty_print
         )
         ,p_pretty_print
         ,'  '
      );
      
      --------------------------------------------------------------------------
      -- Step 30
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

