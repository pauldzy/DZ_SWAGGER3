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
      WHERE
          a.versionid    = p_versionid
      AND a.operation_id = p_operation_id;
      
      --------------------------------------------------------------------------
      -- Step 80
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
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output                 CLOB;
      clb_operation_tags         CLOB;
      clb_operation_externalDocs CLOB;
      clb_operation_parameters   CLOB;
      clb_operation_requestBody  CLOB;
      clb_operation_responses    CLOB;
      clb_operation_callbacks    CLOB;
      clb_operation_security     CLOB;
      clb_operation_servers      CLOB;
      str_identifier             VARCHAR2(255 Char);
  
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Add operation tags array if populated 
      --------------------------------------------------------------------------
      IF  self.operation_tags IS NOT NULL
      AND self.operation_tags.COUNT > 0
      THEN
         SELECT
         JSON_ARRAYAGG(
            a.tagtyp.tag_name
            ORDER BY b.object_order
            RETURNING CLOB
         )
         INTO clb_operation_tags
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.operation_tags) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id;
 
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional externalDocs
      --------------------------------------------------------------------------
      IF  self.operation_externalDocs IS NOT NULL
      AND self.operation_externalDocs.object_id IS NOT NULL
      THEN
         BEGIN
            SELECT
            a.extrdocstyp.toJSON()
            INTO clb_operation_externalDocs
            FROM 
            dz_swagger3_xobjects a
            WHERE
                a.object_type_id = self.operation_externalDocs.object_type_id
            AND a.object_id      = self.operation_externalDocs.object_id;
            
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_operation_externalDocs := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Generate parameters array
      --------------------------------------------------------------------------
      IF  self.operation_parameters IS NOT NULL 
      AND self.operation_parameters.COUNT > 0
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
         INTO clb_operation_parameters
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.operation_parameters) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id
         WHERE
         COALESCE(a.parametertyp.parameter_list_hidden,'FALSE') <> 'TRUE'         ;

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Generate operation requestBody value
      --------------------------------------------------------------------------
      IF  self.operation_requestBody IS NOT NULL
      AND self.operation_requestBody.object_id IS NOT NULL
      THEN
         BEGIN
            SELECT
            a.requestbodytyp.toJSON(
                p_force_inline     => p_force_inline
               ,p_short_id         => p_short_id
               ,p_identifier       => a.object_id
               ,p_short_identifier => a.short_id
               ,p_reference_count  => a.reference_count
            )
            INTO clb_operation_requestBody
            FROM 
            dz_swagger3_xobjects a
            WHERE
                a.object_type_id = self.operation_requestBody.object_type_id
            AND a.object_id      = self.operation_requestBody.object_id;
            
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_operation_requestBody := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Generate operation responses map
      --------------------------------------------------------------------------
      IF  self.operation_responses IS NOT NULL 
      AND self.operation_responses.COUNT > 0
      THEN
         SELECT
         JSON_OBJECTAGG(
            b.object_key VALUE a.responsetyp.toJSON(
                p_force_inline     => p_force_inline
               ,p_short_id         => p_short_id
               ,p_identifier       => a.object_id
               ,p_short_identifier => a.short_id
               ,p_reference_count  => a.reference_count
            ) FORMAT JSON
            RETURNING CLOB
         )
         INTO clb_operation_responses
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.operation_responses) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id;
 
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Generate operation callbacks map
      --------------------------------------------------------------------------
      IF  self.operation_callbacks IS NOT NULL 
      AND self.operation_callbacks.COUNT > 0
      THEN
         SELECT
         JSON_OBJECTAGG(
            b.object_key VALUE json_object(
               a.pathtyp.path_endpoint VALUE a.pathtyp.toJSON(
                   p_force_inline     => p_force_inline
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_reference_count  => a.reference_count
               ) FORMAT JSON
               RETURNING CLOB
            )
            RETURNING CLOB
         )
         INTO clb_operation_callbacks
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.operation_callbacks) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id;

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Generate operation security req array
      --------------------------------------------------------------------------
      IF  self.operation_security IS NOT NULL 
      AND self.operation_security.COUNT > 0
      THEN
         SELECT
         JSON_ARRAYAGG(
            a.securityschemetyp.toJSON_req(
               p_oauth_scope_flows => b.object_attribute
            ) FORMAT JSON
            ORDER BY b.object_order
            RETURNING CLOB
         )
         INTO clb_operation_security
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.operation_security) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id;

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Gnerate operation server array
      --------------------------------------------------------------------------
      IF  self.operation_servers IS NOT NULL 
      AND self.operation_servers.COUNT > 0
      THEN
         SELECT
         JSON_ARRAYAGG(
            a.securityschemetyp.toJSON_req() FORMAT JSON
            ORDER BY b.object_order
            RETURNING CLOB
         )
         INTO clb_operation_servers
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.operation_servers) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id;
  
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Build the object
      --------------------------------------------------------------------------
      IF p_short_id = 'TRUE'
      THEN
         str_identifier := p_short_identifier;
         
      ELSE
         str_identifier := p_identifier;
      
      END IF;
      
      SELECT
      JSON_OBJECT(
          'tags'         VALUE clb_operation_tags         FORMAT JSON
         ,'summary'      VALUE self.operation_summary
         ,'description'  VALUE self.operation_description
         ,'externalDocs' VALUE clb_operation_externalDocs FORMAT JSON
         ,'operationId'  VALUE str_identifier
         ,'parameters'   VALUE clb_operation_parameters   FORMAT JSON
         ,'requestBody'  VALUE clb_operation_requestBody  FORMAT JSON
         ,'responses'    VALUE clb_operation_responses    FORMAT JSON
         ,'callbacks'    VALUE clb_operation_callbacks    FORMAT JSON
         ,'deprecated'   VALUE CASE
            WHEN LOWER(self.operation_deprecated) = 'true'
            THEN
               'true'
            WHEN LOWER(self.operation_deprecated) = 'false'
            THEN
               'false'
            ELSE
               NULL
            END FORMAT JSON
         ,'security'     VALUE clb_operation_security     FORMAT JSON
         ,'servers'      VALUE clb_operation_servers      FORMAT JSON 
         ABSENT ON NULL
         RETURNING CLOB
      )
      INTO clb_output
      FROM dual;

      --------------------------------------------------------------------------
      -- Step 110
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toJSON;
   
END;
/

