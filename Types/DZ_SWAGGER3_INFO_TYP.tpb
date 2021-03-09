CREATE OR REPLACE TYPE BODY dz_swagger3_info_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_info_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_info_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_info_typ(
       p_doc_id         IN  VARCHAR2
      ,p_versionid      IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
   BEGIN
   
      SELECT 
      dz_swagger3_info_typ(
         p_info_title          => a.info_title
        ,p_info_description    => a.info_description
        ,p_info_termsofservice => a.info_termsofservice
        ,p_info_contact        => dz_swagger3_info_contact_typ(
             p_contact_name  => a.info_contact_name
            ,p_contact_url   => a.info_contact_url
            ,p_contact_email => a.info_contact_email
         )
        ,p_info_license        => dz_swagger3_info_license_typ(
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
   
   END dz_swagger3_info_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_info_typ(
       p_info_title          IN  VARCHAR2
      ,p_info_description    IN  VARCHAR2
      ,p_info_termsofservice IN  VARCHAR2
      ,p_info_contact        IN  dz_swagger3_info_contact_typ
      ,p_info_license        IN  dz_swagger3_info_license_typ
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
      
   END dz_swagger3_info_typ;
   
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
      p_force_inline         IN  VARCHAR2  DEFAULT 'FALSE'
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
      -- Build the object
      --------------------------------------------------------------------------
      SELECT
      JSON_OBJECT(
          'title'          VALUE self.info_title
         ,'description'    VALUE self.info_description
         ,'termsOfService' VALUE self.info_termsOfService
         ,'contact'        VALUE CASE
            WHEN self.info_contact.isNULL() = 'FALSE'
            THEN
               self.info_contact.toJSON()
            ELSE
               NULL
            END FORMAT JSON
         ,'license'        VALUE CASE
            WHEN self.info_license.isNULL() = 'FALSE'
            THEN
               self.info_license.toJSON()
            ELSE
               NULL
            END FORMAT JSON
         ,'version'        VALUE self.info_version        
         ABSENT ON NULL
         RETURNING CLOB
      )
      INTO clb_output
      FROM dual; 
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toJSON;
   
END;
/

