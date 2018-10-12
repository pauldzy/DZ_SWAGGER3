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
   ) RETURN CLOB
   AS
      clb_output          CLOB;
      clb_output2         CLOB;
      clb_output3         CLOB;
      str_doc_id          VARCHAR2(255 Char);
      str_group_id        VARCHAR2(255 Char);
      str_versionid       VARCHAR2(40 Char);
      boo_miss            BOOLEAN;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      boo_miss := FALSE;
      
      --------------------------------------------------------------------------
      -- Step 20     
      -- Determine the default version if not provided
      --------------------------------------------------------------------------
      dz_swagger3_typ.defaults(
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
      BEGIN
         SELECT
         a.json_payload
         INTO clb_output
         FROM
         dz_swagger3_cache a
         WHERE
             a.versionid = str_versionid
         AND a.doc_id    = str_doc_id
         AND a.group_id  = str_group_id;
         
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            boo_fetch := TRUE;
      
         WHEN OTHERS
         THEN
            RAISE;
            
      END;
      
      --------------------------------------------------------------------------
      -- Step 40     
      -- Return results if found
      --------------------------------------------------------------------------
      IF NOT boo_miss
      THEN
         RETURN clb_output;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40     
      -- Hit the cache
      --------------------------------------------------------------------------
      update_cache(
          p_doc_id         => str_doc_id
         ,p_group_id       => str_group_id
         ,p_versionid      => str_versionid
         ,out_json         => clb_output
         ,out_json_pretty  => clb_output2
         ,out_yaml         => clb_output2
      );
      
   END json;
   
   

END dz_swagger3_cache_mgr;
/

