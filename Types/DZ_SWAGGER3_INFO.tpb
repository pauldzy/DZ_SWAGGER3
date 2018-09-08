CREATE OR REPLACE TYPE BODY dz_swagger3_info
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_info
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger_info;
   
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
         p_title          => a.info_title
        ,p_description    => a.info_description
        ,p_termsofservice => a.info_termsofservice
        ,p_contact        => dz_swagger3_info_contact(
             p_contact_name  => a.info_contact_name
            ,p_contact_url   => a.info_contact_url
            ,p_contact_email => a.info_contact_email
         )
        ,p_license        => dz_swagger3_info_license(
             p_license_name  => a.info_license_name
            ,p_license_url   => a.info_license_url
         )
        ,p_version        => a.info_version
      )
      INTO SELF
      FROM
      dz_swagger3_doc
      WHERE
          a.versionid = p_versionid
      AND a.doc_id = p_doc_id;
   
   END dz_swagger3_info;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_info(
       p_title          IN  VARCHAR2
      ,p_description    IN  VARCHAR2
      ,p_termsofservice IN  VARCHAR2
      ,p_contact        IN  dz_swagger3_info_contact
      ,p_license        IN  dz_swagger3_info_license
      ,p_version        IN  VARCHAR2
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.title          := p_title;
      self.description    := p_description;
      self.termsofservice := p_termsofservice;
      self.contact        := p_contact;
      self.license        := p_license;
      self.version        := p_version;
      
      RETURN; 
      
   END dz_swagger_info;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION isNULL
   RETURN VARCHAR2
   AS
   BEGIN
   
      IF self.title IS NOT NULL
      THEN
         RETURN 'FALSE';
         
      ELSE
         RETURN 'TRUE';
         
      END IF;
   
   END isNULL;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print     IN  NUMBER   DEFAULT NULL
   ) RETURN CLOB
   AS
      num_pretty_print NUMBER := p_pretty_print;
      clb_output       CLOB;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF num_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add name element
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          ' ' || dz_json_main.value2json(
             'title'
            ,self.title
            ,num_pretty_print + 1
         )
         ,num_pretty_print + 1
      );
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional description
      --------------------------------------------------------------------------
      IF self.description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             ',' || dz_json_main.value2json(
                'description'
               ,self.description
               ,num_pretty_print + 1
            )
            ,num_pretty_print + 1
         );

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional termsOfService
      --------------------------------------------------------------------------
      IF self.termsOfService IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             ',' || dz_json_main.value2json(
                'termsOfService'
               ,self.termsOfService
               ,num_pretty_print + 1
            )
            ,num_pretty_print + 1
         );

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add optional contact object
      --------------------------------------------------------------------------
      IF self.contact.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             ',' || dz_json_main.formatted2json(
                'contact'
               ,self.contact.toJSON(num_pretty_print + 1)
               ,num_pretty_print + 1
            )
            ,num_pretty_print + 1
         );

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Add optional license object
      --------------------------------------------------------------------------
      IF self.license.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             ',' || dz_json_main.formatted2json(
                'license'
               ,self.license.toJSON(num_pretty_print + 1)
               ,num_pretty_print + 1
            )
            ,num_pretty_print + 1
         );

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Add optional version
      --------------------------------------------------------------------------
      IF self.version IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             ',' || dz_json_main.value2json(
                'version'
               ,self.version
               ,num_pretty_print + 1
            )
            ,num_pretty_print + 1
         );

      END IF;
 
      --------------------------------------------------------------------------
      -- Step 100
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,num_pretty_print,NULL,NULL
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
      p_pretty_print      IN  NUMBER   DEFAULT 0
   ) RETURN CLOB
   AS
      clb_output        CLOB;
      num_pretty_print  NUMBER := p_pretty_print;
      
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
             self.title
            ,num_pretty_print
         )
         ,num_pretty_print
         ,'  '
      );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional info description
      --------------------------------------------------------------------------
      IF self.description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'description: ' || dz_swagger3_util.yaml_text(
                self.description
               ,num_pretty_print
            )
            ,num_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the optional info termsOfService
      --------------------------------------------------------------------------
      IF self.termsOfService IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'termsOfService: ' || dz_swagger3_util.yaml_text(
                self.termsOfService
               ,num_pretty_print
            )
            ,num_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the optional info contact object
      --------------------------------------------------------------------------
      IF self.contact.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'contact: ' 
            ,num_pretty_print
            ,'  '
         ) || self.contact.toYAML(
            num_pretty_print + 1
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Write the optional info license object
      --------------------------------------------------------------------------
      IF self.license.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'license: '
            ,num_pretty_print
            ,'  '
         ) || self.license.toYAML(
            num_pretty_print + 1
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Write the optional info version
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty_str(
          'version: ' || dz_swagger3_util.yaml_text(
             self.version
            ,num_pretty_print
         )
         ,num_pretty_print
         ,'  '
      );
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Cough it out without final line feed
      --------------------------------------------------------------------------
      RETURN clb_output;
      
   END toYAML;
   
END;
/

