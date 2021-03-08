CREATE OR REPLACE TYPE BODY dz_swagger3_extrdocs_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_extrdocs_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_extrdocs_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_extrdocs_typ(
       p_externaldoc_id          IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Initialize the object
      --------------------------------------------------------------------------
      self.versionid := p_versionid;

      --------------------------------------------------------------------------
      -- Step 20
      -- Pull the object information
      --------------------------------------------------------------------------
      BEGIN
         SELECT
          a.externaldoc_id
         ,a.externaldoc_description
         ,a.externaldoc_url
         INTO
          self.externaldoc_id
         ,self.externaldoc_description
         ,self.externaldoc_url
         FROM
         dz_swagger3_externaldoc a
         WHERE
             a.versionid      = p_versionid
         AND a.externaldoc_id = p_externaldoc_id;
      
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            self.externaldoc_url         := NULL;
            self.externaldoc_description := NULL;
            
         WHEN OTHERS
         THEN
            RAISE;
            
      END;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Return the completed object
      --------------------------------------------------------------------------
      RETURN; 
      
   END dz_swagger3_extrdocs_typ;

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
      SELECT
      JSON_OBJECT(
          'description'  VALUE self.externaldoc_description
         ,'url'          VALUE self.externaldoc_url         
         ABSENT ON NULL
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
      -- Write the yaml description
      --------------------------------------------------------------------------
      dz_swagger3_util.conc(
          p_c    => cb
         ,p_v    => v2
         ,p_in_c => NULL
         ,p_in_v => 'description: ' || dz_swagger3_util.yaml_text(
             self.externaldoc_description
            ,p_pretty_print
          )
         ,p_pretty_print => p_pretty_print
         ,p_amount       => '  '
      );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional license url
      --------------------------------------------------------------------------
      IF self.externaldoc_url IS NOT NULL
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => 'url: ' || dz_swagger3_util.yaml_text(
                self.externaldoc_url
               ,p_pretty_print
             )
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
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

