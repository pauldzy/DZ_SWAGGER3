CREATE OR REPLACE TYPE BODY dz_swagger3_components_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_components_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      
      self.components_schemas         := dz_swagger3_schema_nf_list();
      self.components_responses       := dz_swagger3_response_list();
      self.components_parameters      := dz_swagger3_parameter_list();
      self.components_examples        := dz_swagger3_example_list();
      self.components_requestBodies   := dz_swagger3_requestBody_list();
      self.components_headers         := dz_swagger3_header_list();
      self.components_securitySchemes := dz_swagger3_securitySchem_list();
      self.components_links           := dz_swagger3_link_list();
      self.components_callbacks       := dz_swagger3_callback_list();
      
      RETURN;
      
   END dz_swagger3_components_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_components_typ(
      p_versionid                     IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS 
   BEGIN
      self.load_components_schemas(
         p_versionid   => p_versionid
      );
      
      self.load_components_responses(
         p_versionid   => p_versionid
      );
      
      self.load_components_parameters(
         p_versionid   => p_versionid
      );
      
      self.load_components_examples(
         p_versionid   => p_versionid
      );
      
      self.load_components_requestBodies(
         p_versionid   => p_versionid
      );
      
      self.load_components_headers(
         p_versionid   => p_versionid
      );
      
      self.load_components_securityScheme(
         p_versionid   => p_versionid
      );
      
      self.load_components_links(
         p_versionid   => p_versionid
      );
      
      self.load_components_callbacks(
         p_versionid   => p_versionid
      );
            
      RETURN;
      
   END dz_swagger3_components_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_components_typ(
       p_components_schemas           IN  dz_swagger3_schema_nf_list
      ,p_components_responses         IN  dz_swagger3_response_list
      ,p_components_parameters        IN  dz_swagger3_parameter_list
      ,p_components_examples          IN  dz_swagger3_example_list
      ,p_components_requestBodies     IN  dz_swagger3_requestBody_list
      ,p_components_headers           IN  dz_swagger3_header_list
      ,p_components_securitySchemes   IN  dz_swagger3_securitySchem_list
      ,p_components_links             IN  dz_swagger3_link_list
      ,p_components_callbacks         IN  dz_swagger3_callback_list
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.components_schemas         := p_components_schemas;
      self.components_responses       := p_components_responses;
      self.components_parameters      := p_components_parameters;
      self.components_examples        := p_components_examples;
      self.components_requestBodies   := p_components_requestBodies;
      self.components_headers         := p_components_headers;
      self.components_securitySchemes := p_components_securitySchemes;
      self.components_links           := p_components_links;
      self.components_callbacks       := p_components_callbacks;
      
      RETURN; 
      
   END dz_swagger3_components_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE load_components_schemas(
       SELF        IN OUT NOCOPY dz_swagger3_components_typ
      ,p_versionid IN VARCHAR2
   )
   AS
   BEGIN

      SELECT
      a.schemaobj
      BULK COLLECT INTO self.components_schemas
      FROM (
         SELECT
          dz_swagger3_schema_typ(
             p_hash_key         => aa.hash_key
            ,p_schema_id        => aa.object_id
            ,p_required         => aa.schema_required
            ,p_versionid        => p_versionid
            ,p_load_components  => 'FALSE'
            ,p_ref_brake        => 'FIRE'
          ) AS schemaobj
         ,aa.object_id
         FROM
         dz_swagger3_components aa
         WHERE
         aa.object_type = 'schema'
         UNION ALL
         SELECT
          dz_swagger3_schema_typ(
             p_parameter        => dz_swagger3_parameter_typ(
                p_parameter_id     => bb.object_id
               ,p_versionid        => p_versionid
               ,p_load_components  => 'FALSE'
               ,p_ref_brake        => 'FIRE'
             )
            ,p_load_components  => 'FALSE'
          ) AS schemaobj
         ,'rb.' || bb.object_id
         FROM
         dz_swagger3_components bb
         WHERE
         bb.object_type = 'rbparameter'
      ) a
      ORDER BY
      a.object_id;

   END load_components_schemas;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE load_components_responses(
       SELF        IN OUT NOCOPY dz_swagger3_components_typ
      ,p_versionid IN VARCHAR2
   )
   AS
   BEGIN
      
      SELECT
      dz_swagger3_response_typ(
          p_response_id    => a.object_id
         ,p_response_code  => a.response_code
         ,p_versionid      => p_versionid
         ,p_load_components  => 'FALSE'
         ,p_ref_brake        => 'FIRE'
      )
      BULK COLLECT INTO self.components_responses
      FROM
      dz_swagger3_components a
      WHERE
      a.object_type = 'response'
      ORDER BY
      a.object_id;
   
   END load_components_responses;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE load_components_parameters(
       SELF        IN OUT NOCOPY dz_swagger3_components_typ
      ,p_versionid IN VARCHAR2
   )
   AS
   BEGIN
      
      SELECT
      dz_swagger3_parameter_typ(
          p_parameter_id     => a.object_id
         ,p_versionid        => p_versionid 
         ,p_load_components  => 'FALSE'
         ,p_ref_brake        => 'FIRE'
      )
      BULK COLLECT INTO self.components_parameters
      FROM
      dz_swagger3_components a
      WHERE
      a.object_type = 'parameter'
      ORDER BY
      a.object_id;
   
   END load_components_parameters;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE load_components_examples(
       SELF        IN OUT NOCOPY dz_swagger3_components_typ
      ,p_versionid IN VARCHAR2
   )
   AS
   BEGIN
      
      SELECT
      dz_swagger3_example_typ(
          p_hash_key         => a.hash_key
         ,p_example_id       => a.object_id
         ,p_versionid        => p_versionid 
         ,p_load_components  => 'FALSE'
         ,p_ref_brake        => 'FIRE'
      )
      BULK COLLECT INTO self.components_examples
      FROM
      dz_swagger3_components a
      WHERE
      a.object_type = 'example'
      ORDER BY
      a.object_id;
   
   END load_components_examples;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE load_components_requestBodies(
       SELF        IN OUT NOCOPY dz_swagger3_components_typ
      ,p_versionid IN VARCHAR2
   )
   AS
   BEGIN
      
      SELECT
      dz_swagger3_requestbody_typ(
          p_requestbody_id   => a.object_id
         ,p_versionid        => p_versionid 
         ,p_load_components  => 'FALSE'
         ,p_ref_brake        => 'FIRE'
      )
      BULK COLLECT INTO self.components_requestBodies
      FROM
      dz_swagger3_components a
      WHERE
      a.object_type = 'requestBody'
      ORDER BY
      a.object_id;
   
   END load_components_requestBodies;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE load_components_headers(
       SELF        IN OUT NOCOPY dz_swagger3_components_typ
      ,p_versionid IN VARCHAR2
   )
   AS
   BEGIN
      
      SELECT
      dz_swagger3_header_typ(
          p_hash_key         => a.hash_key
         ,p_header_id        => a.object_id
         ,p_versionid        => p_versionid
         ,p_load_components  => 'FALSE'
         ,p_ref_brake        => 'FIRE'
      )
      BULK COLLECT INTO self.components_headers
      FROM
      dz_swagger3_components a
      WHERE
      a.object_type = 'header'
      ORDER BY
      a.object_id;
   
   END load_components_headers;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE load_components_securityScheme(
       SELF        IN OUT NOCOPY dz_swagger3_components_typ
      ,p_versionid IN VARCHAR2
   )
   AS
   BEGIN
      
      SELECT
      dz_swagger3_securityScheme_typ(
          p_hash_key         => a.hash_key
         ,p_scheme_id        => a.object_id
         ,p_versionid        => p_versionid
         ,p_load_components  => 'FALSE'
         ,p_ref_brake        => 'FIRE'
      )
      BULK COLLECT INTO self.components_securitySchemes
      FROM
      dz_swagger3_components a
      WHERE
      a.object_type = 'securityScheme'
      ORDER BY
      a.object_id;
   
   END load_components_securityScheme;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE load_components_links(
       SELF        IN OUT NOCOPY dz_swagger3_components_typ
      ,p_versionid IN VARCHAR2
   )
   AS
   BEGIN
   
      SELECT
      dz_swagger3_link_typ(
          p_hash_key         => a.hash_key
         ,p_link_id          => a.object_id
         ,p_versionid        => p_versionid
         ,p_load_components  => 'FALSE'
         ,p_ref_brake        => 'FIRE'
      )
      BULK COLLECT INTO self.components_links
      FROM
      dz_swagger3_components a
      WHERE
      a.object_type = 'link'
      ORDER BY
      a.object_id;
   
   END load_components_links;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE load_components_callbacks(
       SELF        IN OUT NOCOPY dz_swagger3_components_typ
      ,p_versionid IN VARCHAR2
   )
   AS
    BEGIN
    
      SELECT
      dz_swagger3_callback_typ(
          p_hash_key         => a.hash_key
         ,p_callback_id      => a.object_id
         ,p_versionid        => p_versionid
         ,p_load_components  => 'FALSE'
         ,p_ref_brake        => 'FIRE'
      )
      BULK COLLECT INTO self.components_callbacks
      FROM
      dz_swagger3_components a
      WHERE
      a.object_type = 'callback'
      ORDER BY
      a.object_id;
   
   END load_components_callbacks;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION isNULL
   RETURN VARCHAR2
   AS
   BEGIN
   
      IF  (self.components_schemas         IS NULL OR self.components_schemas.COUNT = 0 )
      AND (self.components_responses       IS NULL OR self.components_responses.COUNT = 0 )
      AND (self.components_parameters      IS NULL OR self.components_parameters.COUNT = 0 )
      AND (self.components_examples        IS NULL OR self.components_examples.COUNT = 0 )
      AND (self.components_requestBodies   IS NULL OR self.components_requestBodies.COUNT = 0 )
      AND (self.components_headers         IS NULL OR self.components_headers.COUNT = 0 )
      AND (self.components_securitySchemes IS NULL OR self.components_securitySchemes.COUNT = 0 )
      AND (self.components_links           IS NULL OR self.components_links.COUNT = 0 )
      AND (self.components_callbacks       IS NULL OR self.components_callbacks.COUNT = 0 )
      THEN
         RETURN 'TRUE';
         
      ELSE
         RETURN 'FALSE';
         
      END IF;
   
   END isNULL;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER  DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output        CLOB;
      clb_hash          CLOB;
      str_pad           VARCHAR2(1 Char);
      str_pad1          VARCHAR2(1 Char);
      str_pad2          VARCHAR2(1 Char);
      
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
      -- Add schemas map
      --------------------------------------------------------------------------
      IF self.components_schemas IS NULL
      OR self.components_schemas.COUNT = 0
      OR p_force_inline = 'TRUE'
      THEN
         NULL;
      
      ELSE
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('{',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('{',-1);
            
         END IF;
      
         FOR i IN 1 .. self.components_schemas.COUNT
         LOOP
            IF self.components_schemas(i).property_list_hidden = 'TRUE'
            THEN
               NULL;
               
            ELSE
               clb_hash := clb_hash || dz_json_util.pretty(
                   str_pad2 || '"' || dz_swagger3_main.short(
                      p_object_id   => self.components_schemas(i).schema_id
                     ,p_object_type => 'schema'
                   ) || '":' || str_pad || self.components_schemas(i).toJSON_component(
                      p_pretty_print   => p_pretty_print + 2
                     ,p_force_inline   => p_force_inline
                   )
                  ,p_pretty_print + 2
               );
               str_pad2 := ',';
               
            END IF;
         
         END LOOP;
         
         clb_hash := clb_hash || dz_json_util.pretty(
             '}'
            ,p_pretty_print + 1,NULL,NULL
         );
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                 'schemas'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Add responses map
      --------------------------------------------------------------------------
      IF self.components_responses IS NULL
      OR self.components_responses.COUNT = 0
      OR p_force_inline = 'TRUE'
      THEN
         NULL;
      
      ELSE
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('{',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('{',-1);
            
         END IF;
      
         FOR i IN 1 .. self.components_responses.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || dz_swagger3_main.short(
                      p_object_id   => self.components_responses(i).response_id
                     ,p_object_type => 'response'
                ) || '":' || str_pad || self.components_responses(i).toJSON_schema(
                   p_pretty_print   => p_pretty_print + 2
                  ,p_force_inline   => p_force_inline
                )
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
      -- Step 50
      -- Add parameters map
      --------------------------------------------------------------------------
      IF self.components_parameters IS NULL
      OR self.components_parameters.COUNT = 0
      OR p_force_inline = 'TRUE'
      THEN
         NULL;
      
      ELSE
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('{',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('{',-1);
            
         END IF;
      
         FOR i IN 1 .. self.components_parameters.COUNT
         LOOP
            IF self.components_parameters(i).parameter_list_hidden = 'TRUE'
            THEN
               NULL;
               
            ELSE
               clb_hash := clb_hash || dz_json_util.pretty(
                   str_pad2 || '"' || dz_swagger3_main.short(
                      p_object_id   => self.components_parameters(i).parameter_id
                     ,p_object_type => 'parameter'
                   ) || '":' || str_pad || self.components_parameters(i).toJSON_schema(
                      p_pretty_print   => p_pretty_print + 2
                     ,p_force_inline   => p_force_inline
                   )
                  ,p_pretty_print + 2
               );
               str_pad2 := ',';
               
            END IF;
         
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
      -- Step 60
      -- Add examples map
      --------------------------------------------------------------------------
      IF self.components_examples IS NULL
      OR self.components_examples.COUNT = 0
      OR p_force_inline = 'TRUE'
      THEN
         NULL;
      
      ELSE
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('{',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('{',-1);
            
         END IF;

         FOR i IN 1 .. self.components_examples.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || dz_swagger3_main.short(
                      p_object_id   => self.components_examples(i).example_id
                     ,p_object_type => 'example'
                ) || '":' || str_pad || self.components_examples(i).toJSON_schema(
                   p_pretty_print   => p_pretty_print + 2
                  ,p_force_inline   => p_force_inline
                )
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
                 'examples'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 70
      -- Add requestBodies map
      --------------------------------------------------------------------------
      IF self.components_requestBodies IS NULL
      OR self.components_requestBodies.COUNT = 0
      OR p_force_inline = 'TRUE'
      THEN
         NULL;
      
      ELSE
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('{',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('{',-1);
            
         END IF;

         FOR i IN 1 .. self.components_requestBodies.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || dz_swagger3_main.short(
                      p_object_id   => self.components_requestBodies(i).requestBody_id
                     ,p_object_type => 'requestBody'
                ) || '":' || str_pad || self.components_requestBodies(i).toJSON_schema(
                   p_pretty_print   => p_pretty_print + 2
                  ,p_force_inline   => p_force_inline
                )
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
                 'requestBodies'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 80
      -- Add headers map
      --------------------------------------------------------------------------
      IF self.components_headers IS NULL
      OR self.components_headers.COUNT = 0
      OR p_force_inline = 'TRUE'
      THEN
         NULL;
      
      ELSE
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('{',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('{',-1);
            
         END IF;

         FOR i IN 1 .. self.components_headers.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || dz_swagger3_main.short(
                      p_object_id   => self.components_headers(i).header_id
                     ,p_object_type => 'header'
                ) || '":' || str_pad || self.components_headers(i).toJSON_schema(
                   p_pretty_print   => p_pretty_print + 2
                  ,p_force_inline   => p_force_inline
                )
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
                 'headers'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 90
      -- Add headers map
      --------------------------------------------------------------------------
      IF self.components_securitySchemes IS NULL
      OR self.components_securitySchemes.COUNT = 0
      OR p_force_inline = 'TRUE'
      THEN
         NULL;
      
      ELSE
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('{',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('{',-1);
            
         END IF;

         FOR i IN 1 .. self.components_securitySchemes.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || dz_swagger3_main.short(
                      p_object_id   => self.components_securitySchemes(i).scheme_id
                     ,p_object_type => 'securityScheme'
                ) || '":' || str_pad || self.components_securitySchemes(i).toJSON_schema(
                   p_pretty_print   => p_pretty_print + 2
                  ,p_force_inline   => p_force_inline
                )
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
                 'securitySchemes'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 100
      -- Add links map
      --------------------------------------------------------------------------
      IF self.components_links IS NULL
      OR self.components_links.COUNT = 0
      OR p_force_inline = 'TRUE'
      THEN
         NULL;
      
      ELSE
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('{',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('{',-1);
            
         END IF;

         FOR i IN 1 .. self.components_links.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || dz_swagger3_main.short(
                      p_object_id   => self.components_links(i).link_id
                     ,p_object_type => 'link'
                ) || '":' || str_pad || self.components_links(i).toJSON_schema(
                   p_pretty_print   => p_pretty_print + 2
                  ,p_force_inline   => p_force_inline
                )
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
                 'links'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 110
      -- Add callbacks map
      --------------------------------------------------------------------------
      IF self.components_callbacks IS NULL
      OR self.components_callbacks.COUNT = 0
      OR p_force_inline = 'TRUE'
      THEN
         NULL;
      
      ELSE
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('{',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('{',-1);
            
         END IF;

         FOR i IN 1 .. self.components_callbacks.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || dz_swagger3_main.short(
                      p_object_id   => self.components_callbacks(i).callback_id
                     ,p_object_type => 'callback'
                ) || '":' || str_pad || self.components_callbacks(i).toJSON_schema(
                   p_pretty_print   => p_pretty_print + 2
                  ,p_force_inline   => p_force_inline
                )
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
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 130
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
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------

      --------------------------------------------------------------------------
      -- Step 20
      -- Write the component schemas
      --------------------------------------------------------------------------
      IF self.components_schemas IS NULL 
      OR self.components_schemas.COUNT = 0
      OR p_force_inline = 'TRUE'
      THEN
         NULL;

      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'schemas: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. self.components_schemas.COUNT
         LOOP
            IF self.components_schemas(i).property_list_hidden = 'TRUE'
            THEN
               NULL;
               
            ELSE
               clb_output := clb_output || dz_json_util.pretty(
                   dz_swagger3_util.yamlq(
                      dz_swagger3_main.short(
                         p_object_id   => self.components_schemas(i).schema_id
                        ,p_object_type => 'schema'
                      )
                   ) || ': '
                  ,p_pretty_print + 1
                  ,'  '
               ) || self.components_schemas(i).toYAML_component(
                   p_pretty_print   => p_pretty_print + 2
                  ,p_force_inline   => p_force_inline
               );
               
            END IF;
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the component responses
      --------------------------------------------------------------------------
      IF self.components_responses IS NULL 
      OR self.components_responses.COUNT = 0
      OR p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'responses: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. self.components_responses.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                dz_swagger3_util.yamlq(
                   dz_swagger3_main.short(
                      p_object_id   => self.components_responses(i).response_id
                     ,p_object_type => 'response'
                   )
                ) || ': '
               ,p_pretty_print + 1
               ,'  '
            ) || self.components_responses(i).toYAML_schema(
                p_pretty_print   => p_pretty_print + 2
               ,p_force_inline   => p_force_inline
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the component parameters
      --------------------------------------------------------------------------
      IF self.components_parameters IS NULL 
      OR self.components_parameters.COUNT = 0
      OR p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'parameters: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. self.components_parameters.COUNT
         LOOP
            IF self.components_parameters(i).parameter_list_hidden = 'TRUE'
            THEN
               NULL;
               
            ELSE
               clb_output := clb_output || dz_json_util.pretty(
                   dz_swagger3_util.yamlq(
                      dz_swagger3_main.short(
                         p_object_id   => self.components_parameters(i).parameter_id
                        ,p_object_type => 'parameter'
                      )
                   ) || ': '
                  ,p_pretty_print + 1
                  ,'  '
               ) || self.components_parameters(i).toYAML_schema(
                   p_pretty_print   => p_pretty_print + 2
                  ,p_force_inline   => p_force_inline
               );
               
            END IF;
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the component examples
      --------------------------------------------------------------------------
      IF self.components_examples IS NULL 
      OR self.components_examples.COUNT = 0
      OR p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'examples: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. self.components_examples.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                dz_swagger3_util.yamlq(
                   dz_swagger3_main.short(
                      p_object_id   => self.components_examples(i).example_id
                     ,p_object_type => 'example'
                   )
                ) || ': '
               ,p_pretty_print + 1
               ,'  '
            ) || self.components_examples(i).toYAML_schema(
                p_pretty_print   => p_pretty_print + 2
               ,p_force_inline   => p_force_inline
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Write the component requestBodies
      --------------------------------------------------------------------------
      IF self.components_requestBodies IS NULL 
      OR self.components_requestBodies.COUNT = 0
      OR p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'requestBodies: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. self.components_requestBodies.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                dz_swagger3_util.yamlq(
                   dz_swagger3_main.short(
                      p_object_id   => self.components_requestBodies(i).requestBody_id
                     ,p_object_type => 'requestBody'
                   )
                ) || ': '
               ,p_pretty_print + 1
               ,'  '
            ) || self.components_requestBodies(i).toYAML_schema(
                p_pretty_print   => p_pretty_print + 2
               ,p_force_inline   => p_force_inline
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Write the component headers
      --------------------------------------------------------------------------
      IF self.components_headers IS NULL 
      OR self.components_headers.COUNT = 0
      OR p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'headers: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. self.components_headers.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                dz_swagger3_util.yamlq(
                   dz_swagger3_main.short(
                      p_object_id   => self.components_headers(i).header_id
                     ,p_object_type => 'header'
                   )
                ) || ': '
               ,p_pretty_print + 1
               ,'  '
            ) || self.components_headers(i).toYAML_schema(
                p_pretty_print   => p_pretty_print + 2
               ,p_force_inline   => p_force_inline
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Write the component securitySchemes
      --------------------------------------------------------------------------
      IF self.components_securitySchemes IS NULL 
      OR self.components_securitySchemes.COUNT = 0
      OR p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'securitySchemes: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. self.components_securitySchemes.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                dz_swagger3_util.yamlq(
                   dz_swagger3_main.short(
                      p_object_id   => self.components_securitySchemes(i).scheme_id
                     ,p_object_type => 'securityScheme'
                   )
                ) || ': '
               ,p_pretty_print + 1
               ,'  '
            ) || self.components_securitySchemes(i).toYAML_schema(
                p_pretty_print   => p_pretty_print + 2
               ,p_force_inline   => p_force_inline
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Write the component links
      --------------------------------------------------------------------------
      IF self.components_links IS NULL 
      OR self.components_links.COUNT = 0
      OR p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'links: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. self.components_links.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                dz_swagger3_util.yamlq(
                   dz_swagger3_main.short(
                      p_object_id   => self.components_links(i).link_id
                     ,p_object_type => 'link'
                   )
                ) || ': '
               ,p_pretty_print + 1
               ,'  '
            ) || self.components_links(i).toYAML_schema(
                p_pretty_print   => p_pretty_print + 2
               ,p_force_inline   => p_force_inline
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Write the component callbacks
      --------------------------------------------------------------------------
      IF self.components_callbacks IS NULL 
      OR self.components_callbacks.COUNT = 0
      OR p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'callbacks: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. self.components_callbacks.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                dz_swagger3_util.yamlq(
                   dz_swagger3_main.short(
                      p_object_id   => self.components_callbacks(i).callback_id
                     ,p_object_type => 'callback'
                   )
                ) || ': '
               ,p_pretty_print + 1
               ,'  '
            ) || self.components_callbacks(i).toYAML_schema(
                p_pretty_print   => p_pretty_print + 2
               ,p_force_inline   => p_force_inline
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Cough it out without final line feed
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

