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
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
   BEGIN
      SELECT
       a.securityscheme_id
      ,a.securityscheme_type
      ,a.securityscheme_description
      ,a.securityscheme_name
      ,a.securityscheme_in
      ,a.securityscheme_bearerFormat
      INTO
       self.securityscheme_id
      ,self.securityscheme_type
      ,self.securityscheme_description
      ,self.securityscheme_name
      ,self.securityscheme_in
      ,self.securityscheme_bearerFormat
      FROM
      dz_swagger3_securityScheme a
      WHERE
          a.versionid         = p_versionid
      AND a.securityscheme_id = p_securityscheme_id;

      RETURN; 
      
   END dz_swagger3_securityScheme_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_identifier   VARCHAR2(255 Char);
      
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
      -- Step 20
      -- Add  the ref object
      --------------------------------------------------------------------------
      IF  COALESCE(p_force_inline,'FALSE') = 'FALSE'
      AND p_reference_count > 1
      THEN
         IF p_short_id = 'TRUE'
         THEN
            str_identifier := p_short_identifier;
            
         ELSE
            str_identifier := p_identifier;
            
         END IF;
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                '$ref'
               ,'#/components/securitySchemes/' || str_identifier
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
      
      ELSE
      --------------------------------------------------------------------------
      -- Step 30
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
      -- Step 40
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
      -- Step 50
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
      -- Step 60
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
      -- Step 70
      -- Add scheme auth
      --------------------------------------------------------------------------
         IF self.securityscheme_auth IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'auth'
                  ,self.securityscheme_auth
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
      -- Step 90
      -- Add flows object
      --------------------------------------------------------------------------
         IF  self.securityscheme_flows IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                   'flows'
                  ,self.securityscheme_flows.toJSON(
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
      -- Step 100
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
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_identifier   VARCHAR2(255 Char);
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      IF  COALESCE(p_force_inline,'FALSE') = 'FALSE'
      AND p_reference_count > 1
      THEN
         IF p_short_id = 'TRUE'
         THEN
            str_identifier := p_short_identifier;
            
         ELSE
            str_identifier := p_identifier;
            
         END IF;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             '$ref: ' || dz_swagger3_util.yaml_text(
                '#/components/securitySchemes/' || str_identifier
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      ELSE
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml scheme type
      --------------------------------------------------------------------------
         IF self.securityscheme_type IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'type: ' || dz_swagger3_util.yaml_text(
                   self.securityscheme_type
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
         IF self.securityscheme_description IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'description: ' || dz_swagger3_util.yaml_text(
                   self.securityscheme_description
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
         IF self.securityscheme_name IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'name: ' || dz_swagger3_util.yaml_text(
                   self.securityscheme_name
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
         IF self.securityscheme_in IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'in: ' || dz_swagger3_util.yaml_text(
                   self.securityscheme_in
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
         IF self.securityscheme_auth IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'scheme: ' || dz_swagger3_util.yaml_text(
                   self.securityscheme_auth
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
         IF self.securityscheme_bearerFormat IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'bearerFormat: ' || dz_swagger3_util.yaml_text(
                   self.securityscheme_bearerFormat
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
         IF self.securityscheme_flows IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'flows: '
               ,p_pretty_print
               ,'  '
            ) || self.securityscheme_flows.toYAML(
                p_pretty_print   => p_pretty_print + 1
               ,p_force_inline   => p_force_inline
            );  
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Write the yaml scheme in
      --------------------------------------------------------------------------
         IF self.securityscheme_openIdConUrl IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'openIdConnectUrl: ' || dz_swagger3_util.yaml_text(
                   self.securityscheme_openIdConUrl
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
         
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

