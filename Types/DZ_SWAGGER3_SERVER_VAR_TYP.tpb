CREATE OR REPLACE TYPE BODY dz_swagger3_server_var_typ
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_server_var_typ
   RETURN SELF AS RESULT
   AS
   BEGIN
      RETURN;

   END dz_swagger3_server_var_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_server_var_typ(
       p_server_var_id      IN  VARCHAR2
      ,p_enum               IN  MDSYS.SDO_STRING2_ARRAY
      ,p_default_value      IN  VARCHAR2
      ,p_description        IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
   BEGIN

      self.server_var_id     := p_server_var_id;
      self.enum              := p_enum;
      self.default_value     := p_default_value;
      self.description       := p_description;

      RETURN;

   END dz_swagger3_server_var_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION key
   RETURN VARCHAR2
   AS
   BEGIN
      RETURN self.server_var_id;

   END key;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION isNULL
   RETURN VARCHAR2
   AS
   BEGIN

      IF self.server_var_id IS NOT NULL
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
      -- Add elem element
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          str_pad || dz_json_main.value2json(
             'enum'
            ,self.enum
            ,p_pretty_print + 1
         )
         ,p_pretty_print + 1
      );
      str_pad := ',';

      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional default
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          str_pad || dz_json_main.value2json(
             'default'
            ,self.default_value
            ,p_pretty_print + 1
         )
         ,p_pretty_print + 1
      );
      str_pad := ',';

      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional description
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          str_pad || dz_json_main.value2json(
             'description'
            ,self.description
            ,p_pretty_print + 1
         )
         ,p_pretty_print + 1
      );
      str_pad := ',';

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

   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------

      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml license name
      --------------------------------------------------------------------------
      IF  self.enum IS NOT NULL
      AND self.enum.COUNT > 0
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'enum: '
            ,p_pretty_print
            ,'  '
         );

         FOR i IN 1 .. self.enum.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '- ' || dz_swagger3_util.yaml_text(self.enum(i),p_pretty_print)
               ,p_pretty_print + 1
               ,'  '
            );

         END LOOP;

      END IF;

      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional license url
      --------------------------------------------------------------------------
      IF self.default_value IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'default: ' || dz_swagger3_util.yaml_text(
                self.default_value
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );

      END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Write the optional license url
      --------------------------------------------------------------------------
      IF self.description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'description: ' || dz_swagger3_util.yaml_text(
                self.description
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );

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
      ,'servervartyp'
      FROM
      TABLE(p_children_ids) a;

      EXECUTE IMMEDIATE 
      'INSERT 
      INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,object_key
          ,servertyp
          ,ordering_key
      )
      SELECT
       a.column_value
      ,''servervartyp''
      ,a.column_value
      ,dz_swagger3_server_var_typ(
          p_server_var_id  => a.column_value
         ,p_versionid      => :p01
       )
      ,rownum * 10
      FROM 
      TABLE(:p02) a 
      WHERE
      a.column_value NOT IN (
         SELECT b.object_id FROM dz_swagger3_xobjects b
         WHERE b.object_type_id = ''servervartyp''
      )  
      AND a.column_value IS NOT NULL '
      USING p_versionid,p_children_ids;

   END;

END;
/

