CREATE OR REPLACE TYPE BODY dz_swagger3_operation_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_operation_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_operation_typ;
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_operation_typ(
       p_operation_id            IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS 
   BEGIN 
      
      -------------------------------------------------------------------------
      -- Step 10
      -- Load the operation type
      -------------------------------------------------------------------------
      BEGIN
         SELECT
         dz_swagger3_operation_typ(
             p_hash_key               => a.operation_type
            ,p_operation_tags         => NULL
            ,p_operation_summary      => a.operation_summary
            ,p_operation_description  => a.operation_description
            ,p_operation_externalDocs => dz_swagger3_extrdocs_typ(
                p_externaldoc_id      => a.operation_externaldocs_id
               ,p_versionid           => p_versionid
             )
            ,p_operation_operationID  => a.operation_operationID
            ,p_operation_parameters   => NULL
            ,p_operation_requestBody  => NULL
            ,p_operation_responses    => NULL
            ,p_operation_callbacks    => NULL
            ,p_operation_deprecated   => a.operation_deprecated
            ,p_operation_security     => NULL
            ,p_operation_servers      => NULL
         )
         INTO SELF
         FROM
         dz_swagger3_operation a
         WHERE
             a.versionid    = p_versionid
         AND a.operation_id = p_operation_id;

      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN;
             
         WHEN OTHERS
         THEN
            RAISE;
            
      END;
      
      -------------------------------------------------------------------------
      -- Step 20
      -- Add any required tags
      -------------------------------------------------------------------------
      SELECT
      a.tag_name
      BULK COLLECT INTO self.operation_tags
      FROM
      dz_swagger3_operation_tag_map a
      WHERE
          a.versionid    = p_versionid
      AND a.operation_id = p_operation_id
      ORDER by
      a.tag_name;
      
      -------------------------------------------------------------------------
      -- Step 30
      -- Add any parameters
      -------------------------------------------------------------------------
      SELECT
      dz_swagger3_parameter_typ(
          p_hash_key                  => a.parameter_name
         ,p_parameter_id              => a.parameter_id
         ,p_parameter_name            => a.parameter_name
         ,p_parameter_in              => a.parameter_in
         ,p_parameter_description     => a.parameter_description
         ,p_parameter_required        => a.parameter_required
         ,p_parameter_deprecated      => a.parameter_deprecated
         ,p_parameter_allowEmptyValue => a.parameter_allowEmptyValue
         ,p_parameter_style           => a.parameter_style
         ,p_parameter_explode         => a.parameter_explode
         ,p_parameter_allowReserved   => a.parameter_allowReserved
         ,p_parameter_schema          => NULL
         ,p_parameter_example_string  => a.parameter_example_string
         ,p_parameter_example_number  => a.parameter_example_number
         ,p_parameter_examples        => NULL
      )
      BULK COLLECT INTO self.operation_parameters
      FROM
      dz_swagger3_parameter a
      JOIN
      dz_swagger3_parm_parent_map b
      ON
          a.versionid = b.versionid
      AND a.parameter_id = b.parameter_id
      WHERE
          b.versionid = p_versionid
      AND b.parent_id = p_operation_id
      ORDER BY
      b.parameter_order;
      
      -------------------------------------------------------------------------
      -- Step 40
      -- Add the requestBody
      -------------------------------------------------------------------------
      
      -------------------------------------------------------------------------
      -- Step 50
      -- Add the responses
      -------------------------------------------------------------------------
      SELECT
      dz_swagger3_response_typ(
          p_hash_key               => a.response_code
         ,p_response_description   => b.response_description
         ,p_response_headers       => NULL
         ,p_response_content       => NULL
         ,p_response_links         => NULL
      )
      BULK COLLECT INTO self.operation_responses
      FROM
      dz_swagger3_operation_resp_map a
      JOIN
      dz_swagger3_response b
      ON
          a.versionid   = b.versionid
      AND a.response_id = b.response_id
      WHERE
          a.versionid    = p_versionid
      AND a.operation_id = p_operation_id
      ORDER BY
      a.response_order;
      
      -------------------------------------------------------------------------
      -- Step 60
      -- Add any callbacks
      -------------------------------------------------------------------------
      
      -------------------------------------------------------------------------
      -- Step 70
      -- Add any security
      -------------------------------------------------------------------------
      
      -------------------------------------------------------------------------
      -- Step 80
      -- Add any servers
      -------------------------------------------------------------------------
      SELECT
      dz_swagger3_server_typ(
          p_server_id    => a.server_id
         ,p_versionid    => p_versionid
      )
      BULK COLLECT INTO self.operation_servers
      FROM
      dz_swagger3_server_parent_map a
      WHERE
          a.versionid = p_versionid
      AND a.parent_id = p_operation_id;
      
      -------------------------------------------------------------------------
      -- Step 90
      -- Return the completed object
      -------------------------------------------------------------------------
      RETURN;       
      
   END dz_swagger3_operation_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_operation_typ(
       p_hash_key                IN  VARCHAR2
      ,p_operation_tags          IN  MDSYS.SDO_STRING2_ARRAY
      ,p_operation_summary       IN  VARCHAR2
      ,p_operation_description   IN  VARCHAR2
      ,p_operation_externalDocs  IN  dz_swagger3_extrdocs_typ
      ,p_operation_operationId   IN  VARCHAR2
      ,p_operation_parameters    IN  dz_swagger3_parameter_list
      ,p_operation_requestBody   IN  dz_swagger3_requestbody_typ
      ,p_operation_responses     IN  dz_swagger3_response_list
      ,p_operation_callbacks     IN  dz_swagger3_callback_list
      ,p_operation_deprecated    IN  VARCHAR2
      ,p_operation_security      IN  dz_swagger3_security_req_list
      ,p_operation_servers       IN  dz_swagger3_server_list
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.hash_key                := p_hash_key;
      self.operation_tags          := p_operation_tags;
      self.operation_summary       := p_operation_summary;
      self.operation_description   := p_operation_description;
      self.operation_externalDocs  := p_operation_externalDocs;
      self.operation_operationId   := p_operation_operationId;
      self.operation_parameters    := p_operation_parameters;
      self.operation_requestBody   := p_operation_requestBody;
      self.operation_responses     := p_operation_responses;
      self.operation_callbacks     := p_operation_callbacks;
      self.operation_deprecated    := p_operation_deprecated;
      self.operation_security      := p_operation_security;
      self.operation_servers       := p_operation_servers;
      
      RETURN; 
      
   END dz_swagger3_operation_typ;
   
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
   MEMBER FUNCTION operation_responses_keys
   RETURN MDSYS.SDO_STRING2_ARRAY
   AS
      int_index  PLS_INTEGER;
      ary_output MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
      IF self.operation_responses IS NULL
      OR self.operation_responses.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := MDSYS.SDO_STRING2_ARRAY();
      FOR i IN 1 .. self.operation_responses.COUNT
      LOOP
         ary_output.EXTEND();
         ary_output(int_index) := self.operation_responses(i).hash_key;
         int_index := int_index + 1;
      
      END LOOP;
      
      RETURN ary_output;
   
   END operation_responses_keys;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION operation_callbacks_keys
   RETURN MDSYS.SDO_STRING2_ARRAY
   AS
      int_index  PLS_INTEGER;
      ary_output MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
      IF self.operation_callbacks IS NULL
      OR self.operation_callbacks.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := MDSYS.SDO_STRING2_ARRAY();
      FOR i IN 1 .. self.operation_callbacks.COUNT
      LOOP
         ary_output.EXTEND();
         ary_output(int_index) := self.operation_callbacks(i).hash_key;
         int_index := int_index + 1;
      
      END LOOP;
      
      RETURN ary_output;
   
   END operation_callbacks_keys;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      boo_temp         BOOLEAN;
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
      -- Add optional description 
      --------------------------------------------------------------------------
      IF self.operation_tags IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'tags'
               ,self.operation_tags
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional description 
      --------------------------------------------------------------------------
      IF self.operation_summary IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'summary'
               ,self.operation_summary
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional description 
      --------------------------------------------------------------------------
      IF self.operation_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'description'
               ,self.operation_description
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Add optional externalDocs
      --------------------------------------------------------------------------
      IF  self.operation_externalDocs IS NOT NULL
      AND self.operation_externalDocs.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'externalDocs'
               ,self.operation_externalDocs.toJSON(p_pretty_print + 1)
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Add optional description 
      --------------------------------------------------------------------------
      IF self.operation_operationId IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'operationId'
               ,self.operation_operationId
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 130
      -- Add parameters array
      --------------------------------------------------------------------------
      IF self.operation_parameters IS NULL 
      OR self.operation_parameters.COUNT = 0
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
      
         FOR i IN 1 .. operation_parameters.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
               str_pad2 || self.operation_parameters(i).toJSON(
                  p_pretty_print => p_pretty_print + 2
               )
               ,p_pretty_print + 2
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
              'parameters'
             ,clb_hash
             ,p_pretty_print + 1
          )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';
      
      --------------------------------------------------------------------------
      -- Step 140
      -- Add requestBody object
      --------------------------------------------------------------------------
      IF  self.operation_requestBody IS NOT NULL
      AND self.operation_requestBody.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'requestBody'
               ,self.operation_requestBody.toJSON(p_pretty_print + 1)
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 150
      -- Add optional variables map
      --------------------------------------------------------------------------
      IF self.operation_responses IS NULL 
      OR self.operation_responses.COUNT = 0
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
      
      
         ary_keys := self.operation_responses_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || ary_keys(i) || '":' || str_pad || self.operation_responses(i).toJSON(
                  p_pretty_print => p_pretty_print + 2
                )
               ,p_pretty_print + 2
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
              'responses'
             ,clb_hash
             ,p_pretty_print + 1
          )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';
      
      --------------------------------------------------------------------------
      -- Step 160
      -- Add operation callbacks map
      --------------------------------------------------------------------------
      IF self.operation_callbacks IS NULL 
      OR self.operation_callbacks.COUNT = 0
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
      
      
         ary_keys := self.operation_callbacks_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || ary_keys(i) || '":' || str_pad || self.operation_callbacks(i).toJSON(
                  p_pretty_print => p_pretty_print + 2
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
              'callbacks'
             ,clb_hash
             ,p_pretty_print + 1
          )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';
      
      --------------------------------------------------------------------------
      -- Step 170
      -- Add deprecated flag
      --------------------------------------------------------------------------
      IF self.operation_deprecated IS NOT NULL
      THEN
         IF LOWER(self.operation_deprecated) = 'true'
         THEN
            boo_temp := TRUE;
            
         ELSE
            boo_temp := FALSE;
            
         END IF;
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'deprecated'
               ,boo_temp
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 180
      -- Add security array
      --------------------------------------------------------------------------
      IF self.operation_security IS NULL 
      OR self.operation_security.COUNT = 0
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
      
         FOR i IN 1 .. operation_security.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
               str_pad2 || self.operation_security(i).toJSON(
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
      -- Step 190
      -- Add server array
      --------------------------------------------------------------------------
      IF self.operation_servers IS NULL 
      OR self.operation_servers.COUNT = 0
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
      
         FOR i IN 1 .. operation_servers.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
               str_pad2 || self.operation_servers(i).toJSON(
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
      -- Step 200
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 210
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
      p_pretty_print      IN  INTEGER   DEFAULT 0
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
      -- Write the tags
      --------------------------------------------------------------------------
      IF  self.operation_tags IS NOT NULL
      AND self.operation_tags.COUNT > 0
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'tags: '
            ,p_pretty_print + 1
            ,'  '
         );
         
         FOR i IN 1 .. operation_tags.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty_str(
                '- ' || operation_tags(i)
               ,p_pretty_print + 1
               ,'  '
            );
            
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the summary
      --------------------------------------------------------------------------
      IF self.operation_summary IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'summary: ' || dz_swagger_util.yaml_text(
                self.operation_summary
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the description
      --------------------------------------------------------------------------
      IF self.operation_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'description: ' || dz_swagger_util.yaml_text(
                self.operation_description
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the description
      --------------------------------------------------------------------------
      IF  self.operation_externalDocs IS NOT NULL
      AND self.operation_externalDocs.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'externalDocs: ' 
            ,p_pretty_print + 1
            ,'  '
         ) || self.operation_externalDocs.toYAML(
            p_pretty_print + 1
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Write the operationId
      --------------------------------------------------------------------------
      IF self.operation_operationId IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'operationId: ' || dz_swagger_util.yaml_text(
                self.operation_operationId
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Write the parameters map
      --------------------------------------------------------------------------
      IF self.operation_parameters IS NULL 
      OR self.operation_parameters.COUNT = 0
      THEN
         NULL;
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'parameters: '
            ,p_pretty_print + 1
            ,'  '
         );
         
         FOR i IN 1 .. operation_parameters.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '- ' || self.operation_parameters(i).toYAML(p_pretty_print + 2,'FALSE')
               ,p_pretty_print
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Write the requestBody
      --------------------------------------------------------------------------
      IF  self.operation_requestBody IS NOT NULL
      AND self.operation_requestBody.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'requestBody: ' 
            ,p_pretty_print + 1
            ,'  '
         ) || self.operation_requestBody.toYAML(
            p_pretty_print + 1
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Write the optional variables map
      --------------------------------------------------------------------------
      IF self.operation_callbacks IS NULL 
      OR self.operation_callbacks.COUNT = 0
      THEN
         NULL;
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'callbacks: '
            ,p_pretty_print + 1
            ,'  '
         );
         
         ary_keys := self.operation_callbacks_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '''' || ary_keys(i) || ''': '
               ,p_pretty_print + 1
               ,'  '
            ) || self.operation_callbacks(i).toYAML(
               p_pretty_print + 2
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Write the operationId
      --------------------------------------------------------------------------
      IF self.operation_deprecated IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'deprecated: ' || LOWER(self.operation_deprecated)
            ,p_pretty_print + 1
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Write the security array
      --------------------------------------------------------------------------
      IF self.operation_security IS NULL 
      OR self.operation_security.COUNT = 0
      THEN
         NULL;
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'security: '
            ,p_pretty_print + 1
            ,'  '
         );
         
         FOR i IN 1 .. operation_parameters.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '- '
               ,p_pretty_print + 1
               ,'  '
            ) || self.operation_security(i).toYAML(
               p_pretty_print + 2
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Write the servers arrya
      --------------------------------------------------------------------------
      IF self.operation_servers IS NULL 
      OR self.operation_servers.COUNT = 0
      THEN
         NULL;
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'servers: '
            ,p_pretty_print + 1
            ,'  '
         );
         
         FOR i IN 1 .. operation_servers.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '- '
               ,p_pretty_print + 1
               ,'  '
            ) || self.operation_servers(i).toYAML(
               p_pretty_print + 2
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 130
      -- Cough it out 
      --------------------------------------------------------------------------
      RETURN clb_output;
      
   END toYAML;
   
END;
/

