CREATE OR REPLACE PACKAGE dz_swagger3_main
AUTHID DEFINER
AS
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   /*
   header: DZ_SWAGGER3
     
   - Release: %GITRELEASE%
   - Commit Date: %GITCOMMITDATE%
   
   Conversion of DZ_SWAGGER from specification 2.0 to OpenAPI 3.0.
   
   */
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------

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
 
 END dz_swagger3_main;
/

GRANT EXECUTE ON dz_swagger3_main TO public;

