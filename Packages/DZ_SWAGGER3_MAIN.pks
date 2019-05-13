CREATE OR REPLACE PACKAGE dz_swagger3_main
AUTHID DEFINER
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE startup_defaults(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2 DEFAULT NULL
      ,p_versionid           IN  VARCHAR2 DEFAULT NULL
      ,out_doc_id            OUT VARCHAR2
      ,out_group_id          OUT VARCHAR2
      ,out_versionid         OUT VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE purge_xtemp;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE purge_component;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE insert_component(
       p_object_id           IN  VARCHAR2
      ,p_object_type         IN  VARCHAR2
      ,p_schema_required     IN  VARCHAR2 DEFAULT NULL
      ,p_response_code       IN  VARCHAR2 DEFAULT NULL
      ,p_hash_key            IN  VARCHAR2 DEFAULT NULL
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE add_short_names(
      p_shorten_logic        IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION short(
       p_object_id           IN  VARCHAR2
      ,p_object_type         IN  VARCHAR2
   ) RETURN VARCHAR2;
 
 END dz_swagger3_main;
/

GRANT EXECUTE ON dz_swagger3_main TO public;

