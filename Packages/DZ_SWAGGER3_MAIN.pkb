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
         AND rownum = 1;
         
      END IF;

   END startup_defaults;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE purge_component
   AS
   PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
   
      EXECUTE IMMEDIATE 'TRUNCATE TABLE dz_swagger3_components';
      
   END purge_component;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE insert_component(
       p_object_id           IN  VARCHAR2
      ,p_object_type         IN  VARCHAR2
      ,p_schema_required     IN  VARCHAR2 DEFAULT NULL
      ,p_response_code       IN  VARCHAR2 DEFAULT NULL
      ,p_hash_key            IN  VARCHAR2 DEFAULT NULL
   )
   AS
   PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      
      INSERT INTO dz_swagger3_components(
          object_id
         ,object_type
         ,schema_required
         ,response_code
         ,hash_key
      ) VALUES (
          p_object_id
         ,p_object_type
         ,p_schema_required
         ,p_response_code
         ,p_hash_key
      );
      
      COMMIT;
      
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         NULL;

      WHEN OTHERS
      THEN
         RAISE;
         
   END insert_component;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE add_short_names(
      p_shorten_logic        IN  VARCHAR2
   )
   AS
   PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN

      IF p_shorten_logic IS NULL
      OR p_shorten_logic = 'NONE'
      THEN
         UPDATE dz_swagger3_components
         SET
         short_id = CASE
         WHEN object_type = 'rbparameter'
         THEN
            'rb.' || object_id
         ELSE
            object_id
         END;
         
      ELSIF p_shorten_logic = 'CONDENSE'
      THEN
         UPDATE dz_swagger3_components
         SET
         short_id = 'x' || TO_CHAR(rownum);

      END IF;
      
      COMMIT;
      
   END add_short_names;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION short(
       p_object_id           IN  VARCHAR2
      ,p_object_type         IN  VARCHAR2
   ) RETURN VARCHAR2
   AS
      str_output VARCHAR2(255 Char);
      
   BEGIN
   
      SELECT
      a.short_id
      INTO str_output
      FROM
      dz_swagger3_components a
      WHERE (
             a.object_type = p_object_type
         AND a.object_id   = p_object_id 
      ) OR (
             a.object_type = 'rbparameter'
         AND p_object_type = 'schema'
         AND 'rb.' || a.object_id   = p_object_id
      );
      
      RETURN str_output;

   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RAISE_APPLICATION_ERROR(
             -20001
            ,'no results for ' || p_object_id
         );
         
      WHEN OTHERS
      THEN
         RAISE;

   END short;

END dz_swagger3_main;
/

