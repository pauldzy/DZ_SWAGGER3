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
       p_media_id                IN  VARCHAR2
      ,p_media_type              IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
      ,p_ref_brake               IN  VARCHAR2 DEFAULT 'FALSE'
   ) RETURN SELF AS RESULT
   AS
      str_check VARCHAR2(255 Char);
      
   BEGIN
   /*
      BEGIN
         SELECT
         dz_swagger3_media_typ(
             p_hash_key              => p_media_type
            ,p_media_schema          => dz_swagger3_schema_typ(
                p_hash_key              => NULL
               ,p_schema_id             => a.media_schema_id
               ,p_required              => NULL
               ,p_versionid             => p_versionid
               ,p_ref_brake             => p_ref_brake
             )
            ,p_media_example_string  => a.media_example_string
            ,p_media_example_number  => a.media_example_number
            ,p_media_examples        => NULL
            ,p_media_encoding        => NULL
         )
         INTO SELF
         FROM
         dz_swagger3_media a
         WHERE
             a.versionid = p_versionid
         AND a.media_id  = p_media_id;
         
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RAISE_APPLICATION_ERROR(
                -20001
               ,'unable to find media ' || p_media_id
            );
            
         WHEN OTHERS
         THEN
            RAISE;
            
      END;
       */
      RETURN; 
      
   END dz_swagger3_media_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_media_typ(
       p_media_id                IN  VARCHAR2
      ,p_media_schema            IN  VARCHAR2 --dz_swagger3_schema_typ_nf
      ,p_media_example_string    IN  VARCHAR2
      ,p_media_example_number    IN  NUMBER
      ,p_media_examples          IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_example_list
      ,p_media_encoding          IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_encoding_list
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.media_id              := p_media_id;
      self.media_schema          := p_media_schema;
      self.media_example_string  := p_media_example_string;
      self.media_example_number  := p_media_example_number;
      self.media_examples        := p_media_examples;
      self.media_encoding        := p_media_encoding;
      
      RETURN; 
      
   END dz_swagger3_media_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION isNULL
   RETURN VARCHAR2
   AS
   BEGIN
   
      IF self.media_id     IS NOT NULL
      OR self.media_schema IS NOT NULL
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
      RETURN self.media_id;
      
   END key;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      boo_temp         BOOLEAN;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_hash         CLOB;
      clb_tmp          CLOB;
      
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
      -- Add schema object
      --------------------------------------------------------------------------
      IF self.media_schema IS NOT NULL
      THEN
         EXECUTE IMMEDIATE
            'SELECT a.schematyp.toJSON( '
         || '   p_pretty_print   => :p01 + 1 '
         || '  ,p_force_inline   => :p02 '
         || ') FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || 'a.object_id = :p03 '
         INTO clb_tmp
         USING 
          p_pretty_print
         ,p_force_inline
         ,self.media_schema; 
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'schema'
               ,clb_tmp
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional example
      --------------------------------------------------------------------------
      IF self.media_example_string IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'example'
               ,self.media_example_string
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      ELSIF self.media_example_number IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'example'
               ,self.media_example_number
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Add optional examples map
      --------------------------------------------------------------------------
      IF  self.media_examples IS NOT NULL 
      AND self.media_examples.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.exampletyp.toJSON( '
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
         ,self.media_examples;
         
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
               ,p_pretty_print + 1
            );
            str_pad2 := ',';
         
         END LOOP;
         
         clb_hash := clb_hash || dz_json_util.pretty(
             '}'
            ,p_pretty_print + 1,NULL,NULL
         );
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                 'examples'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Add optional encoding map
      --------------------------------------------------------------------------
      IF  self.media_encoding IS NOT NULL 
      AND self.media_encoding.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.encodingtyp.toJSON( '
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
         ,self.media_encoding;
         
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
               ,p_pretty_print + 1
            );
            str_pad2 := ',';
         
         END LOOP;
         
         clb_hash := clb_hash || dz_json_util.pretty(
             '}'
            ,p_pretty_print + 1,NULL,NULL
         );
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                 'encoding'
                ,clb_hash
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
      clb_output       CLOB;
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_tmp          CLOB;
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml schema object
      --------------------------------------------------------------------------
      IF self.media_schema IS NULL
      THEN
         EXECUTE IMMEDIATE
            'SELECT a.schematyp.toYAML( '
         || '   p_pretty_print   => :p01 + 1 '
         || '  ,p_force_inline   => :p02 '
         || ') FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || 'a.object_id = :p03 '
         INTO clb_tmp
         USING 
          p_pretty_print
         ,p_force_inline
         ,self.media_schema; 
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'schema: ' 
            ,p_pretty_print
            ,'  '
         ) || clb_tmp;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the yaml example item
      --------------------------------------------------------------------------
      IF self.media_example_string IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'example: ' || dz_swagger3_util.yaml_text(
                self.media_example_string
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      ELSIF self.media_example_number IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'example: ' || dz_swagger3_util.yaml_text(
                self.media_example_number
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the optional variables map
      --------------------------------------------------------------------------
      IF  self.media_examples IS NOT NULL 
      AND self.media_examples.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.exampletyp.toYAML( '
         || '   p_pretty_print   => :p01 + 3 '
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
         ,self.media_examples;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'examples: '
            ,p_pretty_print + 1
            ,'  '
         );
         
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '''' || ary_keys(i) || ''': '
               ,p_pretty_print + 2
               ,'  '
            ) || ary_clb(i);
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the optional variables map
      --------------------------------------------------------------------------
      IF  self.media_encoding IS NOT NULL 
      AND self.media_encoding.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.encodingtyp.toYAML( '
         || '   p_pretty_print   => :p01 + 3 '
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
         ,self.media_encoding;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'encoding: '
            ,p_pretty_print + 1
            ,'  '
         );
         
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '''' || ary_keys(i) || ''': '
               ,p_pretty_print + 2
               ,'  '
            ) || ary_clb(i);
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
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

