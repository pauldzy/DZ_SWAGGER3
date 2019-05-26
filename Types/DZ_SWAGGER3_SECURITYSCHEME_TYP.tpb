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
       p_pretty_print        IN  INTEGER   DEFAULT NULL
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
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;
      
      str_pad1 := str_pad;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Add scheme type
      --------------------------------------------------------------------------
      IF self.securityscheme_type IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'type'
               ,self.securityscheme_type
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add scheme description
      --------------------------------------------------------------------------
      IF self.securityscheme_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'description'
               ,self.securityscheme_description
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add scheme name
      --------------------------------------------------------------------------
      IF self.securityscheme_name IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'name'
               ,self.securityscheme_name
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Add scheme in
      --------------------------------------------------------------------------
      IF self.securityscheme_in IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'in'
               ,self.securityscheme_in
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Add scheme scheme
      --------------------------------------------------------------------------
      IF self.securityscheme_scheme IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'scheme'
               ,self.securityscheme_scheme
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Add scheme bearerFormat
      --------------------------------------------------------------------------
      IF self.securityscheme_bearerFormat IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'bearerFormat'
               ,self.securityscheme_bearerFormat
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Add flows object
      --------------------------------------------------------------------------
      IF  self.oauth_flow_implicit IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'flows'
               ,self.oauth_flow_implicit.toJSON(
                  p_pretty_print   => p_pretty_print + 1 
                )
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Add scheme openIdConnectUrl
      --------------------------------------------------------------------------
      IF self.securityscheme_openIdConUrl IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'openIdConnectUrl'
               ,self.securityscheme_openIdConUrl
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
   MEMBER FUNCTION toJSON_req(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
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
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add description 
      --------------------------------------------------------------------------
      IF self.securityScheme_type IN ('oauth2','openIdConnect')
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || '"' || self.securityScheme_fullname || '":' || str_pad || '[]'
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || '"' || self.securityScheme_fullname || '":' || str_pad || '[]'
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
/*
      --------------------------------------------------------------------------
      -- Step 30
      -- Add name element
      --------------------------------------------------------------------------
      IF  self.scope_names IS NOT NULL
      AND self.scope_names.COUNT > 0
      THEN
         FOR i IN 1 .. self.scope_names.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                str_pad || dz_json_main.json_format(self.scope_names(i))
               ,p_pretty_print + 1
            );
            str_pad := ',';

         END LOOP;
         
      END IF;
*/
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
           
   END toJSON_req;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
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
         ,p_in_v => dz_json_util.pretty_str(
             'type: ' || dz_swagger3_util.yaml_text(
                self.securityscheme_type
               ,p_pretty_print
             )
            ,p_pretty_print
            ,'  '
          ) 
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
            ,p_in_v => dz_json_util.pretty_str(
                'description: ' || dz_swagger3_util.yaml_text(
                   self.securityscheme_description
                  ,p_pretty_print
                )
               ,p_pretty_print
               ,'  '
             ) 
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
            ,p_in_v => dz_json_util.pretty_str(
                'name: ' || dz_swagger3_util.yaml_text(
                   self.securityscheme_name
                  ,p_pretty_print
                )
               ,p_pretty_print
               ,'  '
             ) 
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
            ,p_in_v => dz_json_util.pretty_str(
                'in: ' || dz_swagger3_util.yaml_text(
                   self.securityscheme_in
                  ,p_pretty_print
                )
               ,p_pretty_print
               ,'  '
             ) 
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
            ,p_in_v => dz_json_util.pretty_str(
                'scheme: ' || dz_swagger3_util.yaml_text(
                   self.securityscheme_scheme
                  ,p_pretty_print
                )
               ,p_pretty_print
               ,'  '
             ) 
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
            ,p_in_v => dz_json_util.pretty_str(
                'bearerFormat: ' || dz_swagger3_util.yaml_text(
                   self.securityscheme_bearerFormat
                  ,p_pretty_print
                )
               ,p_pretty_print
               ,'  '
             ) 
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
            ,p_in_v => dz_json_util.pretty_str(
                'flows: '
               ,p_pretty_print
               ,'  '
            )
         );

         IF self.oauth_flow_implicit IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty_str(
                   'implicit: '
                  ,p_pretty_print + 1
                  ,'  '
               )
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
               ,p_in_v => dz_json_util.pretty_str(
                   'password: '
                  ,p_pretty_print + 1
                  ,'  '
               )
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
               ,p_in_v => dz_json_util.pretty_str(
                   'clientCredentials: '
                  ,p_pretty_print + 1
                  ,'  '
               )
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
               ,p_in_v => dz_json_util.pretty_str(
                   'authorizationCode: '
                  ,p_pretty_print + 1
                  ,'  '
               )
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
            ,p_in_v => dz_json_util.pretty_str(
                'openIdConnectUrl: ' || dz_swagger3_util.yaml_text(
                   self.securityscheme_openIdConUrl
                  ,p_pretty_print
                )
               ,p_pretty_print
               ,'  '
             ) 
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
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
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
      -- Write the yaml contact name
      --------------------------------------------------------------------------
      IF self.securityScheme_type IN ('oauth2','openIdConnect')
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             dz_swagger3_util.yamlq(self.securityScheme_fullname) || ': []'
            ,p_pretty_print + 1
            ,'  '
         );
            
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             dz_swagger3_util.yamlq(self.securityScheme_fullname) || ': []'
            ,p_pretty_print + 1
            ,'  '
         );
         
      END IF;

/*
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml contact name
      --------------------------------------------------------------------------
      IF  self.scope_names IS NOT NULL
      AND self.scope_names.COUNT > 0
      THEN
         clb_output := clb_output || ': ';

         FOR i IN 1 .. self.scope_names.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '- ' || dz_swagger3_util.yaml_text(self.scope_names(i),p_pretty_print)
               ,p_pretty_print
               ,'  '
            );

         END LOOP;

      END IF;
*/
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
      
   END toYAML_req;
   
END;
/

