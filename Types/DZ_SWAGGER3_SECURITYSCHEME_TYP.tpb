CREATE OR REPLACE TYPE BODY dz_swagger3_securityScheme_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_securityScheme_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_securityScheme_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_securityScheme_typ(
       p_hash_key                IN  VARCHAR2
      ,p_scheme_id               IN  VARCHAR2
      ,p_scheme_type             IN  VARCHAR2
      ,p_scheme_description      IN  VARCHAR2
      ,p_scheme_name             IN  VARCHAR2
      ,p_scheme_in               IN  VARCHAR2
      ,p_scheme_auth             IN  VARCHAR2
      ,p_scheme_bearerFormat     IN  VARCHAR2
      ,p_scheme_flows            IN  dz_swagger3_oauth_flows_typ
      ,p_scheme_openIdConnectUrl IN  VARCHAR2
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.hash_key                := p_hash_key;
      self.scheme_id               := p_scheme_id;
      self.scheme_type             := p_scheme_type;
      self.scheme_description      := p_scheme_description;
      self.scheme_name             := p_scheme_name;
      self.scheme_in               := p_scheme_in;
      self.scheme_auth             := p_scheme_auth;
      self.scheme_bearerFormat     := p_scheme_bearerFormat;
      self.scheme_flows            := p_scheme_flows;
      self.scheme_openIdConnectUrl := p_scheme_openIdConnectUrl;      
      
      RETURN; 
      
   END dz_swagger3_securityScheme_typ;
   
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
   MEMBER FUNCTION toJSON(
       p_pretty_print     IN  INTEGER   DEFAULT NULL
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
      -- Add scheme type
      --------------------------------------------------------------------------
      IF self.scheme_type IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'type'
               ,self.scheme_type
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Add scheme description
      --------------------------------------------------------------------------
      IF self.scheme_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'description'
               ,self.scheme_description
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add scheme name
      --------------------------------------------------------------------------
      IF self.scheme_name IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'name'
               ,self.scheme_name
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add scheme in
      --------------------------------------------------------------------------
      IF self.scheme_in IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'in'
               ,self.scheme_in
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Add scheme auth
      --------------------------------------------------------------------------
      IF self.scheme_auth IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'auth'
               ,self.scheme_auth
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Add scheme bearerFormat
      --------------------------------------------------------------------------
      IF self.scheme_bearerFormat IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'bearerFormat'
               ,self.scheme_bearerFormat
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Add flows object
      --------------------------------------------------------------------------
      IF  self.scheme_flows IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'flows'
               ,self.scheme_flows.toJSON(p_pretty_print + 1)
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Add scheme openIdConnectUrl
      --------------------------------------------------------------------------
      IF self.scheme_openIdConnectUrl IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'openIdConnectUrl'
               ,self.scheme_openIdConnectUrl
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
         
      --------------------------------------------------------------------------
      -- Step 110
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 120
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
      -- Write the yaml scheme type
      --------------------------------------------------------------------------
      IF self.scheme_type IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'type: ' || dz_swagger3_util.yaml_text(
                self.scheme_type
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the yaml scheme description
      --------------------------------------------------------------------------
      IF self.scheme_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'description: ' || dz_swagger3_util.yaml_text(
                self.scheme_description
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the yaml scheme name
      --------------------------------------------------------------------------
      IF self.scheme_name IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'name: ' || dz_swagger3_util.yaml_text(
                self.scheme_name
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the yaml scheme in
      --------------------------------------------------------------------------
      IF self.scheme_in IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'in: ' || dz_swagger3_util.yaml_text(
                self.scheme_in
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Write the yaml scheme auth
      --------------------------------------------------------------------------
      IF self.scheme_auth IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'scheme: ' || dz_swagger3_util.yaml_text(
                self.scheme_auth
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Write the yaml scheme in
      --------------------------------------------------------------------------
      IF self.scheme_bearerFormat IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'bearerFormat: ' || dz_swagger3_util.yaml_text(
                self.scheme_bearerFormat
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Write the yaml scheme in
      --------------------------------------------------------------------------
      IF self.scheme_flows IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'flows: '
            ,p_pretty_print
            ,'  '
         ) || self.scheme_flows.toYAML(
            p_pretty_print + 1
         );  
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Write the yaml scheme in
      --------------------------------------------------------------------------
      IF self.scheme_openIdConnectUrl IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'openIdConnectUrl: ' || dz_swagger3_util.yaml_text(
                self.scheme_openIdConnectUrl
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
      
   END toYAML;
   
END;
/

