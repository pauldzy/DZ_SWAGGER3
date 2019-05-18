CREATE OR REPLACE TYPE BODY dz_swagger3_tag_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_tag_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_tag_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_tag_typ(
       p_tag_id             IN  VARCHAR2
      ,p_versionid          IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
   
   BEGIN
   
      self.versionid := p_versionid;
   
      SELECT
       a.tag_id
      ,a.tag_name
      ,a.tag_description
      ,CASE
       WHEN a.tag_externaldocs_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id => a.tag_externaldocs_id
            ,p_object_type_id => 'extrdocstyp'
         )
       ELSE
         NULL
       END
      INTO 
       self.tag_id
      ,self.tag_name
      ,self.tag_description
      ,self.tag_externalDocs
      FROM
      dz_swagger3_tag a
      WHERE
      a.versionid = p_versionid
      AND a.tag_id = p_tag_id;
      
      RETURN;
   
   END dz_swagger3_tag_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_tag_typ(
       p_tag_id             IN  VARCHAR2
      ,p_tag_name           IN  VARCHAR2
      ,p_tag_description    IN  VARCHAR2
      ,p_tag_externalDocs   IN  dz_swagger3_object_typ --dz_swagger3_extrdocs_typ
      ,p_load_components    IN  VARCHAR2 DEFAULT 'TRUE'
      ,p_versionid          IN  VARCHAR2
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.tag_id            := p_tag_id;
      self.tag_name          := p_tag_name;
      self.tag_description   := p_tag_description;
      self.tag_externalDocs  := p_tag_externalDocs;
      self.versionid         := p_versionid;

      RETURN; 
      
   END dz_swagger3_tag_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Load the external docs
      --------------------------------------------------------------------------
      IF self.tag_externalDocs IS NOT NULL
      THEN
         dz_swagger3_loader.extrdocstyp(
             p_parent_id    => self.tag_id
            ,p_children_ids => dz_swagger3_object_vry(self.tag_externalDocs)
            ,p_versionid    => self.versionid
         );
      
      END IF;

   END traverse;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION isNULL
   RETURN VARCHAR2
   AS
   BEGIN
   
      IF self.tag_name IS NOT NULL
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
      clb_tmp          CLOB;
      
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
      -- Add mandatory name
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          str_pad || dz_json_main.value2json(
             'name'
            ,self.tag_name
            ,p_pretty_print + 1
         )
         ,p_pretty_print + 1
      );
      str_pad := ',';
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional description
      --------------------------------------------------------------------------
      IF self.tag_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.value2json(
                'description'
               ,self.tag_description
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional externalDocs
      --------------------------------------------------------------------------
      IF self.tag_externalDocs IS NOT NULL
      THEN
         BEGIN
            EXECUTE IMMEDIATE
               'SELECT '
            || 'a.extrdocs.toJSON( '
            || '   p_pretty_print   => :p01 + 1 '
            || '  ,p_force_inline   => :p02 '
            || ') FROM '
            || 'dz_swagger3_xobjects a '
            || 'WHERE '
            || '    a.object_type_id = :p03 '
            || 'AND a.object_id      = :p04 '
            INTO clb_tmp
            USING 
             p_pretty_print
            ,p_force_inline
            ,self.tag_externalDocs.object_type_id
            ,self.tag_externalDocs.object_id;
            
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_tmp := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.formatted2json(
                'externalDocs'
               ,clb_tmp
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
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output        CLOB;
      clb_tmp           CLOB;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the required name
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty_str(
          'name: ' || dz_swagger3_util.yaml_text(
             self.tag_name
            ,p_pretty_print
         )
         ,p_pretty_print
         ,'  '
      );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional description
      --------------------------------------------------------------------------
      IF self.tag_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'description: ' || dz_swagger3_util.yaml_text(
                self.tag_description
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional externalDocs object
      --------------------------------------------------------------------------
      IF self.tag_externalDocs IS NOT NULL
      THEN
         BEGIN
            EXECUTE IMMEDIATE
               'SELECT '
            || 'a.extrdocs.toYAML( '
            || '   p_pretty_print   => :p01 + 1 '
            || '  ,p_force_inline   => :p02 '
            || ') FROM '
            || 'dz_swagger3_xobjects a '
            || 'WHERE '
            || '    a.object_type_id = :p03 '
            || 'AND a.object_id      = :p04 '
            INTO clb_tmp
            USING 
             p_pretty_print
            ,p_force_inline
            ,self.tag_externalDocs.object_type_id
            ,self.tag_externalDocs.object_id;
           
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_tmp := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'externalDocs: ' 
            ,p_pretty_print
            ,'  '
         ) || clb_tmp;
         
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

