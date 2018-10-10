CREATE OR REPLACE TYPE BODY dz_swagger3_components
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_components
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
      
   END dz_swagger3_components;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_components(
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
      
   END dz_swagger3_components;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION get_components_schemas
   RETURN dz_swagger3_schema_nf_list
   AS
      int_index  PLS_INTEGER;
      ary_output dz_swagger3_schema_nf_list;
      obj_schema dz_swagger3_schema_typ;
      
   BEGIN
      IF self.components_schemas IS NULL
      OR self.components_schemas.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := dz_swagger3_schema_nf_list();
      FOR i IN 1 .. self.components_schemas.COUNT
      LOOP
         obj_schema := TREAT(
            self.components_schemas(i) AS dz_swagger3_schema_typ
         );
         
         IF obj_schema.doRef() = 'TRUE'
         THEN
            ary_output.EXTEND();
            ary_output(int_index) := obj_schema;
            int_index := int_index + 1;
            
         END IF;
         
      END LOOP;
      
      RETURN ary_output;
   
   END get_components_schemas;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION get_components_responses
   RETURN dz_swagger3_response_list
   AS
      int_index  PLS_INTEGER;
      ary_output dz_swagger3_response_list;
      
   BEGIN
      IF self.components_responses IS NULL
      OR self.components_responses.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := dz_swagger3_response_list();
      FOR i IN 1 .. self.components_responses.COUNT
      LOOP
         IF self.components_responses(i).doREF() = 'TRUE'
         THEN
            ary_output.EXTEND();
            ary_output(int_index) := self.components_responses(i);
            int_index := int_index + 1;
            
         END IF;
         
      END LOOP;
      
      RETURN ary_output;
   
   END get_components_responses;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION get_components_parameters
   RETURN dz_swagger3_parameter_list
   AS
      int_index  PLS_INTEGER;
      ary_output dz_swagger3_parameter_list;
      
   BEGIN
      IF self.components_parameters IS NULL
      OR self.components_parameters.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := dz_swagger3_parameter_list();
      FOR i IN 1 .. self.components_parameters.COUNT
      LOOP
         IF self.components_parameters(i).doREF() = 'TRUE'
         AND self.components_parameters(i).parameter_list_hidden <> 'TRUE'
         THEN
            ary_output.EXTEND();
            ary_output(int_index) := self.components_parameters(i);
            int_index := int_index + 1;
           
         END IF;
         
      END LOOP;
      
      RETURN ary_output;
   
   END get_components_parameters;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION get_components_examples
   RETURN dz_swagger3_example_list
   AS
      int_index  PLS_INTEGER;
      ary_output dz_swagger3_example_list;
      
   BEGIN
      IF self.components_examples IS NULL
      OR self.components_examples.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := dz_swagger3_example_list();
      FOR i IN 1 .. self.components_examples.COUNT
      LOOP
         IF self.components_examples(i).doREF() = 'TRUE'
         THEN
            ary_output.EXTEND();
            ary_output(int_index) := self.components_examples(i);
            int_index := int_index + 1;
            
         END IF;
         
      END LOOP;
      
      RETURN ary_output;
   
   END get_components_examples;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION get_components_requestBodies
   RETURN dz_swagger3_requestBody_list
   AS
      int_index  PLS_INTEGER;
      ary_output dz_swagger3_requestBody_list;
      
   BEGIN
      IF self.components_requestBodies IS NULL
      OR self.components_requestBodies.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := dz_swagger3_requestBody_list();
      FOR i IN 1 .. self.components_requestBodies.COUNT
      LOOP
         IF self.components_requestBodies(i).doREF() = 'TRUE'
         THEN
            ary_output.EXTEND();
            ary_output(int_index) := self.components_requestBodies(i);
            int_index := int_index + 1;
         
         END IF;
         
      END LOOP;
      
      RETURN ary_output;
   
   END get_components_requestBodies;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION get_components_headers
   RETURN dz_swagger3_header_list
   AS
      int_index  PLS_INTEGER;
      ary_output dz_swagger3_header_list;
      
   BEGIN
      IF self.components_headers IS NULL
      OR self.components_headers.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := dz_swagger3_header_list();
      FOR i IN 1 .. self.components_headers.COUNT
      LOOP
         IF self.components_headers(i).doREF() = 'TRUE'
         THEN
            ary_output.EXTEND();
            ary_output(int_index) := self.components_headers(i);
            int_index := int_index + 1;
           
         END IF;
         
      END LOOP;
      
      RETURN ary_output;
   
   END get_components_headers;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION get_components_securitySchemes
   RETURN dz_swagger3_securitySchem_list
   AS
      int_index  PLS_INTEGER;
      ary_output dz_swagger3_securitySchem_list;
      
   BEGIN
      IF self.components_securitySchemes IS NULL
      OR self.components_securitySchemes.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := dz_swagger3_securitySchem_list();
      FOR i IN 1 .. self.components_securitySchemes.COUNT
      LOOP
         IF self.components_securitySchemes(i).doREF() = 'TRUE'
         THEN
            ary_output.EXTEND();
            ary_output(int_index) := self.components_securitySchemes(i);
            int_index := int_index + 1;
            
         END IF;
         
      END LOOP;
      
      RETURN ary_output;
   
   END get_components_securitySchemes;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION get_components_links
   RETURN dz_swagger3_link_list
   AS
      int_index  PLS_INTEGER;
      ary_output dz_swagger3_link_list;
      
   BEGIN
      IF self.components_links IS NULL
      OR self.components_links.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := dz_swagger3_link_list();
      FOR i IN 1 .. self.components_links.COUNT
      LOOP
         IF self.components_links(i).doREF() = 'TRUE'
         THEN
            ary_output.EXTEND();
            ary_output(int_index) := self.components_links(i);
            int_index := int_index + 1;
            
         END IF;
         
      END LOOP;
      
      RETURN ary_output;
   
   END get_components_links;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION get_components_callbacks
   RETURN dz_swagger3_callback_list
   AS
      int_index  PLS_INTEGER;
      ary_output dz_swagger3_callback_list;
      
   BEGIN
      IF self.components_callbacks IS NULL
      OR self.components_callbacks.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := dz_swagger3_callback_list();
      FOR i IN 1 .. self.components_callbacks.COUNT
      LOOP
         IF self.components_callbacks(i).doREF() = 'TRUE'
         THEN
            ary_output.EXTEND();
            ary_output(int_index) := self.components_callbacks(i);
            int_index := int_index + 1;
            
         END IF;
         
      END LOOP;
      
      RETURN ary_output;
   
   END get_components_callbacks;
   
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
      ary_schemas       dz_swagger3_schema_nf_list;
      ary_responses     dz_swagger3_response_list;
      ary_parameters    dz_swagger3_parameter_list;
      ary_examples      dz_swagger3_example_list;
      ary_requestBodies dz_swagger3_requestBody_list;
      ary_headers       dz_swagger3_header_list;
      ary_schemes       dz_swagger3_securitySchem_list;
      ary_links         dz_swagger3_link_list;
      ary_callbacks     dz_swagger3_callback_list;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      ary_schemas       := self.get_components_schemas();
      ary_responses     := self.get_components_responses();
      ary_parameters    := self.get_components_parameters();
      ary_examples      := self.get_components_examples();
      ary_requestBodies := self.get_components_requestBodies();
      ary_headers       := self.get_components_headers();
      ary_schemes       := self.get_components_securitySchemes();
      ary_links         := self.get_components_links();
      ary_callbacks     := self.get_components_callbacks(); 

      
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
      IF ary_schemas IS NULL
      OR ary_schemas.COUNT = 0
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
      
         FOR i IN 1 .. ary_schemas.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || ary_schemas(i).schema_id || '":' || str_pad || ary_schemas(i).toJSON_component(
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
      IF ary_responses IS NULL
      OR ary_responses.COUNT = 0
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
      
         FOR i IN 1 .. ary_responses.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || ary_responses(i).response_id || '":' || str_pad || ary_responses(i).toJSON_schema(
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
      IF ary_parameters IS NULL
      OR ary_parameters.COUNT = 0
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
      
         FOR i IN 1 .. ary_parameters.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || ary_parameters(i).parameter_id || '":' || str_pad || ary_parameters(i).toJSON_schema(
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
      IF ary_examples IS NULL
      OR ary_examples.COUNT = 0
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

         FOR i IN 1 .. ary_examples.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || ary_examples(i).example_id || '":' || str_pad || ary_examples(i).toJSON_schema(
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
      IF ary_requestBodies IS NULL
      OR ary_requestBodies.COUNT = 0
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

         FOR i IN 1 .. ary_requestBodies.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || ary_requestBodies(i).requestBody_id || '":' || str_pad || ary_requestBodies(i).toJSON_schema(
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
      IF ary_headers IS NULL
      OR ary_headers.COUNT = 0
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

         FOR i IN 1 .. ary_headers.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || ary_headers(i).header_id || '":' || str_pad || ary_headers(i).toJSON_schema(
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
      IF ary_schemes IS NULL
      OR ary_schemes.COUNT = 0
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

         FOR i IN 1 .. ary_schemes.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || ary_schemes(i).scheme_id || '":' || str_pad || ary_schemes(i).toJSON_schema(
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
      IF ary_links IS NULL
      OR ary_links.COUNT = 0
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

         FOR i IN 1 .. ary_links.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || ary_links(i).link_id || '":' || str_pad || ary_links(i).toJSON_schema(
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
      IF ary_callbacks IS NULL
      OR ary_callbacks.COUNT = 0
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

         FOR i IN 1 .. ary_callbacks.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || ary_callbacks(i).callback_id || '":' || str_pad || ary_callbacks(i).toJSON_schema(
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
      ary_schemas       dz_swagger3_schema_nf_list;
      ary_responses     dz_swagger3_response_list;
      ary_parameters    dz_swagger3_parameter_list;
      ary_examples      dz_swagger3_example_list;
      ary_requestBodies dz_swagger3_requestBody_list;
      ary_headers       dz_swagger3_header_list;
      ary_schemes       dz_swagger3_securitySchem_list;
      ary_links         dz_swagger3_link_list;
      ary_callbacks     dz_swagger3_callback_list;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      ary_schemas       := self.get_components_schemas();
      ary_responses     := self.get_components_responses();
      ary_parameters    := self.get_components_parameters();
      ary_examples      := self.get_components_examples();
      ary_requestBodies := self.get_components_requestBodies();
      ary_headers       := self.get_components_headers();
      ary_schemes       := self.get_components_securitySchemes();
      ary_links         := self.get_components_links();
      ary_callbacks     := self.get_components_callbacks(); 

      --------------------------------------------------------------------------
      -- Step 20
      -- Write the component schemas
      --------------------------------------------------------------------------
      IF ary_schemas IS NULL 
      OR ary_schemas.COUNT = 0
      OR p_force_inline = 'TRUE'
      THEN
         NULL;

      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'schemas: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. ary_schemas.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                dz_swagger3_util.yamlq(ary_schemas(i).schema_id) || ': '
               ,p_pretty_print + 1
               ,'  '
            ) || ary_schemas(i).toYAML_component(
                p_pretty_print   => p_pretty_print + 2
               ,p_force_inline   => p_force_inline
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the component responses
      --------------------------------------------------------------------------
      IF ary_responses IS NULL 
      OR ary_responses.COUNT = 0
      OR p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'responses: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. ary_responses.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                dz_swagger3_util.yamlq(ary_responses(i).response_id) || ': '
               ,p_pretty_print + 1
               ,'  '
            ) || ary_responses(i).toYAML_schema(
                p_pretty_print   => p_pretty_print + 2
               ,p_force_inline   => p_force_inline
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the component parameters
      --------------------------------------------------------------------------
      IF ary_parameters IS NULL 
      OR ary_parameters.COUNT = 0
      OR p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'parameters: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. ary_parameters.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                dz_swagger3_util.yamlq(ary_parameters(i).parameter_id) || ': '
               ,p_pretty_print + 1
               ,'  '
            ) || ary_parameters(i).toYAML_schema(
                p_pretty_print   => p_pretty_print + 2
               ,p_force_inline   => p_force_inline
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the component examples
      --------------------------------------------------------------------------
      IF ary_examples IS NULL 
      OR ary_examples.COUNT = 0
      OR p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'examples: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. ary_examples.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                dz_swagger3_util.yamlq(ary_examples(i).example_id) || ': '
               ,p_pretty_print + 1
               ,'  '
            ) || ary_examples(i).toYAML_schema(
                p_pretty_print   => p_pretty_print + 2
               ,p_force_inline   => p_force_inline
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Write the component requestBodies
      --------------------------------------------------------------------------
      IF ary_requestBodies IS NULL 
      OR ary_requestBodies.COUNT = 0
      OR p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'requestBodies: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. ary_requestBodies.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                dz_swagger3_util.yamlq(ary_requestBodies(i).requestBody_id) || ': '
               ,p_pretty_print + 1
               ,'  '
            ) || ary_requestBodies(i).toYAML_schema(
                p_pretty_print   => p_pretty_print + 2
               ,p_force_inline   => p_force_inline
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Write the component headers
      --------------------------------------------------------------------------
      IF ary_headers IS NULL 
      OR ary_headers.COUNT = 0
      OR p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'headers: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. ary_headers.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                dz_swagger3_util.yamlq(ary_headers(i).header_id) || ': '
               ,p_pretty_print + 1
               ,'  '
            ) || ary_headers(i).toYAML_schema(
                p_pretty_print   => p_pretty_print + 2
               ,p_force_inline   => p_force_inline
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Write the component securitySchemes
      --------------------------------------------------------------------------
      IF ary_schemes IS NULL 
      OR ary_schemes.COUNT = 0
      OR p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'securitySchemes: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. ary_schemes.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                dz_swagger3_util.yamlq(ary_schemes(i).scheme_id) || ': '
               ,p_pretty_print + 1
               ,'  '
            ) || ary_schemes(i).toYAML_schema(
                p_pretty_print   => p_pretty_print + 2
               ,p_force_inline   => p_force_inline
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Write the component links
      --------------------------------------------------------------------------
      IF ary_links IS NULL 
      OR ary_links.COUNT = 0
      OR p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'links: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. ary_links.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                dz_swagger3_util.yamlq(ary_links(i).link_id) || ': '
               ,p_pretty_print + 1
               ,'  '
            ) || ary_links(i).toYAML_schema(
                p_pretty_print   => p_pretty_print + 2
               ,p_force_inline   => p_force_inline
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Write the component callbacks
      --------------------------------------------------------------------------
      IF ary_callbacks IS NULL 
      OR ary_callbacks.COUNT = 0
      OR p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'callbacks: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. ary_callbacks.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                dz_swagger3_util.yamlq(ary_callbacks(i).callback_id) || ': '
               ,p_pretty_print + 1
               ,'  '
            ) || ary_callbacks(i).toYAML_schema(
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

