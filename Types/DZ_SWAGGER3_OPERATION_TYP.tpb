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
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_operation_typ(
       p_operation_id              IN  VARCHAR2
      ,p_versionid                 IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
   BEGIN 
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Set up the object
      --------------------------------------------------------------------------
      self.versionid := p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Load the operation type
      --------------------------------------------------------------------------
      SELECT
       a.operation_id
      ,a.operation_type
      ,a.operation_summary
      ,a.operation_description
      ,CASE
       WHEN a.operation_externaldocs_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id      => a.operation_externaldocs_id
            ,p_object_type_id => 'extrdocstyp'
         )
       ELSE
         NULL
       END
      ,CASE
       WHEN a.operation_requestbody_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id      => a.operation_requestbody_id
            ,p_object_type_id => 'operationtyp'
         )
       ELSE
         NULL
       END
      ,a.operation_inline_rb
      ,a.operation_deprecated
      INTO
       self.operation_id
      ,self.operation_type
      ,self.operation_summary
      ,self.operation_description
      ,self.operation_externalDocs  
      ,self.operation_requestBody
      ,self.operation_inline_rb 
      ,self.operation_deprecated 
      FROM
      dz_swagger3_operation a
      WHERE
          a.versionid    = p_versionid
      AND a.operation_id = p_operation_id;
      
      self.operation_responses  := NULL;
      self.operation_callbacks  := NULL;
      self.operation_security  := NULL;
      self.operation_servers := NULL;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add any required tags
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id      => a.tag_id
         ,p_object_type_id => 'tagtyp'
         ,p_object_order   => a.tag_order
      )
      BULK COLLECT INTO self.operation_tags
      FROM
      dz_swagger3_operation_tag_map a
      WHERE
          a.versionid    = p_versionid
      AND a.operation_id = p_operation_id;

      --------------------------------------------------------------------------
      -- Step 30
      -- Add any parameters
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id      => a.parameter_id
         ,p_object_type_id => 'parametertyp'
         ,p_object_key     => a.parameter_name
         ,p_object_order   => b.parameter_order
      )
      BULK COLLECT INTO self.operation_parameters
      FROM
      dz_swagger3_parameter a
      JOIN
      dz_swagger3_parent_parm_map b
      ON
          a.versionid = b.versionid
      AND a.parameter_id = b.parameter_id
      WHERE
          b.versionid = p_versionid
      AND b.parent_id = p_operation_id
      AND COALESCE(b.requestbody_flag,'FALSE') = 'FALSE';

      --------------------------------------------------------------------------
      -- Step 40
      -- Check for the condition of being post without a request body
      --------------------------------------------------------------------------
      IF  self.operation_requestBody IS NULL
      AND self.operation_type = 'post'
      THEN
         SELECT
         dz_swagger3_object_typ(
             p_object_id       => a.parameter_id
            ,p_object_type_id  => 'parametertyp'
            ,p_object_key      => a.parameter_name
            ,p_object_required => a.parameter_required
            ,p_object_order    => b.parameter_order
         )
         BULK COLLECT INTO self.operation_emulated_rbparms
         FROM
         dz_swagger3_parameter a
         JOIN
         dz_swagger3_parent_parm_map b
         ON
             a.versionid    = b.versionid
         AND a.parameter_id = b.parameter_id
         WHERE
             b.versionid = p_versionid
         AND b.parent_id = p_operation_id
         AND b.requestbody_flag = 'TRUE';
         
         IF  self.operation_emulated_rbparms IS NOT NULL
         AND self.operation_emulated_rbparms.COUNT > 0
         THEN    
            self.operation_requestBody := dz_swagger3_object_typ(
                p_object_id        => 'rb.' || self.operation_id
               ,p_object_type_id   => 'requestbodytyp'
               ,p_object_subtype   => 'emulated'
               ,p_object_attribute => self.operation_id
            );
         
         END IF;
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 60
      -- Add the responses
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id        => b.response_id
         ,p_object_type_id   => 'responsetyp'
         ,p_object_key       => a.response_code
         ,p_object_order     => a.response_order
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
      AND a.operation_id = p_operation_id;

      --------------------------------------------------------------------------
      -- Step 70
      -- Add any callbacks
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id        => a.callback_id
         ,p_object_type_id   => 'callbacktyp'
         ,p_object_key       => a.callback_name
         ,p_object_order     => a.callback_order
      )
      BULK COLLECT INTO self.operation_callbacks
      FROM
      dz_swagger3_operation_call_map a
      JOIN
      dz_swagger3_path b
      ON
          a.versionid    = b.versionid
      AND a.callback_id  = b.path_id
      WHERE
          a.versionid    = p_versionid
      AND a.operation_id = p_operation_id;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Load the security items
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id      => a.securityScheme_id
         ,p_object_type_id => 'securityschemetyp'
         ,p_object_order   => a.securityScheme_order
      )
      BULK COLLECT INTO self.operation_security
      FROM
      dz_swagger3_parent_secschm_map a
      WHERE
          a.versionid = p_versionid
      AND a.parent_id = p_operation_id;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Add any servers
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id      => a.server_id
         ,p_object_type_id => 'servertyp'
         ,p_object_order   => a.server_order
      )
      BULK COLLECT INTO self.operation_servers
      FROM
      dz_swagger3_parent_server_map a
      WHERE
          a.versionid = p_versionid
      AND a.parent_id = p_operation_id;
 
      --------------------------------------------------------------------------
      -- Step 100
      -- Return the completed object
      --------------------------------------------------------------------------
      RETURN;       
      
   END dz_swagger3_operation_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Load the external docs
      --------------------------------------------------------------------------
      IF  self.operation_externalDocs IS NOT NULL
      AND self.operation_externalDocs.object_id IS NOT NULL
      THEN
         dz_swagger3_loader.extrdocstyp(
             p_parent_id    => self.operation_id
            ,p_children_ids => dz_swagger3_object_vry(self.operation_externalDocs)
            ,p_versionid    => self.versionid
         );
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 20
      -- Load the tags
      --------------------------------------------------------------------------
      IF  self.operation_tags IS NOT NULL
      AND self.operation_tags.COUNT > 0
      THEN
         dz_swagger3_loader.tagtyp(
             p_parent_id    => self.operation_id
            ,p_children_ids => self.operation_tags
            ,p_versionid    => self.versionid
         );
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Load the parameters
      --------------------------------------------------------------------------
      IF  self.operation_parameters IS NOT NULL
      AND self.operation_parameters.COUNT > 0
      THEN
         dz_swagger3_loader.parametertyp(
             p_parent_id    => self.operation_id
            ,p_children_ids => self.operation_parameters
            ,p_versionid    => self.versionid
         );
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Load the parameters
      --------------------------------------------------------------------------
      IF  self.operation_requestBody IS NOT NULL
      AND self.operation_requestBody.object_id IS NOT NULL
      THEN
         IF self.operation_requestBody.object_subtype = 'emulated'
         THEN
            dz_swagger3_loader.requestbodytyp_emulated(
                p_parent_id      => self.operation_id
               ,p_child_id       => self.operation_requestBody
               ,p_parameter_ids  => self.operation_emulated_rbparms
               ,p_versionid      => self.versionid
            );

         ELSE
            dz_swagger3_loader.requestbodytyp(
                p_parent_id    => self.operation_id
               ,p_child_id     => self.operation_requestBody
               ,p_versionid    => self.versionid
            );

         END IF;
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Load the responses
      --------------------------------------------------------------------------
      IF  self.operation_responses IS NOT NULL
      AND self.operation_responses.COUNT > 0
      THEN
         dz_swagger3_loader.responsetyp(
             p_parent_id    => self.operation_id
            ,p_children_ids => self.operation_responses
            ,p_versionid    => self.versionid
         );
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Load the callbacks
      --------------------------------------------------------------------------
      IF  self.operation_callbacks IS NOT NULL
      AND self.operation_callbacks.COUNT > 0
      THEN
         dz_swagger3_loader.pathtyp(
             p_parent_id    => self.operation_id
            ,p_children_ids => self.operation_callbacks
            ,p_versionid    => self.versionid
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Load the security
      --------------------------------------------------------------------------
      IF  self.operation_security IS NOT NULL
      AND self.operation_security.COUNT > 0
      THEN
         dz_swagger3_loader.securitySchemetyp(
             p_parent_id    => self.operation_id
            ,p_children_ids => self.operation_security 
            ,p_versionid    => self.versionid
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Load the servers
      --------------------------------------------------------------------------
      IF  self.operation_servers IS NOT NULL
      AND self.operation_servers.COUNT > 0
      THEN
         dz_swagger3_loader.servertyp(
             p_parent_id    => self.operation_id
            ,p_children_ids => self.operation_servers
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
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      boo_temp         BOOLEAN;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_hash         CLOB;
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
         clb_output  := dz_json_util.pretty('{',NULL);
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;
      
      str_pad1 := str_pad;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional description 
      --------------------------------------------------------------------------
      IF  self.operation_tags IS NOT NULL
      AND self.operation_tags.COUNT > 0
      THEN
         SELECT
         a.tagtyp.tag_name
         BULK COLLECT INTO ary_keys
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.operation_tags) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id
         ORDER BY b.object_order;

         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('[',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('[',-1);
            
         END IF;
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
               str_pad2 || '"' || ary_keys(i) || '"'
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
                 'tags'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Add summary 
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
      -- Step 50
      -- Add description 
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
      -- Step 60
      -- Add optional externalDocs
      --------------------------------------------------------------------------
      IF  self.operation_externalDocs IS NOT NULL
      AND self.operation_externalDocs.object_id IS NOT NULL
      THEN
         BEGIN
            SELECT
            a.extrdocstyp.toJSON(
                p_pretty_print => p_pretty_print + 1
               ,p_force_inline => p_force_inline
               ,p_short_id     => p_short_id
            )
            INTO clb_tmp
            FROM 
            dz_swagger3_xobjects a
            WHERE
                a.object_type_id = self.operation_externalDocs.object_type_id
            AND a.object_id      = self.operation_externalDocs.object_id;
            
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
      -- Step 70
      -- Add optional operationId 
      --------------------------------------------------------------------------
      IF p_short_id = 'TRUE'
      THEN
         str_identifier := p_short_identifier;
         
      ELSE
         str_identifier := p_identifier;
      
      END IF;
      
      IF str_identifier IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'operationId'
               ,str_identifier
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Add parameters array
      --------------------------------------------------------------------------
      IF  self.operation_parameters IS NOT NULL 
      AND self.operation_parameters.COUNT > 0
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
         TABLE(self.operation_parameters) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id
         WHERE
         COALESCE(a.parametertyp.parameter_list_hidden,'FALSE') <> 'TRUE'
         ORDER BY b.object_order;

         str_pad2 := str_pad;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            IF p_pretty_print IS NULL
            THEN
               clb_hash := dz_json_util.pretty('[',NULL);
               
            ELSE
               clb_hash := dz_json_util.pretty('[',-1);
               
            END IF;
         
            FOR i IN 1 .. ary_keys.COUNT
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
      -- Step 90
      -- Add requestBody object
      --------------------------------------------------------------------------
      IF  self.operation_requestBody IS NOT NULL
      AND self.operation_requestBody.object_id IS NOT NULL
      THEN
         BEGIN
            SELECT
            a.requestbodytyp.toJSON(
                p_pretty_print     => p_pretty_print + 1
               ,p_force_inline     => p_force_inline
               ,p_short_id         => p_short_id
               ,p_identifier       => a.object_id
               ,p_short_identifier => a.short_id
               ,p_reference_count  => a.reference_count
            )
            INTO clb_tmp
            FROM 
            dz_swagger3_xobjects a
            WHERE
                a.object_type_id = self.operation_requestBody.object_type_id
            AND a.object_id      = self.operation_requestBody.object_id;
            
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
                'requestBody'
               ,clb_tmp               
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Add optional variables map
      --------------------------------------------------------------------------
      IF  self.operation_responses IS NOT NULL 
      AND self.operation_responses.COUNT > 0
      THEN
         SELECT
          a.responsetyp.toJSON(
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
         TABLE(self.operation_responses) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id
         ORDER BY b.object_order;
         
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

      --------------------------------------------------------------------------
      -- Step 110
      -- Add operation callbacks map
      --------------------------------------------------------------------------
      IF  self.operation_callbacks IS NOT NULL 
      AND self.operation_callbacks.COUNT > 0
      THEN
         SELECT
         a.pathtyp.toJSON(
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
         TABLE(self.operation_callbacks) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id
         ORDER BY b.object_order;
         
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
                 'callbacks'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 120
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
      -- Step 130
      -- Add security req array
      --------------------------------------------------------------------------
      IF  self.operation_security IS NOT NULL 
      AND self.operation_security.COUNT > 0
      THEN
         SELECT
         a.securityschemetyp.toJSON_req(
            p_pretty_print     => p_pretty_print + 2
         )
         BULK COLLECT INTO ary_clb
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.operation_security) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id
         ORDER BY b.object_order;

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
      -- Step 140
      -- Add server array
      --------------------------------------------------------------------------
      IF  self.operation_servers IS NOT NULL 
      AND self.operation_servers.COUNT > 0
      THEN
         SELECT
         a.securityschemetyp.toJSON_req(
            p_pretty_print  => p_pretty_print + 2
         )
         BULK COLLECT INTO ary_clb
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.operation_servers) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id
         ORDER BY b.object_order;
         
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
                ,p_pretty_print + 2
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
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
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
      -- Write the tags
      --------------------------------------------------------------------------
      IF  self.operation_tags IS NOT NULL
      AND self.operation_tags.COUNT > 0
      THEN
         SELECT
         a.tagtyp.tag_name
         BULK COLLECT INTO ary_keys
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.operation_tags) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id
         ORDER BY b.object_order;
      
         clb_output := clb_output || dz_json_util.pretty_str(
             'tags: '
            ,p_pretty_print + 1
            ,'  '
         );
         
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty_str(
                '- ' || dz_swagger3_util.yamlq(ary_keys(i))
               ,p_pretty_print + 2
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
             'summary: ' || dz_swagger3_util.yaml_text(
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
             'description: ' || dz_swagger3_util.yaml_text(
                self.operation_description
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the externalDoc object
      --------------------------------------------------------------------------
      IF  self.operation_externalDocs IS NOT NULL
      AND self.operation_externalDocs.object_id IS NOT NULL
      THEN
         BEGIN
            SELECT
            a.extrdocstyp.toYAML(
                p_pretty_print => p_pretty_print + 2
               ,p_force_inline => p_force_inline
               ,p_short_id     => p_short_id
            )
            INTO clb_tmp
            FROM 
            dz_swagger3_xobjects a
            WHERE
                a.object_type_id = self.operation_externalDocs.object_type_id
            AND a.object_id      = self.operation_externalDocs.object_id;

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
            ,p_pretty_print + 1
            ,'  '
         ) || clb_tmp;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Write the operationId
      --------------------------------------------------------------------------
      IF p_short_id = 'TRUE'
      THEN
         str_identifier := p_short_identifier;
         
      ELSE
         str_identifier := p_identifier;
      
      END IF;

      IF str_identifier IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'operationId: ' || dz_swagger3_util.yaml_text(
                str_identifier
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
      IF  self.operation_parameters IS NOT NULL 
      AND self.operation_parameters.COUNT > 0
      THEN
         SELECT
          a.parametertyp.toYAML(
             p_pretty_print     => p_pretty_print + 3
            ,p_initial_indent   => 'FALSE'
            ,p_final_linefeed   => 'FALSE'
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
         TABLE(self.operation_parameters) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id
         WHERE
         COALESCE(a.parametertyp.parameter_list_hidden,'FALSE') <> 'TRUE'
         ORDER BY b.object_order;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'parameters: '
               ,p_pretty_print + 1
               ,'  '
            );
            
            FOR i IN 1 .. ary_clb.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   '- ' || ary_clb(i)
                  ,p_pretty_print + 2
                  ,'  '
               );
            
            END LOOP;

         END IF;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Write the requestBody
      --------------------------------------------------------------------------
      IF  self.operation_requestBody IS NOT NULL
      AND self.operation_requestBody.object_id IS NOT NULL
      THEN
         BEGIN
            SELECT
            a.requestbodytyp.toYAML(
                p_pretty_print     => p_pretty_print + 2
               ,p_force_inline     => p_force_inline
               ,p_short_id         => p_short_id
               ,p_identifier       => a.object_id
               ,p_short_identifier => a.short_id
               ,p_reference_count  => a.reference_count
            )
            INTO clb_tmp
            FROM
            dz_swagger3_xobjects a
            WHERE
                a.object_type_id = self.operation_requestBody.object_type_id
            AND a.object_id      = self.operation_requestBody.object_id;

            clb_output := clb_output || dz_json_util.pretty_str(
                'requestBody: ' 
               ,p_pretty_print + 1
               ,'  '
            ) || clb_tmp;

         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_tmp := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Write the responses map
      --------------------------------------------------------------------------
      IF  self.operation_responses IS NOT NULL 
      AND self.operation_responses.COUNT > 0
      THEN
         SELECT
          a.responsetyp.toYAML(
             p_pretty_print     => p_pretty_print + 3
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
         TABLE(self.operation_responses) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id
         ORDER BY b.object_order;
      
         clb_output := clb_output || dz_json_util.pretty_str(
             'responses: '
            ,p_pretty_print + 1
            ,'  '
         );
         
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                dz_swagger3_util.yamlq(ary_keys(i)) || ': '
               ,p_pretty_print + 2
               ,'  '
            ) || ary_clb(i);
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Write the optional variables map
      --------------------------------------------------------------------------
      IF  self.operation_callbacks IS NOT NULL 
      AND self.operation_callbacks.COUNT > 0
      THEN
         SELECT
          a.pathtyp.toYAML(
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
         TABLE(self.operation_callbacks) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id
         ORDER BY b.object_order;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'callbacks: '
            ,p_pretty_print + 1
            ,'  '
         );
         
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                dz_swagger3_util.yamlq(ary_keys(i)) || ': '
               ,p_pretty_print + 1
               ,'  '
            ) || ary_clb(i);
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
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
      -- Step 120
      -- Write the security array
      --------------------------------------------------------------------------
      IF  self.operation_security IS NOT NULL 
      AND self.operation_security.COUNT > 0
      THEN
         SELECT
         a.securityschemetyp.toYAML_req(
            p_pretty_print     => p_pretty_print + 2
         )
         BULK COLLECT INTO ary_clb
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.operation_security) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id
         ORDER BY b.object_order;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'security: '
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
      -- Write the servers array
      --------------------------------------------------------------------------
      IF  self.operation_servers IS NOT NULL 
      AND self.operation_servers.COUNT > 0
      THEN
         SELECT
         a.servertyp.toYAML(
             p_pretty_print   => p_pretty_print + 3
            ,p_initial_indent => 'FALSE'
            ,p_final_linefeed => 'FALSE'
            ,p_force_inline   => p_force_inline
            ,p_short_id       => p_short_id
         )
         BULK COLLECT INTO ary_clb
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.operation_servers) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id
         ORDER BY b.object_order;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'servers: '
            ,p_pretty_print + 1
            ,'  '
         );
         
         FOR i IN 1 .. ary_clb.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '- ' || ary_clb(i)
               ,p_pretty_print + 2
               ,'  '
            );
         
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

