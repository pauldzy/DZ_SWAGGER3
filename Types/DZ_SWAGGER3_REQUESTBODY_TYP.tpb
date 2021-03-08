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
      IF  self.requestBody_content IS NOT NULL
      AND self.requestBody_content.COUNT > 0
      AND self.requestBody_content(1).object_subtype = 'emulated'
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
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output              CLOB;
      str_identifier          VARCHAR2(255 Char);
      clb_requestbody_content CLOB;
      
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
         
         SELECT
         JSON_OBJECT(
            '$ref' VALUE '#/components/requestBodies/' || dz_swagger3_util.utl_url_escape(
               str_identifier
            )
         )
         INTO clb_output
         FROM dual;
         
      ELSE         
      --------------------------------------------------------------------------
      -- Step 30
      -- Add requestbody content
      --------------------------------------------------------------------------
         IF  self.requestbody_content IS NOT NULL 
         AND self.requestbody_content.COUNT > 0
         THEN 
            SELECT
            JSON_OBJECTAGG(
               b.object_key VALUE a.mediatyp.toJSON(
                   p_force_inline   => p_force_inline
                  ,p_short_id       => p_short_id
               ) FORMAT JSON
               RETURNING CLOB
            )
            INTO clb_requestbody_content
            FROM
            dz_swagger3_xobjects a
            JOIN
            TABLE(self.requestbody_content) b
            ON
                a.object_type_id = b.object_type_id
            AND a.object_id      = b.object_id
            ORDER BY b.object_order; 

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Build the output object
      --------------------------------------------------------------------------
         SELECT
         JSON_OBJECT(
             'description'  VALUE self.requestbody_description
            ,'content'      VALUE clb_requestbody_content      FORMAT JSON
            ,'required'     VALUE CASE
               WHEN LOWER(self.requestbody_required) = 'true'
               THEN
                  'true'
               WHEN LOWER(self.requestbody_required) = 'false'
               THEN
                  'false'
               ELSE
                  NULL
               END FORMAT JSON
            ABSENT ON NULL
            RETURNING CLOB
         )
         INTO clb_output
         FROM dual;
 
      END IF;
      
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
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      cb               CLOB;
      v2               VARCHAR2(32000);
      
      ary_keys         dz_swagger3_string_vry;
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
         
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => '$ref: ' || dz_swagger3_util.yaml_text(
               '#/components/requestBodies/' || str_identifier
             )
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );
      
      ELSE
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml description
      --------------------------------------------------------------------------
         IF self.requestbody_description IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'description: ' || dz_swagger3_util.yaml_text(
                   self.requestbody_description
                  ,p_pretty_print
                )
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );
            
         END IF;

      --------------------------------------------------------------------------
      -- Step 30
      -- Write the yaml media content
      --------------------------------------------------------------------------
         IF  self.requestbody_content IS NOT NULL 
         AND self.requestbody_content.COUNT > 0
         THEN
            SELECT
             a.mediatyp.toYAML(
                p_pretty_print   => p_pretty_print + 2
               ,p_force_inline   => p_force_inline
               ,p_short_id       => p_short_id
             )
            ,b.object_key
            BULK COLLECT INTO 
             ary_clb
            ,ary_keys
            FROM
            dz_swagger3_xobjects a
            JOIN
            TABLE(self.requestbody_content) b
            ON
                a.object_type_id = b.object_type_id
            AND a.object_id      = b.object_id
            ORDER BY b.object_order; 
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'content:' 
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v => dz_swagger3_util.yamlq(ary_keys(i)) || ': '
                  ,p_pretty_print => p_pretty_print + 1
                  ,p_amount       => '  '
               );
               
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => ary_clb(i)
                  ,p_in_v => NULL
               );
            
            END LOOP;
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the yaml required boolean
      --------------------------------------------------------------------------
         IF self.requestbody_required IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'required: ' || LOWER(self.requestbody_required)
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );
            
         END IF;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Cough it out 
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

