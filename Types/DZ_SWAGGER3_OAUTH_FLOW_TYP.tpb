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
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      clb_hash         CLOB;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
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
      -- Step 30
      -- Add authorizationUrl
      --------------------------------------------------------------------------
      IF self.oauth_flow_authorizationUrl IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'authorizationUrl'
               ,self.oauth_flow_authorizationUrl
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Add tokenUrl
      --------------------------------------------------------------------------
      IF self.oauth_flow_tokenUrl IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'tokenUrl'
               ,self.oauth_flow_tokenUrl
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add refreshUrl
      --------------------------------------------------------------------------
      IF self.oauth_flow_refreshUrl IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'refreshUrl'
               ,self.oauth_flow_refreshUrl
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add optional parameter map
      --------------------------------------------------------------------------
      IF self.oauth_flow_scope_names IS NOT NULL
      AND self.oauth_flow_scope_names.COUNT > 0
      THEN
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('{',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('{',-1);
            
         END IF;
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || self.oauth_flow_scope_names(i) || '":' || str_pad || self.oauth_flow_scope_desc(i)
               ,p_pretty_print + 1
            );
            str_pad2 := ',';
         
         END LOOP;
         
         clb_hash := clb_hash || dz_json_util.pretty(
             '}'
            ,p_pretty_print + 1,NULL,NULL
         );
         
      END IF;
         
      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.formatted2json(
              'scopes'
             ,clb_hash
             ,p_pretty_print + 1
          )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';
         
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
   ) RETURN CLOB
   AS
      cb            CLOB;
      v2            VARCHAR2(32000);
      ary_keys      MDSYS.SDO_STRING2_ARRAY;
      
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
            ,p_in_v => dz_json_util.pretty_str(
                'authorizationUrl: ' || dz_swagger3_util.yaml_text(
                   self.oauth_flow_authorizationUrl
                  ,p_pretty_print
                )
               ,p_pretty_print
               ,'  '
             ) 
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
            ,p_in_v => dz_json_util.pretty_str(
                'tokenUrl: ' || dz_swagger3_util.yaml_text(
                   self.oauth_flow_tokenUrl
                  ,p_pretty_print
                )
               ,p_pretty_print
               ,'  '
             ) 
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
            ,p_in_v => dz_json_util.pretty_str(
                'refreshUrl: ' || dz_swagger3_util.yaml_text(
                   self.oauth_flow_refreshUrl
                  ,p_pretty_print
                )
               ,p_pretty_print
               ,'  '
             ) 
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
            ,p_in_v => dz_json_util.pretty_str(
                'scopes: '
               ,p_pretty_print
               ,'  '
             ) 
         );
         
         FOR i IN 1 .. self.oauth_flow_scope_names.COUNT
         LOOP
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => dz_json_util.pretty_str(
                   dz_swagger3_util.yamlq(self.oauth_flow_scope_names(i)) || ': ' || dz_swagger3_util.yamlq(self.oauth_flow_scope_desc(i))
                  ,p_pretty_print + 1
                  ,'  '
                ) 
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

