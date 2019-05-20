CREATE OR REPLACE TYPE BODY dz_swagger3_example_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_example_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_example_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_example_typ(
       p_example_id              IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS 
   BEGIN
   
      SELECT
       a.example_id
      ,a.example_summary
      ,a.example_description
      ,a.example_value_string
      ,a.example_value_number
      ,a.example_externalValue
      INTO
       self.example_id
      ,self.example_summary
      ,self.example_description
      ,self.example_value_string
      ,self.example_value_number
      ,self.example_externalValue
      FROM
      dz_swagger3_example a
      WHERE
          a.versionid = p_versionid
      AND a.example_id = p_example_id;
   
      RETURN; 
      
   END dz_swagger3_example_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN
      NULL;
      
   END traverse;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_identifier   VARCHAR2(255 Char);
      
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
      -- Step 20
      -- Add  the ref object
      --------------------------------------------------------------------------
      IF  COALESCE(p_force_inline,'FALSE') = 'FALSE'
      AND p_reference_count > 1
      THEN
         IF p_short_id = 'TRUE'
         THEN
            str_identifier := p_short_identifier;
            
         ELSE
            str_identifier := p_identifier;
            
         END IF;
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                '$ref'
               ,'#/components/examples/' || str_identifier
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
      
      ELSE
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional summary
      --------------------------------------------------------------------------
         IF self.example_summary IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'summary'
                  ,self.example_summary
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional description 
      --------------------------------------------------------------------------
         IF self.example_description IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'description'
                  ,self.example_description
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional value
      --------------------------------------------------------------------------
         IF self.example_value_string IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'value'
                  ,self.example_value_string
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         ELSIF self.example_value_number IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'value'
                  ,self.example_value_number
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add optional externalValue
      --------------------------------------------------------------------------
         IF self.example_externalValue IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'externalValue'
                  ,self.example_externalValue
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
 
      END IF;

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
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output        CLOB;
      str_identifier   VARCHAR2(255 Char);
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Add  the ref object
      --------------------------------------------------------------------------
      IF  COALESCE(p_force_inline,'FALSE') = 'FALSE'
      AND p_reference_count > 1
      THEN
         IF p_short_id = 'TRUE'
         THEN
            str_identifier := p_short_identifier;
            
         ELSE
            str_identifier := p_identifier;
            
         END IF;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             '$ref: ' || dz_swagger3_util.yaml_text(
                '#/components/examples/' || str_identifier
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
      
      ELSE
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml summary
      --------------------------------------------------------------------------
         IF self.example_summary IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'summary: ' || dz_swagger3_util.yaml_text(
                   self.example_summary
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional license url
      --------------------------------------------------------------------------
         IF self.example_description IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'description: ' || dz_swagger3_util.yaml_text(
                   self.example_description
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional value
      --------------------------------------------------------------------------
         IF self.example_value_string IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'value: ' || dz_swagger3_util.yaml_text(
                   self.example_value_string
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         ELSIF self.example_value_number IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'value: ' || dz_swagger3_util.yaml_text(
                   self.example_value_number
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional license url
      --------------------------------------------------------------------------
         IF self.example_externalValue IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'externalValue: ' || dz_swagger3_util.yaml_text(
                   self.example_externalValue
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
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

