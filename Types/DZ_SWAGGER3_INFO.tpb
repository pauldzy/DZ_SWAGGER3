CREATE OR REPLACE TYPE BODY dz_swagger3_info
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_info
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_info;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_info(
       p_doc_id         IN  VARCHAR2
      ,p_versionid      IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
   BEGIN
   
      SELECT 
      dz_swagger3_info(
         p_info_title          => a.info_title
        ,p_info_description    => a.info_description
        ,p_info_termsofservice => a.info_termsofservice
        ,p_info_contact        => dz_swagger3_info_contact(
             p_contact_name  => a.info_contact_name
            ,p_contact_url   => a.info_contact_url
            ,p_contact_email => a.info_contact_email
         )
        ,p_info_license        => dz_swagger3_info_license(
             p_license_name  => a.info_license_name
            ,p_license_url   => a.info_license_url
         )
        ,p_info_version        => a.info_version
      )
      INTO SELF
      FROM
      dz_swagger3_doc a
      WHERE
          a.versionid = p_versionid
      AND a.doc_id = p_doc_id;
      
      RETURN;
   
   END dz_swagger3_info;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_info(
       p_info_title          IN  VARCHAR2
      ,p_info_description    IN  VARCHAR2
      ,p_info_termsofservice IN  VARCHAR2
      ,p_info_contact        IN  dz_swagger3_info_contact
      ,p_info_license        IN  dz_swagger3_info_license
      ,p_info_version        IN  VARCHAR2
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.info_title          := p_info_title;
      self.info_description    := p_info_description;
      self.info_termsofservice := p_info_termsofservice;
      self.info_contact        := p_info_contact;
      self.info_license        := p_info_license;
      self.info_version        := p_info_version;
      
      RETURN; 
      
   END dz_swagger3_info;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION isNULL
   RETURN VARCHAR2
   AS
   BEGIN
   
      IF self.info_title IS NOT NULL
      THEN
         RETURN 'FALSE';
         
      ELSE
         RETURN 'TRUE';
         
      END IF;
   
   END isNULL;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_pad          VARCHAR(1 Char);
      
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
      -- Add name element
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          str_pad || dz_json_main.value2json(
             'title'
            ,self.info_title
            ,p_pretty_print + 1
         )
         ,p_pretty_print + 1
      );
      str_pad := ',';
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional description
      --------------------------------------------------------------------------
      IF self.info_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.value2json(
                'description'
               ,self.info_description
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional termsOfService
      --------------------------------------------------------------------------
      IF self.info_termsOfService IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.value2json(
                'termsOfService'
               ,self.info_termsOfService
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add optional contact object
      --------------------------------------------------------------------------
      IF self.info_contact.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.formatted2json(
                'contact'
               ,self.info_contact.toJSON(
                   p_pretty_print    => p_pretty_print + 1
                  ,p_force_inline    => p_force_inline
                )
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Add optional license object
      --------------------------------------------------------------------------
      IF self.info_license.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.formatted2json(
                'license'
               ,self.info_license.toJSON(
                   p_pretty_print   => p_pretty_print + 1
                  ,p_force_inline   => p_force_inline
                )
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Add optional version
      --------------------------------------------------------------------------
      IF self.info_version IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.value2json(
                'version'
               ,self.info_version
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';

      END IF;
 
      --------------------------------------------------------------------------
      -- Step 100
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 110
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
      -- Write the info title
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty_str(
          'title: ' || dz_swagger3_util.yaml_text(
             self.info_title
            ,p_pretty_print
         )
         ,p_pretty_print
         ,'  '
      );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional info description
      --------------------------------------------------------------------------
      IF self.info_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'description: ' || dz_swagger3_util.yaml_text(
                self.info_description
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the optional info termsOfService
      --------------------------------------------------------------------------
      IF self.info_termsOfService IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'termsOfService: ' || dz_swagger3_util.yaml_text(
                self.info_termsOfService
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the optional info contact object
      --------------------------------------------------------------------------
      IF self.info_contact.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'contact: ' 
            ,p_pretty_print
            ,'  '
         ) || self.info_contact.toYAML(
             p_pretty_print   => p_pretty_print + 1
            ,p_force_inline   => p_force_inline
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Write the optional info license object
      --------------------------------------------------------------------------
      IF self.info_license.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'license: '
            ,p_pretty_print
            ,'  '
         ) || self.info_license.toYAML(
             p_pretty_print   => p_pretty_print + 1
            ,p_force_inline   => p_force_inline
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Write the optional info version
      --------------------------------------------------------------------------
      IF self.info_version IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'version: ' || dz_swagger3_util.yaml_text(
                self.info_version
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

