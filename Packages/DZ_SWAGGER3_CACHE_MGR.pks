CREATE OR REPLACE PACKAGE dz_swagger3_cache_mgr
AUTHID DEFINER
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION json(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_refresh_interval    IN  INTERVAL  DAY TO SECOND DEFAULT NULL
      ,p_short_id            IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_escapes       IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION yaml(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_refresh_interval    IN  INTERVAL  DAY TO SECOND DEFAULT NULL
      ,p_short_id            IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_escapes       IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB;
   
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
   ) RETURN CLOB;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION vintage(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
   ) RETURN TIMESTAMP;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE reload_cache(
       p_doc_id              IN  VARCHAR2  DEFAULT NULL
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_short_id            IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_escapes       IN  VARCHAR2  DEFAULT 'FALSE'
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE purge_cache(
       p_doc_id              IN  VARCHAR2  DEFAULT NULL
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
   );

 END dz_swagger3_cache_mgr;
/

GRANT EXECUTE ON dz_swagger3_cache_mgr TO public;

