CREATE OR REPLACE PACKAGE dz_swagger3_constants
AUTHID DEFINER
AS
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   /*
   Header: DZ_SWAGGER3
     
   - Build ID: DZBUILDIDDZ
   - Change Set: DZCHANGESETDZ
   
   PLSQL module for the creation, storage and production of Open API 3.0 service 
   definitions.   Support for the unloading of Swagger JSON specifications into
   the storage tables is not currently supported.   
   
   */
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   /*
   Constant: dz_swagger3_constants.c_table_tablespace
      Tablespace in which to store table resources created by dz_swagger3. Leave
      NULL to use the schema default
   */
   c_table_tablespace  CONSTANT VARCHAR2(40 Char) := NULL;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   /*
   Constant: dz_swagger3_constants.c_index_tablespace
      Tablespace in which to store index resources created by dz_swagger3. Leave
      NULL to use the schema default
   */
   c_index_tablespace  CONSTANT VARCHAR2(40 Char) := NULL;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   /*
   Constant: dz_swagger3_constants.c_openapi_version
      Sematic version number of the OpenAPI Specification version used by the 
      package.
   */
   c_openapi_version  CONSTANT VARCHAR2(16 Char) := '3.0.0';

END dz_swagger3_constants;
/

GRANT EXECUTE ON dz_swagger3_constants TO PUBLIC;

CREATE OR REPLACE PACKAGE dz_swagger3_util
AUTHID DEFINER
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION get_guid
   RETURN VARCHAR2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION yamlq(
       p_input        IN  VARCHAR2
   ) RETURN VARCHAR2;
  
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION yaml_text(
       p_input        IN  VARCHAR2 
      ,p_pretty_print IN  NUMBER DEFAULT 0
   ) RETURN VARCHAR2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION yaml_text(
       p_input        IN  NUMBER 
      ,p_pretty_print IN  NUMBER DEFAULT 0
   ) RETURN VARCHAR2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION yaml_text(
       p_input        IN  BOOLEAN
      ,p_pretty_print IN  NUMBER DEFAULT 0
   ) RETURN VARCHAR2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION utl_url_escape(
       p_input_url       IN VARCHAR2 CHARACTER SET ANY_CS
      ,p_escape_reserved IN VARCHAR2 DEFAULT NULL
      ,p_url_charset     IN VARCHAR2 DEFAULT NULL
   )  RETURN VARCHAR2 CHARACTER SET p_input_url%CHARSET;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION a_in_b(
       p_input_a          IN VARCHAR2
      ,p_input_b          IN MDSYS.SDO_STRING2_ARRAY
   ) RETURN VARCHAR2 DETERMINISTIC;
 
 END dz_swagger3_util;
/

GRANT EXECUTE ON dz_swagger3_util TO public;

CREATE OR REPLACE PACKAGE BODY dz_swagger3_util
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION get_guid
   RETURN VARCHAR2
   AS
      str_sysguid VARCHAR2(40 Char);
      
   BEGIN
   
      str_sysguid := UPPER(RAWTOHEX(SYS_GUID()));
      
      RETURN '{' 
         || SUBSTR(str_sysguid,1,8)  || '-'
         || SUBSTR(str_sysguid,9,4)  || '-'
         || SUBSTR(str_sysguid,13,4) || '-'
         || SUBSTR(str_sysguid,17,4) || '-'
         || SUBSTR(str_sysguid,21,12)|| '}';
   
   END get_guid;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION yaml_quote(
       p_input        IN  VARCHAR2
   ) RETURN VARCHAR2
   AS
   BEGIN
      
      IF INSTR(p_input,CHR(10)) > 0
      OR INSTR(p_input,CHR(13)) > 0
      THEN
         RETURN 'multiline';
         
      -- Smells like JSON?
      ELSIF ( REGEXP_LIKE(p_input,'^\[') AND REGEXP_LIKE(p_input,'\"+') AND REGEXP_LIKE(p_input,'\]$') )
      OR    ( REGEXP_LIKE(p_input,'^\{') AND REGEXP_LIKE(p_input,'\"+') AND REGEXP_LIKE(p_input,'\}$') )
      THEN
         RETURN 'single';
      
      ELSIF REGEXP_LIKE(p_input,'\:|\?|\]|\[|\"|\''|\&|\%|\$')
      THEN
         RETURN 'double';
         
      ELSIF REGEXP_LIKE(p_input,'^[-[:digit:],.]+$')
      OR LOWER(p_input) IN ('true','false') 
      OR INSTR(p_input,'#') = 1     
      THEN
         RETURN 'single';
         
      ELSE
         RETURN 'bare';
         
      END IF;
   
   END yaml_quote;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION yamlq(
       p_input        IN  VARCHAR2
   ) RETURN VARCHAR2
   AS
      str_format  VARCHAR2(4000 Char);
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10 
      -- Determine what format to use
      --------------------------------------------------------------------------
      str_format := yaml_quote(p_input);
      
      --------------------------------------------------------------------------
      -- Step 20 
      -- Return with or without quotes as needed
      --------------------------------------------------------------------------
      IF str_format = 'single'
      THEN
         RETURN '''' || p_input || '''';
         
      ELSIF str_format = 'double'
      THEN
         RETURN '"' || p_input || '"';
         
      ELSE
         RETURN p_input;
      
      END IF;
   
   END yamlq;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION yaml_text(
       p_input        IN  VARCHAR2 
      ,p_pretty_print IN  NUMBER DEFAULT 0
   ) RETURN VARCHAR2
   AS
      str_output  VARCHAR2(32000 Char) := p_input;
      str_format  VARCHAR2(4000 Char);
      ary_strings MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10 
      -- Determine what format to use
      --------------------------------------------------------------------------
      str_format := yaml_quote(p_input);
      
      --------------------------------------------------------------------------
      -- Step 20 
      -- Process bare strings
      --------------------------------------------------------------------------
      IF str_format = 'bare'
      THEN
         RETURN str_output;
         
      --------------------------------------------------------------------------
      -- Step 30 
      -- Process single quoted strings
      --------------------------------------------------------------------------
      ELSIF str_format = 'single'
      THEN
         str_output := REGEXP_REPLACE(str_output,'''','''''');
         
         RETURN '''' || str_output || '''';
         
      --------------------------------------------------------------------------
      -- Step 40 
      -- Process double quoted strings
      --------------------------------------------------------------------------
      ELSIF str_format = 'double'
      THEN
         str_output := REGEXP_REPLACE(str_output,CHR(13),'');
         
         str_output := REGEXP_REPLACE(str_output,'"','\"');
         
         RETURN '"' || str_output || '"';
      
      --------------------------------------------------------------------------
      -- Step 50 
      -- Process bar indented strings
      --------------------------------------------------------------------------
      ELSIF str_format = 'multiline'
      THEN
         str_output := REGEXP_REPLACE(str_output,CHR(13),'');
         
         str_output := REGEXP_REPLACE(
             str_output
            ,CHR(10) || CHR(10)
            ,CHR(10) || ' ' || CHR(10)
         );
         
         ary_strings := dz_json_util.gz_split(
             str_output
            ,CHR(10)
         );
         
         str_output := dz_json_util.pretty_str(
             '|-'
            ,0
            ,'  '
         );
         
         FOR i IN 1 .. ary_strings.COUNT
         LOOP
            IF i < ary_strings.COUNT
            THEN
               str_output := str_output || dz_json_util.pretty_str(
                   ary_strings(i)
                  ,p_pretty_print + 1
                  ,'  '
               );
               
            ELSE
               str_output := str_output || dz_json_util.pretty_str(
                   ary_strings(i)
                  ,p_pretty_print + 1
                  ,'  '
                  ,NULL
               );

            END IF;
         
         END LOOP;
         
         RETURN str_output;
         
      ELSE
         RAISE_APPLICATION_ERROR(-20001,'err');
      
      END IF;

      
   END yaml_text;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION yaml_text(
       p_input        IN  NUMBER 
      ,p_pretty_print IN  NUMBER DEFAULT 0
   ) RETURN VARCHAR2
   AS
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10 
      -- Simple override
      --------------------------------------------------------------------------
      RETURN TO_CHAR(p_input);

      
   END yaml_text;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION yaml_text(
       p_input        IN  BOOLEAN 
      ,p_pretty_print IN  NUMBER DEFAULT 0
   ) RETURN VARCHAR2
   AS
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10 
      -- Simple override
      --------------------------------------------------------------------------
      IF p_input
      THEN
         RETURN 'true';
         
      ELSE
         RETURN 'false';
         
      END IF;

   END yaml_text;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION utl_url_escape(
       p_input_url       IN VARCHAR2 CHARACTER SET ANY_CS
      ,p_escape_reserved IN VARCHAR2 DEFAULT NULL
      ,p_url_charset     IN VARCHAR2 DEFAULT NULL
   )  RETURN VARCHAR2 CHARACTER SET p_input_url%CHARSET
   AS
      str_escape_reserved VARCHAR2(4000 Char) := UPPER(p_escape_reserved);
      boo_escape_reserved BOOLEAN;
      str_url_charset     VARCHAR2(4000 Char) := p_url_charset;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF str_escape_reserved IS NULL
      THEN
         boo_escape_reserved := FALSE;
         
      ELSIF str_escape_reserved = 'TRUE'
      THEN
         boo_escape_reserved := TRUE;
         
      ELSIF str_escape_reserved = 'FALSE'
      THEN
         boo_escape_reserved := FALSE;
         
      ELSE
         RAISE_APPLICATION_ERROR(-20001,'boolean error');
         
      END IF;
      
      IF str_url_charset IS NULL
      THEN
         str_url_charset := utl_http.get_body_charset;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Return results
      --------------------------------------------------------------------------
      RETURN SYS.UTL_URL.ESCAPE(
          p_input_url
         ,boo_escape_reserved
         ,str_url_charset
      );
      
   END utl_url_escape;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION a_in_b(
       p_input_a          IN VARCHAR2
      ,p_input_b          IN MDSYS.SDO_STRING2_ARRAY
   ) RETURN VARCHAR2 DETERMINISTIC
   AS
      boo_check BOOLEAN := FALSE;
      
   BEGIN
   
      IF p_input_a IS NULL
      THEN
         RETURN 'FALSE';
         
      END IF;

      IF p_input_b IS NULL
      OR p_input_b.COUNT = 0
      THEN
         RETURN 'FALSE';
         
      END IF;

      FOR i IN 1 .. p_input_b.COUNT
      LOOP
         IF p_input_a = p_input_b(i)
         THEN
            boo_check := TRUE;
            EXIT;
            
         END IF;
         
      END LOOP;

      IF boo_check = TRUE
      THEN
         RETURN 'TRUE';
         
      ELSE
         RETURN 'FALSE';
         
      END IF;
      
   END a_in_b;

END dz_swagger3_util;
/

CREATE OR REPLACE PACKAGE dz_swagger3_setup
AUTHID CURRENT_USER
AS
  
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE create_storage_tables(
       p_table_tablespace VARCHAR2 DEFAULT dz_swagger3_constants.c_table_tablespace
      ,p_index_tablespace VARCHAR2 DEFAULT dz_swagger3_constants.c_index_tablespace
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE create_temp_tables(
       p_table_tablespace VARCHAR2 DEFAULT dz_swagger3_constants.c_table_tablespace
      ,p_index_tablespace VARCHAR2 DEFAULT dz_swagger3_constants.c_index_tablespace
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dz_swagger3_storage_table_list
   RETURN MDSYS.SDO_STRING2_ARRAY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dz_swagger3_temp_table_list
   RETURN MDSYS.SDO_STRING2_ARRAY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION is_valid
   RETURN MDSYS.SDO_STRING2_ARRAY PIPELINED;
 
 END dz_swagger3_setup;
/

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
              || '   ,is_default           VARCHAR2(5 Char)   NOT NULL '
              || '   ,versionid            VARCHAR2(40 Char)  NOT NULL '
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
      -- Build GROUP table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_group('
              || '    group_id                  VARCHAR2(255 Char) NOT NULL '
              || '   ,doc_id                    VARCHAR2(255 Char) NOT NULL '
              || '   ,path_id                   VARCHAR2(255 Char) NOT NULL '
              || '   ,path_order                INTEGER            NOT NULL '
              || '   ,versionid                 VARCHAR2(40 Char)  NOT NULL '
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
      -- Build SERVER MAP table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_parent_server_map('
              || '    parent_id           VARCHAR2(255 Char) NOT NULL '
              || '   ,server_id           VARCHAR2(255 Char) NOT NULL '
              || '   ,server_order        INTEGER            NOT NULL '
              || '   ,versionid           VARCHAR2(40 Char)  NOT NULL '
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
      -- Build SERVER VAR MAP table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_server_var_map('
              || '    server_id              VARCHAR2(255 Char) NOT NULL '
              || '   ,server_var_id          VARCHAR2(255 Char) NOT NULL '
              || '   ,server_var_order       INTEGER            NOT NULL '
              || '   ,versionid              VARCHAR2(40 Char)  NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_server_var_map '
              || 'ADD CONSTRAINT dz_swagger3_server_var_map_pk '
              || 'PRIMARY KEY(versionid,server_id,server_var_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_server_var_map '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_server_var_map_c01 '
              || '    CHECK (server_id = TRIM(server_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_server_var_map_c02 '
              || '    CHECK (server_var_id = TRIM(server_var_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_server_var_map_c03 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Build SERVER VARIABLE table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_server_variable('
              || '    server_var_id          VARCHAR2(255 Char) NOT NULL '
              || '   ,server_var_name        VARCHAR2(255 Char) NOT NULL '
              || '   ,server_var_enum        VARCHAR2(4000 Char) '
              || '   ,server_var_default     VARCHAR2(255 Char) NOT NULL '
              || '   ,server_var_description VARCHAR2(4000 Char) '
              || '   ,versionid              VARCHAR2(40 Char) NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_server_variable '
              || 'ADD CONSTRAINT dz_swagger3_server_variable_pk '
              || 'PRIMARY KEY(versionid,server_var_id) ';
              
      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_server_variable '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_server_variablec01 '
              || '    CHECK (server_var_id = TRIM(server_var_id)) '
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
      -- Step 90
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
      -- Step 100
      -- Build PARENT PARM MAP table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_parent_parm_map('
              || '    parent_id              VARCHAR2(255 Char) NOT NULL '
              || '   ,parameter_id           VARCHAR2(255 Char) NOT NULL '
              || '   ,parameter_order        INTEGER NOT NULL '
              || '   ,requestbody_flag       VARCHAR2(5 Char) '
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
              || '   ,CONSTRAINT dz_swagger3_parent_parm_mapc04 '
              || '    CHECK (requestbody_flag IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 110
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
              || '    CHECK (parameter_force_inline IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parameter_c09 '
              || '    CHECK (parameter_list_hidden IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parameter_c10 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 120
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
              || '    CHECK (operation_inline_rb IN (''TRUE'',''FALSE'')) '
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
      -- Step 130
      -- Build OPERATION REPONSE MAP table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_operation_resp_map('
              || '    operation_id        VARCHAR2(255 Char) NOT NULL '
              || '   ,response_code       VARCHAR2(255 Char) NOT NULL '
              || '   ,response_id         VARCHAR2(255 Char) NOT NULL '
              || '   ,response_order      INTEGER '
              || '   ,versionid           VARCHAR2(40 Char)  NOT NULL '
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
      -- Step 140
      -- Build OPERATION REPONSE MAP table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_operation_call_map('
              || '    operation_id        VARCHAR2(255 Char) NOT NULL '
              || '   ,callback_name       VARCHAR2(255 Char) NOT NULL '
              || '   ,callback_id         VARCHAR2(255 Char) NOT NULL '
              || '   ,callback_order      INTEGER '
              || '   ,versionid           VARCHAR2(40 Char)  NOT NULL '
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
      -- Step 150
      -- Build REQUESTBODY table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_requestbody('
              || '    requestbody_id            VARCHAR2(255 Char) NOT NULL '
              || '   ,requestbody_description   VARCHAR2(4000 Char) '
              || '   ,requestbody_required      VARCHAR2(5 Char) '
              || '   ,requestbody_force_inline  VARCHAR2(5 Char) '
              || '   ,versionid                 VARCHAR2(40 Char)  NOT NULL '
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
      -- Step 160
      -- Build OPERATION TAG MAP table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_operation_tag_map('
              || '    operation_id        VARCHAR2(255 Char) NOT NULL '
              || '   ,tag_id              VARCHAR2(255 Char) NOT NULL '
              || '   ,tag_order           INTEGER            NOT NULL '
              || '   ,versionid           VARCHAR2(40 Char)  NOT NULL '
              || ') ';
              
      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;
      
      END IF;
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_operation_tag_map '
              || 'ADD CONSTRAINT dz_swagger3_operation_tag_mapk '
              || 'PRIMARY KEY(versionid,operation_id,tag_id) ';
              
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
              || '   ,CONSTRAINT dz_swagger3_operation_tag_mc03 '
              || '    CHECK (tag_id = TRIM(tag_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_tag_mc04 '
              || '    CHECK (versionid = TRIM(versionid)) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 170
      -- Build RESPONSE table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_response('
              || '    response_id           VARCHAR2(255 Char) NOT NULL '
              || '   ,response_description  VARCHAR2(255 Char) NOT NULL '
              || '   ,response_force_inline VARCHAR2(5 Char) '
              || '   ,response_desc_updated DATE '
              || '   ,response_desc_author  VARCHAR2(30 Char) '
              || '   ,response_desc_notes   VARCHAR2(255 Char) '
              || '   ,versionid             VARCHAR2(40 Char)  NOT NULL '
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
      -- Step 180
      -- Build MEDIA TO PARENT table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_parent_media_map('
              || '    parent_id           VARCHAR2(255 Char) NOT NULL '
              || '   ,media_type          VARCHAR2(255 Char) NOT NULL '
              || '   ,media_id            VARCHAR2(255 Char) NOT NULL '
              || '   ,media_order         INTEGER '
              || '   ,versionid           VARCHAR2(40 Char)  NOT NULL '
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
      -- Step 190
      -- Build MEDIA table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_media('
              || '    media_id              VARCHAR2(255 Char) NOT NULL '
              || '   ,media_schema_id       VARCHAR2(255 Char) NOT NULL '
              || '   ,media_example_string  VARCHAR2(4000 Char) '
              || '   ,media_example_number  NUMBER '
              || '   ,versionid             VARCHAR2(40 Char)  NOT NULL '
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
      -- Step 200
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
              || '   ,versionid                VARCHAR2(40 Char)  NOT NULL '
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
              || '    CHECK (schema_category IN (''scalar'',''object'',''combine'',''array'')) '
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
              || '   ,CONSTRAINT dz_swagger3_schema_c16 '
              || '    CHECK ( '
              || '          ( schema_type = ''integer'' AND (schema_format IS NULL OR schema_format = ''int32'' OR schema_format = ''int64'')) '
              || '       OR '
              || '          ( schema_type = ''number''  AND (schema_format IS NULL OR schema_format = ''float'' OR schema_format = ''double'')) '
              || '       OR '
              || '          ( schema_type = ''string''  AND (schema_format IS NULL OR schema_format IN (''byte'',''binary'',''date'',''date-time'',''password''))) '
              || '       OR '
              || '          ( schema_type = ''boolean'' AND schema_format IS NULL ) '
              || '       OR '
              || '          ( schema_type = ''object''  AND schema_format IS NULL ) '
              || '       OR '
              || '          ( schema_type = ''array''   AND schema_format IS NULL ) '
              || '       OR '
              || '          ( schema_type IS NULL       AND schema_format IS NULL ) '
              || '    ) '
              || '    ENABLE VALIDATE '
              || ') ';
              
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 210
      -- Build SCHEMA PROPERTY MAP table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_schema_prop_map('
              || '    parent_schema_id         VARCHAR2(255 Char) NOT NULL '
              || '   ,property_name            VARCHAR2(255 Char) NOT NULL '
              || '   ,property_schema_id       VARCHAR2(255 Char) NOT NULL '
              || '   ,property_order           INTEGER NOT NULL '
              || '   ,property_required        VARCHAR2(5 Char) '
              || '   ,versionid                VARCHAR2(40 Char)  NOT NULL '
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
      -- Step 220
      -- Build SCHEMA ENUM MAP table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_schema_enum_map('
              || '    schema_id                VARCHAR2(255 Char) NOT NULL '
              || '   ,enum_string              VARCHAR2(255 Char) '
              || '   ,enum_number              NUMBER '
              || '   ,enum_order               INTEGER '
              || '   ,versionid                VARCHAR2(40 Char)  NOT NULL '
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
      -- Step 230
      -- Build SCHEMA COMBO MAP table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_schema_combine_map('
              || '    schema_id                VARCHAR2(255 Char) NOT NULL '
              || '   ,combine_keyword          VARCHAR2(16 Char)  NOT NULL '
              || '   ,combine_schema_id        VARCHAR2(255 Char) NOT NULL '
              || '   ,combine_order            INTEGER '
              || '   ,versionid                VARCHAR2(40 Char)  NOT NULL '
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
      -- Step 240
      -- Build EXAMPLE table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_example('
              || '    example_id             VARCHAR2(255 Char) NOT NULL '
              || '   ,example_summary        VARCHAR2(255 Char) '
              || '   ,example_description    VARCHAR2(4000 Char) '
              || '   ,example_value_string   VARCHAR2(255 Char) '
              || '   ,example_value_number   NUMBER '
              || '   ,example_externalValue  VARCHAR2(255 Char) '
              || '   ,versionid              VARCHAR2(40 Char)  NOT NULL '
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
      -- Step 250
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
      -- Step 260
      -- Build ENCODING table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_encoding('
              || '    encoding_id            VARCHAR2(255 Char) NOT NULL '
              || '   ,encoding_contentType   VARCHAR2(255 Char) '
              || '   ,encoding_style         VARCHAR2(255 Char) '
              || '   ,encoding_explode       VARCHAR2(5 Char) '
              || '   ,encoding_allowReserved VARCHAR2(5 Char) '
              || '   ,versionid              VARCHAR2(40 Char)  NOT NULL '
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
      -- Step 270
      -- Build MEDIA ENCODING MAP table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_media_encoding_map('
              || '    media_id            VARCHAR2(255 Char) NOT NULL '
              || '   ,encoding_name       VARCHAR2(255 Char) NOT NULL '
              || '   ,encoding_id         VARCHAR2(255 Char) NOT NULL '
              || '   ,encoding_order      INTEGER '
              || '   ,versionid           VARCHAR2(40 Char)  NOT NULL '
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
      -- Step 280
      -- Build LINK table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_link('
              || '    link_id                VARCHAR2(255 Char) NOT NULL '
              || '   ,link_operationRef      VARCHAR2(255 Char) '
              || '   ,link_operationId       VARCHAR2(255 Char) '
              || '   ,link_description       VARCHAR2(4000 Char) '
              || '   ,link_requestBody       VARCHAR2(4000 Char) '
              || '   ,link_server_id         VARCHAR2(255 Char) '
              || '   ,versionid              VARCHAR2(40 Char)  NOT NULL '
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
      -- Step 290
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
              || '   ,versionid              VARCHAR2(40 Char) NOT NULL '
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
      -- Step 300
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
      -- Step 310
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
      -- Step 320
      -- Build EXTERNALDOC table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_externaldoc('
              || '    externaldoc_id           VARCHAR2(255 Char) NOT NULL '
              || '   ,externaldoc_description  VARCHAR2(4000 Char) '
              || '   ,externaldoc_url          VARCHAR2(245 Char) '
              || '   ,versionid                VARCHAR2(40 Char)  NOT NULL '
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
      -- Step 330
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
              || '   ,versionid                   VARCHAR2(40 Char)  NOT NULL '
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
      -- Step 340
      -- Build TAG table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_tag('
              || '    tag_id               VARCHAR2(255 Char) NOT NULL '
              || '   ,tag_name             VARCHAR2(255 Char) NOT NULL '
              || '   ,tag_description      VARCHAR2(4000 Char) '
              || '   ,tag_externalDocs_id  VARCHAR2(255 Char) '
              || '   ,versionid            VARCHAR2(40 Char)  NOT NULL '
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
      -- Step 350
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
              || '   ,versionid            VARCHAR2(40 Char)  NOT NULL '
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
      
   END create_storage_tables;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE create_temp_tables(
       p_table_tablespace VARCHAR2 DEFAULT dz_swagger3_constants.c_table_tablespace
      ,p_index_tablespace VARCHAR2 DEFAULT dz_swagger3_constants.c_index_tablespace
   )
   AS
      str_sql VARCHAR2(4000 Char);
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Build XRELATES table
      --------------------------------------------------------------------------
      str_sql := 'CREATE GLOBAL TEMPORARY TABLE dz_swagger3_xrelates('
              || '    parent_object_id     VARCHAR2(255 Char) NOT NULL '
              || '   ,child_object_id      VARCHAR2(255 Char) NOT NULL '
              || '   ,child_object_type_id VARCHAR2(255 Char) NOT NULL '
              || ') '
              || 'ON COMMIT PRESERVE ROWS ';
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_xrelates '
              || 'ADD CONSTRAINT dz_swagger3_xrelates_pk '
              || 'PRIMARY KEY(parent_object_id,child_object_id) ';
      
      EXECUTE IMMEDIATE str_sql;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build XOBJECTS table
      --------------------------------------------------------------------------
      str_sql := 'CREATE GLOBAL TEMPORARY TABLE dz_swagger3_xobjects('
              || '    object_id            VARCHAR2(255 Char) NOT NULL '
              || '   ,object_type_id       VARCHAR2(255 Char) NOT NULL '
              || '   ,short_id             VARCHAR2(255 Char) '
              || '   ,reference_count      INTEGER '
              || '   ,servertyp            dz_swagger3_server_typ '
              || '   ,servervartyp         dz_swagger3_server_var_typ '
              || '   ,pathtyp              dz_swagger3_path_typ '
              || '   ,operationtyp         dz_swagger3_operation_typ '
              || '   ,parametertyp         dz_swagger3_parameter_typ '
              || '   ,headertyp            dz_swagger3_header_typ '
              || '   ,linktyp              dz_swagger3_link_typ '
              || '   ,requestbodytyp       dz_swagger3_requestBody_typ '
              || '   ,responsetyp          dz_swagger3_response_typ '
              || '   ,mediatyp             dz_swagger3_media_typ '
              || '   ,schematyp            dz_swagger3_schema_typ '
              || '   ,exampletyp           dz_swagger3_example_typ '
              || '   ,extrdocstyp          dz_swagger3_extrdocs_typ '
              || '   ,securityreqtyp       dz_swagger3_security_req_typ '
              || '   ,securityschemetyp    dz_swagger3_securityscheme_typ '
              || '   ,encodingtyp          dz_swagger3_encoding_typ '
              || '   ,tagtyp               dz_swagger3_tag_typ '
              || '   ,stringhashtyp        dz_swagger3_string_hash_typ '
              || ') '
              || 'ON COMMIT PRESERVE ROWS ';
      
      EXECUTE IMMEDIATE str_sql;
      
      str_sql := 'ALTER TABLE dz_swagger3_xobjects '
              || 'ADD CONSTRAINT dz_swagger3_xobjects_pk '
              || 'PRIMARY KEY(object_type_id,object_id) ';
      
      EXECUTE IMMEDIATE str_sql;
   
   END create_temp_tables;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dz_swagger3_storage_table_list
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
         ,'DZ_SWAGGER3_SERVER_VAR_MAP'
         ,'DZ_SWAGGER3_TAG'
         ,'DZ_SWAGGER3_VERS'
      );
   
   END dz_swagger3_storage_table_list;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dz_swagger3_temp_table_list
   RETURN MDSYS.SDO_STRING2_ARRAY
   AS
   
   BEGIN
   
      RETURN MDSYS.SDO_STRING2_ARRAY(
          'DZ_SWAGGER3_XRELATES'
         ,'DZ_SWAGGER3_XOBJECTS'
      );
   
   END dz_swagger3_temp_table_list;
   
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

DECLARE
   int_count NUMBER;
   
BEGIN

   SELECT
   COUNT(*)
   INTO int_count
   FROM
   user_tables a
   WHERE 
   a.table_name IN (
      SELECT * FROM TABLE(dz_swagger3_setup.dz_swagger3_storage_table_list())
   );
   
   -- Note the tablespaces are controlled via constants package
   IF int_count = 0
   THEN
      dz_swagger3_setup.create_storage_tables();
   
   END IF;

END;
/

BEGIN

   EXECUTE IMMEDIATE 'DROP TABLE dz_swagger3_xrelates';
   EXECUTE IMMEDIATE 'DROP TABLE dz_swagger3_xobjects';
   
EXCEPTION
   WHEN OTHERS
   THEN
      NULL;

END;
/

CREATE OR REPLACE TYPE dz_swagger3_object_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    object_id           VARCHAR2(255 Char)
   ,object_type_id      VARCHAR2(255 Char)
   ,object_subtype      VARCHAR2(255 Char)
   ,object_attribute    VARCHAR2(255 Char)
   ,object_key          VARCHAR2(255 Char)
   ,object_hidden       VARCHAR2(5 Char)
   ,object_required     VARCHAR2(5 Char)
   ,object_force_inline VARCHAR2(5 Char)
   ,object_order        INTEGER
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_object_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_object_typ(
       p_object_id           IN  VARCHAR2
      ,p_object_type_id      IN  VARCHAR2
      ,p_object_subtype      IN  VARCHAR2 DEFAULT NULL
      ,p_object_attribute    IN  VARCHAR2 DEFAULT NULL
      ,p_object_key          IN  VARCHAR2 DEFAULT NULL
      ,p_object_hidden       IN  VARCHAR2 DEFAULT NULL
      ,p_object_required     IN  VARCHAR2 DEFAULT NULL
      ,p_object_force_inline IN  VARCHAR2 DEFAULT NULL
      ,p_object_order        IN  INTEGER  DEFAULT 10
   ) RETURN SELF AS RESULT

);
/

GRANT EXECUTE ON dz_swagger3_object_typ TO public;

CREATE OR REPLACE TYPE BODY dz_swagger3_object_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_object_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_object_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_object_typ(
       p_object_id           IN  VARCHAR2
      ,p_object_type_id      IN  VARCHAR2
      ,p_object_subtype      IN  VARCHAR2 DEFAULT NULL
      ,p_object_attribute    IN  VARCHAR2 DEFAULT NULL
      ,p_object_key          IN  VARCHAR2 DEFAULT NULL
      ,p_object_hidden       IN  VARCHAR2 DEFAULT NULL
      ,p_object_required     IN  VARCHAR2 DEFAULT NULL
      ,p_object_force_inline IN  VARCHAR2 DEFAULT NULL
      ,p_object_order        IN  INTEGER  DEFAULT 10
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.object_id        := p_object_id;
      self.object_type_id   := p_object_type_id;
      self.object_subtype   := p_object_subtype;
      self.object_attribute := p_object_attribute;
      self.object_key       := p_object_key;
      self.object_hidden    := p_object_hidden;
      self.object_required  := p_object_required;
      self.object_order     := p_object_order;
      
      RETURN; 
      
   END dz_swagger3_object_typ;
   
END;
/

CREATE OR REPLACE TYPE dz_swagger3_object_vry FORCE                                       
AS 
VARRAY(2147483647) OF dz_swagger3_object_typ;
/

GRANT EXECUTE ON dz_swagger3_object_vry TO public;

CREATE OR REPLACE TYPE dz_swagger3_info_license_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    license_name        VARCHAR2(255 Char)
   ,license_url         VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_info_license_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_info_license_typ(
       p_license_name     IN  VARCHAR2
      ,p_license_url      IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION isNULL
    RETURN VARCHAR2
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_info_license_typ TO public;

CREATE OR REPLACE TYPE BODY dz_swagger3_info_license_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_info_license_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_info_license_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_info_license_typ(
       p_license_name     IN  VARCHAR2
      ,p_license_url      IN  VARCHAR2
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.license_name      := p_license_name;
      self.license_url       := p_license_url;
      
      RETURN; 
      
   END dz_swagger3_info_license_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION isNULL
   RETURN VARCHAR2
   AS
   BEGIN
   
      IF self.license_name IS NOT NULL
      THEN
         RETURN 'FALSE';
         
      ELSE
         RETURN 'TRUE';
         
      END IF;
   
   END isNULL;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_pad          VARCHAR2(1 Char);
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add name element
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          str_pad || dz_json_main.value2json(
             'name'
            ,self.license_name
            ,p_pretty_print + 1
         )
         ,p_pretty_print + 1
      );
      str_pad := ',';
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional url 
      --------------------------------------------------------------------------
      IF self.license_url IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.value2json(
                'url'
               ,self.license_url
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';

      END IF;
 
      --------------------------------------------------------------------------
      -- Step 100
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output        CLOB;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml license name
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty_str(
          'name: ' || dz_swagger3_util.yaml_text(
             self.license_name
            ,p_pretty_print
         )
         ,p_pretty_print
         ,'  '
      );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional license url
      --------------------------------------------------------------------------
      IF self.license_url IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'url: ' || dz_swagger3_util.yaml_text(
                self.license_url
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Cough it out without final line feed
      --------------------------------------------------------------------------
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(10) || '$','');
         
      END IF;
               
      RETURN clb_output;
      
   END toYAML;
   
END;
/

CREATE OR REPLACE TYPE dz_swagger3_info_contact_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    contact_name        VARCHAR2(255 Char)
   ,contact_url         VARCHAR2(255 Char)
   ,contact_email       VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_info_contact_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_info_contact_typ(
       p_contact_name     IN  VARCHAR2
      ,p_contact_url      IN  VARCHAR2
      ,p_contact_email    IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION isNULL
    RETURN VARCHAR2
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_info_contact_typ TO public;

CREATE OR REPLACE TYPE BODY dz_swagger3_info_contact_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_info_contact_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_info_contact_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_info_contact_typ(
       p_contact_name     IN  VARCHAR2
      ,p_contact_url      IN  VARCHAR2
      ,p_contact_email    IN  VARCHAR2
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.contact_name      := p_contact_name;
      self.contact_url       := p_contact_url;
      self.contact_email     := p_contact_email;
      
      RETURN; 
      
   END dz_swagger3_info_contact_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION isNULL
   RETURN VARCHAR2
   AS
   BEGIN
   
      IF self.contact_name IS NOT NULL
      THEN
         RETURN 'FALSE';
         
      ELSIF self.contact_url IS NOT NULL
      THEN
         RETURN 'FALSE';
      
      ELSIF self.contact_email IS NOT NULL
      THEN
         RETURN 'FALSE';
      
      ELSE
         RETURN 'TRUE';
         
      END IF;
   
   END isNULL;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_pad          VARCHAR2(1 Char);
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add name element
      --------------------------------------------------------------------------
      IF self.contact_name IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.value2json(
                'name'
               ,self.contact_name
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional url 
      --------------------------------------------------------------------------
      IF self.contact_url IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.value2json(
                'url'
               ,self.contact_url
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional email 
      --------------------------------------------------------------------------
      IF self.contact_email IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.value2json(
                'email'
               ,self.contact_email
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         
         str_pad := ',';

      END IF;
 
      --------------------------------------------------------------------------
      -- Step 100
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output        CLOB;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml contact name
      --------------------------------------------------------------------------
      IF self.contact_name IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'name: ' || dz_swagger3_util.yaml_text(
                self.contact_name
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional contact url
      --------------------------------------------------------------------------
      IF self.contact_url IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'url: ' || dz_swagger3_util.yaml_text(
                self.contact_url
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional contact_email
      --------------------------------------------------------------------------
      IF self.contact_email IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'email: ' || dz_swagger3_util.yaml_text(
                self.contact_email
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Cough it out without final line feed
      --------------------------------------------------------------------------
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(10) || '$','');
         
      END IF;
               
      RETURN clb_output;
      
   END toYAML;
   
END;
/

CREATE OR REPLACE TYPE dz_swagger3_info_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    info_title           VARCHAR2(255 Char)
   ,info_description     VARCHAR2(4000 Char)
   ,info_termsofservice  VARCHAR2(255 Char)
   ,info_contact         dz_swagger3_info_contact_typ
   ,info_license         dz_swagger3_info_license_typ
   ,info_version         VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_info_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_info_typ(
       p_doc_id         IN  VARCHAR2
      ,p_versionid      IN  VARCHAR2
   ) RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_info_typ(
       p_info_title          IN  VARCHAR2
      ,p_info_description    IN  VARCHAR2
      ,p_info_termsofservice IN  VARCHAR2
      ,p_info_contact        IN  dz_swagger3_info_contact_typ
      ,p_info_license        IN  dz_swagger3_info_license_typ
      ,p_info_version        IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION isNULL
    RETURN VARCHAR2
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_info_typ TO public;

CREATE OR REPLACE TYPE BODY dz_swagger3_info_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_info_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_info_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_info_typ(
       p_doc_id         IN  VARCHAR2
      ,p_versionid      IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
   BEGIN
   
      SELECT 
      dz_swagger3_info_typ(
         p_info_title          => a.info_title
        ,p_info_description    => a.info_description
        ,p_info_termsofservice => a.info_termsofservice
        ,p_info_contact        => dz_swagger3_info_contact_typ(
             p_contact_name  => a.info_contact_name
            ,p_contact_url   => a.info_contact_url
            ,p_contact_email => a.info_contact_email
         )
        ,p_info_license        => dz_swagger3_info_license_typ(
             p_license_name  => a.info_license_name
            ,p_license_url   => a.info_license_url
         )
        ,p_info_version        => a.info_version
      )
      INTO SELF
      FROM
      dz_swagger3_doc a
      WHERE
          a.versionid = p_versionid
      AND a.doc_id = p_doc_id;
      
      RETURN;
   
   END dz_swagger3_info_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_info_typ(
       p_info_title          IN  VARCHAR2
      ,p_info_description    IN  VARCHAR2
      ,p_info_termsofservice IN  VARCHAR2
      ,p_info_contact        IN  dz_swagger3_info_contact_typ
      ,p_info_license        IN  dz_swagger3_info_license_typ
      ,p_info_version        IN  VARCHAR2
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.info_title          := p_info_title;
      self.info_description    := p_info_description;
      self.info_termsofservice := p_info_termsofservice;
      self.info_contact        := p_info_contact;
      self.info_license        := p_info_license;
      self.info_version        := p_info_version;
      
      RETURN; 
      
   END dz_swagger3_info_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION isNULL
   RETURN VARCHAR2
   AS
   BEGIN
   
      IF self.info_title IS NOT NULL
      THEN
         RETURN 'FALSE';
         
      ELSE
         RETURN 'TRUE';
         
      END IF;
   
   END isNULL;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_pad          VARCHAR(1 Char);
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add name element
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          str_pad || dz_json_main.value2json(
             'title'
            ,self.info_title
            ,p_pretty_print + 1
         )
         ,p_pretty_print + 1
      );
      str_pad := ',';
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional description
      --------------------------------------------------------------------------
      IF self.info_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.value2json(
                'description'
               ,self.info_description
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional termsOfService
      --------------------------------------------------------------------------
      IF self.info_termsOfService IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.value2json(
                'termsOfService'
               ,self.info_termsOfService
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add optional contact object
      --------------------------------------------------------------------------
      IF self.info_contact.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.formatted2json(
                'contact'
               ,self.info_contact.toJSON(
                   p_pretty_print    => p_pretty_print + 1
                  ,p_force_inline    => p_force_inline
                )
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Add optional license object
      --------------------------------------------------------------------------
      IF self.info_license.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.formatted2json(
                'license'
               ,self.info_license.toJSON(
                   p_pretty_print   => p_pretty_print + 1
                  ,p_force_inline   => p_force_inline
                )
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Add optional version
      --------------------------------------------------------------------------
      IF self.info_version IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.value2json(
                'version'
               ,self.info_version
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';

      END IF;
 
      --------------------------------------------------------------------------
      -- Step 100
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output        CLOB;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the info title
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty_str(
          'title: ' || dz_swagger3_util.yaml_text(
             self.info_title
            ,p_pretty_print
         )
         ,p_pretty_print
         ,'  '
      );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional info description
      --------------------------------------------------------------------------
      IF self.info_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'description: ' || dz_swagger3_util.yaml_text(
                self.info_description
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the optional info termsOfService
      --------------------------------------------------------------------------
      IF self.info_termsOfService IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'termsOfService: ' || dz_swagger3_util.yaml_text(
                self.info_termsOfService
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the optional info contact object
      --------------------------------------------------------------------------
      IF self.info_contact.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'contact: ' 
            ,p_pretty_print
            ,'  '
         ) || self.info_contact.toYAML(
             p_pretty_print   => p_pretty_print + 1
            ,p_force_inline   => p_force_inline
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Write the optional info license object
      --------------------------------------------------------------------------
      IF self.info_license.isNULL() = 'FALSE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'license: '
            ,p_pretty_print
            ,'  '
         ) || self.info_license.toYAML(
             p_pretty_print   => p_pretty_print + 1
            ,p_force_inline   => p_force_inline
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Write the optional info version
      --------------------------------------------------------------------------
      IF self.info_version IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'version: ' || dz_swagger3_util.yaml_text(
                self.info_version
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Cough it out without final line feed
      --------------------------------------------------------------------------
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(10) || '$','');
         
      END IF;
               
      RETURN clb_output;
      
   END toYAML;
   
END;
/

CREATE OR REPLACE TYPE dz_swagger3_xml_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    xml_name            VARCHAR2(255 Char)
   ,xml_namespace       VARCHAR2(2000 Char)
   ,xml_prefix          VARCHAR2(255 Char)
   ,xml_attribute       VARCHAR2(5 Char)
   ,xml_wrapped         VARCHAR2(5 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_xml_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_xml_typ(
       p_xml_name            IN  VARCHAR2 DEFAULT NULL
      ,p_xml_namespace       IN  VARCHAR2 DEFAULT NULL
      ,p_xml_prefix          IN  VARCHAR2 DEFAULT NULL
      ,p_xml_attribute       IN  VARCHAR2 DEFAULT NULL
      ,p_xml_wrapped         IN  VARCHAR2 DEFAULT NULL
   ) RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER  DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_xml_typ TO public;

CREATE OR REPLACE TYPE BODY dz_swagger3_xml_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_xml_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_xml_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_xml_typ(
       p_xml_name            IN  VARCHAR2 DEFAULT NULL
      ,p_xml_namespace       IN  VARCHAR2 DEFAULT NULL
      ,p_xml_prefix          IN  VARCHAR2 DEFAULT NULL
      ,p_xml_attribute       IN  VARCHAR2 DEFAULT NULL
      ,p_xml_wrapped         IN  VARCHAR2 DEFAULT NULL
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.xml_name         := p_xml_name;
      self.xml_namespace    := p_xml_namespace;
      self.xml_prefix       := p_xml_prefix;
      self.xml_attribute    := p_xml_attribute;
      self.xml_wrapped      := p_xml_wrapped;
      
      RETURN; 
      
   END dz_swagger3_xml_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER  DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_pad          VARCHAR2(1 Char);
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         str_pad := '';
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad := ' ';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional name
      --------------------------------------------------------------------------
      IF self.xml_name IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.value2json(
                'name'
               ,self.xml_name
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional namespace
      --------------------------------------------------------------------------
      IF self.xml_namespace IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.value2json(
                'namespace'
               ,self.xml_namespace
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional prefix
      --------------------------------------------------------------------------
      IF self.xml_prefix IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.value2json(
                'prefix'
               ,self.xml_prefix
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add optional attribute
      --------------------------------------------------------------------------
      IF self.xml_attribute = 'TRUE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.value2json(
                'attribute'
               ,TRUE
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Add optional wrapped
      --------------------------------------------------------------------------
      IF self.xml_wrapped = 'TRUE'
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.value2json(
                'wrapped'
               ,TRUE
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output        CLOB;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the optional name
      --------------------------------------------------------------------------
      IF self.xml_name IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'name: ' || dz_swagger3_util.yaml_text(
                self.xml_name
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional namespace
      --------------------------------------------------------------------------
      IF self.xml_namespace IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'namespace: ' || dz_swagger3_util.yaml_text(
                self.xml_namespace
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the optional prefix
      --------------------------------------------------------------------------
      IF self.xml_prefix IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'prefix: ' || dz_swagger3_util.yaml_text(
                self.xml_prefix
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the optional attribute boolean
      --------------------------------------------------------------------------
      IF self.xml_attribute = 'TRUE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'attribute: ' || dz_swagger3_util.yaml_text(
                TRUE
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Write the optional wrapped boolean
      --------------------------------------------------------------------------
      IF self.xml_wrapped = 'TRUE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'wrapped: ' || dz_swagger3_util.yaml_text(
                TRUE
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Cough it out 
      --------------------------------------------------------------------------
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(10) || '$','');
         
      END IF;
               
      RETURN clb_output;
      
   END toYAML;
   
END;
/

CREATE OR REPLACE TYPE dz_swagger3_oauth_flow_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    oauth_authorizationUrl       VARCHAR2(255 Char)
   ,oauth_tokenUrl               VARCHAR2(255 Char)
   ,oauth_refreshUrl             VARCHAR2(255 Char)
   ,oauth_scopes                 MDSYS.SDO_STRING2_ARRAY --dz_swagger3_string_hash_list
   ,versionid                    VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_oauth_flow_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_oauth_flow_typ(
       p_oauth_authorizationUrl  IN  VARCHAR2
      ,p_oauth_tokenUrl          IN  VARCHAR2
      ,p_oauth_refreshUrl        IN  VARCHAR2
      ,p_oauth_scopes            IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_string_hash_list
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_oauth_flow_typ TO public;

CREATE OR REPLACE TYPE dz_swagger3_oauth_flows_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    flows_implicit             dz_swagger3_oauth_flow_typ
   ,flows_password             dz_swagger3_oauth_flow_typ
   ,flows_clientCredentials    dz_swagger3_oauth_flow_typ
   ,flows_authorizationCode    dz_swagger3_oauth_flow_typ
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_oauth_flows_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_oauth_flows_typ(
       p_flows_implicit          IN  dz_swagger3_oauth_flow_typ
      ,p_flows_password          IN  dz_swagger3_oauth_flow_typ
      ,p_flows_clientCredentials IN  dz_swagger3_oauth_flow_typ
      ,p_flows_authorizationCode IN  dz_swagger3_oauth_flow_typ
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_oauth_flows_typ TO public;

CREATE OR REPLACE TYPE dz_swagger3_encoding_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    encoding_id            VARCHAR2(255 Char)
   ,encoding_contentType   VARCHAR2(255 Char)
   ,encoding_headers       dz_swagger3_object_vry --dz_swagger3_header_list
   ,encoding_style         VARCHAR2(255 Char)
   ,encoding_explode       VARCHAR2(5 Char)
   ,encoding_allowReserved VARCHAR2(5 Char)
   ,versionid              VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_encoding_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_encoding_typ(
       p_encoding_id            IN  VARCHAR2
      ,p_versionid              IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE traverse
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_encoding_typ TO public;

CREATE OR REPLACE TYPE dz_swagger3_example_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    example_id             VARCHAR2(255 Char)
   ,example_summary        VARCHAR2(255 Char)
   ,example_description    VARCHAR2(4000 Char)
   ,example_value_string   VARCHAR2(255 Char)
   ,example_value_number   NUMBER
   ,example_externalValue  VARCHAR2(255 Char)
   ,versionid              VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_example_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_example_typ(
       p_example_id              IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE traverse
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_example_typ TO public;

CREATE OR REPLACE TYPE dz_swagger3_extrdocs_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    externaldoc_id          VARCHAR2(255 Char)
   ,externaldoc_description VARCHAR2(4000 Char)
   ,externaldoc_url         VARCHAR2(255 Char)
   ,versionid               VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_extrdocs_typ
    RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_extrdocs_typ(
       p_externaldoc_id          IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE traverse
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_extrdocs_typ TO public;

CREATE OR REPLACE TYPE dz_swagger3_header_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    header_id               VARCHAR2(255 Char)
   ,header_description      VARCHAR2(4000 Char)
   ,header_required         VARCHAR2(5 Char)
   ,header_deprecated       VARCHAR2(5 Char)
   ,header_allowEmptyValue  VARCHAR2(5 Char)
   ,header_style            VARCHAR2(255 Char)
   ,header_explode          VARCHAR2(5 Char)
   ,header_allowReserved    VARCHAR2(5 Char)
   ,header_schema           dz_swagger3_object_typ --dz_swagger3_schema_typ
   ,header_example_string   VARCHAR2(255 Char)
   ,header_example_number   NUMBER
   ,header_examples         dz_swagger3_object_vry --dz_swagger3_example_list
   ,versionid               VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_header_typ
    RETURN SELF AS RESULT

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_header_typ(
       p_header_id               IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE traverse

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_header_typ TO public;

CREATE OR REPLACE TYPE dz_swagger3_link_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    link_id             VARCHAR2(255 Char)
   ,link_operationRef   VARCHAR2(255 Char)
   ,link_operationId    VARCHAR2(255 Char)
   ,link_parameters     dz_swagger3_object_vry --dz_swagger3_string_hash_list
   ,link_requestBody    VARCHAR2(4000 Char)
   ,link_description    VARCHAR2(4000 Char)
   ,link_server         dz_swagger3_object_typ --dz_swagger3_server_typ
   ,versionid           VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_link_typ
    RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_link_typ(
       p_link_id                 IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
 
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE traverse
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_link_typ TO public;

CREATE OR REPLACE TYPE dz_swagger3_media_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    media_id                 VARCHAR2(255 Char)
   ,media_schema             dz_swagger3_object_typ --dz_swagger3_schema_typ
   ,media_emulated_parms     dz_swagger3_object_vry
   ,media_example_string     VARCHAR2(4000 Char)
   ,media_example_number     NUMBER
   ,media_examples           dz_swagger3_object_vry --dz_swagger3_example_list
   ,media_encoding           dz_swagger3_object_vry --dz_swagger3_encoding_list
   ,versionid                VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_media_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_media_typ(
       p_media_id                 IN  VARCHAR2
      ,p_versionid                IN  VARCHAR2
   ) RETURN SELF AS RESULT

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_media_typ(
       p_media_id                 IN  VARCHAR2
      ,p_parameters               IN  dz_swagger3_object_vry --dz_swagger3_parameter_list
      ,p_versionid                IN  VARCHAR2
   ) RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE traverse
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_media_typ TO public;

CREATE OR REPLACE TYPE dz_swagger3_operation_typ FORCE
AUTHID DEFINER
AS OBJECT (
    operation_id                  VARCHAR2(255 Char)
   ,operation_type                VARCHAR2(255 Char)
   ,operation_tags                dz_swagger3_object_vry --dz_swagger3_tag_list
   ,operation_summary             VARCHAR2(255 Char)
   ,operation_description         VARCHAR2(4000 Char)
   ,operation_externalDocs        dz_swagger3_object_typ --dz_swagger3_extrdocs_typ
   ,operation_operationId         VARCHAR2(255 Char)
   ,operation_parameters          dz_swagger3_object_vry --dz_swagger3_parameter_list
   ,operation_emulated_rbparms    dz_swagger3_object_vry --dz_swagger3_parameter_list
   ,operation_requestBody         dz_swagger3_object_typ --dz_swagger3_requestbody_typ
   ,operation_responses           dz_swagger3_object_vry --dz_swagger3_response_list
   ,operation_callbacks           dz_swagger3_object_vry --dz_swagger3_path_list
   ,operation_deprecated          VARCHAR2(5 Char)
   ,operation_inline_rb           VARCHAR2(5 Char)
   ,operation_security            dz_swagger3_object_vry --dz_swagger3_security_req_list
   ,operation_servers             dz_swagger3_object_vry --dz_swagger3_server_list
   ,versionid                     VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_operation_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_operation_typ(
       p_operation_id              IN  VARCHAR2
      ,p_versionid                 IN  VARCHAR2
   ) RETURN SELF AS RESULT

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE traverse

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_operation_typ TO public;

CREATE OR REPLACE TYPE dz_swagger3_parameter_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    parameter_id               VARCHAR2(255 Char)
   ,parameter_name             VARCHAR2(255 Char)
   ,parameter_in               VARCHAR2(255 Char)
   ,parameter_description      VARCHAR2(4000 Char)
   ,parameter_required         VARCHAR2(5 Char)
   ,parameter_deprecated       VARCHAR2(5 Char)
   ,parameter_allowEmptyValue  VARCHAR2(5 Char)
   ,parameter_style            VARCHAR2(255 Char)
   ,parameter_explode          VARCHAR2(5 Char)
   ,parameter_allowReserved    VARCHAR2(5 Char)
   ,parameter_schema           dz_swagger3_object_typ --dz_swagger3_schema_typ_nf
   ,parameter_example_string   VARCHAR2(255 Char)
   ,parameter_example_number   NUMBER
   ,parameter_examples         dz_swagger3_object_vry --dz_swagger3_example_list
   ,parameter_force_inline     VARCHAR2(5 Char)
   ,parameter_list_hidden      VARCHAR2(5 Char)
   ,parameter_requestbody_flag VARCHAR2(5 Char)
   ,versionid                  VARCHAR2(40 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_parameter_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_parameter_typ(
       p_parameter_id              IN  VARCHAR2
      ,p_versionid                 IN  VARCHAR2
   ) RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE traverse
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_parameter_typ TO public;

CREATE OR REPLACE TYPE dz_swagger3_path_typ FORCE
AUTHID DEFINER
AS OBJECT (
    path_id                  VARCHAR2(255 Char)
   ,path_endpoint            VARCHAR2(255 Char)
   ,path_summary             VARCHAR2(255 Char)
   ,path_description         VARCHAR2(4000 Char)
   ,path_get_operation       dz_swagger3_object_typ --dz_swagger3_operation_typ
   ,path_put_operation       dz_swagger3_object_typ --dz_swagger3_operation_typ
   ,path_post_operation      dz_swagger3_object_typ --dz_swagger3_operation_typ
   ,path_delete_operation    dz_swagger3_object_typ --dz_swagger3_operation_typ
   ,path_options_operation   dz_swagger3_object_typ --dz_swagger3_operation_typ
   ,path_head_operation      dz_swagger3_object_typ --dz_swagger3_operation_typ
   ,path_patch_operation     dz_swagger3_object_typ --dz_swagger3_operation_typ
   ,path_trace_operation     dz_swagger3_object_typ --dz_swagger3_operation_typ
   ,path_servers             dz_swagger3_object_vry --dz_swagger3_server_list
   ,path_parameters          dz_swagger3_object_vry --dz_swagger3_parameter_list
   ,versionid                VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_path_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_path_typ(
       p_path_id                   IN  VARCHAR2
      ,p_versionid                 IN  VARCHAR2
   ) RETURN SELF AS RESULT

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE traverse

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
    ) RETURN CLOB

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_path_typ TO public;

CREATE OR REPLACE TYPE dz_swagger3_requestbody_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    requestBody_id             VARCHAR2(255 Char)
   ,requestBody_description    VARCHAR2(4000 Char)
   ,requestBody_inline         VARCHAR2(5 Char)
   ,requestBody_force_inline   VARCHAR2(5 Char)
   ,requestBody_content        dz_swagger3_object_vry --dz_swagger3_media_list
   ,requestBody_emulated_parms dz_swagger3_object_vry
   ,requestBody_required       VARCHAR2(5 Char)
   ,versionid                  VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_requestbody_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_requestbody_typ(
       p_requestbody_id           IN  VARCHAR2
      ,p_versionid                IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_requestbody_typ(
       p_requestbody_id           IN  VARCHAR2
      ,p_parameters               IN  dz_swagger3_object_vry --dz_swagger3_parameter_list
      ,p_versionid                IN  VARCHAR2
   ) RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE traverse
    
    -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_requestbody_typ TO public;

CREATE OR REPLACE TYPE dz_swagger3_response_typ FORCE
AUTHID DEFINER
AS OBJECT (
    response_id              VARCHAR2(255 Char)
   ,response_description     VARCHAR2(4000 Char)
   ,response_headers         dz_swagger3_object_vry --dz_swagger3_header_list
   ,response_content         dz_swagger3_object_vry --dz_swagger3_media_list
   ,response_links           dz_swagger3_object_vry --dz_swagger3_link_list
   ,versionid                VARCHAR2(255 Char)

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_response_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_response_typ(
       p_response_id             IN  VARCHAR2
      ,p_response_code           IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE traverse

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
    ) RETURN CLOB

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_response_typ TO public;

CREATE OR REPLACE TYPE dz_swagger3_schema_typ FORCE 
AUTHID DEFINER 
AS OBJECT (
    
    schema_id                VARCHAR2(255 Char)
   ,schema_title             VARCHAR2(255 Char)
   ,schema_category          VARCHAR2(255 Char)
   ,schema_type              VARCHAR2(255 Char)
   ,schema_description       VARCHAR2(4000 Char)
   ,schema_format            VARCHAR2(255 Char)
   ,schema_nullable          VARCHAR2(5 Char)
   ,schema_discriminator     VARCHAR2(255 Char)
   ,schema_readonly          VARCHAR2(5 Char)
   ,schema_writeonly         VARCHAR2(5 Char)
   ,schema_externalDocs      dz_swagger3_object_typ --dz_swagger3_extrdocs_typ
   ,schema_example_string    VARCHAR2(4000 Char)
   ,schema_example_number    NUMBER
   ,schema_deprecated        VARCHAR2(5 Char)
   ,schema_required          VARCHAR2(5 Char)
   ,property_list_hidden     VARCHAR2(5 Char)
   ,schema_force_inline      VARCHAR2(5 Char)
   -----
   ,schema_items_schema      dz_swagger3_object_typ --dz_swagger3_schema_typ
   -----
   ,schema_default_string    VARCHAR2(255 Char) 
   ,schema_default_number    NUMBER 
   ,schema_multipleOf        NUMBER 
   ,schema_minimum           NUMBER 
   ,schema_exclusiveMinimum  VARCHAR2(5 Char) 
   ,schema_maximum           NUMBER 
   ,schema_exclusiveMaximum  VARCHAR2(5 Char) 
   ,schema_minLength         INTEGER 
   ,schema_maxLength         INTEGER 
   ,schema_pattern           VARCHAR2(4000 Char) 
   ,schema_minItems          INTEGER 
   ,schema_maxItems          INTEGER 
   ,schema_uniqueItems       VARCHAR2(5 Char) 
   ,schema_minProperties     INTEGER 
   ,schema_maxProperties     INTEGER
   -----
   ,schema_properties        dz_swagger3_object_vry --dz_swagger3_schema_list
   ,schema_emulated_parms    dz_swagger3_object_vry --dz_swagger3_parameter_list
   -----
   ,schema_enum_string       MDSYS.SDO_STRING2_ARRAY
   ,schema_enum_number       MDSYS.SDO_NUMBER_ARRAY
   -----
   ,xml_name                 VARCHAR2(255 Char)
   ,xml_namespace            VARCHAR2(2000 Char)
   ,xml_prefix               VARCHAR2(255 Char)
   ,xml_attribute            VARCHAR2(5 Char)
   ,xml_wrapped              VARCHAR2(5 Char)
   -----
   ,combine_schemas          dz_swagger3_object_vry --dz_swagger3_schema_list
   -----
   ,inject_jsonschema        VARCHAR2(5 Char)
   ,versionid                VARCHAR2(255 Char)

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_schema_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_schema_typ(
       p_schema_id                IN  VARCHAR2
      ,p_versionid                IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_schema_typ(
       p_schema_id                IN  VARCHAR2
      ,p_parameters               IN  dz_swagger3_object_vry
      ,p_versionid                IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_schema_typ(
       p_schema_id                IN  VARCHAR2
      ,p_emulated_parameter_id    IN  VARCHAR2
      ,p_versionid                IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE traverse
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
      ,p_jsonschema          IN  VARCHAR2  DEFAULT 'FALSE'    
   ) RETURN CLOB
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON_schema(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
      ,p_jsonschema          IN  VARCHAR2  DEFAULT 'FALSE'       
   ) RETURN CLOB
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON_combine(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_jsonschema          IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML_schema(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML_combine(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   
);
/

GRANT EXECUTE ON dz_swagger3_schema_typ TO public;

CREATE OR REPLACE TYPE dz_swagger3_security_req_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    security_req_name   VARCHAR2(255 Char)
   ,scope_names         MDSYS.SDO_STRING2_ARRAY
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_security_req_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_security_req_typ(
       p_security_req_name  IN  VARCHAR2
      ,p_scope_names        IN  MDSYS.SDO_STRING2_ARRAY
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_security_req_typ TO public;

CREATE OR REPLACE TYPE dz_swagger3_securityScheme_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    securityscheme_id           VARCHAR2(255 Char)
   ,securityscheme_type         VARCHAR2(255 Char)
   ,securityscheme_description  VARCHAR2(255 Char)
   ,securityscheme_name         VARCHAR2(255 Char)
   ,securityscheme_in           VARCHAR2(255 Char)
   ,securityscheme_auth         VARCHAR2(255 Char)
   ,securityscheme_bearerFormat VARCHAR2(255 Char)
   ,securityscheme_flows        dz_swagger3_oauth_flows_typ
   ,securityscheme_openIdConUrl VARCHAR2(255 Char)
   ,versionid                   VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_securityScheme_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_securityScheme_typ(
       p_securityscheme_id   IN  VARCHAR2
      ,p_versionid           IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_securityScheme_typ TO public;

CREATE OR REPLACE TYPE dz_swagger3_server_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    server_url          VARCHAR2(255 Char)
   ,server_description  VARCHAR2(4000 Char)
   ,server_variables    dz_swagger3_object_vry --dz_swagger3_server_var_list
   ,versionid           VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_server_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_server_typ(
       p_server_id           IN  VARCHAR2
      ,p_versionid           IN  VARCHAR2 DEFAULT NULL
   ) RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE traverse
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_server_typ TO public;

CREATE OR REPLACE TYPE dz_swagger3_server_var_typ FORCE
AUTHID DEFINER
AS OBJECT (
    server_var_id       VARCHAR2(255 Char)
   ,server_var_name     VARCHAR2(255 Char)
   ,enum                MDSYS.SDO_STRING2_ARRAY
   ,default_value       VARCHAR2(255 Char)
   ,description         VARCHAR2(4000 Char)
   ,versionid           VARCHAR2(255 Char)

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_server_var_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_server_var_typ(
       p_server_var_id      IN  VARCHAR2
      ,p_versionid          IN  VARCHAR2
   ) RETURN SELF AS RESULT

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE traverse

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_server_var_typ TO public;

CREATE OR REPLACE TYPE dz_swagger3_string_hash_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    hash_key            VARCHAR2(255 Char)
   ,string_value        VARCHAR2(4000 Char)
   ,versionid           VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_string_hash_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_string_hash_typ(
       p_hash_key           IN  VARCHAR2
      ,p_string_value       IN  VARCHAR2
      ,p_versionid          IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE traverse
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_string_hash_typ TO public;

CREATE OR REPLACE TYPE dz_swagger3_tag_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    tag_id              VARCHAR2(255 Char)
   ,tag_name            VARCHAR2(255 Char)
   ,tag_description     VARCHAR2(4000 Char)
   ,tag_externalDocs    dz_swagger3_object_typ --dz_swagger3_extrdocs_typ
   ,versionid           VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_tag_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_tag_typ(
       p_tag_id             IN  VARCHAR2
      ,p_versionid          IN  VARCHAR2
   ) RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE traverse
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_tag_typ TO public;

CREATE OR REPLACE TYPE dz_swagger3_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    versionid           VARCHAR2(40 Char)
   ,group_id            VARCHAR2(255 Char)
   ,info                dz_swagger3_info_typ
   ,servers             dz_swagger3_object_vry --dz_swagger3_server_list
   ,paths               dz_swagger3_object_vry --dz_swagger3_path_list
   ,security            dz_swagger3_object_vry --dz_swagger3_security_req_list
   ,externalDocs        dz_swagger3_object_typ --dz_swagger3_extrdocs_typ
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_typ 
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_typ(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2 DEFAULT NULL
      ,p_versionid           IN  VARCHAR2 DEFAULT NULL
      ,p_shorten_logic       IN  VARCHAR2 DEFAULT NULL
   ) RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON_components(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML_components(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_typ TO public;

BEGIN

   BEGIN
      EXECUTE IMMEDIATE 'DROP TABLE dz_swagger3_xrelates';
      EXECUTE IMMEDIATE 'DROP TABLE dz_swagger3_xobjects';
   
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
         
   END;
   
   dz_swagger3_setup.create_temp_tables();

END;
/

CREATE OR REPLACE PACKAGE dz_swagger3_loader
AUTHID DEFINER
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE encodingtyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE exampletyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE extrdocstyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE headertyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE linktyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE mediatyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE mediatyp_emulated(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_parameter_ids       IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE operationtyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE parametertyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE pathtyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE requestbodytyp(
       p_parent_id           IN  VARCHAR2
      ,p_child_id            IN  dz_swagger3_object_typ
      ,p_versionid           IN  VARCHAR2
   );

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE requestbodytyp_emulated(
       p_parent_id           IN  VARCHAR2
      ,p_child_id            IN  dz_swagger3_object_typ
      ,p_parameter_ids       IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE responsetyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE schematyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE schematyp_emulated(
       p_parent_id           IN  VARCHAR2
      ,p_child_id            IN  dz_swagger3_object_typ
      ,p_parameter_ids       IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE servertyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE servervartyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE stringhashtyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE tagtyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
 
 END dz_swagger3_loader;
/

GRANT EXECUTE ON dz_swagger3_loader TO public;

CREATE OR REPLACE PACKAGE BODY dz_swagger3_loader
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE xrelates(
       p_children_ids        IN  dz_swagger3_object_vry
      ,p_parent_id           IN  VARCHAR2
   )
   AS
   BEGIN

      INSERT INTO dz_swagger3_xrelates(
          parent_object_id
         ,child_object_id
         ,child_object_type_id
      )
      SELECT
       p_parent_id
      ,a.object_id
      ,a.object_type_id
      FROM
      TABLE(p_children_ids) a
      WHERE
      NOT EXISTS (
         SELECT 1 FROM dz_swagger3_xrelates b 
         WHERE 
             b.parent_object_id = p_parent_id
         AND b.child_object_id  = a.object_id
      )
      AND a.object_id IS NOT NULL
      GROUP BY
       a.object_id
      ,a.object_type_id;

   END;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION filter_ids(
       p_children_ids        IN  dz_swagger3_object_vry
      ,p_parent_id           IN  VARCHAR2
   ) RETURN dz_swagger3_object_vry
   AS
      ary_output dz_swagger3_object_vry;
      
   BEGIN
   
      xrelates(p_children_ids,p_parent_id);
   
      SELECT
      dz_swagger3_object_typ(
          p_object_id           => a.object_id
         ,p_object_type_id      => a.object_type_id
         ,p_object_key          => MAX(a.object_key)
         ,p_object_subtype      => MAX(a.object_subtype)
         ,p_object_attribute    => MAX(a.object_attribute)
      )
      BULK COLLECT INTO ary_output
      FROM
      TABLE(p_children_ids) a
      LEFT JOIN
      dz_swagger3_xobjects b
      ON
          a.object_id      = b.object_id
      AND a.object_type_id = b.object_type_id
      WHERE 
          b.object_id IS NULL 
      AND a.object_id IS NOT NULL
      GROUP BY
       a.object_id
      ,a.object_type_id;
      
      RETURN ary_output;
      
   END filter_ids;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE encodingtyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,encodingtyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_encoding_typ(
          p_encoding_id   => a.object_id
         ,p_versionid     => p_versionid
      )
      FROM 
      TABLE(ary_ids) a;

      FOR r IN (
         SELECT 
         a.encodingtyp
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.encodingtyp.traverse();
      END LOOP;
      
   END encodingtyp;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE exampletyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);
      
      INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,exampletyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_example_typ(
          p_example_id => a.object_id
         ,p_versionid  => p_versionid
       )
      FROM 
      TABLE(ary_ids) a;
      
      -- No subobjects

   END exampletyp;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE extrdocstyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,extrdocstyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_extrdocs_typ(
          p_externaldoc_id => a.object_id
         ,p_versionid      => p_versionid
       )
      FROM 
      TABLE(ary_ids) a;
      
      -- No subobjects

   END extrdocstyp;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE headertyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,headertyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_header_typ(
          p_header_id    => a.object_id
         ,p_versionid    => p_versionid
       )
      FROM 
      TABLE(ary_ids) a;

      FOR r IN (
         SELECT 
         a.headertyp
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.headertyp.traverse();
      END LOOP;

   END headertyp;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE linktyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,linktyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_link_typ(
          p_link_id    => a.object_id
         ,p_versionid  => p_versionid
       )
      FROM 
      TABLE(ary_ids) a;

      FOR r IN (
         SELECT 
         a.linktyp
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.linktyp.traverse();
      END LOOP;

   END linktyp;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE mediatyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      INSERT 
      INTO dz_swagger3_xobjects(
          object_id
         ,object_type_id
         ,mediatyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_media_typ(
          p_media_id    => a.object_id
         ,p_versionid   => p_versionid
       )
      FROM
      TABLE(ary_ids) a;
      
      FOR r IN (
         SELECT 
         a.mediatyp
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.mediatyp.traverse();
      END LOOP;

   END mediatyp;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE mediatyp_emulated(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_parameter_ids       IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(
          p_children_ids
         ,p_parent_id
      );

      INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,mediatyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_media_typ(
          p_media_id       => a.object_id
         ,p_parameters     => p_parameter_ids
         ,p_versionid      => p_versionid
       )
      FROM 
      TABLE(ary_ids) a;

      FOR r IN (
         SELECT 
         a.mediatyp
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.mediatyp.traverse();
      END LOOP;   

   END mediatyp_emulated;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE operationtyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      INSERT 
      INTO dz_swagger3_xobjects(
          object_id
         ,object_type_id
         ,operationtyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_operation_typ(
          p_operation_id => a.object_id
         ,p_versionid    => p_versionid
       )
      FROM
      TABLE(ary_ids) a;
      
      FOR r IN (
         SELECT 
         a.operationtyp
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.operationtyp.traverse();
      END LOOP;
      
   END operationtyp;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE parametertyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
      
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,parametertyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_parameter_typ(
          p_parameter_id => a.object_id
         ,p_versionid    => p_versionid
       )
      FROM 
      TABLE(ary_ids) a;

      FOR r IN (
         SELECT 
         a.parametertyp
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.parametertyp.traverse();
      END LOOP;
   
   END parametertyp;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE pathtyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,pathtyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_path_typ(
          p_path_id    => a.object_id
         ,p_versionid  => p_versionid
       )
      FROM 
      TABLE(ary_ids) a;
      
      FOR r IN (
         SELECT 
         a.pathtyp
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.pathtyp.traverse();
      END LOOP;

   END pathtyp;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE requestbodytyp(
       p_parent_id           IN  VARCHAR2
      ,p_child_id            IN  dz_swagger3_object_typ
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(
          dz_swagger3_object_vry(p_child_id)
         ,p_parent_id
      );

      INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,requestbodytyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_requestbody_typ(
          p_requestbody_id => a.object_id
         ,p_versionid      => p_versionid
       )
      FROM 
      TABLE(ary_ids) a;
      
      FOR r IN (
         SELECT 
         a.requestbodytyp
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.requestbodytyp.traverse();
      END LOOP;

   END requestbodytyp;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE requestbodytyp_emulated(
       p_parent_id           IN  VARCHAR2
      ,p_child_id            IN  dz_swagger3_object_typ
      ,p_parameter_ids       IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(
          dz_swagger3_object_vry(p_child_id)
         ,p_parent_id
      );

      INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,requestbodytyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_requestbody_typ(
          p_requestbody_id => a.object_id
         ,p_parameters     => p_parameter_ids
         ,p_versionid      => p_versionid
       )
      FROM 
      TABLE(ary_ids) a;

      FOR r IN (
         SELECT 
         a.requestbodytyp
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.requestbodytyp.traverse();
      END LOOP;

   END requestbodytyp_emulated;
   
    -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE responsetyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(
          p_children_ids
         ,p_parent_id
      );

      INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,responsetyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_response_typ(
          p_response_id    => a.object_id
         ,p_response_code  => a.object_key
         ,p_versionid      => p_versionid
       )
      FROM 
      TABLE(ary_ids) a;

      FOR r IN (
         SELECT 
         a.responsetyp
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.responsetyp.traverse();
      END LOOP;

   END responsetyp;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE schematyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,schematyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,CASE 
       WHEN a.object_subtype = 'emulated_item'
       THEN
         dz_swagger3_schema_typ(
             p_schema_id             => a.object_id
            ,p_emulated_parameter_id => a.object_attribute
            ,p_versionid             => p_versionid
         )
       ELSE
         dz_swagger3_schema_typ(
             p_schema_id             => a.object_id
            ,p_versionid             => p_versionid
         )
       END
      FROM 
      TABLE(ary_ids) a;
      
      FOR r IN (
         SELECT 
         a.schematyp 
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.schematyp.traverse();
      END LOOP;

   END schematyp;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE schematyp_emulated(
       p_parent_id           IN  VARCHAR2
      ,p_child_id            IN  dz_swagger3_object_typ
      ,p_parameter_ids       IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(
          dz_swagger3_object_vry(p_child_id)
         ,p_parent_id
      );

      INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,schematyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_schema_typ(
          p_schema_id     => a.object_id
         ,p_parameters    => p_parameter_ids
         ,p_versionid     => p_versionid
       )
      FROM 
      TABLE(ary_ids) a;

      FOR r IN (
         SELECT 
         a.schematyp
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.schematyp.traverse();
      END LOOP;

   END schematyp_emulated;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE servertyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      INSERT 
      INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,servertyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_server_typ(
          p_server_id   => a.object_id
         ,p_versionid   => p_versionid
       )
      FROM 
      TABLE(ary_ids) a;
      
      FOR r IN (
         SELECT 
         a.servertyp
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.servertyp.traverse();
      END LOOP;
      
   END servertyp;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE servervartyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      INSERT 
      INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,servervartyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_server_var_typ(
          p_server_var_id  => a.object_id
         ,p_versionid      => p_versionid
       )
      FROM 
      TABLE(ary_ids) a;
      
      -- No subobjects
      
   END servervartyp;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE stringhashtyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;
      str_otype VARCHAR2(255 Char) := 'stringhashtyp';

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      INSERT 
      INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,stringhashtyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_string_hash_typ(
          p_hash_key       => a.object_id
         ,p_string_value   => a.object_key
         ,p_versionid      => p_versionid
       )
      FROM 
      TABLE(ary_ids) a;
      
      -- No subobjects
      
   END stringhashtyp;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE tagtyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;
      str_otype VARCHAR2(255 Char) := 'tagtyp';

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      INSERT 
      INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,tagtyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_tag_typ(
          p_tag_id        => a.object_id
         ,p_versionid     => p_versionid
       )
      FROM
      TABLE(ary_ids) a;
      
      FOR r IN (
         SELECT 
         a.tagtyp
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.tagtyp.traverse();
      END LOOP;
      
   END tagtyp;

END dz_swagger3_loader;
/

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
 
 END dz_swagger3_main;
/

GRANT EXECUTE ON dz_swagger3_main TO public;

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

CREATE OR REPLACE PACKAGE dz_swagger3_cache_mgr
AUTHID DEFINER
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION json(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_refresh_interval    IN  INTERVAL  DAY TO SECOND DEFAULT NULL
      ,p_shorten_logic       IN  VARCHAR2  DEFAULT NULL
   ) RETURN CLOB;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION json_pretty(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_refresh_interval    IN  INTERVAL  DAY TO SECOND DEFAULT NULL
      ,p_shorten_logic       IN  VARCHAR2  DEFAULT NULL
   ) RETURN CLOB;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION yaml(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_refresh_interval    IN  INTERVAL  DAY TO SECOND DEFAULT NULL
      ,p_shorten_logic       IN  VARCHAR2  DEFAULT NULL
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
      ,p_shorten_logic       IN  VARCHAR2  DEFAULT NULL
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

CREATE OR REPLACE PACKAGE BODY dz_swagger3_cache_mgr
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE vintage(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_timestamp           OUT TIMESTAMP
      ,p_shorten_logic       OUT VARCHAR2
   )
   AS
      str_doc_id          VARCHAR2(255 Char);
      str_group_id        VARCHAR2(255 Char);
      str_versionid       VARCHAR2(40 Char);

   BEGIN
   
      dz_swagger3_main.startup_defaults(
          p_doc_id        => p_doc_id
         ,p_group_id      => p_group_id
         ,p_versionid     => p_versionid
         ,out_doc_id      => str_doc_id
         ,out_group_id    => str_group_id
         ,out_versionid   => str_versionid
      );
   
      SELECT
       a.extraction_timestamp
      ,a.shorten_logic
      INTO
       p_timestamp
      ,p_shorten_logic
      FROM
      dz_swagger3_cache a
      WHERE
          a.doc_id    = str_doc_id
      AND a.group_id  = str_group_id
      AND a.versionid = str_versionid;
      
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN;
          
      WHEN OTHERS
      THEN
         RAISE;
   
   END vintage;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE update_cache(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_shorten_logic       IN  VARCHAR2  DEFAULT NULL
      ,out_json              OUT CLOB
      ,out_json_pretty       OUT CLOB
      ,out_yaml              OUT CLOB
   )
   AS
   PRAGMA AUTONOMOUS_TRANSACTION;
      obj_core        dz_swagger3_typ;
      
   BEGIN
   
      obj_core := dz_swagger3_typ(
          p_doc_id        => p_doc_id
         ,p_group_id      => p_group_id
         ,p_versionid     => p_versionid
         ,p_shorten_logic => p_shorten_logic 
      );
   
      out_json        := obj_core.toJSON(
         p_short_id      => 'TRUE'   
      );
      out_json_pretty := obj_core.toJSON(
          p_pretty_print => 0
         ,p_short_id     => 'TRUE'
      );
      out_yaml        := obj_core.toYAML(
          p_pretty_print => 0
         ,p_short_id     => 'TRUE'
      );
      
      BEGIN
         INSERT INTO dz_swagger3_cache(
             doc_id
            ,group_id
            ,json_payload
            ,json_pretty_payload
            ,yaml_payload
            ,extraction_timestamp 
            ,shorten_logic
            ,versionid 
         ) VALUES (
             p_doc_id
            ,p_group_id
            ,out_json
            ,out_json_pretty
            ,out_yaml
            ,SYSTIMESTAMP
            ,p_shorten_logic
            ,p_versionid
         );
         
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            UPDATE dz_swagger3_cache
            SET
             json_payload         = out_json
            ,json_pretty_payload  = out_json_pretty
            ,yaml_payload         = out_yaml
            ,extraction_timestamp = SYSTIMESTAMP
            ,shorten_logic        = p_shorten_logic
            WHERE
                doc_id    = p_doc_id
            AND group_id  = p_group_id
            AND versionid = p_versionid;
            
         WHEN OTHERS
         THEN
            RAISE;
            
      END;
      
      COMMIT;
   
   END update_cache;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION json(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_refresh_interval    IN  INTERVAL  DAY TO SECOND DEFAULT NULL
      ,p_shorten_logic       IN  VARCHAR2  DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output          CLOB;
      clb_output2         CLOB;
      clb_output3         CLOB;
      str_doc_id          VARCHAR2(255 Char);
      str_group_id        VARCHAR2(255 Char);
      str_versionid       VARCHAR2(40 Char);
      dat_timestamp       TIMESTAMP;
      str_shorten_logic   VARCHAR2(255 Char);

   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------

      --------------------------------------------------------------------------
      -- Step 20     
      -- Determine the default version if not provided
      --------------------------------------------------------------------------
      dz_swagger3_main.startup_defaults(
          p_doc_id        => p_doc_id
         ,p_group_id      => p_group_id
         ,p_versionid     => p_versionid
         ,out_doc_id      => str_doc_id
         ,out_group_id    => str_group_id
         ,out_versionid   => str_versionid
      );
      
      --------------------------------------------------------------------------
      -- Step 30     
      -- Fetch cache if populated
      --------------------------------------------------------------------------
      vintage(
          p_doc_id        => str_doc_id
         ,p_group_id      => str_group_id
         ,p_versionid     => str_versionid
         ,p_timestamp     => dat_timestamp
         ,p_shorten_logic => str_shorten_logic
      );
      
      IF  p_shorten_logic IS NOT NULL
      AND p_shorten_logic <> str_shorten_logic
      THEN
         str_shorten_logic := p_shorten_logic;
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40     
      -- Return results if found
      --------------------------------------------------------------------------
      IF dat_timestamp IS NULL
      OR SYSTIMESTAMP - dat_timestamp > p_refresh_interval
      OR p_shorten_logic <> str_shorten_logic
      THEN
         update_cache(
             p_doc_id          => str_doc_id
            ,p_group_id        => str_group_id
            ,p_versionid       => str_versionid
            ,p_shorten_logic   => str_shorten_logic
            ,out_json          => clb_output
            ,out_json_pretty   => clb_output2
            ,out_yaml          => clb_output3
         );
         
      ELSE
         SELECT
         a.json_payload
         INTO clb_output
         FROM
         dz_swagger3_cache a
         WHERE
             doc_id    = str_doc_id
         AND group_id  = str_group_id
         AND versionid = str_versionid;
            
      END IF;
      
      RETURN clb_output; 
      
   END json;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION json_pretty(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_refresh_interval    IN  INTERVAL  DAY TO SECOND DEFAULT NULL
      ,p_shorten_logic       IN  VARCHAR2  DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output          CLOB;
      clb_output2         CLOB;
      clb_output3         CLOB;
      str_doc_id          VARCHAR2(255 Char);
      str_group_id        VARCHAR2(255 Char);
      str_versionid       VARCHAR2(40 Char);
      dat_timestamp       TIMESTAMP;
      str_shorten_logic   VARCHAR2(255 Char);

   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------

      --------------------------------------------------------------------------
      -- Step 20     
      -- Determine the default version if not provided
      --------------------------------------------------------------------------
      dz_swagger3_main.startup_defaults(
          p_doc_id        => p_doc_id
         ,p_group_id      => p_group_id
         ,p_versionid     => p_versionid
         ,out_doc_id      => str_doc_id
         ,out_group_id    => str_group_id
         ,out_versionid   => str_versionid
      );
      
      --------------------------------------------------------------------------
      -- Step 30     
      -- Fetch cache if populated
      --------------------------------------------------------------------------
      vintage(
          p_doc_id        => str_doc_id
         ,p_group_id      => str_group_id
         ,p_versionid     => str_versionid
         ,p_timestamp     => dat_timestamp
         ,p_shorten_logic => str_shorten_logic
      );
      
      IF  p_shorten_logic IS NOT NULL
      AND p_shorten_logic <> str_shorten_logic
      THEN
         str_shorten_logic := p_shorten_logic;
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40     
      -- Return results if found
      --------------------------------------------------------------------------
      IF dat_timestamp IS NULL
      OR SYSTIMESTAMP - dat_timestamp > p_refresh_interval
      THEN
         update_cache(
             p_doc_id          => str_doc_id
            ,p_group_id        => str_group_id
            ,p_versionid       => str_versionid
            ,p_shorten_logic   => str_shorten_logic
            ,out_json          => clb_output
            ,out_json_pretty   => clb_output2
            ,out_yaml          => clb_output3
         );
         
      ELSE
         SELECT
         a.json_pretty_payload
         INTO clb_output2
         FROM
         dz_swagger3_cache a
         WHERE
             doc_id    = str_doc_id
         AND group_id  = str_group_id
         AND versionid = str_versionid;
            
      END IF;
      
      RETURN clb_output2;

   END json_pretty;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION yaml(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_refresh_interval    IN  INTERVAL  DAY TO SECOND DEFAULT NULL
      ,p_shorten_logic       IN  VARCHAR2  DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output          CLOB;
      clb_output2         CLOB;
      clb_output3         CLOB;
      str_doc_id          VARCHAR2(255 Char);
      str_group_id        VARCHAR2(255 Char);
      str_versionid       VARCHAR2(40 Char);
      dat_timestamp       TIMESTAMP;
      str_shorten_logic   VARCHAR2(255 Char);

   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------

      --------------------------------------------------------------------------
      -- Step 20     
      -- Determine the default version if not provided
      --------------------------------------------------------------------------
      dz_swagger3_main.startup_defaults(
          p_doc_id        => p_doc_id
         ,p_group_id      => p_group_id
         ,p_versionid     => p_versionid
         ,out_doc_id      => str_doc_id
         ,out_group_id    => str_group_id
         ,out_versionid   => str_versionid
      );
      
      --------------------------------------------------------------------------
      -- Step 30     
      -- Fetch cache if populated
      --------------------------------------------------------------------------
      vintage(
          p_doc_id        => str_doc_id
         ,p_group_id      => str_group_id
         ,p_versionid     => str_versionid
         ,p_timestamp     => dat_timestamp
         ,p_shorten_logic => str_shorten_logic
      );
      
      IF  p_shorten_logic IS NOT NULL
      AND p_shorten_logic <> str_shorten_logic
      THEN
         str_shorten_logic := p_shorten_logic;
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40     
      -- Return results if found
      --------------------------------------------------------------------------
      IF dat_timestamp IS NULL
      OR SYSTIMESTAMP - dat_timestamp > p_refresh_interval
      THEN
         update_cache(
             p_doc_id          => str_doc_id
            ,p_group_id        => str_group_id
            ,p_versionid       => str_versionid
            ,p_shorten_logic   => str_shorten_logic
            ,out_json          => clb_output
            ,out_json_pretty   => clb_output2
            ,out_yaml          => clb_output3
         );
         
      ELSE
         SELECT
         a.yaml_payload
         INTO clb_output3
         FROM
         dz_swagger3_cache a
         WHERE
             doc_id    = str_doc_id
         AND group_id  = str_group_id
         AND versionid = str_versionid;
            
      END IF;
      
      RETURN clb_output3; 
      
   END yaml;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION vintage(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
   ) RETURN TIMESTAMP
   AS
      dat_result          TIMESTAMP;
      str_shorten_logic   VARCHAR2(255 Char);
      
   BEGIN
   
      vintage(
          p_doc_id        => p_doc_id
         ,p_group_id      => p_group_id
         ,p_versionid     => p_versionid
         ,p_timestamp     => dat_result
         ,p_shorten_logic => str_shorten_logic
      );
   
      RETURN dat_result;
      
   END vintage;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE reload_cache(
       p_doc_id              IN  VARCHAR2  DEFAULT NULL
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_shorten_logic       IN  VARCHAR2  DEFAULT NULL
   )
   AS
      clb_output          CLOB;
      clb_output2         CLOB;
      clb_output3         CLOB;
      str_doc_id          VARCHAR2(255 Char);
      str_group_id        VARCHAR2(255 Char);
      str_versionid       VARCHAR2(40 Char);
      
   BEGIN
   
      dz_swagger3_main.startup_defaults(
          p_doc_id        => p_doc_id
         ,p_group_id      => p_group_id
         ,p_versionid     => p_versionid
         ,out_doc_id      => str_doc_id
         ,out_group_id    => str_group_id
         ,out_versionid   => str_versionid
      );      
   
      update_cache(
          p_doc_id          => str_doc_id
         ,p_group_id        => str_group_id
         ,p_versionid       => str_versionid
         ,p_shorten_logic   => p_shorten_logic
         ,out_json          => clb_output
         ,out_json_pretty   => clb_output2
         ,out_yaml          => clb_output3
      );
         
   END reload_cache;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE purge_cache(
       p_doc_id              IN  VARCHAR2  DEFAULT NULL
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
   )
   AS
      str_doc_id          VARCHAR2(255 Char);
      str_group_id        VARCHAR2(255 Char);
      str_versionid       VARCHAR2(40 Char);

   BEGIN
      
      dz_swagger3_main.startup_defaults(
          p_doc_id        => p_doc_id
         ,p_group_id      => p_group_id
         ,p_versionid     => p_versionid
         ,out_doc_id      => str_doc_id
         ,out_group_id    => str_group_id
         ,out_versionid   => str_versionid
      );

      DELETE FROM dz_swagger3_cache
      WHERE
          doc_id    = p_doc_id
      AND group_id  = p_group_id
      AND versionid = p_versionid;

      COMMIT;
      
   END purge_cache;

END dz_swagger3_cache_mgr;
/

CREATE OR REPLACE TYPE BODY dz_swagger3_extrdocs_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_extrdocs_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_extrdocs_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_extrdocs_typ(
       p_externaldoc_id          IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.versionid := p_versionid;
      
      BEGIN
         SELECT
          a.externaldoc_id
         ,a.externaldoc_description
         ,a.externaldoc_url
         INTO
          self.externaldoc_id
         ,self.externaldoc_description
         ,self.externaldoc_url
         FROM
         dz_swagger3_externaldoc a
         WHERE
             a.versionid      = p_versionid
         AND a.externaldoc_id = p_externaldoc_id;
      
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            self.externaldoc_url         := NULL;
            self.externaldoc_description := NULL;
            RETURN;
            
         WHEN OTHERS
         THEN
            RAISE;
            
      END;
      
      RETURN; 
      
   END dz_swagger3_extrdocs_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN
       NULL;
       
   END traverse;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;

      str_pad1 := str_pad;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add name element
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.value2json(
             'description'
            ,self.externaldoc_description
            ,p_pretty_print + 1
         )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional url 
      --------------------------------------------------------------------------
      IF self.externaldoc_url IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'url'
               ,self.externaldoc_url
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
 
      --------------------------------------------------------------------------
      -- Step 100
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output        CLOB;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml description
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty_str(
          'description: ' || dz_swagger3_util.yaml_text(
             self.externaldoc_description
            ,p_pretty_print
         )
         ,p_pretty_print
         ,'  '
      );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional license url
      --------------------------------------------------------------------------
      IF self.externaldoc_url IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'url: ' || dz_swagger3_util.yaml_text(
                self.externaldoc_url
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Cough it out without final line feed
      --------------------------------------------------------------------------
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(10) || '$','');
         
      END IF;
               
      RETURN clb_output;
      
   END toYAML;
   
END;
/

CREATE OR REPLACE TYPE BODY dz_swagger3_example_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_example_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_example_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_example_typ(
       p_example_id              IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS 
   BEGIN
   
      SELECT
       a.example_id
      ,a.example_summary
      ,a.example_description
      ,a.example_value_string
      ,a.example_value_number
      ,a.example_externalValue
      INTO
       self.example_id
      ,self.example_summary
      ,self.example_description
      ,self.example_value_string
      ,self.example_value_number
      ,self.example_externalValue
      FROM
      dz_swagger3_example a
      WHERE
          a.versionid = p_versionid
      AND a.example_id = p_example_id;
   
      RETURN; 
      
   END dz_swagger3_example_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN
      NULL;
      
   END traverse;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_identifier   VARCHAR2(255 Char);
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------

      --------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;
      
      str_pad1 := str_pad;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Add  the ref object
      --------------------------------------------------------------------------
      IF  COALESCE(p_force_inline,'FALSE') = 'FALSE'
      AND p_reference_count > 1
      THEN
         IF p_short_id = 'TRUE'
         THEN
            str_identifier := p_short_identifier;
            
         ELSE
            str_identifier := p_identifier;
            
         END IF;
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                '$ref'
               ,'#/components/examples/' || str_identifier
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
      
      ELSE
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional summary
      --------------------------------------------------------------------------
         IF self.example_summary IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'summary'
                  ,self.example_summary
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional description 
      --------------------------------------------------------------------------
         IF self.example_description IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'description'
                  ,self.example_description
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional value
      --------------------------------------------------------------------------
         IF self.example_value_string IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'value'
                  ,self.example_value_string
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         ELSIF self.example_value_number IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'value'
                  ,self.example_value_number
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add optional externalValue
      --------------------------------------------------------------------------
         IF self.example_externalValue IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'externalValue'
                  ,self.example_externalValue
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
 
      END IF;

      --------------------------------------------------------------------------
      -- Step 70
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output        CLOB;
      str_identifier   VARCHAR2(255 Char);
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Add  the ref object
      --------------------------------------------------------------------------
      IF  COALESCE(p_force_inline,'FALSE') = 'FALSE'
      AND p_reference_count > 1
      THEN
         IF p_short_id = 'TRUE'
         THEN
            str_identifier := p_short_identifier;
            
         ELSE
            str_identifier := p_identifier;
            
         END IF;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             '$ref: ' || dz_swagger3_util.yaml_text(
                '#/components/examples/' || str_identifier
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
      
      ELSE
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml summary
      --------------------------------------------------------------------------
         IF self.example_summary IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'summary: ' || dz_swagger3_util.yaml_text(
                   self.example_summary
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional license url
      --------------------------------------------------------------------------
         IF self.example_description IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'description: ' || dz_swagger3_util.yaml_text(
                   self.example_description
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional value
      --------------------------------------------------------------------------
         IF self.example_value_string IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'value: ' || dz_swagger3_util.yaml_text(
                   self.example_value_string
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         ELSIF self.example_value_number IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'value: ' || dz_swagger3_util.yaml_text(
                   self.example_value_number
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional license url
      --------------------------------------------------------------------------
         IF self.example_externalValue IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'externalValue: ' || dz_swagger3_util.yaml_text(
                   self.example_externalValue
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Cough it out without final line feed
      --------------------------------------------------------------------------
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(10) || '$','');
         
      END IF;
               
      RETURN clb_output;
   
   END toYAML;
   
END;
/

CREATE OR REPLACE TYPE BODY dz_swagger3_encoding_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_encoding_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_encoding_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_encoding_typ(
       p_encoding_id            IN  VARCHAR2
      ,p_versionid              IN  VARCHAR2
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Set up the object
      --------------------------------------------------------------------------
      self.versionid := p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Pull the object information
      --------------------------------------------------------------------------
      SELECT
       a.encoding_id
      ,a.encoding_contentType
      ,a.encoding_style
      ,a.encoding_explode
      ,a.encoding_allowReserved
      INTO
       self.encoding_id
      ,self.encoding_contentType
      ,self.encoding_style 
      ,self.encoding_explode 
      ,self.encoding_allowReserved
      FROM
      dz_swagger3_encoding a
      WHERE
          a.versionid   = p_versionid
      AND a.encoding_id = p_encoding_id;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Collect the response headers
      --------------------------------------------------------------------------
      /*
      SELECT
      dz_swagger3_object_typ(
          p_object_id          => b.header_id
         ,p_object_type_id     => 'headertyp'
         ,p_object_key         => a.header_name
         ,p_object_order       => a.header_order
      )
      BULK COLLECT INTO self.encoding_headers 
      FROM
      dz_swagger3_response_headr_map a
      JOIN
      dz_swagger3_header b
      ON
          a.versionid   = b.versionid
      AND a.header_id   = b.header_id
      WHERE
          a.versionid   = p_versionid
      AND a.response_id = p_encoding_headers;
*/
      --------------------------------------------------------------------------
      -- Step 40
      -- Return the completed object
      --------------------------------------------------------------------------
      RETURN; 
      
   END dz_swagger3_encoding_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Load the external docs
      --------------------------------------------------------------------------
      IF  self.encoding_headers IS NOT NULL
      AND self.encoding_headers.COUNT > 0
      THEN
         dz_swagger3_loader.headertyp(
             p_parent_id    => self.encoding_id
            ,p_children_ids => self.encoding_headers
            ,p_versionid    => self.versionid
         );
      
      END IF;

   END traverse;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      boo_temp         BOOLEAN;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_hash         CLOB;
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional contentType
      --------------------------------------------------------------------------
      str_pad1 := str_pad;
      IF self.encoding_contentType IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'contentType'
               ,self.encoding_contentType
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional encoding headers
      --------------------------------------------------------------------------
      IF  self.encoding_headers IS NOT NULL 
      AND self.encoding_headers.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.headertyp.toJSON( '
         || '    p_pretty_print     => :p01 + 2 '
         || '   ,p_force_inline     => :p02 '
         || '   ,p_short_id         => :p03 '
         || '   ,p_identifier       => a.object_id '
         || '   ,p_short_identifier => a.short_id '
         || '   ,p_reference_count  => a.reference_count '
         || ' ) '
         || ',b.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p01) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      = b.object_id '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.encoding_headers;
      
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('{',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('{',-1);
            
         END IF;
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
               ,p_pretty_print + 1
            );
            str_pad2 := ',';
         
         END LOOP;
         
         clb_hash := clb_hash || dz_json_util.pretty(
             '}'
            ,p_pretty_print + 1,NULL,NULL
         );
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                 'headers'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional encoding style
      --------------------------------------------------------------------------
      IF self.encoding_style IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'style'
               ,self.encoding_style
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add optional explode boolean
      --------------------------------------------------------------------------
      IF self.encoding_explode IS NOT NULL
      THEN
         IF LOWER(self.encoding_explode) = 'true'
         THEN
            boo_temp := TRUE;
            
         ELSE
            boo_temp := FALSE;
            
         END IF;
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'explode'
               ,boo_temp
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Add optional encoding allowReserved
      --------------------------------------------------------------------------
      IF self.encoding_allowReserved IS NOT NULL
      THEN
         IF LOWER(self.encoding_allowReserved) = 'true'
         THEN
            boo_temp := TRUE;
            
         ELSE
            boo_temp := FALSE;
            
         END IF;
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'allowReserved'
               ,boo_temp
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
 
      --------------------------------------------------------------------------
      -- Step 80
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml summary
      --------------------------------------------------------------------------
      IF self.encoding_contentType IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'contentType: ' || dz_swagger3_util.yaml_text(
                self.encoding_contentType
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional license url
      --------------------------------------------------------------------------
      IF  self.encoding_headers IS NOT NULL 
      AND self.encoding_headers.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.headertyp.toYAML( '
         || '    p_pretty_print     => :p01 + 3 '
         || '   ,p_force_inline     => :p02 '
         || '   ,p_short_id         => :p03 '
         || '   ,p_identifier       => a.object_id '
         || '   ,p_short_identifier => a.short_id '
         || '   ,p_reference_count  => a.reference_count '
         || ' ) '
         || ',b.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p01) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      = b.object_id '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.encoding_headers;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'headers: '
            ,p_pretty_print + 1
            ,'  '
         );
         
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '''' || ary_keys(i) || ''': '
               ,p_pretty_print + 2
               ,'  '
            ) || ary_clb(i);
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the optional encoding style element
      --------------------------------------------------------------------------
      IF self.encoding_style IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'style: ' || dz_swagger3_util.yaml_text(
                self.encoding_style
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the optional encoding explode element
      --------------------------------------------------------------------------
      IF self.encoding_explode IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'explode: ' || LOWER(self.encoding_explode)
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Write the optional allowReserved element
      --------------------------------------------------------------------------
      IF self.encoding_allowReserved IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'allowReserved: ' || LOWER(self.encoding_allowReserved)
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Cough it out without final line feed
      --------------------------------------------------------------------------
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(10) || '$','');
         
      END IF;
               
      RETURN clb_output;
      
   END toYAML;
   
END;
/

CREATE OR REPLACE TYPE BODY dz_swagger3_header_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_header_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_header_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_header_typ(
       p_header_id               IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Initialize the object
      --------------------------------------------------------------------------
      self.versionid := p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Pull the attributes
      --------------------------------------------------------------------------
      SELECT
       a.header_id
      ,a.header_description
      ,a.header_required
      ,a.header_deprecated
      ,a.header_allowEmptyValue
      ,a.header_style
      ,a.header_explode
      ,a.header_allowReserved
      ,dz_swagger3_object_typ(
          p_object_id         => a.header_schema_id
         ,p_object_type_id    => 'schematyp'
         ,p_object_required   => 'TRUE'
       )
      ,a.header_example_string
      ,a.header_example_number
      INTO
       self.header_id
      ,self.header_description
      ,self.header_required
      ,self.header_deprecated
      ,self.header_allowEmptyValue
      ,self.header_style
      ,self.header_explode
      ,self.header_allowReserved
      ,self.header_schema
      ,self.header_example_string
      ,self.header_example_number
      FROM
      dz_swagger3_header a
      WHERE
          a.versionid = p_versionid
      AND a.header_id = p_header_id;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Pull the examples
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id      => a.example_id
         ,p_object_type_id => 'exampletyp'
         ,p_object_order   => a.example_order
      )
      BULK COLLECT INTO self.header_examples
      FROM
      dz_swagger3_parent_example_map a
      WHERE
          a.parent_id = p_header_id
      AND a.versionid = p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Return then object
      --------------------------------------------------------------------------
      RETURN; 
      
   END dz_swagger3_header_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Traverse the schema
      --------------------------------------------------------------------------
      IF  self.header_schema IS NOT NULL
      AND self.header_schema.object_id IS NOT NULL
      THEN
         dz_swagger3_loader.schematyp(
             p_parent_id    => self.header_id
            ,p_children_ids => dz_swagger3_object_vry(self.header_schema)
            ,p_versionid    => self.versionid
         );
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Traverse the examples
      --------------------------------------------------------------------------
      IF  self.header_examples IS NOT NULL
      AND self.header_examples.COUNT > 0
      THEN
         dz_swagger3_loader.headertyp(
             p_parent_id    => self.header_id
            ,p_children_ids => self.header_examples
            ,p_versionid    => self.versionid
         );
      
      END IF;
      
   END traverse;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      boo_temp         BOOLEAN;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_hash         CLOB;
      clb_tmp          CLOB;
      str_identifier   VARCHAR2(255 Char);
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;
      
      str_pad1 := str_pad;

      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      IF  COALESCE(p_force_inline,'FALSE') = 'FALSE'
      AND p_reference_count > 1
      THEN
         IF p_short_id = 'TRUE'
         THEN
            str_identifier := p_short_identifier;
            
         ELSE
            str_identifier := p_identifier;
            
         END IF;
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                '$ref'
               ,'#/components/headers/' || str_identifier
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
      
      ELSE
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional summary
      --------------------------------------------------------------------------
         IF self.header_description IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'description'
                  ,self.header_description
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional description 
      --------------------------------------------------------------------------
         IF self.header_required IS NOT NULL
         THEN
            IF LOWER(self.header_required) = 'true'
            THEN
               boo_temp := TRUE;
               
            ELSE
               boo_temp := FALSE;
               
            END IF;
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'required'
                  ,boo_temp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
         
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional description 
      --------------------------------------------------------------------------
         IF self.header_deprecated IS NOT NULL
         THEN
            IF LOWER(self.header_deprecated) = 'true'
            THEN
               boo_temp := TRUE;
               
            ELSE
               boo_temp := FALSE;
               
            END IF;
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'deprecated'
                  ,boo_temp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add optional description 
      --------------------------------------------------------------------------
         IF self.header_allowEmptyValue IS NOT NULL
         THEN
            IF LOWER(self.header_allowEmptyValue) = 'true'
            THEN
               boo_temp := TRUE;
               
            ELSE
               boo_temp := FALSE;
               
            END IF;
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'allowEmptyValue'
                  ,boo_temp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Add optional value
      --------------------------------------------------------------------------
         IF self.header_style IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'style'
                  ,self.header_style
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Add optional description 
      --------------------------------------------------------------------------
         IF self.header_explode IS NOT NULL
         THEN
            IF LOWER(self.header_explode) = 'true'
            THEN
               boo_temp := TRUE;
               
            ELSE
               boo_temp := FALSE;
               
            END IF;
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'explode'
                  ,boo_temp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Add optional description 
      --------------------------------------------------------------------------
         IF self.header_allowReserved IS NOT NULL
         THEN
            IF LOWER(self.header_allowReserved) = 'true'
            THEN
               boo_temp := TRUE;
               
            ELSE
               boo_temp := FALSE;
               
            END IF;
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'allowReserved'
                  ,boo_temp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Add optional externalValue
      --------------------------------------------------------------------------
         IF self.header_schema IS NOT NULL
         THEN
            BEGIN
               EXECUTE IMMEDIATE
                  'SELECT '
               || 'a.schematyp.toJSON( '
               || '    p_pretty_print     => :p01 + 1 '
               || '   ,p_force_inline     => :p02 '
               || '   ,p_short_id         => :p03 '
               || '   ,p_identifier       => a.object_id '
               || '   ,p_short_identifier => a.short_id '
               || '   ,p_reference_count  => a.reference_count '
               || ') '
               || 'FROM '
               || 'dz_swagger3_xobjects a '
               || 'WHERE '
               || '    a.object_type_id = :p04 '
               || 'AND a.object_id      = :p05 '
               INTO clb_tmp
               USING 
                p_pretty_print
               ,p_force_inline
               ,p_short_id
               ,self.header_schema.object_type_id
               ,self.header_schema.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                   'schema'
                  ,clb_tmp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Add optional example
      --------------------------------------------------------------------------
         IF self.header_example_string IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'example'
                  ,self.header_example_string
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         ELSIF self.header_example_number IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'example'
                  ,self.header_example_number
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Add optional variables map
      --------------------------------------------------------------------------
         IF  self.header_examples IS NOT NULL 
         AND self.header_examples.COUNT > 0
         THEN
            EXECUTE IMMEDIATE
               'SELECT '
            || ' a.exampletyp.toJSON( '
            || '    p_pretty_print     => :p01 + 2 '
            || '   ,p_force_inline     => :p02 '
            || '   ,p_short_id         => :p03 '
            || '   ,p_identifier       => a.object_id '
            || '   ,p_short_identifier => a.short_id '
            || '   ,p_reference_count  => a.reference_count '
            || ' ) '
            || ',b.object_key '
            || 'FROM '
            || 'dz_swagger3_xobjects a '
            || 'JOIN '
            || 'TABLE(:p04) b '
            || 'ON '
            || '    a.object_type_id = b.object_type_id '
            || 'AND a.object_id      = b.object_id '
            || 'ORDER BY b.object_order '
            BULK COLLECT INTO 
             ary_clb
            ,ary_keys
            USING
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.header_examples; 
            
            str_pad2 := str_pad;
            
            IF p_pretty_print IS NULL
            THEN
               clb_hash := dz_json_util.pretty('{',NULL);
               
            ELSE
               clb_hash := dz_json_util.pretty('{',-1);
               
            END IF;
         
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_hash := clb_hash || dz_json_util.pretty(
                   str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                  ,p_pretty_print + 1
               );
               str_pad2 := ',';
            
            END LOOP;
            
            clb_hash := clb_hash || dz_json_util.pretty(
                '}'
               ,p_pretty_print + 1,NULL,NULL
            );
            
         END IF;
            
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                 'examples'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
 
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 130
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 140
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_tmp          CLOB;
      str_identifier   VARCHAR2(255 Char);
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      IF  COALESCE(p_force_inline,'FALSE') = 'FALSE'
      AND p_reference_count > 1
      THEN
         IF p_short_id = 'TRUE'
         THEN
            str_identifier := p_short_identifier;
            
         ELSE
            str_identifier := p_identifier;
            
         END IF;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             '$ref: ' || dz_swagger3_util.yaml_text(
                '#/components/headers/' || str_identifier
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
         
      ELSE
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml summary
      --------------------------------------------------------------------------
         IF self.header_description IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'description: ' || dz_swagger3_util.yaml_text(
                   self.header_description
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional license url
      --------------------------------------------------------------------------
         IF self.header_required IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'required: ' || LOWER(self.header_required)
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the optional license url
      --------------------------------------------------------------------------
         IF self.header_deprecated IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'deprecated: ' || LOWER(self.header_deprecated)
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the optional license url
      --------------------------------------------------------------------------
         IF self.header_allowEmptyValue IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'allowEmptyValue: ' || LOWER(self.header_allowEmptyValue)
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Write the yaml summary
      --------------------------------------------------------------------------
         IF self.header_style IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'style: ' || dz_swagger3_util.yaml_text(
                   self.header_style
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Write the optional license url
      --------------------------------------------------------------------------
         IF self.header_explode IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'explode: ' || LOWER(self.header_explode)
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Write the optional license url
      --------------------------------------------------------------------------
         IF self.header_allowReserved IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'allowReserved: ' || LOWER(self.header_allowReserved)
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Write the optional info license object
      --------------------------------------------------------------------------
         IF self.header_schema IS NOT NULL
         THEN
            BEGIN
               EXECUTE IMMEDIATE
                  'SELECT '
               || 'a.schematyp.toYAML( '
               || '    p_pretty_print     => :p01 + 1 '
               || '   ,p_force_inline     => :p02 '
               || '   ,p_short_id         => :p03 '
               || '   ,p_identifier       => a.object_id '
               || '   ,p_short_identifier => a.short_id '
               || '   ,p_reference_count  => a.reference_count '
               || ') '
               || 'FROM '
               || 'dz_swagger3_xobjects a '
               || 'WHERE '
               || '    a.object_type_id = :p04 '
               || 'AND a.object_id      = :p05 '
               INTO clb_tmp
               USING 
                p_pretty_print
               ,p_force_inline
               ,p_short_id
               ,self.header_schema.object_type_id
               ,self.header_schema.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;
            
            clb_output := clb_output || dz_json_util.pretty_str(
                'schema: '
               ,p_pretty_print
               ,'  '
            ) || clb_tmp;
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Write the optional value
      --------------------------------------------------------------------------
         IF self.header_example_string IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'example: ' || dz_swagger3_util.yaml_text(
                   self.header_example_string
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         ELSIF self.header_example_number IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'example: ' || dz_swagger3_util.yaml_text(
                   self.header_example_number
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Write the optional variables map
      --------------------------------------------------------------------------
         IF  self.header_examples IS NULL 
         AND self.header_examples.COUNT = 0
         THEN
            EXECUTE IMMEDIATE
               'SELECT '
            || ' a.exampletyp.toYAML( '
            || '    p_pretty_print     => :p01 + 2 '
            || '   ,p_force_inline     => :p02 '
            || '   ,p_short_id         => :p03 '
            || '   ,p_identifier       => a.object_id '
            || '   ,p_short_identifier => a.short_id '
            || '   ,p_reference_count  => a.reference_count '
            || ' ) '
            || ',b.object_key '
            || 'FROM '
            || 'dz_swagger3_xobjects a '
            || 'JOIN '
            || 'TABLE(:p01) b '
            || 'ON '
            || '    a.object_type_id = b.object_type_id '
            || 'AND a.object_id      = b.object_id '
            || 'ORDER BY b.object_order '
            BULK COLLECT INTO 
             ary_clb
            ,ary_keys
            USING
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.header_examples;
         
            clb_output := clb_output || dz_json_util.pretty_str(
                'examples: '
               ,p_pretty_print + 1
               ,'  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   '''' || ary_keys(i) || ''': '
                  ,p_pretty_print + 2
                  ,'  '
               ) || ary_clb(i);
            
            END LOOP;
            
         END IF;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Cough it out without final line feed
      --------------------------------------------------------------------------
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(10) || '$','');
         
      END IF;
               
      RETURN clb_output;
      
   END toYAML;
   
END;
/

CREATE OR REPLACE TYPE BODY dz_swagger3_oauth_flow_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_oauth_flow_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_oauth_flow_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_oauth_flow_typ(
       p_oauth_authorizationUrl  IN  VARCHAR2
      ,p_oauth_tokenUrl          IN  VARCHAR2
      ,p_oauth_refreshUrl        IN  VARCHAR2
      ,p_oauth_scopes            IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_string_hash_list
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.oauth_authorizationUrl   := p_oauth_authorizationUrl;
      self.oauth_tokenUrl           := p_oauth_tokenUrl;
      self.oauth_refreshUrl         := p_oauth_refreshUrl;
      self.oauth_scopes             := p_oauth_scopes;      
      
      RETURN; 
      
   END dz_swagger3_oauth_flow_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      clb_hash         CLOB;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;
      
      str_pad1 := str_pad;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add authorizationUrl
      --------------------------------------------------------------------------
      IF self.oauth_authorizationUrl IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'authorizationUrl'
               ,self.oauth_authorizationUrl
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Add tokenUrl
      --------------------------------------------------------------------------
      IF self.oauth_tokenUrl IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'tokenUrl'
               ,self.oauth_tokenUrl
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add refreshUrl
      --------------------------------------------------------------------------
      IF self.oauth_refreshUrl IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'refreshUrl'
               ,self.oauth_refreshUrl
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add optional parameter map
      --------------------------------------------------------------------------
      IF self.oauth_scopes IS NOT NULL
      AND self.oauth_scopes.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.stringhashtyp.toJSON( '
         || '    p_pretty_print   => :p01 + 2 '
         || '   ,p_force_inline   => :p02 '
         || '   ,p_short_id       => :p03 '
         || ' ) '
         || ',a.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || 'a.object_id IN (SELECT column_name FROM TABLE(:p03)) '
         || 'ORDER BY a.ordering_key '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.oauth_scopes;
         
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('{',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('{',-1);
            
         END IF;
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
               ,p_pretty_print + 1
            );
            str_pad2 := ',';
         
         END LOOP;
         
         clb_hash := clb_hash || dz_json_util.pretty(
             '}'
            ,p_pretty_print + 1,NULL,NULL
         );
         
      END IF;
         
      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.formatted2json(
              'scopes'
             ,clb_hash
             ,p_pretty_print + 1
          )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';
         
      --------------------------------------------------------------------------
      -- Step 70
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write yaml authorizationUrl
      --------------------------------------------------------------------------
      IF self.oauth_authorizationUrl IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'authorizationUrl: ' || dz_swagger3_util.yaml_text(
                self.oauth_authorizationUrl
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write yaml tokenUrl
      --------------------------------------------------------------------------
      IF self.oauth_authorizationUrl IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'tokenUrl: ' || dz_swagger3_util.yaml_text(
                self.oauth_tokenUrl
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write yaml refreshUrl
      --------------------------------------------------------------------------
      IF self.oauth_authorizationUrl IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'refreshUrl: ' || dz_swagger3_util.yaml_text(
                self.oauth_refreshUrl
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write flows authorizationCode
      --------------------------------------------------------------------------
      IF  self.oauth_scopes IS NOT NULL 
      AND self.oauth_scopes.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.stringhashtyp.toYAML( '
         || '    p_pretty_print   => :p01 + 2 '
         || '   ,p_force_inline   => :p02 '
         || '   ,p_short_id       => :p03 '
         || ' ) '
         || ',a.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || 'a.object_id IN (SELECT column_name FROM TABLE(:p03)) '
         || 'ORDER BY a.ordering_key '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.oauth_scopes;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'scopes: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '''' || ary_keys(i) || ''': '
               ,p_pretty_print + 1
               ,'  '
            ) || ary_clb(i);
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Cough it out without final line feed
      --------------------------------------------------------------------------
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(10) || '$','');
         
      END IF;
               
      RETURN clb_output;
      
   END toYAML;
   
END;
/

CREATE OR REPLACE TYPE BODY dz_swagger3_media_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_media_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_media_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_media_typ(
       p_media_id                IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Initialize the object
      --------------------------------------------------------------------------
      self.versionid := p_versionid;

      --------------------------------------------------------------------------
      -- Step 20
      -- Pull the object information
      --------------------------------------------------------------------------
      SELECT
       a.media_id
      ,dz_swagger3_object_typ(
          p_object_id      => a.media_schema_id
         ,p_object_type_id => 'schematyp'
       )
      ,a.media_example_string
      ,a.media_example_number
      INTO
       self.media_id
      ,self.media_schema
      ,self.media_example_string
      ,self.media_example_number
      FROM
      dz_swagger3_media a
      WHERE
          a.versionid = p_versionid
      AND a.media_id  = p_media_id;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Pull any examples
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id      => a.example_id
         ,p_object_type_id => 'exampletyp'
         ,p_object_order   => a.example_order
      )
      BULK COLLECT INTO self.media_examples
      FROM
      dz_swagger3_parent_example_map a
      JOIN
      dz_swagger3_example b
      ON
          a.example_id  = b.example_id
      AND a.versionid   = b.versionid
      WHERE
          a.versionid   = p_versionid
      AND a.parent_id   = p_media_id;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Pull any encodings
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id      => a.encoding_id
         ,p_object_type_id => 'encodingtyp'
         ,p_object_order   => a.encoding_order
      )
      BULK COLLECT INTO self.media_encoding
      FROM
      dz_swagger3_media_encoding_map a
      JOIN
      dz_swagger3_encoding b
      ON
          a.encoding_id = b.encoding_id
      AND a.versionid   = b.versionid
      WHERE
          a.versionid   = p_versionid
      AND a.media_id   = p_media_id;
      
      RETURN; 
      
   END dz_swagger3_media_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_media_typ(
       p_media_id                 IN  VARCHAR2
      ,p_parameters               IN  dz_swagger3_object_vry --dz_swagger3_parameter_list
      ,p_versionid                IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Initialize the object
      --------------------------------------------------------------------------
      self.versionid    := p_versionid;

      --------------------------------------------------------------------------
      -- Step 20
      -- Emulate the post request body
      --------------------------------------------------------------------------
      self.media_id     := p_media_id;
      self.media_schema := dz_swagger3_object_typ(
          p_object_id      => 'sc.' || p_media_id
         ,p_object_type_id => 'schematyp'
         ,p_object_subtype => 'emulated'
      );
      self.media_emulated_parms := p_parameters;
      
      RETURN;
         
   END dz_swagger3_media_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Load the media schema
      --------------------------------------------------------------------------
      IF self.media_schema.object_subtype = 'emulated'
      THEN
         dz_swagger3_loader.schematyp_emulated(
             p_parent_id     => self.media_id
            ,p_child_id      => self.media_schema
            ,p_parameter_ids => self.media_emulated_parms
            ,p_versionid     => self.versionid
         );
         
      ELSE
         dz_swagger3_loader.schematyp(
             p_parent_id     => self.media_id
            ,p_children_ids  => dz_swagger3_object_vry(self.media_schema)
            ,p_versionid     => self.versionid
         );

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Load the examples
      --------------------------------------------------------------------------
      IF  self.media_examples IS NOT NULL
      AND self.media_examples.COUNT > 0
      THEN
         dz_swagger3_loader.mediatyp(
             p_parent_id    => self.media_id
            ,p_children_ids => self.media_examples
            ,p_versionid    => self.versionid
         );
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Load the encoding
      --------------------------------------------------------------------------
      IF  self.media_encoding IS NOT NULL
      AND self.media_encoding.COUNT > 0
      THEN
         dz_swagger3_loader.encodingtyp(
             p_parent_id    => self.media_id
            ,p_children_ids => self.media_encoding
            ,p_versionid    => self.versionid
         );
      
      END IF;

   END traverse;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      boo_temp         BOOLEAN;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_hash         CLOB;
      clb_tmp          CLOB;
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;
      
      str_pad1 := str_pad;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add schema object
      --------------------------------------------------------------------------
      IF  self.media_schema IS NOT NULL
      AND self.media_schema.object_id IS NOT NULL
      THEN
         BEGIN
            SELECT 
            a.schematyp.toJSON( 
                p_pretty_print     => p_pretty_print + 1 
               ,p_force_inline     => p_force_inline
               ,p_short_id         => p_short_id
               ,p_identifier       => a.object_id 
               ,p_short_identifier => a.short_id 
               ,p_reference_count  => a.reference_count 
            )
            INTO clb_tmp
            FROM 
            dz_swagger3_xobjects a 
            WHERE 
                a.object_type_id = self.media_schema.object_type_id
            AND a.object_id      = self.media_schema.object_id; 
            
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_tmp := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'schema'
               ,clb_tmp
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional example
      --------------------------------------------------------------------------
      IF self.media_example_string IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'example'
               ,self.media_example_string
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      ELSIF self.media_example_number IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'example'
               ,self.media_example_number
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Add optional examples map
      --------------------------------------------------------------------------
      IF  self.media_examples IS NOT NULL 
      AND self.media_examples.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.exampletyp.toJSON( '
         || '    p_pretty_print     => :p01 + 1 '
         || '   ,p_force_inline     => :p02 '
         || '   ,p_short_id         => :p03 '
         || '   ,p_identifier       => a.object_id '
         || '   ,p_short_identifier => a.short_id '
         || '   ,p_reference_count  => a.reference_count '
         || ' ) '
         || ',b.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p04) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      = b.object_id '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.media_examples;
         
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('{',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('{',-1);
            
         END IF;
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
               ,p_pretty_print + 1
            );
            str_pad2 := ',';
         
         END LOOP;
         
         clb_hash := clb_hash || dz_json_util.pretty(
             '}'
            ,p_pretty_print + 1,NULL,NULL
         );
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                 'examples'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Add optional encoding map
      --------------------------------------------------------------------------
      IF  self.media_encoding IS NOT NULL 
      AND self.media_encoding.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.encodingtyp.toJSON( '
         || '    p_pretty_print   => :p01 + 1 '
         || '   ,p_force_inline   => :p02 '
         || '   ,p_short_id       => :p03 '
         || ' ) '
         || ',b.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p04) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      = b.object_id '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.media_encoding;
         
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('{',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('{',-1);
            
         END IF;
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
               ,p_pretty_print + 1
            );
            str_pad2 := ',';
         
         END LOOP;
         
         clb_hash := clb_hash || dz_json_util.pretty(
             '}'
            ,p_pretty_print + 1,NULL,NULL
         );
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                 'encoding'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 60
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_tmp          CLOB;
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml schema object
      --------------------------------------------------------------------------
      IF self.media_schema IS NOT NULL
      AND self.media_schema.object_id IS NOT NULL
      THEN
         BEGIN
            EXECUTE IMMEDIATE
               'SELECT a.schematyp.toYAML( '
            || '    p_pretty_print     => :p01 + 1 '
            || '   ,p_force_inline     => :p02 '
            || '   ,p_short_id         => :p03 '
            || '   ,p_identifier       => a.object_id '
            || '   ,p_short_identifier => a.short_id '
            || '   ,p_reference_count  => a.reference_count ' 
            || ') FROM '
            || 'dz_swagger3_xobjects a '
            || 'WHERE '
            || '    a.object_type_id = :p04 '
            || 'AND a.object_id      = :p05 '
            INTO clb_tmp
            USING 
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.media_schema.object_type_id
            ,self.media_schema.object_id; 
            
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_tmp := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'schema: ' 
            ,p_pretty_print
            ,'  '
         ) || clb_tmp;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the yaml example item
      --------------------------------------------------------------------------
      IF self.media_example_string IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'example: ' || dz_swagger3_util.yaml_text(
                self.media_example_string
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      ELSIF self.media_example_number IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'example: ' || dz_swagger3_util.yaml_text(
                self.media_example_number
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the optional variables map
      --------------------------------------------------------------------------
      IF  self.media_examples IS NOT NULL 
      AND self.media_examples.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.exampletyp.toYAML( '
         || '    p_pretty_print     => :p01 + 3 '
         || '   ,p_force_inline     => :p02 '
         || '   ,p_short_id         => :p03 '
         || '   ,p_identifier       => a.object_id '
         || '   ,p_short_identifier => a.short_id '
         || '   ,p_reference_count  => a.reference_count '
         || ' ) '
         || ',b.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p04) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      = b.object_id '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.media_examples;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'examples: '
            ,p_pretty_print + 1
            ,'  '
         );
         
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '''' || ary_keys(i) || ''': '
               ,p_pretty_print + 2
               ,'  '
            ) || ary_clb(i);
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the optional variables map
      --------------------------------------------------------------------------
      IF  self.media_encoding IS NOT NULL 
      AND self.media_encoding.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.encodingtyp.toYAML( '
         || '    p_pretty_print   => :p01 + 3 '
         || '   ,p_force_inline   => :p02 '
         || '   ,p_short_id       => :p03 '
         || ' ) '
         || ',b.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p04) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      = b.object_id '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.media_encoding;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'encoding: '
            ,p_pretty_print + 1
            ,'  '
         );
         
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '''' || ary_keys(i) || ''': '
               ,p_pretty_print + 2
               ,'  '
            ) || ary_clb(i);
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Cough it out 
      --------------------------------------------------------------------------
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(10) || '$','');
         
      END IF;
               
      RETURN clb_output;
      
   END toYAML;

END;
/

CREATE OR REPLACE TYPE BODY dz_swagger3_link_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_link_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_link_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_link_typ(
       p_link_id                 IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Initialize the object
      --------------------------------------------------------------------------
      self.versionid := p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Fetch component items
      --------------------------------------------------------------------------
      SELECT
       a.link_id
      ,a.link_operationRef
      ,a.link_operationId
      ,CASE
       WHEN a.link_server_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id      => a.link_server_id
            ,p_object_type_id => 'servertyp'
         )
       ELSE
         NULL
       END
      INTO
       self.link_id
      ,self.link_operationRef
      ,self.link_operationId
      ,self.link_server
      FROM
      dz_swagger3_link a
      WHERE
          a.versionid = p_versionid
      AND a.link_id   = p_link_id;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Fetch hash string parameters
      --------------------------------------------------------------------------
      

      --------------------------------------------------------------------------
      -- Step 40
      -- Return completed object
      --------------------------------------------------------------------------
      RETURN; 
      
   END dz_swagger3_link_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Load the tags
      --------------------------------------------------------------------------
      IF  self.link_parameters IS NOT NULL
      AND self.link_parameters.COUNT > 0
      THEN
         dz_swagger3_loader.parametertyp(
             p_parent_id    => self.link_id
            ,p_children_ids => self.link_parameters
            ,p_versionid    => self.versionid
         );
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Load the server
      --------------------------------------------------------------------------
      IF  self.link_server IS NOT NULL
      AND self.link_server.object_id IS NOT NULL
      THEN
         dz_swagger3_loader.servertyp(
             p_parent_id    => self.link_id
            ,p_children_ids => dz_swagger3_object_vry(self.link_server)
            ,p_versionid    => self.versionid
         );
      
      END IF;

   END traverse;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      clb_hash         CLOB;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_tmp          CLOB;
      str_identifier   VARCHAR2(255 Char);
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;
      
      str_pad1 := str_pad;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Add  the ref object
      --------------------------------------------------------------------------
      IF  COALESCE(p_force_inline,'FALSE') = 'FALSE'
      AND p_reference_count > 1
      THEN
         IF p_short_id = 'TRUE'
         THEN
            str_identifier := p_short_identifier;
            
         ELSE
            str_identifier := p_identifier;
            
         END IF;
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                '$ref'
               ,'#/components/links/' || str_identifier
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      ELSE      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional operationRef
      --------------------------------------------------------------------------
         IF self.link_operationRef IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'operationRef'
                  ,self.link_operationRef
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional operationId
      --------------------------------------------------------------------------
         IF self.link_operationId IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'operationId'
                  ,self.link_operationId
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional parameter map
      --------------------------------------------------------------------------
         IF  self.link_parameters IS NOT NULL
         AND self.link_parameters.COUNT > 0
         THEN
            EXECUTE IMMEDIATE 
               'SELECT '
            || ' a.parameteryp.toJSON( '
            || '    p_pretty_print     => :p01 + 2 '
            || '   ,p_force_inline     => :p02 '
            || '   ,p_short_id         => :p03 '
            || '   ,p_identifier       => a.object_id '
            || '   ,p_short_identifier => a.short_id '
            || '   ,p_reference_count  => a.reference_count '
            || ' ) '
            || ',b.object_key '
            || 'FROM '
            || 'dz_swagger3_xobjects a '
            || 'JOIN '
            || 'TABLE(:p04) b '
            || 'ON '
            || '    a.object_type_id = b.object_type_id '
            || 'AND a.object_id      = b.object_id '
            || 'WHERE '
            || 'COALESCE(a.parametertyp.parameter_list_hidden,''FALSE'') <> ''TRUE'' '
            || 'ORDER BY b.object_order '
            BULK COLLECT INTO
             ary_clb
            ,ary_keys
            USING 
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.link_parameters;
         
            IF  ary_keys IS NOT NULL
            AND ary_keys.COUNT > 0
            THEN
               str_pad2 := str_pad;
               
               IF p_pretty_print IS NULL
               THEN
                  clb_hash := dz_json_util.pretty('{',NULL);
                  
               ELSE
                  clb_hash := dz_json_util.pretty('{',-1);
                  
               END IF;
            
               FOR i IN 1 .. ary_keys.COUNT
               LOOP
                  clb_hash := clb_hash || dz_json_util.pretty(
                      str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                     ,p_pretty_print + 1
                  );
                  str_pad2 := ',';
               
               END LOOP;
               
               clb_hash := clb_hash || dz_json_util.pretty(
                   '}'
                  ,p_pretty_print + 1,NULL,NULL
               );
               
               clb_output := clb_output || dz_json_util.pretty(
                   str_pad1 || dz_json_main.formatted2json(
                       'parameters'
                      ,clb_hash
                      ,p_pretty_print + 1
                   )
                  ,p_pretty_print + 1
               );
               str_pad1 := ',';
               
            END IF;
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add optional requestBody
      --------------------------------------------------------------------------
         IF self.link_operationId IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'requestBody'
                  ,self.link_requestBody
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Add optional description
      --------------------------------------------------------------------------
         IF self.link_description IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'description'
                  ,self.link_description
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Add server object
      --------------------------------------------------------------------------
         IF self.link_server IS NOT NULL
         THEN
            BEGIN
               EXECUTE IMMEDIATE 
                  'SELECT '
               || 'a.servertyp.toJSON( '
               || '    p_pretty_print  => :p01 + 1 '
               || '   ,p_force_inline  => :p02 '
               || '   ,p_short_id      => :p03 '
               || ') '
               || 'FROM dz_swagger3_xobjects a '
               || 'WHERE '
               || '    a.object_type_id = :p04 '
               || 'AND a.object_id      = :p05 '
               INTO clb_tmp
               USING
                p_pretty_print
               ,p_force_inline
               ,p_short_id
               ,self.link_server.object_type_id
               ,self.link_server.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;

            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                   'server'
                  ,clb_tmp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
 
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_tmp          CLOB;
      str_identifier   VARCHAR2(255 Char);
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      IF  COALESCE(p_force_inline,'FALSE') = 'FALSE'
      AND p_reference_count > 1
      THEN
         IF p_short_id = 'TRUE'
         THEN
            str_identifier := p_short_identifier;
            
         ELSE
            str_identifier := p_identifier;
            
         END IF;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             '$ref: ' || dz_swagger3_util.yaml_text(
                '#/components/links/' || str_identifier
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      ELSE
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the required operationRef
      --------------------------------------------------------------------------
         IF self.link_operationRef IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'operationRef: ' || dz_swagger3_util.yaml_text(
                   self.link_operationRef
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional operationId
      --------------------------------------------------------------------------
         IF self.link_operationId IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'operationId: ' || dz_swagger3_util.yaml_text(
                   self.link_operationId
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional parameter map
      --------------------------------------------------------------------------
         IF  self.link_parameters IS NULL 
         AND self.link_parameters.COUNT = 0
         THEN
            EXECUTE IMMEDIATE 
               'SELECT '
            || ' a.parametertyp.toYAML( '
            || '    p_pretty_print  => :p01 + 2 '
            || '   ,p_force_inline  => :p02 '
            || '   ,p_short_id      => :p03 '
            || '   ,p_identifier       => a.object_id '
            || '   ,p_short_identifier => a.short_id '
            || '   ,p_reference_count  => a.reference_count '
            || ' ) '
            || ',b.object_key '
            || 'FROM '
            || 'dz_swagger3_xobjects a '
            || 'JOIN '
            || 'TABLE(:p01) b '
            || 'ON '
            || '    a.object_type_id = b.object_type_id '
            || 'AND a.object_id      = b.object_id '
            || 'WHERE '
            || 'COALESCE(a.parametertyp.parameter_list_hidden,''FALSE'') <> ''TRUE'' '
            || 'ORDER BY b.object_order '
            BULK COLLECT INTO
             ary_clb
            ,ary_keys
            USING 
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.link_parameters;
         
            IF  ary_keys IS NOT NULL
            AND ary_keys.COUNT > 0
            THEN
               clb_output := clb_output || dz_json_util.pretty_str(
                   'parameters: '
                  ,p_pretty_print + 1
                  ,'  '
               );

               FOR i IN 1 .. ary_keys.COUNT
               LOOP
                  clb_output := clb_output || dz_json_util.pretty(
                      '''' || ary_keys(i) || ''': '
                     ,p_pretty_print + 1
                     ,'  '
                  ) || ary_clb(i);
               
               END LOOP;
             
            END IF;
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the optional requestBody
      --------------------------------------------------------------------------
         IF self.link_requestBody IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'requestBody: ' || dz_swagger3_util.yaml_text(
                   self.link_requestBody
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Write the optional operationId
      --------------------------------------------------------------------------
         IF self.link_description IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'description: ' || dz_swagger3_util.yaml_text(
                   self.link_description
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the server object
      --------------------------------------------------------------------------
         IF self.link_server IS NOT NULL
         THEN
            BEGIN
               EXECUTE IMMEDIATE 
                  'SELECT '
               || 'a.servertyp.toYAML( '
               || '    p_pretty_print  => :p01 + 1 '
               || '   ,p_force_inline  => :p02 '
               || '   ,p_short_id      => :p03 '
               || ') '
               || 'FROM dz_swagger3_xobjects a '
               || 'WHERE '
               || '    a.object_type_id = :p04 '
               || 'AND a.object_id      = :p05 '
               INTO clb_tmp
               USING
                p_pretty_print
               ,p_force_inline
               ,p_short_id
               ,self.link_server.object_type_id
               ,self.link_server.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;
         
            clb_output := clb_output || dz_json_util.pretty_str(
                'server: ' 
               ,p_pretty_print
               ,'  '
            ) || clb_tmp;
            
         END IF;
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Cough it out without final line feed
      --------------------------------------------------------------------------
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(10) || '$','');
         
      END IF;
               
      RETURN clb_output;
      
   END toYAML;
   
END;
/

CREATE OR REPLACE TYPE BODY dz_swagger3_oauth_flows_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_oauth_flows_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_oauth_flows_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_oauth_flows_typ(
       p_flows_implicit          IN  dz_swagger3_oauth_flow_typ
      ,p_flows_password          IN  dz_swagger3_oauth_flow_typ
      ,p_flows_clientCredentials IN  dz_swagger3_oauth_flow_typ
      ,p_flows_authorizationCode IN  dz_swagger3_oauth_flow_typ
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.flows_implicit          := p_flows_implicit;
      self.flows_password          := p_flows_password;
      self.flows_clientCredentials := p_flows_clientCredentials;
      self.flows_authorizationCode := p_flows_authorizationCode;      
      
      RETURN; 
      
   END dz_swagger3_oauth_flows_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;
      
      str_pad1 := str_pad;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add implicit flow
      --------------------------------------------------------------------------
      IF self.flows_implicit IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'implicit'
               ,self.flows_implicit.toJSON(
                   p_pretty_print   => p_pretty_print + 1
                  ,p_force_inline   => p_force_inline 
                )
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Add password flow
      --------------------------------------------------------------------------
      IF self.flows_password IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'password'
               ,self.flows_password.toJSON(
                   p_pretty_print   => p_pretty_print + 1
                  ,p_force_inline   => p_force_inline 
                )
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add clientCredentials flow
      --------------------------------------------------------------------------
      IF self.flows_clientCredentials IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'clientCredentials'
               ,self.flows_clientCredentials.toJSON(
                   p_pretty_print   => p_pretty_print + 1
                  ,p_force_inline   => p_force_inline 
                )
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add authorizationCode flow
      --------------------------------------------------------------------------
      IF self.flows_authorizationCode IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'authorizationCode'
               ,self.flows_authorizationCode.toJSON(
                   p_pretty_print   => p_pretty_print + 1
                  ,p_force_inline   => p_force_inline 
                )
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
         
      --------------------------------------------------------------------------
      -- Step 70
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output        CLOB;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write flows implicit
      --------------------------------------------------------------------------
      IF self.flows_implicit IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'implicit: '
            ,p_pretty_print
            ,'  '
         ) || self.flows_implicit.toYAML(
             p_pretty_print   => p_pretty_print + 1
            ,p_force_inline   => p_force_inline 
         );  
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write flows password
      --------------------------------------------------------------------------
      IF self.flows_password IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'password: '
            ,p_pretty_print
            ,'  '
         ) || self.flows_password.toYAML(
             p_pretty_print   => p_pretty_print + 1
            ,p_force_inline   => p_force_inline 
         );  
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write flows clientCredentials
      --------------------------------------------------------------------------
      IF self.flows_clientCredentials IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'clientCredentials: '
            ,p_pretty_print
            ,'  '
         ) || self.flows_clientCredentials.toYAML(
             p_pretty_print   => p_pretty_print + 1
            ,p_force_inline   => p_force_inline 
         );  
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write flows authorizationCode
      --------------------------------------------------------------------------
      IF self.flows_authorizationCode IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'authorizationCode: '
            ,p_pretty_print
            ,'  '
         ) || self.flows_authorizationCode.toYAML(
             p_pretty_print   => p_pretty_print + 1
            ,p_force_inline   => p_force_inline 
         );  
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Cough it out without final line feed
      --------------------------------------------------------------------------
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(10) || '$','');
         
      END IF;
               
      RETURN clb_output;
      
   END toYAML;
   
END;
/

CREATE OR REPLACE TYPE BODY dz_swagger3_operation_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_operation_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_operation_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_operation_typ(
       p_operation_id              IN  VARCHAR2
      ,p_versionid                 IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
   BEGIN 
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Set up the object
      --------------------------------------------------------------------------
      self.versionid := p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Load the operation type
      --------------------------------------------------------------------------
      SELECT
       a.operation_id
      ,a.operation_type
      ,a.operation_summary
      ,a.operation_description
      ,CASE
       WHEN a.operation_externaldocs_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id      => a.operation_externaldocs_id
            ,p_object_type_id => 'extrdocstyp'
         )
       ELSE
         NULL
       END
      ,a.operation_operationID
      ,CASE
       WHEN a.operation_requestbody_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id      => a.operation_requestbody_id
            ,p_object_type_id => 'operationtyp'
         )
       ELSE
         NULL
       END
      ,a.operation_inline_rb
      ,a.operation_deprecated
      INTO
       self.operation_id
      ,self.operation_type
      ,self.operation_summary
      ,self.operation_description
      ,self.operation_externalDocs  
      ,self.operation_operationId 
      ,self.operation_requestBody
      ,self.operation_inline_rb 
      ,self.operation_deprecated 
      FROM
      dz_swagger3_operation a
      WHERE
          a.versionid    = p_versionid
      AND a.operation_id = p_operation_id;
      
      self.operation_responses  := NULL;
      self.operation_callbacks  := NULL;
      self.operation_security  := NULL;
      self.operation_servers := NULL;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add any required tags
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id      => a.tag_id
         ,p_object_type_id => 'tagtyp'
         ,p_object_order   => a.tag_order
      )
      BULK COLLECT INTO self.operation_tags
      FROM
      dz_swagger3_operation_tag_map a
      WHERE
          a.versionid    = p_versionid
      AND a.operation_id = p_operation_id;

      --------------------------------------------------------------------------
      -- Step 30
      -- Add any parameters
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id      => a.parameter_id
         ,p_object_type_id => 'parametertyp'
         ,p_object_key     => a.parameter_name
         ,p_object_order   => b.parameter_order
      )
      BULK COLLECT INTO self.operation_parameters
      FROM
      dz_swagger3_parameter a
      JOIN
      dz_swagger3_parent_parm_map b
      ON
          a.versionid = b.versionid
      AND a.parameter_id = b.parameter_id
      WHERE
          b.versionid = p_versionid
      AND b.parent_id = p_operation_id
      AND COALESCE(b.requestbody_flag,'FALSE') = 'FALSE';

      --------------------------------------------------------------------------
      -- Step 40
      -- Check for the condition of being post without a request body
      --------------------------------------------------------------------------
      IF  self.operation_requestBody IS NULL
      AND self.operation_type = 'post'
      THEN
         SELECT
         dz_swagger3_object_typ(
             p_object_id       => a.parameter_id
            ,p_object_type_id  => 'parametertyp'
            ,p_object_key      => a.parameter_name
            ,p_object_required => a.parameter_required
            ,p_object_order    => b.parameter_order
         )
         BULK COLLECT INTO self.operation_emulated_rbparms
         FROM
         dz_swagger3_parameter a
         JOIN
         dz_swagger3_parent_parm_map b
         ON
             a.versionid    = b.versionid
         AND a.parameter_id = b.parameter_id
         WHERE
             b.versionid = p_versionid
         AND b.parent_id = p_operation_id
         AND b.requestbody_flag = 'TRUE';
         
         IF  self.operation_emulated_rbparms IS NOT NULL
         AND self.operation_emulated_rbparms.COUNT > 0
         THEN    
            self.operation_requestBody := dz_swagger3_object_typ(
                p_object_id        => 'rb.' || self.operation_id
               ,p_object_type_id   => 'requestbodytyp'
               ,p_object_subtype   => 'emulated'
               ,p_object_attribute => self.operation_id
            );
         
         END IF;
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 60
      -- Add the responses
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id        => b.response_id
         ,p_object_type_id   => 'responsetyp'
         ,p_object_key       => a.response_code
         ,p_object_order     => a.response_order
      )
      BULK COLLECT INTO self.operation_responses
      FROM
      dz_swagger3_operation_resp_map a
      JOIN
      dz_swagger3_response b
      ON
          a.versionid   = b.versionid
      AND a.response_id = b.response_id
      WHERE
          a.versionid    = p_versionid
      AND a.operation_id = p_operation_id;

      --------------------------------------------------------------------------
      -- Step 70
      -- Add any callbacks
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id        => a.callback_id
         ,p_object_type_id   => 'callbacktyp'
         ,p_object_key       => a.callback_name
         ,p_object_order     => a.callback_order
      )
      BULK COLLECT INTO self.operation_callbacks
      FROM
      dz_swagger3_operation_call_map a
      JOIN
      dz_swagger3_path b
      ON
          a.versionid    = b.versionid
      AND a.callback_id  = b.path_id
      WHERE
          a.versionid    = p_versionid
      AND a.operation_id = p_operation_id;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Add any security
      --------------------------------------------------------------------------
      
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Add any servers
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id      => a.server_id
         ,p_object_type_id => 'servertyp'
         ,p_object_order   => a.server_order
      )
      BULK COLLECT INTO self.operation_servers
      FROM
      dz_swagger3_parent_server_map a
      WHERE
          a.versionid = p_versionid
      AND a.parent_id = p_operation_id;
 
      --------------------------------------------------------------------------
      -- Step 100
      -- Return the completed object
      --------------------------------------------------------------------------
      RETURN;       
      
   END dz_swagger3_operation_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Load the tags
      --------------------------------------------------------------------------
      IF  self.operation_tags IS NOT NULL
      AND self.operation_tags.COUNT > 0
      THEN
         dz_swagger3_loader.tagtyp(
             p_parent_id    => self.operation_id
            ,p_children_ids => self.operation_tags
            ,p_versionid    => self.versionid
         );
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Load the parameters
      --------------------------------------------------------------------------
      IF  self.operation_parameters IS NOT NULL
      AND self.operation_parameters.COUNT > 0
      THEN
         dz_swagger3_loader.parametertyp(
             p_parent_id    => self.operation_id
            ,p_children_ids => self.operation_parameters
            ,p_versionid    => self.versionid
         );
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Load the parameters
      --------------------------------------------------------------------------
      IF  self.operation_requestBody IS NOT NULL
      AND self.operation_requestBody.object_id IS NOT NULL
      THEN
         IF self.operation_requestBody.object_subtype = 'emulated'
         THEN
            dz_swagger3_loader.requestbodytyp_emulated(
                p_parent_id      => self.operation_id
               ,p_child_id       => self.operation_requestBody
               ,p_parameter_ids  => self.operation_emulated_rbparms
               ,p_versionid      => self.versionid
            );

         ELSE
            dz_swagger3_loader.requestbodytyp(
                p_parent_id    => self.operation_id
               ,p_child_id     => self.operation_requestBody
               ,p_versionid    => self.versionid
            );

         END IF;
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Load the responses
      --------------------------------------------------------------------------
      IF  self.operation_responses IS NOT NULL
      AND self.operation_responses.COUNT > 0
      THEN
         dz_swagger3_loader.responsetyp(
             p_parent_id    => self.operation_id
            ,p_children_ids => self.operation_responses
            ,p_versionid    => self.versionid
         );
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Load the callbacks
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Load the security
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Load the servers
      --------------------------------------------------------------------------
      IF  self.operation_servers IS NOT NULL
      AND self.operation_servers.COUNT > 0
      THEN
         dz_swagger3_loader.servertyp(
             p_parent_id    => self.operation_id
            ,p_children_ids => self.operation_servers
            ,p_versionid    => self.versionid
         );
      
      END IF;

   END traverse;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      boo_temp         BOOLEAN;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_hash         CLOB;
      clb_tmp          CLOB;
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;
      
      str_pad1 := str_pad;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional description 
      --------------------------------------------------------------------------
      IF  self.operation_tags IS NOT NULL
      AND self.operation_tags.COUNT > 0
      THEN
         EXECUTE IMMEDIATE 
            'SELECT '
         || 'a.tagtyp.tag_name '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p04) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      = b.object_id '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO
         ary_keys
         USING 
         self.operation_tags;

         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('[',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('[',-1);
            
         END IF;
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
               str_pad2 || '"' || ary_keys(i) || '"'
               ,p_pretty_print + 2
            );
            str_pad2 := ',';
         
         END LOOP;
         
         clb_hash := clb_hash || dz_json_util.pretty(
             ']'
            ,p_pretty_print + 1,NULL,NULL
         );
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                 'tags'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Add summary 
      --------------------------------------------------------------------------
      IF self.operation_summary IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'summary'
               ,self.operation_summary
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 50
      -- Add description 
      --------------------------------------------------------------------------
      IF self.operation_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'description'
               ,self.operation_description
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add optional externalDocs
      --------------------------------------------------------------------------
      IF  self.operation_externalDocs IS NOT NULL
      AND self.operation_externalDocs.object_id IS NOT NULL
      THEN
         BEGIN
            EXECUTE IMMEDIATE 
               'SELECT '
            || 'a.extrdocstyp.toJSON( '
            || '    p_pretty_print => :p01 + 1 '
            || '   ,p_force_inline => :p02 '
            || '   ,p_short_id     => :p03 '
            || ') '
            || 'FROM dz_swagger3_xobjects a '
            || 'WHERE '
            || '    a.object_type_id = :p04 '
            || 'AND a.object_id      = :p05 '
            INTO clb_tmp
            USING
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.operation_externalDocs.object_type_id
            ,self.operation_externalDocs.object_id;
            
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_tmp := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;
      
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'externalDocs'
               ,clb_tmp
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Add optional operationId 
      --------------------------------------------------------------------------
      IF self.operation_operationId IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'operationId'
               ,self.operation_operationId
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Add parameters array
      --------------------------------------------------------------------------
      IF  self.operation_parameters IS NOT NULL 
      AND self.operation_parameters.COUNT > 0
      THEN
         EXECUTE IMMEDIATE 
            'SELECT '
         || ' a.parametertyp.toJSON( '
         || '    p_pretty_print     => :p01 + 2 '
         || '   ,p_force_inline     => :p02 '
         || '   ,p_short_id         => :p03 '
         || '   ,p_identifier       => a.object_id '
         || '   ,p_short_identifier => a.short_id '
         || '   ,p_reference_count  => a.reference_count '
         || ' ) '
         || ',b.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p04) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      = b.object_id '
         || 'WHERE '
         || 'COALESCE(a.parametertyp.parameter_list_hidden,''FALSE'') <> ''TRUE'' '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO
          ary_clb
         ,ary_keys
         USING 
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.operation_parameters;

         str_pad2 := str_pad;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            IF p_pretty_print IS NULL
            THEN
               clb_hash := dz_json_util.pretty('[',NULL);
               
            ELSE
               clb_hash := dz_json_util.pretty('[',-1);
               
            END IF;
         
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_hash := clb_hash || dz_json_util.pretty(
                  str_pad2 || ary_clb(i)
                  ,p_pretty_print + 2
               );
               str_pad2 := ',';
            
            END LOOP;
            
            clb_hash := clb_hash || dz_json_util.pretty(
                ']'
               ,p_pretty_print + 1,NULL,NULL
            );
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                    'parameters'
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Add requestBody object
      --------------------------------------------------------------------------
      IF  self.operation_requestBody IS NOT NULL
      AND self.operation_requestBody.object_id IS NOT NULL
      THEN
         BEGIN
            EXECUTE IMMEDIATE 
               'SELECT '
            || 'a.requestbodytyp.toJSON( '
            || '    p_pretty_print     => :p01 + 1 '
            || '   ,p_force_inline     => :p02 '
            || '   ,p_short_id         => :p03 '
            || '   ,p_identifier       => a.object_id '
            || '   ,p_short_identifier => a.short_id '
            || '   ,p_reference_count  => a.reference_count '
            || ') '
            || 'FROM dz_swagger3_xobjects a '
            || 'WHERE '
            || '    a.object_type_id = :p04 '
            || 'AND a.object_id      = :p05 '
            INTO clb_tmp
            USING
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.operation_requestBody.object_type_id
            ,self.operation_requestBody.object_id;
            
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_tmp := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;

         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'requestBody'
               ,clb_tmp               
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Add optional variables map
      --------------------------------------------------------------------------
      IF  self.operation_responses IS NOT NULL 
      AND self.operation_responses.COUNT > 0
      THEN
         EXECUTE IMMEDIATE 
            'SELECT '
         || ' a.responsetyp.toJSON( '
         || '    p_pretty_print     => :p01 + 2 '
         || '   ,p_force_inline     => :p02 '
         || '   ,p_short_id         => :p03 '
         || '   ,p_identifier       => a.object_id '
         || '   ,p_short_identifier => a.short_id '
         || '   ,p_reference_count  => a.reference_count '
         || ' ) '
         || ',b.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p04) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      = b.object_id '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO
          ary_clb
         ,ary_keys
         USING 
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.operation_responses;
         
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('{',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('{',-1);
            
         END IF;
 
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
               ,p_pretty_print + 2
            );
            str_pad2 := ',';
         
         END LOOP;
         
         clb_hash := clb_hash || dz_json_util.pretty(
             '}'
            ,p_pretty_print + 1,NULL,NULL
         );
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                 'responses'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 110
      -- Add operation callbacks map
      --------------------------------------------------------------------------
      IF  self.operation_callbacks IS NOT NULL 
      AND self.operation_callbacks.COUNT > 0
      THEN
         EXECUTE IMMEDIATE 
            'SELECT '
         || 'a.pathtyp.toJSON( '
         || '    p_pretty_print     => :p01 + 2 '
         || '   ,p_force_inline     => :p02 '
         || '   ,p_short_id         => :p03 '
         || '   ,p_identifier       => a.object_id '
         || '   ,p_short_identifier => a.short_id '
         || '   ,p_reference_count  => a.reference_count '
         || ') '
         || ',b.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p04) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      = b.object_id '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO
          ary_clb
         ,ary_keys
         USING 
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.operation_callbacks;
         
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('{',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('{',-1);
            
         END IF;
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
               ,p_pretty_print + 1
            );
            str_pad2 := ',';
         
         END LOOP;
         
         clb_hash := clb_hash || dz_json_util.pretty(
             '}'
            ,p_pretty_print + 1,NULL,NULL
         );
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                 'callbacks'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 120
      -- Add deprecated flag
      --------------------------------------------------------------------------
      IF self.operation_deprecated IS NOT NULL
      THEN
         IF LOWER(self.operation_deprecated) = 'true'
         THEN
            boo_temp := TRUE;
            
         ELSE
            boo_temp := FALSE;
            
         END IF;
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'deprecated'
               ,boo_temp
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;

      --------------------------------------------------------------------------
      -- Step 130
      -- Add security req array
      --------------------------------------------------------------------------
      IF  self.operation_security IS NOT NULL 
      AND self.operation_security.COUNT > 0
      THEN
         EXECUTE IMMEDIATE 
            'SELECT '
         || 'a.securityreqtyp.toJSON( '
         || '    p_pretty_print  => :p01 + 2 '
         || '   ,p_force_inline  => :p02 '
         || '   ,p_short_id      => :p03 '
         || ') '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p04) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      = b.object_id '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO
         ary_clb
         USING 
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.operation_security;

         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('[',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('[',-1);
            
         END IF;
      
         FOR i IN 1 .. ary_clb.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
               str_pad2 || ary_clb(i)
               ,p_pretty_print + 1
            );
            str_pad2 := ',';
         
         END LOOP;
         
         clb_hash := clb_hash || dz_json_util.pretty(
             ']'
            ,p_pretty_print + 1,NULL,NULL
         );
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                 'security'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 140
      -- Add server array
      --------------------------------------------------------------------------
      IF  self.operation_servers IS NOT NULL 
      AND self.operation_servers.COUNT > 0
      THEN
         EXECUTE IMMEDIATE 
            'SELECT '
         || 'a.securitytyp.toJSON( '
         || '    p_pretty_print  => :p01 + 2 '
         || '   ,p_force_inline  => :p02 '
         || '   ,p_short_id      => :p03 '
         || ') '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p04) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      = b.object_id '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO
         ary_clb
         USING 
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.operation_servers;
         
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('[',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('[',-1);
            
         END IF;
      
         FOR i IN 1 .. ary_clb.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
               str_pad2 || ary_clb(i)
               ,p_pretty_print + 2
            );
            str_pad2 := ',';
         
         END LOOP;
         
         clb_hash := clb_hash || dz_json_util.pretty(
             ']'
            ,p_pretty_print + 1,NULL,NULL
         );
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                 'servers'
                ,clb_hash
                ,p_pretty_print + 2
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 150
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );

      --------------------------------------------------------------------------
      -- Step 160
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_tmp          CLOB;
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the tags
      --------------------------------------------------------------------------
      IF  self.operation_tags IS NOT NULL
      AND self.operation_tags.COUNT > 0
      THEN
         EXECUTE IMMEDIATE 
            'SELECT '
         || 'a.tagtyp.tag_name '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p01) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      = b.object_id '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO
         ary_keys
         USING 
         self.operation_tags;
      
         clb_output := clb_output || dz_json_util.pretty_str(
             'tags: '
            ,p_pretty_print + 1
            ,'  '
         );
         
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty_str(
                '- ' || dz_swagger3_util.yamlq(ary_keys(i))
               ,p_pretty_print + 2
               ,'  '
            );
            
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the summary
      --------------------------------------------------------------------------
      IF self.operation_summary IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'summary: ' || dz_swagger3_util.yaml_text(
                self.operation_summary
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the description
      --------------------------------------------------------------------------
      IF self.operation_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'description: ' || dz_swagger3_util.yaml_text(
                self.operation_description
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the externalDoc object
      --------------------------------------------------------------------------
      IF  self.operation_externalDocs IS NOT NULL
      AND self.operation_externalDocs.object_id IS NOT NULL
      THEN
         BEGIN
            EXECUTE IMMEDIATE 
               'SELECT '
            || 'a.extrdocstyp.toYAML( '
            || '    p_pretty_print =>  :p01 + 1 '
            || '   ,p_force_inline =>  :p02 '
            || '   ,p_short_id      => :p03 '
            || ') '
            || 'FROM dz_swagger3_xobjects a '
            || 'WHERE '
            || '    a.object_type_id = :p04 '
            || 'AND a.object_id      = :p05 '
            INTO clb_tmp
            USING
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.operation_externalDocs.object_type_id
            ,self.operation_externalDocs.object_id;

         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_tmp := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;

         clb_output := clb_output || dz_json_util.pretty_str(
             'externalDocs: ' 
            ,p_pretty_print + 1
            ,'  '
         ) || clb_tmp;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Write the operationId
      --------------------------------------------------------------------------
      IF self.operation_operationId IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'operationId: ' || dz_swagger3_util.yaml_text(
                self.operation_operationId
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Write the parameters map
      --------------------------------------------------------------------------
      IF  self.operation_parameters IS NOT NULL 
      AND self.operation_parameters.COUNT > 0
      THEN
         EXECUTE IMMEDIATE 
            'SELECT '
         || ' a.parametertyp.toYAML( '
         || '    p_pretty_print     => :p01 + 3 '
         || '   ,p_initial_indent   => ''FALSE'' '
         || '   ,p_final_linefeed   => ''FALSE'' '
         || '   ,p_force_inline     => :p02 '
         || '   ,p_short_id         => :p03 '
         || '   ,p_identifier       => a.object_id '
         || '   ,p_short_identifier => a.short_id '
         || '   ,p_reference_count  => a.reference_count '
         || ' ) '
         || ',b.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p04) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      = b.object_id '
         || 'WHERE '
         || 'COALESCE(a.parametertyp.parameter_list_hidden,''FALSE'') <> ''TRUE'' '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO
          ary_clb
         ,ary_keys
         USING 
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.operation_parameters;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'parameters: '
               ,p_pretty_print + 1
               ,'  '
            );
            
            FOR i IN 1 .. ary_clb.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   '- ' || ary_clb(i)
                  ,p_pretty_print + 2
                  ,'  '
               );
            
            END LOOP;

         END IF;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Write the requestBody
      --------------------------------------------------------------------------
      IF  self.operation_requestBody IS NOT NULL
      AND self.operation_requestBody.object_id IS NOT NULL
      THEN
         BEGIN
            EXECUTE IMMEDIATE 
               'SELECT '
            || 'a.requestbodytyp.toYAML( '
            || '    p_pretty_print     => :p01 + 1 '
            || '   ,p_force_inline     => :p02 '
            || '   ,p_short_id         => :p03 '
            || '   ,p_identifier       => a.object_id '
            || '   ,p_short_identifier => a.short_id '
            || '   ,p_reference_count  => a.reference_count '
            || ') '
            || 'FROM '
            || 'dz_swagger3_xobjects a '
            || 'WHERE '
            || '    a.object_type_id = :p04 '
            || 'AND a.object_id      = :p05 '
            INTO clb_tmp
            USING
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.operation_requestBody.object_type_id
            ,self.operation_requestBody.object_id;

            clb_output := clb_output || dz_json_util.pretty_str(
                'requestBody: ' 
               ,p_pretty_print + 1
               ,'  '
            ) || clb_tmp;

         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_tmp := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Write the responses map
      --------------------------------------------------------------------------
      IF  self.operation_responses IS NOT NULL 
      AND self.operation_responses.COUNT > 0
      THEN
         EXECUTE IMMEDIATE 
            'SELECT '
         || ' a.responsetyp.toYAML( '
         || '    p_pretty_print     => :p01 + 3 '
         || '   ,p_force_inline     => :p02 '
         || '   ,p_short_id         => :p03 '
         || '   ,p_identifier       => a.object_id '
         || '   ,p_short_identifier => a.short_id '
         || '   ,p_reference_count  => a.reference_count '
         || ' ) '
         || ',b.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p04) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      = b.object_id '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO
          ary_clb
         ,ary_keys
         USING 
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.operation_responses;
      
         clb_output := clb_output || dz_json_util.pretty_str(
             'responses: '
            ,p_pretty_print + 1
            ,'  '
         );
         
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                dz_swagger3_util.yamlq(ary_keys(i)) || ': '
               ,p_pretty_print + 2
               ,'  '
            ) || ary_clb(i);
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Write the optional variables map
      --------------------------------------------------------------------------
      IF  self.operation_callbacks IS NOT NULL 
      AND self.operation_callbacks.COUNT > 0
      THEN
         EXECUTE IMMEDIATE 
            'SELECT '
         || ' a.pathtyp.toYAML( '
         || '    p_pretty_print     => :p01 + 2 '
         || '   ,p_force_inline     => :p02 '
         || '   ,p_short_id         => :p03 '
         || '   ,p_identifier       => a.object_id '
         || '   ,p_short_identifier => a.short_id '
         || '   ,p_reference_count  => a.reference_count '
         || ' ) '
         || ',b.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p04) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      = b.object_id '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO
          ary_clb
         ,ary_keys
         USING 
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.operation_callbacks;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'callbacks: '
            ,p_pretty_print + 1
            ,'  '
         );
         
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                dz_swagger3_util.yamlq(ary_keys(i)) || ': '
               ,p_pretty_print + 1
               ,'  '
            ) || ary_clb(i);
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Write the operationId
      --------------------------------------------------------------------------
      IF self.operation_deprecated IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'deprecated: ' || LOWER(self.operation_deprecated)
            ,p_pretty_print + 1
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Write the security array
      --------------------------------------------------------------------------
      IF  self.operation_security IS NOT NULL 
      AND self.operation_security.COUNT > 0
      THEN
         EXECUTE IMMEDIATE 
            'SELECT '
         || 'a.securityreqtyp.toYAML( '
         || '    p_pretty_print  => :p01 + 2 '
         || '   ,p_force_inline  => :p02 '
         || '   ,p_short_id      => :p03 '
         || ') '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p04) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      = b.object_id '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO
         ary_clb
         USING 
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.operation_security;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'security: '
            ,p_pretty_print + 1
            ,'  '
         );
         
         FOR i IN 1 .. ary_clb.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '- '
               ,p_pretty_print + 1
               ,'  '
            ) || ary_clb(i);
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 130
      -- Write the servers array
      --------------------------------------------------------------------------
      IF  self.operation_servers IS NOT NULL 
      AND self.operation_servers.COUNT > 0
      THEN
         EXECUTE IMMEDIATE 
            'SELECT '
         || 'a.securitytyp.toYAML( '
         || '    p_pretty_print   => :p01 + 3 '
         || '   ,p_initial_indent => ''FALSE'' '
         || '   ,p_final_linefeed => ''FALSE'' '
         || '   ,p_force_inline   => :p02 '
         || '   ,p_short_id       => :p03 '
         || ') '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p04) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      = b.object_id '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO
         ary_clb
         USING 
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.operation_servers;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'servers: '
            ,p_pretty_print + 1
            ,'  '
         );
         
         FOR i IN 1 .. ary_clb.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '- ' || ary_clb(i)
               ,p_pretty_print + 2
               ,'  '
            );
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 140
      -- Cough it out 
      --------------------------------------------------------------------------
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');

      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(10) || '$','');
         
      END IF;
               
      RETURN clb_output;
      
   END toYAML;
   
END;
/

CREATE OR REPLACE TYPE BODY dz_swagger3_parameter_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_parameter_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_parameter_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_parameter_typ(
       p_parameter_id              IN  VARCHAR2
      ,p_versionid                 IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10 
      -- Initialize the object
      --------------------------------------------------------------------------
      self.versionid := p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 20 
      -- Load the parameter self and schema id
      --------------------------------------------------------------------------
      BEGIN
         SELECT
          a.parameter_id
         ,a.parameter_name
         ,a.parameter_in
         ,a.parameter_description
         ,a.parameter_required
         ,a.parameter_deprecated
         ,a.parameter_allowEmptyValue
         ,a.parameter_style
         ,a.parameter_explode
         ,a.parameter_allowReserved
         ,CASE
          WHEN a.parameter_schema_id IS NOT NULL
          THEN
            dz_swagger3_object_typ(
                p_object_id      => a.parameter_schema_id
               ,p_object_type_id => 'schematyp'
            )
          ELSE
            NULL
          END
         ,a.parameter_example_string
         ,a.parameter_example_number
         ,a.parameter_force_inline
         ,a.parameter_list_hidden
         INTO
          self.parameter_id
         ,self.parameter_name
         ,self.parameter_in
         ,self.parameter_description
         ,self.parameter_required
         ,self.parameter_deprecated
         ,self.parameter_allowEmptyValue
         ,self.parameter_style
         ,self.parameter_explode
         ,self.parameter_allowReserved
         ,self.parameter_schema
         ,self.parameter_example_string
         ,self.parameter_example_number
         ,self.parameter_force_inline
         ,self.parameter_list_hidden
         FROM
         dz_swagger3_parameter a
         WHERE
             a.versionid    = p_versionid
         AND a.parameter_id = p_parameter_id;

      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RAISE_APPLICATION_ERROR(
                -20001
               ,'Missing parameter ' || p_parameter_id
            );
            
         WHEN OTHERS
         THEN
            RAISE;
            
      END;
      
      --------------------------------------------------------------------------
      -- Step 30 
      -- Load any example ids
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id      => a.example_id
         ,p_object_type_id => 'exampletyp'
         ,p_object_order   => a.example_order
      )
      BULK COLLECT INTO self.parameter_examples
      FROM
      dz_swagger3_parent_example_map a
      WHERE
          a.parent_id = p_parameter_id
      AND a.versionid = p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 40 
      -- Return the object
      --------------------------------------------------------------------------
      RETURN;

   END;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Load the parameter schema
      --------------------------------------------------------------------------
      dz_swagger3_loader.schematyp(
          p_parent_id    => self.parameter_id
         ,p_children_ids => dz_swagger3_object_vry(self.parameter_schema)
         ,p_versionid    => self.versionid
      );
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Load the examples
      --------------------------------------------------------------------------
      IF  self.parameter_examples IS NOT NULL
      AND self.parameter_examples.COUNT > 0
      THEN
         dz_swagger3_loader.exampletyp(
             p_parent_id    => self.parameter_id
            ,p_children_ids => self.parameter_examples
            ,p_versionid    => self.versionid
         );
         
      END IF;  

   END traverse;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      boo_temp         BOOLEAN;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_hash         CLOB;
      clb_tmp          CLOB;
      str_identifier   VARCHAR2(255 Char);
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------

      --------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;
      
      str_pad1 := str_pad;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Add  the ref object
      --------------------------------------------------------------------------
      IF  COALESCE(p_force_inline,'FALSE') = 'FALSE'
      AND p_reference_count > 1
      THEN
         IF p_short_id = 'TRUE'
         THEN
            str_identifier := p_short_identifier;
            
         ELSE
            str_identifier := p_identifier;
            
         END IF;

         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                '$ref'
               ,'#/components/parameters/' || dz_swagger3_util.utl_url_escape(
                  str_identifier
                )
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
      
      ELSE
      --------------------------------------------------------------------------
      -- Step 30
      -- Add mandatory parameter name attribute
      --------------------------------------------------------------------------
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'name'
               ,self.parameter_name
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional in attribute
      --------------------------------------------------------------------------
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'in'
               ,self.parameter_in
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional description attribute
      --------------------------------------------------------------------------
         IF self.parameter_description IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'description'
                  ,self.parameter_description
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Add mandatory required flag
      --------------------------------------------------------------------------
         IF self.parameter_required IS NOT NULL
         THEN
            IF LOWER(self.parameter_required) = 'true'
            THEN
               boo_temp := TRUE;
               
            ELSE
               boo_temp := FALSE;
               
            END IF;
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'required'
                  ,boo_temp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional deprecated flag
      --------------------------------------------------------------------------
         IF  self.parameter_deprecated IS NOT NULL
         AND LOWER(self.parameter_deprecated) = 'true'
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'deprecated'
                  ,TRUE
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;

      --------------------------------------------------------------------------
      -- Step 60
      -- Add optional description 
      --------------------------------------------------------------------------
         IF self.parameter_allowEmptyValue IS NOT NULL
         AND LOWER(self.parameter_allowEmptyValue) = 'true'
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'allowEmptyValue'
                  ,TRUE
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Add optional value
      --------------------------------------------------------------------------
         IF self.parameter_style IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'style'
                  ,self.parameter_style
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Add optional explode attribute 
      --------------------------------------------------------------------------
         IF self.parameter_explode IS NOT NULL
         THEN
            IF LOWER(self.parameter_explode) = 'true'
            THEN
               boo_temp := TRUE;
               
            ELSE
               boo_temp := FALSE;
               
            END IF;
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'explode'
                  ,boo_temp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Add optional allowReserved attribute 
      --------------------------------------------------------------------------
         IF self.parameter_allowReserved IS NOT NULL
         THEN
            IF LOWER(self.parameter_allowReserved) = 'true'
            THEN
               boo_temp := TRUE;
               
            ELSE
               boo_temp := FALSE;
               
            END IF;
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'allowReserved'
                  ,boo_temp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;

      --------------------------------------------------------------------------
      -- Step 100
      -- Add optional schema attribute
      --------------------------------------------------------------------------
         IF self.parameter_schema IS NOT NULL
         THEN
            BEGIN
               EXECUTE IMMEDIATE
                  'SELECT '
               || 'a.schematyp.toJSON( '
               || '    p_pretty_print     => :p01 + 1 '
               || '   ,p_force_inline     => :p02 '
               || '   ,p_short_id         => :p03 '
               || '   ,p_identifier       => a.object_id '
               || '   ,p_short_identifier => a.short_id '
               || '   ,p_reference_count  => a.reference_count '
               || ') '
               || 'FROM '
               || 'dz_swagger3_xobjects a '
               || 'WHERE '
               || '    a.object_type_id = :p04 '
               || 'AND a.object_id      = :p05 '
               INTO clb_tmp
               USING 
                p_pretty_print
               ,p_force_inline
               ,p_short_id
               ,self.parameter_schema.object_type_id
               ,self.parameter_schema.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;

            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                   'schema'
                  ,clb_tmp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;

      --------------------------------------------------------------------------
      -- Step 110
      -- Add optional example
      --------------------------------------------------------------------------
         IF self.parameter_example_string IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'example'
                  ,self.parameter_example_string
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         ELSIF self.parameter_example_number IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'example'
                  ,self.parameter_example_number
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Add optional variables map
      --------------------------------------------------------------------------
         IF  self.parameter_examples IS NOT NULL 
         AND self.parameter_examples.COUNT > 0
         THEN
            EXECUTE IMMEDIATE
               'SELECT '
            || ' a.exampletyp.toJSON( '
            || '    p_pretty_print     => :p01 + 1 '
            || '   ,p_force_inline     => :p02 '
            || '   ,p_short_id         => :p03 '
            || '   ,p_identifier       => a.object_id '
            || '   ,p_short_identifier => a.short_id '
            || '   ,p_reference_count  => a.reference_count '
            || ' ) '
            || ',b.object_key '
            || 'FROM '
            || 'dz_swagger3_xobjects a '
            || 'JOIN '
            || 'TABLE(:p04) b '
            || 'ON '
            || '    a.object_type_id = b.object_type_id '
            || 'AND a.object_id      = b.object_id '
            || 'ORDER BY b.object_order '
            BULK COLLECT INTO 
             ary_clb
            ,ary_keys
            USING
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.parameter_examples;
            
            str_pad2 := str_pad;
            
            IF p_pretty_print IS NULL
            THEN
               clb_hash := dz_json_util.pretty('{',NULL);
               
            ELSE
               clb_hash := dz_json_util.pretty('{',-1);
               
            END IF;

            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_hash := clb_hash || dz_json_util.pretty(
                   str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                  ,p_pretty_print + 1
               );
               str_pad2 := ',';
            
            END LOOP;
            
            clb_hash := clb_hash || dz_json_util.pretty(
                '}'
               ,p_pretty_print + 1,NULL,NULL
            );
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                    'examples'
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
      
      END IF;
      --------------------------------------------------------------------------
      -- Step 130
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 140
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_tmp          CLOB;
      str_identifier   VARCHAR2(255 Char);
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      IF  COALESCE(p_force_inline,'FALSE') = 'FALSE'
      AND p_reference_count > 1
      THEN
         IF p_short_id = 'TRUE'
         THEN
            str_identifier := p_short_identifier;
            
         ELSE
            str_identifier := p_identifier;
            
         END IF;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             '$ref: ' || dz_swagger3_util.yaml_text(
                '#/components/parameters/' || str_identifier
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
  
      ELSE
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the mandatory parameter name
      --------------------------------------------------------------------------
         clb_output := clb_output || dz_json_util.pretty_str(
             'name: ' || dz_swagger3_util.yaml_text(
                self.parameter_name
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the mandatory parameter in attribute
      --------------------------------------------------------------------------
         clb_output := clb_output || dz_json_util.pretty_str(
             'in: ' || dz_swagger3_util.yaml_text(
                self.parameter_in
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the optional description attribute
      --------------------------------------------------------------------------
         IF self.parameter_description IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'description: ' || dz_swagger3_util.yaml_text(
                   REGEXP_REPLACE(
                      self.parameter_description
                     ,CHR(10) || '$'
                     ,'')
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional required attribute
      --------------------------------------------------------------------------
         IF self.parameter_required IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'required: ' || LOWER(self.parameter_required)
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the optional deprecated attribute
      --------------------------------------------------------------------------
         IF self.parameter_deprecated IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'deprecated: ' || LOWER(self.parameter_deprecated)
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the optional allowEmptyValue attribute
      --------------------------------------------------------------------------
         IF self.parameter_allowEmptyValue IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'allowEmptyValue: ' || LOWER(self.parameter_allowEmptyValue)
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Write the optional style attribute
      --------------------------------------------------------------------------
         IF self.parameter_style IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'style: ' || dz_swagger3_util.yaml_text(
                   self.parameter_style
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Write the optional explode attribute
      --------------------------------------------------------------------------
         IF self.parameter_explode IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'explode: ' || LOWER(self.parameter_explode)
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Write the optional allowReserved attribute
      --------------------------------------------------------------------------
         IF self.parameter_allowReserved IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'allowReserved: ' || LOWER(self.parameter_allowReserved)
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Write the optional schema subobject
      --------------------------------------------------------------------------
         IF  self.parameter_schema IS NOT NULL
         AND self.parameter_schema.object_id IS NOT NULL
         THEN
            BEGIN
               EXECUTE IMMEDIATE
                  'SELECT '
               || 'a.schematyp.toYAML( '
               || '    p_pretty_print     => :p01 + 1 '
               || '   ,p_force_inline     => :p02 '
               || '   ,p_short_id         => :p03 '
               || '   ,p_identifier       => a.object_id '
               || '   ,p_short_identifier => a.short_id '
               || '   ,p_reference_count  => a.reference_count '
               || ') '
               || 'FROM '
               || 'dz_swagger3_xobjects a '
               || 'WHERE '
               || '    a.object_type_id = :p04 '
               || 'AND a.object_id      = :p05 '
               INTO clb_tmp
               USING 
                p_pretty_print
               ,p_force_inline
               ,p_short_id
               ,self.parameter_schema.object_type_id
               ,self.parameter_schema.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;

            END;
            
            clb_output := clb_output || dz_json_util.pretty_str(
                'schema: '
               ,p_pretty_print
               ,'  '
            ) || clb_tmp;
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Write the optional examples values
      --------------------------------------------------------------------------
         IF self.parameter_example_string IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'example: ' || dz_swagger3_util.yaml_text(
                   self.parameter_example_string
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         ELSIF self.parameter_example_number IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'example: ' || dz_swagger3_util.yaml_text(
                   self.parameter_example_number
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Write the optional examples map
      --------------------------------------------------------------------------
         IF  self.parameter_examples IS NOT NULL 
         AND self.parameter_examples.COUNT > 0
         THEN
            EXECUTE IMMEDIATE
               'SELECT '
            || ' a.exampletyp.toYAML( '
            || '    p_pretty_print     => :p01 + 1 '
            || '   ,p_force_inline     => :p02 '
            || '   ,p_short_id         => :p03 '
            || '   ,p_identifier       => a.object_id '
            || '   ,p_short_identifier => a.short_id '
            || '   ,p_reference_count  => a.reference_count '
            || ' ) '
            || ',b.object_key '
            || 'FROM '
            || 'dz_swagger3_xobjects a '
            || 'JOIN '
            || 'TABLE(:p01) b '
            || 'ON '
            || '    a.object_type_id = b.object_type_id '
            || 'AND a.object_id      = b.object_id '
            || 'ORDER BY b.object_order '
            BULK COLLECT INTO 
             ary_clb
            ,ary_keys
            USING
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.parameter_examples; 
            
            clb_output := clb_output || dz_json_util.pretty_str(
                'examples: '
               ,p_pretty_print + 1
               ,'  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   '''' || ary_keys(i) || ''': '
                  ,p_pretty_print + 2
                  ,'  '
               ) || ary_clb(i);
            
            END LOOP;
            
         END IF;
      
      END IF;
      --------------------------------------------------------------------------
      -- Step 110
      -- Cough it out without final line feed
      --------------------------------------------------------------------------
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(10) || '$','');
         
      END IF;
               
      RETURN clb_output;
      
   END toYAML;
   
END;
/

CREATE OR REPLACE TYPE BODY dz_swagger3_path_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_path_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_path_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_path_typ(
       p_path_id                   IN  VARCHAR2
      ,p_versionid                 IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS   
   BEGIN 
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Initialize the object
      --------------------------------------------------------------------------
      self.versionid := p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Fetch component items
      --------------------------------------------------------------------------
      SELECT
       a.path_endpoint
      ,a.path_id
      ,a.path_summary
      ,a.path_description
      ,CASE
       WHEN a.path_get_operation_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id      => a.path_get_operation_id
            ,p_object_type_id => 'operationtyp'
            ,p_object_subtype => 'get'
         )
       ELSE
         NULL
       END
      ,CASE
       WHEN a.path_put_operation_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id      => a.path_put_operation_id
            ,p_object_type_id => 'operationtyp'
            ,p_object_subtype => 'put'
         )
       ELSE
         NULL
       END
      ,CASE
       WHEN a.path_post_operation_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id      => a.path_post_operation_id
            ,p_object_type_id => 'operationtyp'
            ,p_object_subtype => 'post'
         )
       ELSE
         NULL
       END
      ,CASE
       WHEN a.path_delete_operation_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id      => a.path_delete_operation_id
            ,p_object_type_id => 'operationtyp'
            ,p_object_subtype => 'delete'
         )
       ELSE
         NULL
       END
      ,CASE
       WHEN a.path_options_operation_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id      => a.path_options_operation_id
            ,p_object_type_id => 'operationtyp'
            ,p_object_subtype => 'options'
         )
       ELSE
         NULL
       END
      ,CASE
       WHEN a.path_head_operation_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id      => a.path_head_operation_id
            ,p_object_type_id => 'operationtyp'
            ,p_object_subtype => 'head'
         )
       ELSE
         NULL
       END
      ,CASE
       WHEN a.path_patch_operation_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id      => a.path_patch_operation_id
            ,p_object_type_id => 'operationtyp'
            ,p_object_subtype => 'patch'
         )
       ELSE
         NULL
       END
      ,CASE
       WHEN a.path_trace_operation_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id      => a.path_trace_operation_id
            ,p_object_type_id => 'operationtyp'
            ,p_object_subtype => 'trace'
         )
       ELSE
         NULL
       END
      INTO 
       self.path_endpoint
      ,self.path_id
      ,self.path_summary
      ,self.path_description
      ,self.path_get_operation
      ,self.path_put_operation
      ,self.path_post_operation
      ,self.path_delete_operation
      ,self.path_options_operation
      ,self.path_head_operation
      ,self.path_patch_operation
      ,self.path_trace_operation
      FROM
      dz_swagger3_path a
      WHERE
          a.versionid = p_versionid
      AND a.path_id   = p_path_id;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Load the server objects on this path
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id      => a.server_id
         ,p_object_type_id => 'servertyp'
         ,p_object_order   => a.server_order
      )
      BULK COLLECT INTO self.path_servers
      FROM
      dz_swagger3_parent_server_map a
      WHERE
          a.versionid = p_versionid
      AND a.parent_id = p_path_id;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Load the parameter objects on this path
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id      => a.parameter_id
         ,p_object_type_id => 'parametertyp'
         ,p_object_order   => b.parameter_order
      )
      BULK COLLECT INTO self.path_parameters
      FROM
      dz_swagger3_parameter a
      JOIN
      dz_swagger3_parent_parm_map b
      ON
          a.versionid = b.versionid
      AND a.parameter_id = b.parameter_id
      WHERE
          b.versionid = p_versionid
      AND b.parent_id = p_path_id;

      --------------------------------------------------------------------------
      -- Step 40
      -- Return the object
      --------------------------------------------------------------------------
      RETURN; 
      
   END dz_swagger3_path_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Load the operations
      --------------------------------------------------------------------------
      dz_swagger3_loader.operationtyp(
          p_parent_id    => self.path_id
         ,p_children_ids => dz_swagger3_object_vry(
             self.path_get_operation
            ,self.path_put_operation
            ,self.path_post_operation
            ,self.path_delete_operation
            ,self.path_options_operation
            ,self.path_head_operation
            ,self.path_patch_operation
            ,self.path_trace_operation
          )
         ,p_versionid    => self.versionid
      );
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Load the servers
      --------------------------------------------------------------------------
      IF  self.path_servers IS NOT NULL
      AND self.path_servers.COUNT > 0
      THEN
         dz_swagger3_loader.servertyp(
             p_parent_id    => self.path_id
            ,p_children_ids => self.path_servers
            ,p_versionid    => self.versionid
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Load the path parameters
      --------------------------------------------------------------------------
      IF  self.path_parameters IS NOT NULL
      AND self.path_parameters.COUNT > 0
      THEN
         dz_swagger3_loader.parametertyp(
             p_parent_id    => self.path_id
            ,p_children_ids => self.path_parameters
            ,p_versionid    => self.versionid
         );
         
      END IF;
      
   END traverse;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_hash         CLOB;
      clb_tmp          CLOB;
      str_identifier   VARCHAR2(255 Char);
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;
      
      str_pad1 := str_pad;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Add  the ref object for callbacks
      --------------------------------------------------------------------------
      IF  COALESCE(p_force_inline,'FALSE') = 'FALSE'
      AND p_reference_count > 1
      THEN
         IF p_short_id = 'TRUE'
         THEN
            str_identifier := p_short_identifier;
            
         ELSE
            str_identifier := p_identifier;
            
         END IF;

         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                '$ref'
               ,'#/components/callbacks/' || dz_swagger3_util.utl_url_escape(
                  str_identifier
                )
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
      
      ELSE
      --------------------------------------------------------------------------
      -- Step 30
      -- Add path summary
      --------------------------------------------------------------------------
         IF self.path_summary IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'summary'
                  ,self.path_summary
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Add path description 
      --------------------------------------------------------------------------
         IF self.path_description IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'description'
                  ,self.path_description
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add get operation
      --------------------------------------------------------------------------
         IF  self.path_get_operation IS NOT NULL
         AND self.path_get_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT 
               a.operationtyp.toJSON( 
                   p_pretty_print   => p_pretty_print + 1 
                  ,p_force_inline   => p_force_inline 
                  ,p_short_id       => p_short_id
               )
               INTO clb_tmp
               FROM 
               dz_swagger3_xobjects a 
               WHERE 
                   a.object_type_id = self.path_get_operation.object_type_id
               AND a.object_id      = self.path_get_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE_APPLICATION_ERROR(
                      -20001
                     ,SQLERRM || self.path_get_operation.object_id
                  );
                  
            END;
         
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                   'get'
                  ,clb_tmp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;

      --------------------------------------------------------------------------
      -- Step 60
      -- Add put operation
      --------------------------------------------------------------------------
         IF  self.path_put_operation IS NOT NULL
         AND self.path_put_operation.object_id IS NOT NULL
         THEN
            BEGIN
               EXECUTE IMMEDIATE
                  'SELECT '
               || 'a.operationtyp.toJSON( '
               || '    p_pretty_print   => :p01 + 1 '
               || '   ,p_force_inline   => :p02 '
               || '   ,p_short_id       => :p03 '
               || ') FROM '
               || 'dz_swagger3_xobjects a '
               || 'WHERE '
               || '    a.object_type_id = :p04 '
               || 'AND a.object_id      = :p05 '
               INTO clb_tmp
               USING 
                p_pretty_print
               ,p_force_inline
               ,p_short_id
               ,self.path_put_operation.object_type_id
               ,self.path_put_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;

            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                   'put'
                  ,clb_tmp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;

      --------------------------------------------------------------------------
      -- Step 70
      -- Add post operation
      --------------------------------------------------------------------------
         IF  self.path_post_operation IS NOT NULL
         AND self.path_post_operation.object_id IS NOT NULL
         THEN
            BEGIN
               EXECUTE IMMEDIATE
                  'SELECT '
               || 'a.operationtyp.toJSON( '
               || '    p_pretty_print   => :p01 + 1 '
               || '   ,p_force_inline   => :p02 '
               || '   ,p_short_id       => :p03 '
               || ') FROM '
               || 'dz_swagger3_xobjects a '
               || 'WHERE '
               || '    a.object_type_id = :p04 '
               || 'AND a.object_id      = :p05 '
               INTO clb_tmp
               USING 
                p_pretty_print
               ,p_force_inline
               ,p_short_id
               ,self.path_post_operation.object_type_id
               ,self.path_post_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;

            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                   'post'
                  ,clb_tmp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;

      --------------------------------------------------------------------------
      -- Step 80
      -- Add delete operation
      --------------------------------------------------------------------------
         IF  self.path_delete_operation IS NOT NULL
         AND self.path_delete_operation.object_id IS NOT NULL
         THEN
            BEGIN
               EXECUTE IMMEDIATE
                  'SELECT '
               || 'a.operationtyp.toJSON( '
               || '    p_pretty_print   => :p01 + 1 '
               || '   ,p_force_inline   => :p02 '
               || '   ,p_short_id       => :p03 '
               || ') FROM '
               || 'dz_swagger3_xobjects a '
               || 'WHERE '
               || '    a.object_type_id = :p04 '
               || 'AND a.object_id      = :p05 '
               INTO clb_tmp
               USING 
                p_pretty_print
               ,p_force_inline
               ,p_short_id
               ,self.path_delete_operation.object_type_id
               ,self.path_delete_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;

            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                   'delete'
                  ,clb_tmp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Add options operation
      --------------------------------------------------------------------------
         IF  self.path_options_operation IS NOT NULL
         AND self.path_options_operation.object_id IS NOT NULL
         THEN
            BEGIN
               EXECUTE IMMEDIATE
                  'SELECT '
               || 'a.operationtyp.toJSON( '
               || '    p_pretty_print   => :p01 + 1 '
               || '   ,p_force_inline   => :p02 '
               || '   ,p_short_id       => :p03 '
               || ') FROM '
               || 'dz_swagger3_xobjects a '
               || 'WHERE '
               || '    a.object_type_id = :p04 '
               || 'AND a.object_id      = :p05 '
               INTO clb_tmp
               USING 
                p_pretty_print
               ,p_force_inline
               ,p_short_id
               ,self.path_options_operation.object_type_id
               ,self.path_options_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                   'options'
                  ,clb_tmp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Add head operation
      --------------------------------------------------------------------------
         IF  self.path_head_operation IS NOT NULL
         AND self.path_head_operation.object_id IS NOT NULL
         THEN
            BEGIN
               EXECUTE IMMEDIATE
                  'SELECT '
               || 'a.operationtyp.toJSON( '
               || '    p_pretty_print   => :p01 + 1 '
               || '   ,p_force_inline   => :p02 '
               || '   ,p_short_id       => :p03 '
               || ') FROM '
               || 'dz_swagger3_xobjects a '
               || 'WHERE '
               || '    a.object_type_id = :p04 '
               || 'AND a.object_id      = :p05 '
               INTO clb_tmp
               USING 
                p_pretty_print
               ,p_force_inline
               ,p_short_id
               ,self.path_head_operation.object_type_id
               ,self.path_head_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                   'head'
                  ,clb_tmp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Add patch operation
      --------------------------------------------------------------------------
         IF  self.path_patch_operation IS NOT NULL
         AND self.path_patch_operation.object_id IS NOT NULL
         THEN
            BEGIN
               EXECUTE IMMEDIATE
                  'SELECT '
               || 'a.operationtyp.toJSON( '
               || '    p_pretty_print   => :p01 + 1 '
               || '   ,p_force_inline   => :p02 '
               || '   ,p_short_id       => :p03 '
               || ') FROM '
               || 'dz_swagger3_xobjects a '
               || 'WHERE '
               || '    a.object_type_id = :p04 '
               || 'AND a.object_id      = :p05 '
               INTO clb_tmp
               USING 
                p_pretty_print
               ,p_force_inline
               ,p_short_id
               ,self.path_patch_operation.object_type_id
               ,self.path_patch_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                   'patch'
                  ,clb_tmp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Add trace operation
      --------------------------------------------------------------------------
         IF  self.path_trace_operation IS NOT NULL
         AND self.path_trace_operation.object_id IS NOT NULL
         THEN
            BEGIN
               EXECUTE IMMEDIATE
                  'SELECT '
               || 'a.operationtyp.toJSON( '
               || '    p_pretty_print   => :p01 + 1 '
               || '   ,p_force_inline   => :p02 '
               || '   ,p_short_id       => :p03 '
               || ') FROM '
               || 'dz_swagger3_xobjects a '
               || 'WHERE '
               || '    a.object_type_id = :p04 '
               || 'AND a.object_id      = :p05 '
               INTO clb_tmp
               USING 
                p_pretty_print
               ,p_force_inline
               ,p_short_id
               ,self.path_trace_operation.object_type_id
               ,self.path_trace_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                   'trace'
                  ,clb_tmp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;

      --------------------------------------------------------------------------
      -- Step 130
      -- Add servers
      --------------------------------------------------------------------------
         IF  self.path_servers IS NOT NULL 
         AND self.path_servers.COUNT > 0
         THEN
            EXECUTE IMMEDIATE
               'SELECT '
            || 'a.servertyp.toJSON( '
            || '    p_pretty_print   => :p01 + 1 '
            || '   ,p_force_inline   => :p02 '
            || '   ,p_short_id       => :p03 '
            || ') '
            || 'FROM '
            || 'dz_swagger3_xobjects a '
            || 'JOIN '
            || 'TABLE(:p04) b '
            || 'ON '
            || '    a.object_type_id = b.object_type_id '
            || 'AND a.object_id      = b.object_id '
            || 'ORDER BY b.object_order '
            BULK COLLECT INTO 
             ary_clb
            USING
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.path_servers;
            
            str_pad2 := str_pad;
            
            IF p_pretty_print IS NULL
            THEN
               clb_hash := dz_json_util.pretty('[',NULL);
               
            ELSE
               clb_hash := dz_json_util.pretty('[',-1);
               
            END IF;
         
            FOR i IN 1 .. ary_clb.COUNT
            LOOP
               clb_hash := clb_hash || dz_json_util.pretty(
                   str_pad2 || ary_clb(i)
                  ,p_pretty_print + 1
               );
               str_pad2 := ',';
            
            END LOOP;
            
            clb_hash := clb_hash || dz_json_util.pretty(
                ']'
               ,p_pretty_print + 1,NULL,NULL
            );
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                    'servers'
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;

      --------------------------------------------------------------------------
      -- Step 140
      -- Add parameters
      --------------------------------------------------------------------------
         IF  self.path_parameters IS NOT NULL 
         AND self.path_parameters.COUNT > 0
         THEN
            EXECUTE IMMEDIATE
               'SELECT '
            || ' a.parametertyp.toJSON( '
            || '    p_pretty_print     => :p01 + 1 '
            || '   ,p_force_inline     => :p02 '
            || '   ,p_short_id         => :p03 '
            || '   ,p_identifier       => a.object_id '
            || '   ,p_short_identifier => a.short_id '
            || '   ,p_reference_count  => a.reference_count '
            || ' ) '
            || ',b.object_key '
            || 'FROM '
            || 'dz_swagger3_xobjects a '
            || 'JOIN '
            || 'TABLE(:p04) b '
            || 'ON '
            || '    a.object_type_id = b.object_type_id '
            || 'AND a.object_id      = b.object_id '
            || 'WHERE '
            || 'COALESCE(a.parametertyp.parameter_list_hidden,''FALSE'') <> ''TRUE'' '
            || 'ORDER BY b.object_order '
            BULK COLLECT INTO 
             ary_clb
            ,ary_keys
            USING
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.path_parameters;
            
            IF  ary_keys IS NOT NULL
            AND ary_keys.COUNT > 0
            THEN            
               str_pad2 := str_pad;
               
               IF p_pretty_print IS NULL
               THEN
                  clb_hash := dz_json_util.pretty('{',NULL);
                  
               ELSE
                  clb_hash := dz_json_util.pretty('{',-1);
                  
               END IF;
            
               FOR i IN 1 .. ary_keys.COUNT
               LOOP
                  clb_hash := clb_hash || dz_json_util.pretty(
                      str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                     ,p_pretty_print + 1
                  );
                  str_pad2 := ',';
                     
               END LOOP;
               
               clb_hash := clb_hash || dz_json_util.pretty(
                   '}'
                  ,p_pretty_print + 1,NULL,NULL
               );
               
               clb_output := clb_output || dz_json_util.pretty(
                   str_pad1 || dz_json_main.formatted2json(
                       'parameters'
                      ,clb_hash
                      ,p_pretty_print + 1
                   )
                  ,p_pretty_print + 1
               );
               str_pad1 := ',';
               
            END IF;
            
         END IF;

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 150
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 160
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_tmp          CLOB;
      str_identifier   VARCHAR2(255 Char);
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      IF  COALESCE(p_force_inline,'FALSE') = 'FALSE'
      AND p_reference_count > 1
      THEN
         IF p_short_id = 'TRUE'
         THEN
            str_identifier := p_short_identifier;
            
         ELSE
            str_identifier := p_identifier;
            
         END IF;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             '$ref: ' || dz_swagger3_util.yaml_text(
                '#/components/callbacks/' || str_identifier
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
  
      ELSE
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the summary
      --------------------------------------------------------------------------
         IF self.path_summary IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'summary: ' || dz_swagger3_util.yaml_text(
                   self.path_summary
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the description
      --------------------------------------------------------------------------
         IF self.path_description IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'description: ' || dz_swagger3_util.yaml_text(
                   self.path_description
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Write the get operation
      --------------------------------------------------------------------------
         IF  self.path_get_operation IS NOT NULL
         AND self.path_get_operation.object_id IS NOT NULL
         THEN
            BEGIN
               EXECUTE IMMEDIATE
                  'SELECT '
               || 'a.operationtyp.toYAML( '
               || '    p_pretty_print   => :p01 + 0 '
               || '   ,p_force_inline   => :p02 '
               || '   ,p_short_id       => :p03 '
               || ') FROM '
               || 'dz_swagger3_xobjects a '
               || 'WHERE '
               || '    a.object_type_id = :p04 '
               || 'AND a.object_id      = :p05 '
               INTO clb_tmp
               USING 
                p_pretty_print
               ,p_force_inline
               ,p_short_id
               ,self.path_get_operation.object_type_id
               ,self.path_get_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;

            clb_output := clb_output || dz_json_util.pretty_str(
                'get: ' 
               ,p_pretty_print
               ,'  '
            ) || clb_tmp;
            
         END IF;

      --------------------------------------------------------------------------
      -- Step 50
      -- Write the get operation
      --------------------------------------------------------------------------
         IF  self.path_put_operation IS NOT NULL
         AND self.path_put_operation.object_id IS NOT NULL
         THEN
            BEGIN
               EXECUTE IMMEDIATE
                  'SELECT '
               || 'a.operationtyp.toYAML( '
               || '    p_pretty_print   => :p01 + 0 '
               || '   ,p_force_inline   => :p02 '
               || '   ,p_short_id       => :p03 '
               || ') FROM '
               || 'dz_swagger3_xobjects a '
               || 'WHERE '
               || '    a.object_type_id = :p04 '
               || 'AND a.object_id      = :p05 '
               INTO clb_tmp
               USING 
                p_pretty_print
               ,p_force_inline
               ,p_short_id
               ,self.path_put_operation.object_type_id
               ,self.path_put_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;
            
            clb_output := clb_output || dz_json_util.pretty_str(
                'put: ' 
               ,p_pretty_print
               ,'  '
            ) || clb_tmp;
            
         END IF;

      --------------------------------------------------------------------------
      -- Step 60
      -- Write the post operation
      --------------------------------------------------------------------------
         IF  self.path_post_operation IS NOT NULL
         AND self.path_post_operation.object_id IS NOT NULL
         THEN
            BEGIN
               EXECUTE IMMEDIATE
                  'SELECT '
               || 'a.operationtyp.toYAML( '
               || '    p_pretty_print   => :p01 + 0 '
               || '   ,p_force_inline   => :p02 '
               || '   ,p_short_id       => :p03 '
               || ') FROM '
               || 'dz_swagger3_xobjects a '
               || 'WHERE '
               || '    a.object_type_id = :p04 '
               || 'AND a.object_id      = :p05 '
               INTO clb_tmp
               USING 
                p_pretty_print
               ,p_force_inline
               ,p_short_id
               ,self.path_post_operation.object_type_id
               ,self.path_post_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;
            
            clb_output := clb_output || dz_json_util.pretty_str(
                'post: ' 
               ,p_pretty_print
               ,'  '
            ) || clb_tmp;
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Write the delete operation
      --------------------------------------------------------------------------
         IF  self.path_delete_operation IS NOT NULL
         AND self.path_delete_operation.object_id IS NOT NULL
         THEN
            BEGIN
               EXECUTE IMMEDIATE
                  'SELECT '
               || 'a.operationtyp.toYAML( '
               || '    p_pretty_print   => :p01 + 0 '
               || '   ,p_force_inline   => :p02 '
               || '   ,p_short_id       => :p03 '
               || ') FROM '
               || 'dz_swagger3_xobjects a '
               || 'WHERE '
               || '    a.object_type_id = :p04 '
               || 'AND a.object_id      = :p05 '
               INTO clb_tmp
               USING 
                p_pretty_print
               ,p_force_inline
               ,p_short_id
               ,self.path_delete_operation.object_type_id
               ,self.path_delete_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;
            
            clb_output := clb_output || dz_json_util.pretty_str(
                'delete: ' 
               ,p_pretty_print
               ,'  '
            ) || clb_tmp;
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Write the options operation
      --------------------------------------------------------------------------
         IF  self.path_options_operation IS NOT NULL
         AND self.path_options_operation.object_id IS NOT NULL
         THEN
            BEGIN
               EXECUTE IMMEDIATE
                  'SELECT '
               || 'a.operationtyp.toYAML( '
               || '    p_pretty_print   => :p01 + 0 '
               || '   ,p_force_inline   => :p02 '
               || '   ,p_short_id       => :p03 '
               || ') FROM '
               || 'dz_swagger3_xobjects a '
               || 'WHERE '
               || '    a.object_type_id = :p04 '
               || 'AND a.object_id      = :p05 '
               INTO clb_tmp
               USING 
                p_pretty_print
               ,p_force_inline
               ,p_short_id
               ,self.path_options_operation.object_type_id
               ,self.path_options_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;
            
            clb_output := clb_output || dz_json_util.pretty_str(
                'options: ' 
               ,p_pretty_print
               ,'  '
            ) || clb_tmp;
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Write the head operation
      --------------------------------------------------------------------------
         IF  self.path_head_operation IS NOT NULL
         AND self.path_head_operation.object_id IS NOT NULL
         THEN
            BEGIN
               EXECUTE IMMEDIATE
                  'SELECT '
               || 'a.operationtyp.toYAML( '
               || '    p_pretty_print   => :p01 + 0 '
               || '   ,p_force_inline   => :p02 '
               || '   ,p_short_id       => :p03 '
               || ') FROM '
               || 'dz_swagger3_xobjects a '
               || 'WHERE '
               || '    a.object_type_id = :p04 '
               || 'AND a.object_id      = :p05 '
               INTO clb_tmp
               USING 
                p_pretty_print
               ,p_force_inline
               ,p_short_id
               ,self.path_head_operation.object_type_id
               ,self.path_head_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;
            
            clb_output := clb_output || dz_json_util.pretty_str(
                'head: ' 
               ,p_pretty_print
               ,'  '
            ) || clb_tmp;
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Write the patch operation
      --------------------------------------------------------------------------
         IF  self.path_patch_operation IS NOT NULL
         AND self.path_patch_operation.object_id IS NOT NULL
         THEN
            BEGIN
               EXECUTE IMMEDIATE
                  'SELECT '
               || 'a.operationtyp.toYAML( '
               || '    p_pretty_print   => :p01 + 0 '
               || '   ,p_force_inline   => :p02 '
               || '   ,p_short_id       => :p03 '
               || ') FROM '
               || 'dz_swagger3_xobjects a '
               || 'WHERE '
               || '    a.object_type_id = :p04 '
               || 'AND a.object_id      = :p05 '
               INTO clb_tmp
               USING 
                p_pretty_print
               ,p_force_inline
               ,p_short_id
               ,self.path_patch_operation.object_type_id
               ,self.path_patch_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;
            
            clb_output := clb_output || dz_json_util.pretty_str(
                'patch: ' 
               ,p_pretty_print
               ,'  '
            ) || clb_tmp;
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Write the trace operation
      --------------------------------------------------------------------------
         IF  self.path_trace_operation IS NOT NULL
         AND self.path_trace_operation.object_id IS NOT NULL
         THEN
            BEGIN
               EXECUTE IMMEDIATE
                  'SELECT '
               || 'a.operationtyp.toYAML( '
               || '    p_pretty_print   => :p01 + 0 '
               || '   ,p_force_inline   => :p02 '
               || '   ,p_short_id       => :p03 '
               || ') FROM '
               || 'dz_swagger3_xobjects a '
               || 'WHERE '
               || '    a.object_type_id = :p04 '
               || 'AND a.object_id      = :p05 '
               INTO clb_tmp
               USING 
                p_pretty_print
               ,p_force_inline
               ,p_short_id
               ,self.path_trace_operation.object_type_id
               ,self.path_trace_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;
            
            clb_output := clb_output || dz_json_util.pretty_str(
                'trace: ' 
               ,p_pretty_print
               ,'  '
            ) || clb_tmp;
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Write the server array
      --------------------------------------------------------------------------
         IF  self.path_servers IS NOT NULL 
         AND self.path_servers.COUNT > 0
         THEN
            EXECUTE IMMEDIATE
               'SELECT '
            || 'a.servertyp.toJSON( '
            || '    p_pretty_print   => :p01 + 1 '
            || '   ,p_force_inline   => :p02 '
            || '   ,p_short_id       => :p03 '
            || ') '
            || 'FROM '
            || 'dz_swagger3_xobjects a '
            || 'JOIN '
            || 'TABLE(:p04) b '
            || 'ON '
            || '    a.object_type_id = b.object_type_id '
            || 'AND a.object_id      = b.object_id '
            || 'ORDER BY b.object_order '
            BULK COLLECT INTO 
            ary_clb
            USING
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.path_servers;

            clb_output := clb_output || dz_json_util.pretty_str(
                'servers: '
               ,p_pretty_print + 1
               ,'  '
            );
            
            FOR i IN 1 .. ary_clb.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   '- '
                  ,p_pretty_print + 1
                  ,'  '
               ) || ary_clb(i);
               
            END LOOP;
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 130
      -- Write the parameters map
      --------------------------------------------------------------------------
         IF  self.path_parameters IS NOT NULL 
         AND self.path_parameters.COUNT > 0
         THEN
            EXECUTE IMMEDIATE
               'SELECT '
            || ' a.parametertyp.toYAML( '
            || '    p_pretty_print     => :p01 + 1 '
            || '   ,p_force_inline     => :p02 '
            || '   ,p_short_id         => :p03 '
            || '   ,p_identifier       => a.object_id '
            || '   ,p_short_identifier => a.short_id '
            || '   ,p_reference_count  => a.reference_count '
            || ' ) '
            || ',b.object_key '
            || 'FROM '
            || 'dz_swagger3_xobjects a '
            || 'JOIN '
            || 'TABLE(:p04) b '
            || 'ON '
            || 'a.object_type_id = b.object_type_id '
            || 'a.object_id      = b.object_id '
            || 'WHERE '
            || 'COALESCE(a.parametertyp.parameter_list_hidden,''FALSE'') <> ''TRUE'' '
            || 'ORDER BY b.object_order '
            BULK COLLECT INTO 
             ary_clb
            ,ary_keys
            USING
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.path_parameters;
            
            IF  ary_keys IS NOT NULL
            AND ary_keys.COUNT > 0
            THEN
               clb_output := clb_output || dz_json_util.pretty_str(
                   'parameters: '
                  ,p_pretty_print + 1
                  ,'  '
               );
               
               FOR i IN 1 .. ary_keys.COUNT
               LOOP
                  clb_output := clb_output || dz_json_util.pretty(
                      '''' || ary_keys(i) || ''': '
                     ,p_pretty_print + 2
                     ,'  '
                  ) || ary_clb(i);
               
               END LOOP;
               
            END IF;
            
         END IF;
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 140
      -- Cough it out 
      --------------------------------------------------------------------------
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(10) || '$','');
         
      END IF;
               
      RETURN clb_output;
      
   END toYAML;
   
END;
/

CREATE OR REPLACE TYPE BODY dz_swagger3_requestbody_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_requestbody_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_requestbody_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_requestbody_typ(
       p_requestbody_id          IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Initialize the object
      --------------------------------------------------------------------------
      self.versionid                  := p_versionid;

      --------------------------------------------------------------------------
      -- Step 20
      -- Pull the object information
      --------------------------------------------------------------------------
      SELECT
       a.requestBody_id
      ,a.requestBody_description
      ,a.requestBody_force_inline
      ,a.requestBody_required
      INTO
       self.requestBody_id
      ,self.requestBody_description
      ,self.requestBody_force_inline
      ,self.requestBody_required
      FROM
      dz_swagger3_requestbody a
      WHERE
          a.versionid      = p_versionid
      AND a.requestBody_id = p_requestBody_id;

      --------------------------------------------------------------------------
      -- Step 30
      -- Collect the media content
      -------------------------------------------------------------------------- 
      SELECT
      dz_swagger3_object_typ(
          p_object_id       => b.media_id
         ,p_object_type_id  => 'mediatyp'
         ,p_object_key      => a.media_type
         ,p_object_order    => a.media_order
      )
      BULK COLLECT INTO self.requestbody_content
      FROM
      dz_swagger3_parent_media_map a
      JOIN
      dz_swagger3_media b
      ON
          a.versionid  = b.versionid
      AND a.media_id   = b.media_id
      WHERE
          a.versionid = p_versionid
      AND a.parent_id = p_requestbody_id;

      --------------------------------------------------------------------------
      -- Step 40
      -- Return the completed object
      --------------------------------------------------------------------------   
      RETURN; 
   
   END dz_swagger3_requestbody_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_requestbody_typ(
       p_requestbody_id           IN  VARCHAR2
      ,p_parameters               IN  dz_swagger3_object_vry --dz_swagger3_parameter_list
      ,p_versionid                IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Initialize the object
      --------------------------------------------------------------------------
      self.versionid                  := p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Emulate the post object
      --------------------------------------------------------------------------
      self.requestBody_id             := p_requestbody_id;
      self.requestBody_force_inline   := 'TRUE';
      self.requestBody_emulated_parms := p_parameters;
      
      self.requestbody_content := dz_swagger3_object_vry(
         dz_swagger3_object_typ(
             p_object_id        => 'md.' || p_requestbody_id
            ,p_object_type_id   => 'mediatyp'
            ,p_object_subtype   => 'emulated'
            ,p_object_key       => 'application/x-www-form-urlencoded'
            ,p_object_attribute => 'TRUE'
         )
      );
 
      RETURN;
      
   END dz_swagger3_requestbody_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Load the media types
      --------------------------------------------------------------------------
      IF self.requestBody_content(1).object_subtype = 'emulated'
      THEN
         dz_swagger3_loader.mediatyp_emulated(
             p_parent_id      => self.requestBody_id
            ,p_children_ids   => self.requestBody_content
            ,p_parameter_ids  => self.requestBody_emulated_parms
            ,p_versionid      => self.versionid
         );
         
      ELSE
         dz_swagger3_loader.mediatyp(
             p_parent_id      => self.requestBody_id
            ,p_children_ids   => self.requestBody_content
            ,p_versionid      => self.versionid
         );
         
      END IF;
  
   END traverse;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      boo_temp         BOOLEAN;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_hash         CLOB;
      str_identifier   VARCHAR2(255 Char);
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;
      
      str_pad1 := str_pad;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Add  the ref object
      --------------------------------------------------------------------------
      IF  COALESCE(p_force_inline,'FALSE') = 'FALSE'
      AND p_reference_count > 1
      THEN
         IF p_short_id = 'TRUE'
         THEN
            str_identifier := p_short_identifier;
            
         ELSE
            str_identifier := p_identifier;
            
         END IF;

         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                '$ref'
               ,'#/components/requestBodies/' || dz_swagger3_util.utl_url_escape(
                  str_identifier
                ) 
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      ELSE      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional description
      --------------------------------------------------------------------------
         IF self.requestbody_description IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'description'
                  ,self.requestbody_description
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add media content
      --------------------------------------------------------------------------
         IF  self.requestbody_content IS NOT NULL 
         AND self.requestbody_content.COUNT > 0
         THEN 
            EXECUTE IMMEDIATE
               'SELECT '
            || ' a.mediatyp.toJSON( '
            || '    p_pretty_print   => :p01 + 2 '
            || '   ,p_force_inline   => :p02 '
            || '   ,p_short_id       => :p03 '
            || ' ) '
            || ',b.object_key '
            || 'FROM '
            || 'dz_swagger3_xobjects a '
            || 'JOIN '
            || 'TABLE(:p04) b '
            || 'ON '
            || '    a.object_type_id = b.object_type_id '
            || 'AND a.object_id      = b.object_id '
            || 'ORDER BY b.object_order '
            BULK COLLECT INTO 
             ary_clb
            ,ary_keys
            USING
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.requestbody_content; 
            
            str_pad2 := str_pad;
            
            IF p_pretty_print IS NULL
            THEN
               clb_hash := dz_json_util.pretty('{',NULL);
               
            ELSE
               clb_hash := dz_json_util.pretty('{',-1);
               
            END IF;
         
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_hash := clb_hash || dz_json_util.pretty(
                   str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                  ,p_pretty_print + 2
               );
               str_pad2 := ',';
            
            END LOOP;
            
            clb_hash := clb_hash || dz_json_util.pretty(
                '}'
               ,p_pretty_print + 1,NULL,NULL
            );
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                    'content'
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional required
      --------------------------------------------------------------------------
         IF self.requestbody_required IS NOT NULL
         THEN
            IF LOWER(self.requestbody_required) = 'true'
            THEN
               boo_temp := TRUE;
               
            ELSE
               boo_temp := FALSE;
            
            END IF;
         
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'required'
                  ,boo_temp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
 
      END IF;
      --------------------------------------------------------------------------
      -- Step 60
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      str_identifier   VARCHAR2(255 Char);
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      IF  COALESCE(p_force_inline,'FALSE') = 'FALSE'
      AND p_reference_count > 1
      THEN
         IF p_short_id = 'TRUE'
         THEN
            str_identifier := p_short_identifier;
            
         ELSE
            str_identifier := p_identifier;
            
         END IF;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             '$ref: ' || dz_swagger3_util.yaml_text(
                '#/components/requestBodies/' || p_identifier
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
      
      ELSE
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml description
      --------------------------------------------------------------------------
         IF self.requestbody_description IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'description: ' || dz_swagger3_util.yaml_text(
                   self.requestbody_description
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;

      --------------------------------------------------------------------------
      -- Step 30
      -- Write the yaml media content
      --------------------------------------------------------------------------
         IF  self.requestbody_content IS NOT NULL 
         AND self.requestbody_content.COUNT > 0
         THEN
            EXECUTE IMMEDIATE
               'SELECT '
            || ' a.mediatyp.toYAML( '
            || '    p_pretty_print   => :p01 + 3 '
            || '   ,p_force_inline   => :p02 '
            || '   ,p_short_id       => :p03 '
            || ' ) '
            || ',b.object_key '
            || 'FROM '
            || 'dz_swagger3_xobjects a '
            || 'JOIN '
            || 'TABLE(:p04) b '
            || 'ON '
            || '    a.object_type_id = b.object_type_id '
            || 'AND a.object_id      = b.object_id '
            || 'ORDER BY b.object_order '
            BULK COLLECT INTO 
             ary_clb
            ,ary_keys
            USING
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.requestbody_content; 
            
            clb_output := clb_output || dz_json_util.pretty_str(
                'content: '
               ,p_pretty_print + 1
               ,'  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   dz_swagger3_util.yamlq(ary_keys(i)) || ': '
                  ,p_pretty_print + 2
                  ,'  '
               ) || ary_clb(i);
            
            END LOOP;
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the yaml required boolean
      --------------------------------------------------------------------------
         IF self.requestbody_required IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'required: ' || LOWER(self.requestbody_required)
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Cough it out 
      --------------------------------------------------------------------------
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(10) || '$','');
         
      END IF;
               
      RETURN clb_output;
      
   END toYAML;
   
END;
/

CREATE OR REPLACE TYPE BODY dz_swagger3_server_var_typ
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_server_var_typ
   RETURN SELF AS RESULT
   AS
   BEGIN
      RETURN;

   END dz_swagger3_server_var_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_server_var_typ(
       p_server_var_id      IN  VARCHAR2
      ,p_versionid          IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
   BEGIN

      self.versionid         := p_versionid;
      
      SELECT
       a.server_var_id
      ,a.server_var_name
      ,dz_json_util.gz_split(a.server_var_enum,',')
      ,a.server_var_default
      ,a.server_var_description
      INTO
       self.server_var_id
      ,self.server_var_name
      ,self.enum
      ,self.default_value
      ,self.description
      FROM
      dz_swagger3_server_variable a
      WHERE
          a.server_var_id = p_server_var_id
      AND a.versionid     = p_versionid;
      
      RETURN;

   END dz_swagger3_server_var_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN
      NULL;
      
   END traverse;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_pad          VARCHAR2(1 Char);

   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------

      --------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);

      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';

      END IF;

      --------------------------------------------------------------------------
      -- Step 30
      -- Add elem element
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          str_pad || dz_json_main.value2json(
             'enum'
            ,self.enum
            ,p_pretty_print + 1
         )
         ,p_pretty_print + 1
      );
      str_pad := ',';

      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional default
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          str_pad || dz_json_main.value2json(
             'default'
            ,self.default_value
            ,p_pretty_print + 1
         )
         ,p_pretty_print + 1
      );
      str_pad := ',';

      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional description
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          str_pad || dz_json_main.value2json(
             'description'
            ,self.description
            ,p_pretty_print + 1
         )
         ,p_pretty_print + 1
      );
      str_pad := ',';

      --------------------------------------------------------------------------
      -- Step 60
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );

      --------------------------------------------------------------------------
      -- Step 70
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toJSON;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output        CLOB;

   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------

      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml license name
      --------------------------------------------------------------------------
      IF  self.enum IS NOT NULL
      AND self.enum.COUNT > 0
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'enum: '
            ,p_pretty_print
            ,'  '
         );

         FOR i IN 1 .. self.enum.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '- ' || dz_swagger3_util.yaml_text(self.enum(i),p_pretty_print)
               ,p_pretty_print + 1
               ,'  '
            );

         END LOOP;

      END IF;

      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional license url
      --------------------------------------------------------------------------
      IF self.default_value IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'default: ' || dz_swagger3_util.yaml_text(
                self.default_value
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );

      END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Write the optional license url
      --------------------------------------------------------------------------
      IF self.description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'description: ' || dz_swagger3_util.yaml_text(
                self.description
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );

      END IF;

      --------------------------------------------------------------------------
      -- Step 50
      -- Cough it out without final line feed
      --------------------------------------------------------------------------
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(10) || '$','');
         
      END IF;
               
      RETURN clb_output;

   END toYAML;

END;
/

CREATE OR REPLACE TYPE BODY dz_swagger3_server_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_server_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_server_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_server_typ(
       p_server_id           IN  VARCHAR2
      ,p_versionid           IN  VARCHAR2 DEFAULT NULL
   ) RETURN SELF AS RESULT
   AS 
   BEGIN 

      self.versionid := p_versionid;
      
      SELECT
       a.server_url
      ,a.server_description
      INTO
       self.server_url
      ,self.server_description
      FROM
      dz_swagger3_server a
      WHERE
          a.versionid = p_versionid
      AND a.server_id = p_server_id;

      SELECT
      dz_swagger3_object_typ(
          p_object_id      => b.server_var_id
         ,p_object_type_id => 'servervartyp'
         ,p_object_key     => b.server_var_name
         ,p_object_order   => a.server_var_order
      )
      BULK COLLECT INTO self.server_variables
      FROM
      dz_swagger3_server_var_map a
      JOIN
      dz_swagger3_server_variable b
      ON
          a.server_var_id = b.server_var_id
      AND a.versionid     = b.versionid
      WHERE
          a.versionid = p_versionid
      AND a.server_id = p_server_id;
  
      RETURN;
      
   END dz_swagger3_server_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Load the server vars
      --------------------------------------------------------------------------
      IF  self.server_variables IS NOT NULL
      AND self.server_variables.COUNT > 0
      THEN
         dz_swagger3_loader.servervartyp(
             p_parent_id    => self.server_url
            ,p_children_ids => self.server_variables
            ,p_versionid    => self.versionid
         );
         
      END IF;

   END traverse;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_hash         CLOB;
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add name element
      --------------------------------------------------------------------------
      str_pad1 := str_pad;
      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.value2json(
             'url'
            ,self.server_url
            ,p_pretty_print + 1
         )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional url 
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.value2json(
             'description'
            ,self.server_description
            ,p_pretty_print + 1
         )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional variables map
      --------------------------------------------------------------------------
      IF  self.server_variables IS NOT NULL 
      AND self.server_variables.COUNT > 0
      THEN
         EXECUTE IMMEDIATE 
            'SELECT '
         || ' a.servervartyp.toJSON( '
         || '    p_pretty_print  => :p01 + 2 '
         || '   ,p_force_inline  => :p02 '
         || '   ,p_short_id      => :p03 '
         || ' ) '
         || ',b.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p01) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      = b.object_id '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO
          ary_clb
         ,ary_keys
         USING 
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.server_variables;   
      
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('{',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('{',-1);
            
         END IF;
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_keys(i)
               ,p_pretty_print + 2
            );
            str_pad2 := ',';
         
         END LOOP;
         
         clb_hash := clb_hash || dz_json_util.pretty(
             '}'
            ,p_pretty_print + 1,NULL,NULL
         );
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                 'variables'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output        CLOB;
      ary_keys          MDSYS.SDO_STRING2_ARRAY;
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the url item, note the dumn handling if object array
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty_str(
          'url: ' || dz_swagger3_util.yaml_text(
             self.server_url
            ,p_pretty_print
         )
         ,p_pretty_print
         ,'  '
      );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional description item
      --------------------------------------------------------------------------
      IF self.server_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'description: ' || dz_swagger3_util.yaml_text(
                self.server_description
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the optional variables map
      --------------------------------------------------------------------------
      IF  self.server_variables IS NOT NULL 
      AND self.server_variables.COUNT > 0
      THEN
         EXECUTE IMMEDIATE 
            'SELECT '
         || ' a.servervartyp.toYAML( '
         || '    p_pretty_print  => :p01 + 2 '
         || '   ,p_force_inline  => :p02 '
         || '   ,p_short_id      => :p03 '
         || ' ) '
         || ',b.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p01) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      = b.object_id '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO
          ary_clb
         ,ary_keys
         USING 
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.server_variables; 
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'variables: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '''' || ary_keys(i) || ''': '
               ,p_pretty_print + 1
               ,'  '
            ) || ary_clb(i);
         
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Cough it out without final line feed
      --------------------------------------------------------------------------
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(10) || '$','');
         
      END IF;
               
      RETURN clb_output;
      
   END toYAML;
   
END;
/

CREATE OR REPLACE TYPE BODY dz_swagger3_securityScheme_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_securityScheme_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_securityScheme_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_securityScheme_typ(
       p_securityscheme_id       IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
   BEGIN
      SELECT
       a.securityscheme_id
      ,a.securityscheme_type
      ,a.securityscheme_description
      ,a.securityscheme_name
      ,a.securityscheme_in
      ,a.securityscheme_bearerFormat
      INTO
       self.securityscheme_id
      ,self.securityscheme_type
      ,self.securityscheme_description
      ,self.securityscheme_name
      ,self.securityscheme_in
      ,self.securityscheme_bearerFormat
      FROM
      dz_swagger3_securityScheme a
      WHERE
          a.versionid         = p_versionid
      AND a.securityscheme_id = p_securityscheme_id;

      RETURN; 
      
   END dz_swagger3_securityScheme_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_identifier   VARCHAR2(255 Char);
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;
      
      str_pad1 := str_pad;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Add  the ref object
      --------------------------------------------------------------------------
      IF  COALESCE(p_force_inline,'FALSE') = 'FALSE'
      AND p_reference_count > 1
      THEN
         IF p_short_id = 'TRUE'
         THEN
            str_identifier := p_short_identifier;
            
         ELSE
            str_identifier := p_identifier;
            
         END IF;
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                '$ref'
               ,'#/components/securitySchemes/' || str_identifier
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
      
      ELSE
      --------------------------------------------------------------------------
      -- Step 30
      -- Add scheme type
      --------------------------------------------------------------------------
         IF self.securityscheme_type IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'type'
                  ,self.securityscheme_type
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Add scheme description
      --------------------------------------------------------------------------
         IF self.securityscheme_description IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'description'
                  ,self.securityscheme_description
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add scheme name
      --------------------------------------------------------------------------
         IF self.securityscheme_name IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'name'
                  ,self.securityscheme_name
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add scheme in
      --------------------------------------------------------------------------
         IF self.securityscheme_in IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'in'
                  ,self.securityscheme_in
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Add scheme auth
      --------------------------------------------------------------------------
         IF self.securityscheme_auth IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'auth'
                  ,self.securityscheme_auth
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Add scheme bearerFormat
      --------------------------------------------------------------------------
         IF self.securityscheme_bearerFormat IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'bearerFormat'
                  ,self.securityscheme_bearerFormat
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Add flows object
      --------------------------------------------------------------------------
         IF  self.securityscheme_flows IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                   'flows'
                  ,self.securityscheme_flows.toJSON(
                      p_pretty_print   => p_pretty_print + 1
                     ,p_force_inline   => p_force_inline   
                   )
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Add scheme openIdConnectUrl
      --------------------------------------------------------------------------
         IF self.securityscheme_openIdConUrl IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'openIdConnectUrl'
                  ,self.securityscheme_openIdConUrl
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 110
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_identifier   VARCHAR2(255 Char);
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      IF  COALESCE(p_force_inline,'FALSE') = 'FALSE'
      AND p_reference_count > 1
      THEN
         IF p_short_id = 'TRUE'
         THEN
            str_identifier := p_short_identifier;
            
         ELSE
            str_identifier := p_identifier;
            
         END IF;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             '$ref: ' || dz_swagger3_util.yaml_text(
                '#/components/securitySchemes/' || str_identifier
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      ELSE
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml scheme type
      --------------------------------------------------------------------------
         IF self.securityscheme_type IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'type: ' || dz_swagger3_util.yaml_text(
                   self.securityscheme_type
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the yaml scheme description
      --------------------------------------------------------------------------
         IF self.securityscheme_description IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'description: ' || dz_swagger3_util.yaml_text(
                   self.securityscheme_description
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the yaml scheme name
      --------------------------------------------------------------------------
         IF self.securityscheme_name IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'name: ' || dz_swagger3_util.yaml_text(
                   self.securityscheme_name
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the yaml scheme in
      --------------------------------------------------------------------------
         IF self.securityscheme_in IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'in: ' || dz_swagger3_util.yaml_text(
                   self.securityscheme_in
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Write the yaml scheme auth
      --------------------------------------------------------------------------
         IF self.securityscheme_auth IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'scheme: ' || dz_swagger3_util.yaml_text(
                   self.securityscheme_auth
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Write the yaml scheme in
      --------------------------------------------------------------------------
         IF self.securityscheme_bearerFormat IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'bearerFormat: ' || dz_swagger3_util.yaml_text(
                   self.securityscheme_bearerFormat
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Write the yaml scheme in
      --------------------------------------------------------------------------
         IF self.securityscheme_flows IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'flows: '
               ,p_pretty_print
               ,'  '
            ) || self.securityscheme_flows.toYAML(
                p_pretty_print   => p_pretty_print + 1
               ,p_force_inline   => p_force_inline
            );  
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Write the yaml scheme in
      --------------------------------------------------------------------------
         IF self.securityscheme_openIdConUrl IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'openIdConnectUrl: ' || dz_swagger3_util.yaml_text(
                   self.securityscheme_openIdConUrl
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Cough it out without final line feed
      --------------------------------------------------------------------------
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(10) || '$','');
         
      END IF;
               
      RETURN clb_output;
      
   END toYAML;
   
END;
/

CREATE OR REPLACE TYPE BODY dz_swagger3_security_req_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_security_req_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_security_req_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_security_req_typ(
       p_security_req_name  IN  VARCHAR2
      ,p_scope_names        IN  MDSYS.SDO_STRING2_ARRAY
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.security_req_name := p_security_req_name;
      self.scope_names       := p_scope_names;
      
      RETURN; 
      
   END dz_swagger3_security_req_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_pad          VARCHAR2(1 Char);
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('[',NULL);
         
      ELSE
         clb_output  := dz_json_util.pretty('[',-1);
         str_pad     := ' ';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add name element
      --------------------------------------------------------------------------
      IF  self.scope_names IS NOT NULL
      AND self.scope_names.COUNT > 0
      THEN
         FOR i IN 1 .. self.scope_names.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                str_pad || dz_json_main.json_format(self.scope_names(i))
               ,p_pretty_print + 1
            );
            str_pad := ',';

         END LOOP;
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          ']'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output        CLOB;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml contact name
      --------------------------------------------------------------------------
      IF  self.scope_names IS NOT NULL
      AND self.scope_names.COUNT > 0
      THEN
         clb_output := clb_output || ': ';

         FOR i IN 1 .. self.scope_names.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '- ' || dz_swagger3_util.yaml_text(self.scope_names(i),p_pretty_print)
               ,p_pretty_print
               ,'  '
            );

         END LOOP;

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Cough it out without final line feed
      --------------------------------------------------------------------------
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(10) || '$','');
         
      END IF;
               
      RETURN clb_output;
      
   END toYAML;
   
END;
/

CREATE OR REPLACE TYPE BODY dz_swagger3_schema_typ
AS 
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_schema_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_schema_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_schema_typ(
       p_schema_id               IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Initialize the object
      --------------------------------------------------------------------------
      self.versionid := p_versionid;

      --------------------------------------------------------------------------
      -- Step 20
      -- Load the easy items using constructor
      --------------------------------------------------------------------------
      SELECT
       a.schema_id
      ,a.schema_category
      ,a.schema_title
      ,a.schema_type
      ,a.schema_description
      ,a.schema_format
      ,a.schema_nullable
      ,a.schema_discriminator
      ,a.schema_readonly
      ,a.schema_writeonly
      ,CASE
       WHEN a.schema_externaldocs_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id => a.schema_externaldocs_id
            ,p_object_type_id => 'extrdocstyp'
         )
       ELSE
         NULL
       END
      ,a.schema_example_string
      ,a.schema_example_number
      ,a.schema_deprecated
      ,CASE
       WHEN a.schema_items_schema_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id      => a.schema_items_schema_id
            ,p_object_type_id => 'schematyp'
         )
       ELSE
         NULL
       END
      ,a.schema_default_string
      ,a.schema_default_number
      ,a.schema_multipleOf
      ,a.schema_minimum
      ,a.schema_exclusiveMinimum
      ,a.schema_maximum 
      ,a.schema_exclusiveMaximum
      ,a.schema_minLength
      ,a.schema_maxLength
      ,a.schema_pattern
      ,a.schema_minItems
      ,a.schema_maxItems
      ,a.schema_uniqueItems 
      ,a.schema_minProperties
      ,a.schema_maxProperties
      ,a.xml_name
      ,a.xml_namespace
      ,a.xml_prefix
      ,a.xml_attribute
      ,a.xml_wrapped
      ,a.schema_force_inline
      ,a.property_list_hidden
      INTO
       self.schema_id
      ,self.schema_category
      ,self.schema_title
      ,self.schema_type
      ,self.schema_description
      ,self.schema_format
      ,self.schema_nullable
      ,self.schema_discriminator
      ,self.schema_readonly
      ,self.schema_writeonly
      ,self.schema_externaldocs
      ,self.schema_example_string
      ,self.schema_example_number
      ,self.schema_deprecated
      ,self.schema_items_schema
      ,self.schema_default_string
      ,self.schema_default_number
      ,self.schema_multipleOf
      ,self.schema_minimum
      ,self.schema_exclusiveMinimum
      ,self.schema_maximum 
      ,self.schema_exclusiveMaximum
      ,self.schema_minLength
      ,self.schema_maxLength
      ,self.schema_pattern
      ,self.schema_minItems
      ,self.schema_maxItems
      ,self.schema_uniqueItems 
      ,self.schema_minProperties
      ,self.schema_maxProperties
      ,self.xml_name
      ,self.xml_namespace
      ,self.xml_prefix
      ,self.xml_attribute
      ,self.xml_wrapped
      ,self.schema_force_inline
      ,self.property_list_hidden
      FROM
      dz_swagger3_schema a
      WHERE
          a.versionid = p_versionid
      AND a.schema_id = p_schema_id;

      --------------------------------------------------------------------------
      -- Step 30
      -- Collect the enumerations
      --------------------------------------------------------------------------
      SELECT
      a.enum_string
      BULK COLLECT INTO
      self.schema_enum_string
      FROM
      dz_swagger3_schema_enum_map a
      WHERE
          a.versionid = p_versionid
      AND a.schema_id = p_schema_id
      AND a.enum_string IS NOT NULL;
      
      SELECT
      a.enum_number
      BULK COLLECT INTO
      self.schema_enum_number
      FROM
      dz_swagger3_schema_enum_map a
      WHERE
          a.versionid = p_versionid
      AND a.schema_id = p_schema_id
      AND a.enum_number IS NOT NULL;

      --------------------------------------------------------------------------
      -- Step 40
      -- Load the schema properties
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id           => a.property_schema_id 
         ,p_object_type_id      => 'schematyp'
         ,p_object_key          => a.property_name
         ,p_object_required     => a.property_required
         ,p_object_force_inline => b.schema_force_inline
         ,p_object_order        => a.property_order
      )
      BULK COLLECT INTO self.schema_properties
      FROM
      dz_swagger3_schema_prop_map a
      JOIN
      dz_swagger3_schema b
      ON
          a.versionid          = b.versionid
      AND a.property_schema_id = b.schema_id
      WHERE
          a.versionid        = p_versionid
      AND a.parent_schema_id = self.schema_id;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Load the schema combines
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id      => a.combine_schema_id
         ,p_object_type_id => 'schematyp'
         ,p_object_key     => a.combine_keyword
         ,p_object_order   => a.combine_order
      )
      BULK COLLECT INTO self.combine_schemas
      FROM
      dz_swagger3_schema_combine_map a
      JOIN
      dz_swagger3_schema b
      ON
          a.versionid         = b.versionid
      AND a.combine_schema_id = b.schema_id
      WHERE
          a.versionid         = p_versionid
      AND a.schema_id         = self.schema_id;  

      --------------------------------------------------------------------------
      -- Step 60
      -- Return completed object
      --------------------------------------------------------------------------
      RETURN;
      
   END dz_swagger3_schema_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_schema_typ(
       p_schema_id                IN  VARCHAR2
      ,p_parameters               IN  dz_swagger3_object_vry
      ,p_versionid                IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Initialize the object
      --------------------------------------------------------------------------
      self.versionid := p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Load the bare array to hold the parameter derived schema object
      --------------------------------------------------------------------------
      self.schema_id           := p_schema_id;
      self.schema_type         := 'object';
      self.schema_category     := 'object';
      self.schema_nullable     := 'FALSE';

      --------------------------------------------------------------------------
      -- Step 30
      -- Load the items on the schema object as properties
      --------------------------------------------------------------------------
      self.schema_properties := dz_swagger3_object_vry();
      self.schema_properties.EXTEND(p_parameters.COUNT);

      FOR i IN 1 .. p_parameters.COUNT
      LOOP
         self.schema_properties(i) := dz_swagger3_object_typ(
             p_object_id        => 'rb.' || p_parameters(i).object_id
            ,p_object_type_id   => 'schematyp'
            ,p_object_key       => p_parameters(i).object_key
            ,p_object_subtype   => 'emulated_item'
            ,p_object_attribute => p_parameters(i).object_id
            ,p_object_required  => p_parameters(i).object_required
            ,p_object_order     => p_parameters(i).object_order
         );
         
      END LOOP;

      --------------------------------------------------------------------------
      -- Step 50
      -- Return completed object
      --------------------------------------------------------------------------
      RETURN;
      
   END dz_swagger3_schema_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_schema_typ(
       p_schema_id                IN  VARCHAR2
      ,p_emulated_parameter_id    IN  VARCHAR2
      ,p_versionid                IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
      str_inner_schema_id VARCHAR2(255 Char);

   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Initialize the object
      --------------------------------------------------------------------------
      self.versionid := p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Load the bare array to hold the parameter derived schema object
      --------------------------------------------------------------------------
      self.schema_id := p_schema_id;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Load the parameter details to emulate
      --------------------------------------------------------------------------
      SELECT
       a.parameter_schema_id
      ,a.parameter_name || ' rb'
      ,a.parameter_description
      ,a.parameter_required
      ,a.parameter_example_string
      ,a.parameter_example_number
      ,a.parameter_list_hidden
      INTO
       str_inner_schema_id
      ,self.schema_title
      ,self.schema_description
      ,self.schema_required
      ,self.schema_example_string
      ,self.schema_example_number
      ,self.property_list_hidden
      FROM
      dz_swagger3_parameter a
      WHERE
          a.parameter_id = p_emulated_parameter_id
      AND a.versionid    = p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Load the easy items using constructor
      --------------------------------------------------------------------------
      SELECT
       a.schema_category
      ,a.schema_type
      ,a.schema_format
      ,a.schema_default_string
      ,a.schema_default_number
      ,a.schema_multipleOf
      ,a.schema_minimum
      ,a.schema_exclusiveMinimum
      ,a.schema_maximum 
      ,a.schema_exclusiveMaximum
      ,a.schema_minLength
      ,a.schema_maxLength
      ,a.schema_pattern
      ,a.schema_minItems
      ,a.schema_maxItems
      ,a.schema_uniqueItems 
      ,a.schema_minProperties
      ,a.schema_maxProperties
      INTO
       self.schema_category
      ,self.schema_type
      ,self.schema_format
      ,self.schema_default_string
      ,self.schema_default_number
      ,self.schema_multipleOf
      ,self.schema_minimum
      ,self.schema_exclusiveMinimum
      ,self.schema_maximum 
      ,self.schema_exclusiveMaximum
      ,self.schema_minLength
      ,self.schema_maxLength
      ,self.schema_pattern
      ,self.schema_minItems
      ,self.schema_maxItems
      ,self.schema_uniqueItems 
      ,self.schema_minProperties
      ,self.schema_maxProperties
      FROM
      dz_swagger3_schema a
      WHERE
          a.versionid = p_versionid
      AND a.schema_id = str_inner_schema_id;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Collect the enumerations
      --------------------------------------------------------------------------
      SELECT
      a.enum_string
      BULK COLLECT INTO
      self.schema_enum_string
      FROM
      dz_swagger3_schema_enum_map a
      WHERE
          a.versionid = p_versionid
      AND a.schema_id = str_inner_schema_id
      AND a.enum_string IS NOT NULL;
      
      SELECT
      a.enum_number
      BULK COLLECT INTO
      self.schema_enum_number
      FROM
      dz_swagger3_schema_enum_map a
      WHERE
          a.versionid = p_versionid
      AND a.schema_id = str_inner_schema_id
      AND a.enum_number IS NOT NULL;
   
      --------------------------------------------------------------------------
      -- Step 60
      -- Return completed object
      --------------------------------------------------------------------------
      RETURN;
      
   END dz_swagger3_schema_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Load the external docs
      --------------------------------------------------------------------------
      IF self.schema_externalDocs IS NOT NULL
      THEN
         dz_swagger3_loader.extrdocstyp(
             p_parent_id    => self.schema_id
            ,p_children_ids => dz_swagger3_object_vry(self.schema_externalDocs)
            ,p_versionid    => self.versionid
         );
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Load the items schema
      --------------------------------------------------------------------------
      IF self.schema_items_schema IS NOT NULL
      THEN
         dz_swagger3_loader.schematyp(
             p_parent_id    => self.schema_id
            ,p_children_ids => dz_swagger3_object_vry(self.schema_items_schema)
            ,p_versionid    => self.versionid
         );
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Load the properties schemas
      --------------------------------------------------------------------------
      IF  self.schema_properties IS NOT NULL
      AND self.schema_properties.COUNT > 0
      THEN
         dz_swagger3_loader.schematyp(
             p_parent_id    => self.schema_id
            ,p_children_ids => self.schema_properties
            ,p_versionid    => self.versionid
         );
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Load the combine schemas
      --------------------------------------------------------------------------
      IF  self.combine_schemas IS NOT NULL
      AND self.combine_schemas.COUNT > 0
      THEN
         dz_swagger3_loader.schematyp(
             p_parent_id    => self.schema_id
            ,p_children_ids => self.combine_schemas
            ,p_versionid    => self.versionid
         );
         
      END IF;

   END traverse;
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
      ,p_jsonschema          IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
   BEGIN
   
      IF  self.combine_schemas IS NOT NULL
      AND self.combine_schemas.COUNT > 0
      THEN
         RETURN self.toJSON_combine(
             p_pretty_print     => p_pretty_print
            ,p_force_inline     => p_force_inline
            ,p_short_id         => p_short_id
            ,p_jsonschema       => p_jsonschema
         );
         
      ELSE
         RETURN self.toJSON_schema(
             p_pretty_print     => p_pretty_print
            ,p_force_inline     => p_force_inline
            ,p_short_id         => p_short_id
            ,p_identifier       => p_identifier
            ,p_short_identifier => p_short_identifier
            ,p_reference_count  => p_reference_count 
            ,p_jsonschema       => p_jsonschema
         );
         
      END IF;
      
   END toJSON;
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON_schema(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
      ,p_jsonschema          IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      str_jsonschema   VARCHAR2(4000 Char) := UPPER(p_jsonschema);
      clb_output       CLOB;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_items        MDSYS.SDO_STRING2_ARRAY;
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      ary_required     MDSYS.SDO_STRING2_ARRAY;
      clb_hash         CLOB;
      clb_tmp          CLOB;
      int_counter      PLS_INTEGER;
      boo_temp         BOOLEAN;
      str_identifier   VARCHAR2(255 Char);
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      IF str_jsonschema IS NULL
      OR str_jsonschema NOT IN ('TRUE','FALSE')
      THEN
         str_jsonschema := 'FALSE';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad  := ' ';
         
      END IF;
      
      str_pad1 := str_pad;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Add  the ref object
      --------------------------------------------------------------------------
      IF  COALESCE(p_force_inline,'FALSE') = 'FALSE'
      AND p_reference_count > 1
      THEN
         IF p_short_id = 'TRUE'
         THEN
            str_identifier := p_short_identifier;
            
         ELSE
            str_identifier := p_identifier;
            
         END IF;
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                '$ref'
               ,'#/components/schemas/' || dz_swagger3_util.utl_url_escape(
                  str_identifier
                )
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      ELSE
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional title object
      --------------------------------------------------------------------------
         IF self.inject_jsonschema = 'TRUE'
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   '$schema'
                  ,'http://json-schema.org/draft-04/schema#'
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add base attributes
      --------------------------------------------------------------------------
         IF str_jsonschema = 'TRUE'
         AND self.schema_nullable = 'TRUE'
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'type'
                  ,MDSYS.SDO_STRING2_ARRAY(self.schema_type,'null')
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
         
         ELSE
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'type'
                  ,self.schema_type
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional title object
      --------------------------------------------------------------------------
         IF self.schema_title IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'title'
                  ,self.schema_title
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional description object
      --------------------------------------------------------------------------
         IF self.schema_description IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'description'
                  ,self.schema_description
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add optional description object
      --------------------------------------------------------------------------
         IF self.schema_format IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'format'
                  ,self.schema_format
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Add optional enum array
      --------------------------------------------------------------------------
         IF  self.schema_enum_string IS NOT NULL
         AND self.schema_enum_string.COUNT > 0
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'enum'
                  ,self.schema_enum_string
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
         
         ELSIF  self.schema_enum_number IS NOT NULL
         AND self.schema_enum_number.COUNT > 0
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'enum'
                  ,self.schema_enum_number
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Add optional description object
      --------------------------------------------------------------------------
         IF  self.schema_nullable IS NOT NULL
         AND str_jsonschema <> 'TRUE'
         THEN
            IF LOWER(self.schema_nullable) = 'true'
            THEN
               boo_temp := TRUE;
               
            ELSE
               boo_temp := FALSE;
            
            END IF;
         
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'nullable'
                  ,boo_temp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Add optional description object
      --------------------------------------------------------------------------
         IF self.schema_discriminator IS NOT NULL
         AND str_jsonschema <> 'TRUE'
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'discriminator'
                  ,self.schema_discriminator
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Add optional readOnly and writeOnly attributes
      --------------------------------------------------------------------------
         IF self.schema_readOnly IS NOT NULL
         AND str_jsonschema <> 'TRUE'
         THEN
            IF LOWER(self.schema_readOnly) = 'true'
            THEN
               boo_temp := TRUE;
               
            ELSE
               boo_temp := FALSE;
            
            END IF;
         
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'readOnly'
                  ,boo_temp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
         
         END IF;
         
         IF self.schema_writeOnly IS NOT NULL
         AND str_jsonschema <> 'TRUE'
         THEN
            IF LOWER(self.schema_writeOnly) = 'true'
            THEN
               boo_temp := TRUE;
               
            ELSE
               boo_temp := FALSE;
            
            END IF;
         
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'writeOnly'
                  ,boo_temp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Add optional minItems and MaxItems attribute
      --------------------------------------------------------------------------
         IF self.schema_maxItems IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'maxItems'
                  ,self.schema_maxItems
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
         
         END IF;
         
         IF self.schema_minItems IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'minItems'
                  ,self.schema_minItems
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Add optional minProperties and MaxProperties attribute
      --------------------------------------------------------------------------
         IF self.schema_maxProperties IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'maxProperties'
                  ,self.schema_maxProperties
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
         
         END IF;
         
         IF self.schema_minProperties IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'minProperties'
                  ,self.schema_minProperties
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 130
      -- Add optional externalDocs
      --------------------------------------------------------------------------
         IF  self.schema_externalDocs IS NOT NULL
         AND str_jsonschema <> 'TRUE'
         THEN
            BEGIN
               EXECUTE IMMEDIATE
                  'SELECT '
               || 'a.extrdocstyp.toJSON( '
               || '    p_pretty_print   => :p01 + 1 '
               || '   ,p_force_inline   => :p02 '
               || '   ,p_short_id       => :p03 '
               || ') '
               || 'FROM '
               || 'dz_swagger3_xobjects a '
               || 'WHERE '
               || '    a.object_type_id = :p04 '
               || 'AND a.object_id      = :p05 '
               INTO clb_tmp
               USING 
                p_pretty_print
               ,p_force_inline
               ,p_short_id
               ,self.schema_externalDocs.object_type_id 
               ,self.schema_externalDocs.object_id;
            
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END; 
         
            clb_output := clb_output || dz_json_util.pretty(
                str_pad || dz_json_main.formatted2json(
                   'externalDocs'
                  ,clb_tmp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 140
      -- Add optional example scalars
      --------------------------------------------------------------------------
         IF self.schema_example_string IS NOT NULL
         AND str_jsonschema <> 'TRUE'
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'example'
                  ,self.schema_example_string
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
         
         ELSIF self.schema_example_number IS NOT NULL
         AND str_jsonschema <> 'TRUE'
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'example'
                  ,self.schema_example_number
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 150
      -- Add optional deprecated object
      --------------------------------------------------------------------------
         IF  LOWER(self.schema_deprecated) = 'true'
         AND str_jsonschema <> 'TRUE'
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'deprecated'
                  ,TRUE
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 160
      -- Add schema items
      --------------------------------------------------------------------------
         IF self.schema_items_schema IS NOT NULL
         THEN
            BEGIN
               EXECUTE IMMEDIATE
                  'SELECT '
               || 'a.schematyp.toJSON( '
               || '    p_pretty_print     => :p01 + 1 '
               || '   ,p_force_inline     => :p02 '
               || '   ,p_short_id         => :p03 '
               || '   ,p_identifier       => a.object_id '
               || '   ,p_short_identifier => a.short_id '
               || '   ,p_reference_count  => a.reference_count '
               || ') '
               || 'FROM '
               || 'dz_swagger3_xobjects a '
               || 'WHERE '
               || '    a.object_type_id = :p04 '
               || 'AND a.object_id      = :p05 '
               INTO 
               clb_tmp
               USING
                p_pretty_print
               ,p_force_inline
               ,p_short_id
               ,self.schema_items_schema.object_type_id
               ,self.schema_items_schema.object_id;
            
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;

            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                   'items'
                  ,clb_tmp
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 170
      -- Add optional xml object
      --------------------------------------------------------------------------
         IF str_jsonschema = 'FALSE'
         THEN
            IF self.xml_name      IS NOT NULL
            OR self.xml_namespace IS NOT NULL
            OR self.xml_prefix    IS NOT NULL
            OR self.xml_attribute IS NOT NULL
            OR self.xml_wrapped   IS NOT NULL
            THEN
               clb_output := clb_output || dz_json_util.pretty(
                   str_pad1 || dz_json_main.formatted2json(
                      'xml'
                     ,dz_swagger3_xml_typ(
                         p_xml_name       => self.xml_name
                        ,p_xml_namespace  => self.xml_namespace
                        ,p_xml_prefix     => self.xml_prefix
                        ,p_xml_attribute  => self.xml_attribute
                        ,p_xml_wrapped    => self.xml_wrapped
                      ).toJSON(
                         p_pretty_print   => p_pretty_print + 1
                        ,p_force_inline   => p_force_inline
                      )
                     ,p_pretty_print + 1
                   )
                  ,p_pretty_print + 1
               );
               str_pad1 := ',';
               
            END IF;
            
         END IF;
      
      -------------------------------------------------------------------------
      -- Step 180
      -- Add parameters
      -------------------------------------------------------------------------
         IF  self.schema_properties IS NOT NULL 
         AND self.schema_properties.COUNT > 0
         THEN
            EXECUTE IMMEDIATE
               'SELECT '
            || ' a.schematyp.toJSON( '
            || '    p_pretty_print     => :p01 + 2 '
            || '   ,p_force_inline     => :p02 '
            || '   ,p_short_id         => :p03 '
            || '   ,p_identifier       => a.object_id '
            || '   ,p_short_identifier => a.short_id '
            || '   ,p_reference_count  => a.reference_count '
            || ' ) '
            || ',b.object_key '
            || ',b.object_required '
            || 'FROM '
            || 'dz_swagger3_xobjects a '
            || 'JOIN '
            || 'TABLE(:p04) b '
            || 'ON '
            || '    a.object_type_id = b.object_type_id '
            || 'AND a.object_id      = b.object_id '
            || 'WHERE '
            || 'COALESCE(a.schematyp.property_list_hidden,''FALSE'') <> ''TRUE'' '
            || 'ORDER BY b.object_order '
            BULK COLLECT INTO 
             ary_clb
            ,ary_keys
            ,ary_required
            USING
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.schema_properties; 

            str_pad2 := str_pad;
            ary_items := MDSYS.SDO_STRING2_ARRAY();
            
            IF p_pretty_print IS NULL
            THEN
               clb_hash := dz_json_util.pretty('{',NULL);
               
            ELSE
               clb_hash := dz_json_util.pretty('{',-1);
               
            END IF;

            int_counter := 1;
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_hash := clb_hash || dz_json_util.pretty(
                   str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                  ,p_pretty_print + 2
               );
               str_pad2 := ',';
               
               IF ary_required(i) = 'TRUE'
               THEN
                  ary_items.EXTEND();
                  ary_items(int_counter) := ary_keys(i);
                  int_counter := int_counter + 1;

               END IF;
            
            END LOOP;
            
            clb_hash := clb_hash || dz_json_util.pretty(
                '}'
               ,p_pretty_print + 1,NULL,NULL
            );
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                    'properties'
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
         
      -------------------------------------------------------------------------
      -- Step 190
      -- Add required array
      -------------------------------------------------------------------------
            IF ary_items IS NOT NULL
            AND ary_items.COUNT > 0
            THEN
               clb_output := clb_output || dz_json_util.pretty(
                   str_pad1 || dz_json_main.value2json(
                      'required'
                     ,ary_items
                     ,p_pretty_print + 1
                  )
                  ,p_pretty_print + 1
               );
               str_pad1 := ',';
            
            END IF;
            
         END IF;
            
      END IF;

      --------------------------------------------------------------------------
      -- Step 200
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 210
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON_schema;
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON_combine(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_jsonschema          IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      str_jsonschema   VARCHAR2(4000 Char) := UPPER(p_jsonschema);
      clb_output       CLOB;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_hash         CLOB;
      boo_is_not       BOOLEAN := FALSE;
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over object status
      --------------------------------------------------------------------------
      IF self.combine_schemas IS NULL
      OR self.combine_schemas.COUNT = 0
      THEN
         RAISE_APPLICATION_ERROR(-20001,'err');

      END IF;
      
      EXECUTE IMMEDIATE
         'SELECT '
      || ' a.schematyp.toJSON( '
      || '    p_pretty_print     => :p01 + 2 '
      || '   ,p_force_inline     => :p02 '
      || '   ,p_short_id         => :p03 '
      || '   ,p_identifier       => a.object_id '
      || '   ,p_short_identifier => a.short_id '
      || '   ,p_reference_count  => a.reference_count '
      || '   ,p_jsonschema       => :p04 '
      || ' ) '
      || ',b.object_key '
      || 'FROM '
      || 'dz_swagger3_xobjects a '
      || 'JOIN '
      || 'TABLE(:p05) b '
      || 'ON '
      || '    a.object_type_id = b.object_type_id '
      || 'AND a.object_id      = b.object_id '
      || 'ORDER BY b.object_order '
      BULK COLLECT INTO 
       ary_clb
      ,ary_keys
      USING
       p_pretty_print
      ,p_force_inline
      ,p_short_id
      ,p_jsonschema
      ,self.combine_schemas; 
       
      IF ary_keys.COUNT = 1 AND ary_keys(1) = 'not'
      THEN
         boo_is_not := TRUE;
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad  := ' ';
         
      END IF;
      
      str_pad1 := str_pad;

      --------------------------------------------------------------------------
      -- Step 30
      -- Add base attributes
      --------------------------------------------------------------------------
      IF self.schema_type IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                'type'
               ,self.schema_type
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Add the left bracket
      --------------------------------------------------------------------------
      IF boo_is_not
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.formatted2json(
                'not'
               ,ary_clb(1)
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';
      
      ELSE
         str_pad2 := str_pad;
            
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('[',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('[',-1);
            
         END IF;
      
         FOR i IN 1 .. combine_schemas.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || ary_clb(i)
               ,p_pretty_print + 2
            );
            str_pad2 := ',';
         
         END LOOP;
         
         clb_hash := clb_hash || dz_json_util.pretty(
             ']'
            ,p_pretty_print + 1,NULL,NULL
         );
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                 ary_keys(1)
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
      
   END toJSON_combine;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
   BEGIN

      IF  self.combine_schemas IS NOT NULL
      AND self.combine_schemas.COUNT > 0
      THEN
         RETURN self.toYAML_combine(
             p_pretty_print     => p_pretty_print
            ,p_initial_indent   => p_initial_indent
            ,p_final_linefeed   => p_final_linefeed
            ,p_force_inline     => p_force_inline
            ,p_short_id         => p_short_id
         );
         
      ELSE
         RETURN self.toYAML_schema(
             p_pretty_print     => p_pretty_print
            ,p_initial_indent   => p_initial_indent
            ,p_final_linefeed   => p_final_linefeed
            ,p_force_inline     => p_force_inline
            ,p_short_id         => p_short_id
            ,p_identifier       => p_identifier
            ,p_short_identifier => p_short_identifier
            ,p_reference_count  => p_reference_count 
         );
         
      END IF;
      
   END toYAML;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML_schema(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      ary_items        MDSYS.SDO_STRING2_ARRAY;
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      ary_required     MDSYS.SDO_STRING2_ARRAY;
      clb_hash         CLOB;
      clb_tmp          CLOB;
      int_counter      PLS_INTEGER;
      boo_check        BOOLEAN;
      str_identifier   VARCHAR2(255 Char);
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      IF  COALESCE(p_force_inline,'FALSE') = 'FALSE'
      AND p_reference_count > 1
      THEN
         IF p_short_id = 'TRUE'
         THEN
            str_identifier := p_short_identifier;
            
         ELSE
            str_identifier := p_identifier;
            
         END IF;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             '$ref: ' || dz_swagger3_util.yaml_text(
                '#/components/schemas/' || str_identifier
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      ELSE
      --------------------------------------------------------------------------
      -- Step 20
      -- Do the type element
      --------------------------------------------------------------------------
         clb_output := clb_output || dz_json_util.pretty_str(
             'type: ' || self.schema_type
            ,p_pretty_print
            ,'  '
         );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional title object
      --------------------------------------------------------------------------
         IF self.schema_title IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'title: ' || dz_swagger3_util.yamlq(self.schema_title)
               ,p_pretty_print
               ,'  '
            );
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional description object
      --------------------------------------------------------------------------
         IF self.schema_description IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'description: ' || dz_swagger3_util.yaml_text(
                   REGEXP_REPLACE(self.schema_description,CHR(10) || '$','')
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional format attribute
      --------------------------------------------------------------------------
         IF self.schema_format IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'format: ' || self.schema_format
               ,p_pretty_print
               ,'  '
            );
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add optional nullable attribute
      --------------------------------------------------------------------------
         IF self.schema_nullable IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'nullable: ' || LOWER(self.schema_nullable)
               ,p_pretty_print
               ,'  '
            );
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Add optional enum array
      --------------------------------------------------------------------------
         IF  self.schema_enum_string IS NOT NULL
         AND self.schema_enum_string.COUNT > 0
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'enum: '
               ,p_pretty_print
               ,'  '
            );
            
            FOR i IN 1 .. self.schema_enum_string.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty_str(
                   '- ' || dz_swagger3_util.yamlq(self.schema_enum_string(i))
                  ,p_pretty_print + 1
                  ,'  '
               );
               
            END LOOP;
         
         ELSIF  self.schema_enum_number IS NOT NULL
         AND self.schema_enum_number.COUNT > 0
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'enum: '
               ,p_pretty_print
               ,'  '
            );
            
            FOR i IN 1 .. self.schema_enum_number.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty_str(
                   '- ' || self.schema_enum_number(i)
                  ,p_pretty_print + 1
                  ,'  '
               );
               
            END LOOP;
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Add optional discriminator attribute
      --------------------------------------------------------------------------
         IF self.schema_discriminator IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'discriminator: ' || self.schema_discriminator
               ,p_pretty_print
               ,'  '
            );
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Add optional readonly and writeonly booleans
      --------------------------------------------------------------------------
         IF self.schema_readOnly IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'readOnly: ' || LOWER(self.schema_readOnly)
               ,p_pretty_print
               ,'  '
            );
         
         END IF;
         
         IF self.schema_writeOnly IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'writeOnly: ' || LOWER(self.schema_writeOnly)
               ,p_pretty_print
               ,'  '
            );
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Add optional maxitems and minitems
      --------------------------------------------------------------------------
         IF self.schema_minItems IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'minItems: ' || self.schema_minItems
               ,p_pretty_print
               ,'  '
            );
         
         END IF;
         
         IF self.schema_maxItems IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'maxItems: ' || self.schema_maxItems
               ,p_pretty_print
               ,'  '
            );
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Add optional maxProperties and minProperties
      --------------------------------------------------------------------------
         IF self.schema_minProperties IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'minProperties: ' || self.schema_minProperties
               ,p_pretty_print
               ,'  '
            );
         
         END IF;
         
         IF self.schema_maxProperties IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'maxProperties: ' || self.schema_maxProperties
               ,p_pretty_print
               ,'  '
            );
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Write the optional externalDocs object
      --------------------------------------------------------------------------
         IF  self.schema_externalDocs IS NOT NULL
         THEN
            BEGIN
               EXECUTE IMMEDIATE
                  'SELECT '
               || 'a.extrdocstyp.toYAML( '
               || '    p_pretty_print   => :p01 + 1 '
               || '   ,p_force_inline   => :p02 '
               || '   ,p_short_id       => :p03 '
               || ') '
               || 'FROM '
               || 'dz_swagger3_xobjects a '
               || 'WHERE '
               || '    a.object_type_id = :p04 '
               || 'AND a.object_id      = :p05 '
               INTO clb_tmp
               USING 
                p_pretty_print
               ,p_force_inline
               ,p_short_id
               ,self.schema_externalDocs.object_type_id
               ,self.schema_externalDocs.object_id; 
            
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;
         
            clb_output := clb_output || dz_json_util.pretty_str(
                'externalDocs: ' 
               ,p_pretty_print
               ,'  '
            ) || clb_tmp;
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 130
      -- Add optional description object
      --------------------------------------------------------------------------
         IF self.schema_example_string IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'example: ' || dz_swagger3_util.yamlq(self.schema_example_string)
               ,p_pretty_print
               ,'  '
            );
         
         ELSIF self.schema_example_number IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'example: ' || self.schema_example_number
               ,p_pretty_print
               ,'  '
            );
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 140
      -- Add optional deprecated flag
      --------------------------------------------------------------------------
         IF self.schema_deprecated IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'deprecated: ' || LOWER(self.schema_deprecated)
               ,p_pretty_print
               ,'  '
            );
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 150
      -- Write the optional externalDocs object
      --------------------------------------------------------------------------
         IF  self.schema_items_schema IS NOT NULL
         AND self.schema_items_schema.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT 
               a.schematyp.toYAML( 
                   p_pretty_print     => p_pretty_print + 1 
                  ,p_force_inline     => p_force_inline
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id 
                  ,p_short_identifier => a.short_id 
                  ,p_reference_count  => a.reference_count 
               )
               INTO clb_tmp
               FROM 
               dz_swagger3_xobjects a 
               WHERE 
                   a.object_type_id = self.schema_items_schema.object_type_id
               AND a.object_id      = self.schema_items_schema.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_tmp := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;
         
            clb_output := clb_output || dz_json_util.pretty_str(
                'items: ' 
               ,p_pretty_print
               ,'  '
            ) || clb_tmp;
            
         END IF;

      --------------------------------------------------------------------------
      -- Step 160
      -- Add optional xml object
      --------------------------------------------------------------------------
         IF self.xml_name      IS NOT NULL
         OR self.xml_namespace IS NOT NULL
         OR self.xml_prefix    IS NOT NULL
         OR self.xml_attribute IS NOT NULL
         OR self.xml_wrapped   IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'xml: '
               ,p_pretty_print
               ,'  '
            ) || dz_swagger3_xml_typ(
                p_xml_name      => self.xml_name
               ,p_xml_namespace => self.xml_namespace
               ,p_xml_prefix    => self.xml_prefix
               ,p_xml_attribute => self.xml_attribute
               ,p_xml_wrapped   => self.xml_wrapped
            ).toYAML(
                p_pretty_print   => p_pretty_print + 1
               ,p_force_inline   => p_force_inline
            );
         
         END IF;
      
      -------------------------------------------------------------------------
      -- Step 170
      -- Write the properties map
      -------------------------------------------------------------------------
         IF  self.schema_properties IS NOT NULL 
         AND self.schema_properties.COUNT > 0
         THEN
            EXECUTE IMMEDIATE
               'SELECT '
            || ' a.schematyp.toYAML( '
            || '    p_pretty_print     => :p01 + 2 '
            || '   ,p_force_inline     => :p02 '
            || '   ,p_short_id         => :p03 '
            || '   ,p_identifier       => a.object_id '
            || '   ,p_short_identifier => a.short_id '
            || '   ,p_reference_count  => a.reference_count '
            || ' ) '
            || ',b.object_key '
            || ',b.object_required '
            || 'FROM '
            || 'dz_swagger3_xobjects a '
            || 'JOIN '
            || 'TABLE(:p04) b '
            || 'ON '
            || '    a.object_type_id = b.object_type_id '
            || 'AND a.object_id      = b.object_id '
            || 'WHERE '
            || 'COALESCE(a.schematyp.property_list_hidden,''FALSE'') <> ''TRUE'' '
            || 'ORDER BY b.object_order '
            BULK COLLECT INTO 
             ary_clb
            ,ary_keys
            ,ary_required
            USING
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.schema_properties;          
            
            boo_check    := FALSE;
            int_counter  := 1;
            ary_items    := MDSYS.SDO_STRING2_ARRAY();
            
            clb_output := clb_output || dz_json_util.pretty_str(
                'properties: '
               ,p_pretty_print
               ,'  '
            );

            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   dz_swagger3_util.yamlq(ary_keys(i)) || ': '
                  ,p_pretty_print + 1
                  ,'  '
               ) || ary_clb(i);
               
               IF ary_required(i) = 'TRUE'
               THEN
                  ary_items.EXTEND();
                  ary_items(int_counter) := ary_keys(i);
                  int_counter := int_counter + 1;
                  boo_check   := TRUE;

               END IF;
            
            END LOOP;
         
      --------------------------------------------------------------------------
      -- Step 180
      -- Add requirements array
      --------------------------------------------------------------------------
            IF boo_check
            THEN
               clb_output := clb_output || dz_json_util.pretty_str(
                   'required: '
                  ,p_pretty_print
                  ,'  '
               );
               
               FOR i IN 1 .. ary_items.COUNT
               LOOP
                  clb_output := clb_output || dz_json_util.pretty_str(
                      '- ' || dz_swagger3_util.yamlq(ary_items(i))
                     ,p_pretty_print + 1
                     ,'  '
                  );
                  
               END LOOP;
               
            END IF;
            
         END IF;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 190
      -- Cough it out with adjustments as needed
      --------------------------------------------------------------------------
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(10) || '$','');
         
      END IF;
               
      RETURN clb_output;
      
   END toYAML_schema;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML_combine(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      boo_is_not       BOOLEAN := FALSE;
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over object status
      --------------------------------------------------------------------------
      IF self.combine_schemas IS NULL
      OR self.combine_schemas.COUNT = 0
      THEN
         RAISE_APPLICATION_ERROR(-20001,'err');

      END IF;
      
      EXECUTE IMMEDIATE
         'SELECT '
      || ' a.schematyp.toYAML( '
      || '    p_pretty_print     => :p01 + 2 '
      || '   ,p_initial_indent   => ''FALSE'' '
      || '   ,p_final_linefeed   => ''FALSE'' '
      || '   ,p_force_inline     => :p02 '
      || '   ,p_short_id         => :p03 '
      || '   ,p_identifier       => a.object_id '
      || '   ,p_short_identifier => a.short_id '
      || '   ,p_reference_count  => a.reference_count '
      || ' ) '
      || ',b.object_key '
      || 'FROM '
      || 'dz_swagger3_xobjects a '
      || 'JOIN '
      || 'TABLE(:p04) b '
      || 'ON '
      || '    a.object_type_id = b.object_type_id '
      || 'AND a.object_id      = b.object_id '
      || 'ORDER BY b.object_order '
      BULK COLLECT INTO 
       ary_clb
      ,ary_keys
      USING
       p_pretty_print
      ,p_force_inline
      ,p_short_id
      ,self.combine_schemas;
         
      IF ary_keys.COUNT = 1 AND ary_keys(1) = 'not'
      THEN
         boo_is_not := TRUE;
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Do the type element
      --------------------------------------------------------------------------
      IF self.schema_type IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'type: ' || self.schema_type
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Do the not combine schema array
      --------------------------------------------------------------------------
      IF boo_is_not 
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'not: ' 
            ,p_pretty_print
            ,'  '
         ) || ary_clb(1);
      
      ELSE 
         clb_output := clb_output || dz_json_util.pretty_str(
             ary_keys(1) || ': '
            ,p_pretty_print
            ,'  '
         );
      
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '- ' || ary_clb(i)
               ,p_pretty_print + 1
               ,'  '
            );
            
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Cough it out with adjustments as needed
      --------------------------------------------------------------------------
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(10) || '$','');
         
      END IF;
               
      RETURN clb_output;
      
   END toYAML_combine;
   
END;
/
CREATE OR REPLACE TYPE BODY dz_swagger3_response_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_response_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_response_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_response_typ(
       p_response_id             IN  VARCHAR2
      ,p_response_code           IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
   BEGIN 
 
      --------------------------------------------------------------------------
      -- Step 10
      -- Set up the object
      --------------------------------------------------------------------------
      self.versionid := p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Pull the object information
      --------------------------------------------------------------------------
      SELECT
       a.response_id
      ,a.response_description
      INTO
       self.response_id
      ,self.response_description
      FROM
      dz_swagger3_response a
      WHERE
          a.versionid   = p_versionid
      AND a.response_id = p_response_id;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Collect the response headers
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id          => b.header_id
         ,p_object_type_id     => 'headertyp'
         ,p_object_key         => a.header_name
         ,p_object_order       => a.header_order
      )
      BULK COLLECT INTO self.response_headers
      FROM
      dz_swagger3_response_headr_map a
      JOIN
      dz_swagger3_header b
      ON
          a.versionid   = b.versionid
      AND a.header_id   = b.header_id
      WHERE
          a.versionid   = p_versionid
      AND a.response_id = p_response_id;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Collect the response media content
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id          => b.media_id
         ,p_object_type_id     => 'mediatyp'
         ,p_object_key         => a.media_type
         ,p_object_order       => a.media_order
      )
      BULK COLLECT INTO self.response_content
      FROM
      dz_swagger3_parent_media_map a
      JOIN
      dz_swagger3_media b
      ON
          a.versionid  = b.versionid
      AND a.media_id   = b.media_id
      WHERE
          a.versionid  = p_versionid
      AND a.parent_id  = p_response_id;

      --------------------------------------------------------------------------
      -- Step 50
      -- Collect the response links
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id          => b.link_id
         ,p_object_type_id     => 'linktyp'
         ,p_object_key         => a.link_name
         ,p_object_order       => a.link_order
      )
      BULK COLLECT INTO self.response_links
      FROM
      dz_swagger3_response_link_map a
      JOIN
      dz_swagger3_link b
      ON
          a.versionid   = b.versionid
      AND a.link_id     = b.link_id
      WHERE
          a.versionid   = p_versionid
      AND a.response_id = p_response_id;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Return the completed object
      --------------------------------------------------------------------------   
      RETURN; 
      
   END dz_swagger3_response_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Load the external docs
      --------------------------------------------------------------------------
      IF  self.response_headers IS NOT NULL
      AND self.response_headers.COUNT > 0
      THEN
         dz_swagger3_loader.headertyp(
             p_parent_id    => self.response_id
            ,p_children_ids => self.response_headers
            ,p_versionid    => self.versionid
         );
      
      END IF;

      --------------------------------------------------------------------------
      -- Step 20
      -- Load the properties schemas
      --------------------------------------------------------------------------
      IF  self.response_content IS NOT NULL
      AND self.response_content.COUNT > 0
      THEN
         dz_swagger3_loader.mediatyp(
             p_parent_id    => self.response_id
            ,p_children_ids => self.response_content
            ,p_versionid    => self.versionid
         );
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Load the combine schemas
      --------------------------------------------------------------------------
      IF  self.response_links IS NOT NULL
      AND self.response_links.COUNT > 0
      THEN
         dz_swagger3_loader.linktyp(
             p_parent_id    => self.response_id
            ,p_children_ids => self.response_links
            ,p_versionid    => self.versionid
         );
         
      END IF;

   END traverse;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      boo_temp         BOOLEAN;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_hash         CLOB;
      str_identifier   VARCHAR2(255 Char);
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;
      
      str_pad1 := str_pad;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Add  the ref object
      --------------------------------------------------------------------------
      IF  COALESCE(p_force_inline,'FALSE') = 'FALSE'
      AND p_reference_count > 1
      THEN
         IF p_short_id = 'TRUE'
         THEN
            str_identifier := p_short_identifier;
            
         ELSE
            str_identifier := p_identifier;
            
         END IF;
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.value2json(
                '$ref'
               ,'#/components/responses/' || dz_swagger3_util.utl_url_escape(
                  str_identifier
                )
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
      
      ELSE
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional description 
      --------------------------------------------------------------------------
         IF self.response_description IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.value2json(
                   'description'
                  ,self.response_description
                  ,p_pretty_print + 1
               )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional headers
      --------------------------------------------------------------------------
         IF  self.response_headers IS NOT NULL 
         AND self.response_headers.COUNT > 0
         THEN
            EXECUTE IMMEDIATE
               'SELECT '
            || ' a.headertyp.toJSON( '
            || '    p_pretty_print     => :p01 + 2 '
            || '   ,p_force_inline     => :p02 '
            || '   ,p_short_id         => :p03 '
            || '   ,p_identifier       => a.object_id '
            || '   ,p_short_identifier => a.short_id '
            || '   ,p_reference_count  => a.reference_count '
            || ' ) '
            || ',b.object_key '
            || 'FROM '
            || 'dz_swagger3_xobjects a '
            || 'JOIN '
            || 'TABLE(:p04) b '
            || 'ON '
            || '    a.object_type_id = b.object_type_id '
            || 'AND a.object_id      = b.object_id '
            || 'ORDER BY b.object_order '
            BULK COLLECT INTO 
             ary_clb
            ,ary_keys
            USING
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.response_headers; 
            
            str_pad2 := str_pad;
            
            IF p_pretty_print IS NULL
            THEN
               clb_hash := dz_json_util.pretty('{',NULL);
               
            ELSE
               clb_hash := dz_json_util.pretty('{',-1);
               
            END IF;
         
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_hash := clb_hash || dz_json_util.pretty(
                   str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                  ,p_pretty_print + 1
               );
               str_pad2 := ',';
            
            END LOOP;
            
            clb_hash := clb_hash || dz_json_util.pretty(
                '}'
               ,p_pretty_print + 1,NULL,NULL
            );
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                    'headers'
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;

      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional content objects
      --------------------------------------------------------------------------
         IF  self.response_content IS NOT NULL 
         AND self.response_content.COUNT > 0
         THEN
            EXECUTE IMMEDIATE
               'SELECT '
            || ' a.mediatyp.toJSON( '
            || '    p_pretty_print   => :p01 + 2 '
            || '   ,p_force_inline   => :p02 '
            || '   ,p_short_id       => :p03 '
            || ' ) '
            || ',b.object_key '
            || 'FROM '
            || 'dz_swagger3_xobjects a '
            || 'JOIN '
            || 'TABLE(:p04) b '
            || 'ON '
            || '    a.object_type_id = b.object_type_id '
            || 'AND a.object_id      = b.object_id '
            || 'ORDER BY b.object_order '
            BULK COLLECT INTO 
             ary_clb
            ,ary_keys
            USING
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.response_content; 

            str_pad2 := str_pad;
            
            IF p_pretty_print IS NULL
            THEN
               clb_hash := dz_json_util.pretty('{',NULL);
               
            ELSE
               clb_hash := dz_json_util.pretty('{',-1);
               
            END IF;
         
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_hash := clb_hash || dz_json_util.pretty(
                   str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                  ,p_pretty_print + 2
               );
               str_pad2 := ',';
            
            END LOOP;
            
            clb_hash := clb_hash || dz_json_util.pretty(
                '}'
               ,p_pretty_print + 1,NULL,NULL
            );
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                    'content'
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;

      --------------------------------------------------------------------------
      -- Step 60
      -- Add optional links map
      --------------------------------------------------------------------------
         IF  self.response_links IS NOT NULL 
         AND self.response_links.COUNT > 0
         THEN
            EXECUTE IMMEDIATE
               'SELECT '
            || ' a.linktyp.toJSON( '
            || '    p_pretty_print     => :p01 + 2 '
            || '   ,p_force_inline     => :p02 '
            || '   ,p_short_id         => :p03 '
            || '   ,p_identifier       => a.object_id '
            || '   ,p_short_identifier => a.short_id '
            || '   ,p_reference_count  => a.reference_count '
            || ' ) '
            || ',b.object_key '
            || 'FROM '
            || 'dz_swagger3_xobjects a '
            || 'JOIN '
            || 'TABLE(:p04) b '
            || 'ON '
            || '    a.object_type_id = b.object_type_id '
            || 'AND a.object_id      = b.object_id '
            || 'ORDER BY b.object_order '
            BULK COLLECT INTO 
             ary_clb
            ,ary_keys
            USING
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.response_links; 
            
            str_pad2 := str_pad;
            
            IF p_pretty_print IS NULL
            THEN
               clb_hash := dz_json_util.pretty('{',NULL);
               
            ELSE
               clb_hash := dz_json_util.pretty('{',-1);
               
            END IF;
         
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_hash := clb_hash || dz_json_util.pretty(
                   str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                  ,p_pretty_print + 1
               );
               str_pad2 := ',';
            
            END LOOP;
            
            clb_hash := clb_hash || dz_json_util.pretty(
                '}'
               ,p_pretty_print + 1,NULL,NULL
            );
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                    'links'
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      str_identifier   VARCHAR2(255 Char);
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      IF  COALESCE(p_force_inline,'FALSE') = 'FALSE'
      AND p_reference_count > 1
      THEN
         IF p_short_id = 'TRUE'
         THEN
            str_identifier := p_short_identifier;
            
         ELSE
            str_identifier := p_identifier;
            
         END IF;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             '$ref: ' || dz_swagger3_util.yaml_text(
                '#/components/responses/' || str_identifier
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      ELSE
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml description
      --------------------------------------------------------------------------
         IF self.response_description IS NOT NULL
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'description: ' || dz_swagger3_util.yaml_text(
                   self.response_description
                  ,p_pretty_print
               )
               ,p_pretty_print
               ,'  '
            );
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional header object list
      --------------------------------------------------------------------------
         IF  self.response_headers IS NOT NULL 
         AND self.response_headers.COUNT > 0
         THEN
            EXECUTE IMMEDIATE
               'SELECT '
            || ' a.headertyp.toYAML( '
            || '    p_pretty_print     => :p01 + 2 '
            || '   ,p_force_inline     => :p02 '
            || '   ,p_short_id         => :p03 '
            || '   ,p_identifier       => a.object_id '
            || '   ,p_short_identifier => a.short_id '
            || '   ,p_reference_count  => a.reference_count '
            || ' ) '
            || ',b.object_key '
            || 'FROM '
            || 'dz_swagger3_xobjects a '
            || 'JOIN '
            || 'TABLE(:p01) b '
            || 'ON '
            || '    a.object_type_id = b.object_type_id '
            || 'AND a.object_id      = b.object_id '
            || 'ORDER BY b.object_order '
            BULK COLLECT INTO 
             ary_clb
            ,ary_keys
            USING
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.response_headers; 

            clb_output := clb_output || dz_json_util.pretty_str(
                'headers: '
               ,p_pretty_print
               ,'  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   dz_swagger3_util.yamlq(ary_keys(i)) || ': '
                  ,p_pretty_print + 1
                  ,'  '
               ) || ary_clb(i);
            
            END LOOP;
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the optional content list
      --------------------------------------------------------------------------
         IF  self.response_content IS NOT NULL 
         AND self.response_content.COUNT > 0
         THEN
            EXECUTE IMMEDIATE
               'SELECT '
            || ' a.mediatyp.toYAML( '
            || '    p_pretty_print   => :p01 + 2 '
            || '   ,p_force_inline   => :p02 '
            || '   ,p_short_id       => :p03 '
            || ' ) '
            || ',b.object_key '
            || 'FROM '
            || 'dz_swagger3_xobjects a '
            || 'JOIN '
            || 'TABLE(:p01) b '
            || 'ON '
            || '    a.object_type_id = b.object_type_id '
            || 'AND a.object_id      = b.object_id '
            || 'ORDER BY b.object_order '
            BULK COLLECT INTO 
             ary_clb
            ,ary_keys
            USING
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.response_content; 

            clb_output := clb_output || dz_json_util.pretty_str(
                'content: '
               ,p_pretty_print
               ,'  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   dz_swagger3_util.yamlq(ary_keys(i)) || ': '
                  ,p_pretty_print + 1
                  ,'  '
               ) || ary_clb(i);
            
            END LOOP;
            
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the optional links list
      --------------------------------------------------------------------------
         IF  self.response_links IS NOT NULL 
         AND self.response_links.COUNT > 0
         THEN
            EXECUTE IMMEDIATE
               'SELECT '
            || ' a.linktyp.toYAML( '
            || '    p_pretty_print     => :p01 + 2 '
            || '   ,p_force_inline     => :p02 '
            || '   ,p_short_id         => :p03 '
            || '   ,p_identifier       => a.object_id '
            || '   ,p_short_identifier => a.short_id '
            || '   ,p_reference_count  => a.reference_count '
            || ' ) '
            || ',b.object_key '
            || 'FROM '
            || 'dz_swagger3_xobjects a '
            || 'JOIN '
            || 'TABLE(:p04) b '
            || 'ON '
            || '    a.object_type_id = b.object_type_id '
            || 'AND a.object_id      = b.object_id '
            || 'ORDER BY b.object_order '
            BULK COLLECT INTO 
             ary_clb
            ,ary_keys
            USING
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.response_links; 
            
            clb_output := clb_output || dz_json_util.pretty_str(
                'links: '
               ,p_pretty_print
               ,'  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   dz_swagger3_util.yamlq(ary_keys(i)) || ': '
                  ,p_pretty_print + 1
                  ,'  '
               ) || ary_clb(i);
            
            END LOOP;
            
         END IF;
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Cough it out 
      --------------------------------------------------------------------------
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(10) || '$','');
         
      END IF;
               
      RETURN clb_output;
      
   END toYAML;

END;
/

CREATE OR REPLACE TYPE BODY dz_swagger3_tag_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_tag_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_tag_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_tag_typ(
       p_tag_id             IN  VARCHAR2
      ,p_versionid          IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
   
   BEGIN
   
      self.versionid := p_versionid;
   
      SELECT
       a.tag_id
      ,a.tag_name
      ,a.tag_description
      ,CASE
       WHEN a.tag_externaldocs_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id => a.tag_externaldocs_id
            ,p_object_type_id => 'extrdocstyp'
         )
       ELSE
         NULL
       END
      INTO 
       self.tag_id
      ,self.tag_name
      ,self.tag_description
      ,self.tag_externalDocs
      FROM
      dz_swagger3_tag a
      WHERE
      a.versionid = p_versionid
      AND a.tag_id = p_tag_id;
      
      RETURN;
   
   END dz_swagger3_tag_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Load the external docs
      --------------------------------------------------------------------------
      IF self.tag_externalDocs IS NOT NULL
      THEN
         dz_swagger3_loader.extrdocstyp(
             p_parent_id    => self.tag_id
            ,p_children_ids => dz_swagger3_object_vry(self.tag_externalDocs)
            ,p_versionid    => self.versionid
         );
      
      END IF;

   END traverse;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_pad          VARCHAR2(1 Char);
      clb_tmp          CLOB;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add mandatory name
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          str_pad || dz_json_main.value2json(
             'name'
            ,self.tag_name
            ,p_pretty_print + 1
         )
         ,p_pretty_print + 1
      );
      str_pad := ',';
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional description
      --------------------------------------------------------------------------
      IF self.tag_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.value2json(
                'description'
               ,self.tag_description
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional externalDocs
      --------------------------------------------------------------------------
      IF self.tag_externalDocs IS NOT NULL
      THEN
         BEGIN
            EXECUTE IMMEDIATE
               'SELECT '
            || 'a.extrdocs.toJSON( '
            || '    p_pretty_print   => :p01 + 1 '
            || '   ,p_force_inline   => :p02 '
            || '   ,p_short_id       => :p03 '
            || ') '
            || 'FROM '
            || 'dz_swagger3_xobjects a '
            || 'WHERE '
            || '    a.object_type_id = :p04 '
            || 'AND a.object_id      = :p05 '
            INTO clb_tmp
            USING 
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.tag_externalDocs.object_type_id
            ,self.tag_externalDocs.object_id;
            
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_tmp := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad || dz_json_main.formatted2json(
                'externalDocs'
               ,clb_tmp
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad := ',';

      END IF;
 
      --------------------------------------------------------------------------
      -- Step 60
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output        CLOB;
      clb_tmp           CLOB;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Write the required name
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty_str(
          'name: ' || dz_swagger3_util.yaml_text(
             self.tag_name
            ,p_pretty_print
         )
         ,p_pretty_print
         ,'  '
      );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional description
      --------------------------------------------------------------------------
      IF self.tag_description IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'description: ' || dz_swagger3_util.yaml_text(
                self.tag_description
               ,p_pretty_print
            )
            ,p_pretty_print
            ,'  '
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the optional externalDocs object
      --------------------------------------------------------------------------
      IF self.tag_externalDocs IS NOT NULL
      THEN
         BEGIN
            EXECUTE IMMEDIATE
               'SELECT '
            || 'a.extrdocs.toYAML( '
            || '    p_pretty_print   => :p01 + 1 '
            || '   ,p_force_inline   => :p02 '
            || '   ,p_short_id       => :p03 '
            || ') '
            || 'FROM '
            || 'dz_swagger3_xobjects a '
            || 'WHERE '
            || '    a.object_type_id = :p04 '
            || 'AND a.object_id      = :p05 '
            INTO clb_tmp
            USING 
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.tag_externalDocs.object_type_id
            ,self.tag_externalDocs.object_id;
           
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_tmp := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'externalDocs: ' 
            ,p_pretty_print
            ,'  '
         ) || clb_tmp;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Cough it out without final line feed
      --------------------------------------------------------------------------
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(10) || '$','');
         
      END IF;
               
      RETURN clb_output;
      
   END toYAML;
   
END;
/

CREATE OR REPLACE TYPE BODY dz_swagger3_string_hash_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_string_hash_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_string_hash_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_string_hash_typ(
       p_hash_key           IN  VARCHAR2
      ,p_string_value       IN  VARCHAR2
      ,p_versionid          IN  VARCHAR2
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.hash_key          := p_hash_key;
      self.string_value      := p_string_value;
      self.versionid         := p_versionid;
      
      RETURN; 
      
   END dz_swagger3_string_hash_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN
      NULL;

   END traverse;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
   BEGIN
   
      RETURN dz_json_main.json_format(self.string_value);
           
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output CLOB;
      
   BEGIN
   
      clb_output :=  dz_swagger3_util.yaml_text(self.string_value);
      
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(10) || '$','');
         
      END IF;
               
      RETURN clb_output;
      
   END toYAML;

END;
/

CREATE OR REPLACE TYPE BODY dz_swagger3_typ
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_typ
   RETURN SELF AS RESULT
   AS
   BEGIN
      
      RETURN;

   END dz_swagger3_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_typ(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2 DEFAULT NULL
      ,p_versionid           IN  VARCHAR2 DEFAULT NULL
      ,p_shorten_logic       IN  VARCHAR2 DEFAULT NULL
   ) RETURN SELF AS RESULT
   AS
      str_doc_id          VARCHAR2(255 Char) := p_doc_id;
      str_group_id        VARCHAR2(255 Char) := p_group_id;
      str_versionid       VARCHAR2(40 Char)  := p_versionid;
      str_externaldocs_id VARCHAR2(255 Char);

   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      dz_swagger3_main.purge_xtemp();

      --------------------------------------------------------------------------
      -- Step 20     
      -- Determine the default version if not provided
      --------------------------------------------------------------------------
      dz_swagger3_main.startup_defaults(
          p_doc_id        => p_doc_id
         ,p_group_id      => p_group_id
         ,p_versionid     => p_versionid
         ,out_doc_id      => str_doc_id
         ,out_group_id    => str_group_id
         ,out_versionid   => str_versionid
      );

      --------------------------------------------------------------------------
      -- Step 30
      -- Load the info object and externalDocs object
      --------------------------------------------------------------------------
      SELECT
       dz_swagger3_info_typ(
          p_info_title          => a.info_title
         ,p_info_description    => a.info_description
         ,p_info_termsofservice => a.info_termsofservice
         ,p_info_contact        => dz_swagger3_info_contact_typ(
             p_contact_name  => a.info_contact_name
            ,p_contact_url   => a.info_contact_url
            ,p_contact_email => a.info_contact_email
          )
         ,p_info_license        => dz_swagger3_info_license_typ(
             p_license_name  => a.info_license_name
            ,p_license_url   => a.info_license_url
          )
         ,p_info_version        => a.info_version
       )
      ,CASE
       WHEN a.doc_externaldocs_id IS NOT NULL
       THEN
         dz_swagger3_object_typ(
             p_object_id      => a.doc_externaldocs_id
            ,p_object_type_id => 'extrdocstyp'
         )
       ELSE
         NULL
       END 
      INTO 
       self.info
      ,self.externalDocs
      FROM
      dz_swagger3_doc a
      WHERE
          a.versionid  = str_versionid
      AND a.doc_id     = str_doc_id;
      
      IF self.externalDocs IS NOT NULL
      THEN
         dz_swagger3_loader.extrdocstyp(
             p_parent_id    => 'root'
            ,p_children_ids => dz_swagger3_object_vry(self.externalDocs)
            ,p_versionid    => str_versionid
         );
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Load the servers
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id      => a.server_id
         ,p_object_type_id => 'servertyp'
         ,p_object_order   => a.server_order
      )
      BULK COLLECT INTO self.servers
      FROM
      dz_swagger3_parent_server_map a
      WHERE
          a.versionid = str_versionid
      AND a.parent_id = str_doc_id;
      
      IF self.servers.COUNT > 0
      THEN
         dz_swagger3_loader.servertyp(
             p_parent_id    => 'root'
            ,p_children_ids => self.servers
            ,p_versionid    => str_versionid
         );
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 50
      -- Load the paths account for MOA
      --------------------------------------------------------------------------
      IF str_group_id = 'MOA'
      THEN
         SELECT
         dz_swagger3_object_typ(
             p_object_id      => b.path_id
            ,p_object_type_id => 'pathtyp'
            ,p_object_key     => b.path_endpoint
            ,p_object_order   => a.path_order
         )
         BULK COLLECT INTO self.paths
         FROM (
            SELECT
             aa.path_id
            ,MAX(aa.path_order) AS path_order
            ,aa.versionid
            FROM
            dz_swagger3_group aa
            WHERE
            aa.versionid = str_versionid
            GROUP BY
             aa.path_id
            ,aa.versionid
         ) a
         JOIN
         dz_swagger3_path b
         ON
             a.versionid = b.versionid
         AND a.path_id   = b.path_id
         WHERE
         a.versionid = str_versionid;
         
      ELSE
         SELECT
         dz_swagger3_object_typ(
             p_object_id      => b.path_id
            ,p_object_type_id => 'pathtyp'
            ,p_object_key     => b.path_endpoint
            ,p_object_order   => a.path_order
         )
         BULK COLLECT INTO self.paths
         FROM
         dz_swagger3_group a
         JOIN
         dz_swagger3_path b
         ON
             a.versionid = b.versionid
         AND a.path_id   = b.path_id
         WHERE
             a.versionid = str_versionid
         AND a.group_id  = str_group_id;
         
      END IF;
      
      IF self.paths.COUNT > 0
      THEN
         dz_swagger3_loader.pathtyp(
             p_parent_id    => 'root'
            ,p_children_ids => self.paths
            ,p_versionid    => str_versionid
         );
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Load the security items
      --------------------------------------------------------------------------

      --------------------------------------------------------------------------
      -- Step 70
      -- Update the object list with reference count and shorty id
      --------------------------------------------------------------------------
      UPDATE dz_swagger3_xobjects a
      SET
       reference_count = (
         SELECT
         COUNT(*)
         FROM
         dz_swagger3_xrelates b
         WHERE
             b.child_object_id      = a.object_id
         AND b.child_object_type_id = a.object_type_id
       )
      ,short_id = 'x' || TO_CHAR(rownum);

      --------------------------------------------------------------------------
      -- Step 80
      -- Return the completed object
      --------------------------------------------------------------------------
      COMMIT;
      
      RETURN;

   END dz_swagger3_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_hash         CLOB;
      clb_tmp          CLOB;
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------

      --------------------------------------------------------------------------
      -- Step 20
      -- Add the left bracket
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);

      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';

      END IF;
      
      str_pad1 := str_pad;

      --------------------------------------------------------------------------
      -- Step 30
      -- Add base attributes
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.value2json(
             'openapi'
            ,dz_swagger3_constants.c_openapi_version
            ,p_pretty_print + 1
         )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';

      --------------------------------------------------------------------------
      -- Step 40
      -- Add info object
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          str_pad1 || dz_json_main.formatted2json(
              'info'
             ,self.info.toJSON(
                p_pretty_print   => p_pretty_print + 1
               ,p_force_inline   => p_force_inline
             )
             ,p_pretty_print + 1
          )
         ,p_pretty_print + 1
      );
      str_pad1 := ',';

      --------------------------------------------------------------------------
      -- Step 50
      -- Add servers
      --------------------------------------------------------------------------
      IF  self.servers IS NOT NULL 
      AND self.servers.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.servertyp.toJSON( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || '  ,p_short_id       => :p03 '
         || ' ) '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p04) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      = b.object_id '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO 
         ary_clb
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.servers;
         
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('[',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('[',-1);
            
         END IF;
      
         FOR i IN 1 .. ary_clb.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || ary_clb(i)
               ,p_pretty_print + 2
            );
            str_pad2 := ',';
         
         END LOOP;
         
         clb_hash := clb_hash || dz_json_util.pretty(
             ']'
            ,p_pretty_print + 1,NULL,NULL
         );
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                 'servers'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;
  
      --------------------------------------------------------------------------
      -- Step 60
      -- Add paths
      --------------------------------------------------------------------------
      IF  self.paths IS NOT NULL 
      AND self.paths.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.pathtyp.toJSON( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || '  ,p_short_id       => :p03 '
         || ' ) '
         || ',b.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p04) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      = b.object_id '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.paths;
         
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('{',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('{',-1);
            
         END IF;

         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
               ,p_pretty_print + 2
            );
            str_pad2 := ',';
         
         END LOOP;
         
         clb_hash := clb_hash || dz_json_util.pretty(
             '}'
            ,p_pretty_print + 1,NULL,NULL
         );
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                 'paths'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 70
      -- Add components subobject
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;

      ELSE
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'components'
               ,self.toJSON_components(
                   p_pretty_print   => p_pretty_print + 1
                  ,p_force_inline   => p_force_inline
                  ,p_short_id       => p_short_id
               )
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 80
      -- Add security
      --------------------------------------------------------------------------
      IF  self.security IS NOT NULL 
      AND self.security.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.securitytyp.toJSON( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || '  ,p_short_id       => :p03 '
         || ' ) '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p04) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      = b.object_id '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO 
         ary_clb
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.security;
         
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('[',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('[',-1);
            
         END IF;
      
         FOR i IN 1 .. ary_clb.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || ary_clb(i)
               ,p_pretty_print + 1
            );
            str_pad2 := ',';
         
         END LOOP;
         
         clb_hash := clb_hash || dz_json_util.pretty(
             ']'
            ,p_pretty_print + 1,NULL,NULL
         );
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                 'security'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 90
      -- Add tags
      --------------------------------------------------------------------------
      EXECUTE IMMEDIATE
         'SELECT '
      || ' a.tagtyp.toJSON( '
      || '   p_pretty_print   => :p01 + 2 '
      || '  ,p_force_inline   => :p02 '
      || '  ,p_short_id       => :p03 '
      || ' ) '
      || 'FROM '
      || 'dz_swagger3_xobjects a '
      || 'WHERE '
      || '    a.object_type_id = ''tagtyp'' '
      || 'AND ( '
      || '      a.tagtyp.tag_description IS NOT NULL '  
      || '   OR a.tagtyp.tag_externaldocs IS NOT NULL '
      || ') '
      || 'ORDER BY a.object_id '
      BULK COLLECT INTO 
      ary_clb
      USING
       p_pretty_print
      ,p_force_inline
      ,p_short_id;
      
      IF  ary_clb IS NOT NULL
      AND ary_clb.COUNT > 0
      THEN  
         str_pad2 := str_pad;
         
         IF p_pretty_print IS NULL
         THEN
            clb_hash := dz_json_util.pretty('[',NULL);
            
         ELSE
            clb_hash := dz_json_util.pretty('[',-1);
            
         END IF;
      
         FOR i IN 1 .. ary_clb.COUNT
         LOOP
            clb_hash := clb_hash || dz_json_util.pretty(
                str_pad2 || ary_clb(i)
               ,p_pretty_print + 1
            );
            str_pad2 := ',';
         
         END LOOP;
         
         clb_hash := clb_hash || dz_json_util.pretty(
             ']'
            ,p_pretty_print + 1,NULL,NULL
         );
         
         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                 'tags'
                ,clb_hash
                ,p_pretty_print + 1
             )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 100
      -- Add externalDocs
      --------------------------------------------------------------------------
      IF self.externalDocs IS NOT NULL
      THEN
         BEGIN
            EXECUTE IMMEDIATE
               'SELECT '
            || 'a.extrdocstyp.toJSON( '
            || '   p_pretty_print   => :p01 + 1 '
            || '  ,p_force_inline   => :p02 '
            || '  ,p_short_id       => :p03 '
            || ') FROM '
            || 'dz_swagger3_xobjects a '
            || 'WHERE '
            || '    a.object_type_id = :p04 '
            || 'AND a.object_id      = :p05 '
            INTO clb_tmp
            USING 
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.externalDocs.object_type_id
            ,self.externalDocs.object_id; 
         
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_tmp := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;

         clb_output := clb_output || dz_json_util.pretty(
             str_pad1 || dz_json_main.formatted2json(
                'externalDocs'
               ,clb_tmp
               ,p_pretty_print + 1
            )
            ,p_pretty_print + 1
         );
         str_pad1 := ',';

      END IF;

      --------------------------------------------------------------------------
      -- Step 110
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );

      --------------------------------------------------------------------------
      -- Step 120
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON_components(
       p_pretty_print        IN  INTEGER  DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      clb_hash         CLOB;
      str_pad          VARCHAR2(1 Char);
      str_pad1         VARCHAR2(1 Char);
      str_pad2         VARCHAR2(1 Char);
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------

      --------------------------------------------------------------------------
      -- Step 20
      -- Build the wrapper
      --------------------------------------------------------------------------
      IF p_pretty_print IS NULL
      THEN
         clb_output  := dz_json_util.pretty('{',NULL);
         
      ELSE
         clb_output  := dz_json_util.pretty('{',-1);
         str_pad     := ' ';
         
      END IF;
      
      str_pad1 := str_pad;

      --------------------------------------------------------------------------
      -- Step 30
      -- Add schemas map
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
      
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.schematyp.toJSON( '
         || '    p_pretty_print   => :p01 + 2 '
         || '   ,p_force_inline   => ''FALSE'' '
         || '   ,p_short_id       => :p02 '
         || ' ) '
         || ',CASE '
         || ' WHEN COALESCE(:p03,''FALSE'') = ''TRUE'' '
         || ' THEN '
         || '   a.short_id '
         || ' ELSE '
         || '   a.object_id '
         || ' END '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''schematyp'' '
         || 'AND a.reference_count > 1 '
         || 'AND COALESCE(a.schematyp.property_list_hidden,''FALSE'') <> ''TRUE'' '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_short_id
         ,p_short_id; 
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            str_pad2 := str_pad;
            
            IF p_pretty_print IS NULL
            THEN
               clb_hash := dz_json_util.pretty('{',NULL);
               
            ELSE
               clb_hash := dz_json_util.pretty('{',-1);
               
            END IF;
         
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_hash := clb_hash || dz_json_util.pretty(
                   str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                  ,p_pretty_print + 2
               );
               str_pad2 := ',';
            
            END LOOP;
            
            clb_hash := clb_hash || dz_json_util.pretty(
                '}'
               ,p_pretty_print + 1,NULL,NULL
            );
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                    'schemas'
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Add responses map
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
      
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.responsetyp.toJSON( '
         || '    p_pretty_print   => :p01 + 2 '
         || '   ,p_force_inline   => ''FALSE'' '
         || '   ,p_short_id       => :p02 '
         || ' ) '
         || ',CASE '
         || ' WHEN COALESCE(:p03,''FALSE'') = ''TRUE'' '
         || ' THEN '
         || '   a.short_id '
         || ' ELSE '
         || '   a.object_id '
         || ' END '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''responsetyp'' '
         || 'AND a.reference_count > 1 '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_short_id
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN          
            str_pad2 := str_pad;
            
            IF p_pretty_print IS NULL
            THEN
               clb_hash := dz_json_util.pretty('{',NULL);
               
            ELSE
               clb_hash := dz_json_util.pretty('{',-1);
               
            END IF;
         
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_hash := clb_hash || dz_json_util.pretty(
                   str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                  ,p_pretty_print + 2
               );
               str_pad2 := ',';
            
            END LOOP;
            
            clb_hash := clb_hash || dz_json_util.pretty(
                '}'
               ,p_pretty_print + 1,NULL,NULL
            );
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                    'responses'
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 50
      -- Add parameters map
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
      
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.parametertyp.toJSON( '
         || '    p_pretty_print     => :p01 + 2 '
         || '   ,p_force_inline     => ''FALSE'' '
         || '   ,p_short_id       => :p02 '
         || ' ) '
         || ',CASE '
         || ' WHEN COALESCE(:p03,''FALSE'') = ''TRUE'' '
         || ' THEN '
         || '   a.short_id '
         || ' ELSE '
         || '   a.object_id '
         || ' END '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''parametertyp'' '
         || 'AND a.reference_count > 1 '
         || 'AND COALESCE(a.parametertyp.parameter_list_hidden,''FALSE'') <> ''TRUE'' '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_short_id
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            str_pad2 := str_pad;
            
            IF p_pretty_print IS NULL
            THEN
               clb_hash := dz_json_util.pretty('{',NULL);
               
            ELSE
               clb_hash := dz_json_util.pretty('{',-1);
               
            END IF;
         
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_hash := clb_hash || dz_json_util.pretty(
                   str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                  ,p_pretty_print + 2
               );
               str_pad2 := ',';
            
            END LOOP;
            
            clb_hash := clb_hash || dz_json_util.pretty(
                '}'
               ,p_pretty_print + 1,NULL,NULL
            );
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                    'parameters'
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 60
      -- Add examples map
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
      
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.exampletyp.toJSON( '
         || '    p_pretty_print   => :p01 + 2 '
         || '   ,p_force_inline   => ''FALSE'' '
         || '   ,p_short_id       => :p02 '
         || ' ) '
         || ',CASE '
         || ' WHEN COALESCE(:p02,''FALSE'') = ''TRUE'' '
         || ' THEN '
         || '   a.short_id '
         || ' ELSE '
         || '   a.object_id '
         || ' END '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''exampletyp'' '
         || 'AND a.reference_count > 1 '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_short_id
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            str_pad2 := str_pad;
            
            IF p_pretty_print IS NULL
            THEN
               clb_hash := dz_json_util.pretty('{',NULL);
               
            ELSE
               clb_hash := dz_json_util.pretty('{',-1);
               
            END IF;

            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_hash := clb_hash || dz_json_util.pretty(
                   str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                  ,p_pretty_print + 2
               );
               str_pad2 := ',';
            
            END LOOP;
            
            clb_hash := clb_hash || dz_json_util.pretty(
                '}'
               ,p_pretty_print + 1,NULL,NULL
            );
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                    'examples'
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 70
      -- Add requestBodies map
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
      
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.requestbodytyp.toJSON( '
         || '    p_pretty_print   => :p01 + 2 '
         || '   ,p_force_inline   => ''FALSE'' '
         || '   ,p_short_id       => :p02 '
         || ' ) '
         || ',CASE '
         || ' WHEN COALESCE(:p02,''FALSE'') = ''TRUE'' '
         || ' THEN '
         || '   a.short_id '
         || ' ELSE '
         || '   a.object_id '
         || ' END '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''requestbodytyp'' '
         || 'AND a.reference_count > 1 '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_short_id
         ,p_short_id;

         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            str_pad2 := str_pad;
            
            IF p_pretty_print IS NULL
            THEN
               clb_hash := dz_json_util.pretty('{',NULL);
               
            ELSE
               clb_hash := dz_json_util.pretty('{',-1);
               
            END IF;

            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_hash := clb_hash || dz_json_util.pretty(
                   str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                  ,p_pretty_print + 2
               );
               str_pad2 := ',';
            
            END LOOP;
            
            clb_hash := clb_hash || dz_json_util.pretty(
                '}'
               ,p_pretty_print + 1,NULL,NULL
            );
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                    'requestBodies'
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 80
      -- Add headers map
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
      
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.headertyp.toJSON( '
         || '    p_pretty_print   => :p01 + 2 '
         || '   ,p_force_inline   => ''FALSE'' '
         || '   ,p_short_id       => :p02 '
         || ' ) '
         || ',CASE '
         || ' WHEN COALESCE(:p03,''FALSE'') = ''TRUE'' '
         || ' THEN '
         || '   a.short_id '
         || ' ELSE '
         || '   a.object_id '
         || ' END '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''headertyp'' '
         || 'AND a.reference_count > 1 '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_short_id
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            str_pad2 := str_pad;
            
            IF p_pretty_print IS NULL
            THEN
               clb_hash := dz_json_util.pretty('{',NULL);
               
            ELSE
               clb_hash := dz_json_util.pretty('{',-1);
               
            END IF;

            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_hash := clb_hash || dz_json_util.pretty(
                   str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                  ,p_pretty_print + 2
               );
               str_pad2 := ',';
            
            END LOOP;
            
            clb_hash := clb_hash || dz_json_util.pretty(
                '}'
               ,p_pretty_print + 1,NULL,NULL
            );
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                    'headers'
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 90
      -- Add security scheme map
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
      
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.securityschemetyp.toJSON( '
         || '    p_pretty_print   => :p01 + 2 '
         || '   ,p_force_inline   => ''FALSE'' '
         || '   ,p_short_id       => :p02 '
         || ' ) '
         || ',CASE '
         || ' WHEN COALESCE(:p03,''FALSE'') = ''TRUE'' '
         || ' THEN '
         || '   a.short_id '
         || ' ELSE '
         || '   a.object_id '
         || ' END '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''securityschemetyp'' '
         || 'AND a.reference_count > 1 '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_short_id
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            str_pad2 := str_pad;
            
            IF p_pretty_print IS NULL
            THEN
               clb_hash := dz_json_util.pretty('{',NULL);
               
            ELSE
               clb_hash := dz_json_util.pretty('{',-1);
               
            END IF;

            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_hash := clb_hash || dz_json_util.pretty(
                   str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                  ,p_pretty_print + 2
               );
               str_pad2 := ',';
            
            END LOOP;
            
            clb_hash := clb_hash || dz_json_util.pretty(
                '}'
               ,p_pretty_print + 1,NULL,NULL
            );
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                    'securitySchemes'
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 100
      -- Add links map
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
      
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.linktyp.toJSON( '
         || '    p_pretty_print   => :p01 + 2 '
         || '   ,p_force_inline   => ''FALSE'' '
         || '   ,p_short_id       => :p02 '
         || ' ) '
         || ',CASE '
         || ' WHEN COALESCE(:p03,''FALSE'') = ''TRUE'' '
         || ' THEN '
         || '   a.short_id '
         || ' ELSE '
         || '   a.object_id '
         || ' END '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''linktyp'' '
         || 'AND a.reference_count > 1 '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_short_id
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            str_pad2 := str_pad;
            
            IF p_pretty_print IS NULL
            THEN
               clb_hash := dz_json_util.pretty('{',NULL);
               
            ELSE
               clb_hash := dz_json_util.pretty('{',-1);
               
            END IF;

            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_hash := clb_hash || dz_json_util.pretty(
                   str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                  ,p_pretty_print + 2
               );
               str_pad2 := ',';
            
            END LOOP;
            
            clb_hash := clb_hash || dz_json_util.pretty(
                '}'
               ,p_pretty_print + 1,NULL,NULL
            );
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                    'links'
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 110
      -- Add callbacks map
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
      
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.pathtyp.toJSON( '
         || '    p_pretty_print   => :p01 + 2 '
         || '   ,p_force_inline   => ''FALSE'' '
         || '   ,p_short_id       => :p02 '
         || ' ) '
         || ',CASE '
         || ' WHEN COALESCE(:p03,''FALSE'') = ''TRUE'' '
         || ' THEN '
         || '   a.short_id '
         || ' ELSE '
         || '   a.object_id '
         || ' END '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''callbacktyp'' '
         || 'AND a.reference_count > 1 '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_short_id
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            str_pad2 := str_pad;
            
            IF p_pretty_print IS NULL
            THEN
               clb_hash := dz_json_util.pretty('{',NULL);
               
            ELSE
               clb_hash := dz_json_util.pretty('{',-1);
               
            END IF;

            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_hash := clb_hash || dz_json_util.pretty(
                   str_pad2 || '"' || ary_keys(i) || '":' || str_pad || ary_clb(i)
                  ,p_pretty_print + 2
               );
               str_pad2 := ',';
            
            END LOOP;
            
            clb_hash := clb_hash || dz_json_util.pretty(
                '}'
               ,p_pretty_print + 1,NULL,NULL
            );
            
            clb_output := clb_output || dz_json_util.pretty(
                str_pad1 || dz_json_main.formatted2json(
                    'callbacks'
                   ,clb_hash
                   ,p_pretty_print + 1
                )
               ,p_pretty_print + 1
            );
            str_pad1 := ',';
            
         END IF;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 120
      -- Add the left bracket
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty(
          '}'
         ,p_pretty_print,NULL,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 130
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON_components;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      clb_tmp          CLOB;
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------

      --------------------------------------------------------------------------
      -- Step 20
      -- Write the yaml
      --------------------------------------------------------------------------
      clb_output := dz_json_util.pretty_str(
          '---'
         ,p_pretty_print
         ,'  '
      ) || dz_json_util.pretty_str(
          'openapi: ' || dz_swagger3_util.yaml_text(
             dz_swagger3_constants.c_openapi_version
            ,p_pretty_print
          )
         ,p_pretty_print
         ,'  '
      );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the info object
      --------------------------------------------------------------------------
      IF self.info IS NOT NULL
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'info: '
            ,p_pretty_print
            ,'  '
         ) || self.info.toYAML(
             p_pretty_print   => p_pretty_print + 1
            ,p_force_inline   => p_force_inline
         );
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Write the server array
      --------------------------------------------------------------------------
      IF  self.servers IS NOT NULL 
      AND self.servers.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || 'a.servertyp.toYAML( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_initial_indent => ''FALSE'' '
         || '  ,p_final_linefeed => ''FALSE'' '
         || '  ,p_force_inline   => :p02 '
         || '  ,p_short_id       => :p03 '
         || ') '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p04) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      = b.object_id '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO 
         ary_clb
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.servers;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'servers: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. ary_clb.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '- ' || ary_clb(i)
               ,p_pretty_print + 1
               ,'  '
            );
            
         END LOOP;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 50
      -- Do the paths
      --------------------------------------------------------------------------
      clb_output := clb_output || dz_json_util.pretty_str(
          'paths: '
         ,p_pretty_print
         ,'  '
      );
      
      IF  self.paths IS NOT NULL 
      AND self.paths.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.pathtyp.toYAML( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || '  ,p_short_id       => :p03 '
         || ' ) '
         || ',b.object_key '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p04) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      = b.object_id '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.paths;
         
         FOR i IN 1 .. ary_keys.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty_str(
                dz_swagger3_util.yamlq(ary_keys(i)) || ': '
               ,p_pretty_print + 1
               ,'  '
            ) || ary_clb(i);

         END LOOP;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 60
      -- Write the components operation
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'components: {}' 
            ,p_pretty_print
            ,'  '
         );
         
      ELSE
         clb_output := clb_output || dz_json_util.pretty_str(
             'components: ' 
            ,p_pretty_print
            ,'  '
         ) || self.toYAML_components(
             p_pretty_print   => p_pretty_print + 1
            ,p_force_inline   => p_force_inline
            ,p_short_id       => p_short_id
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Write the security array
      --------------------------------------------------------------------------
      IF  self.security IS NOT NULL 
      AND self.security.COUNT > 0
      THEN
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.securitytyp.toYAML( '
         || '   p_pretty_print   => :p01 + 2 '
         || '  ,p_force_inline   => :p02 '
         || '  ,p_short_id       => :p03 '
         || ' ) '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'JOIN '
         || 'TABLE(:p04) b '
         || 'ON '
         || '    a.object_type_id = b.object_type_id '
         || 'AND a.object_id      = b.object_id '
         || 'ORDER BY b.object_order '
         BULK COLLECT INTO 
         ary_clb
         USING
          p_pretty_print
         ,p_force_inline
         ,p_short_id
         ,self.security;

         clb_output := clb_output || dz_json_util.pretty_str(
             'security: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. ary_clb.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '- '
               ,p_pretty_print + 1
               ,'  '
            ) || ary_clb(i);
            
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Write the tags array
      --------------------------------------------------------------------------
      EXECUTE IMMEDIATE
         'SELECT '
      || ' a.tagtyp.toJSON( '
      || '   p_pretty_print   => :p01 + 2 '
      || '  ,p_force_inline   => :p02 '
      || '  ,p_short_id       => :p03 '
      || ' ) '
      || 'FROM '
      || 'dz_swagger3_xobjects a '
      || 'WHERE '
      || '    a.object_type_id = ''tagtyp'' '
      || 'AND ( '
      || '      a.tagtyp.tag_description IS NOT NULL '  
      || '   OR a.tagtyp.tag_externaldocs IS NOT NULL '
      || ') '
      || 'ORDER BY a.object_id '
      BULK COLLECT INTO 
      ary_clb
      USING
       p_pretty_print
      ,p_force_inline
      ,p_short_id;
      
      IF  ary_clb IS NOT NULL
      AND ary_clb.COUNT > 0
      THEN
         clb_output := clb_output || dz_json_util.pretty_str(
             'tags: '
            ,p_pretty_print
            ,'  '
         );
         
         FOR i IN 1 .. ary_clb.COUNT
         LOOP
            clb_output := clb_output || dz_json_util.pretty(
                '- '
               ,p_pretty_print + 1
               ,'  '
            ) || ary_clb(i);
            
         END LOOP;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Write the externalDocs
      --------------------------------------------------------------------------
      IF self.externalDocs IS NOT NULL
      THEN
         BEGIN
            EXECUTE IMMEDIATE
               'SELECT '
            || 'a.extrdocstyp.toYAML( '
            || '   p_pretty_print   => :p01 + 1 '
            || '  ,p_force_inline   => :p02 '
            || '  ,p_short_id       => :p03 '
            || ') FROM '
            || 'dz_swagger3_xobjects a '
            || 'WHERE '
            || '    a.object_type_id = :p04 '
            || 'AND a.object_id      = :p05 '
            INTO clb_tmp
            USING 
             p_pretty_print
            ,p_force_inline
            ,p_short_id
            ,self.externalDocs.object_type_id
            ,self.externalDocs.object_id;
           
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_tmp := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;
         
         clb_output := clb_output || dz_json_util.pretty_str(
             'externalDocs: ' 
            ,p_pretty_print
            ,'  '
         ) || clb_tmp;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Cough it out
      --------------------------------------------------------------------------
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(10) || '$','');
         
      END IF;
               
      RETURN clb_output;

   END toYAML;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML_components(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      ary_keys         MDSYS.SDO_STRING2_ARRAY;
      
      TYPE clob_table IS TABLE OF CLOB;
      ary_clb          clob_table;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------

      --------------------------------------------------------------------------
      -- Step 20
      -- Write the component schemas
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;

      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.schematyp.toYAML( '
         || '    p_pretty_print   => :p01 + 2 '
         || '   ,p_force_inline   => ''FALSE'' '
         || '   ,p_short_id       => :p02 '
         || ' ) '
         || ',CASE '
         || ' WHEN COALESCE(:p03,''FALSE'') = ''TRUE'' '
         || ' THEN '
         || '   a.short_id '
         || ' ELSE '
         || '   a.object_id '
         || ' END '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''schematyp'' '
         || 'AND a.reference_count > 1 '
         || 'AND COALESCE(a.schematyp.property_list_hidden,''FALSE'') <> ''TRUE'' '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_short_id
         ,p_short_id;

         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN         
            clb_output := clb_output || dz_json_util.pretty_str(
                'schemas: '
               ,p_pretty_print
               ,'  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   dz_swagger3_util.yamlq(
                      ary_keys(i)
                   ) || ': '
                  ,p_pretty_print + 1
                  ,'  '
               ) || ary_clb(i);
            
            END LOOP;
         
         END IF;

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Write the component responses
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.responsetyp.toYAML( '
         || '    p_pretty_print   => :p01 + 2 '
         || '   ,p_force_inline   => ''FALSE'' '
         || '   ,p_short_id       => :p02 '
         || ' ) '
         || ',CASE '
         || ' WHEN COALESCE(:p02,''FALSE'') = ''TRUE'' '
         || ' THEN '
         || '   a.short_id '
         || ' ELSE '
         || '   a.object_id '
         || ' END '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''responsetyp'' '
         || 'AND a.reference_count > 1 '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_short_id
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN          
            clb_output := clb_output || dz_json_util.pretty_str(
                'responses: '
               ,p_pretty_print
               ,'  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   dz_swagger3_util.yamlq(
                     ary_keys(i)
                   ) || ': '
                  ,p_pretty_print + 1
                  ,'  '
               ) || ary_clb(i);
            
            END LOOP;
            
         END IF;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Write the component parameters
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.parametertyp.toYAML( '
         || '    p_pretty_print   => :p01 + 2 '
         || '   ,p_force_inline   => ''FALSE'' '
         || '   ,p_short_id       => :p02 '
         || ' ) '
         || ',CASE '
         || ' WHEN COALESCE(:p02,''FALSE'') = ''TRUE'' '
         || ' THEN '
         || '   a.short_id '
         || ' ELSE '
         || '   a.object_id '
         || ' END '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''parametertyp'' '
         || 'AND a.reference_count > 1 '
         || 'AND COALESCE(a.parametertyp.parameter_list_hidden,''FALSE'') <> ''TRUE'' '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_short_id
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'parameters: '
               ,p_pretty_print
               ,'  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   dz_swagger3_util.yamlq(
                     ary_keys(i)
                   ) || ': '
                  ,p_pretty_print + 1
                  ,'  '
               ) || ary_clb(i);
            
            END LOOP;
            
         END IF;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Write the component examples
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.exampletyp.toYAML( '
         || '    p_pretty_print   => :p01 + 2 '
         || '   ,p_force_inline   => ''FALSE'' '
         || '   ,p_short_id       => :p02 '
         || ' ) '
         || ',CASE '
         || ' WHEN COALESCE(:p02,''FALSE'') = ''TRUE'' '
         || ' THEN '
         || '   a.short_id '
         || ' ELSE '
         || '   a.object_id '
         || ' END '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''exampletyp'' '
         || 'AND a.reference_count > 1 '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_short_id
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'examples: '
               ,p_pretty_print
               ,'  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   dz_swagger3_util.yamlq(
                     ary_keys(i)
                   ) || ': '
                  ,p_pretty_print + 1
                  ,'  '
               ) || ary_clb(i);
            
            END LOOP;
            
         END IF;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Write the component requestBodies
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.requestbodytyp.toYAML( '
         || '    p_pretty_print   => :p01 + 2 '
         || '   ,p_force_inline   => ''FALSE'' '
         || '   ,p_short_id       => :p02 '
         || ' ) '
         || ',CASE '
         || ' WHEN COALESCE(:p02,''FALSE'') = ''TRUE'' '
         || ' THEN '
         || '   a.short_id '
         || ' ELSE '
         || '   a.object_id '
         || ' END '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''requestbodytyp'' '
         || 'AND a.reference_count > 1 '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_short_id
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'requestBodies: '
               ,p_pretty_print
               ,'  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   dz_swagger3_util.yamlq(
                     ary_keys(i)
                   ) || ': '
                  ,p_pretty_print + 1
                  ,'  '
               ) || ary_clb(i);
            
            END LOOP;
            
         END IF;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Write the component headers
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.headertyp.toYAML( '
         || '    p_pretty_print   => :p01 + 2 '
         || '   ,p_force_inline   => ''FALSE'' '
         || '   ,p_short_id       => :p02 '
         || ' ) '
         || ',CASE '
         || ' WHEN COALESCE(:p02,''FALSE'') = ''TRUE'' '
         || ' THEN '
         || '   a.short_id '
         || ' ELSE '
         || '   a.object_id '
         || ' END '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''headertyp'' '
         || 'AND a.reference_count > 1 '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_short_id
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'headers: '
               ,p_pretty_print
               ,'  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   dz_swagger3_util.yamlq(
                     ary_keys(i)
                   ) || ': '
                  ,p_pretty_print + 1
                  ,'  '
               ) || ary_clb(i);
            
            END LOOP;
            
         END IF;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Write the component securitySchemes
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.securityschemetyp.toYAML( '
         || '    p_pretty_print   => :p01 + 2 '
         || '   ,p_force_inline   => ''FALSE'' '
         || '   ,p_short_id       => :p02 '
         || ' ) '
         || ',CASE '
         || ' WHEN COALESCE(:p02,''FALSE'') = ''TRUE'' '
         || ' THEN '
         || '   a.short_id '
         || ' ELSE '
         || '   a.object_id '
         || ' END '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''securityschemetyp'' '
         || 'AND a.reference_count > 1 '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_short_id
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'securitySchemes: '
               ,p_pretty_print
               ,'  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   dz_swagger3_util.yamlq(
                     ary_keys(i)
                   ) || ': '
                  ,p_pretty_print + 1
                  ,'  '
               ) || ary_clb(i);
            
            END LOOP;
            
         END IF;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Write the component links
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.linktyp.toYAML( '
         || '    p_pretty_print   => :p01 + 2 '
         || '   ,p_force_inline   => ''FALSE'' '
         || '   ,p_short_id       => :p02 '
         || ' ) '
         || ',CASE '
         || ' WHEN COALESCE(:p02,''FALSE'') = ''TRUE'' '
         || ' THEN '
         || '   a.short_id '
         || ' ELSE '
         || '   a.object_id '
         || ' END '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''linktyp'' '
         || 'AND a.reference_count > 1 '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_short_id
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'links: '
               ,p_pretty_print
               ,'  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   dz_swagger3_util.yamlq(
                     ary_keys(i)
                   ) || ': '
                  ,p_pretty_print + 1
                  ,'  '
               ) || ary_clb(i);
            
            END LOOP;

         END IF;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Write the component callbacks
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      THEN
         NULL;
         
      ELSE
         EXECUTE IMMEDIATE
            'SELECT '
         || ' a.pathtyp.toYAML( '
         || '    p_pretty_print   => :p01 + 2 '
         || '   ,p_force_inline   => ''FALSE'' '
         || '   ,p_short_id       => :p02 '
         || ' ) '
         || ',CASE '
         || ' WHEN COALESCE(:p02,''FALSE'') = ''TRUE'' '
         || ' THEN '
         || '   a.short_id '
         || ' ELSE '
         || '   a.object_id '
         || ' END '
         || 'FROM '
         || 'dz_swagger3_xobjects a '
         || 'WHERE '
         || '    a.object_type_id = ''callbacktyp'' '
         || 'AND a.reference_count > 1 '
         || 'ORDER BY a.object_id '
         BULK COLLECT INTO 
          ary_clb
         ,ary_keys
         USING
          p_pretty_print
         ,p_short_id
         ,p_short_id;
         
         IF  ary_keys IS NOT NULL
         AND ary_keys.COUNT > 0
         THEN
            clb_output := clb_output || dz_json_util.pretty_str(
                'callbacks: '
               ,p_pretty_print
               ,'  '
            );
            
            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               clb_output := clb_output || dz_json_util.pretty(
                   dz_swagger3_util.yamlq(
                     ary_keys(i)
                   ) || ': '
                  ,p_pretty_print + 1
                  ,'  '
               ) || ary_clb(i);
            
            END LOOP;
            
         END IF;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 110
      -- Cough it out without final line feed
      --------------------------------------------------------------------------
      IF p_initial_indent = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'^\s+','');
       
      END IF;
      
      IF p_final_linefeed = 'FALSE'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(10) || '$','');
         
      END IF;
               
      RETURN clb_output;
      
   END toYAML_components;

END;
/

CREATE OR REPLACE TYPE dz_swagger3_jsonsch_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    schema_obj     dz_swagger3_schema_typ
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_jsonsch_typ 
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_jsonsch_typ(
       p_path_id              IN  VARCHAR2
      ,p_http_method          IN  VARCHAR2 DEFAULT 'get'
      ,p_response_code        IN  VARCHAR2 DEFAULT 'default'
      ,p_media_type           IN  VARCHAR2 DEFAULT 'application/json'
      ,p_title                IN  VARCHAR2 DEFAULT NULL
      ,p_versionid            IN  VARCHAR2 DEFAULT NULL
   ) RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print         IN  INTEGER  DEFAULT NULL
      ,p_short_id             IN  VARCHAR2 DEFAULT 'FALSE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_jsonsch_typ TO public;

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
         ,p_versionid    => str_versionid
      )
      INTO
      self.schema_obj
      FROM
      dz_swagger3_media a
      WHERE
         a.versionid = str_versionid
      AND a.media_id = str_media_id;
      
      self.schema_obj.traverse();
      
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
       p_pretty_print         IN  INTEGER  DEFAULT NULL
      ,p_short_id             IN  VARCHAR2 DEFAULT 'FALSE'
   ) RETURN CLOB
   AS 
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
      -- Return the schema for the endpoint media
      --------------------------------------------------------------------------
      RETURN self.schema_obj.toJSON(
          p_pretty_print   => p_pretty_print
         ,p_force_inline   => 'TRUE'
         ,p_short_id       => p_short_id
         ,p_jsonschema     => 'TRUE'
      );
           
   END toJSON;
   
END;
/

CREATE OR REPLACE PACKAGE dz_swagger3_test
AUTHID DEFINER
AS

   C_CHANGESET CONSTANT VARCHAR2(255 Char) := 'NULL';
   C_JENKINS_JOBNM CONSTANT VARCHAR2(255 Char) := 'NULL';
   C_JENKINS_BUILD CONSTANT NUMBER := 0.0;
   C_JENKINS_BLDID CONSTANT VARCHAR2(255 Char) := 'NULL';
   
   C_PREREQUISITES CONSTANT MDSYS.SDO_STRING2_ARRAY := MDSYS.SDO_STRING2_ARRAY(
      'DZ_JSON'
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION prerequisites
   RETURN NUMBER;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION version
   RETURN VARCHAR2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION inmemory_test
   RETURN NUMBER;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION scratch_test
   RETURN NUMBER;
      
END dz_swagger3_test;
/

GRANT EXECUTE ON dz_swagger3_test TO public;

CREATE OR REPLACE PACKAGE BODY dz_swagger3_test
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION prerequisites
   RETURN NUMBER
   AS
      num_check NUMBER;
      
   BEGIN
      
      FOR i IN 1 .. C_PREREQUISITES.COUNT
      LOOP
         SELECT 
         COUNT(*)
         INTO num_check
         FROM 
         user_objects a
         WHERE 
             a.object_name = C_PREREQUISITES(i) || '_TEST'
         AND a.object_type = 'PACKAGE';
         
         IF num_check <> 1
         THEN
            RETURN 1;
         
         END IF;
      
      END LOOP;
      
      RETURN 0;
   
   END prerequisites;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION version
   RETURN VARCHAR2
   AS
   BEGIN
      RETURN '{"CHANGESET":' || C_CHANGESET || ','
      || '"JOBN":"' || C_JENKINS_JOBNM || '",'   
      || '"BUILD":' || C_JENKINS_BUILD || ','
      || '"BUILDID":"' || C_JENKINS_BLDID || '"}';
      
   END version;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION inmemory_test
   RETURN NUMBER
   AS
   BEGIN
      RETURN 0;
      
   END inmemory_test;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION scratch_test
   RETURN NUMBER
   AS
   BEGIN
      RETURN 0;
      
   END scratch_test;

END dz_swagger3_test;
/


