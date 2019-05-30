CREATE OR REPLACE TYPE BODY dz_swagger3_link_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_link_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_link_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_link_typ(
       p_link_id                 IN  VARCHAR2
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
      -- Fetch component items
      --------------------------------------------------------------------------
      SELECT
       a.link_id
      ,a.link_operationRef
      ,a.link_operationId
      ,a.link_requestBody_exp
      ,CASE
       WHEN a.link_server_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id      => a.link_server_id
            ,p_object_type_id => 'servertyp'
         )
       ELSE
         NULL
       END
      INTO
       self.link_id
      ,self.link_operationRef
      ,self.link_operationId
      ,self.link_requestBody_exp
      ,self.link_server
      FROM
      dz_swagger3_link a
      WHERE
          a.versionid = p_versionid
      AND a.link_id   = p_link_id;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Fetch parameter expression map
      --------------------------------------------------------------------------
      SELECT
       a.link_op_parm_name
      ,a.link_op_parm_exp
      BULK COLLECT INTO
       self.link_op_parm_names
      ,self.link_op_parm_exps
      FROM
      dz_swagger3_link_op_parms a
      WHERE
          a.versionid = p_versionid
      AND a.link_id   = p_link_id
      ORDER BY a.link_op_parm_order;

      --------------------------------------------------------------------------
      -- Step 40
      -- Return completed object
      --------------------------------------------------------------------------
      RETURN; 
      
   END dz_swagger3_link_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Load the server
      --------------------------------------------------------------------------
      IF  self.link_server IS NOT NULL
      AND self.link_server.object_id IS NOT NULL
      THEN
         dz_swagger3_loader.servertyp(
             p_parent_id    => self.link_id
            ,p_children_ids => dz_swagger3_object_vry(self.link_server)
            ,p_versionid    => self.versionid
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
      cb               CLOB;
      v2               VARCHAR2(32000);
      
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      
      clb_tmp          CLOB;
      str_identifier   VARCHAR2(255 Char);
      str_operation_id VARCHAR2(255 Char);
      
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
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => dz_json_util.pretty('{',NULL)
         );

      ELSE
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => dz_json_util.pretty('{',-1)
         );
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
         
         dz_swagger3_util.conc(
             p_c    => cb
            ,p_v    => v2
            ,p_in_c => NULL
            ,p_in_v => str_pad1 || dz_json_main.value2json(
                '$ref'
               ,'#/components/links/' || dz_swagger3_util.utl_url_escape(
                  str_identifier
                )
               ,p_pretty_print + 1
            )
            ,p_pretty_print => p_pretty_print + 1
         );
         str_pad1 := ',';

      ELSE      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional operationRef
      --------------------------------------------------------------------------
         IF self.link_operationRef IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => str_pad1 || dz_json_main.value2json(
                   'operationRef'
                  ,self.link_operationRef
                  ,p_pretty_print + 1
                )
               ,p_pretty_print => p_pretty_print + 1
            );
            str_pad1 := ',';
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional operationId
      --------------------------------------------------------------------------
         ELSIF self.link_operationId IS NOT NULL
         THEN
            IF p_short_id = 'TRUE'
            THEN
               SELECT
               a.short_id
               INTO str_operation_id
               FROM
               dz_swagger3_xobjects a
               WHERE
               a.object_id = self.link_operationID;
            
            ELSE
               str_operation_id := self.link_operationID;
               
            END IF;
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => str_pad1 || dz_json_main.value2json(
                   'operationId'
                  ,str_operation_id
                  ,p_pretty_print + 1
                )
               ,p_pretty_print => p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional parameter map
      --------------------------------------------------------------------------
         IF  self.link_op_parm_names IS NOT NULL
         AND self.link_op_parm_names.COUNT > 0
         THEN
            str_pad2 := str_pad;
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => str_pad1 || '"parameters":' || str_pad || '{'
               ,p_pretty_print => p_pretty_print + 1
            );
            
            FOR i IN 1 .. self.link_op_parm_names.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v =>
                      str_pad2 || '"' || self.link_op_parm_names(i) || '":' || 
                      str_pad  || '"' || self.link_op_parm_exps(i)  || '"' 
                  ,p_pretty_print => p_pretty_print + 2
               );
               str_pad2 := ',';
               
            END LOOP;
               
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => '}'
               ,p_pretty_print => p_pretty_print + 1
            );
            str_pad1 := ',';
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add optional requestBody
      --------------------------------------------------------------------------
         IF self.link_requestBody_exp IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => str_pad1 || dz_json_main.value2json(
                   'requestBody'
                  ,self.link_requestBody_exp
                  ,p_pretty_print + 1
                )
               ,p_pretty_print => p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Add optional description
      --------------------------------------------------------------------------
         IF self.link_description IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => str_pad1 || dz_json_main.value2json(
                   'description'
                  ,self.link_description
                  ,p_pretty_print + 1
                )
               ,p_pretty_print => p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Add server object
      --------------------------------------------------------------------------
         IF self.link_server IS NOT NULL
         THEN
            BEGIN
               SELECT
               a.servertyp.toJSON(
                   p_pretty_print  => p_pretty_print + 1
                  ,p_force_inline  => p_force_inline
                  ,p_short_id      => p_short_id
               )
               INTO clb_tmp
               FROM dz_swagger3_xobjects a
               WHERE
                   a.object_type_id = self.link_server.object_type_id
               AND a.object_id      = self.link_server.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;

            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => str_pad1 || '"server":' || str_pad
               ,p_pretty_print => p_pretty_print + 1
               ,p_final_linefeed => FALSE
            );
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => clb_tmp
               ,p_in_v => NULL
               ,p_pretty_print => p_pretty_print + 1
               ,p_initial_indent => FALSE
            );
            
            str_pad1 := ',';

         END IF;
 
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Add the left bracket
      --------------------------------------------------------------------------
      dz_swagger3_util.conc(
          p_c    => cb
         ,p_v    => v2
         ,p_in_c => NULL
         ,p_in_v => '}'
         ,p_pretty_print   => p_pretty_print
         ,p_final_linefeed => FALSE
      );

      --------------------------------------------------------------------------
      -- Step 100
      -- Cough it out
      --------------------------------------------------------------------------
      dz_swagger3_util.fconc(
          p_c    => cb
         ,p_v    => v2
      );
      
      RETURN cb;
           
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
      
      clb_tmp          CLOB;
      str_identifier   VARCHAR2(255 Char);
      str_operation_id VARCHAR2(255 Char);
      
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
               '#/components/links/' || str_identifier
             )
            ,p_pretty_print => p_pretty_print
            ,p_amount       => '  '
         );
         
      ELSE
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the required operationRef
      --------------------------------------------------------------------------
         IF self.link_operationRef IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'operationRef: ' || dz_swagger3_util.yaml_text(
                   self.link_operationRef
                  ,p_pretty_print
                )
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional operationId
      --------------------------------------------------------------------------
         ELSIF self.link_operationId IS NOT NULL
         THEN
            IF p_short_id = 'TRUE'
            THEN
               SELECT
               a.short_id
               INTO str_operation_id
               FROM
               dz_swagger3_xobjects a
               WHERE
               a.object_id = self.link_operationID;
            
            ELSE
               str_operation_id := self.link_operationID;
               
            END IF;
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'operationId: ' || dz_swagger3_util.yaml_text(
                   str_operation_id
                  ,p_pretty_print
                )
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional parameter map
      --------------------------------------------------------------------------
         IF  self.link_op_parm_names IS NOT NULL
         AND self.link_op_parm_names.COUNT > 0
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'parameters: '
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );

            FOR i IN 1 .. self.link_op_parm_names.COUNT
            LOOP
               dz_swagger3_util.conc(
                   p_c    => cb
                  ,p_v    => v2
                  ,p_in_c => NULL
                  ,p_in_v => dz_swagger3_util.yamlq(link_op_parm_names(i)) 
                     || ': ' 
                     || dz_swagger3_util.yamlq(link_op_parm_exps(i)) 
                  ,p_pretty_print => p_pretty_print + 1
                  ,p_amount       => '  '
               );
            
            END LOOP;
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the optional requestBody
      --------------------------------------------------------------------------
         IF self.link_requestBody_exp IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'requestBody: ' || dz_swagger3_util.yaml_text(
                   self.link_requestBody_exp
                  ,p_pretty_print
                )
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Write the optional operationId
      --------------------------------------------------------------------------
         IF self.link_description IS NOT NULL
         THEN
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'description: ' || dz_swagger3_util.yaml_text(
                   self.link_description
                  ,p_pretty_print
                )
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the server object
      --------------------------------------------------------------------------
         IF self.link_server IS NOT NULL
         THEN
            BEGIN
               SELECT
               a.servertyp.toYAML(
                   p_pretty_print  => p_pretty_print + 1
                  ,p_force_inline  => p_force_inline
                  ,p_short_id      => p_short_id
               )
               INTO clb_tmp
               FROM 
               dz_swagger3_xobjects a
               WHERE
                   a.object_type_id = self.link_server.object_type_id
               AND a.object_id      = self.link_server.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;
         
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => NULL
               ,p_in_v => 'server: '
               ,p_pretty_print => p_pretty_print
               ,p_amount       => '  '
            );
            
            dz_swagger3_util.conc(
                p_c    => cb
               ,p_v    => v2
               ,p_in_c => clb_tmp
               ,p_in_v => NULL
            );
            
         END IF;
      
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

