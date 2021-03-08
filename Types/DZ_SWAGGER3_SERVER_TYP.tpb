CREATE OR REPLACE TYPE BODY dz_swagger3_server_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_server_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_server_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_server_typ(
       p_server_id           IN  VARCHAR2
      ,p_versionid           IN  VARCHAR2 DEFAULT NULL
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
      -- Load the parameter self and schema id
      --------------------------------------------------------------------------
      SELECT
       a.server_url
      ,a.server_description
      INTO
       self.server_url
      ,self.server_description
      FROM
      dz_swagger3_server a
      WHERE
          a.versionid = p_versionid
      AND a.server_id = p_server_id;

      --------------------------------------------------------------------------
      -- Step 30 
      -- Load any server variables
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id      => b.server_var_id
         ,p_object_type_id => 'servervartyp'
         ,p_object_key     => b.server_var_name
         ,p_object_order   => a.server_var_order
      )
      BULK COLLECT INTO self.server_variables
      FROM
      dz_swagger3_server_var_map a
      JOIN
      dz_swagger3_server_variable b
      ON
          a.server_var_id = b.server_var_id
      AND a.versionid     = b.versionid
      WHERE
          a.versionid = p_versionid
      AND a.server_id = p_server_id;
  
      --------------------------------------------------------------------------
      -- Step 40 
      -- Return the object
      --------------------------------------------------------------------------
      RETURN;
      
   END dz_swagger3_server_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Load the server vars
      --------------------------------------------------------------------------
      IF  self.server_variables IS NOT NULL
      AND self.server_variables.COUNT > 0
      THEN
         dz_swagger3_loader.servervartyp(
             p_parent_id    => self.server_url
            ,p_children_ids => self.server_variables
            ,p_versionid    => self.versionid
         );
         
      END IF;

   END traverse;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON
   RETURN CLOB
   AS
      clb_output       CLOB;
      clb_variables    CLOB;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Add optional variables map
      --------------------------------------------------------------------------
      IF  self.server_variables IS NOT NULL 
      AND self.server_variables.COUNT > 0
      THEN
         SELECT
         JSON_OBJECTAGG(
            b.object_key VALUE a.servervartyp.toJSON() FORMAT JSON
            RETURNING CLOB
         )
         INTO clb_variables
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.server_variables) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id
         ORDER BY b.object_order;   
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Build the object
      --------------------------------------------------------------------------
      SELECT
      JSON_OBJECT(
          'url'          VALUE self.server_url
         ,'description'  VALUE self.server_description
         ,'variables'    VALUE clb_variables           FORMAT JSON
         ABSENT ON NULL
         RETURNING CLOB
      )
      INTO clb_output
      FROM dual;
      
      --------------------------------------------------------------------------
      -- Step 40
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
      
      ary_keys         dz_swagger3_string_vry;
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the url item, note the dumn handling if object array
      --------------------------------------------------------------------------
      dz_swagger3_util.conc(
          p_c    => cb
         ,p_v    => v2
         ,p_in_c => NULL
         ,p_in_v => 'url: ' || dz_swagger3_util.yaml_text(
             self.server_url
            ,p_pretty_print
         )
         ,p_pretty_print => p_pretty_print
         ,p_amount       => '  '
      );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional description item
      --------------------------------------------------------------------------
      IF self.server_description IS NOT NULL
      THEN
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => 'description: ' || dz_swagger3_util.yaml_text(
                self.server_description
               ,p_pretty_print
             )
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the optional variables map
      --------------------------------------------------------------------------
      IF  self.server_variables IS NOT NULL 
      AND self.server_variables.COUNT > 0
      THEN
         SELECT
          a.servervartyp.toYAML(
             p_pretty_print  => p_pretty_print + 2
            ,p_force_inline  => p_force_inline
            ,p_short_id      => p_short_id
          )
         ,b.object_key
         BULK COLLECT INTO
          ary_clb
         ,ary_keys
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.server_variables) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id
         ORDER BY b.object_order; 
         
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => 'variables: '
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
      -- Step 50
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

