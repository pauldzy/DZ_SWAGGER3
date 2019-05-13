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
       p_oauth_authorizationUrl  IN  VARCHAR2
      ,p_oauth_tokenUrl          IN  VARCHAR2
      ,p_oauth_refreshUrl        IN  VARCHAR2
      ,p_oauth_scopes            IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_string_hash_list
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.oauth_authorizationUrl   := p_oauth_authorizationUrl;
      self.oauth_tokenUrl           := p_oauth_tokenUrl;
      self.oauth_refreshUrl         := p_oauth_refreshUrl;
      self.oauth_scopes             := p_oauth_scopes;      
      
      RETURN; 
      
   END dz_swagger3_oauth_flow_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION oauth_scopes_keys
   RETURN MDSYS.SDO_STRING2_ARRAY
   AS
      int_index  PLS_INTEGER;
      ary_output MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
      IF self.oauth_scopes IS NULL
      OR self.oauth_scopes.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
/*
      int_index  := 1;
      ary_output := MDSYS.SDO_STRING2_ARRAY();
      FOR i IN 1 .. self.oauth_scopes.COUNT
      LOOP
         ary_output.EXTEND();
         ary_output(int_index) := self.oauth_scopes(i).hash_key;
         int_index := int_index + 1;
      
      END LOOP;
*/
      RETURN ary_output;
   
   END oauth_scopes_keys;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
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
         str_pad     := '';
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;
      
      str_pad1 := str_pad;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add authorizationUrl
      --------------------------------------------------------------------------
      IF self.oauth_authorizationUrl IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'authorizationUrl'
               ,self.oauth_authorizationUrl
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
      IF self.oauth_tokenUrl IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'tokenUrl'
               ,self.oauth_tokenUrl
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
      IF self.oauth_refreshUrl IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'refreshUrl'
               ,self.oauth_refreshUrl
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
      IF self.oauth_scopes IS NOT NULL
      AND self.oauth_scopes.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.stringhashtyp.toJSON( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || ' ) '
         || ',a.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || 'a.object_id IN (SELECT column_name FROM TABLE(:p03)) '
         || 'ORDER BY a.ordering_key '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,self.oauth_scopes;
         
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
                str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
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
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
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
      -- Write yaml authorizationUrl
      --------------------------------------------------------------------------
      IF self.oauth_authorizationUrl IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'authorizationUrl: ' || dz_swagger3_util.yaml_text(
                self.oauth_authorizationUrl
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write yaml tokenUrl
      --------------------------------------------------------------------------
      IF self.oauth_authorizationUrl IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'tokenUrl: ' || dz_swagger3_util.yaml_text(
                self.oauth_tokenUrl
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write yaml refreshUrl
      --------------------------------------------------------------------------
      IF self.oauth_authorizationUrl IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'refreshUrl: ' || dz_swagger3_util.yaml_text(
                self.oauth_refreshUrl
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write flows authorizationCode
      --------------------------------------------------------------------------
      IF  self.oauth_scopes IS NOT NULL 
      AND self.oauth_scopes.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.stringhashtyp.toYAML( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || ' ) '
         || ',a.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || 'a.object_id IN (SELECT column_name FROM TABLE(:p03)) '
         || 'ORDER BY a.ordering_key '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,self.oauth_scopes;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'scopes: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '''' || ary_keys(i) || ''': '
               ,p_pretty_print + 1
               ,'  '
            ) || ary_clb(i);
         
         END LOOP;
         
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
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   STATIC PROCEDURE loader(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  MDSYS.SDO_STRING2_ARRAY
      ,p_versionid           IN  VARCHAR2
   )
   AS
   BEGIN
   
      INSERT INTO dz_swagger3_xrelates(
          parent_object_id
         ,child_object_id
         ,child_object_type_id
      )
      SELECT
       p_parent_id
      ,a.column_value
      ,'extrdocs'
      FROM
      TABLE(p_children_ids) a;

      EXECUTE IMMEDIATE 
      'INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,extrdocstyp
          ,ordering_key
      )
      SELECT
       a.column_value
      ,''extrdocstyp''
      ,dz_swagger3_extrdocs_typ(
          p_externaldoc_id => a.column_value
         ,p_versionid      => :p01
       )
      ,10
      FROM 
      TABLE(:p02) a'
      USING p_versionid,p_children_ids;
      
      COMMIT;

   END;
   
END;
/

