CREATE OR REPLACE TYPE BODY dz_swagger3_example_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_example_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_example_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_example_typ(
       p_hash_key                IN  VARCHAR2
      ,p_example_id              IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
      ,p_load_components         IN  VARCHAR2 DEFAULT 'TRUE'
      ,p_ref_brake               IN  VARCHAR2 DEFAULT 'FALSE'
   ) RETURN SELF AS RESULT
   AS 
   BEGIN
   
      SELECT
      dz_swagger3_example_typ(
          p_hash_key               => p_hash_key
         ,p_example_id             => a.example_id
         ,p_example_summary        => a.example_summary
         ,p_example_description    => a.example_description
         ,p_example_value_string   => a.example_value_string
         ,p_example_value_number   => a.example_value_number
         ,p_example_externalValue  => a.example_externalValue
         ,p_load_components        => p_load_components
      )
      INTO SELF
      FROM
      dz_swagger3_example a
      WHERE
          a.versionid = p_versionid
      AND a.example_id = p_example_id;
   
   RETURN; 
      
   END dz_swagger3_example_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_example_typ(
       p_hash_key                IN  VARCHAR2
      ,p_example_id              IN  VARCHAR2
      ,p_example_summary         IN  VARCHAR2
      ,p_example_description     IN  VARCHAR2
      ,p_example_value_string    IN  VARCHAR2
      ,p_example_value_number    IN  NUMBER
      ,p_example_externalValue   IN  VARCHAR2
      ,p_load_components         IN  VARCHAR2 DEFAULT 'TRUE'
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.hash_key              := p_hash_key;
      self.example_id            := p_example_id;
      self.example_summary       := p_example_summary;
      self.example_description   := p_example_description;
      self.example_value_string  := p_example_value_string;
      self.example_value_number  := p_example_value_number;
      self.example_externalValue := p_example_externalValue;
      
      --------------------------------------------------------------------------
      IF self.doREF() = 'TRUE'
      AND p_load_components = 'TRUE'
      THEN
         dz_swagger3_main.insert_component(
             p_object_id     => p_example_id
            ,p_object_type   => 'example'
            ,p_response_code => p_hash_key
         );
         
      END IF;
      
      RETURN; 
      
   END dz_swagger3_example_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION isNULL
   RETURN VARCHAR2
   AS
   BEGIN
   
      IF self.example_summary       IS NOT NULL
      OR self.example_description   IS NOT NULL
      OR self.example_value_string  IS NOT NULL
      OR self.example_value_number  IS NOT NULL
      OR self.example_externalValue IS NOT NULL
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
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
   BEGIN
   
      IF self.doREF() = 'TRUE'
      AND p_force_inline <> 'TRUE'
      THEN
         RETURN toJSON_ref(
             p_pretty_print  => p_pretty_print
            ,p_force_inline  => p_force_inline
         );
   
      ELSE
         RETURN toJSON_schema(
             p_pretty_print  => p_pretty_print
            ,p_force_inline  => p_force_inline
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
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional summary
      --------------------------------------------------------------------------
      IF self.example_summary IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.value2json(
                'summary'
               ,self.example_summary
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional description 
      --------------------------------------------------------------------------
      IF self.example_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.value2json(
                'description'
               ,self.example_description
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional value
      --------------------------------------------------------------------------
      IF self.example_value_string IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.value2json(
                'value'
               ,self.example_value_string
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';

      ELSIF self.example_value_number IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.value2json(
                'value'
               ,self.example_value_number
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add optional externalValue
      --------------------------------------------------------------------------
      IF self.example_externalValue IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.value2json(
                'externalValue'
               ,self.example_externalValue
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';

      END IF;
 
      --------------------------------------------------------------------------
      -- Step 70
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 80
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
      IF  p_pretty_print IS NULL
      AND p_force_inline <> 'TRUE'
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
      -- Add optional summary
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.value2json(
             '$ref'
            ,'#/components/examples/' || dz_swagger3_main.short(
                p_object_id   => self.example_id
               ,p_object_type => 'example'
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
      clb_output        CLOB;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml summary
      --------------------------------------------------------------------------
      IF self.example_summary IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'summary: ' || dz_swagger3_util.yaml_text(
                self.example_summary
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional license url
      --------------------------------------------------------------------------
      IF self.example_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'description: ' || dz_swagger3_util.yaml_text(
                self.example_description
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional value
      --------------------------------------------------------------------------
      IF self.example_value_string IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'value: ' || dz_swagger3_util.yaml_text(
                self.example_value_string
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      ELSIF self.example_value_number IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'value: ' || dz_swagger3_util.yaml_text(
                self.example_value_number
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional license url
      --------------------------------------------------------------------------
      IF self.example_externalValue IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'externalValue: ' || dz_swagger3_util.yaml_text(
                self.example_externalValue
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
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
      clb_output        CLOB;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml summary
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty_str(
          '$ref: ' || dz_swagger3_util.yaml_text(
             '#/components/examples/' || dz_swagger3_main.short(
                p_object_id   => self.example_id
               ,p_object_type => 'example'
             )
            ,p_pretty_print
         )
         ,p_pretty_print
         ,'  '
      );
      
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
      
   END toYAML_ref;
   
END;
/

