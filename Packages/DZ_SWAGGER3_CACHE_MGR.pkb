CREATE OR REPLACE PACKAGE BODY dz_swagger3_cache_mgr
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE force_escape(
      p_json            IN OUT NOCOPY CLOB
   )
   AS
   BEGIN
   
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00A0'),'\u00A0');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00AE'),'\u00AE');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00B0'),'\u00B0');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00B1'),'\u00B1');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00B2'),'\u00B2');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00B3'),'\u00B3');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00B4'),'\u00B4');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00B5'),'\u00B5');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00B7'),'\u00B7');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00BC'),'\u00BC');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00BD'),'\u00BD');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00C0'),'\u00C0');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00C1'),'\u00C1');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00C7'),'\u00C7');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00C8'),'\u00C8');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00C9'),'\u00C9');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00CA'),'\u00CA');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00CD'),'\u00CD');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00D1'),'\u00D1');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00D3'),'\u00D3');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00D6'),'\u00D6');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00D7'),'\u00D7');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00DA'),'\u00DA');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00E0'),'\u00E0');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00E1'),'\u00E1');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00E2'),'\u00E2');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00E3'),'\u00E3');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00E7'),'\u00E7');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00E8'),'\u00E8');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00E9'),'\u00E9');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00EA'),'\u00EA');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00EB'),'\u00EB');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00EC'),'\u00EC');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00ED'),'\u00ED');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00F3'),'\u00F3');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00F6'),'\u00F6');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\0100'),'\u0100');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\0112'),'\u0112');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\012A'),'\u012A');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\0141'),'\u0141');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\014C'),'\u014C');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\0160'),'\u0160');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\0161'),'\u0161');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\016A'),'\u016A');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\02BB'),'\u02BB');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\0302'),'\u0302');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\2013'),'\u2013');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\2014'),'\u2014');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\2015'),'\u2015');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\2018'),'\u2018');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\2019'),'\u2019');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\201B'),'\u201B');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\201C'),'\u201C');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\201D'),'\u201D');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\201F'),'\u201F');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\2022'),'\u2022');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\20AC'),'\u20AC');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\2122'),'\u2122');
      
   END force_escape;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE vintage(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_timestamp           OUT TIMESTAMP
      ,p_short_id            OUT VARCHAR2
      ,p_force_escapes       OUT VARCHAR2
   )
   AS
      str_doc_id          VARCHAR2(255 Char);
      str_group_id        VARCHAR2(255 Char);
      str_versionid       VARCHAR2(40 Char);

   BEGIN
   
      dz_swagger3_main.startup_defaults(
          p_doc_id        => p_doc_id
         ,p_group_id      => p_group_id
         ,p_versionid     => p_versionid
         ,out_doc_id      => str_doc_id
         ,out_group_id    => str_group_id
         ,out_versionid   => str_versionid
      );
   
      SELECT
       a.extraction_timestamp
      ,a.short_id
      ,a.force_escapes
      INTO
       p_timestamp
      ,p_short_id
      ,p_force_escapes
      FROM
      dz_swagger3_cache a
      WHERE
          a.doc_id    = str_doc_id
      AND a.group_id  = str_group_id
      AND a.versionid = str_versionid;
      
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN;
          
      WHEN OTHERS
      THEN
         RAISE;
   
   END vintage;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE update_cache(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_short_id            IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_escapes       IN  VARCHAR2  DEFAULT 'FALSE'
      ,out_json              OUT CLOB
      ,out_yaml              OUT CLOB
   )
   AS
   PRAGMA AUTONOMOUS_TRANSACTION;
      obj_core        dz_swagger3_typ;
      
   BEGIN
   
      obj_core := dz_swagger3_typ(
          p_doc_id    => p_doc_id
         ,p_group_id  => p_group_id
         ,p_versionid => p_versionid
      );
   
      out_json := obj_core.toJSON(
         p_short_id   => p_short_id   
      );
      
      dz_swagger3_util.json2yaml(
          p_input    => out_json
         ,p_output   => out_yaml
      );
      
      IF UPPER(p_force_escapes) = 'TRUE'
      THEN
         force_escape(p_json => out_json);
         force_escape(p_json => out_yaml);
      
      END IF;
      
      BEGIN
         INSERT INTO dz_swagger3_cache(
             doc_id
            ,group_id
            ,json_payload
            ,yaml_payload
            ,extraction_timestamp 
            ,short_id
            ,force_escapes
            ,versionid 
         ) VALUES (
             p_doc_id
            ,p_group_id
            ,out_json
            ,out_yaml
            ,SYSTIMESTAMP
            ,p_short_id
            ,p_force_escapes
            ,p_versionid
         );
         
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            UPDATE dz_swagger3_cache
            SET
             json_payload         = out_json
            ,yaml_payload         = out_yaml
            ,extraction_timestamp = SYSTIMESTAMP
            ,short_id             = p_short_id
            ,force_escapes        = p_force_escapes
            WHERE
                doc_id    = p_doc_id
            AND group_id  = p_group_id
            AND versionid = p_versionid;
            
         WHEN OTHERS
         THEN
            RAISE;
            
      END;
      
      COMMIT;
   
   END update_cache;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION json(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_refresh_interval    IN  INTERVAL  DAY TO SECOND DEFAULT NULL
      ,p_short_id            IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_escapes       IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output                  CLOB;
      clb_output3                 CLOB;
      str_doc_id                  VARCHAR2(255 Char);
      str_group_id                VARCHAR2(255 Char);
      str_versionid               VARCHAR2(40 Char);
      dat_timestamp               TIMESTAMP;
      str_stored_short_id         VARCHAR2(255 Char);
      str_stored_force_escapes    VARCHAR2(255 Char);
      str_requested_short_id      VARCHAR2(255 Char) := UPPER(p_short_id);
      str_requested_force_escapes VARCHAR2(255 Char) := UPPER(p_force_escapes);

   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF str_requested_short_id IS NULL
      OR str_requested_short_id NOT IN ('TRUE','FALSE')
      THEN
         str_requested_short_id := 'TRUE';
         
      END IF;
      
      IF str_requested_force_escapes IS NULL
      OR str_requested_force_escapes NOT IN ('TRUE','FALSE')
      THEN
         str_requested_force_escapes := 'FALSE';
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 20     
      -- Determine the default version if not provided
      --------------------------------------------------------------------------
      dz_swagger3_main.startup_defaults(
          p_doc_id        => p_doc_id
         ,p_group_id      => p_group_id
         ,p_versionid     => p_versionid
         ,out_doc_id      => str_doc_id
         ,out_group_id    => str_group_id
         ,out_versionid   => str_versionid
      );
      
      --------------------------------------------------------------------------
      -- Step 30     
      -- Fetch cache if populated
      --------------------------------------------------------------------------
      vintage(
          p_doc_id        => str_doc_id
         ,p_group_id      => str_group_id
         ,p_versionid     => str_versionid
         ,p_timestamp     => dat_timestamp
         ,p_short_id      => str_stored_short_id
         ,p_force_escapes => str_stored_force_escapes
      );
      
      --------------------------------------------------------------------------
      -- Step 40     
      -- Return results if found
      --------------------------------------------------------------------------
      IF dat_timestamp IS NULL
      OR SYSTIMESTAMP - dat_timestamp > p_refresh_interval
      OR str_requested_short_id      <> str_stored_short_id
      OR str_requested_force_escapes <> str_stored_force_escapes
      THEN
         update_cache(
             p_doc_id          => str_doc_id
            ,p_group_id        => str_group_id
            ,p_versionid       => str_versionid
            ,p_short_id        => str_requested_short_id
            ,p_force_escapes   => str_requested_force_escapes
            ,out_json          => clb_output
            ,out_yaml          => clb_output3
         );
         
      ELSE
         SELECT
         a.json_payload
         INTO clb_output
         FROM
         dz_swagger3_cache a
         WHERE
             doc_id    = str_doc_id
         AND group_id  = str_group_id
         AND versionid = str_versionid;
            
      END IF;
      
      RETURN clb_output; 
      
   END json;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION yaml(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_refresh_interval    IN  INTERVAL  DAY TO SECOND DEFAULT NULL
      ,p_short_id            IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_escapes       IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output                  CLOB;
      clb_output3                 CLOB;
      str_doc_id                  VARCHAR2(255 Char);
      str_group_id                VARCHAR2(255 Char);
      str_versionid               VARCHAR2(40 Char);
      dat_timestamp               TIMESTAMP;
      str_stored_short_id         VARCHAR2(255 Char);
      str_stored_force_escapes    VARCHAR2(255 Char);
      str_requested_short_id      VARCHAR2(255 Char) := UPPER(p_short_id);
      str_requested_force_escapes VARCHAR2(255 Char) := UPPER(p_force_escapes);

   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF str_requested_short_id IS NULL
      OR str_requested_short_id NOT IN ('TRUE','FALSE')
      THEN
         str_requested_short_id := 'TRUE';
         
      END IF;
      
      IF str_requested_force_escapes IS NULL
      OR str_requested_force_escapes NOT IN ('TRUE','FALSE')
      THEN
         str_requested_force_escapes := 'FALSE';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20     
      -- Determine the default version if not provided
      --------------------------------------------------------------------------
      dz_swagger3_main.startup_defaults(
          p_doc_id        => p_doc_id
         ,p_group_id      => p_group_id
         ,p_versionid     => p_versionid
         ,out_doc_id      => str_doc_id
         ,out_group_id    => str_group_id
         ,out_versionid   => str_versionid
      );
      
      --------------------------------------------------------------------------
      -- Step 30     
      -- Fetch cache if populated
      --------------------------------------------------------------------------
      vintage(
          p_doc_id        => str_doc_id
         ,p_group_id      => str_group_id
         ,p_versionid     => str_versionid
         ,p_timestamp     => dat_timestamp
         ,p_short_id      => str_stored_short_id
         ,p_force_escapes => str_stored_force_escapes
      );
      
      --------------------------------------------------------------------------
      -- Step 40     
      -- Return results if found
      --------------------------------------------------------------------------
      IF dat_timestamp IS NULL
      OR SYSTIMESTAMP - dat_timestamp > p_refresh_interval
      OR str_requested_short_id      <> str_stored_short_id
      OR str_requested_force_escapes <> str_stored_force_escapes
      THEN
         update_cache(
             p_doc_id          => str_doc_id
            ,p_group_id        => str_group_id
            ,p_versionid       => str_versionid
            ,p_short_id        => str_requested_short_id
            ,p_force_escapes   => str_requested_force_escapes
            ,out_json          => clb_output
            ,out_yaml          => clb_output3
         );
         
      ELSE
         SELECT
         a.yaml_payload
         INTO clb_output3
         FROM
         dz_swagger3_cache a
         WHERE
             doc_id    = str_doc_id
         AND group_id  = str_group_id
         AND versionid = str_versionid;
            
      END IF;
      
      RETURN clb_output3; 
      
   END yaml;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION jsonschema(
       p_path_endpoint       IN  VARCHAR2
      ,p_path_group_id       IN  VARCHAR2  DEFAULT NULL
      ,p_operation           IN  VARCHAR2  DEFAULT 'get'
      ,p_response_code       IN  VARCHAR2  DEFAULT 'default'
      ,p_media_type          IN  VARCHAR2  DEFAULT 'application/json' 
      ,p_schema_title        IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_short_id            IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_escapes       IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output         CLOB;
      str_pathid         VARCHAR2(4000 Char);
      str_versionid      VARCHAR2(4000 Char) := p_versionid;
      str_pathgroupid    VARCHAR2(4000 Char) := UPPER(p_path_group_id);
      str_path_endpoint  VARCHAR2(4000 Char) := p_path_endpoint;

   BEGIN
   
      IF str_versionid IS NULL
      THEN
         str_versionid := 'TRUNK';
         
      END IF;
   
      BEGIN
         IF str_pathgroupid IS NULL
         THEN
            SELECT
            a.path_id
            INTO
            str_pathid
            FROM
            echo_swagger.dz_swagger3_path a
            WHERE
                a.versionid     = str_versionid
            AND a.path_endpoint = str_path_endpoint
            AND rownum <= 1;
            
         ELSE
            SELECT
            a.path_id
            INTO
            str_pathid
            FROM
            echo_swagger.dz_swagger3_path a
            JOIN
            echo_swagger.dz_swagger3_group b
            ON
            a.path_id = b.path_id
            WHERE
                a.versionid     = str_versionid
            AND b.versionid     = str_versionid
            AND a.path_endpoint = str_path_endpoint
            AND b.group_id      = str_pathgroupid;
         
         END IF;
      
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN NULL;
            
         WHEN OTHERS
         THEN
            RAISE;

      END;
      
      clb_output := dz_swagger3_jsonsch_typ(
          p_path_id        => str_pathid
         ,p_http_method    => p_operation
         ,p_response_code  => p_response_code
         ,p_media_type     => p_media_type
         ,p_title          => p_schema_title
         ,p_versionid      => str_versionid
      ).toJSON();
      
      IF UPPER(p_force_escapes) = 'TRUE'
      THEN
         force_escape(p_json => clb_output);
         
      END IF;
      
      RETURN clb_output;
      
   END jsonschema;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION vintage(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
   ) RETURN TIMESTAMP
   AS
      dat_result          TIMESTAMP;
      str_shorten_logic   VARCHAR2(255 Char);
      str_force_escapes   VARCHAR2(255 Char);
      
   BEGIN
   
      vintage(
          p_doc_id        => p_doc_id
         ,p_group_id      => p_group_id
         ,p_versionid     => p_versionid
         ,p_timestamp     => dat_result
         ,p_short_id      => str_shorten_logic
         ,p_force_escapes => str_force_escapes
      );
   
      RETURN dat_result;
      
   END vintage;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE reload_cache(
       p_doc_id              IN  VARCHAR2  DEFAULT NULL
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_short_id            IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_escapes       IN  VARCHAR2  DEFAULT 'FALSE'
   )
   AS
      clb_output          CLOB;
      clb_output3         CLOB;
      str_doc_id          VARCHAR2(255 Char);
      str_group_id        VARCHAR2(255 Char);
      str_versionid       VARCHAR2(40 Char);
      
   BEGIN
   
      dz_swagger3_main.startup_defaults(
          p_doc_id        => p_doc_id
         ,p_group_id      => p_group_id
         ,p_versionid     => p_versionid
         ,out_doc_id      => str_doc_id
         ,out_group_id    => str_group_id
         ,out_versionid   => str_versionid
      );      
   
      update_cache(
          p_doc_id          => str_doc_id
         ,p_group_id        => str_group_id
         ,p_versionid       => str_versionid
         ,p_short_id        => p_short_id
         ,p_force_escapes   => p_force_escapes
         ,out_json          => clb_output
         ,out_yaml          => clb_output3
      );
         
   END reload_cache;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE purge_cache(
       p_doc_id              IN  VARCHAR2  DEFAULT NULL
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
   )
   AS
      str_doc_id          VARCHAR2(255 Char);
      str_group_id        VARCHAR2(255 Char);
      str_versionid       VARCHAR2(40 Char);

   BEGIN
      
      dz_swagger3_main.startup_defaults(
          p_doc_id        => p_doc_id
         ,p_group_id      => p_group_id
         ,p_versionid     => p_versionid
         ,out_doc_id      => str_doc_id
         ,out_group_id    => str_group_id
         ,out_versionid   => str_versionid
      );

      DELETE FROM dz_swagger3_cache
      WHERE
          doc_id    = p_doc_id
      AND group_id  = p_group_id
      AND versionid = p_versionid;

      COMMIT;
      
   END purge_cache;

END dz_swagger3_cache_mgr;
/

