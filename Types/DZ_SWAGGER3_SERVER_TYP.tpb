CREATE OR REPLACE TYPE BODY dz_swagger3_server_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_server_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_server_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_server_typ(
       p_server_id           IN  VARCHAR2
      ,p_versionid           IN  VARCHAR2 DEFAULT NULL
   ) RETURN SELF AS RESULT
   AS 
   BEGIN 

      SELECT
       a.server_url
      ,a.server_description
      INTO
       self.server_url
      ,self.server_description
      FROM
      dz_swagger3_server a
      WHERE
          a.versionid = p_versionid
      AND a.server_id = p_server_id;

      SELECT
      a.server_var_name
      BULK COLLECT INTO self.server_variables
      FROM
      dz_swagger3_server_variable a
      WHERE
          a.versionid = p_versionid
      AND a.server_id = p_server_id
      ORDER BY
       a.server_var_order
      ,a.server_var_name;
      
      IF self.server_variables.COUNT > 0
      THEN
         dz_swagger3_server_var_typ.loader(
             p_parent_id    => 'server'
            ,p_children_ids => self.server_variables
            ,p_versionid    => p_versionid
         );

      END IF;
  
      RETURN;
      
   END dz_swagger3_server_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_server_typ(
       p_server_url         IN  VARCHAR2
      ,p_server_description IN  VARCHAR2
      ,p_server_variables   IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_server_var_list
   ) RETURN SELF AS RESULT 
   AS
   BEGIN 
   
      self.server_url         := p_server_url;
      self.server_description := p_server_description;
      self.server_variables   := p_server_variables;
      
      RETURN; 
      
   END dz_swagger3_server_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION isNULL
   RETURN VARCHAR2
   AS
   BEGIN
   
      IF self.server_url IS NOT NULL
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
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_hash         CLOB;
      
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
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add name element
      --------------------------------------------------------------------------
      str_pad1 := str_pad;
      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.value2json(
             'url'
            ,self.server_url
            ,p_pretty_print + 1
         )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional url 
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.value2json(
             'description'
            ,self.server_description
            ,p_pretty_print + 1
         )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional variables map
      --------------------------------------------------------------------------
      IF  self.server_variables IS NOT NULL 
      AND self.server_variables.COUNT > 0
      THEN
         EXECUTE IMMEDIATE 
            'SELECT '
         || ' a.servervartyp.toJSON( '
         || '   p_pretty_print  => :p01 + 2 '
         || '  ,p_force_inline  => :p02 '
         || ' ) '
         || ',a.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''servervartyp'' '
         || 'AND a.object_id IN (SELECT * FROM TABLE(:p03)) '
         || 'ORDER BY a.ordering_key '
         BULK COLLECT INTO
          ary_clb
         ,ary_keys
         USING 
          p_pretty_print
         ,p_force_inline
         ,self.server_variables;   
      
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
                str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_keys(i)
               ,p_pretty_print + 2
            );
            str_pad2 := ',';
         
         END LOOP;
         
         clb_hash := clb_hash || dz_json_util.pretty(
             '}'
            ,p_pretty_print + 1,NULL,NULL
         );
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                 'variables'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 70
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
      ary_keys          MDSYS.SDO_STRING2_ARRAY;
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the url item, note the dumn handling if object array
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty_str(
          'url: ' || dz_swagger3_util.yaml_text(
             self.server_url
            ,p_pretty_print
         )
         ,p_pretty_print
         ,'  '
      );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional description item
      --------------------------------------------------------------------------
      IF self.server_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'description: ' || dz_swagger3_util.yaml_text(
                self.server_description
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the optional variables map
      --------------------------------------------------------------------------
      IF  self.server_variables IS NOT NULL 
      AND self.server_variables.COUNT > 0
      THEN
         EXECUTE IMMEDIATE 
            'SELECT '
         || ' a.servervartyp.toYAML( '
         || '   p_pretty_print  => :p01 + 2 '
         || '  ,p_force_inline  => :p02 '
         || ' ) '
         || ',a.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || 'a.object_id IN (SELECT * FROM TABLE(:p03))'
         BULK COLLECT INTO
          ary_clb
         ,ary_keys
         USING 
          p_pretty_print
         ,p_force_inline
         ,self.server_variables; 
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'variables: '
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
      -- Step 50
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
      ,'servertyp'
      FROM
      TABLE(p_children_ids) a;

      EXECUTE IMMEDIATE 
      'INSERT 
      INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,servertyp
          ,ordering_key
      )
      SELECT
       a.column_value
      ,''servertyp''
      ,dz_swagger3_server_typ(
          p_server_id   => a.column_value
         ,p_versionid   => :p01
       )
      ,rownum * 10
      FROM 
      TABLE(:p02) a 
      WHERE
      a.column_value NOT IN (
         SELECT b.object_id FROM dz_swagger3_xobjects b
         WHERE b.object_type_id = ''servertyp''
      )  
      AND a.column_value IS NOT NULL '
      USING p_versionid,p_children_ids;

   END;
   
END;
/

