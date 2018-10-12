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
 
 END dz_swagger3_main;
/

GRANT EXECUTE ON dz_swagger3_main TO public;

