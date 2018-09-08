CREATE OR REPLACE TYPE BODY dz_swagger3_typ
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_typ
   RETURN SELF AS RESULT
   AS
   BEGIN
      RETURN;

   END dz_swagger3_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger_typ(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2 DEFAULT NULL
      ,p_versionid           IN  VARCHAR2 DEFAULT NULL
   ) RETURN SELF AS RESULT
   AS
      str_group_id      VARCHAR2(4000 Char);
      str_versionid     VARCHAR2(40 Char) := p_versionid;

   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF p_group_id IS NULL
      THEN
         str_group_id := p_doc_id;

      ELSE
         str_group_id := p_group_id;

      END IF;

      --------------------------------------------------------------------------
      -- Step 20     
      -- Determine the default version if not provided
      --------------------------------------------------------------------------
      IF str_versionid IS NULL
      THEN
         BEGIN
            SELECT
            a.versionid
            INTO str_versionid
            FROM
            dz_swagger_vers a
            WHERE
                a.is_default = 'TRUE'
            AND rownum <= 1;

         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               RAISE;

         END;

      END IF;

      --------------------------------------------------------------------------
      -- Step 30
      -- Load the info object
      --------------------------------------------------------------------------
      self.info := dz_swagger_info(
          p_doc_id    => p_doc_id
         ,p_versionid => p_versionid
      );
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Load the paths
      --------------------------------------------------------------------------
      self.info := dz_swagger_info(
          p_doc_id    => p_doc_id
         ,p_versionid => p_versionid
      );

      RETURN;

   END dz_swagger_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger_typ(
       p_group_id            IN  VARCHAR2
      ,p_info                IN  dz_swagger3_info
      ,p_servers             IN  dz_swagger3_server_list
      ,p_paths               IN  dz_swagger3_path_hash
      ,p_components          IN  dz_swagger3_components
      ,p_security            IN  dz_swagger3_security_list
      ,p_tags                IN  dz_swagger3_tag_list
      ,p_externalDocs        IN  dz_swagger3_externalDocs
      ,p_versionid           IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS

   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------

      --------------------------------------------------------------------------
      -- Step 20
      -- Load the object
      --------------------------------------------------------------------------
      self.group_id            := p_group_id;
      self.info                := p_info;
      self.servers             := p_servers;
      self.paths               := p_paths;
      self.components          := p_components;
      self.security            := p_security;
      self.tags                := p_tags;
      self.externalDocs        := p_externalDocs;
      self.versionid           := p_versionid;

      RETURN;      

   END dz_swagger_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print      IN  NUMBER   DEFAULT NULL
   ) RETURN CLOB
   AS

   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------

      --------------------------------------------------------------------------
      -- Step 20
      -- Add the left bracket
      --------------------------------------------------------------------------
      IF num_pretty_print IS NULL
      THEN
         clb_output := dz_json_util.pretty('{',NULL);
         str_pad := '';

      ELSE
         clb_output := dz_json_util.pretty('{',-1);
         str_pad := ' ';

      END IF;

      --------------------------------------------------------------------------
      -- Step 30
      -- Add base attributes
      --------------------------------------------------------------------------
      str_pad1 := str_pad;

      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.value2json(
             'openapi'
            ,dz_swagger3_constants.c_openapi_version
            ,num_pretty_print + 1
         )
         ,num_pretty_print + 1
      );
      str_pad1 := ',';

      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.formatted2json(
              'info'
             ,self.swagger_info.toJSON(num_pretty_print + 1)
             ,num_pretty_print + 1
          )
         ,num_pretty_print + 1
      );
      str_pad1 := ',';

      --------------------------------------------------------------------------
      -- Step 40
      -- Add the parms
      --------------------------------------------------------------------------
      /*
      IF self.swagger_parms IS NULL
      OR self.swagger_parms.COUNT = 0
      THEN
         NULL;

      ELSE
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.fastname('parameters',num_pretty_print) || '{'
            ,num_pretty_print + 1
         );
         str_pad1 := ',';

         str_pad2 := str_pad;
         FOR i IN 1 .. self.swagger_parms.COUNT
         LOOP
            IF  self.swagger_parms(i).inline_parm = 'FALSE'
            AND self.swagger_parms(i).parm_undocumented = 'FALSE'
            THEN
               clb_output := clb_output || dz_json_util.pretty(
                   str_pad2 || '"' || self.swagger_parms(i).parameter_ref_id || '": ' || self.swagger_parms(i).toJSON(
                      p_pretty_print => num_pretty_print + 2
                   )
                  ,num_pretty_print + 2
               );
               str_pad2 := ',';

            END IF;

         END LOOP;

         clb_output := clb_output || dz_json_util.pretty(
             '}'
            ,num_pretty_print + 1
         );

      END IF;

      --------------------------------------------------------------------------
      -- Step 80
      -- Add the paths
      --------------------------------------------------------------------------
      IF self.swagger_paths IS NULL
      OR self.swagger_paths.COUNT = 0
      THEN
         NULL;

      ELSE
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.fastname('paths',num_pretty_print) || '{'
            ,num_pretty_print + 1
         );
         str_pad1 := ',';

         str_pad2 := str_pad;
         FOR i IN 1 .. self.swagger_paths.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                str_pad2 || self.swagger_paths(i).toJSON(
                   p_pretty_print => num_pretty_print + 2
                )
               ,num_pretty_print + 2
            );
            str_pad2 := ',';

         END LOOP;

         clb_output := clb_output || dz_json_util.pretty(
             '}'
            ,num_pretty_print + 1
         );

      END IF;

      --------------------------------------------------------------------------
      -- Step 90
      -- Add the defs
      --------------------------------------------------------------------------
      IF self.swagger_defs IS NULL
      OR self.swagger_defs.COUNT = 0
      THEN
         NULL;

      ELSE
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.fastname('definitions',num_pretty_print) || '{'
            ,num_pretty_print + 1
         );
         str_pad1 := ',';

         str_pad2 := str_pad;
         FOR i IN 1 .. self.swagger_defs.COUNT
         LOOP
            IF self.swagger_defs(i).inline_def = 'FALSE'
            THEN
               clb_output := clb_output || dz_json_util.pretty(
                   str_pad2 || '"' || dz_swagger_util.dzcondense(
                      self.swagger_defs(i).versionid
                     ,self.swagger_defs(i).definition
                   ) || '": ' || self.swagger_defs(i).toJSON(
                      p_pretty_print => num_pretty_print + 2
                   )
                  ,num_pretty_print + 2
               );
               str_pad2 := ',';

            END IF;

         END LOOP;

         clb_output := clb_output || dz_json_util.pretty(
             '}'
            ,num_pretty_print + 1
         );

      END IF;
*/
      --------------------------------------------------------------------------
      -- Step 100
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,num_pretty_print,NULL,NULL
      );

      --------------------------------------------------------------------------
      -- Step 110
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toJSON;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML()
   RETURN CLOB
   AS

   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------

      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml
      --------------------------------------------------------------------------
      clb_output := dz_json_util.pretty_str(
          '---'
         ,0
         ,'  '
      ) || dz_json_util.pretty_str(
          'openapi: ' || dz_swagger3_util.yaml_text(
             dz_swagger3_constants.c_openapi_version
            ,0
          )
         ,0
         ,'  '
      ) || dz_json_util.pretty_str(
          'info: '
         ,0
         ,'  '
      ) || self.swagger_info.toYAML(1);
/*
      --------------------------------------------------------------------------
      -- Step 30
      -- Do the parameters
      --------------------------------------------------------------------------
      IF self.swagger_parms IS NOT NULL
      AND self.swagger_parms.COUNT > 0
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'parameters: '
            ,0
            ,'  '
         );

         FOR i IN 1 .. self.swagger_parms.COUNT
         LOOP
            IF  self.swagger_parms(i).inline_parm = 'FALSE'
            AND self.swagger_parms(i).parm_undocumented = 'FALSE'
            THEN
               clb_output := clb_output || dz_json_util.pretty(
                   self.swagger_parms(i).parameter_ref_id || ': '
                  ,1
                  ,'  '
               ) || self.swagger_parms(i).toYAML(2);

            END IF;

         END LOOP;

      END IF;

      --------------------------------------------------------------------------
      -- Step 90
      -- Do the paths
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty_str(
          'paths: '
         ,0
         ,'  '
      );

      FOR i IN 1 .. self.swagger_paths.COUNT
      LOOP
         clb_output := clb_output || dz_json_util.pretty_str(
             '"' || self.swagger_paths(i).swagger_path || '": '
            ,1
            ,'  '
         ) || self.swagger_paths(i).toYAML(2);

      END LOOP;

      --------------------------------------------------------------------------
      -- Step 100
      -- Do the definitions
      --------------------------------------------------------------------------
      IF self.swagger_defs IS NOT NULL
      AND self.swagger_defs.COUNT > 0
      THEN
         int_counter := 0;
         FOR i IN 1 .. self.swagger_defs.COUNT
         LOOP
            IF self.swagger_defs(i).inline_def = 'FALSE'
            THEN
               int_counter := int_counter + 1;

            END IF;

         END LOOP;

         IF int_counter > 0
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'definitions: '
               ,0
               ,'  '
            );

            FOR i IN 1 .. self.swagger_defs.COUNT
            LOOP
               IF self.swagger_defs(i).inline_def = 'FALSE'
               THEN
                  clb_output := clb_output || dz_json_util.pretty(
                      dz_swagger_util.dzcondense(
                         self.swagger_defs(i).versionid
                        ,self.swagger_defs(i).definition
                     ) || ': '
                     ,1
                     ,'  '
                  ) || self.swagger_defs(i).toYAML(2);

               END IF;

            END LOOP;

         END IF;

      END IF;
*/
      --------------------------------------------------------------------------
      -- Step 110
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toYAML;

END;
/

