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
   MEMBER FUNCTION toJSON
   RETURN CLOB
   AS
      clb_output       CLOB;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the object
      --------------------------------------------------------------------------
      SELECT
      JSON_OBJECT(
          'type'             VALUE self.securityscheme_type         ABSENT ON NULL
         ,'description'      VALUE self.securityscheme_description  ABSENT ON NULL
         ,'name'             VALUE self.securityscheme_name         ABSENT ON NULL
         ,'in'               VALUE self.securityscheme_in           ABSENT ON NULL
         ,'scheme'           VALUE self.securityscheme_scheme       ABSENT ON NULL
         ,'bearerFormat'     VALUE self.securityscheme_bearerFormat ABSENT ON NULL
         ,'flows'            VALUE CASE
            WHEN self.oauth_flow_implicit IS NOT NULL
            OR   self.oauth_flow_password IS NOT NULL
            OR   self.oauth_flow_clientCredentials IS NOT NULL
            OR   self.oauth_flow_authorizationCode IS NOT NULL
            THEN
               JSON_OBJECT(
                   'implicit'          VALUE CASE
                     WHEN self.oauth_flow_implicit IS NOT NULL
                     THEN
                        self.oauth_flow_implicit.toJSON() FORMAT JSON
                     ELSE
                        NULL
                     END                                        ABSENT ON NULL
                  ,'password'          VALUE CASE
                     WHEN self.oauth_flow_password IS NOT NULL
                     THEN
                        self.oauth_flow_password.toJSON() FORMAT JSON
                     ELSE
                        NULL
                     END                                        ABSENT ON NULL
                  ,'clientCredentials' VALUE CASE
                     WHEN self.oauth_flow_clientCredentials IS NOT NULL
                     THEN
                        self.oauth_flow_clientCredentials.toJSON() FORMAT JSON
                     ELSE
                        NULL
                     END                                        ABSENT ON NULL
                  ,'authorizationCode' VALUE CASE
                     WHEN self.oauth_flow_authorizationCode IS NOT NULL
                     THEN
                        self.oauth_flow_authorizationCode.toJSON() FORMAT JSON
                     ELSE
                        NULL
                     END                                        ABSENT ON NULL
               )
            ELSE
               NULL
            END                                                 ABSENT ON NULL
         ,'openIdConnectUrl' VALUE self.securityscheme_openIdConUrl ABSENT ON NULL
      )
      INTO clb_output
      FROM dual;

      --------------------------------------------------------------------------
      -- Step 80
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON_req(
      p_oauth_scope_flows        IN  VARCHAR2  DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output    CLOB;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the object
      --------------------------------------------------------------------------
      SELECT
      JSON_OBJECT(
          self.securityScheme_fullname VALUE CASE
            WHEN self.securityScheme_type IN ('oauth2','openIdConnect')
            AND p_oauth_scope_flows IS NOT NULL
            THEN
               (
                  SELECT 
                  JSON_ARRAYAGG(column_value) 
                  FROM 
                  TABLE(dz_swagger3_util.gz_split(p_oauth_scope_flows,','))
               )
            ELSE
               '[]' FORMAT JSON
            END
      )
      INTO clb_output
      FROM dual;

      --------------------------------------------------------------------------
      -- Step 30
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
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
      ary_oauth     dz_swagger3_string_vry;
      
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

