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
      str_url         VARCHAR2(255 Char);
      str_description VARCHAR2(255 Char);
      ary_variables   dz_swagger3_server_var_list;
      
   BEGIN 
   
      SELECT
       a.server_url
      ,a.server_description
      INTO
       str_url
      ,str_description
      FROM
      dz_swagger3_server a
      WHERE
          a.versionid = p_versionid
      AND a.server_id = p_server_id;
      
      SELECT
      dz_swagger3_server_var_typ(
          p_hash_key       => a.server_var_name
         ,p_enum           => dz_json_util.gz_split(
             p_str            => a.server_var_enum
            ,p_regex          => ','
            ,p_trim           => 'TRUE'
          )
         ,p_default_value  => a.server_var_default
         ,p_description    => a.server_var_description
      )
      BULK COLLECT INTO ary_variables
      FROM
      dz_swagger3_server_variable a
      WHERE
          a.versionid = p_versionid
      AND a.server_id = p_server_id
      ORDER BY
      a.server_var_name;
      
      SELECT dz_swagger3_server_typ(
          p_server_url         => str_url
         ,p_server_description => str_description
         ,p_server_variables   => ary_variables
      )
      INTO SELF
      FROM dual;
      
      RETURN;
      
   END dz_swagger3_server_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_server_typ(
       p_server_url         IN  VARCHAR2
      ,p_server_description IN  VARCHAR2
      ,p_server_variables   IN  dz_swagger3_server_var_list
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
   MEMBER FUNCTION server_variables_keys
   RETURN MDSYS.SDO_STRING2_ARRAY
   AS
      int_index  PLS_INTEGER;
      ary_output MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
      IF self.server_variables IS NULL
      OR self.server_variables.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      int_index  := 1;
      ary_output := MDSYS.SDO_STRING2_ARRAY();
      FOR i IN 1 .. self.server_variables.COUNT
      LOOP
         ary_output.EXTEND();
         ary_output(int_index) := self.server_variables(i).hash_key;
         int_index := int_index + 1;
      
      END LOOP;
      
      RETURN ary_output;
   
   END server_variables_keys;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_hash         CLOB;
      
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
      IF self.server_variables IS NULL 
      OR self.server_variables.COUNT = 0
      THEN
         clb_hash := 'null';
         
      ELSE
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('{',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('{',-1);
            
         END IF;
      
      
         ary_keys := self.server_variables_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || ary_keys(i) || '":' || str_pad || self.server_variables(i).toJSON(
                  p_pretty_print => p_pretty_print + 2
                )
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
              'variables'
             ,clb_hash
             ,p_pretty_print + 1
          )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';

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
   ) RETURN CLOB
   AS
      clb_output        CLOB;
      ary_keys          MDSYS.SDO_STRING2_ARRAY;
      
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
      IF self.server_description IS NULL
      THEN
         NULL;
         
      ELSE
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
      IF  self.server_variables IS NULL 
      OR self.server_variables.COUNT = 0
      THEN
         NULL;
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'variables: '
            ,p_pretty_print
            ,'  '
         );
         
         ary_keys := self.server_variables_keys();
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '''' || ary_keys(i) || ''': '
               ,p_pretty_print + 1
               ,'  '
            ) || self.server_variables(i).toYAML(
               p_pretty_print + 2
            );
         
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
   
END;
/

