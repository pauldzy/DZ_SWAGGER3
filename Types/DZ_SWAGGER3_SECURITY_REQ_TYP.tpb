CREATE OR REPLACE TYPE BODY dz_swagger3_security_req_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_security_req_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_security_req_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_security_req_typ(
       p_security_req_name  IN  VARCHAR2
      ,p_scope_names        IN  MDSYS.SDO_STRING2_ARRAY
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.security_req_name := p_security_req_name;
      self.scope_names       := p_scope_names;
      
      RETURN; 
      
   END dz_swagger3_security_req_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
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
         clb_output  := dz_json_util.pretty('[',NULL);
         
      ELSE
         clb_output  := dz_json_util.pretty('[',-1);
         str_pad     := ' ';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add name element
      --------------------------------------------------------------------------
      IF  self.scope_names IS NOT NULL
      AND self.scope_names.COUNT > 0
      THEN
         FOR i IN 1 .. self.scope_names.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                str_pad || dz_json_main.json_format(self.scope_names(i))
               ,p_pretty_print + 1
            );
            str_pad := ',';

         END LOOP;
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          ']'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 50
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
      clb_output        CLOB;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml contact name
      --------------------------------------------------------------------------
      IF  self.scope_names IS NOT NULL
      AND self.scope_names.COUNT > 0
      THEN
         clb_output := clb_output || ': ';

         FOR i IN 1 .. self.scope_names.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '- ' || dz_swagger3_util.yaml_text(self.scope_names(i),p_pretty_print)
               ,p_pretty_print
               ,'  '
            );

         END LOOP;

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

