CREATE OR REPLACE TYPE BODY dz_swagger3_components
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_components
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      self.components_schemas         := dz_swagger3_schema_list();
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
       p_components_schemas           IN  dz_swagger3_schema_list
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
   MEMBER FUNCTION components_schemas_keys
   RETURN MDSYS.SDO_STRING2_ARRAY
   AS
      int_index  PLS_INTEGER;
      ary_output MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
      IF self.components_schemas IS NULL
      OR self.components_schemas.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := MDSYS.SDO_STRING2_ARRAY();
      FOR i IN 1 .. self.components_schemas.COUNT
      LOOP
         ary_output(int_index) := self.components_schemas(i).key();
      
      END LOOP;
      
      RETURN ary_output;
   
   END components_schemas_keys;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION components_responses_keys
   RETURN MDSYS.SDO_STRING2_ARRAY
   AS
      int_index  PLS_INTEGER;
      ary_output MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
      IF self.components_responses IS NULL
      OR self.components_responses.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := MDSYS.SDO_STRING2_ARRAY();
      FOR i IN 1 .. self.components_responses.COUNT
      LOOP
         ary_output(int_index) := self.components_responses(i).hash_key;
      
      END LOOP;
      
      RETURN ary_output;
   
   END components_responses_keys;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION components_parameters_keys
   RETURN MDSYS.SDO_STRING2_ARRAY
   AS
      int_index  PLS_INTEGER;
      ary_output MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
      IF self.components_parameters IS NULL
      OR self.components_parameters.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := MDSYS.SDO_STRING2_ARRAY();
      FOR i IN 1 .. self.components_parameters.COUNT
      LOOP
         ary_output(int_index) := self.components_parameters(i).hash_key;
      
      END LOOP;
      
      RETURN ary_output;
   
   END components_parameters_keys;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION components_examples_keys
   RETURN MDSYS.SDO_STRING2_ARRAY
   AS
      int_index  PLS_INTEGER;
      ary_output MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
      IF self.components_examples IS NULL
      OR self.components_examples.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := MDSYS.SDO_STRING2_ARRAY();
      FOR i IN 1 .. self.components_examples.COUNT
      LOOP
         ary_output(int_index) := self.components_examples(i).hash_key;
      
      END LOOP;
      
      RETURN ary_output;
   
   END components_examples_keys;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION components_requestBodies_keys
   RETURN MDSYS.SDO_STRING2_ARRAY
   AS
      int_index  PLS_INTEGER;
      ary_output MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
      IF self.components_requestBodies IS NULL
      OR self.components_requestBodies.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := MDSYS.SDO_STRING2_ARRAY();
      FOR i IN 1 .. self.components_requestBodies.COUNT
      LOOP
         ary_output(int_index) := self.components_requestBodies(i).hash_key;
      
      END LOOP;
      
      RETURN ary_output;
   
   END components_requestBodies_keys;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION components_headers_keys
   RETURN MDSYS.SDO_STRING2_ARRAY
   AS
      int_index  PLS_INTEGER;
      ary_output MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
      IF self.components_headers IS NULL
      OR self.components_headers.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := MDSYS.SDO_STRING2_ARRAY();
      FOR i IN 1 .. self.components_headers.COUNT
      LOOP
         ary_output(int_index) := self.components_headers(i).hash_key;
      
      END LOOP;
      
      RETURN ary_output;
   
   END components_headers_keys;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION components_securityScheme_keys
   RETURN MDSYS.SDO_STRING2_ARRAY
   AS
      int_index  PLS_INTEGER;
      ary_output MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
      IF self.components_securitySchemes IS NULL
      OR self.components_securitySchemes.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := MDSYS.SDO_STRING2_ARRAY();
      FOR i IN 1 .. self.components_securitySchemes.COUNT
      LOOP
         ary_output(int_index) := self.components_securitySchemes(i).hash_key;
      
      END LOOP;
      
      RETURN ary_output;
   
   END components_securityScheme_keys;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION components_links_keys
   RETURN MDSYS.SDO_STRING2_ARRAY
   AS
      int_index  PLS_INTEGER;
      ary_output MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
      IF self.components_links IS NULL
      OR self.components_links.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := MDSYS.SDO_STRING2_ARRAY();
      FOR i IN 1 .. self.components_links.COUNT
      LOOP
         ary_output(int_index) := self.components_links(i).hash_key;
      
      END LOOP;
      
      RETURN ary_output;
   
   END components_links_keys;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION components_callbacks_keys
   RETURN MDSYS.SDO_STRING2_ARRAY
   AS
      int_index  PLS_INTEGER;
      ary_output MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
      IF self.components_callbacks IS NULL
      OR self.components_callbacks.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := MDSYS.SDO_STRING2_ARRAY();
      FOR i IN 1 .. self.components_callbacks.COUNT
      LOOP
         ary_output(int_index) := self.components_callbacks(i).hash_key;
      
      END LOOP;
      
      RETURN ary_output;
   
   END components_callbacks_keys;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print     IN  INTEGER  DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      clb_hash         CLOB;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      
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
      
         ary_keys := self.components_schemas_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || dz_json_main.value2json(
                   ary_keys(i)
                  ,self.components_schemas(i).toJSON(
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
              'schemas'
             ,clb_hash
             ,p_pretty_print + 1
          )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Add responses map
      --------------------------------------------------------------------------
      IF self.components_responses IS NULL
      OR self.components_responses.COUNT = 0
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
      
         ary_keys := self.components_responses_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || dz_json_main.value2json(
                   ary_keys(i)
                  ,self.components_responses(i).toJSON(
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
              'responses'
             ,clb_hash
             ,p_pretty_print + 1
          )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add parameters map
      --------------------------------------------------------------------------
      IF self.components_parameters IS NULL
      OR self.components_parameters.COUNT = 0
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

         ary_keys := self.components_parameters_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || dz_json_main.value2json(
                   ary_keys(i)
                  ,self.components_parameters(i).toJSON(
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
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add examples map
      --------------------------------------------------------------------------
      IF self.components_examples IS NULL
      OR self.components_examples.COUNT = 0
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

         ary_keys := self.components_examples_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || dz_json_main.value2json(
                   ary_keys(i)
                  ,self.components_examples(i).toJSON(
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
              'examples'
             ,clb_hash
             ,p_pretty_print + 1
          )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Add requestBodies map
      --------------------------------------------------------------------------
      IF self.components_requestBodies IS NULL
      OR self.components_requestBodies.COUNT = 0
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

         ary_keys := self.components_requestBodies_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || dz_json_main.value2json(
                   ary_keys(i)
                  ,self.components_requestBodies(i).toJSON(
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
              'requestBodies'
             ,clb_hash
             ,p_pretty_print + 1
          )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Add headers map
      --------------------------------------------------------------------------
      IF self.components_headers IS NULL
      OR self.components_headers.COUNT = 0
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

         ary_keys := self.components_headers_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || dz_json_main.value2json(
                   ary_keys(i)
                  ,self.components_headers(i).toJSON(
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
              'headers'
             ,clb_hash
             ,p_pretty_print + 1
          )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Add headers map
      --------------------------------------------------------------------------
      IF self.components_securitySchemes IS NULL
      OR self.components_securitySchemes.COUNT = 0
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

         ary_keys := self.components_securityScheme_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || dz_json_main.value2json(
                   ary_keys(i)
                  ,self.components_securitySchemes(i).toJSON(
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
              'securitySchemes'
             ,clb_hash
             ,p_pretty_print + 1
          )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Add links map
      --------------------------------------------------------------------------
      IF self.components_links IS NULL
      OR self.components_links.COUNT = 0
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

         ary_keys := self.components_links_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || dz_json_main.value2json(
                   ary_keys(i)
                  ,self.components_links(i).toJSON(
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
              'links'
             ,clb_hash
             ,p_pretty_print + 1
          )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Add callbacks map
      --------------------------------------------------------------------------
      IF self.components_callbacks IS NULL
      OR self.components_callbacks.COUNT = 0
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

         ary_keys := self.components_callbacks_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || dz_json_main.value2json(
                   ary_keys(i)
                  ,self.components_callbacks(i).toJSON(
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
              'callbacks'
             ,clb_hash
             ,p_pretty_print + 1
          )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';
 
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
      p_pretty_print      IN  INTEGER  DEFAULT 0
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
      -- Write the component schemas
      --------------------------------------------------------------------------
      IF  self.components_schemas IS NULL 
      OR self.components_schemas.COUNT = 0
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'schemas: null'
            ,p_pretty_print
            ,'  '
         );
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'schemas: '
            ,p_pretty_print
            ,'  '
         );
         
         ary_keys := self.components_schemas_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '''' || ary_keys(i) || ''': '
               ,p_pretty_print + 1
               ,'  '
            ) || self.components_schemas(i).toYAML(
               p_pretty_print + 2
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the component responses
      --------------------------------------------------------------------------
      IF self.components_responses IS NULL 
      OR self.components_responses.COUNT = 0
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'responses: null'
            ,p_pretty_print
            ,'  '
         );
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'responses: '
            ,p_pretty_print
            ,'  '
         );
         
         ary_keys := self.components_responses_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '''' || ary_keys(i) || ''': '
               ,p_pretty_print + 1
               ,'  '
            ) || self.components_responses(i).toYAML(
               p_pretty_print + 2
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the component parameters
      --------------------------------------------------------------------------
      IF self.components_parameters IS NULL 
      OR self.components_parameters.COUNT = 0
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'parameters: null'
            ,p_pretty_print
            ,'  '
         );
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'parameters: '
            ,p_pretty_print
            ,'  '
         );
         
         ary_keys := self.components_parameters_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '''' || ary_keys(i) || ''': '
               ,p_pretty_print + 1
               ,'  '
            ) || self.components_parameters(i).toYAML(
               p_pretty_print + 2
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the component examples
      --------------------------------------------------------------------------
      IF self.components_examples IS NULL 
      OR self.components_examples.COUNT = 0
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'examples: null'
            ,p_pretty_print
            ,'  '
         );
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'examples: '
            ,p_pretty_print
            ,'  '
         );
         
         ary_keys := self.components_examples_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '''' || ary_keys(i) || ''': '
               ,p_pretty_print + 1
               ,'  '
            ) || self.components_examples(i).toYAML(
               p_pretty_print + 2
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Write the component requestBodies
      --------------------------------------------------------------------------
      IF self.components_requestBodies IS NULL 
      OR self.components_requestBodies.COUNT = 0
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'requestBodies: null'
            ,p_pretty_print
            ,'  '
         );
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'requestBodies: '
            ,p_pretty_print
            ,'  '
         );
         
         ary_keys := self.components_requestBodies_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '''' || ary_keys(i) || ''': '
               ,p_pretty_print + 1
               ,'  '
            ) || self.components_requestBodies(i).toYAML(
               p_pretty_print + 2
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Write the component headers
      --------------------------------------------------------------------------
      IF self.components_headers IS NULL 
      OR self.components_headers.COUNT = 0
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'headers: null'
            ,p_pretty_print
            ,'  '
         );
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'headers: '
            ,p_pretty_print
            ,'  '
         );
         
         ary_keys := self.components_headers_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '''' || ary_keys(i) || ''': '
               ,p_pretty_print + 1
               ,'  '
            ) || self.components_headers(i).toYAML(
               p_pretty_print + 2
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Write the component securitySchemes
      --------------------------------------------------------------------------
      IF self.components_securitySchemes IS NULL 
      OR self.components_securitySchemes.COUNT = 0
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'securitySchemes: null'
            ,p_pretty_print
            ,'  '
         );
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'securitySchemes: '
            ,p_pretty_print
            ,'  '
         );
         
         ary_keys := self.components_securityScheme_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '''' || ary_keys(i) || ''': '
               ,p_pretty_print + 1
               ,'  '
            ) || self.components_securitySchemes(i).toYAML(
               p_pretty_print + 2
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Write the component links
      --------------------------------------------------------------------------
      IF self.components_links IS NULL 
      OR self.components_links.COUNT = 0
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'links: null'
            ,p_pretty_print
            ,'  '
         );
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'links: '
            ,p_pretty_print
            ,'  '
         );
         
         ary_keys := self.components_links_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '''' || ary_keys(i) || ''': '
               ,p_pretty_print + 1
               ,'  '
            ) || self.components_links(i).toYAML(
               p_pretty_print + 2
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Write the component callbacks
      --------------------------------------------------------------------------
      IF self.components_callbacks IS NULL 
      OR self.components_callbacks.COUNT = 0
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'callbacks: null'
            ,p_pretty_print
            ,'  '
         );
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'callbacks: '
            ,p_pretty_print
            ,'  '
         );
         
         ary_keys := self.components_callbacks_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '''' || ary_keys(i) || ''': '
               ,p_pretty_print + 1
               ,'  '
            ) || self.components_callbacks(i).toYAML(
               p_pretty_print + 2
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Cough it out without final line feed
      --------------------------------------------------------------------------
      RETURN clb_output;
      
   END toYAML;
   
END;
/
