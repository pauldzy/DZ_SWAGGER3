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
       p_securityscheme_id       IN  VARCHAR2
      ,p_securityscheme_fullname IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Set up the object
      --------------------------------------------------------------------------
      self.versionid               := p_versionid;
      self.securityscheme_fullname := p_securityscheme_fullname;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Load the sercurity scheme basics
      --------------------------------------------------------------------------
      SELECT
       a.securityscheme_id
      ,a.securityscheme_type
      ,a.securityscheme_description
      ,a.securityscheme_name
      ,a.securityscheme_in
      ,a.securityscheme_scheme
      ,a.securityscheme_bearerFormat
      ,CASE
       WHEN a.oauth_flow_implicit IS NOT NULL
       THEN
         dz_swagger3_oauth_flow_typ(
             p_oauth_flow_id => a.oauth_flow_implicit 
            ,p_versionid     => p_versionid
         )
       ELSE
         NULL
       END
      ,CASE
       WHEN a.oauth_flow_password IS NOT NULL
       THEN
         dz_swagger3_oauth_flow_typ(
             p_oauth_flow_id => a.oauth_flow_password
            ,p_versionid     => p_versionid
         )
       ELSE
         NULL
       END
      ,CASE
       WHEN a.oauth_flow_clientCredentials IS NOT NULL
       THEN
         dz_swagger3_oauth_flow_typ(
             p_oauth_flow_id => a.oauth_flow_clientCredentials 
            ,p_versionid     => p_versionid
         )
       ELSE
         NULL
       END
      ,CASE
       WHEN a.oauth_flow_authorizationCode IS NOT NULL
       THEN
         dz_swagger3_oauth_flow_typ(
             p_oauth_flow_id => a.oauth_flow_authorizationCode 
            ,p_versionid     => p_versionid
         )
       ELSE
         NULL
       END
      ,a.securityscheme_openidcredents
      INTO
       self.securityscheme_id
      ,self.securityscheme_type
      ,self.securityscheme_description
      ,self.securityscheme_name
      ,self.securityscheme_in
      ,self.securityscheme_scheme
      ,self.securityscheme_bearerFormat
      ,self.oauth_flow_implicit 
      ,self.oauth_flow_password
      ,self.oauth_flow_clientCredentials
      ,self.oauth_flow_authorizationCode
      ,self.securityscheme_openIdConUrl 
      FROM
      dz_swagger3_securityScheme a
      WHERE
          a.versionid         = p_versionid
      AND a.securityscheme_id = p_securityscheme_id;

      --------------------------------------------------------------------------
      -- Step 30
      -- Return the completed object
      --------------------------------------------------------------------------
      RETURN; 
      
   END dz_swagger3_securityScheme_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print            IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      cb            CLOB;
      v2            VARCHAR2(32000);
     
      str_pad       VARCHAR2(1 Char);
      str_pad1      VARCHAR2(1 Char);
      str_pad2      VARCHAR2(1 Char);
      
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
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => dz_json_util.pretty('{',NULL)
         );

      ELSE
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => dz_json_util.pretty('{',-1)
         );
         str_pad     := ' ';

      END IF;
      str_pad1 := str_pad;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Add scheme type
      --------------------------------------------------------------------------
      IF self.securityscheme_type IS NOT NULL
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => str_pad1 || dz_json_main.value2json(
                'type'
               ,self.securityscheme_type
               ,p_pretty_print + 1
             )
            ,p_pretty_print => p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add scheme description
      --------------------------------------------------------------------------
      IF self.securityscheme_description IS NOT NULL
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => str_pad1 || dz_json_main.value2json(
                'description'
               ,self.securityscheme_description
               ,p_pretty_print + 1
             )
            ,p_pretty_print => p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add scheme name
      --------------------------------------------------------------------------
      IF self.securityscheme_name IS NOT NULL
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => str_pad1 || dz_json_main.value2json(
                'name'
               ,self.securityscheme_name
               ,p_pretty_print + 1
             )
            ,p_pretty_print => p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Add scheme in
      --------------------------------------------------------------------------
      IF self.securityscheme_in IS NOT NULL
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => str_pad1 || dz_json_main.value2json(
                'in'
               ,self.securityscheme_in
               ,p_pretty_print + 1
             )
            ,p_pretty_print => p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Add scheme scheme
      --------------------------------------------------------------------------
      IF self.securityscheme_scheme IS NOT NULL
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => str_pad1 || dz_json_main.value2json(
                'scheme'
               ,self.securityscheme_scheme
               ,p_pretty_print + 1
             )
            ,p_pretty_print => p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Add scheme bearerFormat
      --------------------------------------------------------------------------
      IF self.securityscheme_bearerFormat IS NOT NULL
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => str_pad1 || dz_json_main.value2json(
                'bearerFormat'
               ,self.securityscheme_bearerFormat
               ,p_pretty_print + 1
             )
            ,p_pretty_print => p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Add flows object
      --------------------------------------------------------------------------
      IF self.oauth_flow_implicit IS NOT NULL
      OR self.oauth_flow_password IS NOT NULL
      OR self.oauth_flow_clientCredentials IS NOT NULL
      OR self.oauth_flow_authorizationCode IS NOT NULL
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => str_pad1 || '"flows":' || str_pad || '{'
            ,p_pretty_print => p_pretty_print + 1
         );
         
         str_pad2 := str_pad;

         IF self.oauth_flow_implicit IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => str_pad2 || '"implicit":' || str_pad
               ,p_pretty_print => p_pretty_print + 2
            );
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => self.oauth_flow_implicit.toJSON(p_pretty_print + 2)
               ,p_in_v => NULL
               ,p_pretty_print => p_pretty_print + 2
            );
            
            str_pad2 := ',';
         
         END IF;
         
         IF self.oauth_flow_password IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => str_pad2 || '"password":' || str_pad
               ,p_pretty_print => p_pretty_print + 2
            );
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => self.oauth_flow_password.toJSON(p_pretty_print + 2)
               ,p_in_v => NULL
               ,p_pretty_print => p_pretty_print + 2
            );
            
            str_pad2 := ',';
         
         END IF;
         
         IF self.oauth_flow_clientCredentials IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => str_pad2 || '"clientCredentials":' || str_pad
               ,p_pretty_print => p_pretty_print + 2
            );
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => self.oauth_flow_clientCredentials.toJSON(p_pretty_print + 2)
               ,p_in_v => NULL
               ,p_pretty_print => p_pretty_print + 2
            );
            
            str_pad2 := ',';
         
         END IF;
         
         IF self.oauth_flow_authorizationCode IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => str_pad2 || '"authorizationCode":' || str_pad
               ,p_pretty_print => p_pretty_print + 2
            );
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => self.oauth_flow_authorizationCode.toJSON(p_pretty_print + 2)
               ,p_in_v => NULL
               ,p_pretty_print => p_pretty_print + 2
            );
            
            str_pad2 := ',';
         
         END IF;
         
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => '}'
            ,p_pretty_print => p_pretty_print + 1
         );
         
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Add scheme openIdConnectUrl
      --------------------------------------------------------------------------
      IF self.securityscheme_openIdConUrl IS NOT NULL
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => str_pad1 || dz_json_main.value2json(
                'openIdConnectUrl'
               ,self.securityscheme_openIdConUrl
               ,p_pretty_print + 1
             )
            ,p_pretty_print => p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
         
      --------------------------------------------------------------------------
      -- Step 70
      -- Add the left bracket
      --------------------------------------------------------------------------
      dz_swagger3_util.conc(
          p_c    => cb
         ,p_v    => v2
         ,p_in_c => NULL
         ,p_in_v => '}'
         ,p_pretty_print => p_pretty_print
         ,p_final_linefeed => FALSE
      );

      --------------------------------------------------------------------------
      -- Step 80
      -- Cough it out
      --------------------------------------------------------------------------
      dz_swagger3_util.fconc(
          p_c    => cb
         ,p_v    => v2
      );
      
      RETURN cb;
           
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON_req(
       p_pretty_print            IN  INTEGER   DEFAULT NULL
      ,p_oauth_scope_flows       IN  VARCHAR2  DEFAULT NULL
   ) RETURN CLOB
   AS
      cb            CLOB;
      v2            VARCHAR2(32000);
     
      str_pad       VARCHAR2(1 Char);
      str_pad1      VARCHAR2(1 Char);
      ary_oauth     MDSYS.SDO_STRING2_ARRAY;
      
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
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => dz_json_util.pretty('{',NULL)
         );

      ELSE
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => dz_json_util.pretty('{',-1)
         );
         str_pad     := ' ';

      END IF;
      str_pad1 := str_pad;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add security item with oauth scopes 
      --------------------------------------------------------------------------
      IF  self.securityScheme_type IN ('oauth2','openIdConnect')
      AND p_oauth_scope_flows IS NOT NULL
      THEN
         ary_oauth := dz_json_util.gz_split(p_oauth_scope_flows,',');
         
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => str_pad1 || dz_json_main.value2json(
                self.securityScheme_fullname
               ,ary_oauth
               ,p_pretty_print + 1
             )
            ,p_pretty_print => p_pretty_print + 1
         );
         str_pad1 := ',';
         
      ELSE
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => str_pad1 || '"' || self.securityScheme_fullname || '":' || str_pad || '[]'
            ,p_pretty_print => p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 70
      -- Add the left bracket
      --------------------------------------------------------------------------
      dz_swagger3_util.conc(
          p_c    => cb
         ,p_v    => v2
         ,p_in_c => NULL
         ,p_in_v => '}'
         ,p_pretty_print   => p_pretty_print
         ,p_final_linefeed => FALSE
      );

      --------------------------------------------------------------------------
      -- Step 80
      -- Cough it out
      --------------------------------------------------------------------------
      dz_swagger3_util.fconc(
          p_c    => cb
         ,p_v    => v2
      );
      
      RETURN cb;
           
   END toJSON_req;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print            IN  INTEGER   DEFAULT 0
      ,p_initial_indent          IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed          IN  VARCHAR2  DEFAULT 'TRUE'
   ) RETURN CLOB
   AS
      cb            CLOB;
      v2            VARCHAR2(32000);
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------

      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml scheme type
      --------------------------------------------------------------------------
      dz_swagger3_util.conc(
          p_c    => cb
         ,p_v    => v2
         ,p_in_c => NULL
         ,p_in_v => 'type: ' || dz_swagger3_util.yaml_text(
             self.securityscheme_type
            ,p_pretty_print
          )
         ,p_pretty_print => p_pretty_print
         ,p_amount       => '  '
      );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the yaml scheme description
      --------------------------------------------------------------------------
      IF self.securityscheme_description IS NOT NULL
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => 'description: ' || dz_swagger3_util.yaml_text(
                self.securityscheme_description
               ,p_pretty_print
             )
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the yaml scheme name
      --------------------------------------------------------------------------
      IF self.securityscheme_name IS NOT NULL
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => 'name: ' || dz_swagger3_util.yaml_text(
                self.securityscheme_name
               ,p_pretty_print
             )
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the yaml scheme in
      --------------------------------------------------------------------------
      IF self.securityscheme_in IS NOT NULL
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => 'in: ' || dz_swagger3_util.yaml_text(
                self.securityscheme_in
               ,p_pretty_print
             )
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Write the yaml scheme auth
      --------------------------------------------------------------------------
      IF self.securityscheme_scheme IS NOT NULL
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => 'scheme: ' || dz_swagger3_util.yaml_text(
                self.securityscheme_scheme
               ,p_pretty_print
             )
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Write the yaml scheme in
      --------------------------------------------------------------------------
      IF self.securityscheme_bearerFormat IS NOT NULL
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => 'bearerFormat: ' || dz_swagger3_util.yaml_text(
                self.securityscheme_bearerFormat
               ,p_pretty_print
             )
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Write the yaml scheme in
      --------------------------------------------------------------------------
      IF self.oauth_flow_implicit IS NOT NULL
      OR self.oauth_flow_password IS NOT NULL
      OR self.oauth_flow_clientCredentials IS NOT NULL
      OR self.oauth_flow_authorizationCode IS NOT NULL
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => 'flows: '
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );

         IF self.oauth_flow_implicit IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'implicit: '
               ,p_pretty_print => p_pretty_print + 1
               ,p_amount       => '  '
            );
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => self.oauth_flow_implicit.toYAML(
                  p_pretty_print + 2
                )
               ,p_in_v => NULL
            );
         
         END IF;
         
         IF self.oauth_flow_password IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'password: '
               ,p_pretty_print => p_pretty_print + 1
               ,p_amount       => '  '
            );
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => self.oauth_flow_password.toYAML(
                  p_pretty_print + 2
                )
               ,p_in_v => NULL
            );
         
         END IF;
         
         IF self.oauth_flow_clientCredentials IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'clientCredentials: '
               ,p_pretty_print => p_pretty_print + 1
               ,p_amount       => '  '
            );
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => self.oauth_flow_clientCredentials.toYAML(
                  p_pretty_print + 2
                )
               ,p_in_v => NULL
            );
         
         END IF;
         
         IF self.oauth_flow_authorizationCode IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'authorizationCode: '
               ,p_pretty_print => p_pretty_print + 1
               ,p_amount       => '  '
            );
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => self.oauth_flow_authorizationCode.toYAML(
                  p_pretty_print + 2
                )
               ,p_in_v => NULL
            );
         
         END IF;
             
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Write the yaml scheme in
      --------------------------------------------------------------------------
      IF self.securityscheme_openIdConUrl IS NOT NULL
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => 'openIdConnectUrl: ' || dz_swagger3_util.yaml_text(
                self.securityscheme_openIdConUrl
               ,p_pretty_print
             )
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Cough it out without final line feed
      --------------------------------------------------------------------------
      dz_swagger3_util.fconc(
          p_c    => cb
         ,p_v    => v2
      );
      
      IF p_initial_indent = 'FALSE'
      THEN
         cb := REGEXP_REPLACE(cb,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         cb := REGEXP_REPLACE(cb,CHR(10) || '$','');
         
      END IF;
               
      RETURN cb;
      
   END toYAML;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML_req(
       p_pretty_print            IN  INTEGER   DEFAULT 0
      ,p_initial_indent          IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed          IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_oauth_scope_flows       IN  VARCHAR2  DEFAULT NULL
   ) RETURN CLOB
   AS
      cb            CLOB;
      v2            VARCHAR2(32000);
      ary_oauth     MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml contact name
      --------------------------------------------------------------------------
      IF  self.securityScheme_type IN ('oauth2','openIdConnect')
      AND p_oauth_scope_flows IS NOT NULL
      THEN
         ary_oauth := dz_json_util.gz_split(p_oauth_scope_flows,',');
         
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => dz_swagger3_util.yamlq(self.securityScheme_fullname) || ': '
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );
         
         FOR i IN 1 .. ary_oauth.COUNT
         LOOP
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => '- ' || dz_swagger3_util.yamlq(ary_oauth(i))
               ,p_pretty_print => p_pretty_print + 1
               ,p_amount       => '  '
            );
         
         END LOOP; 
            
      ELSE
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => dz_swagger3_util.yamlq(self.securityScheme_fullname) || ': []'
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 110
      -- Cough it out without final line feed
      --------------------------------------------------------------------------
      dz_swagger3_util.fconc(
          p_c    => cb
         ,p_v    => v2
      );
      
      IF p_initial_indent = 'FALSE'
      THEN
         cb := REGEXP_REPLACE(cb,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         cb := REGEXP_REPLACE(cb,CHR(10) || '$','');
         
      END IF;
               
      RETURN cb;
      
   END toYAML_req;
   
END;
/

