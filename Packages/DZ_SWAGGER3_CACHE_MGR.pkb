CREATE OR REPLACE PACKAGE BODY dz_swagger3_cache_mgr
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE update_cache(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,out_json              OUT CLOB
      ,out_json_pretty       OUT CLOB
      ,out_yaml              OUT CLOB
   )
   AS
   PRAGMA AUTONOMOUS_TRANSACTION;
      obj_core        dz_swagger3_typ;
      
   BEGIN
   
      obj_core := dz_swagger3_typ(
          p_doc_id     => p_doc_id
         ,p_group_id   => p_group_id
         ,p_versionid  => p_versionid
      );
   
      out_json        := obj_core.toJSON();
      out_json_pretty := obj_core.toJSON(0);
      out_yaml        := obj_core.toYAML(0);
      
      BEGIN
         INSERT INTO dz_swagger3_cache(
             doc_id
            ,group_id
            ,json_payload
            ,json_pretty_payload
            ,yaml_payload
            ,extraction_timestamp 
            ,versionid 
         ) VALUES (
             p_doc_id
            ,p_group_id
            ,out_json
            ,out_json_pretty
            ,out_yaml
            ,SYSTIMESTAMP
            ,p_versionid
         );
         
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            UPDATE dz_swagger3_cache
            SET
             json_payload         = out_json
            ,json_pretty_payload  = out_json
            ,yaml_payload         = out_yaml
            ,extraction_timestamp = SYSTIMESTAMP
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
      ,p_refresh_interval    IN  INTERVAL DAY TO SECOND DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output          CLOB;
      clb_output2         CLOB;
      clb_output3         CLOB;
      str_doc_id          VARCHAR2(255 Char);
      str_group_id        VARCHAR2(255 Char);
      str_versionid       VARCHAR2(40 Char);
      dat_timestamp       TIMESTAMP;

   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------

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
      dat_timestamp := vintage(
          p_doc_id     => str_doc_id
         ,p_group_id   => str_group_id
         ,p_versionid  => str_versionid
      );
      
      --------------------------------------------------------------------------
      -- Step 40     
      -- Return results if found
      --------------------------------------------------------------------------
      IF dat_timestamp IS NULL
      OR SYSTIMESTAMP - dat_timestamp > p_refresh_interval
      THEN
         update_cache(
             p_doc_id          => str_doc_id
            ,p_group_id        => str_group_id
            ,p_versionid       => str_versionid
            ,out_json          => clb_output
            ,out_json_pretty   => clb_output2
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
   FUNCTION json_pretty(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_refresh_interval    IN  INTERVAL DAY TO SECOND DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output          CLOB;
      clb_output2         CLOB;
      clb_output3         CLOB;
      str_doc_id          VARCHAR2(255 Char);
      str_group_id        VARCHAR2(255 Char);
      str_versionid       VARCHAR2(40 Char);
      dat_timestamp       TIMESTAMP;

   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------

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
      dat_timestamp := vintage(
          p_doc_id     => str_doc_id
         ,p_group_id   => str_group_id
         ,p_versionid  => str_versionid
      );
      
      --------------------------------------------------------------------------
      -- Step 40     
      -- Return results if found
      --------------------------------------------------------------------------
      IF dat_timestamp IS NULL
      OR SYSTIMESTAMP - dat_timestamp > p_refresh_interval
      THEN
         update_cache(
             p_doc_id          => str_doc_id
            ,p_group_id        => str_group_id
            ,p_versionid       => str_versionid
            ,out_json          => clb_output
            ,out_json_pretty   => clb_output2
            ,out_yaml          => clb_output3
         );
         
      ELSE
         SELECT
         a.json_pretty_payload
         INTO clb_output2
         FROM
         dz_swagger3_cache a
         WHERE
             doc_id    = str_doc_id
         AND group_id  = str_group_id
         AND versionid = str_versionid;
            
      END IF;
      
      RETURN clb_output2;

   END json_pretty;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION yaml(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_refresh_interval    IN  INTERVAL DAY TO SECOND DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output          CLOB;
      clb_output2         CLOB;
      clb_output3         CLOB;
      str_doc_id          VARCHAR2(255 Char);
      str_group_id        VARCHAR2(255 Char);
      str_versionid       VARCHAR2(40 Char);
      dat_timestamp       TIMESTAMP;

   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------

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
      dat_timestamp := vintage(
          p_doc_id     => str_doc_id
         ,p_group_id   => str_group_id
         ,p_versionid  => str_versionid
      );
      
      --------------------------------------------------------------------------
      -- Step 40     
      -- Return results if found
      --------------------------------------------------------------------------
      IF dat_timestamp IS NULL
      OR SYSTIMESTAMP - dat_timestamp > p_refresh_interval
      THEN
         update_cache(
             p_doc_id          => str_doc_id
            ,p_group_id        => str_group_id
            ,p_versionid       => str_versionid
            ,out_json          => clb_output
            ,out_json_pretty   => clb_output2
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
   FUNCTION vintage(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
   ) RETURN TIMESTAMP
   AS
      dat_result          TIMESTAMP;
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
      INTO dat_result
      FROM
      dz_swagger3_cache a
      WHERE
          a.doc_id    = str_doc_id
      AND a.group_id  = str_group_id
      AND a.versionid = str_versionid;
      
      RETURN dat_result;
      
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
          
      WHEN OTHERS
      THEN
         RAISE;
         
   END vintage;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE reload_cache(
       p_doc_id              IN  VARCHAR2  DEFAULT NULL
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
   )
   AS
      clb_output          CLOB;
      clb_output2         CLOB;
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
         ,out_json          => clb_output
         ,out_json_pretty   => clb_output2
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

