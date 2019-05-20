CREATE OR REPLACE TYPE BODY dz_swagger3_requestbody_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_requestbody_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_requestbody_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_requestbody_typ(
       p_requestbody_id          IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Initialize the object
      --------------------------------------------------------------------------
      self.versionid                  := p_versionid;

      --------------------------------------------------------------------------
      -- Step 20
      -- Pull the object information
      --------------------------------------------------------------------------
      SELECT
       a.requestBody_id
      ,a.requestBody_description
      ,a.requestBody_force_inline
      ,a.requestBody_required
      INTO
       self.requestBody_id
      ,self.requestBody_description
      ,self.requestBody_force_inline
      ,self.requestBody_required
      FROM
      dz_swagger3_requestbody a
      WHERE
          a.versionid      = p_versionid
      AND a.requestBody_id = p_requestBody_id;

      --------------------------------------------------------------------------
      -- Step 30
      -- Collect the media content
      -------------------------------------------------------------------------- 
      SELECT
      dz_swagger3_object_typ(
          p_object_id       => b.media_id
         ,p_object_type_id  => 'mediatyp'
         ,p_object_key      => a.media_type
         ,p_object_order    => a.media_order
      )
      BULK COLLECT INTO self.requestbody_content
      FROM
      dz_swagger3_parent_media_map a
      JOIN
      dz_swagger3_media b
      ON
          a.versionid  = b.versionid
      AND a.media_id   = b.media_id
      WHERE
          a.versionid = p_versionid
      AND a.parent_id = p_requestbody_id;

      --------------------------------------------------------------------------
      -- Step 40
      -- Return the completed object
      --------------------------------------------------------------------------   
      RETURN; 
   
   END dz_swagger3_requestbody_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_requestbody_typ(
       p_requestbody_id           IN  VARCHAR2
      ,p_parameters               IN  dz_swagger3_object_vry --dz_swagger3_parameter_list
      ,p_versionid                IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Initialize the object
      --------------------------------------------------------------------------
      self.versionid                  := p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Emulate the post object
      --------------------------------------------------------------------------
      self.requestBody_id             := p_requestbody_id;
      self.requestBody_force_inline   := 'TRUE';
      self.requestBody_emulated_parms := p_parameters;
      
      self.requestbody_content := dz_swagger3_object_vry(
         dz_swagger3_object_typ(
             p_object_id        => 'md.' || p_requestbody_id
            ,p_object_type_id   => 'mediatyp'
            ,p_object_subtype   => 'emulated'
            ,p_object_key       => 'application/x-www-form-urlencoded'
            ,p_object_attribute => 'TRUE'
         )
      );
 
      RETURN;
      
   END dz_swagger3_requestbody_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Load the media types
      --------------------------------------------------------------------------
      IF self.requestBody_content(1).object_subtype = 'emulated'
      THEN
         dz_swagger3_loader.mediatyp_emulated(
             p_parent_id      => self.requestBody_id
            ,p_children_ids   => self.requestBody_content
            ,p_parameter_ids  => self.requestBody_emulated_parms
            ,p_versionid      => self.versionid
         );
         
      ELSE
         dz_swagger3_loader.mediatyp(
             p_parent_id      => self.requestBody_id
            ,p_children_ids   => self.requestBody_content
            ,p_versionid      => self.versionid
         );
         
      END IF;
  
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
      boo_temp         BOOLEAN;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_hash         CLOB;
      str_identifier   VARCHAR2(255 Char);
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
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
               ,'#/components/requestBodies/' || dz_swagger3_util.utl_url_escape(
                  str_identifier
                ) 
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      ELSE      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional description
      --------------------------------------------------------------------------
         IF self.requestbody_description IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'description'
                  ,self.requestbody_description
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add media content
      --------------------------------------------------------------------------
         IF  self.requestbody_content IS NOT NULL 
         AND self.requestbody_content.COUNT > 0
         THEN 
            EXECUTE IMMEDIATE
               'SELECT '
            || ' a.mediatyp.toJSON( '
            || '    p_pretty_print   => :p01 + 2 '
            || '   ,p_force_inline   => :p02 '
            || '   ,p_short_id       => :p03 '
            || ' ) '
            || ',b.object_key '
            || 'FROM '
            || 'dz_swagger3_xobjects a '
            || 'JOIN '
            || 'TABLE(:p04) b '
            || 'ON '
            || '    a.object_type_id = b.object_type_id '
            || 'AND a.object_id      = b.object_id '
            || 'ORDER BY b.object_order '
            BULK COLLECT INTO 
             ary_clb
            ,ary_keys
            USING
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.requestbody_content; 
            
            str_pad2 := str_pad;
            
            IF p_pretty_print IS NULL
            THEN
               clb_hash := dz_json_util.pretty('{',NULL);
               
            ELSE
               clb_hash := dz_json_util.pretty('{',-1);
               
            END IF;
         
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_hash := clb_hash || dz_json_util.pretty(
                   str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                  ,p_pretty_print + 2
               );
               str_pad2 := ',';
            
            END LOOP;
            
            clb_hash := clb_hash || dz_json_util.pretty(
                '}'
               ,p_pretty_print + 1,NULL,NULL
            );
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                    'content'
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional required
      --------------------------------------------------------------------------
         IF self.requestbody_required IS NOT NULL
         THEN
            IF LOWER(self.requestbody_required) = 'true'
            THEN
               boo_temp := TRUE;
               
            ELSE
               boo_temp := FALSE;
            
            END IF;
         
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'required'
                  ,boo_temp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
 
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
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      str_identifier   VARCHAR2(255 Char);
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
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
                '#/components/requestBodies/' || p_identifier
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
      
      ELSE
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml description
      --------------------------------------------------------------------------
         IF self.requestbody_description IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'description: ' || dz_swagger3_util.yaml_text(
                   self.requestbody_description
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;

      --------------------------------------------------------------------------
      -- Step 30
      -- Write the yaml media content
      --------------------------------------------------------------------------
         IF  self.requestbody_content IS NOT NULL 
         AND self.requestbody_content.COUNT > 0
         THEN
            EXECUTE IMMEDIATE
               'SELECT '
            || ' a.mediatyp.toYAML( '
            || '    p_pretty_print   => :p01 + 3 '
            || '   ,p_force_inline   => :p02 '
            || '   ,p_short_id       => :p03 '
            || ' ) '
            || ',b.object_key '
            || 'FROM '
            || 'dz_swagger3_xobjects a '
            || 'JOIN '
            || 'TABLE(:p04) b '
            || 'ON '
            || '    a.object_type_id = b.object_type_id '
            || 'AND a.object_id      = b.object_id '
            || 'ORDER BY b.object_order '
            BULK COLLECT INTO 
             ary_clb
            ,ary_keys
            USING
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.requestbody_content; 
            
            clb_output := clb_output || dz_json_util.pretty_str(
                'content: '
               ,p_pretty_print + 1
               ,'  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   dz_swagger3_util.yamlq(ary_keys(i)) || ': '
                  ,p_pretty_print + 2
                  ,'  '
               ) || ary_clb(i);
            
            END LOOP;
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the yaml required boolean
      --------------------------------------------------------------------------
         IF self.requestbody_required IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'required: ' || LOWER(self.requestbody_required)
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
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

