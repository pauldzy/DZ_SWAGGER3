CREATE OR REPLACE PACKAGE BODY dz_swagger3_setup
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE create_storage_tables(
       p_table_tablespace VARCHAR2 DEFAULT dz_swagger3_constants.c_table_tablespace
      ,p_index_tablespace VARCHAR2 DEFAULT dz_swagger3_constants.c_index_tablespace
   )
   AS
      str_sql VARCHAR2(4000 Char);
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check that user is qualified to create tables in schema
      --------------------------------------------------------------------------
   
      --------------------------------------------------------------------------
      -- Step 20
      -- Build VERS table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_vers('
              || '    versionid            VARCHAR2(40 Char) NOT NULL '
              || '   ,is_default           VARCHAR2(5 Char) NOT NULL '
              || '   ,version_owner        VARCHAR2(255 Char) '
              || '   ,version_created      DATE '
              || '   ,version_notes        VARCHAR2(255 Char)  '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_vers '
              || 'ADD CONSTRAINT dz_swagger3_vers_pk '
              || 'PRIMARY KEY(versionid) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_vers '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_vers_c01 '
              || '    CHECK (is_default IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_vers_c02 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Build DOC table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_doc('
              || '    doc_id              VARCHAR2(255 Char) NOT NULL '
              || '   ,info_title          VARCHAR2(255 Char) NOT NULL '
              || '   ,info_description    VARCHAR2(4000 Char) '
              || '   ,info_termsofservice VARCHAR2(255 Char) '
              || '   ,info_contact_name   VARCHAR2(255 Char) '
              || '   ,info_contact_url    VARCHAR2(255 Char) '
              || '   ,info_contact_email  VARCHAR2(255 Char) '
              || '   ,info_license_name   VARCHAR2(255 Char) '
              || '   ,info_license_url    VARCHAR2(255 Char) '
              || '   ,info_version        VARCHAR2(255 Char) NOT NULL '
              || '   ,info_desc_updated   DATE '
              || '   ,info_desc_author    VARCHAR2(30 Char) '
              || '   ,info_desc_notes     VARCHAR2(255 Char) '
              || '   ,doc_externalDocs_id VARCHAR2(255 Char) '
              || '   ,versionid           VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_doc '
              || 'ADD CONSTRAINT dz_swagger3_doc_pk '
              || 'PRIMARY KEY(versionid,doc_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_doc '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_doc_c01 '
              || '    CHECK (doc_id = TRIM(doc_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_doc_c02 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Build DOC table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_group('
              || '    group_id            VARCHAR2(255 Char) NOT NULL '
              || '   ,doc_id              VARCHAR2(255 Char) NOT NULL '
              || '   ,path_id             VARCHAR2(255 Char) NOT NULL '
              || '   ,versionid           VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_group '
              || 'ADD CONSTRAINT dz_swagger3_group_pk '
              || 'PRIMARY KEY(versionid,group_id,doc_id,path_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_group '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_group_c01 '
              || '    CHECK (group_id = TRIM(group_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_group_c02 '
              || '    CHECK (doc_id = TRIM(doc_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_group_c03 '
              || '    CHECK (path_id = TRIM(path_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_group_c04 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Build HEAD_TO_SERVER table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_server_parent_map('
              || '    parent_id           VARCHAR2(255 Char) NOT NULL '
              || '   ,server_id           VARCHAR2(255 Char) NOT NULL '
              || '   ,versionid           VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_server_parent_map '
              || 'ADD CONSTRAINT dz_swagger3_server_parent_mapk '
              || 'PRIMARY KEY(versionid,parent_id,server_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_server_parent_map '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_server_parent_mc01 '
              || '    CHECK (parent_id = TRIM(parent_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_server_parent_mc02 '
              || '    CHECK (server_id = TRIM(server_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_server_parent_mc03 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Build SERVER table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_server('
              || '    server_id           VARCHAR2(255 Char) NOT NULL '
              || '   ,server_url          VARCHAR2(255 Char) NOT NULL '
              || '   ,server_description  VARCHAR2(4000 Char) '
              || '   ,server_variables    CLOB '
              || '   ,versionid           VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_server '
              || 'ADD CONSTRAINT dz_swagger3_server_pk '
              || 'PRIMARY KEY(versionid,server_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_server '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_server_c01 '
              || '    CHECK (server_id = TRIM(server_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_server_c02 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT ensure_json '
              || '    CHECK(server_variables IS JSON) '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Build PATH table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_path('
              || '    path_id                VARCHAR2(255 Char) NOT NULL '
              || '   ,path_endpoint          VARCHAR2(255 Char) NOT NULL '
              || '   ,path_summary           VARCHAR2(4000 Char) '
              || '   ,path_description       VARCHAR2(4000 Char) '
              || '   ,path_order             INTEGER NOT NULL '
              || '   ,path_get_operation     VARCHAR2(255 Char) '
              || '   ,path_put_operation     VARCHAR2(255 Char) '
              || '   ,path_post_operation    VARCHAR2(255 Char) '
              || '   ,path_delete_operation  VARCHAR2(255 Char) '
              || '   ,path_options_operation VARCHAR2(255 Char) '
              || '   ,path_head_operation    VARCHAR2(255 Char) '
              || '   ,path_patch_operation   VARCHAR2(255 Char) '
              || '   ,path_trace_operation   VARCHAR2(255 Char) '
              || '   ,path_desc_updated      DATE '
              || '   ,path_desc_author       VARCHAR2(30 Char) '
              || '   ,path_desc_notes        VARCHAR2(255 Char) '
              || '   ,versionid              VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_path '
              || 'ADD CONSTRAINT dz_swagger3_path_pk '
              || 'PRIMARY KEY(versionid,path_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_path '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_path_c01 '
              || '    CHECK (path_id = TRIM(path_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_path_c02 '
              || '    CHECK (path_endpoint = TRIM(path_endpoint)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_path_c03 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Build PARENT_TO_PARM table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_parm_parent_map('
              || '    parent_id              VARCHAR2(255 Char) NOT NULL '
              || '   ,parm_id                VARCHAR2(255 Char) NOT NULL '
              || '   ,parm_order             INTEGER NOT NULL '
              || '   ,versionid              VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_parm_parent_map '
              || 'ADD CONSTRAINT dz_swagger3_parm_parent_map_pk '
              || 'PRIMARY KEY(versionid,parent_id,parm_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_parm_parent_map '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_parm_parent_mapc01 '
              || '    CHECK (parent_id = TRIM(parent_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parm_parent_mapc02 '
              || '    CHECK (parm_id = TRIM(parm_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parm_parent_mapc03 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Build PARM table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_parm('
              || '    parm_id              VARCHAR2(255 Char) NOT NULL '
              || '   ,parm_name            VARCHAR2(255 Char) NOT NULL '
              || '   ,parm_in              VARCHAR2(255 Char) NOT NULL '
              || '   ,parm_description     VARCHAR2(4000 Char) '
              || '   ,parm_required        VARCHAR2(5 Char) '
              || '   ,parm_deprecated      VARCHAR2(5 Char) '
              || '   ,parm_allowEmptyValue VARCHAR2(5 Char) '
              || '   ,parm_style           VARCHAR2(255 Char) '
              || '   ,parm_explode         VARCHAR2(5 Char) '
              || '   ,parm_allowReserved   VARCHAR2(5 Char) '
              || '   ,parm_schema          VARCHAR2(255 Char) '
              || '   ,parm_example         VARCHAR2(255 Char) '
              || '   ,parm_content         VARCHAR2(255 Char) '
              || '   ,parm_sort            INTEGER NOT NULL '
              || '   ,parm_undocumented    VARCHAR2(5 Char) '
              || '   ,parm_desc_updated    DATE '
              || '   ,parm_desc_author     VARCHAR2(30 Char) '
              || '   ,parm_desc_notes      VARCHAR2(255 Char) '
              || '   ,versionid            VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_parm '
              || 'ADD CONSTRAINT dz_swagger3_parm_pk '
              || 'PRIMARY KEY(versionid,parm_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_parm '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_parm_c01 '
              || '    CHECK (parm_required IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parm_c02 '
              || '    CHECK (parm_deprecated IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parm_c03 '
              || '    CHECK (parm_allowEmptyValue IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parm_c04 '
              || '    CHECK (parm_explode IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parm_c05 '
              || '    CHECK (parm_allowReserved IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parm_c06 '
              || '    CHECK (parm_id = TRIM(parm_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parm_c07 '
              || '    CHECK (parm_name = TRIM(parm_name)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parm_c08 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parm_c09 '
              || '    CHECK (parm_undocumented IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Build OPERATION table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_operation('
              || '    operation_id            VARCHAR2(255 Char) NOT NULL '
              || '   ,operation_summary       VARCHAR2(4000 Char) '
              || '   ,operation_description   VARCHAR2(4000 Char) '
              || '   ,operation_externalDocs  CLOB '
              || '   ,operation_operationID   VARCHAR2(255 Char) '
              || '   ,operation_requestBody   VARCHAR2(255 Char) '
              || '   ,operation_deprecated    VARCHAR2(5 Char) '
              || '   ,operation_security_id   VARCHAR2(255 Char) '
              || '   ,operation_desc_updated  DATE '
              || '   ,operation_desc_author   VARCHAR2(30 Char) '
              || '   ,operation_desc_notes    VARCHAR2(255 Char) '
              || '   ,versionid               VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_operation '
              || 'ADD CONSTRAINT dz_swagger3_operation_pk '
              || 'PRIMARY KEY(versionid,operation_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_operation '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_operation_c01 '
              || '    CHECK (operation_id = TRIM(operation_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_c02 '
              || '    CHECK (operation_operationID = TRIM(operation_operationID)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_c03 '
              || '    CHECK (operation_deprecated IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_c04 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Build PARENT_TO_PARM table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_operation_resp_map('
              || '    operation_id        VARCHAR2(255 Char) NOT NULL '
              || '   ,response_code       VARCHAR2(255 Char) NOT NULL '
              || '   ,response_id         VARCHAR2(255 Char) NOT NULL '
              || '   ,versionid           VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_operation_resp_map '
              || 'ADD CONSTRAINT dz_swagger3_operation_resp_mpk '
              || 'PRIMARY KEY(versionid,operation_id,response_code,response_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_operation_resp_map '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_operation_resp_c01 '
              || '    CHECK (operation_id = TRIM(operation_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_resp_c02 '
              || '    CHECK (response_code = TRIM(response_code)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_resp_c03 '
              || '    CHECK (response_id = TRIM(response_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_resp_c04 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Build OPERATION TAG MAP table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_operation_tag_map('
              || '    operation_id        VARCHAR2(255 Char) NOT NULL '
              || '   ,tag_name            VARCHAR2(255 Char) NOT NULL '
              || '   ,tag_id              VARCHAR2(255 Char) '
              || '   ,versionid           VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_operation_tag_map '
              || 'ADD CONSTRAINT dz_swagger3_operation_tag_mapk '
              || 'PRIMARY KEY(versionid,operation_id,tag_name ) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_operation_tag_map '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_operation_tag_mc01 '
              || '    CHECK (operation_id = TRIM(operation_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_tag_mc02 '
              || '    CHECK (tag_name = TRIM(tag_name)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_tag_mc03 '
              || '    CHECK (tag_id = TRIM(tag_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_tag_mc04 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 130
      -- Build RESPONSE table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_response('
              || '    response_id           VARCHAR2(255 Char) NOT NULL '
              || '   ,response_description  VARCHAR2(255 Char) NOT NULL '
              || '   ,response_desc_updated DATE '
              || '   ,response_desc_author  VARCHAR2(30 Char) '
              || '   ,response_desc_notes   VARCHAR2(255 Char) '
              || '   ,versionid             VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_response '
              || 'ADD CONSTRAINT dz_swagger3_response_pk '
              || 'PRIMARY KEY(versionid,response_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_response '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_response_c01 '
              || '    CHECK (response_id = TRIM(response_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_response_c02 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 140
      -- Build CONTENT_TO_RESP table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_media_parent_map('
              || '    parent_id           VARCHAR2(255 Char) NOT NULL '
              || '   ,media_type          VARCHAR2(255 Char) NOT NULL '
              || '   ,media_id            VARCHAR2(255 Char) NOT NULL '
              || '   ,versionid           VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_media_parent_map '
              || 'ADD CONSTRAINT dz_swagger3_media_parent_mappk '
              || 'PRIMARY KEY(versionid,parent_id,media_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_media_parent_map '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_media_parent_mac01 '
              || '    CHECK (parent_id = TRIM(parent_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_media_parent_mac02 '
              || '    CHECK (media_id = TRIM(media_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_media_parent_mac03 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 150
      -- Build MEDIA table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_media('
              || '    media_id            VARCHAR2(255 Char) NOT NULL '
              || '   ,media_schema_id     VARCHAR2(255 Char) NOT NULL '
              || '   ,media_example       VARCHAR2(255 Char) '
              || '   ,versionid           VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_media '
              || 'ADD CONSTRAINT dz_swagger3_media_pk '
              || 'PRIMARY KEY(versionid,media_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_media '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_media_c01 '
              || '    CHECK (media_id = TRIM(media_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_media_c02 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 160
      -- Build SCHEMA table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_schema('
              || '    schema_id               VARCHAR2(255 Char) NOT NULL '
              || '   ,schema_title            VARCHAR2(255 Char) '
              || '   ,schema_type             VARCHAR2(255 Char) '
              || '   ,schema_description      VARCHAR2(4000 Char) '
              || '   ,schema_format           VARCHAR2(255 Char) '
              || '   ,schema_nullable         VARCHAR2(5 Char) '
              || '   ,schema_discriminator    VARCHAR2(255 Char) '
              || '   ,schema_readOnly         VARCHAR2(5 Char) '
              || '   ,schema_writeOnly        VARCHAR2(5 Char) '
              || '   ,schema_externalDocs_id  VARCHAR2(255 Char) '
              || '   ,schema_example          VARCHAR2(255 Char) '
              || '   ,schema_deprecated       VARCHAR2(5 Char) '
              || '   ,xml_name                VARCHAR2(255 Char) '
              || '   ,xml_namespace           VARCHAR2(2000 Char) '
              || '   ,xml_prefix              VARCHAR2(255 Char) '
              || '   ,xml_attribute           VARCHAR2(5 Char) '
              || '   ,xml_wrapped             VARCHAR2(5 Char) '
              || '   ,schema_desc_updated     DATE '
              || '   ,schema_desc_author      VARCHAR2(30 Char) '
              || '   ,schema_desc_notes       VARCHAR2(255 Char) '
              || '   ,versionid               VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_schema '
              || 'ADD CONSTRAINT dz_swagger3_schema_pk '
              || 'PRIMARY KEY(versionid,schema_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_schema '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_schema_c01 '
              || '    CHECK (schema_id = TRIM(schema_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c02 '
              || '    CHECK (schema_nullable IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c03 '
              || '    CHECK (schema_readOnly IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c04 '
              || '    CHECK (schema_writeOnly IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c05 '
              || '    CHECK (schema_deprecated IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c06 '
              || '    CHECK (xml_attribute IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c07 '
              || '    CHECK (xml_wrapped IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c08 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 170
      -- Build COMPONENTS table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_schema_prop_map('
              || '    schema_id                VARCHAR2(255 Char) NOT NULL '
              || '   ,property_id              VARCHAR2(255 Char) NOT NULL '
              || '   ,property_order           INTEGER NOT NULL '
              || '   ,property_required        VARCHAR2(5 Char)   NOT NULL '
              || '   ,versionid                VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_schema_prop_map '
              || 'ADD CONSTRAINT dz_swagger3_schema_prop_mappk '
              || 'PRIMARY KEY(versionid,schema_id,property_order) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_schema_prop_map '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_schema_prop_mac01 '
              || '    CHECK (schema_id = TRIM(schema_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_prop_mac02 '
              || '    CHECK (property_id = TRIM(property_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_prop_mac03 '
              || '    CHECK (property_required IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_prop_mac04 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 180
      -- Build PROPERTIES table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_property('
              || '    property_id           VARCHAR2(255 Char) NOT NULL '
              || '   ,property              VARCHAR2(255 Char) NOT NULL '
              || '   ,property_type         VARCHAR2(255 Char) NOT NULL '
              || '   ,property_target       VARCHAR2(255 Char) '
              || '   ,property_format       VARCHAR2(255 Char) '
              || '   ,property_allow_null   VARCHAR2(5 Char) NOT NULL '
              || '   ,property_title        VARCHAR2(255 Char) '
              || '   ,property_exp_string   VARCHAR2(255 Char) '
              || '   ,property_exp_number   NUMBER '
              || '   ,property_description  VARCHAR2(4000 Char) '
              || '   ,property_desc_updated DATE '
              || '   ,property_desc_author  VARCHAR2(30 Char) '
              || '   ,property_desc_notes   VARCHAR2(255 Char) '
              || '   ,xml_name              VARCHAR2(255 Char) '
              || '   ,xml_namespace         VARCHAR2(2000 Char) '
              || '   ,xml_prefix            VARCHAR2(255 Char) '
              || '   ,xml_attribute         VARCHAR2(5 Char) '
              || '   ,xml_wrapped           VARCHAR2(5 Char) '
              || '   ,xml_array_name        VARCHAR2(255 Char) '
              || '   ,versionid             VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_property '
              || 'ADD CONSTRAINT dz_swagger3_property_pk '
              || 'PRIMARY KEY(versionid,property_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_property '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_property_c01 '
              || '    CHECK (property_id = TRIM(property_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_property_c02 '
              || '    CHECK (property = TRIM(property)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_property_c03 '
              || '    CHECK (property_target = TRIM(property_target)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_property_c04 '
              || '    CHECK (property_allow_null IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_property_c05 '
              || '    CHECK (xml_attribute IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_property_c06 '
              || '    CHECK (xml_wrapped IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_property_c07 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 190
      -- Build EXAMPLE table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_requestBody('
              || '    requestBody_id           VARCHAR2(255 Char) NOT NULL '
              || '   ,requestBody_description  VARCHAR2(4000 Char) '
              || '   ,requestBody_required     VARCHAR2(5 Char) '
              || '   ,versionid                VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_requestBody '
              || 'ADD CONSTRAINT dz_swagger3_requestBody_pk '
              || 'PRIMARY KEY(versionid,requestBody_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_requestBody '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_requestBody_c01 '
              || '    CHECK (requestBody_id = TRIM(requestBody_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_requestBody_c02 '
              || '    CHECK (requestBody_required IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_requestBody_c03 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 200
      -- Build EXAMPLE table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_example('
              || '    example_id             VARCHAR2(255 Char) NOT NULL '
              || '   ,example_summary        VARCHAR2(255 Char) '
              || '   ,example_description    VARCHAR2(4000 Char) '
              || '   ,example_value_string   VARCHAR2(255 Char) '
              || '   ,example_value_number   NUMBER '
              || '   ,example_externalValue  VARCHAR2(255 Char) '
              || '   ,versionid              VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_example '
              || 'ADD CONSTRAINT dz_swagger3_example_pk '
              || 'PRIMARY KEY(versionid,example_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_example '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_example_c01 '
              || '    CHECK (example_id = TRIM(example_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_example_c02 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 210
      -- Build ENCODING table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_encoding('
              || '    encoding_id            VARCHAR2(255 Char) NOT NULL '
              || '   ,encoding_contentType   VARCHAR2(255 Char) '
              || '   ,encoding_style         VARCHAR2(255 Char) '
              || '   ,encoding_explode       VARCHAR2(5 Char) '
              || '   ,encoding_allowReserved VARCHAR2(5 Char) '
              || '   ,versionid              VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_encoding '
              || 'ADD CONSTRAINT dz_swagger3_encoding_pk '
              || 'PRIMARY KEY(versionid,encoding_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_encoding '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_encoding_c01 '
              || '    CHECK (encoding_id = TRIM(encoding_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_encoding_c02 '
              || '    CHECK (encoding_explode IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_encoding_c03 '
              || '    CHECK (encoding_allowReserved IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_encoding_c04 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 220
      -- Build LINK table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_link('
              || '    link_id                VARCHAR2(255 Char) NOT NULL '
              || '    link_operationRef      VARCHAR2(255 Char) '
              || '   ,link_operationId       VARCHAR2(255 Char) '
              || '   ,link_description       VARCHAR2(4000 Char) '
              || '   ,link_server_id         VARCHAR2(255 Char) '
              || '   ,versionid              VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_link '
              || 'ADD CONSTRAINT dz_swagger3_link_pk '
              || 'PRIMARY KEY(versionid,link_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_link '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_link_c01 '
              || '    CHECK (link_id = TRIM(link_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_link_c02 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 230
      -- Build PARM table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_header('
              || '    header_id              VARCHAR2(255 Char) NOT NULL '
              || '   ,header_description     VARCHAR2(4000 Char) '
              || '   ,header_required        VARCHAR2(5 Char) '
              || '   ,header_deprecated      VARCHAR2(5 Char) '
              || '   ,header_allowEmptyValue VARCHAR2(5 Char) '
              || '   ,header_style           VARCHAR2(255 Char) '
              || '   ,header_explode         VARCHAR2(5 Char) '
              || '   ,header_allowReserved   VARCHAR2(5 Char) '
              || '   ,header_schema          VARCHAR2(255 Char) '
              || '   ,header_example         VARCHAR2(255 Char) '
              || '   ,header_content         VARCHAR2(255 Char) '
              || '   ,header_desc_updated    DATE '
              || '   ,header_desc_author     VARCHAR2(30 Char) '
              || '   ,header_desc_notes      VARCHAR2(255 Char) '
              || '   ,versionid            VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_header '
              || 'ADD CONSTRAINT dz_swagger3_header_pk '
              || 'PRIMARY KEY(versionid,header_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_header '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_header_c01 '
              || '    CHECK (header_required IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_header_c02 '
              || '    CHECK (header_deprecated IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_header_c03 '
              || '    CHECK (header_allowEmptyValue IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_header_c04 '
              || '    CHECK (header_explode IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_header_c05 '
              || '    CHECK (header_allowReserved IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_header_c06 '
              || '    CHECK (header_id = TRIM(header_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_header_c07 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 240
      -- Build EXTERNALDOC table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_externaldoc('
              || '    externaldoc_id           VARCHAR2(255 Char) NOT NULL '
              || '   ,externaldoc_description  VARCHAR2(4000 Char) '
              || '   ,externaldoc_url          VARCHAR2(245 Char) '
              || '   ,versionid                VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_externaldoc '
              || 'ADD CONSTRAINT dz_swagger3_externaldoc_pk '
              || 'PRIMARY KEY(versionid,externaldoc_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_externaldoc '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_externaldoc_c01 '
              || '    CHECK (externaldoc_id = TRIM(externaldoc_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_externaldoc_c02 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 250
      -- Build SECURITYSCHEME table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_securityScheme('
              || '    securityScheme_id           VARCHAR2(255 Char) NOT NULL '
              || '   ,securityScheme_type         VARCHAR2(255 Char) NOT NULL '
              || '   ,securityScheme_description  VARCHAR2(4000 Char) '
              || '   ,securityScheme_name         VARCHAR2(255 Char) '
              || '   ,securityScheme_in           VARCHAR2(255 Char) '
              || '   ,securityScheme_scheme       VARCHAR2(255 Char) '
              || '   ,securityScheme_bearerFormat VARCHAR2(255 Char) '
              || '   ,OAuth_authorizationUrl      VARCHAR2(255 Char) '
              || '   ,OAuth_tokenUrl              VARCHAR2(255 Char) '
              || '   ,OAuth_refreshUrl            VARCHAR2(255 Char) '
              || '   ,OAuth_scopes                CLOB '              
              || '   ,versionid                   VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_securityScheme '
              || 'ADD CONSTRAINT dz_swagger3_securityScheme_pk '
              || 'PRIMARY KEY(versionid,securityScheme_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_securityScheme '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_securityScheme_c01 '
              || '    CHECK (securityScheme_id = TRIM(securityScheme_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_securityScheme_c02 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 260
      -- Build TAG table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_tag('
              || '    tag_id               VARCHAR2(255 Char) NOT NULL '
              || '   ,tag_name             VARCHAR2(255 Char) NOT NULL '
              || '   ,tag_description      VARCHAR2(4000 Char) '
              || '   ,tag_externalDocs_id  VARCHAR2(255 Char) '
              || '   ,versionid            VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_tag '
              || 'ADD CONSTRAINT dz_swagger3_tag_pk '
              || 'PRIMARY KEY(versionid,tag_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_tag '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_tag_c01 '
              || '    CHECK (tag_id = TRIM(tag_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_tag_c02 '
              || '    CHECK (tag_name = TRIM(tag_name)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_path_tag_c03 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 270
      -- Build CONDENSE table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_condense('
              || '    condense_key         VARCHAR2(255 Char) NOT NULL '
              || '   ,condense_value       VARCHAR2(255 Char) NOT NULL '
              || '   ,versionid            VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_condense '
              || 'ADD ( '
              || '    CONSTRAINT dz_swagger3_condense_pk '
              || '    PRIMARY KEY(versionid,condense_key,condense_value) ';
              
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || '    USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      str_sql := str_sql 
              || '   ,CONSTRAINT dz_swagger3_condense_u01 '
              || '    UNIQUE(versionid,condense_value) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || '    USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
       
      str_sql := str_sql || ') ';
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_condense '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_condense_c01 '
              || '    CHECK (condense_key = TRIM(condense_key)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_condense_c02 '
              || '    CHECK (condense_value = TRIM(condense_value)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_condense_c03 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;      
      
   END create_storage_tables;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dz_swagger3_table_list
   RETURN MDSYS.SDO_STRING2_ARRAY
   AS
   
   BEGIN
   
      RETURN MDSYS.SDO_STRING2_ARRAY(
          'DZ_SWAGGER3_VERS'
         ,'DZ_SWAGGER3_DOC'
         ,'DZ_SWAGGER3_GROUP'
         ,'DZ_SWAGGER3_SERVER_PARENT_MAP'
         ,'DZ_SWAGGER3_SERVER'
         ,'DZ_SWAGGER3_PATH'
         ,'DZ_SWAGGER3_PARM_PARENT_MAP'
         ,'DZ_SWAGGER3_PARM'
         ,'DZ_SWAGGER3_OPERATION'
         ,'DZ_SWAGGER3_OPERATION_RESP_MAP'
         ,'DZ_SWAGGER3_OPERATION_TAG_MAP'
         ,'DZ_SWAGGER3_RESPONSE'
         ,'DZ_SWAGGER3_MEDIA_PARENT_MAP'
         ,'DZ_SWAGGER3_MEDIA'
         ,'DZ_SWAGGER3_SCHEMA'
         ,'DZ_SWAGGER3_SCHEMA_PROP_MAP'
         ,'DZ_SWAGGER3_PROPERTY'
         ,'DZ_SWAGGER3_REQUESTBODY'
         ,'DZ_SWAGGER3_EXAMPLE'
         ,'DZ_SWAGGER3_ENCODING'
         ,'DZ_SWAGGER3_LINK'
         ,'DZ_SWAGGER3_HEADER'
         ,'DZ_SWAGGER3_EXTERNALDOC'
         ,'DZ_SWAGGER3_SECURITYSCHEME'
         ,'DZ_SWAGGER3_TAG'
         ,'DZ_SWAGGER3_CONDENSE'
      );
   
   END dz_swagger3_table_list;

END dz_swagger3_setup;
/

