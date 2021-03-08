CREATE OR REPLACE TYPE BODY dz_swagger3_oauth_flow_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_oauth_flow_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_oauth_flow_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_oauth_flow_typ(
       p_oauth_flow_id           IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.versionid := p_versionid;
      
      SELECT
       a.oauth_flow_id
      ,a.oauth_flow_authorizationUrl
      ,a.oauth_flow_tokenUrl 
      ,a.oauth_flow_refreshUrl
      INTO
       self.oauth_flow_id
      ,self.oauth_flow_authorizationUrl
      ,self.oauth_flow_tokenUrl
      ,self.oauth_flow_refreshUrl
      FROM
      dz_swagger3_oauth_flow a
      WHERE
          a.versionid     = p_versionid
      AND a.oauth_flow_id = p_oauth_flow_id;
      
      SELECT
       a.oauth_flow_scope_name 
      ,a.oauth_flow_scope_desc
      BULK COLLECT INTO
       self.oauth_flow_scope_names
      ,self.oauth_flow_scope_desc
      FROM
      dz_swagger3_oauth_flow_scope a
      WHERE
          a.versionid     = p_versionid
      AND a.oauth_flow_id = p_oauth_flow_id;
      
      RETURN; 
      
   END dz_swagger3_oauth_flow_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON
   RETURN CLOB
   AS
      clb_output       CLOB;
      clob_scopes      CLOB;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Generate optional scope map
      --------------------------------------------------------------------------
      IF  self.oauth_flow_scope_names IS NOT NULL
      AND self.oauth_flow_scope_names.COUNT > 0
      THEN
         SELECT
         JSON_OBJECTAGG(
            a.scopename VALUE b.scopedesc
            RETURNING CLOB
         )
         INTO clob_scopes
         FROM (
            SELECT
             rownum       AS namerowid
            ,column_value AS scopename
            FROM
            TABLE(self.oauth_flow_scope_names)
         ) a
         JOIN (
            SELECT
             rownum       AS descrowid
            ,column_value AS scopedesc
            FROM
            TABLE(self.oauth_flow_scope_desc)
         ) b
         ON
         a.namerowid = b.descrowid;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Build the object
      --------------------------------------------------------------------------
      SELECT
      JSON_OBJECT(
          'authorizationUrl' VALUE self.oauth_flow_authorizationUrl
         ,'tokenUrl'         VALUE self.oauth_flow_tokenUrl
         ,'refreshUrl'       VALUE self.oauth_flow_refreshUrl
         ,'scopes'           VALUE clob_scopes                      FORMAT JSON 
         ABSENT ON NULL
         RETURNING CLOB
      )
      INTO clb_output
      FROM dual;
      
      --------------------------------------------------------------------------
      -- Step 40
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
      cb            CLOB;
      v2            VARCHAR2(32000);
      ary_keys      dz_swagger3_string_vry;
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb       clob_table;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write yaml authorizationUrl
      --------------------------------------------------------------------------
      IF self.oauth_flow_authorizationUrl IS NOT NULL
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => 'authorizationUrl: ' || dz_swagger3_util.yaml_text(
                self.oauth_flow_authorizationUrl
               ,p_pretty_print
             )
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write yaml tokenUrl
      --------------------------------------------------------------------------
      IF self.oauth_flow_tokenUrl IS NOT NULL
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => 'tokenUrl: ' || dz_swagger3_util.yaml_text(
                self.oauth_flow_tokenUrl
               ,p_pretty_print
             )
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write yaml refreshUrl
      --------------------------------------------------------------------------
      IF self.oauth_flow_refreshUrl IS NOT NULL
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => 'refreshUrl: ' || dz_swagger3_util.yaml_text(
                self.oauth_flow_refreshUrl
               ,p_pretty_print
             )
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write flows authorizationCode
      --------------------------------------------------------------------------
      IF  self.oauth_flow_scope_names IS NOT NULL 
      AND self.oauth_flow_scope_names.COUNT > 0
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => 'scopes: '
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );
         
         FOR i IN 1 .. self.oauth_flow_scope_names.COUNT
         LOOP
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_swagger3_util.yamlq(self.oauth_flow_scope_names(i)) 
                  || ': ' || dz_swagger3_util.yamlq(self.oauth_flow_scope_desc(i))
               ,p_pretty_print => p_pretty_print + 1
               ,p_amount       => '  '
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
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
   
END;
/

