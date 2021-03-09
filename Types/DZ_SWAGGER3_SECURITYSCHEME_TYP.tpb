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
          'type'             VALUE self.securityscheme_type
         ,'description'      VALUE self.securityscheme_description
         ,'name'             VALUE self.securityscheme_name
         ,'in'               VALUE self.securityscheme_in
         ,'scheme'           VALUE self.securityscheme_scheme
         ,'bearerFormat'     VALUE self.securityscheme_bearerFormat
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
                        self.oauth_flow_implicit.toJSON()
                     ELSE
                        NULL
                     END FORMAT JSON
                  ,'password'          VALUE CASE
                     WHEN self.oauth_flow_password IS NOT NULL
                     THEN
                        self.oauth_flow_password.toJSON()
                     ELSE
                        NULL
                     END FORMAT JSON
                  ,'clientCredentials' VALUE CASE
                     WHEN self.oauth_flow_clientCredentials IS NOT NULL
                     THEN
                        self.oauth_flow_clientCredentials.toJSON()
                     ELSE
                        NULL
                     END FORMAT JSON
                  ,'authorizationCode' VALUE CASE
                     WHEN self.oauth_flow_authorizationCode IS NOT NULL
                     THEN
                        self.oauth_flow_authorizationCode.toJSON()
                     ELSE
                        NULL
                     END FORMAT JSON
                  ABSENT ON NULL
                  RETURNING CLOB
               )
            ELSE
               NULL
            END
         ,'openIdConnectUrl' VALUE self.securityscheme_openIdConUrl 
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
               '[]'
            END FORMAT JSON
         RETURNING CLOB
      )
      INTO clb_output
      FROM dual;

      --------------------------------------------------------------------------
      -- Step 30
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON_req;
   
END;
/

