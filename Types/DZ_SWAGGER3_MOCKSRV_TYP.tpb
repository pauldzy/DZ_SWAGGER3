CREATE OR REPLACE TYPE BODY dz_swagger3_mocksrv_typ
AS 
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_mocksrv_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_mocksrv_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_mocksrv_typ(
       p_path_id              IN  VARCHAR2
      ,p_http_method          IN  VARCHAR2 DEFAULT 'get'
      ,p_response_code        IN  VARCHAR2 DEFAULT 'default'
      ,p_media_type           IN  VARCHAR2 DEFAULT 'application/json'
      ,p_versionid            IN  VARCHAR2 DEFAULT NULL
   ) RETURN SELF AS RESULT
   AS    
      str_versionid     VARCHAR2(255 Char);
      str_operation_id  VARCHAR2(255 Char);
      str_response_id   VARCHAR2(255 Char);
      str_media_id      VARCHAR2(255 Char);
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      dz_swagger3_main.purge_xtemp();
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Determine the proper versionid value
      --------------------------------------------------------------------------
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
   
      --------------------------------------------------------------------------
      -- Step 30
      -- Determine the operation id
      --------------------------------------------------------------------------
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
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Determine the response id
      --------------------------------------------------------------------------
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
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Determine the media id
      --------------------------------------------------------------------------
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
            
      --------------------------------------------------------------------------
      -- Step 60
      -- Pull the base schema for the operation response
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_schema_typ(
          p_schema_id    => a.media_schema_id
         ,p_versionid    => str_versionid
      )
      INTO
      self.schema_obj
      FROM
      dz_swagger3_media a
      WHERE
         a.versionid = str_versionid
      AND a.media_id = str_media_id;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Walk the schema tree
      --------------------------------------------------------------------------
      self.schema_obj.traverse();
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Determine the schema title
      --------------------------------------------------------------------------
      RETURN;
   
   END dz_swagger3_mocksrv_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toMockJSON(
      p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS 
      clb_output CLOB;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      IF self.schema_obj IS NULL
      OR self.schema_obj.schema_id IS NULL
      THEN
         RETURN NULL;

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Generate wrapper
      --------------------------------------------------------------------------
      clb_output := self.schema_obj.toMockJSON(
         p_short_id   => p_short_id
      );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Return results
      --------------------------------------------------------------------------
      RETURN clb_output;
 
   END toMockJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toMockXML(
      p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN XMLTYPE
   AS
      doc_working  DBMS_XMLDOM.DOMDocument;
      node_working DBMS_XMLDOM.DOMNode;
      doc_output   DBMS_XMLDOM.DOMDocument;
      node_output  DBMS_XMLDOM.DOMNode;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      IF self.schema_obj IS NULL
      OR self.schema_obj.schema_id IS NULL
      THEN
         RETURN NULL;

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Generate wrapper
      --------------------------------------------------------------------------
      doc_working  := DBMS_XMLDOM.newDOMDocument(self.schema_obj.toMockXML);
      node_working := DBMS_XMLDOM.makeNode(doc_working);
      
      doc_output := DBMS_XMLDOM.newDOMDocument;
      DBMS_XMLDOM.setVersion(doc_output,'1.0');
      DBMS_XMLDOM.setcharset(doc_output,'UTF-8');
      node_output := DBMS_XMLDOM.makeNode(doc_output);
      node_output := DBMS_XMLDOM.appendChild(
          node_output
         ,node_working
      );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Return results
      --------------------------------------------------------------------------
      RETURN DBMS_XMLDOM.getXMLType(doc_output);

   END toMockXML;
   
END;
/

