CREATE OR REPLACE TYPE BODY dz_swagger3_jsonsch_typ
AS 
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_jsonsch_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_jsonsch_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_jsonsch_typ(
       p_path_id              IN  VARCHAR2
      ,p_http_method          IN  VARCHAR2 DEFAULT 'get'
      ,p_response_code        IN  VARCHAR2 DEFAULT 'default'
      ,p_media_type           IN  VARCHAR2 DEFAULT 'application/json'
      ,p_title                IN  VARCHAR2 DEFAULT NULL
      ,p_versionid            IN  VARCHAR2 DEFAULT NULL
   ) RETURN SELF AS RESULT
   AS    
      str_versionid     VARCHAR2(255 Char);
      str_operation_id  VARCHAR2(255 Char);
      str_response_id   VARCHAR2(255 Char);
      str_media_id      VARCHAR2(255 Char);
      
   BEGIN
   
      IF p_versionid IS NULL
      THEN
         SELECT
         a.versionid
         INTO str_versionid
         FROM
         dz_swagger3_vers a
         WHERE
             a.is_default = 'TRUE'
         AND rownum <= 1;

      ELSE
         str_versionid  := p_versionid;
         
      END IF;
   
      IF LOWER(p_http_method) = 'get'
      THEN
         SELECT
         a.path_get_operation_id
         INTO
         str_operation_id
         FROM
         dz_swagger3_path a
         WHERE
             a.versionid = str_versionid
         AND a.path_id = p_path_id;
         
      ELSIF LOWER(p_http_method) = 'put'
      THEN
         SELECT
         a.path_put_operation_id
         INTO
         str_operation_id
         FROM
         dz_swagger3_path a
         WHERE
             a.versionid = str_versionid
         AND a.path_id = p_path_id;
         
      ELSIF LOWER(p_http_method) = 'post'
      THEN
         SELECT
         a.path_post_operation_id
         INTO
         str_operation_id
         FROM
         dz_swagger3_path a
         WHERE
             a.versionid = str_versionid
         AND a.path_id = p_path_id;
         
      ELSIF LOWER(p_http_method) = 'delete'
      THEN
         SELECT
         a.path_delete_operation_id
         INTO
         str_operation_id
         FROM
         dz_swagger3_path a
         WHERE
             a.versionid = str_versionid
         AND a.path_id = p_path_id;
         
      ELSIF LOWER(p_http_method) = 'options'
      THEN
         SELECT
         a.path_options_operation_id
         INTO
         str_operation_id
         FROM
         dz_swagger3_path a
         WHERE
             a.versionid = str_versionid
         AND a.path_id = p_path_id;
         
      ELSIF LOWER(p_http_method) = 'head'
      THEN
         SELECT
         a.path_head_operation_id
         INTO
         str_operation_id
         FROM
         dz_swagger3_path a
         WHERE
             a.versionid = str_versionid
         AND a.path_id = p_path_id;
         
      ELSIF LOWER(p_http_method) = 'patch'
      THEN
         SELECT
         a.path_patch_operation_id
         INTO
         str_operation_id
         FROM
         dz_swagger3_path a
         WHERE
             a.versionid = str_versionid
         AND a.path_id = p_path_id;
         
      ELSIF LOWER(p_http_method) = 'trace'
      THEN
         SELECT
         a.path_trace_operation_id
         INTO
         str_operation_id
         FROM
         dz_swagger3_path a
         WHERE
             a.versionid = str_versionid
         AND a.path_id = p_path_id;
         
      ELSE
         RAISE_APPLICATION_ERROR(-20001,'incorrect http method value');
         
      END IF;
      
      SELECT
      a.response_id
      INTO
      str_response_id
      FROM
      dz_swagger3_operation_resp_map a
      WHERE
          a.versionid = str_versionid
      AND a.operation_id = str_operation_id
      AND a.response_code = p_response_code;
      
      SELECT
      a.media_id
      INTO
      str_media_id
      FROM
      dz_swagger3_parent_media_map a
      WHERE
         a.versionid = str_versionid
      AND a.parent_id = str_response_id
      AND a.media_type = p_media_type;
            
      SELECT
      dz_swagger3_schema_typ(
          p_schema_id    => a.media_schema_id
         ,p_required     => NULL
         ,p_versionid    => str_versionid
      )
      INTO
      self.schema_obj
      FROM
      dz_swagger3_media a
      WHERE
         a.versionid = str_versionid
      AND a.media_id = str_media_id;
      
      IF p_title IS NULL
      THEN
         self.schema_obj.schema_title := p_path_id || '|' || p_http_method || '|' || p_response_code || '|' || p_media_type;
         
      ELSE
         self.schema_obj.schema_title := p_title;
      
      END IF;
      
      self.schema_obj.inject_jsonschema := 'TRUE';
      
      RETURN;
      
   EXCEPTION
   
      WHEN NO_DATA_FOUND
      THEN
         RETURN;
         
      WHEN OTHERS
      THEN
         RAISE;
   
   END dz_swagger3_jsonsch_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
      p_pretty_print      IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS 
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      IF self.schema_obj IS NULL
      OR self.schema_obj.isNULL() = 'TRUE'
      THEN
         RETURN NULL;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Return the schema for the endpoint media
      --------------------------------------------------------------------------
      RETURN self.schema_obj.toJSON(
          p_pretty_print   => p_pretty_print
         ,p_force_inline   => 'TRUE'
         ,p_jsonschema     => 'TRUE'
      );
           
   END toJSON;
   
END;
/

