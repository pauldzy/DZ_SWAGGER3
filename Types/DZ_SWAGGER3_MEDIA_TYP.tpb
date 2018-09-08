CREATE OR REPLACE TYPE BODY dz_swagger3_media_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_media_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_media_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_media_typ(
       p_hash_key                IN  VARCHAR2
      ,p_requestbody_description IN  VARCHAR2
      ,p_requestbody_content     IN  dz_swagger3_media_list
      ,p_requestbody_required    IN  VARCHAR2
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.hash_key                := p_hash_key;
      self.requestbody_description := p_requestbody_description;
      self.requestbody_content     := p_requestbody_content;
      self.requestbody_required    := p_requestbody_required;
      
      RETURN; 
      
   END dz_swagger3_media_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION isNULL
   RETURN VARCHAR2
   AS
   BEGIN
   
      IF self.requestbody_description IS NOT NULL
      OR self.requestbody_content     IS NOT NULL
      OR self.requestbody_required    IS NOT NULL
      THEN
         RETURN 'FALSE';
         
      ELSE
         RETURN 'TRUE';
         
      END IF;
   
   END isNULL;
   
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
   MEMBER FUNCTION toJSON(
       p_pretty_print     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_temp         VARCHAR2(5 Char);
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
         str_pad     := '';
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional description
      --------------------------------------------------------------------------
      IF self.requestbody_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.value2json(
                'description'
               ,self.requestbody_description
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional description 
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          str_pad || dz_json_main.value2json(
             'content'
            ,self.requestbody_content
            ,p_pretty_print + 1
         )
         ,p_pretty_print + 1
      );
      str_pad := ',';
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional required
      --------------------------------------------------------------------------
      IF self.requestbody_required IS NOT NULL
      THEN
         IF LOWER(self.requestbody_required) = 'true'
         THEN
            str_temp := 'true';
            
         ELSE
            str_temp := 'false';
         
         END IF;
      
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.value2json(
                'required'
               ,str_temp
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';

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
      p_pretty_print      IN  INTEGER   DEFAULT 0
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_temp         VARCHAR2(5 Char);
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml description
      --------------------------------------------------------------------------
      IF self.requestbody_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'description: ' || dz_swagger_util.yaml_text(
                self.requestbody_description
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
      clb_output := clb_output || dz_json_util.pretty_str(
          'content: ' || dz_swagger_util.yaml_text(
             self.requestbody_content
            ,p_pretty_print
         )
         ,p_pretty_print
         ,'  '
      );
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the optional license url
      --------------------------------------------------------------------------
      IF self.requestbody_required IS NOT NULL
      THEN
         IF LOWER(self.requestbody_required) = 'true'
         THEN
            str_temp := 'true';
            
         ELSE
            str_temp := 'false';
         
         END IF;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'required: ' || dz_swagger_util.yaml_text(
                str_temp
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Cough it out 
      --------------------------------------------------------------------------
      RETURN clb_output;
      
   END toYAML;
   
END;
/

