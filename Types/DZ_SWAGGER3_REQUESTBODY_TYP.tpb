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
      ,p_load_components         IN  VARCHAR2 DEFAULT 'TRUE'
      ,p_ref_brake               IN  VARCHAR2 DEFAULT 'FALSE'
   ) RETURN SELF AS RESULT
   AS
   BEGIN
   /*
      --------------------------------------------------------------------------
      -- Step 10
      -- Pull the object information
      -------------------------------------------------------------------------- 
      BEGIN
         SELECT
         dz_swagger3_requestbody_typ(
             p_hash_key                 => p_requestbody_id
            ,p_requestbody_id           => p_requestbody_id
            ,p_requestbody_description  => a.requestbody_description
            ,p_requestBody_force_inline => a.requestBody_force_inline
            ,p_requestbody_content      => NULL
            ,p_requestbody_required     => a.requestbody_required
            ,p_load_components          => p_load_components
         )
         INTO SELF
         FROM
         dz_swagger3_requestbody a
         WHERE
             a.versionid      = p_versionid
         AND a.requestbody_id = p_requestbody_id;
         
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN;
            
         WHEN OTHERS
         THEN
            RAISE;
            
      END;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Collect the media content
      -------------------------------------------------------------------------- 
      SELECT
      dz_swagger3_media_typ(
          p_media_id              => b.media_id
         ,p_media_type            => a.media_type
         ,p_versionid             => p_versionid
         ,p_ref_brake             => p_ref_brake
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
      */
      --------------------------------------------------------------------------
      -- Step 
      -- Return the completed object
      --------------------------------------------------------------------------   
      RETURN; 
   
   END dz_swagger3_requestbody_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_requestbody_typ(
       p_requestbody_id           IN  VARCHAR2
      ,p_media_type               IN  VARCHAR2
      ,p_parameters               IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_parameter_list
      ,p_inline_rb                IN  VARCHAR2
      ,p_load_components          IN  VARCHAR2 DEFAULT 'TRUE'
   ) RETURN SELF AS RESULT
   AS
      int_counter PLS_INTEGER;
      obj_parent  dz_swagger3_schema_typ;
      str_check   VARCHAR2(255 Char);
      
   BEGIN
   /*
      self.hash_key            := p_requestbody_id;
      self.requestbody_id      := p_requestbody_id;
      self.requestBody_inline  := p_inline_rb;
      self.requestBody_force_inline := 'TRUE';
      
      self.requestbody_content := dz_swagger3_media_list();
      self.requestbody_content.EXTEND();
      
      self.requestbody_content(1) := dz_swagger3_media_typ();
      self.requestbody_content(1).hash_key := p_media_type;
      
      obj_parent                     := dz_swagger3_schema_typ();
      obj_parent.schema_id           := p_requestbody_id || '.Schema';
      obj_parent.schema_category     := 'object';
      obj_parent.schema_type         := 'object';
      obj_parent.schema_force_inline := 'TRUE';
      obj_parent.schema_properties   := dz_swagger3_schema_nf_list();
       
      IF obj_parent.schema_category IS NULL
      THEN
         RAISE_APPLICATION_ERROR(-20001,'err');
         
      END IF;
      
      int_counter := 1;
      FOR i IN 1 .. p_parameters.COUNT
      LOOP
         IF  p_parameters(i).parameter_list_hidden <> 'TRUE'
         AND p_parameters(i).parameter_requestbody_flag = 'TRUE'
         THEN
            obj_parent.schema_properties.EXTEND();
            obj_parent.schema_properties(int_counter) := dz_swagger3_schema_typ(
                p_parameter       => p_parameters(i)
               ,p_load_components => p_load_components
            );
            int_counter := int_counter + 1;            

         END IF;
         
      END LOOP;

      self.requestbody_content(1).media_schema := obj_parent;
      
      IF TREAT(
         self.requestbody_content(1).media_schema AS dz_swagger3_schema_typ
      ).schema_category IS NULL
      THEN
         RAISE_APPLICATION_ERROR(-20001,'err');
         
      END IF;
      */
      RETURN;
      
   END dz_swagger3_requestbody_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_requestbody_typ(
       p_hash_key                 IN  VARCHAR2
      ,p_requestbody_id           IN  VARCHAR2
      ,p_requestbody_description  IN  VARCHAR2
      ,p_requestBody_force_inline IN  VARCHAR2
      ,p_requestbody_content      IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_media_list
      ,p_requestbody_required     IN  VARCHAR2
      ,p_load_components          IN  VARCHAR2 DEFAULT 'TRUE'
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.hash_key                 := p_hash_key;
      self.requestbody_id           := p_requestbody_id;
      self.requestbody_description  := p_requestbody_description;
      self.requestBody_force_inline := p_requestBody_force_inline;
      self.requestbody_content      := p_requestbody_content;
      self.requestbody_required     := p_requestbody_required;
      /*
      --------------------------------------------------------------------------
      IF  self.doREF() = 'TRUE'
      AND p_load_components = 'TRUE'
      THEN
         dz_swagger3_main.insert_component(
             p_object_id   => p_requestbody_id
            ,p_object_type => 'requestBody'
         );
         
      END IF;
      */
      RETURN; 
      
   END dz_swagger3_requestbody_typ;
   
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
   MEMBER FUNCTION doRef
   RETURN VARCHAR2
   AS
   BEGIN
      
      IF self.requestBody_force_inline = 'TRUE'
      OR self.requestBody_inline = 'TRUE'
      THEN
         RETURN 'FALSE';
         
      END IF;
      
      RETURN 'TRUE';
      
   END doRef;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print         IN  INTEGER   DEFAULT NULL
      ,p_force_inline         IN  VARCHAR2  DEFAULT 'FALSE' 
   ) RETURN CLOB
   AS
   BEGIN
   
      IF self.doREF() = 'TRUE'
      AND p_force_inline <> 'TRUE'
      THEN
         RETURN toJSON_ref(
             p_pretty_print  => p_pretty_print
            ,p_force_inline  => p_force_inline
         );
   
      ELSE
         RETURN toJSON_schema(
             p_pretty_print  => p_pretty_print
            ,p_force_inline  => p_force_inline
         );
      
      END IF;
   
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON_schema(
       p_pretty_print         IN  INTEGER   DEFAULT NULL
      ,p_force_inline         IN  VARCHAR2  DEFAULT 'FALSE' 
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      boo_temp         BOOLEAN;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_hash         CLOB;
      
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
         str_pad     := '';
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;
      
      str_pad1 := str_pad;
      
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
      -- Add optional description 
      --------------------------------------------------------------------------
      IF  self.requestbody_content IS NOT NULL 
      AND self.requestbody_content.COUNT > 0
      THEN 
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.mediatyp.toJSON( '
         || '   p_pretty_print   => :p01 + 1 '
         || '  ,p_force_inline   => :p02 '
         || ' ) '
         || ',a.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || 'a.object_id IN (SELECT column_name FROM TABLE(:p03)) '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
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
           
   END toJSON_schema;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON_ref(
       p_pretty_print         IN  INTEGER   DEFAULT NULL
      ,p_force_inline         IN  VARCHAR2  DEFAULT 'FALSE' 
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      
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
      
      str_pad1 := str_pad;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional description
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.value2json(
             '$ref'
            ,'#/components/requestBodies/' || dz_swagger3_util.utl_url_escape(
               dz_swagger3_main.short(
                   p_object_id   => self.requestbody_id
                  ,p_object_type => 'requestbody'
                )
             ) 
            ,p_pretty_print + 1
         )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';

      --------------------------------------------------------------------------
      -- Step 40
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON_ref;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print         IN  INTEGER   DEFAULT 0
      ,p_initial_indent       IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed       IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline         IN  VARCHAR2  DEFAULT 'FALSE' 
   ) RETURN CLOB
   AS      
   BEGIN
   
      IF self.doRef() = 'TRUE'
      AND p_force_inline <> 'TRUE'
      THEN
         RETURN self.toYAML_ref(
             p_pretty_print    => p_pretty_print
            ,p_initial_indent  => p_initial_indent
            ,p_final_linefeed  => p_final_linefeed
            ,p_force_inline    => p_force_inline
         );
         
      ELSE
         RETURN self.toYAML_schema(
             p_pretty_print    => p_pretty_print
            ,p_initial_indent  => p_initial_indent
            ,p_final_linefeed  => p_final_linefeed
            ,p_force_inline    => p_force_inline
         );
      
      END IF;
   
   END toYAML;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML_schema(
       p_pretty_print         IN  INTEGER   DEFAULT 0
      ,p_initial_indent       IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed       IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline         IN  VARCHAR2  DEFAULT 'FALSE' 
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
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
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || ' ) '
         || ',a.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || 'a.object_id IN (SELECT column_name FROM TABLE(:p03)) '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,self.requestbody_content; 
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'content: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                dz_swagger3_util.yamlq(ary_keys(i)) || ': '
               ,p_pretty_print + 1
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
      
   END toYAML_schema;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML_ref(
       p_pretty_print         IN  INTEGER   DEFAULT 0
      ,p_initial_indent       IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed       IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline         IN  VARCHAR2  DEFAULT 'FALSE' 
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml description
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty_str(
          '$ref: ' || dz_swagger3_util.yaml_text(
             '#/components/requestBodies/' || dz_swagger3_main.short(
                p_object_id   => self.requestbody_id
               ,p_object_type => 'requestbody'
             )
            ,p_pretty_print
         )
         ,p_pretty_print
         ,'  '
      );
      
      --------------------------------------------------------------------------
      -- Step 30
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
      
   END toYAML_ref;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   STATIC PROCEDURE loader(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  MDSYS.SDO_STRING2_ARRAY
      ,p_versionid           IN  VARCHAR2
   )
   AS
   BEGIN
   
      INSERT INTO dz_swagger3_xrelates(
          parent_object_id
         ,child_object_id
         ,child_object_type_id
      )
      SELECT
       p_parent_id
      ,a.column_value
      ,'extrdocs'
      FROM
      TABLE(p_children_ids) a;

      EXECUTE IMMEDIATE 
      'INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,extrdocstyp
          ,ordering_key
      )
      SELECT
       a.column_value
      ,''extrdocstyp''
      ,dz_swagger3_extrdocs_typ(
          p_externaldoc_id => a.column_value
         ,p_versionid      => :p01
       )
      ,10
      FROM 
      TABLE(:p02) a'
      USING p_versionid,p_children_ids;
      
      COMMIT;

   END;
   
END;
/

