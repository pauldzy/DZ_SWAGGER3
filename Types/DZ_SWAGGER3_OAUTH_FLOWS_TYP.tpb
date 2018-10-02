CREATE OR REPLACE TYPE BODY dz_swagger3_oauth_flows_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_oauth_flows_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_oauth_flows_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_oauth_flows_typ(
       p_flows_implicit          IN  dz_swagger3_oauth_flow_typ
      ,p_flows_password          IN  dz_swagger3_oauth_flow_typ
      ,p_flows_clientCredentials IN  dz_swagger3_oauth_flow_typ
      ,p_flows_authorizationCode IN  dz_swagger3_oauth_flow_typ
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.flows_implicit          := p_flows_implicit;
      self.flows_password          := p_flows_password;
      self.flows_clientCredentials := p_flows_clientCredentials;
      self.flows_authorizationCode := p_flows_authorizationCode;      
      
      RETURN; 
      
   END dz_swagger3_oauth_flows_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
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
      -- Add implicit flow
      --------------------------------------------------------------------------
      IF self.flows_implicit IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'implicit'
               ,self.flows_implicit.toJSON(
                   p_pretty_print   => p_pretty_print + 1
                  ,p_force_inline   => p_force_inline 
                )
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Add password flow
      --------------------------------------------------------------------------
      IF self.flows_password IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'password'
               ,self.flows_password.toJSON(
                   p_pretty_print   => p_pretty_print + 1
                  ,p_force_inline   => p_force_inline 
                )
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add clientCredentials flow
      --------------------------------------------------------------------------
      IF self.flows_clientCredentials IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'clientCredentials'
               ,self.flows_clientCredentials.toJSON(
                   p_pretty_print   => p_pretty_print + 1
                  ,p_force_inline   => p_force_inline 
                )
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add authorizationCode flow
      --------------------------------------------------------------------------
      IF self.flows_authorizationCode IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'authorizationCode'
               ,self.flows_authorizationCode.toJSON(
                   p_pretty_print   => p_pretty_print + 1
                  ,p_force_inline   => p_force_inline 
                )
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

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
      clb_output        CLOB;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write flows implicit
      --------------------------------------------------------------------------
      IF self.flows_implicit IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'implicit: '
            ,p_pretty_print
            ,'  '
         ) || self.flows_implicit.toYAML(
             p_pretty_print   => p_pretty_print + 1
            ,p_force_inline   => p_force_inline 
         );  
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write flows password
      --------------------------------------------------------------------------
      IF self.flows_password IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'password: '
            ,p_pretty_print
            ,'  '
         ) || self.flows_password.toYAML(
             p_pretty_print   => p_pretty_print + 1
            ,p_force_inline   => p_force_inline 
         );  
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write flows clientCredentials
      --------------------------------------------------------------------------
      IF self.flows_clientCredentials IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'clientCredentials: '
            ,p_pretty_print
            ,'  '
         ) || self.flows_clientCredentials.toYAML(
             p_pretty_print   => p_pretty_print + 1
            ,p_force_inline   => p_force_inline 
         );  
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write flows authorizationCode
      --------------------------------------------------------------------------
      IF self.flows_authorizationCode IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'authorizationCode: '
            ,p_pretty_print
            ,'  '
         ) || self.flows_authorizationCode.toYAML(
             p_pretty_print   => p_pretty_print + 1
            ,p_force_inline   => p_force_inline 
         );  
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
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

