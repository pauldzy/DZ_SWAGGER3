CREATE OR REPLACE PACKAGE BODY dz_swagger3_main
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
   )
   AS
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      out_doc_id        := p_doc_id;
      out_group_id      := p_group_id;
      out_versionid     := p_versionid;
      
      IF out_group_id IS NULL
      THEN
         out_group_id := out_doc_id;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 20     
      -- Determine the default version if not provided
      --------------------------------------------------------------------------
      IF out_versionid IS NULL
      THEN
         BEGIN
            SELECT
            a.versionid
            INTO out_versionid
            FROM
            dz_swagger3_vers a
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
      -- Step 20     
      -- Handle MOA special case
      --------------------------------------------------------------------------
      IF p_doc_id = 'MOA'
      THEN
         SELECT
         a.doc_id
         INTO
         out_doc_id
         FROM
         dz_swagger3_doc a
         WHERE
             a.versionid = out_versionid
         AND a.is_default = 'TRUE'
         AND rownum = 1;
         
      END IF;

   END startup_defaults;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE purge_xtemp
   AS
   BEGIN
   
      EXECUTE IMMEDIATE 'TRUNCATE TABLE dz_swagger3_xrelates';
      EXECUTE IMMEDIATE 'TRUNCATE TABLE dz_swagger3_xobjects';
      
   END purge_xtemp;

END dz_swagger3_main;
/

