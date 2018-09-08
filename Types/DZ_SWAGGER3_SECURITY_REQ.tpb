CREATE OR REPLACE TYPE BODY dz_swagger3_security_req
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_security_req
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_security_req;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_security_req(
       p_hash_key           IN  VARCHAR2
      ,p_scope_names        IN  MDSYS.SDO_STRING2_ARRAY
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.hash_key        := p_hash_key;
      self.scope_names     := p_scope_names;
      
      RETURN; 
      
   END dz_swagger3_security_req;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION key
   RETURN VARCHAR2
   AS
   BEGIN
      RETURN self.hash_key;

   END key;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION isNULL
   RETURN VARCHAR2
   AS
   BEGIN
   
      IF self.hash_key IS NOT NULL
      THEN
         RETURN 'FALSE';
         
      ELSE
         RETURN 'TRUE';
         
      END IF;
   
   END isNULL;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print     IN  INTEGER   DEFAULT NULL
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
         str_pad     := '';
         
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
                str_pad || json_format(self.scope_names(i))
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
      p_pretty_print      IN  INTEGER   DEFAULT 0
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
      RETURN clb_output;
      
   END toYAML;
   
END;
/

