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
      ,p_versionid          IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Initialize the object
      --------------------------------------------------------------------------
      self.versionid         := p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Pull the object information
      --------------------------------------------------------------------------
      SELECT
       a.server_var_id
      ,a.server_var_name
      ,dz_swagger3_util.gz_split(a.server_var_enum,',')
      ,a.server_var_default
      ,a.server_var_description
      INTO
       self.server_var_id
      ,self.server_var_name
      ,self.enum
      ,self.default_value
      ,self.description
      FROM
      dz_swagger3_server_variable a
      WHERE
          a.server_var_id = p_server_var_id
      AND a.versionid     = p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Return the completed object
      --------------------------------------------------------------------------
      RETURN;

   END dz_swagger3_server_var_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN
      NULL;
      
   END traverse;

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
      IF self.enum IS NOT NULL 
      AND  self.enum.COUNT > 0
      THEN
         SELECT
         JSON_OBJECT(
             'enum'         VALUE (SELECT JSON_ARRAYAGG(column_value) FROM TABLE(self.enum))
            ,'default'      VALUE self.default_value
            ,'description'  VALUE self.description
            ABSENT ON NULL
            RETURNING CLOB
         )
         INTO clb_output
         FROM dual;
         
      ELSE
         SELECT
         JSON_OBJECT(
             'default'      VALUE self.default_value
            ,'description'  VALUE self.description
            ABSENT ON NULL
            RETURNING CLOB
         )
         INTO clb_output
         FROM dual;

      END IF;

      --------------------------------------------------------------------------
      -- Step 30
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
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      cb               CLOB;
      v2               VARCHAR2(32000);

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
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => 'enum: '
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );

         FOR i IN 1 .. self.enum.COUNT
         LOOP
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => '- ' || dz_swagger3_util.yamlq(self.enum(i))
               ,p_pretty_print => p_pretty_print + 1
               ,p_amount       => '  '
            );

         END LOOP;

      END IF;

      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional license url
      --------------------------------------------------------------------------
      IF self.default_value IS NOT NULL
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => 'default: ' || dz_swagger3_util.yaml_text(
                self.default_value
               ,p_pretty_print
             )
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );

      END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Write the optional license url
      --------------------------------------------------------------------------
      IF self.description IS NOT NULL
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => 'description: ' || dz_swagger3_util.yaml_text(
                self.description
               ,p_pretty_print
             )
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );

      END IF;

      --------------------------------------------------------------------------
      -- Step 50
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

