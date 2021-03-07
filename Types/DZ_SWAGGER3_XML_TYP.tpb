CREATE OR REPLACE TYPE BODY dz_swagger3_xml_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_xml_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_xml_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_xml_typ(
       p_xml_name            IN  VARCHAR2 DEFAULT NULL
      ,p_xml_namespace       IN  VARCHAR2 DEFAULT NULL
      ,p_xml_prefix          IN  VARCHAR2 DEFAULT NULL
      ,p_xml_attribute       IN  VARCHAR2 DEFAULT NULL
      ,p_xml_wrapped         IN  VARCHAR2 DEFAULT NULL
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.xml_name         := p_xml_name;
      self.xml_namespace    := p_xml_namespace;
      self.xml_prefix       := p_xml_prefix;
      self.xml_attribute    := p_xml_attribute;
      self.xml_wrapped      := p_xml_wrapped;
      
      RETURN; 
      
   END dz_swagger3_xml_typ;
   
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
      SELECT
      JSON_OBJECT(
          'name'         VALUE self.xml_name        ABSENT ON NULL
         ,'namespace'    VALUE self.xml_namespace   ABSENT ON NULL
         ,'prefix'       VALUE self.xml_prefix      ABSENT ON NULL
         ,'attribute'    VALUE CASE
            WHEN self.xml_attribute = 'TRUE'
            THEN
               TRUE
            ELSE
               NULL
            END                                     ABSENT ON NULL
         ,'wrapped'      VALUE CASE
            WHEN self.xml_wrapped = 'TRUE'
            THEN
               TRUE
            ELSE
               NULL
            END                                     ABSENT ON NULL
      )
      INTO clb_output
      FROM dual;
      
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
      -- Write the optional name
      --------------------------------------------------------------------------
      IF self.xml_name IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'name: ' || dz_swagger3_util.yaml_text(
                self.xml_name
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional namespace
      --------------------------------------------------------------------------
      IF self.xml_namespace IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'namespace: ' || dz_swagger3_util.yaml_text(
                self.xml_namespace
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the optional prefix
      --------------------------------------------------------------------------
      IF self.xml_prefix IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'prefix: ' || dz_swagger3_util.yaml_text(
                self.xml_prefix
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the optional attribute boolean
      --------------------------------------------------------------------------
      IF self.xml_attribute = 'TRUE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'attribute: ' || dz_swagger3_util.yaml_text(
                TRUE
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Write the optional wrapped boolean
      --------------------------------------------------------------------------
      IF self.xml_wrapped = 'TRUE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'wrapped: ' || dz_swagger3_util.yaml_text(
                TRUE
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Cough it out 
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

