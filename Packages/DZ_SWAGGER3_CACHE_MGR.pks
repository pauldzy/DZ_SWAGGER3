CREATE OR REPLACE PACKAGE dz_swagger3_cache_mgr
AUTHID DEFINER
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION json(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_refresh_interval    IN  INTERVAL DAY TO SECOND DEFAULT NULL
   ) RETURN CLOB;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION json_pretty(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_refresh_interval    IN  INTERVAL DAY TO SECOND DEFAULT NULL
   ) RETURN CLOB;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION yaml(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_refresh_interval    IN  INTERVAL DAY TO SECOND DEFAULT NULL
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

