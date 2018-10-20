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
              || '    doc_id               VARCHAR2(255 Char) NOT NULL '
              || '   ,info_title           VARCHAR2(255 Char) NOT NULL '
              || '   ,info_description     VARCHAR2(4000 Char) '
              || '   ,info_termsofservice  VARCHAR2(255 Char) '
              || '   ,info_contact_name    VARCHAR2(255 Char) '
              || '   ,info_contact_url     VARCHAR2(255 Char) '
              || '   ,info_contact_email   VARCHAR2(255 Char) '
              || '   ,info_license_name    VARCHAR2(255 Char) '
              || '   ,info_license_url     VARCHAR2(255 Char) '
              || '   ,info_version         VARCHAR2(255 Char) NOT NULL '
              || '   ,info_desc_updated    DATE '
              || '   ,info_desc_author     VARCHAR2(30 Char) '
              || '   ,info_desc_notes      VARCHAR2(255 Char) '
              || '   ,doc_externalDocs_id  VARCHAR2(255 Char) '
              || '   ,is_default           VARCHAR2(5 Char) NOT NULL '
              || '   ,versionid            VARCHAR2(40 Char) NOT NULL '
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
              || '    CHECK (is_default IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_doc_c03 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Build DOC table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_group('
              || '    group_id                  VARCHAR2(255 Char) NOT NULL '
              || '   ,doc_id                    VARCHAR2(255 Char) NOT NULL '
              || '   ,path_id                   VARCHAR2(255 Char) NOT NULL '
              || '   ,path_order                INTEGER NOT NULL '
              || '   ,versionid                 VARCHAR2(40 Char) NOT NULL '
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
      str_sql := 'CREATE TABLE dz_swagger3_parent_server_map('
              || '    parent_id           VARCHAR2(255 Char) NOT NULL '
              || '   ,server_id           VARCHAR2(255 Char) NOT NULL '
              || '   ,versionid           VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_parent_server_map '
              || 'ADD CONSTRAINT dz_swagger3_parent_server_mapk '
              || 'PRIMARY KEY(versionid,parent_id,server_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_parent_server_map '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_parent_server_mc01 '
              || '    CHECK (parent_id = TRIM(parent_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parent_server_mc02 '
              || '    CHECK (server_id = TRIM(server_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parent_server_mc03 '
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
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Build SERVER VARIABLE table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_server_variable('
              || '    server_id              VARCHAR2(255 Char) NOT NULL '
              || '   ,server_var_name        VARCHAR2(255 Char) NOT NULL '
              || '   ,server_var_enum        VARCHAR2(4000 Char) '
              || '   ,server_var_default     VARCHAR2(255 Char) NOT NULL '
              || '   ,server_var_description VARCHAR2(4000 Char) '
              || '   ,server_var_order       INTEGER '
              || '   ,versionid              VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_server_variable '
              || 'ADD CONSTRAINT dz_swagger3_server_variable_pk '
              || 'PRIMARY KEY(versionid,server_id,server_var_name) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_server_variable '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_server_variablec01 '
              || '    CHECK (server_id = TRIM(server_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_server_variablec02 '
              || '    CHECK (server_var_name = TRIM(server_var_name)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_server_variablec03 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Build PATH table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_path('
              || '    path_id                   VARCHAR2(255 Char) NOT NULL '
              || '   ,path_endpoint             VARCHAR2(255 Char) NOT NULL '
              || '   ,path_summary              VARCHAR2(4000 Char) '
              || '   ,path_description          VARCHAR2(4000 Char) '
              || '   ,path_get_operation_id     VARCHAR2(255 Char) '
              || '   ,path_put_operation_id     VARCHAR2(255 Char) '
              || '   ,path_post_operation_id    VARCHAR2(255 Char) '
              || '   ,path_delete_operation_id  VARCHAR2(255 Char) '
              || '   ,path_options_operation_id VARCHAR2(255 Char) '
              || '   ,path_head_operation_id    VARCHAR2(255 Char) '
              || '   ,path_patch_operation_id   VARCHAR2(255 Char) '
              || '   ,path_trace_operation_id   VARCHAR2(255 Char) '
              || '   ,path_desc_updated         DATE '
              || '   ,path_desc_author          VARCHAR2(30 Char) '
              || '   ,path_desc_notes           VARCHAR2(255 Char) '
              || '   ,versionid                 VARCHAR2(40 Char) NOT NULL '
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
      -- Step 90
      -- Build PARENT_TO_PARM table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_parent_parm_map('
              || '    parent_id              VARCHAR2(255 Char) NOT NULL '
              || '   ,parameter_id           VARCHAR2(255 Char) NOT NULL '
              || '   ,parameter_order        INTEGER NOT NULL '
              || '   ,versionid              VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_parent_parm_map '
              || 'ADD CONSTRAINT dz_swagger3_parent_parm_map_pk '
              || 'PRIMARY KEY(versionid,parent_id,parameter_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_parent_parm_map '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_parent_parm_mapc01 '
              || '    CHECK (parent_id = TRIM(parent_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parent_parm_mapc02 '
              || '    CHECK (parameter_id = TRIM(parameter_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parent_parm_mapc03 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Build PARM table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_parameter('
              || '    parameter_id              VARCHAR2(255 Char) NOT NULL '
              || '   ,parameter_name            VARCHAR2(255 Char) NOT NULL '
              || '   ,parameter_in              VARCHAR2(255 Char) NOT NULL '
              || '   ,parameter_description     VARCHAR2(4000 Char) '
              || '   ,parameter_required        VARCHAR2(5 Char) '
              || '   ,parameter_deprecated      VARCHAR2(5 Char) '
              || '   ,parameter_allowEmptyValue VARCHAR2(5 Char) '
              || '   ,parameter_style           VARCHAR2(255 Char) '
              || '   ,parameter_explode         VARCHAR2(5 Char) '
              || '   ,parameter_allowReserved   VARCHAR2(5 Char) '
              || '   ,parameter_schema_id       VARCHAR2(255 Char) '
              || '   ,parameter_example_string  VARCHAR2(255 Char) '
              || '   ,parameter_example_number  NUMBER '
              || '   ,parameter_content         VARCHAR2(255 Char) '
              || '   ,parameter_force_inline    VARCHAR2(5 Char) '
              || '   ,parameter_list_hidden     VARCHAR2(5 Char) '
              || '   ,parameter_desc_updated    DATE '
              || '   ,parameter_desc_author     VARCHAR2(30 Char) '
              || '   ,parameter_desc_notes      VARCHAR2(255 Char) '
              || '   ,versionid                 VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_parameter '
              || 'ADD CONSTRAINT dz_swagger3_parameter_pk '
              || 'PRIMARY KEY(versionid,parameter_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_parameter '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_parameter_c01 '
              || '    CHECK (parameter_required IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parameter_c02 '
              || '    CHECK (parameter_deprecated IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parameter_c03 '
              || '    CHECK (parameter_allowEmptyValue IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parameter_c04 '
              || '    CHECK (parameter_explode IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parameter_c05 '
              || '    CHECK (parameter_allowReserved IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parameter_c06 '
              || '    CHECK (parameter_id = TRIM(parameter_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parameter_c07 '
              || '    CHECK (parameter_name = TRIM(parameter_name)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parameter_c08 '
              || '    CHECK (parameter_undocumented IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parameter_c09 '
              || '    CHECK (parameter_force_inline IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parameter_c10 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Build OPERATION table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_operation('
              || '    operation_id              VARCHAR2(255 Char) NOT NULL '
              || '   ,operation_type            VARCHAR2(255 Char) NOT NULL '
              || '   ,operation_summary         VARCHAR2(4000 Char) '
              || '   ,operation_description     VARCHAR2(4000 Char) '
              || '   ,operation_externalDocs_id VARCHAR2(255 Char) '
              || '   ,operation_operationID     VARCHAR2(255 Char) '
              || '   ,operation_requestBody_id  VARCHAR2(255 Char) '
              || '   ,operation_inline_rb       VARCHAR2(5 Char) '
              || '   ,operation_deprecated      VARCHAR2(5 Char) '
              || '   ,operation_security_id     VARCHAR2(255 Char) '
              || '   ,operation_desc_updated    DATE '
              || '   ,operation_desc_author     VARCHAR2(30 Char) '
              || '   ,operation_desc_notes      VARCHAR2(255 Char) '
              || '   ,versionid                 VARCHAR2(40 Char) NOT NULL '
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
              || '    CHECK (operation_type IN (''get'',''put'',''post'',''delete'',''options'',''head'',''patch'',''trace'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_c03 '
              || '    CHECK (operation_operationID = TRIM(operation_operationID)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_c04 '
              || '    CHECK (operation_force_rb_inline IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_c05 '
              || '    CHECK (operation_deprecated IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_c06 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Build OPERATION REPONSE MAP table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_operation_resp_map('
              || '    operation_id        VARCHAR2(255 Char) NOT NULL '
              || '   ,response_code       VARCHAR2(255 Char) NOT NULL '
              || '   ,response_id         VARCHAR2(255 Char) NOT NULL '
              || '   ,response_order      INTEGER '
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
      -- Step 130
      -- Build OPERATION REPONSE MAP table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_operation_call_map('
              || '    operation_id        VARCHAR2(255 Char) NOT NULL '
              || '   ,callback_name       VARCHAR2(255 Char) NOT NULL '
              || '   ,callback_id         VARCHAR2(255 Char) NOT NULL '
              || '   ,callback_order      INTEGER '
              || '   ,versionid           VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_operation_call_map '
              || 'ADD CONSTRAINT dz_swagger3_operation_call_mpk '
              || 'PRIMARY KEY(versionid,operation_id,callback_name,callback_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_operation_call_map '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_operation_call_c01 '
              || '    CHECK (operation_id = TRIM(operation_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_call_c02 '
              || '    CHECK (callback_name = TRIM(callback_name)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_call_c03 '
              || '    CHECK (callback_id = TRIM(callback_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_call_c04 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 140
      -- Build REQUESTBODY table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_requestbody('
              || '    requestbody_id            VARCHAR2(255 Char) NOT NULL '
              || '   ,requestbody_description   VARCHAR2(4000 Char) '
              || '   ,requestbody_required      VARCHAR2(5 Char) '
              || '   ,requestbody_force_inline  VARCHAR2(5 Char) '
              || '   ,versionid                 VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_requestbody '
              || 'ADD CONSTRAINT dz_swagger3_requestbody_pk '
              || 'PRIMARY KEY(versionid,requestbody_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_requestbody '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_requestbody_c01 '
              || '    CHECK (requestbody_id = TRIM(requestbody_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_requestbody_c02 '
              || '    CHECK (requestbody_required IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_requestbody_c03 '
              || '    CHECK (requestbody_force_inline IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_requestbody_c04 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 150
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
      -- Step 160
      -- Build RESPONSE table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_response('
              || '    response_id           VARCHAR2(255 Char) NOT NULL '
              || '   ,response_description  VARCHAR2(255 Char) NOT NULL '
              || '   ,response_force_inline VARCHAR2(5 Char) '
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
              || '    CHECK (response_force_inline IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_response_c03 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 170
      -- Build MEDIA TO PARENT table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_parent_media_map('
              || '    parent_id           VARCHAR2(255 Char) NOT NULL '
              || '   ,media_type          VARCHAR2(255 Char) NOT NULL '
              || '   ,media_id            VARCHAR2(255 Char) NOT NULL '
              || '   ,media_order         INTEGER '
              || '   ,versionid           VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_parent_media_map '
              || 'ADD CONSTRAINT dz_swagger3_parent_media_mappk '
              || 'PRIMARY KEY(versionid,parent_id,media_type,media_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_parent_media_map '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_parent_media_mac01 '
              || '    CHECK (parent_id = TRIM(parent_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parent_media_mac02 '
              || '    CHECK (media_type = TRIM(media_type)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parent_media_mac03 '
              || '    CHECK (media_id = TRIM(media_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parent_media_mac04 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 180
      -- Build MEDIA table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_media('
              || '    media_id              VARCHAR2(255 Char) NOT NULL '
              || '   ,media_schema_id       VARCHAR2(255 Char) NOT NULL '
              || '   ,media_example_string  VARCHAR2(4000 Char) '
              || '   ,media_example_number  NUMBER '
              || '   ,versionid             VARCHAR2(40 Char) NOT NULL '
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
      -- Step 190
      -- Build SCHEMA table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_schema('
              || '    schema_id                VARCHAR2(255 Char) NOT NULL '
              || '   ,schema_category          VARCHAR2(255 Char) '
              || '   ,schema_title             VARCHAR2(255 Char) '
              || '   ,schema_type              VARCHAR2(255 Char) '
              || '   ,schema_description       VARCHAR2(4000 Char) '
              || '   ,schema_format            VARCHAR2(255 Char) '
              || '   ,schema_nullable          VARCHAR2(5 Char) '
              || '   ,schema_discriminator     VARCHAR2(255 Char) '
              || '   ,schema_readOnly          VARCHAR2(5 Char) '
              || '   ,schema_writeOnly         VARCHAR2(5 Char) '
              || '   ,schema_externalDocs_id   VARCHAR2(255 Char) '
              || '   ,schema_example_string    VARCHAR2(255 Char) '
              || '   ,schema_example_number    NUMBER '
              || '   ,schema_deprecated        VARCHAR2(5 Char) '
              || '   ,schema_items_schema_id   VARCHAR2(255 Char) '
              || '   ,schema_default_string    VARCHAR2(255 Char) '
              || '   ,schema_default_number    NUMBER '
              || '   ,schema_multipleOf        NUMBER '
              || '   ,schema_minimum           NUMBER '
              || '   ,schema_exclusiveMinimum  VARCHAR2(5 Char) '
              || '   ,schema_maximum           NUMBER '
              || '   ,schema_exclusiveMaximum  VARCHAR2(5 Char) '
              || '   ,schema_minLength         INTEGER '
              || '   ,schema_maxLength         INTEGER '
              || '   ,schema_pattern           VARCHAR2(4000 Char) '
              || '   ,schema_minItems          INTEGER '
              || '   ,schema_maxItems          INTEGER '
              || '   ,schema_uniqueItems       VARCHAR2(5 Char) '
              || '   ,schema_minProperties     INTEGER '
              || '   ,schema_maxProperties     INTEGER '
              || '   ,xml_name                 VARCHAR2(255 Char) '
              || '   ,xml_namespace            VARCHAR2(2000 Char) '
              || '   ,xml_prefix               VARCHAR2(255 Char) '
              || '   ,xml_attribute            VARCHAR2(5 Char) '
              || '   ,xml_wrapped              VARCHAR2(5 Char) '
              || '   ,schema_force_inline      VARCHAR2(5 Char) '
              || '   ,property_list_hidden     VARCHAR2(5 Char) '
              || '   ,schema_desc_updated      DATE '
              || '   ,schema_desc_author       VARCHAR2(30 Char) '
              || '   ,schema_desc_notes        VARCHAR2(255 Char) '
              || '   ,versionid                VARCHAR2(40 Char) NOT NULL '
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
              || '    CHECK (schema_category IN (''object'',''combine'',''array'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c03 '
              || '    CHECK (schema_nullable IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c04 '
              || '    CHECK (schema_readOnly IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c05 '
              || '    CHECK (schema_writeOnly IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c06 '
              || '    CHECK (schema_externalDocs_id = TRIM(schema_externalDocs_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c07 '
              || '    CHECK (schema_deprecated IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c08 '
              || '    CHECK (schema_items_schema_id = TRIM(schema_items_schema_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c09 '
              || '    CHECK (schema_exclusiveMinimum IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c10 '
              || '    CHECK (schema_exclusiveMaximum IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c11 '
              || '    CHECK (schema_uniqueItems IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c12 '
              || '    CHECK (xml_attribute IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c13 '
              || '    CHECK (xml_wrapped IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c14 '
              || '    CHECK (schema_force_inline IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c15 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 200
      -- Build SCHEMA PROPERTY MAP table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_schema_prop_map('
              || '    parent_schema_id         VARCHAR2(255 Char) NOT NULL '
              || '   ,property_name            VARCHAR2(255 Char) NOT NULL '
              || '   ,property_schema_id       VARCHAR2(255 Char) NOT NULL '
              || '   ,property_order           INTEGER NOT NULL '
              || '   ,property_required        VARCHAR2(5 Char) '
              || '   ,versionid                VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_schema_prop_map '
              || 'ADD CONSTRAINT dz_swagger3_schema_prop_mappk '
              || 'PRIMARY KEY(versionid,parent_schema_id,property_name) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_schema_prop_map '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_schema_prop_mapc01 '
              || '    CHECK (parent_schema_id = TRIM(parent_schema_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_prop_mapc02 '
              || '    CHECK (property_name = TRIM(property_name)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_prop_mapc03 '
              || '    CHECK (property_schema_id = TRIM(property_schema_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_prop_mapc04 '
              || '    CHECK (property_required IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_prop_mapc05 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 210
      -- Build SCHEMA ENUM MAP table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_schema_enum_map('
              || '    schema_id                VARCHAR2(255 Char) NOT NULL '
              || '   ,enum_string              VARCHAR2(255 Char) '
              || '   ,enum_number              NUMBER '
              || '   ,enum_order               INTEGER '
              || '   ,versionid                VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_schema_enum_map '
              || 'ADD CONSTRAINT dz_swagger3_schema_enum_mappk '
              || 'PRIMARY KEY(versionid,schema_id,enum_order) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_schema_enum_map '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_schema_enum_mapc01 '
              || '    CHECK (schema_id = TRIM(schema_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_enum_mapc02 '
              || '    CHECK (enum_string = TRIM(enum_string)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_enum_mapc03 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 220
      -- Build SCHEMA COMBO MAP table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_schema_combine_map('
              || '    schema_id                VARCHAR2(255 Char) NOT NULL '
              || '   ,combine_keyword          VARCHAR2(16 Char) NOT NULL '
              || '   ,combine_schema_id        VARCHAR2(255 Char) NOT NULL '
              || '   ,combine_order            INTEGER '
              || '   ,versionid                VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_schema_combine_map '
              || 'ADD CONSTRAINT dz_swagger3_schema_combine_mpk '
              || 'PRIMARY KEY(versionid,schema_id,combine_keyword,combine_schema_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_schema_combine_map '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_schema_combine_c01 '
              || '    CHECK (schema_id = TRIM(schema_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_combine_c02 '
              || '    CHECK (combine_keyword = TRIM(combine_keyword)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_combine_c03 '
              || '    CHECK (combine_schema_id = TRIM(combine_schema_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_combine_c04 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
 
      --------------------------------------------------------------------------
      -- Step 230
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
      -- Step 240
      -- Build PARENT EXAMPLE MAP table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_parent_example_map('
              || '    parent_id                VARCHAR2(255 Char) NOT NULL '
              || '   ,example_name             VARCHAR2(255 Char) NOT NULL '
              || '   ,example_id               VARCHAR2(255 Char) NOT NULL '
              || '   ,example_order            INTEGER '
              || '   ,versionid                VARCHAR2(255 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_parent_example_map '
              || 'ADD CONSTRAINT dz_swagger3_parent_example_mpk '
              || 'PRIMARY KEY(versionid,parent_id,example_name,example_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_parent_example_map '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_parent_example_c01 '
              || '    CHECK (parent_id = TRIM(parent_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parent_example_c02 '
              || '    CHECK (example_name = TRIM(example_name)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parent_example_c03 '
              || '    CHECK (example_id = TRIM(example_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parent_example_c04 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
  
      --------------------------------------------------------------------------
      -- Step 250
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
      -- Step 260
      -- Build MEDIA ENCODING MAP table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_media_encoding_map('
              || '    media_id            VARCHAR2(255 Char) NOT NULL '
              || '   ,encoding_name       VARCHAR2(255 Char) NOT NULL '
              || '   ,encoding_id         VARCHAR2(255 Char) NOT NULL '
              || '   ,encoding_order      INTEGER '
              || '   ,versionid           VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_media_encoding_map '
              || 'ADD CONSTRAINT dz_swagger3_media_encoding_mpk '
              || 'PRIMARY KEY(versionid,media_id,encoding_name,encoding_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_media_encoding_map '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_media_encoding_c01 '
              || '    CHECK (media_id = TRIM(media_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_media_encoding_c02 '
              || '    CHECK (encoding_name = TRIM(encoding_name)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_media_encoding_c03 '
              || '    CHECK (encoding_id = TRIM(encoding_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_media_encoding_c04 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 270
      -- Build LINK table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_link('
              || '    link_id                VARCHAR2(255 Char) NOT NULL '
              || '   ,link_operationRef      VARCHAR2(255 Char) '
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
      -- Step 280
      -- Build HEADER table
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
              || '   ,header_schema_id       VARCHAR2(255 Char) '
              || '   ,header_example_string  VARCHAR2(255 Char) '
              || '   ,header_example_number  NUMBER '
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
      -- Step 290
      -- Build RESPONSE HEADER MAP table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_response_headr_map('
              || '    response_id              VARCHAR2(255 Char) NOT NULL '
              || '   ,header_name              VARCHAR2(255 Char) NOT NULL '
              || '   ,header_id                VARCHAR2(255 Char) NOT NULL '
              || '   ,header_order             INTEGER '
              || '   ,versionid                VARCHAR2(255 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_response_headr_map '
              || 'ADD CONSTRAINT dz_swagger3_response_headr_mpk '
              || 'PRIMARY KEY(versionid,response_id,header_name,header_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_response_headr_map '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_response_headr_c01 '
              || '    CHECK (response_id = TRIM(response_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_response_headr_c02 '
              || '    CHECK (header_name = TRIM(header_name)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_response_headr_c03 '
              || '    CHECK (header_id = TRIM(header_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_response_headr_c04 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 300
      -- Build RESPONSE LINK MAP table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_response_link_map('
              || '    response_id              VARCHAR2(255 Char) NOT NULL '
              || '   ,link_name                VARCHAR2(255 Char) NOT NULL '
              || '   ,link_id                  VARCHAR2(255 Char) NOT NULL '
              || '   ,link_order               INTEGER '
              || '   ,versionid                VARCHAR2(255 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_response_link_map '
              || 'ADD CONSTRAINT dz_swagger3_response_link_mapk '
              || 'PRIMARY KEY(versionid,response_id,link_name,link_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_response_link_map '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_response_link_mc01 '
              || '    CHECK (response_id = TRIM(response_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_response_link_mc02 '
              || '    CHECK (link_name = TRIM(link_name)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_response_link_mc03 '
              || '    CHECK (link_id = TRIM(link_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_response_link_mc04 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 310
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
      -- Step 320
      -- Build SECURITY SCHEME table
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
      -- Step 330
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
              || '   ,CONSTRAINT dz_swagger3_tag_c03 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 340
      -- Build CACHE table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_cache('
              || '    doc_id               VARCHAR2(255 Char) NOT NULL '
              || '   ,group_id             VARCHAR2(255 Char) NOT NULL '
              || '   ,json_payload         CLOB '
              || '   ,json_pretty_payload  CLOB '
              || '   ,yaml_payload         CLOB '
              || '   ,extraction_timestamp TIMESTAMP '
              || '   ,shorten_logic        VARCHAR2(255 Char) '
              || '   ,versionid            VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_cache '
              || 'ADD CONSTRAINT dz_swagger3_cache_pk '
              || 'PRIMARY KEY(versionid,doc_id,group_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;

      --------------------------------------------------------------------------
      -- Step 350
      -- Build COMPONENTS table
      --------------------------------------------------------------------------
      str_sql := 'CREATE GLOBAL TEMPORARY TABLE dz_swagger3_components('
              || '    object_id            VARCHAR2(255 Char) '
              || '   ,object_type          VARCHAR2(255 Char) '
              || '   ,hash_key             VARCHAR2(255 Char) '
              || '   ,schema_required      VARCHAR2(5 Char) '
              || '   ,response_code        VARCHAR2(255 Char)'
              || '   ,short_id             VARCHAR2(255 Char) '
              || ') '
              || 'ON COMMIT PRESERVE ROWS ';
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_components '
              || 'ADD CONSTRAINT dz_swagger3_components_pk '
              || 'PRIMARY KEY(object_type,object_id) ';
      
      EXECUTE IMMEDIATE str_sql;
      
   END create_storage_tables;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dz_swagger3_table_list
   RETURN MDSYS.SDO_STRING2_ARRAY
   AS
   
   BEGIN
   
      RETURN MDSYS.SDO_STRING2_ARRAY(
          'DZ_SWAGGER3_CACHE'
         ,'DZ_SWAGGER3_DOC'
         ,'DZ_SWAGGER3_ENCODING'
         ,'DZ_SWAGGER3_EXAMPLE'
         ,'DZ_SWAGGER3_EXTERNALDOC'
         ,'DZ_SWAGGER3_GROUP'
         ,'DZ_SWAGGER3_HEADER'
         ,'DZ_SWAGGER3_LINK'
         ,'DZ_SWAGGER3_MEDIA'
         ,'DZ_SWAGGER3_MEDIA_ENCODING_MAP'
         ,'DZ_SWAGGER3_OPERATION'
         ,'DZ_SWAGGER3_OPERATION_CALL_MAP'
         ,'DZ_SWAGGER3_OPERATION_RESP_MAP'
         ,'DZ_SWAGGER3_OPERATION_TAG_MAP'
         ,'DZ_SWAGGER3_PARAMETER'
         ,'DZ_SWAGGER3_PARENT_EXAMPLE_MAP'
         ,'DZ_SWAGGER3_PARENT_MEDIA_MAP'
         ,'DZ_SWAGGER3_PARENT_PARM_MAP'
         ,'DZ_SWAGGER3_PARENT_SERVER_MAP' 
         ,'DZ_SWAGGER3_PATH'
         ,'DZ_SWAGGER3_REQUESTBODY'
         ,'DZ_SWAGGER3_RESPONSE'
         ,'DZ_SWAGGER3_RESPONSE_HEADR_MAP'
         ,'DZ_SWAGGER3_RESPONSE_LINK_MAP'
         ,'DZ_SWAGGER3_SCHEMA'
         ,'DZ_SWAGGER3_SCHEMA_COMBINE_MAP'
         ,'DZ_SWAGGER3_SCHEMA_ENUM_MAP'
         ,'DZ_SWAGGER3_SCHEMA_PROP_MAP'
         ,'DZ_SWAGGER3_SECURITYSCHEME'
         ,'DZ_SWAGGER3_SERVER'
         ,'DZ_SWAGGER3_SERVER_VARIABLE'
         ,'DZ_SWAGGER3_TAG'
         ,'DZ_SWAGGER3_VERS'
      );
   
   END dz_swagger3_table_list;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION is_valid
   RETURN MDSYS.SDO_STRING2_ARRAY PIPELINED
   AS
      str_sql     VARCHAR2(32000 Char);
      str_check   VARCHAR2(255 Char);
      ary_results MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
   
      str_sql := 'SELECT '
              || 'a.schema_id '
              || 'FROM '
              || 'dz_swagger3_schema a '
              || 'WHERE '
              || 'a.schema_items_schema_id NOT IN ('
              || '   SELECT '
              || '   b.schema_id '
              || '   FROM '
              || '   dz_swagger3_schema b '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql
      BULK COLLECT INTO ary_results;
      
      IF ary_results IS NULL
      OR ary_results.COUNT > 0
      THEN
         FOR i IN 1 .. ary_results.COUNT
         LOOP
            PIPE ROW('schema - bad items array; ' || ary_results(i));
            
         END LOOP;
      
      END IF;
      
      str_sql := 'SELECT '
              || 'a.property_schema_id '
              || 'FROM '
              || 'dz_swagger3_schema_prop_map a '
              || 'WHERE '
              || 'a.property_schema_id NOT IN ('
              || '   SELECT '
              || '   b.schema_id '
              || '   FROM '
              || '   dz_swagger3_schema b '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql
      BULK COLLECT INTO ary_results;
      
      IF ary_results IS NULL
      OR ary_results.COUNT > 0
      THEN
         FOR i IN 1 .. ary_results.COUNT
         LOOP
            PIPE ROW('schema - bad property schema; ' || ary_results(i));
            
         END LOOP;
      
      END IF;
      
      str_sql := 'SELECT '
              || 'a.parent_schema_id '
              || 'FROM '
              || 'dz_swagger3_schema_prop_map a '
              || 'WHERE '
              || 'a.parent_schema_id NOT IN ('
              || '   SELECT '
              || '   b.schema_id '
              || '   FROM '
              || '   dz_swagger3_schema b '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql
      BULK COLLECT INTO ary_results;
      
      IF ary_results IS NULL
      OR ary_results.COUNT > 0
      THEN
         FOR i IN 1 .. ary_results.COUNT
         LOOP
            PIPE ROW('schema - bad property parent; ' || ary_results(i));
            
         END LOOP;
      
      END IF;
      
      RETURN;
   
   END is_valid;

END dz_swagger3_setup;
/

/*
BEGIN
   dz_swagger3_setup.create_storage_tables();
   
END;
/

*/

