WHENEVER SQLERROR EXIT -99;
WHENEVER OSERROR  EXIT -98;
SET DEFINE OFF;

--******************************--
PROMPT Collections/DZ_SWAGGER3_NUMBER_VRY.tps 

CREATE OR REPLACE TYPE dz_swagger3_number_vry FORCE                                       
AS 
VARRAY(2147483647) OF NUMBER;
/

GRANT EXECUTE ON dz_swagger3_number_vry TO public;

--******************************--
PROMPT Collections/DZ_SWAGGER3_STRING_VRY.tps 

CREATE OR REPLACE TYPE dz_swagger3_string_vry FORCE                                       
AS 
VARRAY(2147483647) OF VARCHAR2(4000 Char);
/

GRANT EXECUTE ON dz_swagger3_string_vry TO public;

--******************************--
PROMPT Collections/DZ_SWAGGER3_CLOB_VRY.tps 

CREATE OR REPLACE TYPE dz_swagger3_clob_vry FORCE                                       
AS 
VARRAY(2147483647) OF CLOB;
/

GRANT EXECUTE ON dz_swagger3_clob_vry TO public;

--******************************--
PROMPT Packages/DZ_SWAGGER3_CONSTANTS.pks 

CREATE OR REPLACE PACKAGE dz_swagger3_constants
AUTHID DEFINER
AS
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   /*
   Header: DZ_SWAGGER3
     
   - Release: v1.1.0
   - Commit Date: Mon May 3 08:41:58 2021 -0400
   
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
   c_openapi_version  CONSTANT VARCHAR2(16 Char) := '3.0.3';
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   /*
   Constant: dz_swagger3_constants.c_inject_path_xorder
   */
   c_inject_path_xorder CONSTANT BOOLEAN := TRUE;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   /*
   Constant: dz_swagger3_constants.c_inject_operation_xorder
   */
   c_inject_operation_xorder CONSTANT BOOLEAN := FALSE;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   /*
   Constant: dz_swagger3_constants.c_inject_property_xorder
   */
   c_inject_property_xorder CONSTANT BOOLEAN := FALSE;

END dz_swagger3_constants;
/

GRANT EXECUTE ON dz_swagger3_constants TO PUBLIC;

--******************************--
PROMPT Packages/DZ_SWAGGER3_UTIL.pks 

CREATE OR REPLACE PACKAGE dz_swagger3_util
AUTHID DEFINER
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION get_guid
   RETURN VARCHAR2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION safe_to_number(
       p_input            IN VARCHAR2
      ,p_null_replacement IN NUMBER DEFAULT NULL
   ) RETURN NUMBER;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION gz_split(
       p_str              IN  VARCHAR2
      ,p_regex            IN  VARCHAR2
      ,p_match            IN  VARCHAR2 DEFAULT NULL
      ,p_end              IN  NUMBER   DEFAULT 0
      ,p_trim             IN  VARCHAR2 DEFAULT 'FALSE'
   ) RETURN dz_swagger3_string_vry DETERMINISTIC;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE json2yaml(
       p_input            IN  CLOB
      ,p_output           IN OUT NOCOPY CLOB
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE json2yaml(
       p_input            IN  JSON_ELEMENT_T
      ,p_level            IN  NUMBER
      ,p_indent           IN  BOOLEAN
      ,p_output           IN OUT NOCOPY CLOB
   );
 
 END dz_swagger3_util;
/

GRANT EXECUTE ON dz_swagger3_util TO public;

--******************************--
PROMPT Packages/DZ_SWAGGER3_UTIL.pkb 

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
   FUNCTION safe_to_number(
       p_input            IN VARCHAR2
      ,p_null_replacement IN NUMBER DEFAULT NULL
   ) RETURN NUMBER
   AS
   BEGIN
      RETURN TO_NUMBER(
         REPLACE(
            REPLACE(
               p_input,
               CHR(10),
               ''
            ),
            CHR(13),
            ''
         ) 
      );
      
   EXCEPTION
      WHEN VALUE_ERROR
      THEN
         RETURN p_null_replacement;
         
   END safe_to_number;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION gz_split(
       p_str              IN  VARCHAR2
      ,p_regex            IN  VARCHAR2
      ,p_match            IN  VARCHAR2 DEFAULT NULL
      ,p_end              IN  NUMBER   DEFAULT 0
      ,p_trim             IN  VARCHAR2 DEFAULT 'FALSE'
   ) RETURN dz_swagger3_string_vry DETERMINISTIC 
   AS
      int_delim      PLS_INTEGER;
      int_position   PLS_INTEGER := 1;
      int_counter    PLS_INTEGER := 1;
      ary_output     dz_swagger3_string_vry;
      num_end        NUMBER      := p_end;
      str_trim       VARCHAR2(5 Char) := UPPER(p_trim);
      
      FUNCTION trim_varray(
         p_input            IN dz_swagger3_string_vry
      ) RETURN dz_swagger3_string_vry
      AS
         ary_output dz_swagger3_string_vry := dz_swagger3_string_vry();
         int_index  PLS_INTEGER := 1;
         str_check  VARCHAR2(4000 Char);
         
      BEGIN

         --------------------------------------------------------------------------
         -- Step 10
         -- Exit if input is empty
         --------------------------------------------------------------------------
         IF p_input IS NULL
         OR p_input.COUNT = 0
         THEN
            RETURN ary_output;
            
         END IF;

         --------------------------------------------------------------------------
         -- Step 20
         -- Trim the strings removing anything utterly trimmed away
         --------------------------------------------------------------------------
         FOR i IN 1 .. p_input.COUNT
         LOOP
            str_check := TRIM(p_input(i));
            
            IF str_check IS NULL
            OR str_check = ''
            THEN
               NULL;
               
            ELSE
               ary_output.EXTEND(1);
               ary_output(int_index) := str_check;
               int_index := int_index + 1;
               
            END IF;

         END LOOP;

         --------------------------------------------------------------------------
         -- Step 10
         -- Return the results
         --------------------------------------------------------------------------
         RETURN ary_output;

      END trim_varray;

   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Create the output array and check parameters
      --------------------------------------------------------------------------
      ary_output := dz_swagger3_string_vry();

      IF str_trim IS NULL
      THEN
         str_trim := 'FALSE';
         
      ELSIF str_trim NOT IN ('TRUE','FALSE')
      THEN
         RAISE_APPLICATION_ERROR(-20001,'boolean error');
         
      END IF;

      IF num_end IS NULL
      THEN
         num_end := 0;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 20
      -- Exit early if input is empty
      --------------------------------------------------------------------------
      IF p_str IS NULL
      OR p_str = ''
      THEN
         RETURN ary_output;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 30
      -- Account for weird instance of pure character breaking
      --------------------------------------------------------------------------
      IF p_regex IS NULL
      OR p_regex = ''
      THEN
         FOR i IN 1 .. LENGTH(p_str)
         LOOP
            ary_output.EXTEND(1);
            ary_output(i) := SUBSTR(p_str,i,1);
            
         END LOOP;
         
         RETURN ary_output;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Break string using the usual REGEXP functions
      --------------------------------------------------------------------------
      LOOP
         EXIT WHEN int_position = 0;
         int_delim  := REGEXP_INSTR(p_str,p_regex,int_position,1,0,p_match);
         
         IF  int_delim = 0
         THEN
            -- no more matches found
            ary_output.EXTEND(1);
            ary_output(int_counter) := SUBSTR(p_str,int_position);
            int_position  := 0;
            
         ELSE
            IF int_counter = num_end
            THEN
               -- take the rest as is
               ary_output.EXTEND(1);
               ary_output(int_counter) := SUBSTR(p_str,int_position);
               int_position  := 0;
               
            ELSE
               --dbms_output.put_line(ary_output.COUNT);
               ary_output.EXTEND(1);
               ary_output(int_counter) := SUBSTR(p_str,int_position,int_delim-int_position);
               int_counter := int_counter + 1;
               int_position := REGEXP_INSTR(p_str,p_regex,int_position,1,1,p_match);
               
            END IF;
            
         END IF;
         
      END LOOP;

      --------------------------------------------------------------------------
      -- Step 50
      -- Trim results if so desired
      --------------------------------------------------------------------------
      IF str_trim = 'TRUE'
      THEN
         RETURN trim_varray(
            p_input => ary_output
         );
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 60
      -- Cough out the results
      --------------------------------------------------------------------------
      RETURN ary_output;
      
   END gz_split;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION yaml_determine(
       p_input        IN  VARCHAR2
   ) RETURN VARCHAR2 DETERMINISTIC
   AS
   BEGIN
      
      -- When the string contains unicode, we just need to double-quote it
      IF INSTR(ASCIISTR(p_input),'\') > 0
      THEN
         RETURN 'double';
      
      -- If the string has newlines then try to multiline line it
      ELSIF INSTR(p_input,CHR(10)) > 0 
      OR INSTR(p_input,CHR(13)) > 0
      THEN
         RETURN 'multiline';
         
      -- Smells like JSON?
      ELSIF ( REGEXP_LIKE(p_input,'^\[') AND REGEXP_LIKE(p_input,'\"+') AND REGEXP_LIKE(p_input,'\]$') )
      OR    ( REGEXP_LIKE(p_input,'^\{') AND REGEXP_LIKE(p_input,'\"+') AND REGEXP_LIKE(p_input,'\}$') )
      THEN
         RETURN 'single';
      
      ELSIF REGEXP_LIKE(p_input,'\:|\?|\]|\[|\"|\''|\&|\%')
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
   
   END yaml_determine;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION yaml_key_quote(
       p_input        IN  VARCHAR2
   ) RETURN VARCHAR2 DETERMINISTIC
   AS
      str_format  VARCHAR2(4000 Char);
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10 
      -- Determine what format to use
      --------------------------------------------------------------------------
      str_format := yaml_determine(p_input);
      
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
   
   END yaml_key_quote;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION yaml_value_quote(
       p_input            IN  CLOB 
      ,p_level            IN  NUMBER   DEFAULT 0
   ) RETURN CLOB DETERMINISTIC
   AS
      lf           VARCHAR2(1 Char) := CHR(10);
      clb_output   CLOB             := p_input;
      str_format   VARCHAR2(4000 Char);
      ary_strings  dz_swagger3_string_vry;
      str_pad      VARCHAR2(32000 Char);
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10 
      -- Determine what format to use
      --------------------------------------------------------------------------
      str_format := yaml_determine(p_input);
      
      --------------------------------------------------------------------------
      -- Step 20 
      -- Process bare strings
      --------------------------------------------------------------------------
      IF str_format = 'bare'
      THEN
         RETURN clb_output;
         
      --------------------------------------------------------------------------
      -- Step 30 
      -- Process single quoted strings
      --------------------------------------------------------------------------
      ELSIF str_format = 'single'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,'''','''''');
         
         RETURN '''' || clb_output || '''';
         
      --------------------------------------------------------------------------
      -- Step 40 
      -- Process double quoted strings
      --------------------------------------------------------------------------
      ELSIF str_format = 'double'
      THEN
         clb_output := REGEXP_REPLACE(clb_output,CHR(13),'');
         
         clb_output := REGEXP_REPLACE(clb_output,'"','\"');
         
         RETURN '"' || clb_output || '"';
      
      --------------------------------------------------------------------------
      -- Step 50 
      -- Process bar indented strings
      --------------------------------------------------------------------------
      ELSIF str_format = 'multiline'
      THEN
         clb_output := REGEXP_REPLACE(
             clb_output
            ,CHR(10) || '$'
            ,''
         );
      
         clb_output := REGEXP_REPLACE(
             clb_output
            ,CHR(13)
            ,''
         );
         
         clb_output := REGEXP_REPLACE(
             clb_output
            ,CHR(10) || CHR(10)
            ,CHR(10) || ' ' || CHR(10)
         );
         
         ary_strings := dz_swagger3_util.gz_split(
             clb_output
            ,CHR(10)
         );
         
         clb_output := '|-' || lf;
         
         FOR i IN 1 .. p_level + 1
         LOOP
            str_pad := str_pad || '  ';
            
         END LOOP;
         
         FOR i IN 1 .. ary_strings.COUNT
         LOOP
            clb_output := clb_output || str_pad || ary_strings(i);
               
            IF i < ary_strings.COUNT
            THEN
               clb_output := clb_output || lf;

            END IF;
         
         END LOOP;
         
         RETURN clb_output;
         
      ELSE
         RAISE_APPLICATION_ERROR(-20001,'err');
      
      END IF;

      
   END yaml_value_quote;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE json2yaml(
       p_input            IN  CLOB
      ,p_output           IN OUT NOCOPY CLOB
   )
   AS
   BEGIN
      json2yaml(
          p_input            => JSON_ELEMENT_T.parse(p_input)
         ,p_level            => -1
         ,p_indent           => TRUE
         ,p_output           => p_output
      );
      
   END json2yaml;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE json2yaml(
       p_input            IN  JSON_ELEMENT_T
      ,p_level            IN  NUMBER
      ,p_indent           IN  BOOLEAN
      ,p_output           IN OUT NOCOPY CLOB
   )
   AS
      lf           VARCHAR2(1 Char) := CHR(10);
      json_obj     JSON_OBJECT_T;
      json_obj2    JSON_OBJECT_T;
      json_elem    JSON_ELEMENT_T;
      json_ary     JSON_ARRAY_T;
      json_keys    JSON_KEY_LIST;
      json_keys2   JSON_KEY_LIST;
      base_pad     VARCHAR2(32000 Char);
      int_size     PLS_INTEGER;
      
   BEGIN

      IF p_output IS NULL
      THEN
         p_output :=  '---' || lf;
   
      END IF;
      
      IF p_input.is_string()
      THEN
         p_output := p_output || yaml_value_quote(
             p_input  => p_input.to_clob()
            ,p_level  => p_level
         ) || lf;
      
      ELSIF p_input.is_number()
      THEN
         p_output := p_output || p_input.to_string() || lf;
         
      ELSIF p_input.is_boolean()
      THEN
         p_output := p_output || p_input.to_string() || lf;
      
      ELSE            
         IF p_input.is_object()
         THEN
            FOR i IN 1 .. p_level + 1
            LOOP
               base_pad := base_pad || '  ';
               
            END LOOP;
            
            json_obj  := JSON_OBJECT_T(p_input);
            json_keys := json_obj.GET_KEYS;
            
            IF json_keys IS NULL
            OR json_keys.COUNT = 0
            THEN
               p_output := p_output || '{}' || lf;
               
            ELSE               
               FOR i IN 1 .. json_keys.COUNT
               LOOP
                  json_elem := json_obj.get(json_keys(i));
                  
                  IF p_indent OR i > 1
                  THEN
                     p_output := p_output || base_pad;
                     
                  END IF;

                  p_output := p_output || yaml_key_quote(json_keys(i)) || ': ';

                  IF json_elem.is_object()
                  THEN 
                     json_obj2  := JSON_OBJECT_T(json_elem);
                     json_keys2 := json_obj2.GET_KEYS;
                     
                     IF  json_keys2 IS NOT NULL
                     AND json_keys.COUNT > 0
                     THEN
                        p_output := p_output || lf;
                        
                     END IF;
                     
                  ELSIF json_elem.is_array()  
                  AND json_elem.get_size() > 0
                  THEN
                     p_output := p_output || lf;
                     
                  END IF;
                  
                  json2yaml(
                      p_input       => json_elem
                     ,p_level       => p_level + 1
                     ,p_indent      => TRUE
                     ,p_output      => p_output 
                  );
                  
               END LOOP;
               
            END IF;
         
         ELSIF p_input.is_array()
         THEN
            FOR i IN 1 .. p_level
            LOOP
               base_pad := base_pad || '  ';
               
            END LOOP;
            
            json_ary  := JSON_ARRAY_T(p_input);
            int_size  := p_input.get_size();
            
            IF int_size = 0
            THEN
               p_output := p_output || '[]' || lf;
               
            ELSE
               FOR i IN 1 .. int_size
               LOOP
                  json_elem := json_ary.get(i-1);
                  
                  p_output := p_output || base_pad || '- ';           

                  json2yaml(
                      p_input       => json_elem
                     ,p_level       => p_level
                     ,p_indent      => FALSE
                     ,p_output      => p_output 
                  );
                  
               END LOOP;
               
            END IF;
         
         ELSE
            RAISE_APPLICATION_ERROR(-20001,'err');
         
         END IF;
      
      END IF;

   END;

END dz_swagger3_util;
/
--******************************--
PROMPT Packages/DZ_SWAGGER3_SETUP.pks 

CREATE OR REPLACE PACKAGE dz_swagger3_setup
AUTHID CURRENT_USER
AS
  
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE create_storage_tables(
       p_table_tablespace      VARCHAR2 DEFAULT dz_swagger3_constants.c_table_tablespace
      ,p_index_tablespace      VARCHAR2 DEFAULT dz_swagger3_constants.c_index_tablespace
      ,p_create_audit_triggers BOOLEAN  DEFAULT TRUE
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
   RETURN dz_swagger3_string_vry;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dz_swagger3_temp_table_list
   RETURN dz_swagger3_string_vry;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION is_valid
   RETURN dz_swagger3_string_vry PIPELINED;
 
 END dz_swagger3_setup;
/

--******************************--
PROMPT Packages/DZ_SWAGGER3_SETUP.pkb 

CREATE OR REPLACE PACKAGE BODY dz_swagger3_setup
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE create_storage_tables(
       p_table_tablespace      VARCHAR2 DEFAULT dz_swagger3_constants.c_table_tablespace
      ,p_index_tablespace      VARCHAR2 DEFAULT dz_swagger3_constants.c_index_tablespace
      ,p_create_audit_triggers BOOLEAN  DEFAULT TRUE
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
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || ') ';

      EXECUTE IMMEDIATE str_sql;

      IF p_create_audit_triggers
      THEN
         str_sql := 'CREATE OR REPLACE TRIGGER dz_swagger3_vers_trig '
                 || 'BEFORE UPDATE OR INSERT ON dz_swagger3_vers '
                 || 'FOR EACH ROW '
                 || 'BEGIN '
                 || '   :NEW.version_owner   := SYS_CONTEXT(''userenv'',''os_user'');'
                 || '   :NEW.version_created := TRUNC(SYSTIMESTAMP);'
                 || 'END;';

         EXECUTE IMMEDIATE str_sql;

      END IF;

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
              || '    CHECK (is_default IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_doc_c02 '
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_doc_c03 '
              || '    CHECK (REGEXP_LIKE(doc_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_doc_c04 '
              || '    CHECK (REGEXP_LIKE(doc_externalDocs_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || ') ';

      EXECUTE IMMEDIATE str_sql;

      IF p_create_audit_triggers
      THEN
         str_sql := 'CREATE OR REPLACE TRIGGER dz_swagger3_doc_trig '
                 || 'BEFORE UPDATE OR INSERT ON dz_swagger3_doc '
                 || 'FOR EACH ROW '
                 || 'BEGIN '
                 || '   :NEW.info_desc_author  := SYS_CONTEXT(''userenv'',''os_user'');'
                 || '   :NEW.info_desc_updated := TRUNC(SYSTIMESTAMP);'
                 || 'END;';

         EXECUTE IMMEDIATE str_sql;

      END IF;

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
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_group_c02 '
              || '    CHECK (REGEXP_LIKE(group_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_group_c03 '
              || '    CHECK (REGEXP_LIKE(doc_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_group_c04 '
              || '    CHECK (REGEXP_LIKE(path_id,''^[0-9a-zA-Z_\.-]+$'')) '
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
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parent_server_mc02 '
              || '    CHECK (REGEXP_LIKE(parent_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parent_server_mc03 '
              || '    CHECK (REGEXP_LIKE(server_id,''^[0-9a-zA-Z_\.-]+$'')) '
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
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_server_c02 '
              || '    CHECK (REGEXP_LIKE(server_id,''^[0-9a-zA-Z_\.-]+$'')) '
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
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_server_var_map_c02 '
              || '    CHECK (REGEXP_LIKE(server_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_server_var_map_c03 '
              || '    CHECK (REGEXP_LIKE(server_var_id,''^[0-9a-zA-Z_\.-]+$'')) '
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
              || '    CHECK (server_var_name = TRIM(server_var_name)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_server_variablec02 '
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_server_variablec03 '
              || '    CHECK (REGEXP_LIKE(server_var_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || ') ';

      EXECUTE IMMEDIATE str_sql;


      --------------------------------------------------------------------------
      -- Step 90
      -- Build PATH table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_path('
              || '    path_id                      VARCHAR2(255 Char) NOT NULL '
              || '   ,path_endpoint                VARCHAR2(255 Char) NOT NULL '
              || '   ,path_summary                 VARCHAR2(4000 Char) '
              || '   ,path_description             VARCHAR2(4000 Char) '
              || '   ,path_get_operation_id        VARCHAR2(255 Char) '
              || '   ,path_get_operation_order     INTEGER '
              || '   ,path_put_operation_id        VARCHAR2(255 Char) '
              || '   ,path_put_operation_order     INTEGER '
              || '   ,path_post_operation_id       VARCHAR2(255 Char) '
              || '   ,path_post_operation_order    INTEGER '
              || '   ,path_delete_operation_id     VARCHAR2(255 Char) '
              || '   ,path_delete_operation_order  INTEGER '
              || '   ,path_options_operation_id    VARCHAR2(255 Char) '
              || '   ,path_options_operation_order INTEGER '
              || '   ,path_head_operation_id       VARCHAR2(255 Char) '
              || '   ,path_head_operation_order    INTEGER '
              || '   ,path_patch_operation_id      VARCHAR2(255 Char) '
              || '   ,path_patch_operation_order   INTEGER '
              || '   ,path_trace_operation_id      VARCHAR2(255 Char) '
              || '   ,path_trace_operation_order   INTEGER '
              || '   ,path_desc_updated            DATE '
              || '   ,path_desc_author             VARCHAR2(30 Char) '
              || '   ,path_desc_notes              VARCHAR2(255 Char) '
              || '   ,versionid                    VARCHAR2(40 Char) NOT NULL '
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
              || '    CHECK (path_endpoint = TRIM(path_endpoint)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_path_c02 '
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_path_c03 '
              || '    CHECK (REGEXP_LIKE(path_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_path_c04 '
              || '    CHECK (REGEXP_LIKE(path_get_operation_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_path_c05 '
              || '    CHECK (REGEXP_LIKE(path_post_operation_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_path_c06 '
              || '    CHECK (REGEXP_LIKE(path_put_operation_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_path_c07 '
              || '    CHECK (REGEXP_LIKE(path_delete_operation_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_path_c08 '
              || '    CHECK (REGEXP_LIKE(path_options_operation_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_path_c09 '
              || '    CHECK (REGEXP_LIKE(path_head_operation_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_path_c10 '
              || '    CHECK (REGEXP_LIKE(path_patch_operation_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_path_c11 '
              || '    CHECK (REGEXP_LIKE(path_trace_operation_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || ') ';

      EXECUTE IMMEDIATE str_sql;

      IF p_create_audit_triggers
      THEN
         str_sql := 'CREATE OR REPLACE TRIGGER dz_swagger3_path_trig '
                 || 'BEFORE UPDATE OR INSERT ON dz_swagger3_path '
                 || 'FOR EACH ROW '
                 || 'BEGIN '
                 || '   :NEW.path_desc_author  := SYS_CONTEXT(''userenv'',''os_user'');'
                 || '   :NEW.path_desc_updated := TRUNC(SYSTIMESTAMP);'
                 || 'END;';

         EXECUTE IMMEDIATE str_sql;

      END IF;

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
              || '    CHECK (requestbody_flag IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parent_parm_mapc02 '
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parent_parm_mapc03 '
              || '    CHECK (REGEXP_LIKE(parent_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parent_parm_mapc04 '
              || '    CHECK (REGEXP_LIKE(parameter_id,''^[0-9a-zA-Z_\.-]+$'')) '
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
              || '    CHECK (parameter_name = TRIM(parameter_name)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parameter_c07 '
              || '    CHECK (parameter_force_inline IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parameter_c08 '
              || '    CHECK (parameter_list_hidden IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parameter_c09 '
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parameter_c10 '
              || '    CHECK (REGEXP_LIKE(parameter_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parameter_c11 '
              || '    CHECK (REGEXP_LIKE(parameter_schema_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || ') ';

      EXECUTE IMMEDIATE str_sql;

      IF p_create_audit_triggers
      THEN
         str_sql := 'CREATE OR REPLACE TRIGGER dz_swagger3_parameter_trig '
                 || 'BEFORE UPDATE OR INSERT ON dz_swagger3_parameter '
                 || 'FOR EACH ROW '
                 || 'BEGIN '
                 || '   :NEW.parameter_desc_author  := SYS_CONTEXT(''userenv'',''os_user'');'
                 || '   :NEW.parameter_desc_updated := TRUNC(SYSTIMESTAMP);'
                 || 'END;';

         EXECUTE IMMEDIATE str_sql;

      END IF;

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
              || '    CHECK (operation_type IN (''get'',''put'',''post'',''delete'',''options'',''head'',''patch'',''trace'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_c02 '
              || '    CHECK (operation_inline_rb IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_c03 '
              || '    CHECK (operation_deprecated IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_c04 '
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_c05 '
              || '    CHECK (REGEXP_LIKE(operation_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_c06 '
              || '    CHECK (REGEXP_LIKE(operation_externalDocs_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_c07 '
              || '    CHECK (REGEXP_LIKE(operation_requestBody_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_c08 '
              || '    CHECK (REGEXP_LIKE(operation_security_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || ') ';

      EXECUTE IMMEDIATE str_sql;

      IF p_create_audit_triggers
      THEN
         str_sql := 'CREATE OR REPLACE TRIGGER dz_swagger3_operation_trig '
                 || 'BEFORE UPDATE OR INSERT ON dz_swagger3_operation '
                 || 'FOR EACH ROW '
                 || 'BEGIN '
                 || '   :NEW.operation_desc_author  := SYS_CONTEXT(''userenv'',''os_user'');'
                 || '   :NEW.operation_desc_updated := TRUNC(SYSTIMESTAMP);'
                 || 'END;';

         EXECUTE IMMEDIATE str_sql;

      END IF;

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
              || '    CHECK (response_code = TRIM(response_code)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_resp_c02 '
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_resp_c03 '
              || '    CHECK (REGEXP_LIKE(operation_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_resp_c04 '
              || '    CHECK (REGEXP_LIKE(response_id,''^[0-9a-zA-Z_\.-]+$'')) '
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
              || '    CHECK (callback_name = TRIM(callback_name)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_call_c02 '
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_call_c03 '
              || '    CHECK (REGEXP_LIKE(operation_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_call_c04 '
              || '    CHECK (REGEXP_LIKE(callback_id,''^[0-9a-zA-Z_\.-]+$'')) '
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
              || '    CHECK (requestbody_required IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_requestbody_c02 '
              || '    CHECK (requestbody_force_inline IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_requestbody_c03 '
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_requestbody_c04 '
              || '    CHECK (REGEXP_LIKE(requestbody_id,''^[0-9a-zA-Z_\.-]+$'')) '
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
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_tag_mc02 '
              || '    CHECK (REGEXP_LIKE(operation_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_operation_tag_mc03 '
              || '    CHECK (REGEXP_LIKE(tag_id,''^[0-9a-zA-Z_\.-]+$'')) '
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
              || '    CHECK (response_force_inline IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_response_c02 '
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_response_c03 '
              || '    CHECK (REGEXP_LIKE(response_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || ') ';

      EXECUTE IMMEDIATE str_sql;

      IF p_create_audit_triggers
      THEN
         str_sql := 'CREATE OR REPLACE TRIGGER dz_swagger3_response_trig '
                 || 'BEFORE UPDATE OR INSERT ON dz_swagger3_response '
                 || 'FOR EACH ROW '
                 || 'BEGIN '
                 || '   :NEW.response_desc_author  := SYS_CONTEXT(''userenv'',''os_user'');'
                 || '   :NEW.response_desc_updated := TRUNC(SYSTIMESTAMP);'
                 || 'END;';

         EXECUTE IMMEDIATE str_sql;

      END IF;

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
              || '    CHECK (media_type = TRIM(media_type)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parent_media_mac02 '
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parent_media_mac03 '
              || '    CHECK (REGEXP_LIKE(parent_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parent_media_mac04 '
              || '    CHECK (REGEXP_LIKE(media_id,''^[0-9a-zA-Z_\.-]+$'')) '
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
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_media_c02 '
              || '    CHECK (REGEXP_LIKE(media_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_media_c03 '
              || '    CHECK (REGEXP_LIKE(media_schema_id,''^[0-9a-zA-Z_\.-]+$'')) '
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
              || '    CHECK (schema_category IN (''scalar'',''object'',''combine'',''array'')) '
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
              || '    CHECK (schema_externalDocs_id = TRIM(schema_externalDocs_id)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c06 '
              || '    CHECK (schema_deprecated IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c07 '
              || '    CHECK (schema_exclusiveMinimum IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c08 '
              || '    CHECK (schema_exclusiveMaximum IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c09 '
              || '    CHECK (schema_uniqueItems IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c10 '
              || '    CHECK (xml_attribute IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c11 '
              || '    CHECK (xml_wrapped IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c12 '
              || '    CHECK (schema_force_inline IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c13 '
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
              || '   ,CONSTRAINT dz_swagger3_schema_c14 '
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c15 '
              || '    CHECK (REGEXP_LIKE(schema_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c16 '
              || '    CHECK (REGEXP_LIKE(schema_externalDocs_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c17 '
              || '    CHECK (REGEXP_LIKE(schema_items_schema_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_c18 '
              || '    CHECK ( '
              || '          ( schema_type not in (''integer'',''number'',''string'') ) '
              || '       OR '
              || '          ( schema_example_string IS NULL AND schema_example_number IS NULL ) '
              || '       OR '
              || '          ( schema_type = ''integer'' AND schema_example_string IS NULL AND schema_example_number IS NOT NULL) '
              || '       OR '
              || '          ( schema_type = ''number''  AND schema_example_string IS NULL AND schema_example_number IS NOT NULL) '
              || '       OR '
              || '          ( schema_type = ''string''  AND schema_example_string IS NOT NULL AND schema_example_number IS NULL) '
              || '    ) '
              || '    ENABLE VALIDATE '
              || ') ';

      EXECUTE IMMEDIATE str_sql;

      IF p_create_audit_triggers
      THEN
         str_sql := 'CREATE OR REPLACE TRIGGER dz_swagger3_schema_trig '
                 || 'BEFORE UPDATE OR INSERT ON dz_swagger3_schema '
                 || 'FOR EACH ROW '
                 || 'BEGIN '
                 || '   :NEW.schema_desc_author  := SYS_CONTEXT(''userenv'',''os_user'');'
                 || '   :NEW.schema_desc_updated := TRUNC(SYSTIMESTAMP);'
                 || 'END;';

         EXECUTE IMMEDIATE str_sql;

      END IF;

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
              || '    CHECK (property_name = TRIM(property_name)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_prop_mapc02 '
              || '    CHECK (property_required IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_prop_mapc03 '
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_prop_mapc04 '
              || '    CHECK (REGEXP_LIKE(parent_schema_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_prop_mapc05 '
              || '    CHECK (REGEXP_LIKE(property_schema_id,''^[0-9a-zA-Z_\.-]+$'')) '
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
              || '    CHECK (enum_string = TRIM(enum_string)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_enum_mapc02 '
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_enum_mapc03 '
              || '    CHECK (REGEXP_LIKE(schema_id,''^[0-9a-zA-Z_\.-]+$'')) '
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
              || '    CHECK (combine_keyword = TRIM(combine_keyword)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_combine_c02 '
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_combine_c03 '
              || '    CHECK (REGEXP_LIKE(schema_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_schema_combine_c04 '
              || '    CHECK (REGEXP_LIKE(combine_schema_id,''^[0-9a-zA-Z_\.-]+$'')) '
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
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_example_c02 '
              || '    CHECK (REGEXP_LIKE(example_id,''^[0-9a-zA-Z_\.-]+$'')) '
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
              || '    CHECK (example_name = TRIM(example_name)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parent_example_c02 '
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parent_example_c03 '
              || '    CHECK (REGEXP_LIKE(parent_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parent_example_c04 '
              || '    CHECK (REGEXP_LIKE(example_id,''^[0-9a-zA-Z_\.-]+$'')) '
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
              || '    CHECK (encoding_explode IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_encoding_c02 '
              || '    CHECK (encoding_allowReserved IN (''TRUE'',''FALSE'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_encoding_c03 '
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_encoding_c04 '
              || '    CHECK (REGEXP_LIKE(encoding_id,''^[0-9a-zA-Z_\.-]+$'')) '
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
              || '    CHECK (encoding_name = TRIM(encoding_name)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_media_encoding_c02 '
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_media_encoding_c03 '
              || '    CHECK (REGEXP_LIKE(media_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_media_encoding_c04 '
              || '    CHECK (REGEXP_LIKE(encoding_id,''^[0-9a-zA-Z_\.-]+$'')) '
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
              || '   ,link_requestBody_exp   VARCHAR2(4000 Char) '
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
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_link_c02 '
              || '    CHECK (REGEXP_LIKE(link_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_link_c03 '
              || '    CHECK (REGEXP_LIKE(link_server_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || ') ';

      EXECUTE IMMEDIATE str_sql;

      --------------------------------------------------------------------------
      -- Step 290
      -- Build LINK OP PARMS table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_link_op_parms('
              || '    link_id                VARCHAR2(255 Char)  NOT NULL '
              || '   ,link_op_parm_name      VARCHAR2(255 Char)  NOT NULL '
              || '   ,link_op_parm_exp       VARCHAR2(4000 Char) NOT NULL '
              || '   ,link_op_parm_order     INTEGER             NOT NULL '
              || '   ,versionid              VARCHAR2(255 Char)  NOT NULL '
              || ') ';

      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;

      END IF;

      EXECUTE IMMEDIATE str_sql;

      str_sql := 'ALTER TABLE dz_swagger3_link_op_parms '
              || 'ADD CONSTRAINT dz_swagger3_link_op_parms_pk '
              || 'PRIMARY KEY(versionid,link_id,link_op_parm_name) ';

      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;

      END IF;

      EXECUTE IMMEDIATE str_sql;

      str_sql := 'ALTER TABLE dz_swagger3_link_op_parms '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_link_op_parms_c01 '
              || '    CHECK (link_op_parm_name = TRIM(link_op_parm_name)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_link_op_parms_c02 '
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_link_op_parms_c03 '
              || '    CHECK (REGEXP_LIKE(link_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || ') ';

      EXECUTE IMMEDIATE str_sql;

      --------------------------------------------------------------------------
      -- Step 300
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
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_header_c07 '
              || '    CHECK (REGEXP_LIKE(header_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_header_c08 '
              || '    CHECK (REGEXP_LIKE(header_schema_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || ') ';

      EXECUTE IMMEDIATE str_sql;

      IF p_create_audit_triggers
      THEN
         str_sql := 'CREATE OR REPLACE TRIGGER dz_swagger3_header_trig '
                 || 'BEFORE UPDATE OR INSERT ON dz_swagger3_header '
                 || 'FOR EACH ROW '
                 || 'BEGIN '
                 || '   :NEW.header_desc_author  := SYS_CONTEXT(''userenv'',''os_user'');'
                 || '   :NEW.header_desc_updated := TRUNC(SYSTIMESTAMP);'
                 || 'END;';

         EXECUTE IMMEDIATE str_sql;

      END IF;

      --------------------------------------------------------------------------
      -- Step 310
      -- Build PARENT HEADER MAP table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_parent_header_map('
              || '    parent_id                VARCHAR2(255 Char) NOT NULL '
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

      str_sql := 'ALTER TABLE dz_swagger3_parent_header_map '
              || 'ADD CONSTRAINT dz_swagger3_parent_header_mapk '
              || 'PRIMARY KEY(versionid,parent_id,header_id) ';

      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;

      END IF;

      EXECUTE IMMEDIATE str_sql;

      str_sql := 'ALTER TABLE dz_swagger3_parent_header_map '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_parent_header_mc01 '
              || '    CHECK (header_name = TRIM(header_name)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parent_header_mc02 '
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parent_header_mc03 '
              || '    CHECK (REGEXP_LIKE(parent_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parent_header_mc04 '
              || '    CHECK (REGEXP_LIKE(header_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || ') ';

      EXECUTE IMMEDIATE str_sql;

      --------------------------------------------------------------------------
      -- Step 320
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
              || '    CHECK (link_name = TRIM(link_name)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_response_link_mc02 '
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_response_link_mc03 '
              || '    CHECK (REGEXP_LIKE(response_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_response_link_mc04 '
              || '    CHECK (REGEXP_LIKE(link_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || ') ';

      EXECUTE IMMEDIATE str_sql;

      --------------------------------------------------------------------------
      -- Step 330
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
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_externaldoc_c02 '
              || '    CHECK (REGEXP_LIKE(externaldoc_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || ') ';

      EXECUTE IMMEDIATE str_sql;

      --------------------------------------------------------------------------
      -- Step 340
      -- Build SECURITY SCHEME table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_parent_secSchm_map('
              || '    parent_id                   VARCHAR2(255 Char) NOT NULL '
              || '   ,securityScheme_id           VARCHAR2(255 Char) NOT NULL '
              || '   ,securityScheme_name         VARCHAR2(255 Char) NOT NULL '
              || '   ,oauth_flow_scopes           VARCHAR2(4000 Char) '
              || '   ,securityScheme_order        INTEGER            NOT NULL '
              || '   ,versionid                   VARCHAR2(40 Char)  NOT NULL '
              || ') ';

      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;

      END IF;

      EXECUTE IMMEDIATE str_sql;

      str_sql := 'ALTER TABLE    dz_swagger3_parent_secSchm_map '
              || 'ADD CONSTRAINT dz_swagger3_parent_secSchm_mpk '
              || 'PRIMARY KEY(versionid,parent_id,securityScheme_id) ';

      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;

      END IF;

      EXECUTE IMMEDIATE str_sql;

      str_sql := 'ALTER TABLE dz_swagger3_parent_secSchm_map '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_parent_secSchm_c01 '
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parent_secSchm_c02 '
              || '    CHECK (REGEXP_LIKE(parent_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_parent_secSchm_c03 '
              || '    CHECK (REGEXP_LIKE(securityScheme_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || ') ';

      EXECUTE IMMEDIATE str_sql;

      --------------------------------------------------------------------------
      -- Step 350
      -- Build SECURITY SCHEME table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_securityScheme('
              || '    securityScheme_id              VARCHAR2(255 Char) NOT NULL '
              || '   ,securityScheme_type            VARCHAR2(255 Char) NOT NULL '
              || '   ,securityScheme_description     VARCHAR2(4000 Char) '
              || '   ,securityScheme_name            VARCHAR2(255 Char) '
              || '   ,securityScheme_in              VARCHAR2(255 Char) '
              || '   ,securityScheme_scheme          VARCHAR2(255 Char) '
              || '   ,securityScheme_bearerFormat    VARCHAR2(255 Char) '
              || '   ,oauth_flow_implicit            VARCHAR2(255 Char) '
              || '   ,oauth_flow_password            VARCHAR2(255 Char) '
              || '   ,oauth_flow_clientcredentials   VARCHAR2(255 Char) '
              || '   ,oauth_flow_authorizationcode   VARCHAR2(255 Char) '
              || '   ,securityscheme_openidcredents  VARCHAR2(255 Char) '
              || '   ,versionid                      VARCHAR2(40 Char)  NOT NULL '
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
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_securityScheme_c02 '
              || '    CHECK (REGEXP_LIKE(securityScheme_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || ') ';

      EXECUTE IMMEDIATE str_sql;

      --------------------------------------------------------------------------
      -- Step 360
      -- Build OAUTH FLOW table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_oauth_flow('
              || '    oauth_flow_id               VARCHAR2(255 Char) NOT NULL '
              || '   ,oauth_flow_authorizationurl VARCHAR2(255 Char) '
              || '   ,oauth_flow_tokenurl         VARCHAR2(255 Char) '
              || '   ,oauth_flow_refreshurl       VARCHAR2(255 Char) '
              || '   ,versionid                   VARCHAR2(255 Char) NOT NULL '
              || ') ';

      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;

      END IF;

      EXECUTE IMMEDIATE str_sql;

      str_sql := 'ALTER TABLE dz_swagger3_oauth_flow '
              || 'ADD CONSTRAINT dz_swagger3_oauth_flow_pk '
              || 'PRIMARY KEY(versionid,oauth_flow_id) ';

      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;

      END IF;

      EXECUTE IMMEDIATE str_sql;

      str_sql := 'ALTER TABLE dz_swagger3_oauth_flow '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_oauth_flow_c01 '
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_oauth_flow_c02 '
              || '    CHECK (REGEXP_LIKE(oauth_flow_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || ') ';

      EXECUTE IMMEDIATE str_sql;

      --------------------------------------------------------------------------
      -- Step 370
      -- Build OAUTH FLOW SCOPE table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_oauth_flow_scope('
              || '    oauth_flow_id          VARCHAR2(255 Char) NOT NULL '
              || '   ,oauth_flow_scope_name  VARCHAR2(255 Char) NOT NULL '
              || '   ,oauth_flow_scope_desc  VARCHAR2(255 Char) NOT NULL '
              || '   ,versionid              VARCHAR2(40 Char)  NOT NULL '
              || ') ';

      IF p_table_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'TABLESPACE ' || p_table_tablespace;

      END IF;

      EXECUTE IMMEDIATE str_sql;

      str_sql := 'ALTER TABLE dz_swagger3_oauth_flow_scope '
              || 'ADD CONSTRAINT dz_swagger3_oauth_flow_scopepk '
              || 'PRIMARY KEY(versionid,oauth_flow_id,oauth_flow_scope_name) ';

      IF p_index_tablespace IS NOT NULL
      THEN
         str_sql := str_sql || 'USING INDEX TABLESPACE ' || p_index_tablespace;

      END IF;

      EXECUTE IMMEDIATE str_sql;

      str_sql := 'ALTER TABLE dz_swagger3_oauth_flow_scope '
              || 'ADD( '
              || '    CONSTRAINT dz_swagger3_oauth_flow_scopc01 '
              || '    CHECK (oauth_flow_scope_name = TRIM(oauth_flow_scope_name)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_oauth_flow_scopc02 '
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
               || '   ,CONSTRAINT dz_swagger3_oauth_flow_scopc03 '
              || '    CHECK (REGEXP_LIKE(oauth_flow_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || ') ';

      EXECUTE IMMEDIATE str_sql;

      --------------------------------------------------------------------------
      -- Step 380
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
              || '    CHECK (tag_name = TRIM(tag_name)) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_tag_c02 '
              || '    CHECK (REGEXP_LIKE(versionid,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_tag_c03 '
              || '    CHECK (REGEXP_LIKE(tag_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || '   ,CONSTRAINT dz_swagger3_tag_c04 '
              || '    CHECK (REGEXP_LIKE(tag_externalDocs_id,''^[0-9a-zA-Z_\.-]+$'')) '
              || '    ENABLE VALIDATE '
              || ') ';

      EXECUTE IMMEDIATE str_sql;

      --------------------------------------------------------------------------
      -- Step 390
      -- Build CACHE table
      --------------------------------------------------------------------------
      str_sql := 'CREATE TABLE dz_swagger3_cache('
              || '    doc_id               VARCHAR2(255 Char) NOT NULL '
              || '   ,group_id             VARCHAR2(255 Char) NOT NULL '
              || '   ,json_payload         CLOB '
              || '   ,yaml_payload         CLOB '
              || '   ,extraction_timestamp TIMESTAMP '
              || '   ,short_id             VARCHAR2(255 Char) '
              || '   ,force_escapes        VARCHAR2(255 Char) '
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
              || '   ,encodingtyp          dz_swagger3_encoding_typ '
              || '   ,exampletyp           dz_swagger3_example_typ '
              || '   ,extrdocstyp          dz_swagger3_extrdocs_typ '
              || '   ,headertyp            dz_swagger3_header_typ '
              || '   ,linktyp              dz_swagger3_link_typ '
              || '   ,mediatyp             dz_swagger3_media_typ '
              || '   ,operationtyp         dz_swagger3_operation_typ '
              || '   ,parametertyp         dz_swagger3_parameter_typ '
              || '   ,pathtyp              dz_swagger3_path_typ '
              || '   ,requestbodytyp       dz_swagger3_requestBody_typ '
              || '   ,responsetyp          dz_swagger3_response_typ '
              || '   ,schematyp            dz_swagger3_schema_typ '
              || '   ,securityschemetyp    dz_swagger3_securityscheme_typ '
              || '   ,servertyp            dz_swagger3_server_typ '
              || '   ,servervartyp         dz_swagger3_server_var_typ '
              || '   ,tagtyp               dz_swagger3_tag_typ '
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
   RETURN dz_swagger3_string_vry
   AS

   BEGIN

      RETURN dz_swagger3_string_vry(
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
         ,'DZ_SWAGGER3_OAUTH_FLOW'
         ,'DZ_SWAGGER3_OAUTH_FLOW_SCOPE'
         ,'DZ_SWAGGER3_OPERATION'
         ,'DZ_SWAGGER3_OPERATION_CALL_MAP'
         ,'DZ_SWAGGER3_OPERATION_RESP_MAP'
         ,'DZ_SWAGGER3_OPERATION_TAG_MAP'
         ,'DZ_SWAGGER3_PARAMETER'
         ,'DZ_SWAGGER3_PARENT_EXAMPLE_MAP'
         ,'DZ_SWAGGER3_PARENT_MEDIA_MAP'
         ,'DZ_SWAGGER3_PARENT_PARM_MAP'
         ,'DZ_SWAGGER3_PARENT_SECSCHM_MAP'
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
   RETURN dz_swagger3_string_vry
   AS

   BEGIN

      RETURN dz_swagger3_string_vry(
          'DZ_SWAGGER3_XRELATES'
         ,'DZ_SWAGGER3_XOBJECTS'
      );

   END dz_swagger3_temp_table_list;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION is_valid
   RETURN dz_swagger3_string_vry PIPELINED
   AS
      str_sql     VARCHAR2(32000 Char);
      ary_results dz_swagger3_string_vry;

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

--******************************--
PROMPT Packages/DZ_SWAGGER3_VALIDATE.pks 

CREATE OR REPLACE PACKAGE dz_swagger3_validate
AUTHID DEFINER
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   /*
   Constant: c_default_validators
   */
   c_default_validators CONSTANT VARCHAR2(4000 Char) := '["plsql"]';

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION request_validate(
       p_doc     IN  CLOB
      ,p_options IN  VARCHAR2
   ) RETURN CLOB;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION plsql_validate(
      p_doc    IN  CLOB
   ) RETURN CLOB;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION swagger_badge_validate(
      p_doc    IN  CLOB
   ) RETURN CLOB;
      
END dz_swagger3_validate;
/

GRANT EXECUTE ON dz_swagger3_validate TO public;

--******************************--
PROMPT Packages/DZ_SWAGGER3_VALIDATE.pkb 

CREATE OR REPLACE PACKAGE BODY dz_swagger3_validate
AS

   -----------------------------------------------------------------------------
   -- One partical solution to hard-coding your wallet password here would be 
   -- to encrypt the package body source via DBMS_DDL.CREATE_WRAPPED
   -----------------------------------------------------------------------------
   c_swagger_badge_url         CONSTANT VARCHAR2(4000 Char) := NULL;
   c_swagger_badge_wallet_path CONSTANT VARCHAR2(4000 Char) := NULL;
   c_swagger_badge_wallet_pwd  CONSTANT VARCHAR2(4000 Char) := NULL;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION request_validate(
       p_doc     IN  CLOB
      ,p_options IN  VARCHAR2
   ) RETURN CLOB
   AS
      str_options    VARCHAR2(32767 Char) := p_options;
      json_input     JSON_OBJECT_T;
      json_keys      JSON_KEY_LIST;
      json_element   JSON_ELEMENT_T;
      json_tests     JSON_ARRAY_T;
      json_index     NUMBER;
      json_ary_val   VARCHAR2(4000 Char);
      json_plsql_tst JSON_OBJECT_T;
      boo_plsql_tst  BOOLEAN;
      json_badge_tst JSON_OBJECT_T;
      boo_badge_tst  BOOLEAN;
      boo_overall    BOOLEAN;
      json_results   JSON_ARRAY_T;
      json_output    JSON_OBJECT_T;

   BEGIN
   
      json_output := JSON_OBJECT_T();

      IF str_options IS NULL
      THEN
         str_options := c_default_validators;

      END IF;

      json_input := JSON_OBJECT_T.PARSE(str_options);
      json_keys  := json_input.GET_KEYS;

      IF json_input.has('tests')
      THEN
         json_element := json_input.get('tests');

      ELSE
         json_output.put('valid',CAST(NULL AS BOOLEAN));
         RETURN json_output.to_clob();

      END IF;

      IF json_element.is_array()
      THEN
         json_tests := JSON_ARRAY_T(json_element);
         json_index := json_element.get_size();

      ELSE
         json_output.put('valid',CAST(NULL AS BOOLEAN));
         RETURN json_output.to_clob();

      END IF;

      json_results := JSON_ARRAY_T();

      FOR i IN 0 .. json_index
      LOOP
         json_ary_val := json_tests.get_string(i);

         IF json_ary_val = 'plsql'
         THEN
            json_plsql_tst := JSON_OBJECT_T.parse(plsql_validate(p_doc));
            boo_plsql_tst  := json_plsql_tst.get_boolean('valid');

            json_results.append(json_plsql_tst);

         ELSIF json_ary_val = 'swagger_badge'
         THEN
            json_badge_tst := JSON_OBJECT_T.parse(swagger_badge_validate(p_doc));
            boo_badge_tst  := json_badge_tst.get_boolean('valid');

            json_results.append(json_badge_tst);

         END IF;

      END LOOP;

      IF  boo_badge_tst IS NULL
      AND boo_plsql_tst IS NULL
      THEN
         boo_overall := NULL;

      ELSIF boo_badge_tst IS NULL
      THEN
         boo_overall := boo_plsql_tst;

      ELSIF boo_plsql_tst IS NULL
      THEN
         boo_overall := boo_badge_tst;

      ELSE
         IF  boo_badge_tst
         AND boo_plsql_tst
         THEN
            boo_overall := TRUE;

         ELSE
            boo_overall := FALSE;

         END IF;

      END IF;

      json_output.put('valid',boo_overall);
      json_output.put('tests',json_element);
      json_output.put('results',json_results);
      RETURN json_output.to_clob();

   END request_validate;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION plsql_validate(
      p_doc    IN  CLOB
   ) RETURN CLOB
   AS
      json_output    JSON_OBJECT_T;
      
   BEGIN
   
      json_output := JSON_OBJECT_T();
      json_output.put('test','plsql');
      json_output.put('version',1.0);
      json_output.put('valid',TRUE);
   
      RETURN json_output.to_clob();     
   
   END plsql_validate;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION swagger_badge_validate(
      p_doc    IN  CLOB
   ) RETURN CLOB
   AS
      rcx UTL_HTTP.REQUEST_CONTEXT_KEY;
      req UTL_HTTP.REQ;
      res UTL_HTTP.RESP;
      buf VARCHAR2(32767 Char);
      clb CLOB;
      cln NUMBER;
      cst NUMBER;

      json_output    JSON_OBJECT_T;
      json_results   JSON_OBJECT_T;
      boo_isvalid    BOOLEAN;

   BEGIN

      json_output := JSON_OBJECT_T();
      json_output.put('test','swagger_badge');
      
      IF p_doc IS NULL
      THEN
         json_output.put('valid',CAST(NULL AS BOOLEAN));
         json_output.put('error','incoming document is null');
         RETURN json_output.to_clob();

      END IF;

      IF c_swagger_badge_url IS NULL
      THEN
         json_output.put('valid',CAST(NULL AS BOOLEAN));
         json_output.put('error','swagger_badge_url is null');
         RETURN json_output.to_clob();

      END IF;

      json_output.put('url',c_swagger_badge_url);

      BEGIN
         IF c_swagger_badge_wallet_path IS NOT NULL
         THEN
            rcx := UTL_HTTP.CREATE_REQUEST_CONTEXT(
                wallet_path     => c_swagger_badge_wallet_path
               ,wallet_password => c_swagger_badge_wallet_pwd
               ,enable_cookies  => TRUE
               ,max_cookies     => 300
               ,max_cookies_per_site => 20
            );

            req := UTL_HTTP.BEGIN_REQUEST(
                url             => c_swagger_badge_url
               ,request_context => rcx
            );

         ELSE
            req := UTL_HTTP.BEGIN_REQUEST(
                url             => c_swagger_badge_url
               ,method          => 'POST'
            );

         END IF;

      EXCEPTION
         WHEN OTHERS
         THEN
            IF SQLCODE IN (-24247,-29273)
            THEN
               json_output.put('valid',CAST(NULL AS BOOLEAN));
               json_output.put('error',SQLERRM);
               RETURN json_output.to_clob();

            ELSE
               RAISE;

            END IF;

      END;

      UTL_HTTP.SET_HEADER(req,'content-type','application/json');
      UTL_HTTP.SET_HEADER(req,'transfer-encoding','chunked');
      UTL_HTTP.SET_HEADER(req,'accept','application/json');

      cst := 1;
      cln := 32767;
      LOOP
         buf := SUBSTR(p_doc,cst,cln);
         UTL_HTTP.WRITE_TEXT(req,buf);

         IF LENGTH(buf) < cln
         THEN
            EXIT;

         END IF;

         cst := cst + cln;

      END LOOP;

      res := UTL_HTTP.GET_RESPONSE(req);
      clb := '';

      BEGIN
         LOOP
            UTL_HTTP.READ_LINE(res,buf);
            clb := clb || buf;

         END LOOP;

         UTL_HTTP.END_RESPONSE(res);

      EXCEPTION
         WHEN UTL_HTTP.END_OF_BODY
         THEN
            UTL_HTTP.END_RESPONSE(res);

      END;

      IF c_swagger_badge_wallet_path IS NOT NULL
      THEN
         UTL_HTTP.DESTROY_REQUEST_CONTEXT(rcx);

      END IF;
      
      IF clb = '{}'
      THEN
         boo_isvalid := TRUE;
         
      ELSE
         boo_isvalid := FALSE;
         
      END IF;  

      json_output.put('valid',boo_isvalid);
      
      IF NOT boo_isvalid
      THEN
         json_results := JSON_OBJECT_T.parse(clb);
      
         IF json_results.has('messages')
         THEN
            json_output.put('messages',json_results.get('messages'));
            
         END IF;
         
         IF json_results.has('schemaValidationMessages')
         THEN
            json_output.put('schemaValidationMessages',json_results.get('schemaValidationMessages'));
            
         END IF;
      
      END IF;
      
      RETURN json_output.to_clob();

   END swagger_badge_validate;

END dz_swagger3_validate;
/

--******************************--
PROMPT Actions/DZ_SWAGGER3_STORAGE_SETUP.sql 

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
      SELECT * FROM TABLE(
         dz_swagger3_setup.dz_swagger3_storage_table_list()
      )
   );
   
   -- Note the tablespaces are controlled via constants package
   IF int_count = 0
   THEN
      dz_swagger3_setup.create_storage_tables();
   
   END IF;

END;
/

--******************************--
PROMPT Actions/DZ_SWAGGER3_TEMP_SETUP1.sql 

BEGIN

   EXECUTE IMMEDIATE 'DROP TABLE dz_swagger3_xrelates';
   EXECUTE IMMEDIATE 'DROP TABLE dz_swagger3_xobjects';
   
EXCEPTION
   WHEN OTHERS
   THEN
      NULL;

END;
/

--******************************--
PROMPT Types/DZ_SWAGGER3_OBJECT_TYP.tps 

CREATE OR REPLACE TYPE dz_swagger3_object_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    object_id           VARCHAR2(255 Char)
   ,object_type_id      VARCHAR2(255 Char)
   ,object_subtype      VARCHAR2(255 Char)
   ,object_attribute    VARCHAR2(4000 Char)
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

--******************************--
PROMPT Types/DZ_SWAGGER3_OBJECT_TYP.tpb 

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

--******************************--
PROMPT Collections/DZ_SWAGGER3_OBJECT_VRY.tps 

CREATE OR REPLACE TYPE dz_swagger3_object_vry FORCE                                       
AS 
VARRAY(2147483647) OF dz_swagger3_object_typ;
/

GRANT EXECUTE ON dz_swagger3_object_vry TO public;

--******************************--
PROMPT Types/DZ_SWAGGER3_INFO_LICENSE_TYP.tps 

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
      p_force_inline         IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_info_license_typ TO public;

--******************************--
PROMPT Types/DZ_SWAGGER3_INFO_LICENSE_TYP.tpb 

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
      p_force_inline         IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the object
      --------------------------------------------------------------------------
      SELECT
      JSON_OBJECT(
          'name'         VALUE self.license_name
         ,'url'          VALUE self.license_url
         ABSENT ON NULL
      )
      INTO clb_output
      FROM dual;

      --------------------------------------------------------------------------
      -- Step 30
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toJSON;
   
END;
/

--******************************--
PROMPT Types/DZ_SWAGGER3_INFO_CONTACT_TYP.tps 

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
       p_contact_name        IN  VARCHAR2
      ,p_contact_url         IN  VARCHAR2
      ,p_contact_email       IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION isNULL
    RETURN VARCHAR2
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON
    RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_info_contact_typ TO public;

--******************************--
PROMPT Types/DZ_SWAGGER3_INFO_CONTACT_TYP.tpb 

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
   MEMBER FUNCTION toJSON
   RETURN CLOB
   AS
      clb_output       CLOB;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the object
      --------------------------------------------------------------------------
      SELECT
      JSON_OBJECT(
          'name'         VALUE self.contact_name
         ,'url'          VALUE self.contact_url
         ,'email'        VALUE self.contact_email   
         ABSENT ON NULL
         RETURNING CLOB
      )
      INTO clb_output
      FROM dual;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toJSON;
   
END;
/

--******************************--
PROMPT Types/DZ_SWAGGER3_INFO_TYP.tps 

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
      p_force_inline         IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_info_typ TO public;

--******************************--
PROMPT Types/DZ_SWAGGER3_INFO_TYP.tpb 

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
      p_force_inline         IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the object
      --------------------------------------------------------------------------
      SELECT
      JSON_OBJECT(
          'title'          VALUE self.info_title
         ,'description'    VALUE self.info_description
         ,'termsOfService' VALUE self.info_termsOfService
         ,'contact'        VALUE CASE
            WHEN self.info_contact.isNULL() = 'FALSE'
            THEN
               self.info_contact.toJSON()
            ELSE
               NULL
            END FORMAT JSON
         ,'license'        VALUE CASE
            WHEN self.info_license.isNULL() = 'FALSE'
            THEN
               self.info_license.toJSON()
            ELSE
               NULL
            END FORMAT JSON
         ,'version'        VALUE self.info_version        
         ABSENT ON NULL
         RETURNING CLOB
      )
      INTO clb_output
      FROM dual; 
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toJSON;
   
END;
/

--******************************--
PROMPT Types/DZ_SWAGGER3_XML_TYP.tps 

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
   ,MEMBER FUNCTION toJSON
    RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_xml_typ TO public;

--******************************--
PROMPT Types/DZ_SWAGGER3_XML_TYP.tpb 

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
   MEMBER FUNCTION toJSON
   RETURN CLOB
   AS
      clb_output       CLOB;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the object
      --------------------------------------------------------------------------
      SELECT
      JSON_OBJECT(
          'name'         VALUE self.xml_name
         ,'namespace'    VALUE self.xml_namespace
         ,'prefix'       VALUE self.xml_prefix
         ,'attribute'    VALUE CASE
            WHEN LOWER(self.xml_attribute) = 'true'
            THEN
               'true'
            ELSE
               NULL
            END FORMAT JSON
         ,'wrapped'      VALUE CASE
            WHEN LOWER(self.xml_wrapped) = 'true'
            THEN
               'true'
            ELSE
               NULL
            END FORMAT JSON
         ABSENT ON NULL
         RETURNING CLOB
      )
      INTO clb_output
      FROM dual;

      --------------------------------------------------------------------------
      -- Step 30
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toJSON;
   
END;
/

--******************************--
PROMPT Types/DZ_SWAGGER3_ENCODING_TYP.tps 

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
       p_force_inline           IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id               IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_encoding_typ TO public;

--******************************--
PROMPT Types/DZ_SWAGGER3_EXAMPLE_TYP.tps 

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
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
    ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_example_typ TO public;

--******************************--
PROMPT Types/DZ_SWAGGER3_EXTRDOCS_TYP.tps 

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
   ,MEMBER FUNCTION toJSON
    RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_extrdocs_typ TO public;

--******************************--
PROMPT Types/DZ_SWAGGER3_HEADER_TYP.tps 

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
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
    ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_header_typ TO public;

--******************************--
PROMPT Types/DZ_SWAGGER3_LINK_TYP.tps 

CREATE OR REPLACE TYPE dz_swagger3_link_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    link_id              VARCHAR2(255 Char)
   ,link_operationRef    VARCHAR2(255 Char)
   ,link_operationId     VARCHAR2(255 Char)
   ,link_op_parm_names   dz_swagger3_string_vry
   ,link_op_parm_exps    dz_swagger3_string_vry
   ,link_requestBody_exp VARCHAR2(4000 Char)
   ,link_description     VARCHAR2(4000 Char)
   ,link_server          dz_swagger3_object_typ --dz_swagger3_server_typ
   ,versionid            VARCHAR2(255 Char)
   
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
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
    ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_link_typ TO public;

--******************************--
PROMPT Types/DZ_SWAGGER3_MEDIA_TYP.tps 

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
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_media_typ TO public;

--******************************--
PROMPT Types/DZ_SWAGGER3_OAUTH_FLOW_TYP.tps 

CREATE OR REPLACE TYPE dz_swagger3_oauth_flow_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    oauth_flow_id                VARCHAR2(255 Char)
   ,oauth_flow_authorizationUrl  VARCHAR2(255 Char)
   ,oauth_flow_tokenUrl          VARCHAR2(255 Char)
   ,oauth_flow_refreshUrl        VARCHAR2(255 Char)
   ,oauth_flow_scope_names       dz_swagger3_string_vry
   ,oauth_flow_scope_desc        dz_swagger3_string_vry
   ,versionid                    VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_oauth_flow_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_oauth_flow_typ(
       p_oauth_flow_id           IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON
    RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_oauth_flow_typ TO public;

--******************************--
PROMPT Types/DZ_SWAGGER3_OPERATION_TYP.tps 

CREATE OR REPLACE TYPE dz_swagger3_operation_typ FORCE
AUTHID DEFINER
AS OBJECT (
    operation_id                  VARCHAR2(255 Char)
   ,operation_type                VARCHAR2(255 Char)
   ,operation_tags                dz_swagger3_object_vry --dz_swagger3_tag_list
   ,operation_summary             VARCHAR2(255 Char)
   ,operation_description         VARCHAR2(4000 Char)
   ,operation_externalDocs        dz_swagger3_object_typ --dz_swagger3_extrdocs_typ
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
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_xorder              IN  INTEGER   DEFAULT NULL
    ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_operation_typ TO public;

--******************************--
PROMPT Types/DZ_SWAGGER3_PARAMETER_TYP.tps 

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
       p_force_inline              IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id                  IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier                IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count           IN  INTEGER   DEFAULT NULL
    ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_parameter_typ TO public;

--******************************--
PROMPT Types/DZ_SWAGGER3_PATH_TYP.tps 

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
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
      ,p_xorder              IN  INTEGER   DEFAULT NULL
    ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_path_typ TO public;

--******************************--
PROMPT Types/DZ_SWAGGER3_REQUESTBODY_TYP.tps 

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
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
    ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_requestbody_typ TO public;

--******************************--
PROMPT Types/DZ_SWAGGER3_RESPONSE_TYP.tps 

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
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
    ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_response_typ TO public;

--******************************--
PROMPT Types/DZ_SWAGGER3_SCHEMA_TYP.tps 

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
   ,schema_enum_string       dz_swagger3_string_vry
   ,schema_enum_number       dz_swagger3_number_vry
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
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
      ,p_jsonschema          IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_xorder              IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toMockJSON(
       p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
   ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toMockXML(
       p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_schema_typ TO public;

--******************************--
PROMPT Types/DZ_SWAGGER3_SECURITYSCHEME_TYP.tps 

CREATE OR REPLACE TYPE dz_swagger3_securityScheme_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    securityscheme_id            VARCHAR2(255 Char)
   ,securityscheme_fullname      VARCHAR2(255 Char)
   ,securityscheme_type          VARCHAR2(255 Char)
   ,securityscheme_description   VARCHAR2(255 Char)
   ,securityscheme_name          VARCHAR2(255 Char)
   ,securityscheme_in            VARCHAR2(255 Char)
   ,securityscheme_scheme        VARCHAR2(255 Char)
   ,securityscheme_bearerFormat  VARCHAR2(255 Char)
   ,oauth_flow_implicit          dz_swagger3_oauth_flow_typ
   ,oauth_flow_password          dz_swagger3_oauth_flow_typ
   ,oauth_flow_clientCredentials dz_swagger3_oauth_flow_typ
   ,oauth_flow_authorizationCode dz_swagger3_oauth_flow_typ
   ,securityscheme_openIdConUrl  VARCHAR2(255 Char)
   ,versionid                    VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_securityScheme_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_securityScheme_typ(
       p_securityscheme_id       IN  VARCHAR2
      ,p_securityscheme_fullname IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON
    RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON_req(
      p_oauth_scope_flows       IN  VARCHAR2  DEFAULT NULL
    ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_securityScheme_typ TO public;

--******************************--
PROMPT Types/DZ_SWAGGER3_SERVER_TYP.tps 

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
   ,MEMBER FUNCTION toJSON
    RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_server_typ TO public;

--******************************--
PROMPT Types/DZ_SWAGGER3_SERVER_VAR_TYP.tps 

CREATE OR REPLACE TYPE dz_swagger3_server_var_typ FORCE
AUTHID DEFINER
AS OBJECT (
    server_var_id       VARCHAR2(255 Char)
   ,server_var_name     VARCHAR2(255 Char)
   ,enum                dz_swagger3_string_vry
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
   ,MEMBER FUNCTION toJSON
    RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_server_var_typ TO public;

--******************************--
PROMPT Types/DZ_SWAGGER3_TAG_TYP.tps 

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
   ,MEMBER FUNCTION toJSON
    RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_tag_typ TO public;

--******************************--
PROMPT Types/DZ_SWAGGER3_TYP.tps 

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
   ,return_code         NUMBER
   ,status_message      VARCHAR2(4000 Char)
   
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
   ) RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION validity(
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_options             IN  VARCHAR2  DEFAULT NULL
    ) RETURN CLOB
    
);
/

GRANT EXECUTE ON dz_swagger3_typ TO public;

--******************************--
PROMPT Actions/DZ_SWAGGER3_TEMP_SETUP2.sql 

BEGIN

   dz_swagger3_setup.create_temp_tables();

END;
/

--******************************--
PROMPT Packages/DZ_SWAGGER3_LOADER.pks 

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
   PROCEDURE securityschemetyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
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
   PROCEDURE tagtyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
 
 END dz_swagger3_loader;
/

GRANT EXECUTE ON dz_swagger3_loader TO public;

--******************************--
PROMPT Packages/DZ_SWAGGER3_LOADER.pkb 

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
      obj       dz_swagger3_encoding_typ;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      FOR i IN 1 .. ary_ids.COUNT
      LOOP
         obj := dz_swagger3_encoding_typ(
             p_encoding_id   => ary_ids(i).object_id
            ,p_versionid     => p_versionid
         );
         
         INSERT INTO dz_swagger3_xobjects(
              object_id
             ,object_type_id
             ,encodingtyp
         ) VALUES (
             ary_ids(i).object_id
            ,ary_ids(i).object_type_id
            ,obj
         );
         
      END LOOP;

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
      obj       dz_swagger3_example_typ;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);
      
      FOR i IN 1 .. ary_ids.COUNT
      LOOP
         obj := dz_swagger3_example_typ(
             p_example_id => ary_ids(i).object_id
            ,p_versionid  => p_versionid
         );
         
         INSERT INTO dz_swagger3_xobjects(
              object_id
             ,object_type_id
             ,exampletyp
         ) VALUES (
             ary_ids(i).object_id
            ,ary_ids(i).object_type_id
            ,obj
         );
         
      END LOOP;
      
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
      obj       dz_swagger3_extrdocs_typ;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      FOR i IN 1 .. ary_ids.COUNT
      LOOP
         obj := dz_swagger3_extrdocs_typ(
             p_externaldoc_id => ary_ids(i).object_id
            ,p_versionid      => p_versionid
         );
         
         INSERT INTO dz_swagger3_xobjects(
              object_id
             ,object_type_id
             ,extrdocstyp
         ) VALUES (
             ary_ids(i).object_id
            ,ary_ids(i).object_type_id
            ,obj
         );
         
      END LOOP;
      
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
      obj       dz_swagger3_header_typ;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      FOR i IN 1 .. ary_ids.COUNT
      LOOP
         obj := dz_swagger3_header_typ(
             p_header_id    => ary_ids(i).object_id
            ,p_versionid    => p_versionid
         );
         
         INSERT INTO dz_swagger3_xobjects(
              object_id
             ,object_type_id
             ,headertyp
         ) VALUES (
             ary_ids(i).object_id
            ,ary_ids(i).object_type_id
            ,obj
         );
         
      END LOOP;

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
         AND a.headertyp IS NOT NULL
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
      obj     dz_swagger3_link_typ;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      FOR i IN 1 .. ary_ids.COUNT
      LOOP
         obj := dz_swagger3_link_typ(
             p_link_id    => ary_ids(i).object_id
            ,p_versionid  => p_versionid
         );
         
         INSERT INTO dz_swagger3_xobjects(
              object_id
             ,object_type_id
             ,linktyp
         ) VALUES (
             ary_ids(i).object_id
            ,ary_ids(i).object_type_id
            ,obj
         );
         
      END LOOP;

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
      obj       dz_swagger3_media_typ;
      
   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      FOR i IN 1 .. ary_ids.COUNT
      LOOP
         obj := dz_swagger3_media_typ(
             p_media_id    => ary_ids(i).object_id
            ,p_versionid   => p_versionid
         );
          
         INSERT 
         INTO dz_swagger3_xobjects(
             object_id
            ,object_type_id
            ,mediatyp
         ) VALUES (
             ary_ids(i).object_id
            ,ary_ids(i).object_type_id
            ,obj
         );

      END LOOP;
      
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
         AND a.mediatyp IS NOT NULL
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
      obj       dz_swagger3_media_typ;
      
   BEGIN
   
      ary_ids := filter_ids(
          p_children_ids
         ,p_parent_id
      );

      FOR i IN 1 .. ary_ids.COUNT
      LOOP
         obj := dz_swagger3_media_typ(
             p_media_id       => ary_ids(i).object_id
            ,p_parameters     => p_parameter_ids
            ,p_versionid      => p_versionid
         );

         INSERT INTO dz_swagger3_xobjects(
              object_id
             ,object_type_id
             ,mediatyp
         ) VALUES (
             ary_ids(i).object_id
            ,ary_ids(i).object_type_id
            ,obj
         );
         
      END LOOP;

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
         AND a.mediatyp IS NOT NULL
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
      obj       dz_swagger3_operation_typ;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      FOR i IN 1 .. ary_ids.COUNT
      LOOP
         obj := dz_swagger3_operation_typ(
             p_operation_id => ary_ids(i).object_id
            ,p_versionid    => p_versionid
         );
         
         INSERT 
         INTO dz_swagger3_xobjects(
             object_id
            ,object_type_id
            ,operationtyp
         ) VALUES (
             ary_ids(i).object_id
            ,ary_ids(i).object_type_id
            ,obj
         );
         
      END LOOP;
      
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
      obj       dz_swagger3_parameter_typ;

   BEGIN
      
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      FOR i IN 1 .. ary_ids.COUNT
      LOOP
         obj := dz_swagger3_parameter_typ(
             p_parameter_id => ary_ids(i).object_id
            ,p_versionid    => p_versionid
         );

         INSERT INTO dz_swagger3_xobjects(
             object_id
            ,object_type_id
            ,parametertyp
         ) VALUES (
             ary_ids(i).object_id
            ,ary_ids(i).object_type_id
            ,obj
         );
         
      END LOOP;

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
      obj       dz_swagger3_path_typ;
      
   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      FOR i IN 1 .. ary_ids.COUNT
      LOOP
         obj := dz_swagger3_path_typ(
             p_path_id    => ary_ids(i).object_id
            ,p_versionid  => p_versionid
         );
         
         INSERT INTO dz_swagger3_xobjects(
              object_id
             ,object_type_id
             ,pathtyp
         ) VALUES (
             ary_ids(i).object_id
            ,ary_ids(i).object_type_id
            ,obj
         );
         
      END LOOP;
      
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
      obj       dz_swagger3_requestbody_typ;

   BEGIN
   
      ary_ids := filter_ids(
          dz_swagger3_object_vry(p_child_id)
         ,p_parent_id
      );

      FOR i IN 1 .. ary_ids.COUNT
      LOOP
         obj := dz_swagger3_requestbody_typ(
             p_requestbody_id => ary_ids(i).object_id
            ,p_versionid      => p_versionid
         );
         
         INSERT INTO dz_swagger3_xobjects(
              object_id
             ,object_type_id
             ,requestbodytyp
         ) VALUES (
             ary_ids(i).object_id
            ,ary_ids(i).object_type_id
            ,obj
         );

      END LOOP;
      
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
      obj       dz_swagger3_requestbody_typ;

   BEGIN
   
      ary_ids := filter_ids(
          dz_swagger3_object_vry(p_child_id)
         ,p_parent_id
      );

      FOR i IN 1 .. ary_ids.COUNT
      LOOP
         obj := dz_swagger3_requestbody_typ(
             p_requestbody_id => ary_ids(i).object_id
            ,p_parameters     => p_parameter_ids
            ,p_versionid      => p_versionid
         );
         
         INSERT INTO dz_swagger3_xobjects(
              object_id
             ,object_type_id
             ,requestbodytyp
         ) VALUES (
             ary_ids(i).object_id
            ,ary_ids(i).object_type_id
            ,obj
         );

      END LOOP;

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
      obj       dz_swagger3_response_typ;

   BEGIN
   
      ary_ids := filter_ids(
          p_children_ids
         ,p_parent_id
      );

      FOR i IN 1 .. ary_ids.COUNT
      LOOP
         obj := dz_swagger3_response_typ(
             p_response_id    => ary_ids(i).object_id
            ,p_response_code  => ary_ids(i).object_key
            ,p_versionid      => p_versionid
         );
         
         INSERT INTO dz_swagger3_xobjects(
              object_id
             ,object_type_id
             ,responsetyp
         ) VALUES (
             ary_ids(i).object_id
            ,ary_ids(i).object_type_id
            ,obj
         );
         
      END LOOP;

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
      obj       dz_swagger3_schema_typ;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      FOR i IN 1 .. ary_ids.COUNT
      LOOP
         IF ary_ids(i).object_subtype = 'emulated_item'
         THEN
            obj := dz_swagger3_schema_typ(
                p_schema_id             => ary_ids(i).object_id
               ,p_emulated_parameter_id => ary_ids(i).object_attribute
               ,p_versionid             => p_versionid
            );
            
         ELSE
            obj := dz_swagger3_schema_typ(
                p_schema_id             => ary_ids(i).object_id
               ,p_versionid             => p_versionid
            );
            
         END IF;

         INSERT INTO dz_swagger3_xobjects(
              object_id
             ,object_type_id
             ,schematyp
         ) VALUES (
             ary_ids(i).object_id
            ,ary_ids(i).object_type_id
            ,obj
         );
         
      END LOOP;
      
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
         AND a.schematyp IS NOT NULL
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
      obj       dz_swagger3_schema_typ;

   BEGIN
   
      ary_ids := filter_ids(
          dz_swagger3_object_vry(p_child_id)
         ,p_parent_id
      );

      FOR i IN 1 .. ary_ids.COUNT
      LOOP
         obj := dz_swagger3_schema_typ(
             p_schema_id     => ary_ids(i).object_id
            ,p_parameters    => p_parameter_ids
            ,p_versionid     => p_versionid
         );
          
         INSERT INTO dz_swagger3_xobjects(
              object_id
             ,object_type_id
             ,schematyp
         ) VALUES (
             ary_ids(i).object_id
            ,ary_ids(i).object_type_id
            ,obj
         );
         
      END LOOP;

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
   PROCEDURE securityschemetyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;
      obj       dz_swagger3_securityscheme_typ;
      
   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      FOR i IN 1 .. ary_ids.COUNT
      LOOP
         obj := dz_swagger3_securityscheme_typ(
             p_securityscheme_id       => ary_ids(i).object_id
            ,p_securityscheme_fullname => ary_ids(i).object_key
            ,p_versionid               => p_versionid
         );
         
         INSERT 
         INTO dz_swagger3_xobjects(
              object_id
             ,object_type_id
             ,securityschemetyp
         ) VALUES (
             ary_ids(i).object_id
            ,ary_ids(i).object_type_id
            ,obj
         );

      END LOOP;

   END securityschemetyp;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE servertyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;
      obj       dz_swagger3_server_typ;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      FOR i IN 1 .. ary_ids.COUNT
      LOOP
         obj := dz_swagger3_server_typ(
             p_server_id   => ary_ids(i).object_id
            ,p_versionid   => p_versionid
         );
         
         INSERT 
         INTO dz_swagger3_xobjects(
              object_id
             ,object_type_id
             ,servertyp
         ) VALUES (
             ary_ids(i).object_id
            ,ary_ids(i).object_type_id
            ,obj
         );
         
      END LOOP;
      
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
         AND a.servertyp IS NOT NULL
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
      obj       dz_swagger3_server_var_typ;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      FOR i IN 1 .. ary_ids.COUNT
      LOOP
         obj := dz_swagger3_server_var_typ(
             p_server_var_id  => ary_ids(i).object_id
            ,p_versionid      => p_versionid
         );
         
         INSERT 
         INTO dz_swagger3_xobjects(
              object_id
             ,object_type_id
             ,servervartyp
         ) VALUES (
             ary_ids(i).object_id
            ,ary_ids(i).object_type_id
            ,obj
         );

      END LOOP;
      
      -- No subobjects
      
   END servervartyp;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE tagtyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;
      obj       dz_swagger3_tag_typ;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      FOR i IN 1 .. ary_ids.COUNT
      LOOP
         obj := dz_swagger3_tag_typ(
             p_tag_id        => ary_ids(i).object_id
            ,p_versionid     => p_versionid
         );
         
         INSERT 
         INTO dz_swagger3_xobjects(
              object_id
             ,object_type_id
             ,tagtyp
         ) VALUES (
             ary_ids(i).object_id
            ,ary_ids(i).object_type_id
            ,obj
         );
         
      END LOOP;
      
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

--******************************--
PROMPT Packages/DZ_SWAGGER3_MAIN.pks 

CREATE OR REPLACE PACKAGE dz_swagger3_main
AUTHID DEFINER
AS
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   /*
   header: DZ_SWAGGER3
     
   - Release: v1.1.0
   - Commit Date: Mon May 3 08:41:58 2021 -0400
   
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

--******************************--
PROMPT Packages/DZ_SWAGGER3_MAIN.pkb 

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

--******************************--
PROMPT Types/DZ_SWAGGER3_ENCODING_TYP.tpb 

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
      SELECT
      dz_swagger3_object_typ(
          p_object_id          => a.header_id
         ,p_object_type_id     => 'headertyp'
         ,p_object_key         => a.header_name
         ,p_object_order       => a.header_order
      )
      BULK COLLECT INTO self.encoding_headers 
      FROM
      dz_swagger3_parent_header_map a
      WHERE
          a.versionid  = p_versionid
      AND a.parent_id  = p_encoding_id;

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
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output           CLOB;
      clb_encoding_headers CLOB;
      int_encoding_headers PLS_INTEGER;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Add optional encoding headers
      --------------------------------------------------------------------------
      IF  self.encoding_headers IS NOT NULL 
      AND self.encoding_headers.COUNT > 0
      THEN
         SELECT
         JSON_OBJECTAGG(
             b.object_key VALUE a.headertyp.toJSON(
                p_force_inline     => p_force_inline
               ,p_short_id         => p_short_id
               ,p_identifier       => a.object_id
               ,p_short_identifier => a.short_id
               ,p_reference_count  => a.reference_count
            ) FORMAT JSON
            RETURNING CLOB
         )
         INTO clb_encoding_headers
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.encoding_headers) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id;

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Build the object
      --------------------------------------------------------------------------
      IF self.encoding_headers IS NOT NULL
      THEN
         int_encoding_headers := self.encoding_headers.COUNT;
         
      ELSE
         int_encoding_headers := 0;
         
      END IF;

      SELECT
      JSON_OBJECT(
          'contentType'         VALUE self.encoding_contentType
         ,'headers'             VALUE CASE
            WHEN int_encoding_headers > 0
            THEN
               clb_encoding_headers
            ELSE
               NULL
            END FORMAT JSON
         ,'style'               VALUE self.encoding_style
         ,'explode'             VALUE CASE
            WHEN LOWER(self.encoding_explode) = 'true'
            THEN
               'true'
            WHEN LOWER(self.encoding_explode) = 'false'
            THEN
               'false'
            ELSE
               NULL
            END FORMAT JSON
         ,'allowReserved'       VALUE CASE
            WHEN LOWER(self.encoding_allowReserved) = 'true'
            THEN
               'true'
            WHEN LOWER(self.encoding_allowReserved) = 'false'
            THEN
               'false'
            ELSE
               NULL
            END FORMAT JSON
         ABSENT ON NULL
         RETURNING CLOB
      )
      INTO clb_output
      FROM dual;

      --------------------------------------------------------------------------
      -- Step 40
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toJSON;
   
END;
/

--******************************--
PROMPT Types/DZ_SWAGGER3_EXAMPLE_TYP.tpb 

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
   
      --------------------------------------------------------------------------
      -- Step 10 
      -- Initialize the object
      --------------------------------------------------------------------------
      self.versionid := p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 20 
      -- Load the example self
      --------------------------------------------------------------------------
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
   
      --------------------------------------------------------------------------
      -- Step 30 
      -- Return the object
      --------------------------------------------------------------------------
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
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_identifier   VARCHAR2(4000 Char);
      
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
         
         SELECT
         JSON_OBJECT(
            '$ref'   VALUE  '#/components/examples/' || str_identifier
         )
         INTO clb_output
         FROM dual;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Or run it as usual
      --------------------------------------------------------------------------
      ELSE
         IF self.example_value_string IS NOT NULL
         THEN
            SELECT
            JSON_OBJECT(
                'summary'       VALUE self.example_summary
               ,'description'   VALUE self.example_description
               ,'value'         VALUE self.example_value_string
               ,'externalValue' VALUE self.example_externalValue 
               ABSENT ON NULL
               RETURNING CLOB
            )
            INTO clb_output
            FROM dual;

         ELSIF self.example_value_number IS NOT NULL
         THEN
            SELECT
            JSON_OBJECT(
                'summary'       VALUE self.example_summary
               ,'description'   VALUE self.example_description
               ,'value'         VALUE self.example_value_number
               ,'externalValue' VALUE self.example_externalValue 
               ABSENT ON NULL
               RETURNING CLOB
            )
            INTO clb_output
            FROM dual;
            
         ELSE
            SELECT
            JSON_OBJECT(
                'summary'       VALUE self.example_summary
               ,'description'   VALUE self.example_description
               ,'externalValue' VALUE self.example_externalValue 
               ABSENT ON NULL
               RETURNING CLOB
            )
            INTO clb_output
            FROM dual;
            
         END IF;
 
      END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toJSON;
   
END;
/

--******************************--
PROMPT Types/DZ_SWAGGER3_EXTRDOCS_TYP.tpb 

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
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Initialize the object
      --------------------------------------------------------------------------
      self.versionid := p_versionid;

      --------------------------------------------------------------------------
      -- Step 20
      -- Pull the object information
      --------------------------------------------------------------------------
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
            
         WHEN OTHERS
         THEN
            RAISE;
            
      END;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Return the completed object
      --------------------------------------------------------------------------
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
   MEMBER FUNCTION toJSON
   RETURN CLOB
   AS
      clb_output       CLOB;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the object
      --------------------------------------------------------------------------
      SELECT
      JSON_OBJECT(
          'description'  VALUE self.externaldoc_description
         ,'url'          VALUE self.externaldoc_url         
         ABSENT ON NULL
         RETURNING CLOB
      )
      INTO clb_output
      FROM dual;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toJSON;
   
END;
/

--******************************--
PROMPT Types/DZ_SWAGGER3_HEADER_TYP.tpb 

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
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output          CLOB;
      str_identifier      VARCHAR2(4000 Char);
      clb_header_examples CLOB;
      clb_header_schema   CLOB;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build refs
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
         
         SELECT
         JSON_OBJECT(
            '$ref' VALUE '#/components/headers/' || str_identifier
         )
         INTO clb_output
         FROM dual;
      
      ELSE
      --------------------------------------------------------------------------
      -- Step 30
      -- Generate optional header examples
      --------------------------------------------------------------------------
         IF  self.header_examples IS NOT NULL 
         AND self.header_examples.COUNT > 0
         THEN
            SELECT
            JSON_OBJECTAGG(
               b.object_key VALUE a.exampletyp.toJSON(
                   p_force_inline     => p_force_inline
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_reference_count  => a.reference_count
               ) FORMAT JSON
               ABSENT ON NULL
               RETURNING CLOB
            )
            INTO clb_header_examples
            FROM
            dz_swagger3_xobjects a
            JOIN
            TABLE(self.header_examples) b
            ON
                a.object_type_id = b.object_type_id
            AND a.object_id      = b.object_id; 

         END IF;
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional header schema
      --------------------------------------------------------------------------
         IF self.header_schema IS NOT NULL
         THEN
            BEGIN
               SELECT
               a.schematyp.toJSON(
                   p_force_inline     => p_force_inline
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_reference_count  => a.reference_count
               )
               INTO clb_header_schema
               FROM
               dz_swagger3_xobjects a
               WHERE
                   a.object_type_id = self.header_schema.object_type_id
               AND a.object_id      = self.header_schema.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_header_schema := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;

         END IF;
         
      --------------------------------------------------------------------------
      -- Step 50
      -- Build the output object
      --------------------------------------------------------------------------
         IF self.header_example_string IS NOT NULL
         THEN
            SELECT
            JSON_OBJECT(
                'description'     VALUE self.header_description
               ,'required'        VALUE CASE
                  WHEN LOWER(self.header_required) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_required) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'deprecated'      VALUE CASE
                  WHEN LOWER(self.header_deprecated) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_deprecated) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'allowEmptyValue' VALUE CASE
                  WHEN LOWER(self.header_allowEmptyValue) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_allowEmptyValue) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'style'            VALUE self.header_style
               ,'explode'          VALUE CASE
                  WHEN LOWER(self.header_explode) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_explode) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'allowReserved'    VALUE CASE
                  WHEN LOWER(self.header_allowReserved) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_allowReserved) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'schema'           VALUE clb_header_schema      FORMAT JSON
               ,'example'          VALUE self.header_example_string
               ABSENT ON NULL
               RETURNING CLOB
            )
            INTO clb_output
            FROM dual;
            
         ELSIF self.header_example_number IS NOT NULL
         THEN
            SELECT
            JSON_OBJECT(
                'description'     VALUE self.header_description
               ,'required'        VALUE CASE
                  WHEN LOWER(self.header_required) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_required) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'deprecated'      VALUE CASE
                  WHEN LOWER(self.header_deprecated) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_deprecated) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'allowEmptyValue' VALUE CASE
                  WHEN LOWER(self.header_allowEmptyValue) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_allowEmptyValue) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'style'            VALUE self.header_style
               ,'explode'          VALUE CASE
                  WHEN LOWER(self.header_explode) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_explode) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'allowReserved'    VALUE CASE
                  WHEN LOWER(self.header_allowReserved) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_allowReserved) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'schema'           VALUE clb_header_schema      FORMAT JSON
               ,'example'          VALUE self.header_example_number
               ABSENT ON NULL
               RETURNING CLOB
            )
            INTO clb_output
            FROM dual;
            
         ELSE
            SELECT
            JSON_OBJECT(
                'description'     VALUE self.header_description
               ,'required'        VALUE CASE
                  WHEN LOWER(self.header_required) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_required) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'deprecated'      VALUE CASE
                  WHEN LOWER(self.header_deprecated) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_deprecated) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'allowEmptyValue' VALUE CASE
                  WHEN LOWER(self.header_allowEmptyValue) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_allowEmptyValue) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'style'            VALUE self.header_style
               ,'explode'          VALUE CASE
                  WHEN LOWER(self.header_explode) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_explode) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'allowReserved'    VALUE CASE
                  WHEN LOWER(self.header_allowReserved) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.header_allowReserved) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'schema'           VALUE clb_header_schema      FORMAT JSON
               ,'examples'         VALUE clb_header_examples    FORMAT JSON
               ABSENT ON NULL
               RETURNING CLOB
            )
            INTO clb_output
            FROM dual;
            
         END IF;

      END IF;

      --------------------------------------------------------------------------
      -- Step 60
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toJSON;
   
END;
/

--******************************--
PROMPT Types/DZ_SWAGGER3_LINK_TYP.tpb 

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
      ,a.link_requestBody_exp
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
      ,self.link_requestBody_exp
      ,self.link_server
      FROM
      dz_swagger3_link a
      WHERE
          a.versionid = p_versionid
      AND a.link_id   = p_link_id;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Fetch parameter expression map
      --------------------------------------------------------------------------
      SELECT
       a.link_op_parm_name
      ,a.link_op_parm_exp
      BULK COLLECT INTO
       self.link_op_parm_names
      ,self.link_op_parm_exps
      FROM
      dz_swagger3_link_op_parms a
      WHERE
          a.versionid = p_versionid
      AND a.link_id   = p_link_id
      ORDER BY a.link_op_parm_order;

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
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output       CLOB;
      str_identifier   VARCHAR2(255 Char);
      str_operation_id VARCHAR2(255 Char);
      clb_parameters   CLOB;
      clb_server       CLOB;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Add the ref object
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
         
         SELECT
         JSON_OBJECT(
            '$ref' VALUE '#/components/links/' || str_identifier
         )
         INTO clb_output
         FROM dual;

      ELSE
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional parameter map
      --------------------------------------------------------------------------
         IF  self.link_op_parm_names IS NOT NULL
         AND self.link_op_parm_names.COUNT > 0
         THEN
            SELECT
            JSON_OBJECTAGG(
               a.parmname VALUE b.parmexps
               RETURNING CLOB          
            )
            INTO clb_parameters
            FROM (
               SELECT
                rownum       AS namerowid
               ,column_value AS parmname
               FROM
               TABLE(self.link_op_parm_names)
            ) a
            JOIN (
               SELECT
                rownum       AS expsrowid
               ,column_value AS parmexps
               FROM
               TABLE(self.link_op_parm_exps)
            ) b
            ON
            a.namerowid = b.expsrowid;
         
         END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Add server object
      --------------------------------------------------------------------------
         IF self.link_server IS NOT NULL
         THEN
            BEGIN
               SELECT
               a.servertyp.toJSON()
               INTO clb_server
               FROM dz_swagger3_xobjects a
               WHERE
                   a.object_type_id = self.link_server.object_type_id
               AND a.object_id      = self.link_server.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_server := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;

         END IF;
         
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional operationId
      --------------------------------------------------------------------------
         IF  self.link_operationRef IS NULL
         AND self.link_operationId  IS NOT NULL
         THEN
            IF p_short_id = 'TRUE'
            THEN
               SELECT
               a.short_id
               INTO str_operation_id
               FROM
               dz_swagger3_xobjects a
               WHERE
               a.object_id = self.link_operationID;
            
            ELSE
               str_operation_id := self.link_operationID;
               
            END IF;
            
         END IF;
         
      --------------------------------------------------------------------------
      -- Step 60
      -- Build the object
      --------------------------------------------------------------------------
         SELECT
         JSON_OBJECT(
             'operationRef'  VALUE self.link_operationRef
            ,'operationId'   VALUE str_operation_id
            ,'parameters'    VALUE clb_parameters            FORMAT JSON
            ,'requestBody'   VALUE self.link_requestBody_exp
            ,'description'   VALUE self.link_description
            ,'server'        VALUE clb_server                FORMAT JSON 
            ABSENT ON NULL
            RETURNING CLOB
         )
         INTO clb_output
         FROM dual;  
      
      END IF;

      --------------------------------------------------------------------------
      -- Step 70
      -- Cough it out
      --------------------------------------------------------------------------      
      RETURN clb_output;
           
   END toJSON;
   
END;
/

--******************************--
PROMPT Types/DZ_SWAGGER3_MEDIA_TYP.tpb 

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
      --dbms_output.put_line('media: ' || p_media_id);
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
         ,p_object_key     => a.example_name
         ,p_object_order   => a.example_order
      )
      BULK COLLECT INTO self.media_examples
      FROM
      dz_swagger3_parent_example_map a
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
         ,p_object_key     => a.encoding_name
         ,p_object_order   => a.encoding_order
      )
      BULK COLLECT INTO self.media_encoding
      FROM
      dz_swagger3_media_encoding_map a
      WHERE
          a.versionid   = p_versionid
      AND a.media_id   = p_media_id;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Return the completed object
      --------------------------------------------------------------------------
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
         dz_swagger3_loader.exampletyp(
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
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output         CLOB;
      clb_media_schema   CLOB;
      clb_media_examples CLOB;
      clb_media_encoding CLOB;
      
   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Add schema object
      --------------------------------------------------------------------------
      IF  self.media_schema IS NOT NULL
      AND self.media_schema.object_id IS NOT NULL
      THEN
         BEGIN
            SELECT 
            a.schematyp.toJSON( 
                p_force_inline     => p_force_inline
               ,p_short_id         => p_short_id
               ,p_identifier       => a.object_id 
               ,p_short_identifier => a.short_id 
               ,p_reference_count  => a.reference_count 
            )
            INTO clb_media_schema
            FROM 
            dz_swagger3_xobjects a 
            WHERE 
                a.object_type_id = self.media_schema.object_type_id
            AND a.object_id      = self.media_schema.object_id; 
            
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_media_schema := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;

      END IF;
        
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional examples map
      --------------------------------------------------------------------------
      IF  self.media_examples IS NOT NULL 
      AND self.media_examples.COUNT > 0
      THEN
         SELECT
         JSON_OBJECTAGG(
            b.object_key VALUE a.exampletyp.toJSON(
                p_force_inline     => p_force_inline
               ,p_short_id         => p_short_id
               ,p_identifier       => a.object_id
               ,p_short_identifier => a.short_id
               ,p_reference_count  => a.reference_count
            ) FORMAT JSON
            RETURNING CLOB
         )
         INTO clb_media_examples
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.media_examples) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional encoding map
      --------------------------------------------------------------------------
      IF  self.media_encoding IS NOT NULL 
      AND self.media_encoding.COUNT > 0
      THEN
         SELECT
         JSON_OBJECTAGG(
            b.object_key VALUE a.encodingtyp.toJSON(
                p_force_inline   => p_force_inline
               ,p_short_id       => p_short_id
            ) FORMAT JSON
            RETURNING CLOB
         )
         INTO clb_media_encoding
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.media_encoding) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id;

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Build the object
      --------------------------------------------------------------------------
      IF self.media_example_string IS NOT NULL
      THEN
         SELECT
         JSON_OBJECT(
             'schema'       VALUE clb_media_schema          FORMAT JSON
            ,'example'      VALUE self.media_example_string
            ,'encoding'     VALUE clb_media_encoding        FORMAT JSON
            ABSENT ON NULL
            RETURNING CLOB
         )
         INTO clb_output
         FROM dual;
         
      ELSIF self.media_example_number IS NOT NULL
      THEN
         SELECT
         JSON_OBJECT(
             'schema'       VALUE clb_media_schema          FORMAT JSON
            ,'example'      VALUE self.media_example_number
            ,'encoding'     VALUE clb_media_encoding        FORMAT JSON
            ABSENT ON NULL
            RETURNING CLOB
         )
         INTO clb_output
         FROM dual;
      
      ELSE
         SELECT
         JSON_OBJECT(
             'schema'       VALUE clb_media_schema          FORMAT JSON
            ,'examples'     VALUE clb_media_examples        FORMAT JSON
            ,'encoding'     VALUE clb_media_encoding        FORMAT JSON
            ABSENT ON NULL
            RETURNING CLOB
         )
         INTO clb_output
         FROM dual;
      
      END IF;

      --------------------------------------------------------------------------
      -- Step 60
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;

END;
/

--******************************--
PROMPT Types/DZ_SWAGGER3_OAUTH_FLOW_TYP.tpb 

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
       p_oauth_flow_id           IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
   
      self.versionid := p_versionid;
      
      SELECT
       a.oauth_flow_id
      ,a.oauth_flow_authorizationUrl
      ,a.oauth_flow_tokenUrl 
      ,a.oauth_flow_refreshUrl
      INTO
       self.oauth_flow_id
      ,self.oauth_flow_authorizationUrl
      ,self.oauth_flow_tokenUrl
      ,self.oauth_flow_refreshUrl
      FROM
      dz_swagger3_oauth_flow a
      WHERE
          a.versionid     = p_versionid
      AND a.oauth_flow_id = p_oauth_flow_id;
      
      SELECT
       a.oauth_flow_scope_name 
      ,a.oauth_flow_scope_desc
      BULK COLLECT INTO
       self.oauth_flow_scope_names
      ,self.oauth_flow_scope_desc
      FROM
      dz_swagger3_oauth_flow_scope a
      WHERE
          a.versionid     = p_versionid
      AND a.oauth_flow_id = p_oauth_flow_id;
      
      RETURN; 
      
   END dz_swagger3_oauth_flow_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON
   RETURN CLOB
   AS
      clb_output       CLOB;
      clob_scopes      CLOB;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Generate optional scope map
      --------------------------------------------------------------------------
      IF  self.oauth_flow_scope_names IS NOT NULL
      AND self.oauth_flow_scope_names.COUNT > 0
      THEN
         SELECT
         JSON_OBJECTAGG(
            a.scopename VALUE b.scopedesc
            RETURNING CLOB
         )
         INTO clob_scopes
         FROM (
            SELECT
             rownum       AS namerowid
            ,column_value AS scopename
            FROM
            TABLE(self.oauth_flow_scope_names)
         ) a
         JOIN (
            SELECT
             rownum       AS descrowid
            ,column_value AS scopedesc
            FROM
            TABLE(self.oauth_flow_scope_desc)
         ) b
         ON
         a.namerowid = b.descrowid;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Build the object
      --------------------------------------------------------------------------
      SELECT
      JSON_OBJECT(
          'authorizationUrl' VALUE self.oauth_flow_authorizationUrl
         ,'tokenUrl'         VALUE self.oauth_flow_tokenUrl
         ,'refreshUrl'       VALUE self.oauth_flow_refreshUrl
         ,'scopes'           VALUE clob_scopes                      FORMAT JSON 
         ABSENT ON NULL
         RETURNING CLOB
      )
      INTO clb_output
      FROM dual;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toJSON;
   
END;
/

--******************************--
PROMPT Types/DZ_SWAGGER3_OPERATION_TYP.tpb 

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
      WHERE
          a.versionid    = p_versionid
      AND a.operation_id = p_operation_id;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Load the security items
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id        => a.securityScheme_id
         ,p_object_type_id   => 'securityschemetyp'
         ,p_object_key       => a.securityScheme_name
         ,p_object_attribute => a.oauth_flow_scopes
         ,p_object_order     => a.securityScheme_order
      )
      BULK COLLECT INTO self.operation_security
      FROM
      dz_swagger3_parent_secschm_map a
      WHERE
          a.versionid = p_versionid
      AND a.parent_id = p_operation_id;
      
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
      -- Load the external docs
      --------------------------------------------------------------------------
      IF  self.operation_externalDocs IS NOT NULL
      AND self.operation_externalDocs.object_id IS NOT NULL
      THEN
         dz_swagger3_loader.extrdocstyp(
             p_parent_id    => self.operation_id
            ,p_children_ids => dz_swagger3_object_vry(self.operation_externalDocs)
            ,p_versionid    => self.versionid
         );
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 20
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
      -- Step 30
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
      -- Step 40
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
      -- Step 50
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
      -- Step 60
      -- Load the callbacks
      --------------------------------------------------------------------------
      IF  self.operation_callbacks IS NOT NULL
      AND self.operation_callbacks.COUNT > 0
      THEN
         dz_swagger3_loader.pathtyp(
             p_parent_id    => self.operation_id
            ,p_children_ids => self.operation_callbacks
            ,p_versionid    => self.versionid
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Load the security
      --------------------------------------------------------------------------
      IF  self.operation_security IS NOT NULL
      AND self.operation_security.COUNT > 0
      THEN
         dz_swagger3_loader.securitySchemetyp(
             p_parent_id    => self.operation_id
            ,p_children_ids => self.operation_security 
            ,p_versionid    => self.versionid
         );
         
      END IF;
      
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
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_xorder              IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output                  CLOB;
      clb_operation_tags          CLOB;
      clb_operation_externalDocs  CLOB;
      clb_operation_parameters    CLOB;
      clb_operation_requestBody   CLOB;
      clb_operation_responses     CLOB;
      clb_operation_callbacks     CLOB;
      clb_operation_security      CLOB;
      clb_operation_servers       CLOB;
      str_identifier              VARCHAR2(255 Char);
      str_externaldoc_url         VARCHAR2(4000 Char);
      int_inject_operation_xorder INTEGER;
  
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Add operation tags array if populated 
      --------------------------------------------------------------------------
      IF  self.operation_tags IS NOT NULL
      AND self.operation_tags.COUNT > 0
      THEN
         SELECT
         JSON_ARRAYAGG(
            a.tagtyp.tag_name
            ORDER BY b.object_order
            RETURNING CLOB
         )
         INTO clb_operation_tags
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.operation_tags) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id;
 
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional externalDocs
      --------------------------------------------------------------------------
      IF  self.operation_externalDocs IS NOT NULL
      AND self.operation_externalDocs.object_id IS NOT NULL
      THEN
         BEGIN
            SELECT
             a.extrdocstyp.toJSON()
            ,a.extrdocstyp.externaldoc_url
            INTO
             clb_operation_externalDocs
            ,str_externaldoc_url
            FROM 
            dz_swagger3_xobjects a
            WHERE
                a.object_type_id = self.operation_externalDocs.object_type_id
            AND a.object_id      = self.operation_externalDocs.object_id;
            
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_operation_externalDocs := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;
         
         IF str_externaldoc_url IS NULL
         THEN
            clb_operation_externalDocs := NULL;
            
         END IF;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Generate parameters array
      --------------------------------------------------------------------------
      IF  self.operation_parameters IS NOT NULL 
      AND self.operation_parameters.COUNT > 0
      THEN
         SELECT
         JSON_ARRAYAGG(
            a.parametertyp.toJSON(
                p_force_inline     => p_force_inline
               ,p_short_id         => p_short_id
               ,p_identifier       => a.object_id
               ,p_short_identifier => a.short_id
               ,p_reference_count  => a.reference_count
            ) FORMAT JSON
            ORDER BY b.object_order
            RETURNING CLOB
         )
         INTO clb_operation_parameters
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.operation_parameters) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id
         WHERE
         COALESCE(a.parametertyp.parameter_list_hidden,'FALSE') <> 'TRUE'         ;

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Generate operation requestBody value
      --------------------------------------------------------------------------
      IF  self.operation_requestBody IS NOT NULL
      AND self.operation_requestBody.object_id IS NOT NULL
      THEN
         BEGIN
            SELECT
            a.requestbodytyp.toJSON(
                p_force_inline     => p_force_inline
               ,p_short_id         => p_short_id
               ,p_identifier       => a.object_id
               ,p_short_identifier => a.short_id
               ,p_reference_count  => a.reference_count
            )
            INTO clb_operation_requestBody
            FROM 
            dz_swagger3_xobjects a
            WHERE
                a.object_type_id = self.operation_requestBody.object_type_id
            AND a.object_id      = self.operation_requestBody.object_id;
            
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_operation_requestBody := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Generate operation responses map
      --------------------------------------------------------------------------
      IF  self.operation_responses IS NOT NULL 
      AND self.operation_responses.COUNT > 0
      THEN
         SELECT
         JSON_OBJECTAGG(
            b.object_key VALUE a.responsetyp.toJSON(
                p_force_inline     => p_force_inline
               ,p_short_id         => p_short_id
               ,p_identifier       => a.object_id
               ,p_short_identifier => a.short_id
               ,p_reference_count  => a.reference_count
            ) FORMAT JSON
            RETURNING CLOB
         )
         INTO clb_operation_responses
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.operation_responses) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id;
 
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Generate operation callbacks map
      --------------------------------------------------------------------------
      IF  self.operation_callbacks IS NOT NULL 
      AND self.operation_callbacks.COUNT > 0
      THEN
         SELECT
         JSON_OBJECTAGG(
            b.object_key VALUE json_object(
               a.pathtyp.path_endpoint VALUE a.pathtyp.toJSON(
                   p_force_inline     => p_force_inline
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_reference_count  => a.reference_count
               ) FORMAT JSON
               RETURNING CLOB
            )
            RETURNING CLOB
         )
         INTO clb_operation_callbacks
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.operation_callbacks) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id;

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Generate operation security req array
      --------------------------------------------------------------------------
      IF  self.operation_security IS NOT NULL 
      AND self.operation_security.COUNT > 0
      THEN
         SELECT
         JSON_ARRAYAGG(
            a.securityschemetyp.toJSON_req(
               p_oauth_scope_flows => b.object_attribute
            ) FORMAT JSON
            ORDER BY b.object_order
            RETURNING CLOB
         )
         INTO clb_operation_security
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.operation_security) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id;

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Gnerate operation server array
      --------------------------------------------------------------------------
      IF  self.operation_servers IS NOT NULL 
      AND self.operation_servers.COUNT > 0
      THEN
         SELECT
         JSON_ARRAYAGG(
            a.securityschemetyp.toJSON_req() FORMAT JSON
            ORDER BY b.object_order
            RETURNING CLOB
         )
         INTO clb_operation_servers
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.operation_servers) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id;
  
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Build the object
      --------------------------------------------------------------------------
      IF p_short_id = 'TRUE'
      THEN
         str_identifier := p_short_identifier;
         
      ELSE
         str_identifier := p_identifier;
      
      END IF;
      
      IF dz_swagger3_constants.c_inject_operation_xorder
      THEN
         int_inject_operation_xorder := 1;
         
      END IF;
      
      SELECT
      JSON_OBJECT(
          'tags'         VALUE clb_operation_tags         FORMAT JSON
         ,'summary'      VALUE self.operation_summary
         ,'description'  VALUE self.operation_description
         ,'externalDocs' VALUE clb_operation_externalDocs FORMAT JSON
         ,'operationId'  VALUE str_identifier
         ,'parameters'   VALUE clb_operation_parameters   FORMAT JSON
         ,'requestBody'  VALUE clb_operation_requestBody  FORMAT JSON
         ,'responses'    VALUE clb_operation_responses    FORMAT JSON
         ,'callbacks'    VALUE clb_operation_callbacks    FORMAT JSON
         ,'deprecated'   VALUE CASE
            WHEN LOWER(self.operation_deprecated) = 'true'
            THEN
               'true'
            WHEN LOWER(self.operation_deprecated) = 'false'
            THEN
               'false'
            ELSE
               NULL
            END FORMAT JSON
         ,'security'     VALUE clb_operation_security     FORMAT JSON
         ,'servers'      VALUE clb_operation_servers      FORMAT JSON
         ,'x-order'      VALUE CASE
          WHEN int_inject_operation_xorder = 1
          THEN
            p_xorder
          ELSE
            NULL
          END
         ABSENT ON NULL
         RETURNING CLOB
      )
      INTO clb_output
      FROM dual;

      --------------------------------------------------------------------------
      -- Step 110
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toJSON;
   
END;
/

--******************************--
PROMPT Types/DZ_SWAGGER3_PARAMETER_TYP.tpb 

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
      --dbms_output.put_line('parameter: ' || p_parameter_id);
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
         ,p_object_key     => a.example_name
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
       p_force_inline              IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id                  IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier                IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count           IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output             CLOB;
      str_identifier         VARCHAR2(4000 Char);
      clb_parameter_schema   CLOB;
      clb_parameter_examples CLOB;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Add the ref object
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
         
         SELECT
         JSON_OBJECT(
            '$ref' VALUE '#/components/parameters/' || str_identifier
         )
         INTO clb_output
         FROM dual;
      
      ELSE
      --------------------------------------------------------------------------
      -- Step 30
      -- Add optional schema attribute
      --------------------------------------------------------------------------
         IF self.parameter_schema IS NOT NULL
         THEN
            BEGIN
               SELECT
               a.schematyp.toJSON(
                   p_force_inline     => p_force_inline
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_reference_count  => a.reference_count
               )
               INTO clb_parameter_schema
               FROM
               dz_swagger3_xobjects a
               WHERE
                   a.object_type_id = self.parameter_schema.object_type_id
               AND a.object_id      = self.parameter_schema.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_parameter_schema := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;

         END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Add optional variables map
      --------------------------------------------------------------------------
         IF  self.parameter_examples IS NOT NULL 
         AND self.parameter_examples.COUNT > 0
         THEN
            SELECT
            JSON_OBJECTAGG(
               b.object_key VALUE a.exampletyp.toJSON(
                   p_force_inline     => p_force_inline
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_reference_count  => a.reference_count
               ) FORMAT JSON
               RETURNING CLOB
            )
            INTO clb_parameter_examples
            FROM
            dz_swagger3_xobjects a
            JOIN
            TABLE(self.parameter_examples) b
            ON
                a.object_type_id = b.object_type_id
            AND a.object_id      = b.object_id
            ORDER BY b.object_order;
 
         END IF;
         
      --------------------------------------------------------------------------
      -- Step 50
      -- Build the object
      --------------------------------------------------------------------------
         IF self.parameter_example_string IS NOT NULL
         THEN 
            SELECT
            JSON_OBJECT(
                'name'            VALUE self.parameter_name
               ,'in'              VALUE self.parameter_in
               ,'description'     VALUE self.parameter_description
               ,'required'        VALUE CASE
                  WHEN LOWER(self.parameter_required) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_required) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'deprecated'      VALUE CASE
                  WHEN LOWER(self.parameter_deprecated) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_deprecated) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'allowEmptyValue' VALUE CASE
                  WHEN LOWER(self.parameter_allowEmptyValue) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_allowEmptyValue) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'style'           VALUE self.parameter_style
               ,'explode'         VALUE CASE
                  WHEN LOWER(self.parameter_explode) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_explode) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'allowReserved'   VALUE CASE
                  WHEN LOWER(self.parameter_allowReserved) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_allowReserved) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'schema'          VALUE clb_parameter_schema       FORMAT JSON
               ,'example'         VALUE self.parameter_example_string
               ABSENT ON NULL
               RETURNING CLOB
            )
            INTO clb_output
            FROM dual;
            
         ELSIF self.parameter_example_number IS NOT NULL
         THEN
            SELECT
            JSON_OBJECT(
                'name'            VALUE self.parameter_name
               ,'in'              VALUE self.parameter_in
               ,'description'     VALUE self.parameter_description
               ,'required'        VALUE CASE
                  WHEN LOWER(self.parameter_required) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_required) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'deprecated'      VALUE CASE
                  WHEN LOWER(self.parameter_deprecated) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_deprecated) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'allowEmptyValue' VALUE CASE
                  WHEN LOWER(self.parameter_allowEmptyValue) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_allowEmptyValue) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'style'           VALUE self.parameter_style
               ,'explode'         VALUE CASE
                  WHEN LOWER(self.parameter_explode) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_explode) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'allowReserved'   VALUE CASE
                  WHEN LOWER(self.parameter_allowReserved) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_allowReserved) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'schema'          VALUE clb_parameter_schema       FORMAT JSON
               ,'example'         VALUE self.parameter_example_number
               ABSENT ON NULL
               RETURNING CLOB
            )
            INTO clb_output
            FROM dual;
            
         ELSE
            SELECT
            JSON_OBJECT(
                'name'            VALUE self.parameter_name
               ,'in'              VALUE self.parameter_in
               ,'description'     VALUE self.parameter_description
               ,'required'        VALUE CASE
                  WHEN LOWER(self.parameter_required) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_required) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'deprecated'      VALUE CASE
                  WHEN LOWER(self.parameter_deprecated) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_deprecated) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'allowEmptyValue' VALUE CASE
                  WHEN LOWER(self.parameter_allowEmptyValue) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_allowEmptyValue) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'style'           VALUE self.parameter_style
               ,'explode'         VALUE CASE
                  WHEN LOWER(self.parameter_explode) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_explode) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'allowReserved'   VALUE CASE
                  WHEN LOWER(self.parameter_allowReserved) = 'true'
                  THEN
                     'true'
                  WHEN LOWER(self.parameter_allowReserved) = 'false'
                  THEN
                     'false'
                  ELSE
                     NULL
                  END FORMAT JSON
               ,'schema'          VALUE clb_parameter_schema       FORMAT JSON
               ,'examples'        VALUE clb_parameter_examples     FORMAT JSON
               ABSENT ON NULL
               RETURNING CLOB
            )
            INTO clb_output
            FROM dual;
            
         END IF;
         
      END IF;
  
      --------------------------------------------------------------------------
      -- Step 60
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
END;
/

--******************************--
PROMPT Types/DZ_SWAGGER3_PATH_TYP.tpb 

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
      --dbms_output.put_line('path: ' || p_path_id);
      self.versionid := p_versionid;

      --------------------------------------------------------------------------
      -- Step 20
      -- Fetch component items
      --------------------------------------------------------------------------
      BEGIN
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
               ,p_object_order   => a.path_get_operation_order
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
               ,p_object_order   => a.path_put_operation_order
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
               ,p_object_order   => a.path_post_operation_order
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
               ,p_object_order   => a.path_delete_operation_order
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
               ,p_object_order   => a.path_options_operation_order
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
               ,p_object_order   => a.path_head_operation_order
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
               ,p_object_order   => a.path_patch_operation_order
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
               ,p_object_order   => a.path_trace_operation_order
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
         
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RAISE_APPLICATION_ERROR(
                -20001
               ,'path not found for path_id = ' || p_path_id || ' versionid ' || p_versionid
            );
            
         WHEN OTHERS
         THEN
            RAISE;
            
      END;

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
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
      ,p_xorder              IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output                 CLOB;
      clb_path_get_operation     CLOB;
      clb_path_put_operation     CLOB;      
      clb_path_post_operation    CLOB;
      clb_path_delete_operation  CLOB;
      clb_path_options_operation CLOB;
      clb_path_head_operation    CLOB;
      clb_path_patch_operation   CLOB;
      clb_path_trace_operation   CLOB;
      clb_path_servers           CLOB;
      clb_path_parameters        CLOB;
      str_identifier             VARCHAR2(4000 Char);
      int_inject_path_xorder     INTEGER;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------

      --------------------------------------------------------------------------
      -- Step 20
      -- Add the ref object for callbacks
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
         
         SELECT
         JSON_OBJECT(
            '$ref' VALUE '#/components/callbacks/' || str_identifier
         )
         INTO clb_output
         FROM dual;
      
      ELSE
      --------------------------------------------------------------------------
      -- Step 30
      -- Add get operation
      --------------------------------------------------------------------------
         IF  self.path_get_operation IS NOT NULL
         AND self.path_get_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT 
               a.operationtyp.toJSON( 
                   p_force_inline     => p_force_inline
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_xorder           => self.path_get_operation.object_order
               )
               INTO clb_path_get_operation
               FROM 
               dz_swagger3_xobjects a 
               WHERE 
                   a.object_type_id = self.path_get_operation.object_type_id
               AND a.object_id      = self.path_get_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_path_get_operation := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE_APPLICATION_ERROR(
                      -20001
                     ,SQLERRM || self.path_get_operation.object_id
                  );
                  
            END;

         END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Add put operation
      --------------------------------------------------------------------------
         IF  self.path_put_operation IS NOT NULL
         AND self.path_put_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT 
               a.operationtyp.toJSON( 
                   p_force_inline     => p_force_inline 
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_xorder           => self.path_put_operation.object_order
               )
               INTO clb_path_put_operation
               FROM 
               dz_swagger3_xobjects a 
               WHERE
                   a.object_type_id = self.path_put_operation.object_type_id
               AND a.object_id      = self.path_put_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_path_put_operation := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;

         END IF;

      --------------------------------------------------------------------------
      -- Step 50
      -- Add post operation
      --------------------------------------------------------------------------
         IF  self.path_post_operation IS NOT NULL
         AND self.path_post_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT 
               a.operationtyp.toJSON( 
                   p_force_inline     => p_force_inline 
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_xorder           => self.path_post_operation.object_order
               )
               INTO clb_path_post_operation
               FROM 
               dz_swagger3_xobjects a 
               WHERE
                   a.object_type_id = self.path_post_operation.object_type_id
               AND a.object_id      = self.path_post_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_path_post_operation := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;

         END IF;

      --------------------------------------------------------------------------
      -- Step 60
      -- Add delete operation
      --------------------------------------------------------------------------
         IF  self.path_delete_operation IS NOT NULL
         AND self.path_delete_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT 
               a.operationtyp.toJSON( 
                   p_force_inline     => p_force_inline 
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_xorder           => self.path_delete_operation.object_order
               )
               INTO clb_path_delete_operation
               FROM 
               dz_swagger3_xobjects a 
               WHERE
                   a.object_type_id = self.path_delete_operation.object_type_id
               AND a.object_id      = self.path_delete_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_path_delete_operation := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Add options operation
      --------------------------------------------------------------------------
         IF  self.path_options_operation IS NOT NULL
         AND self.path_options_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT 
               a.operationtyp.toJSON( 
                   p_force_inline     => p_force_inline 
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_xorder           => self.path_options_operation.object_order
               )
               INTO clb_path_options_operation
               FROM 
               dz_swagger3_xobjects a 
               WHERE
                   a.object_type_id = self.path_options_operation.object_type_id
               AND a.object_id      = self.path_options_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_path_options_operation := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Add head operation
      --------------------------------------------------------------------------
         IF  self.path_head_operation IS NOT NULL
         AND self.path_head_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT 
               a.operationtyp.toJSON( 
                   p_force_inline     => p_force_inline 
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_xorder           => self.path_head_operation.object_order
               )
               INTO clb_path_head_operation
               FROM 
               dz_swagger3_xobjects a 
               WHERE
                   a.object_type_id = self.path_head_operation.object_type_id
               AND a.object_id      = self.path_head_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_path_head_operation := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 90
      -- Add patch operation
      --------------------------------------------------------------------------
         IF  self.path_patch_operation IS NOT NULL
         AND self.path_patch_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT 
               a.operationtyp.toJSON( 
                   p_force_inline     => p_force_inline 
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_xorder           => self.path_patch_operation.object_order
               )
               INTO clb_path_patch_operation
               FROM 
               dz_swagger3_xobjects a 
               WHERE
                   a.object_type_id = self.path_patch_operation.object_type_id
               AND a.object_id      = self.path_patch_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_path_patch_operation := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Add trace operation
      --------------------------------------------------------------------------
         IF  self.path_trace_operation IS NOT NULL
         AND self.path_trace_operation.object_id IS NOT NULL
         THEN
            BEGIN
               SELECT 
               a.operationtyp.toJSON( 
                   p_force_inline     => p_force_inline 
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_xorder           => self.path_trace_operation.object_order
               )
               INTO clb_path_trace_operation
               FROM 
               dz_swagger3_xobjects a 
               WHERE
                   a.object_type_id = self.path_trace_operation.object_type_id
               AND a.object_id      = self.path_trace_operation.object_id;
               
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  clb_path_trace_operation := NULL;
                  
               WHEN OTHERS
               THEN
                  RAISE;
                  
            END;

         END IF;

      --------------------------------------------------------------------------
      -- Step 110
      -- Add servers
      --------------------------------------------------------------------------
         IF  self.path_servers IS NOT NULL 
         AND self.path_servers.COUNT > 0
         THEN
            SELECT
            JSON_ARRAYAGG(
               a.servertyp.toJSON() FORMAT JSON
               ORDER BY b.object_order
               RETURNING CLOB
            )
            INTO clb_path_servers
            FROM
            dz_swagger3_xobjects a
            JOIN
            TABLE(self.path_servers) b
            ON
                a.object_type_id = b.object_type_id
            AND a.object_id      = b.object_id;
            
         END IF;

      --------------------------------------------------------------------------
      -- Step 120
      -- Add parameters
      --------------------------------------------------------------------------
         IF  self.path_parameters IS NOT NULL 
         AND self.path_parameters.COUNT > 0
         THEN
            SELECT
            JSON_ARRAYAGG(
               a.parametertyp.toJSON(
                   p_force_inline     => p_force_inline
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_reference_count  => a.reference_count
               ) FORMAT JSON
               ORDER BY b.object_order
               RETURNING CLOB
            )
            INTO clb_path_parameters
            FROM
            dz_swagger3_xobjects a
            JOIN
            TABLE(self.path_parameters) b
            ON
                a.object_type_id = b.object_type_id
            AND a.object_id      = b.object_id
            WHERE
            COALESCE(a.parametertyp.parameter_list_hidden,'FALSE') <> 'TRUE';
            
         END IF;
         
      --------------------------------------------------------------------------
      -- Step 130
      -- Add the left bracket
      --------------------------------------------------------------------------
         IF dz_swagger3_constants.c_inject_path_xorder
         THEN
            int_inject_path_xorder := 1;
            
         END IF;
         
         SELECT
         JSON_OBJECT(
             'summary'      VALUE self.path_summary
            ,'description'  VALUE self.path_description
            ,'get'          VALUE clb_path_get_operation     FORMAT JSON
            ,'put'          VALUE clb_path_put_operation     FORMAT JSON     
            ,'post'         VALUE clb_path_post_operation    FORMAT JSON
            ,'delete'       VALUE clb_path_delete_operation  FORMAT JSON
            ,'options'      VALUE clb_path_options_operation FORMAT JSON
            ,'head'         VALUE clb_path_head_operation    FORMAT JSON
            ,'patch'        VALUE clb_path_patch_operation   FORMAT JSON
            ,'trace'        VALUE clb_path_trace_operation   FORMAT JSON
            ,'servers'      VALUE clb_path_servers           FORMAT JSON
            ,'parameters'   VALUE clb_path_parameters        FORMAT JSON
            ,'x-order'      VALUE CASE
             WHEN int_inject_path_xorder = 1
             THEN
               p_xorder
             ELSE
               NULL
             END
            ABSENT ON NULL
            RETURNING CLOB
         )
         INTO clb_output
         FROM dual;

      END IF;

      --------------------------------------------------------------------------
      -- Step 140
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
END;
/

--******************************--
PROMPT Types/DZ_SWAGGER3_REQUESTBODY_TYP.tpb 

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
      IF  self.requestBody_content IS NOT NULL
      AND self.requestBody_content.COUNT > 0
      AND self.requestBody_content(1).object_subtype = 'emulated'
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
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output              CLOB;
      str_identifier          VARCHAR2(255 Char);
      clb_requestbody_content CLOB;
      
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
         
         SELECT
         JSON_OBJECT(
            '$ref' VALUE '#/components/requestBodies/' || str_identifier
         )
         INTO clb_output
         FROM dual;
         
      ELSE         
      --------------------------------------------------------------------------
      -- Step 30
      -- Add requestbody content
      --------------------------------------------------------------------------
         IF  self.requestbody_content IS NOT NULL 
         AND self.requestbody_content.COUNT > 0
         THEN 
            SELECT
            JSON_OBJECTAGG(
               b.object_key VALUE a.mediatyp.toJSON(
                   p_force_inline   => p_force_inline
                  ,p_short_id       => p_short_id
               ) FORMAT JSON
               RETURNING CLOB
            )
            INTO clb_requestbody_content
            FROM
            dz_swagger3_xobjects a
            JOIN
            TABLE(self.requestbody_content) b
            ON
                a.object_type_id = b.object_type_id
            AND a.object_id      = b.object_id
            ORDER BY b.object_order; 

         END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Build the output object
      --------------------------------------------------------------------------
         SELECT
         JSON_OBJECT(
             'description'  VALUE self.requestbody_description
            ,'content'      VALUE clb_requestbody_content      FORMAT JSON
            ,'required'     VALUE CASE
               WHEN LOWER(self.requestbody_required) = 'true'
               THEN
                  'true'
               WHEN LOWER(self.requestbody_required) = 'false'
               THEN
                  'false'
               ELSE
                  NULL
               END FORMAT JSON
            ABSENT ON NULL
            RETURNING CLOB
         )
         INTO clb_output
         FROM dual;
 
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
END;
/

--******************************--
PROMPT Types/DZ_SWAGGER3_RESPONSE_TYP.tpb 

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
          p_object_id          => a.header_id
         ,p_object_type_id     => 'headertyp'
         ,p_object_key         => a.header_name
         ,p_object_order       => a.header_order
      )
      BULK COLLECT INTO self.response_headers
      FROM
      dz_swagger3_parent_header_map a
      WHERE
          a.versionid  = p_versionid
      AND a.parent_id  = p_response_id;
      
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
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output                 CLOB;
      str_identifier             VARCHAR2(255 Char);
      clb_response_headers       CLOB;
      clb_response_content       CLOB;
      clb_response_links         CLOB;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Add the inline ref object
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
         
         SELECT
         JSON_OBJECT(
            '$ref' VALUE '#/components/responses/' || str_identifier
         )
         INTO clb_output
         FROM dual;
      
      ELSE
      --------------------------------------------------------------------------
      -- Step 30
      -- Generate optional headers
      --------------------------------------------------------------------------
         IF  self.response_headers IS NOT NULL 
         AND self.response_headers.COUNT > 0
         THEN
            SELECT
            JSON_OBJECTAGG(
               b.object_key VALUE a.headertyp.toJSON(
                   p_force_inline     => p_force_inline
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_reference_count  => a.reference_count
               ) FORMAT JSON
               RETURNING CLOB
            )
            INTO clb_response_headers
            FROM
            dz_swagger3_xobjects a
            JOIN
            TABLE(self.response_headers) b
            ON
                a.object_type_id = b.object_type_id
            AND a.object_id      = b.object_id;
            
         END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Gnerate optional content objects
      --------------------------------------------------------------------------
         IF  self.response_content IS NOT NULL 
         AND self.response_content.COUNT > 0
         THEN
            SELECT
            JSON_OBJECTAGG(
               b.object_key VALUE a.mediatyp.toJSON(
                   p_force_inline   => p_force_inline
                  ,p_short_id       => p_short_id
               ) FORMAT JSON
               RETURNING CLOB
            )
            INTO clb_response_content
            FROM
            dz_swagger3_xobjects a
            JOIN
            TABLE(self.response_content) b
            ON
                a.object_type_id = b.object_type_id
            AND a.object_id      = b.object_id;
            
         END IF;

      --------------------------------------------------------------------------
      -- Step 50
      -- Generate optional links map
      --------------------------------------------------------------------------
         IF  self.response_links IS NOT NULL 
         AND self.response_links.COUNT > 0
         THEN
            SELECT
            JSON_OBJECTAGG(
               b.object_key VALUE a.linktyp.toJSON(
                   p_force_inline     => p_force_inline
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_reference_count  => a.reference_count
               ) FORMAT JSON
               RETURNING CLOB
            )
            INTO clb_response_links
            FROM
            dz_swagger3_xobjects a
            JOIN
            TABLE(self.response_links) b
            ON
                a.object_type_id = b.object_type_id
            AND a.object_id      = b.object_id;
            
         END IF;

      --------------------------------------------------------------------------
      -- Step 60
      -- Build the object
      --------------------------------------------------------------------------
         SELECT
         JSON_OBJECT(
             'description'  VALUE self.response_description
            ,'headers'      VALUE clb_response_headers      FORMAT JSON
            ,'content'      VALUE clb_response_content      FORMAT JSON
            ,'links'        VALUE clb_response_links        FORMAT JSON
            ABSENT ON NULL
            RETURNING CLOB
         )
         INTO clb_output
         FROM dual;
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toJSON;

END;
/

--******************************--
PROMPT Types/DZ_SWAGGER3_SCHEMA_TYP.tpb 

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
      --dbms_output.put_line('schema: ' || p_schema_id);
      self.versionid := p_versionid;

      --------------------------------------------------------------------------
      -- Step 20
      -- Load the easy items using constructor
      --------------------------------------------------------------------------
      BEGIN
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
         
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RAISE_APPLICATION_ERROR(
                -20001
               ,'Model missing schema record for schema_id ' || p_schema_id || ' in version ' || p_versionid
            );
         
         WHEN OTHERS
         THEN
            RAISE;
            
      END;

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
      AND a.enum_string IS NOT NULL
      ORDER BY
      a.enum_order;
      
      SELECT
      a.enum_number
      BULK COLLECT INTO
      self.schema_enum_number
      FROM
      dz_swagger3_schema_enum_map a
      WHERE
          a.versionid = p_versionid
      AND a.schema_id = p_schema_id
      AND a.enum_number IS NOT NULL
      ORDER BY
      a.enum_order;

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
      AND a.enum_string IS NOT NULL
      ORDER BY
      a.enum_order;
      
      SELECT
      a.enum_number
      BULK COLLECT INTO
      self.schema_enum_number
      FROM
      dz_swagger3_schema_enum_map a
      WHERE
          a.versionid = p_versionid
      AND a.schema_id = str_inner_schema_id
      AND a.enum_number IS NOT NULL
      ORDER BY
      a.enum_order;
   
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
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
      ,p_jsonschema          IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_xorder              IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB
   AS
      str_jsonschema                 VARCHAR2(4000 Char) := UPPER(p_jsonschema);
      clb_output                     CLOB;
      clb_combine_schemas            CLOB;
      int_combine_schemas            PLS_INTEGER;
      clb_schema_externalDocs        CLOB;
      clb_schema_items_schema        CLOB;
      clb_schema_properties          CLOB;
      clb_schema_prop_required       CLOB;
      clb_xml                        CLOB;
      str_object_key                 VARCHAR2(255 Char);
      str_identifier                 VARCHAR2(255 Char);
      int_schema_enum_string         PLS_INTEGER;
      int_schema_enum_number         PLS_INTEGER;
      boo_is_not                     BOOLEAN;
      int_inject_property_xorder     INTEGER;
      
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
      -- Branch if needed for combines
      --------------------------------------------------------------------------
      IF  self.combine_schemas IS NOT NULL
      AND self.combine_schemas.COUNT > 0
      THEN
         boo_is_not := FALSE;
         
         SELECT
          a.cnt
         ,a.object_key
         INTO
          int_combine_schemas
         ,str_object_key 
         FROM (
            SELECT
             ROW_NUMBER() OVER(ORDER BY bb.object_order) AS rown
            ,COUNT(*)     OVER(ORDER BY bb.object_order) AS cnt
            ,bb.object_key
            FROM
            dz_swagger3_xobjects aa
            JOIN
            TABLE(self.combine_schemas) bb
            ON
                aa.object_type_id = bb.object_type_id
            AND aa.object_id      = bb.object_id
         ) a
         WHERE
         a.rown = 1; 
          
         IF int_combine_schemas = 1 AND str_object_key = 'not'
         THEN
            boo_is_not := TRUE;
         
         END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- branch for the NOT scenario
      --------------------------------------------------------------------------
         IF boo_is_not
         THEN
            SELECT
            a.schematyp.toJSON(
                p_force_inline     => p_force_inline
               ,p_short_id         => p_short_id
               ,p_identifier       => a.object_id
               ,p_short_identifier => a.short_id
               ,p_reference_count  => a.reference_count
               ,p_jsonschema       => str_jsonschema
            )
            INTO clb_combine_schemas
            FROM
            dz_swagger3_xobjects a
            JOIN
            TABLE(self.combine_schemas) b
            ON
                a.object_type_id = b.object_type_id
            AND a.object_id      = b.object_id; 
         
            SELECT
            JSON_OBJECT(
                'type'         VALUE self.schema_type
               ,'not'          VALUE clb_combine_schemas FORMAT JSON 
               ABSENT ON NULL
               RETURNING CLOB
            )
            INTO clb_output
            FROM dual;
         
         ELSE
            SELECT
            JSON_ARRAYAGG(
               a.schematyp.toJSON(
                   p_force_inline     => p_force_inline
                  ,p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
                  ,p_reference_count  => a.reference_count
                  ,p_jsonschema       => str_jsonschema
               ) FORMAT JSON
               ORDER BY b.object_order
               RETURNING CLOB
            )
            INTO clb_combine_schemas
            FROM
            dz_swagger3_xobjects a
            JOIN
            TABLE(self.combine_schemas) b
            ON
                a.object_type_id = b.object_type_id
            AND a.object_id      = b.object_id; 
            
            SELECT
            JSON_OBJECT(
                'type'         VALUE self.schema_type
               ,str_object_key VALUE clb_combine_schemas FORMAT JSON 
               ABSENT ON NULL
               RETURNING CLOB
            )
            INTO clb_output
            FROM dual;
   
         END IF;
      
      ELSE
      --------------------------------------------------------------------------
      -- Step 40
      -- Branch if needed for ref
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
            
            SELECT
            JSON_OBJECT(
               '$ref' VALUE '#/components/schemas/' || str_identifier
            )
            INTO clb_output
            FROM dual;
            
         ELSE
      --------------------------------------------------------------------------
      -- Step 50
      -- Add optional externalDocs
      --------------------------------------------------------------------------
            IF  self.schema_externalDocs IS NOT NULL
            AND str_jsonschema <> 'TRUE'
            THEN
               BEGIN
                  SELECT
                  a.extrdocstyp.toJSON()
                  INTO clb_schema_externalDocs
                  FROM
                  dz_swagger3_xobjects a
                  WHERE
                      a.object_type_id = self.schema_externalDocs.object_type_id 
                  AND a.object_id      = self.schema_externalDocs.object_id;
               
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     clb_schema_externalDocs := NULL;
                     
                  WHEN OTHERS
                  THEN
                     RAISE;
                     
               END;

            END IF;
            
      --------------------------------------------------------------------------
      -- Step 60
      -- Add schema items
      --------------------------------------------------------------------------
            IF self.schema_items_schema IS NOT NULL
            THEN
               BEGIN
                  SELECT
                  a.schematyp.toJSON(
                      p_force_inline     => p_force_inline
                     ,p_short_id         => p_short_id
                     ,p_identifier       => a.object_id
                     ,p_short_identifier => a.short_id
                     ,p_reference_count  => a.reference_count
                     ,p_jsonschema       => str_jsonschema
                  )
                  INTO clb_schema_items_schema
                  FROM
                  dz_swagger3_xobjects a
                  WHERE
                      a.object_type_id = self.schema_items_schema.object_type_id
                  AND a.object_id      = self.schema_items_schema.object_id;
               
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     clb_schema_items_schema := NULL;
                     
                  WHEN OTHERS
                  THEN
                     RAISE;
                     
               END;

            END IF;
            
      --------------------------------------------------------------------------
      -- Step 70
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
                  clb_xml := dz_swagger3_xml_typ(
                      p_xml_name       => self.xml_name
                     ,p_xml_namespace  => self.xml_namespace
                     ,p_xml_prefix     => self.xml_prefix
                     ,p_xml_attribute  => self.xml_attribute
                     ,p_xml_wrapped    => self.xml_wrapped
                  ).toJSON();
                  
               END IF;
               
            END IF;
            
      -------------------------------------------------------------------------
      -- Step 80
      -- Add parameters
      -------------------------------------------------------------------------
            IF  self.schema_properties IS NOT NULL 
            AND self.schema_properties.COUNT > 0
            THEN
               SELECT
               JSON_OBJECTAGG(
                  b.object_key VALUE a.schematyp.toJSON(
                      p_force_inline     => p_force_inline
                     ,p_short_id         => p_short_id
                     ,p_identifier       => a.object_id
                     ,p_short_identifier => a.short_id
                     ,p_reference_count  => a.reference_count
                     ,p_jsonschema       => str_jsonschema
                     ,p_xorder           => b.object_order
                  ) FORMAT JSON
                  RETURNING CLOB
               )
               INTO clb_schema_properties
               FROM
               dz_swagger3_xobjects a
               JOIN
               TABLE(self.schema_properties) b
               ON
                   a.object_type_id = b.object_type_id
               AND a.object_id      = b.object_id
               WHERE
               COALESCE(a.schematyp.property_list_hidden,'FALSE') <> 'TRUE'; 
               
               SELECT
               JSON_ARRAYAGG(
                  b.object_key
                  ORDER BY b.object_order
                  RETURNING CLOB
               )
               INTO clb_schema_prop_required
               FROM
               dz_swagger3_xobjects a
               JOIN
               TABLE(self.schema_properties) b
               ON
                   a.object_type_id = b.object_type_id
               AND a.object_id      = b.object_id
               WHERE
               COALESCE(a.schematyp.property_list_hidden,'FALSE') <> 'TRUE'
               AND b.object_required = 'TRUE'; 

            END IF;
       
      --------------------------------------------------------------------------
      -- Step 90
      -- Create the object
      --------------------------------------------------------------------------
            IF self.schema_enum_string IS NOT NULL
            THEN
               int_schema_enum_string := self.schema_enum_string.COUNT;
            
            ELSE
               int_schema_enum_string := 0;
               
            END IF;
            
            IF self.schema_enum_number IS NOT NULL
            THEN
               int_schema_enum_number := self.schema_enum_number.COUNT;
               
            ELSE
               int_schema_enum_number := 0;

            END IF;
            
            IF dz_swagger3_constants.c_inject_property_xorder
            THEN
               int_inject_property_xorder := 1;
               
            END IF;

            IF  self.schema_example_string IS NOT NULL
            AND str_jsonschema <> 'TRUE'
            THEN
               IF  str_jsonschema = 'TRUE'
               AND self.schema_nullable = 'TRUE'
               THEN
                  SELECT
                  JSON_OBJECT(
                      '$schema'       VALUE CASE
                        WHEN LOWER(self.inject_jsonschema) = 'true'
                        THEN
                           'http://json-schema.org/draft-04/schema#'
                        ELSE
                           NULL
                        END
                     ,'type'          VALUE JSON_ARRAY(self.schema_type,'null') FORMAT JSON
                     ,'title'         VALUE self.schema_title
                     ,'description'   VALUE self.schema_description
                     ,'format'        VALUE self.schema_format
                     ,'enum'          VALUE CASE
                        WHEN int_schema_enum_string > 0
                        THEN
                           (SELECT JSON_ARRAYAGG(column_value) FROM TABLE(self.schema_enum_string))
                        WHEN int_schema_enum_number > 0
                        THEN
                           (SELECT JSON_ARRAYAGG(column_value) FROM TABLE(self.schema_enum_number))
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'nullable'      VALUE CASE
                        WHEN self.schema_nullable IS NOT NULL
                        AND str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_nullable) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_nullable) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'discriminator' VALUE CASE
                        WHEN self.schema_discriminator IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           self.schema_discriminator
                        ELSE
                           NULL
                        END
                     ,'readOnly'      VALUE CASE
                        WHEN self.schema_readOnly IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_readOnly) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_readOnly) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'writeOnly'     VALUE CASE
                        WHEN self.schema_writeOnly IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_writeOnly) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_writeOnly) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'maxItems'      VALUE self.schema_maxItems
                     ,'minItems'      VALUE self.schema_minItems
                     ,'maxProperties' VALUE self.schema_maxProperties
                     ,'minProperties' VALUE self.schema_minProperties
                     ,'externalDocs'  VALUE clb_schema_externalDocs   FORMAT JSON
                     ,'example'       VALUE self.schema_example_string
                     ,'deprecated'    VALUE CASE
                        WHEN LOWER(self.schema_deprecated) = 'true'
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           'true'
                        WHEN LOWER(self.schema_deprecated) = 'false'
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           'false'
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'items'         VALUE clb_schema_items_schema   FORMAT JSON
                     ,'xml'           VALUE clb_xml                   FORMAT JSON
                     ,'properties'    VALUE clb_schema_properties     FORMAT JSON
                     ,'required'      VALUE clb_schema_prop_required  FORMAT JSON
                     ,'x-order'       VALUE CASE
                      WHEN int_inject_property_xorder = 1
                      THEN
                        p_xorder
                      ELSE
                        NULL
                      END
                     ABSENT ON NULL
                     RETURNING CLOB
                  )
                  INTO clb_output
                  FROM dual;
                  
               ELSE
                  SELECT
                  JSON_OBJECT(
                      '$schema'       VALUE CASE
                        WHEN LOWER(self.inject_jsonschema) = 'true'
                        THEN
                           'http://json-schema.org/draft-04/schema#'
                        ELSE
                           NULL
                        END
                     ,'type'          VALUE self.schema_type
                     ,'title'         VALUE self.schema_title
                     ,'description'   VALUE self.schema_description
                     ,'format'        VALUE self.schema_format
                     ,'enum'          VALUE CASE
                        WHEN int_schema_enum_string > 0
                        THEN
                           (SELECT JSON_ARRAYAGG(column_value) FROM TABLE(self.schema_enum_string))
                        WHEN int_schema_enum_number > 0
                        THEN
                           (SELECT JSON_ARRAYAGG(column_value) FROM TABLE(self.schema_enum_number))
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'nullable'      VALUE CASE
                        WHEN self.schema_nullable IS NOT NULL
                        AND str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_nullable) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_nullable) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'discriminator' VALUE CASE
                        WHEN self.schema_discriminator IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           self.schema_discriminator
                        ELSE
                           NULL
                        END
                     ,'readOnly'      VALUE CASE
                        WHEN self.schema_readOnly IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_readOnly) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_readOnly) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'writeOnly'     VALUE CASE
                        WHEN self.schema_writeOnly IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_writeOnly) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_writeOnly) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'maxItems'      VALUE self.schema_maxItems
                     ,'minItems'      VALUE self.schema_minItems
                     ,'maxProperties' VALUE self.schema_maxProperties
                     ,'minProperties' VALUE self.schema_minProperties
                     ,'externalDocs'  VALUE clb_schema_externalDocs   FORMAT JSON
                     ,'example'       VALUE self.schema_example_string
                     ,'deprecated'    VALUE CASE
                        WHEN LOWER(self.schema_deprecated) = 'true'
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           'true'
                        WHEN LOWER(self.schema_deprecated) = 'false'
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           'false'
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'items'         VALUE clb_schema_items_schema   FORMAT JSON
                     ,'xml'           VALUE clb_xml                   FORMAT JSON
                     ,'properties'    VALUE clb_schema_properties     FORMAT JSON
                     ,'required'      VALUE clb_schema_prop_required  FORMAT JSON
                     ,'x-order'       VALUE CASE
                      WHEN int_inject_property_xorder = 1
                      THEN
                        p_xorder
                      ELSE
                        NULL
                      END
                     ABSENT ON NULL
                     RETURNING CLOB
                  )
                  INTO clb_output
                  FROM dual;
               
               END IF;
               
            ELSIF self.schema_example_number IS NOT NULL
            AND   str_jsonschema <> 'TRUE'
            THEN
            
               IF  str_jsonschema = 'TRUE'
               AND self.schema_nullable = 'TRUE'
               THEN
                  SELECT
                  JSON_OBJECT(
                      '$schema'       VALUE CASE
                        WHEN LOWER(self.inject_jsonschema) = 'true'
                        THEN
                           'http://json-schema.org/draft-04/schema#'
                        ELSE
                           NULL
                        END
                     ,'type'          VALUE JSON_ARRAY(self.schema_type,'null') FORMAT JSON
                     ,'title'         VALUE self.schema_title
                     ,'description'   VALUE self.schema_description
                     ,'format'        VALUE self.schema_format
                     ,'enum'          VALUE CASE
                        WHEN int_schema_enum_string > 0
                        THEN
                           (SELECT JSON_ARRAYAGG(column_value) FROM TABLE(self.schema_enum_string))
                        WHEN int_schema_enum_number > 0
                        THEN
                           (SELECT JSON_ARRAYAGG(column_value) FROM TABLE(self.schema_enum_number))
                        ELSE
                           NULL
                        END
                     ,'nullable'      VALUE CASE
                        WHEN self.schema_nullable IS NOT NULL
                        AND str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_nullable) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_nullable) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'discriminator' VALUE CASE
                        WHEN self.schema_discriminator IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           self.schema_discriminator
                        ELSE
                           NULL
                        END
                     ,'readOnly'      VALUE CASE
                        WHEN self.schema_readOnly IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_readOnly) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_readOnly) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'writeOnly'     VALUE CASE
                        WHEN self.schema_writeOnly IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_writeOnly) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_writeOnly) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'maxItems'      VALUE self.schema_maxItems
                     ,'minItems'      VALUE self.schema_minItems
                     ,'maxProperties' VALUE self.schema_maxProperties
                     ,'minProperties' VALUE self.schema_minProperties
                     ,'externalDocs'  VALUE clb_schema_externalDocs   FORMAT JSON
                     ,'example'       VALUE self.schema_example_number
                     ,'deprecated'    VALUE CASE
                        WHEN LOWER(self.schema_deprecated) = 'true'
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           'true'
                        WHEN LOWER(self.schema_deprecated) = 'false'
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           'false'
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'items'         VALUE clb_schema_items_schema   FORMAT JSON
                     ,'xml'           VALUE clb_xml                   FORMAT JSON
                     ,'properties'    VALUE clb_schema_properties     FORMAT JSON
                     ,'required'      VALUE clb_schema_prop_required  FORMAT JSON
                     ,'x-order'       VALUE CASE
                      WHEN int_inject_property_xorder = 1
                      THEN
                        p_xorder
                      ELSE
                        NULL
                      END
                     ABSENT ON NULL
                     RETURNING CLOB
                  )
                  INTO clb_output
                  FROM dual;
                  
               ELSE
                  SELECT
                  JSON_OBJECT(
                      '$schema'       VALUE CASE
                        WHEN LOWER(self.inject_jsonschema) = 'true'
                        THEN
                           'http://json-schema.org/draft-04/schema#'
                        ELSE
                           NULL
                        END
                     ,'type'          VALUE self.schema_type
                     ,'title'         VALUE self.schema_title
                     ,'description'   VALUE self.schema_description
                     ,'format'        VALUE self.schema_format
                     ,'enum'          VALUE CASE
                        WHEN int_schema_enum_string > 0
                        THEN
                           (SELECT JSON_ARRAYAGG(column_value) FROM TABLE(self.schema_enum_string))
                        WHEN int_schema_enum_number > 0
                        THEN
                           (SELECT JSON_ARRAYAGG(column_value) FROM TABLE(self.schema_enum_number))
                        ELSE
                           NULL
                        END
                     ,'nullable'      VALUE CASE
                        WHEN self.schema_nullable IS NOT NULL
                        AND str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_nullable) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_nullable) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'discriminator' VALUE CASE
                        WHEN self.schema_discriminator IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           self.schema_discriminator
                        ELSE
                           NULL
                        END
                     ,'readOnly'      VALUE CASE
                        WHEN self.schema_readOnly IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_readOnly) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_readOnly) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'writeOnly'     VALUE CASE
                        WHEN self.schema_writeOnly IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_writeOnly) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_writeOnly) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'maxItems'      VALUE self.schema_maxItems
                     ,'minItems'      VALUE self.schema_minItems
                     ,'maxProperties' VALUE self.schema_maxProperties
                     ,'minProperties' VALUE self.schema_minProperties
                     ,'externalDocs'  VALUE clb_schema_externalDocs   FORMAT JSON
                     ,'example'       VALUE self.schema_example_number
                     ,'deprecated'    VALUE CASE
                        WHEN LOWER(self.schema_deprecated) = 'true'
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           'true'
                        WHEN LOWER(self.schema_deprecated) = 'false'
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           'false'
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'items'         VALUE clb_schema_items_schema   FORMAT JSON
                     ,'xml'           VALUE clb_xml                   FORMAT JSON
                     ,'properties'    VALUE clb_schema_properties     FORMAT JSON
                     ,'required'      VALUE clb_schema_prop_required  FORMAT JSON
                     ,'x-order'       VALUE CASE
                      WHEN int_inject_property_xorder = 1
                      THEN
                        p_xorder
                      ELSE
                        NULL
                      END
                     ABSENT ON NULL
                     RETURNING CLOB
                  )
                  INTO clb_output
                  FROM dual;
               
               END IF;
               
            ELSE
               IF  str_jsonschema = 'TRUE'
               AND self.schema_nullable = 'TRUE'
               THEN
                  SELECT
                  JSON_OBJECT(
                      '$schema'       VALUE CASE
                        WHEN LOWER(self.inject_jsonschema) = 'true'
                        THEN
                           'http://json-schema.org/draft-04/schema#'
                        ELSE
                           NULL
                        END
                     ,'type'          VALUE JSON_ARRAY(self.schema_type,'null') FORMAT JSON
                     ,'title'         VALUE self.schema_title
                     ,'description'   VALUE self.schema_description
                     ,'format'        VALUE self.schema_format
                     ,'enum'          VALUE CASE
                        WHEN int_schema_enum_string > 0
                        THEN
                           (SELECT JSON_ARRAYAGG(column_value) FROM TABLE(self.schema_enum_string))
                        WHEN int_schema_enum_number > 0
                        THEN
                           (SELECT JSON_ARRAYAGG(column_value) FROM TABLE(self.schema_enum_number))
                        ELSE
                           NULL
                        END
                     ,'nullable'      VALUE CASE
                        WHEN self.schema_nullable IS NOT NULL
                        AND str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_nullable) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_nullable) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'discriminator' VALUE CASE
                        WHEN self.schema_discriminator IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           self.schema_discriminator
                        ELSE
                           NULL
                        END
                     ,'readOnly'      VALUE CASE
                        WHEN self.schema_readOnly IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_readOnly) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_readOnly) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'writeOnly'     VALUE CASE
                        WHEN self.schema_writeOnly IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_writeOnly) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_writeOnly) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'maxItems'      VALUE self.schema_maxItems
                     ,'minItems'      VALUE self.schema_minItems
                     ,'maxProperties' VALUE self.schema_maxProperties
                     ,'minProperties' VALUE self.schema_minProperties
                     ,'externalDocs'  VALUE clb_schema_externalDocs   FORMAT JSON
                     ,'deprecated'    VALUE CASE
                        WHEN LOWER(self.schema_deprecated) = 'true'
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           'true'
                        WHEN LOWER(self.schema_deprecated) = 'false'
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           'false'
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'items'         VALUE clb_schema_items_schema   FORMAT JSON
                     ,'xml'           VALUE clb_xml                   FORMAT JSON
                     ,'properties'    VALUE clb_schema_properties     FORMAT JSON
                     ,'required'      VALUE clb_schema_prop_required  FORMAT JSON
                     ,'x-order'       VALUE CASE
                      WHEN int_inject_property_xorder = 1
                      THEN
                        p_xorder
                      ELSE
                        NULL
                      END
                     ABSENT ON NULL
                     RETURNING CLOB
                  )
                  INTO clb_output
                  FROM dual;
            
               ELSE
                  SELECT
                  JSON_OBJECT(
                      '$schema'       VALUE CASE
                        WHEN LOWER(self.inject_jsonschema) = 'true'
                        THEN
                           'http://json-schema.org/draft-04/schema#'
                        ELSE
                           NULL
                        END
                     ,'type'          VALUE self.schema_type
                     ,'title'         VALUE self.schema_title
                     ,'description'   VALUE self.schema_description
                     ,'format'        VALUE self.schema_format
                     ,'enum'          VALUE CASE
                        WHEN int_schema_enum_string > 0
                        THEN
                           (SELECT JSON_ARRAYAGG(column_value) FROM TABLE(self.schema_enum_string))
                        WHEN int_schema_enum_number > 0
                        THEN
                           (SELECT JSON_ARRAYAGG(column_value) FROM TABLE(self.schema_enum_number))
                        ELSE
                           NULL
                        END
                     ,'nullable'      VALUE CASE
                        WHEN self.schema_nullable IS NOT NULL
                        AND str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_nullable) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_nullable) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'discriminator' VALUE CASE
                        WHEN self.schema_discriminator IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           self.schema_discriminator
                        ELSE
                           NULL
                        END
                     ,'readOnly'      VALUE CASE
                        WHEN self.schema_readOnly IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_readOnly) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_readOnly) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'writeOnly'     VALUE CASE
                        WHEN self.schema_writeOnly IS NOT NULL
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           CASE
                           WHEN LOWER(self.schema_writeOnly) = 'true'
                           THEN
                              'true'
                           WHEN LOWER(self.schema_writeOnly) = 'false'
                           THEN
                              'false'
                           ELSE
                              NULL
                           END
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'maxItems'      VALUE self.schema_maxItems
                     ,'minItems'      VALUE self.schema_minItems
                     ,'maxProperties' VALUE self.schema_maxProperties
                     ,'minProperties' VALUE self.schema_minProperties
                     ,'externalDocs'  VALUE clb_schema_externalDocs   FORMAT JSON
                     ,'deprecated'    VALUE CASE
                        WHEN LOWER(self.schema_deprecated) = 'true'
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           'true'
                        WHEN LOWER(self.schema_deprecated) = 'false'
                        AND  str_jsonschema <> 'TRUE'
                        THEN
                           'false'
                        ELSE
                           NULL
                        END FORMAT JSON
                     ,'items'         VALUE clb_schema_items_schema   FORMAT JSON
                     ,'xml'           VALUE clb_xml                   FORMAT JSON
                     ,'properties'    VALUE clb_schema_properties     FORMAT JSON
                     ,'required'      VALUE clb_schema_prop_required  FORMAT JSON
                     ,'x-order'       VALUE CASE
                      WHEN int_inject_property_xorder = 1
                      THEN
                        p_xorder
                      ELSE
                        NULL
                      END
                     ABSENT ON NULL
                     RETURNING CLOB
                  )
                  INTO clb_output
                  FROM dual;
                  
               END IF;
               
            END IF;
            
         END IF;
            
      END IF;

      --------------------------------------------------------------------------
      -- Step 100
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toMockJSON(
       p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output                     CLOB;
      str_identifier                 VARCHAR2(255 Char);
      str_combine_type               VARCHAR2(255 Char);
      str_combine_target             VARCHAR2(255 Char);
      
      FUNCTION esc(
         pin IN VARCHAR2
      ) RETURN VARCHAR2
      AS
         pout VARCHAR2(32000);
      BEGIN
         SELECT
         JSON_OBJECT('a' VALUE pin)
         INTO pout
         FROM dual;
         
         pout := REGEXP_REPLACE(pout,'^\{"a"\:','');
         pout := REGEXP_REPLACE(pout,'\}$','');
         
         RETURN pout;
         
      END esc;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Determine item identifier
      --------------------------------------------------------------------------
      IF p_short_id = 'TRUE'
      THEN
         str_identifier := p_short_identifier;
         
      ELSE
         str_identifier := p_identifier;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Branch if needed for combines
      --------------------------------------------------------------------------
      IF  self.combine_schemas IS NOT NULL
      AND self.combine_schemas.COUNT > 0
      THEN
         SELECT
          a.object_type_id
         ,a.object_id
         INTO
          str_combine_type
         ,str_combine_target
         FROM (
            SELECT
             bb.object_type_id
            ,bb.object_id
            FROM
            dz_swagger3_xobjects aa
            JOIN
            TABLE(self.combine_schemas) bb
            ON
                aa.object_type_id = bb.object_type_id
            AND aa.object_id      = bb.object_id
            ORDER BY
            bb.object_order 
         ) a
         WHERE
         ROWNUM <= 1;
         
         SELECT
         a.schematyp.toMockJSON(
             p_short_id         => p_short_id
            ,p_identifier       => a.object_id
            ,p_short_identifier => a.short_id
         )
         INTO clb_output
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = str_combine_type
         AND a.object_id = str_combine_target;
            
      ELSE
         IF self.schema_category = 'scalar'
         THEN
            IF self.schema_type IN ('number','integer')
            THEN
               IF self.schema_example_number IS NULL
               THEN
                  clb_output := '0';
                   
               ELSE
                  clb_output := TO_CHAR(self.schema_example_number);
                  
               END IF;
            
            ELSE
               IF self.schema_example_string IS NULL
               THEN
                  IF self.schema_format = 'date'
                  THEN
                     clb_output := esc('2013-12-25');
                     
                  ELSE
                     clb_output := esc('string');
                  
                  END IF;
                   
               ELSE
                  clb_output :=  esc(self.schema_example_string);
                  
               END IF;
            
            END IF;
         
         ELSIF self.schema_category = 'array'
         THEN
            SELECT
            JSON_ARRAY(
               a.schematyp.toMockJSON(
                   p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
               ) FORMAT JSON
               RETURNING CLOB
            )
            INTO clb_output
            FROM
            dz_swagger3_xobjects a
            WHERE
                a.object_type_id = self.schema_items_schema.object_type_id
            AND a.object_id      = self.schema_items_schema.object_id;
            
         ELSIF self.schema_category IN ('combine','object')
         THEN
            SELECT
            JSON_OBJECTAGG(
               b.object_key VALUE a.schematyp.toMockJSON(
                   p_short_id         => p_short_id
                  ,p_identifier       => a.object_id
                  ,p_short_identifier => a.short_id
               ) FORMAT JSON
               RETURNING CLOB
            )
            INTO clb_output
            FROM
            dz_swagger3_xobjects a
            JOIN
            TABLE(self.schema_properties) b
            ON
                a.object_type_id = b.object_type_id
            AND a.object_id      = b.object_id
            WHERE
            COALESCE(a.schematyp.property_list_hidden,'FALSE') <> 'TRUE';
         
         END IF;
         
      END IF;
      
      RETURN clb_output;
      
   END toMockJSON;
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toMockXML(
       p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_temp                        CLOB;
      clb_output                      CLOB;
      str_identifier                  VARCHAR2(255 Char);
      str_combine_type                VARCHAR2(255 Char);
      str_combine_target              VARCHAR2(255 Char);
      ary_ids                         dz_swagger3_string_vry;
      ary_keys                        dz_swagger3_string_vry;
      ary_clob                        dz_swagger3_clob_vry;
      str_object_name_start           VARCHAR2(255 Char);
      str_object_name_stop            VARCHAR2(255 Char);
      ary_self_schema_type            dz_swagger3_string_vry;
      ary_self_xml_name               dz_swagger3_string_vry;
      ary_self_xml_wrapped            dz_swagger3_string_vry;
      ary_self_xml_namespace          dz_swagger3_string_vry;
      ary_self_xml_prefix             dz_swagger3_string_vry;
      ary_self_xml_attribute          dz_swagger3_string_vry;
      ary_self_properties             dz_swagger3_object_vry;
      str_child_key                   VARCHAR2(4000);
      str_child_xml_name              VARCHAR2(4000);
      str_child_xml_namespace         VARCHAR2(4000);
      str_child_xml_prefix            VARCHAR2(4000);
      str_child_xml_attribute         VARCHAR2(4000);
      str_child_schema_example_str    VARCHAR2(4000);
      str_child_schema_example_num    VARCHAR2(4000);
      str_child_attributes            VARCHAR2(32000);
      
   BEGIN
   
      IF p_short_id = 'TRUE'
      THEN
         str_identifier := p_short_identifier;
         
      ELSE
         str_identifier := p_identifier;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Branch if needed for combines
      --------------------------------------------------------------------------
      IF  self.combine_schemas IS NOT NULL
      AND self.combine_schemas.COUNT > 0
      THEN
         SELECT
          a.object_type_id
         ,a.object_id
         INTO
          str_combine_type
         ,str_combine_target
         FROM (
            SELECT
             bb.object_type_id
            ,bb.object_id
            FROM
            dz_swagger3_xobjects aa
            JOIN
            TABLE(self.combine_schemas) bb
            ON
                aa.object_type_id = bb.object_type_id
            AND aa.object_id      = bb.object_id
            ORDER BY
            bb.object_order 
         ) a
         WHERE
         ROWNUM <= 1;
         
         SELECT
         a.schematyp.toMockXML(
             p_short_id         => p_short_id
            ,p_identifier       => a.object_id
            ,p_short_identifier => a.short_id
         )
         INTO clb_output
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = str_combine_type
         AND a.object_id = str_combine_target;
      
      ELSE
         IF self.schema_category = 'scalar'
         THEN
            IF self.schema_type IN ('number','integer')
            THEN
               IF self.schema_example_number IS NULL
               THEN
                  clb_output := '0';
                   
               ELSE
                  clb_output := TO_CHAR(self.schema_example_number);
                  
               END IF;
            
            ELSE
               IF self.schema_example_string IS NULL
               THEN
                  IF self.schema_format = 'date'
                  THEN
                     clb_output := '2013-12-25';
                     
                  ELSE
                     clb_output := 'string';
                  
                  END IF;
                   
               ELSE
                  clb_output :=  DBMS_XMLGEN.CONVERT(self.schema_example_string);
                  
               END IF;
            
            END IF;
         
         ELSIF self.schema_category = 'array'
         THEN
            SELECT
             a.schematyp.xml_name
            ,a.schematyp.xml_prefix
            ,a.schematyp.xml_namespace
            ,a.schematyp.toMockXML(
                p_short_id         => p_short_id
               ,p_identifier       => a.object_id
               ,p_short_identifier => a.short_id
            )
            ,a.schematyp.schema_properties
            INTO 
             str_child_xml_name
            ,str_child_xml_prefix
            ,str_child_xml_namespace
            ,clb_temp
            ,ary_self_properties
            FROM
            dz_swagger3_xobjects a
            WHERE
                a.object_type_id = self.schema_items_schema.object_type_id
            AND a.object_id      = self.schema_items_schema.object_id;
            
            IF str_child_xml_name IS NOT NULL
            THEN
               str_object_name_start := str_child_xml_name;
               str_object_name_stop := str_child_xml_name;
               
            ELSE
               str_object_name_start := self.schema_items_schema.object_id;
               str_object_name_stop  := self.schema_items_schema.object_id;

            END IF;
            
            IF str_child_xml_prefix IS NOT NULL
            THEN
               str_object_name_start := str_child_xml_prefix || ':' || str_object_name_start;
               str_object_name_stop  := str_child_xml_prefix || ':' || str_object_name_stop;
               
            END IF;
            
            IF str_child_xml_namespace IS NOT NULL
            THEN
               IF str_child_xml_prefix IS NOT NULL
               THEN
                  str_object_name_start := str_object_name_start 
                     || ' xmlns:' || str_child_xml_prefix
                     || '="' || str_child_xml_namespace || '"';
                     
               ELSE
                  str_object_name_start := str_object_name_start 
                     || ' xmlns="' || str_child_xml_namespace || '"';
                     
               END IF;
               
            END IF;
            
            str_child_attributes := '';
            FOR j IN 1 .. ary_self_properties.COUNT
            LOOP
               SELECT
                a.object_id
               ,a.schematyp.xml_name
               ,a.schematyp.xml_prefix
               ,a.schematyp.xml_attribute
               ,a.schematyp.schema_example_string
               ,TO_CHAR(a.schematyp.schema_example_number)
               INTO
                str_child_key
               ,str_child_xml_name
               ,str_child_xml_prefix
               ,str_child_xml_attribute
               ,str_child_schema_example_str
               ,str_child_schema_example_num
               FROM
               dz_swagger3_xobjects a
               WHERE
                   a.object_type_id = 'schematyp'
               AND a.object_id = ary_self_properties(j).object_id;

               IF str_child_xml_attribute = 'TRUE'
               THEN               
                  IF str_child_xml_name IS NOT NULL
                  THEN
                     str_child_xml_name := str_child_xml_name;
                     
                  ELSE
                     str_child_xml_name := str_child_key;
                  
                  END IF;
                     
                  IF str_child_xml_prefix IS NOT NULL
                  THEN
                     str_child_xml_name := str_child_xml_prefix || ':' || str_child_xml_name;
                     
                  END IF;
                  
                  str_child_attributes := str_child_attributes 
                     || ' ' || str_child_xml_name || '="'
                     || DBMS_XMLGEN.CONVERT(
                        COALESCE(str_child_schema_example_str,str_child_schema_example_num,'string')
                     ) || '"';
                     
               END IF;
               
            END LOOP;
            
            clb_output := '<'  || str_object_name_start || str_child_attributes || '>'
                       || clb_temp
                       || '</' || str_object_name_stop || '>';
            
         ELSIF self.schema_category IN ('combine','object')
         THEN
            SELECT
             b.object_id
            ,b.object_key
            ,a.schematyp.toMockXML(
                p_short_id         => p_short_id
               ,p_identifier       => a.object_id
               ,p_short_identifier => a.short_id
            )
            ,a.schematyp.schema_type
            ,a.schematyp.xml_name
            ,a.schematyp.xml_wrapped
            ,a.schematyp.xml_namespace
            ,a.schematyp.xml_prefix
            ,a.schematyp.xml_attribute
            BULK COLLECT INTO
             ary_ids
            ,ary_keys
            ,ary_clob
            ,ary_self_schema_type
            ,ary_self_xml_name
            ,ary_self_xml_wrapped
            ,ary_self_xml_namespace
            ,ary_self_xml_prefix
            ,ary_self_xml_attribute
            FROM
            dz_swagger3_xobjects a
            JOIN
            TABLE(self.schema_properties) b
            ON
                a.object_type_id = b.object_type_id
            AND a.object_id      = b.object_id
            WHERE
            COALESCE(a.schematyp.property_list_hidden,'FALSE') <> 'TRUE';

            FOR i IN 1 .. ary_keys.COUNT
            LOOP
               IF ary_self_xml_attribute(i) IS NULL
               OR ary_self_xml_attribute(i) != 'TRUE'
               THEN
                  IF  ary_self_schema_type(i) = 'array'
                  AND ary_self_xml_name(i) IS NOT NULL
                  AND ary_self_xml_wrapped(i) = 'TRUE'
                  THEN
                     str_object_name_start := ary_self_xml_name(i);
                     str_object_name_stop  := ary_self_xml_name(i);
                     
                  ELSE
                     str_object_name_start := ary_keys(i);
                     str_object_name_stop  := ary_keys(i);
                                 
                  END IF;
                  
                  IF ary_self_xml_prefix(i) IS NOT NULL
                  THEN
                     str_object_name_start := ary_self_xml_prefix(i) || ':' || str_object_name_start;
                     str_object_name_stop  := ary_self_xml_prefix(i) || ':' || str_object_name_stop;
                     
                  END IF;
                  
                  IF ary_self_xml_namespace(i) IS NOT NULL
                  THEN
                     IF ary_self_xml_prefix(i) IS NOT NULL
                     THEN
                        str_object_name_start := str_object_name_start 
                           || ' xmlns:' || ary_self_xml_prefix(i)
                           || '="' || ary_self_xml_namespace(i) || '"';
                           
                     ELSE
                        str_object_name_start := str_object_name_start 
                           || ' xmlns="' || ary_self_xml_namespace(i) || '"';
                           
                     END IF;
                     
                  END IF;
                  
                  SELECT
                  a.schematyp.schema_properties
                  INTO
                  ary_self_properties
                  FROM
                  dz_swagger3_xobjects a
                  WHERE
                      a.object_id = ary_ids(i)
                  AND a.object_type_id = 'schematyp';
                  
                  str_child_attributes := '';
                  FOR j IN 1 .. ary_self_properties.COUNT
                  LOOP
                     SELECT
                      a.object_id
                     ,a.schematyp.xml_name
                     ,a.schematyp.xml_prefix
                     ,a.schematyp.xml_attribute
                     ,a.schematyp.schema_example_string
                     ,TO_CHAR(a.schematyp.schema_example_number)
                     INTO
                      str_child_key
                     ,str_child_xml_name
                     ,str_child_xml_prefix
                     ,str_child_xml_attribute
                     ,str_child_schema_example_str
                     ,str_child_schema_example_num
                     FROM
                     dz_swagger3_xobjects a
                     WHERE
                         a.object_type_id = 'schematyp'
                     AND a.object_id = ary_self_properties(j).object_id;

                     IF str_child_xml_attribute = 'TRUE'
                     THEN
                     
                        IF str_child_xml_name IS NOT NULL
                        THEN
                           str_child_xml_name := str_child_xml_name;
                           
                        ELSE
                           str_child_xml_name := str_child_key;
                        
                        END IF;
                           
                        IF str_child_xml_prefix IS NOT NULL
                        THEN
                           str_child_xml_name := str_child_xml_prefix || ':' || str_child_xml_name;
                           
                        END IF;
                        
                        str_child_attributes := str_child_attributes 
                           || ' ' || str_child_xml_name || '="'
                           || DBMS_XMLGEN.CONVERT(
                              COALESCE(str_child_schema_example_str,str_child_schema_example_num,'string')
                           ) || '"';
                           
                     END IF;
                     
                  END LOOP;

                  clb_output := clb_output
                             || '<'  || str_object_name_start || str_child_attributes || '>'
                             || ary_clob(i)
                             || '</' || str_object_name_stop || '>';
                             
               END IF;

            END LOOP;

         END IF;
         
      END IF;
      
      RETURN clb_output;
      
   END toMockXML;
   
END;
/

--******************************--
PROMPT Types/DZ_SWAGGER3_SECURITYSCHEME_TYP.tpb 

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
      ,p_securityscheme_fullname IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
   AS
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Set up the object
      --------------------------------------------------------------------------
      self.versionid               := p_versionid;
      self.securityscheme_fullname := p_securityscheme_fullname;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Load the sercurity scheme basics
      --------------------------------------------------------------------------
      SELECT
       a.securityscheme_id
      ,a.securityscheme_type
      ,a.securityscheme_description
      ,a.securityscheme_name
      ,a.securityscheme_in
      ,a.securityscheme_scheme
      ,a.securityscheme_bearerFormat
      ,CASE
       WHEN a.oauth_flow_implicit IS NOT NULL
       THEN
         dz_swagger3_oauth_flow_typ(
             p_oauth_flow_id => a.oauth_flow_implicit 
            ,p_versionid     => p_versionid
         )
       ELSE
         NULL
       END
      ,CASE
       WHEN a.oauth_flow_password IS NOT NULL
       THEN
         dz_swagger3_oauth_flow_typ(
             p_oauth_flow_id => a.oauth_flow_password
            ,p_versionid     => p_versionid
         )
       ELSE
         NULL
       END
      ,CASE
       WHEN a.oauth_flow_clientCredentials IS NOT NULL
       THEN
         dz_swagger3_oauth_flow_typ(
             p_oauth_flow_id => a.oauth_flow_clientCredentials 
            ,p_versionid     => p_versionid
         )
       ELSE
         NULL
       END
      ,CASE
       WHEN a.oauth_flow_authorizationCode IS NOT NULL
       THEN
         dz_swagger3_oauth_flow_typ(
             p_oauth_flow_id => a.oauth_flow_authorizationCode 
            ,p_versionid     => p_versionid
         )
       ELSE
         NULL
       END
      ,a.securityscheme_openidcredents
      INTO
       self.securityscheme_id
      ,self.securityscheme_type
      ,self.securityscheme_description
      ,self.securityscheme_name
      ,self.securityscheme_in
      ,self.securityscheme_scheme
      ,self.securityscheme_bearerFormat
      ,self.oauth_flow_implicit 
      ,self.oauth_flow_password
      ,self.oauth_flow_clientCredentials
      ,self.oauth_flow_authorizationCode
      ,self.securityscheme_openIdConUrl 
      FROM
      dz_swagger3_securityScheme a
      WHERE
          a.versionid         = p_versionid
      AND a.securityscheme_id = p_securityscheme_id;

      --------------------------------------------------------------------------
      -- Step 30
      -- Return the completed object
      --------------------------------------------------------------------------
      RETURN; 
      
   END dz_swagger3_securityScheme_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON
   RETURN CLOB
   AS
      clb_output       CLOB;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the object
      --------------------------------------------------------------------------
      SELECT
      JSON_OBJECT(
          'type'             VALUE self.securityscheme_type
         ,'description'      VALUE self.securityscheme_description
         ,'name'             VALUE self.securityscheme_name
         ,'in'               VALUE self.securityscheme_in
         ,'scheme'           VALUE self.securityscheme_scheme
         ,'bearerFormat'     VALUE self.securityscheme_bearerFormat
         ,'flows'            VALUE CASE
            WHEN self.oauth_flow_implicit IS NOT NULL
            OR   self.oauth_flow_password IS NOT NULL
            OR   self.oauth_flow_clientCredentials IS NOT NULL
            OR   self.oauth_flow_authorizationCode IS NOT NULL
            THEN
               JSON_OBJECT(
                   'implicit'          VALUE CASE
                     WHEN self.oauth_flow_implicit IS NOT NULL
                     THEN
                        self.oauth_flow_implicit.toJSON()
                     ELSE
                        NULL
                     END FORMAT JSON
                  ,'password'          VALUE CASE
                     WHEN self.oauth_flow_password IS NOT NULL
                     THEN
                        self.oauth_flow_password.toJSON()
                     ELSE
                        NULL
                     END FORMAT JSON
                  ,'clientCredentials' VALUE CASE
                     WHEN self.oauth_flow_clientCredentials IS NOT NULL
                     THEN
                        self.oauth_flow_clientCredentials.toJSON()
                     ELSE
                        NULL
                     END FORMAT JSON
                  ,'authorizationCode' VALUE CASE
                     WHEN self.oauth_flow_authorizationCode IS NOT NULL
                     THEN
                        self.oauth_flow_authorizationCode.toJSON()
                     ELSE
                        NULL
                     END FORMAT JSON
                  ABSENT ON NULL
                  RETURNING CLOB
               )
            ELSE
               NULL
            END
         ,'openIdConnectUrl' VALUE self.securityscheme_openIdConUrl 
         ABSENT ON NULL
         RETURNING CLOB
      )
      INTO clb_output
      FROM dual;

      --------------------------------------------------------------------------
      -- Step 30
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON_req(
      p_oauth_scope_flows        IN  VARCHAR2  DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output    CLOB;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the object
      --------------------------------------------------------------------------
      SELECT
      JSON_OBJECT(
          self.securityScheme_fullname VALUE CASE
            WHEN self.securityScheme_type IN ('oauth2','openIdConnect')
            AND p_oauth_scope_flows IS NOT NULL
            THEN
               (
                  SELECT 
                  JSON_ARRAYAGG(column_value) 
                  FROM 
                  TABLE(dz_swagger3_util.gz_split(p_oauth_scope_flows,','))
               )
            ELSE
               '[]'
            END FORMAT JSON
         RETURNING CLOB
      )
      INTO clb_output
      FROM dual;

      --------------------------------------------------------------------------
      -- Step 30
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;
           
   END toJSON_req;
   
END;
/

--******************************--
PROMPT Types/DZ_SWAGGER3_SERVER_TYP.tpb 

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

      --------------------------------------------------------------------------
      -- Step 10 
      -- Initialize the object
      --------------------------------------------------------------------------
      self.versionid := p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 20 
      -- Load the parameter self and schema id
      --------------------------------------------------------------------------
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

      --------------------------------------------------------------------------
      -- Step 30 
      -- Load any server variables
      --------------------------------------------------------------------------
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
  
      --------------------------------------------------------------------------
      -- Step 40 
      -- Return the object
      --------------------------------------------------------------------------
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
   MEMBER FUNCTION toJSON
   RETURN CLOB
   AS
      clb_output       CLOB;
      clb_variables    CLOB;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Add optional variables map
      --------------------------------------------------------------------------
      IF  self.server_variables IS NOT NULL 
      AND self.server_variables.COUNT > 0
      THEN
         SELECT
         JSON_OBJECTAGG(
            b.object_key VALUE a.servervartyp.toJSON() FORMAT JSON
            RETURNING CLOB
         )
         INTO clb_variables
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.server_variables) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id;   
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Build the object
      --------------------------------------------------------------------------
      SELECT
      JSON_OBJECT(
          'url'          VALUE self.server_url
         ,'description'  VALUE self.server_description
         ,'variables'    VALUE clb_variables           FORMAT JSON
         ABSENT ON NULL
         RETURNING CLOB
      )
      INTO clb_output
      FROM dual;

      --------------------------------------------------------------------------
      -- Step 40
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toJSON;
   
END;
/

--******************************--
PROMPT Types/DZ_SWAGGER3_SERVER_VAR_TYP.tpb 

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

      --------------------------------------------------------------------------
      -- Step 10
      -- Initialize the object
      --------------------------------------------------------------------------
      self.versionid         := p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Pull the object information
      --------------------------------------------------------------------------
      SELECT
       a.server_var_id
      ,a.server_var_name
      ,dz_swagger3_util.gz_split(a.server_var_enum,',')
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
      
      --------------------------------------------------------------------------
      -- Step 100
      -- Return the completed object
      --------------------------------------------------------------------------
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
   MEMBER FUNCTION toJSON
   RETURN CLOB
   AS
      clb_output       CLOB;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the object
      --------------------------------------------------------------------------
      IF self.enum IS NOT NULL 
      AND  self.enum.COUNT > 0
      THEN
         SELECT
         JSON_OBJECT(
             'enum'         VALUE (SELECT JSON_ARRAYAGG(column_value) FROM TABLE(self.enum))
            ,'default'      VALUE self.default_value
            ,'description'  VALUE self.description
            ABSENT ON NULL
            RETURNING CLOB
         )
         INTO clb_output
         FROM dual;
         
      ELSE
         SELECT
         JSON_OBJECT(
             'default'      VALUE self.default_value
            ,'description'  VALUE self.description
            ABSENT ON NULL
            RETURNING CLOB
         )
         INTO clb_output
         FROM dual;

      END IF;

      --------------------------------------------------------------------------
      -- Step 30
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toJSON;

END;
/

--******************************--
PROMPT Types/DZ_SWAGGER3_TAG_TYP.tpb 

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
   
      --------------------------------------------------------------------------
      -- Step 10 
      -- Initialize the object
      --------------------------------------------------------------------------
      self.versionid := p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 20 
      -- Load the tag self and external doc id
      --------------------------------------------------------------------------
      BEGIN
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

      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RAISE_APPLICATION_ERROR(
                -20001
               ,'Model missing tag record for tag_id ' || p_tag_id || ' in version ' || p_versionid
            );
            
         WHEN OTHERS
         THEN
            RAISE;
      
      END;
      
      --------------------------------------------------------------------------
      -- Step 30 
      -- Return the object
      --------------------------------------------------------------------------
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
   MEMBER FUNCTION toJSON
   RETURN CLOB
   AS
      clb_output       CLOB;
      clb_extrdocstyp  CLOB;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Add optional externalDocs
      --------------------------------------------------------------------------
      IF self.tag_externalDocs IS NOT NULL
      THEN
         BEGIN
            SELECT
            a.extrdocstyp.toJSON()
            INTO clb_extrdocstyp
            FROM
            dz_swagger3_xobjects a
            WHERE
                a.object_type_id = self.tag_externalDocs.object_type_id
            AND a.object_id      = self.tag_externalDocs.object_id;
            
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_extrdocstyp := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Build the object
      --------------------------------------------------------------------------
      SELECT
      JSON_OBJECT(
          'name'         VALUE self.tag_name
         ,'description'  VALUE self.tag_description
         ,'externalDocs' VALUE clb_extrdocstyp        FORMAT JSON 
         ABSENT ON NULL
         RETURNING CLOB
      )
      INTO clb_output
      FROM dual;

      --------------------------------------------------------------------------
      -- Step 40
      -- Cough out the results
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toJSON;
   
END;
/

--******************************--
PROMPT Types/DZ_SWAGGER3_TYP.tpb 

CREATE OR REPLACE TYPE BODY dz_swagger3_typ
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_typ
   RETURN SELF AS RESULT
   AS
   BEGIN
      
      self.return_code := 0;
      RETURN;

   END dz_swagger3_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_typ(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2 DEFAULT NULL
      ,p_versionid           IN  VARCHAR2 DEFAULT NULL
   ) RETURN SELF AS RESULT
   AS
      str_doc_id          VARCHAR2(255 Char) := p_doc_id;
      str_group_id        VARCHAR2(255 Char) := p_group_id;
      str_versionid       VARCHAR2(40 Char)  := p_versionid;

   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      self.return_code := 0;
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
         
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            self.return_code := -1;
            self.status_message := 'doc id not found';
            RETURN;
            
         WHEN OTHERS
         THEN
            RAISE;
            
      END;
      
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
      SELECT
      dz_swagger3_object_typ(
          p_object_id        => a.securityScheme_id
         ,p_object_type_id   => 'securityschemetyp'
         ,p_object_key       => a.securityScheme_name
         ,p_object_attribute => a.oauth_flow_scopes
         ,p_object_order     => a.securityScheme_order
      )
      BULK COLLECT INTO self.security 
      FROM
      dz_swagger3_parent_secschm_map a
      WHERE
          a.versionid = str_versionid
      AND a.parent_id = str_doc_id;
      
      IF self.security.COUNT > 0
      THEN
         dz_swagger3_loader.securitySchemetyp(
             p_parent_id    => 'root'
            ,p_children_ids => self.security 
            ,p_versionid    => str_versionid
         );
         
      END IF;

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
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output              CLOB;
      clb_servers             CLOB;
      clb_paths               CLOB;
      clb_schemas             CLOB;
      clb_responses           CLOB;
      clb_parameters          CLOB;
      clb_examples            CLOB;
      clb_requestbodies       CLOB;
      clb_headers             CLOB;
      clb_securitySchemes     CLOB;
      clb_links               CLOB;
      clb_callbacks           CLOB;
      clb_security            CLOB;
      clb_tags                CLOB;
      clb_externalDocs        CLOB;
      
   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      IF self.return_code <> 0
      THEN
         SELECT
         JSON_OBJECT(
             'return_code'    VALUE self.return_code
            ,'status_message' VALUE self.status_message
            RETURNING CLOB
         )
         INTO clb_output
         FROM dual;
         
         RETURN clb_output;
      
      END IF;

      --------------------------------------------------------------------------
      -- Step 20
      -- Add servers
      --------------------------------------------------------------------------
      IF  self.servers IS NOT NULL 
      AND self.servers.COUNT > 0
      THEN
         SELECT 
         JSON_ARRAYAGG(
            a.servertyp.toJSON() FORMAT JSON
            ORDER BY b.object_order
            RETURNING CLOB
         )
         INTO clb_servers
         FROM
         dz_swagger3_xobjects a 
         JOIN 
         TABLE(self.servers) b 
         ON 
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 30
      -- Add paths
      --------------------------------------------------------------------------
      IF self.paths IS NOT NULL 
      OR self.paths.COUNT > 0
      THEN
         SELECT
         JSON_OBJECTAGG(
            b.object_key VALUE a.pathtyp.toJSON(
                p_force_inline   => p_force_inline
               ,p_short_id       => p_short_id
               ,p_xorder         => b.object_order
            ) FORMAT JSON
            RETURNING CLOB
         )
         INTO clb_paths 
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.paths) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Add schemas components map
      --------------------------------------------------------------------------
      IF p_force_inline = 'TRUE'
      OR self.paths IS NULL
      OR self.paths.COUNT = 0
      THEN
         NULL;

      ELSE
         SELECT
         JSON_OBJECTAGG(
            CASE 
            WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
            THEN 
               a.short_id 
            ELSE 
               a.object_id 
            END VALUE a.schematyp.toJSON( 
                p_force_inline   => 'FALSE'
               ,p_short_id       => p_short_id
            ) FORMAT JSON 
            RETURNING CLOB
         )
         INTO clb_schemas
         FROM 
         dz_swagger3_xobjects a 
         WHERE 
             a.object_type_id = 'schematyp'
         AND a.reference_count > 1 
         AND COALESCE(a.schematyp.property_list_hidden,'FALSE') <> 'TRUE'; 
         
         SELECT
         JSON_OBJECTAGG(
            CASE 
            WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
            THEN
               a.short_id
            ELSE
               a.object_id
            END VALUE a.responsetyp.toJSON(
                p_force_inline   => 'FALSE'
               ,p_short_id       => p_short_id
            ) FORMAT JSON
            RETURNING CLOB
         )
         INTO clb_responses
         FROM
         dz_swagger3_xobjects a
         WHERE 
             a.object_type_id = 'responsetyp'
         AND a.reference_count > 1;
         
         SELECT
         JSON_OBJECTAGG(
            CASE
            WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
            THEN
               a.short_id
            ELSE
               a.object_id
            END VALUE a.parametertyp.toJSON(
                p_force_inline   => 'FALSE'
               ,p_short_id       => p_short_id
            ) FORMAT JSON
            RETURNING CLOB
         )
         INTO clb_parameters 
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'parametertyp'
         AND a.reference_count > 1
         AND COALESCE(a.parametertyp.parameter_list_hidden,'FALSE') <> 'TRUE';
            
         SELECT
         JSON_OBJECTAGG(
            CASE
            WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
            THEN
               a.short_id
            ELSE
               a.object_id
            END VALUE a.exampletyp.toJSON( 
                p_force_inline   => 'FALSE'
               ,p_short_id       => p_short_id
            ) FORMAT JSON
            RETURNING CLOB
         )
         INTO clb_examples
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'exampletyp'
         AND a.reference_count > 1;
         
         SELECT
         JSON_OBJECTAGG(
            CASE
            WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
            THEN
               a.short_id
            ELSE
               a.object_id
            END VALUE a.requestbodytyp.toJSON(
                p_force_inline   => 'FALSE'
               ,p_short_id       => p_short_id
            ) FORMAT JSON
            RETURNING CLOB
         )
         INTO clb_requestbodies
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'requestbodytyp'
         AND a.reference_count > 1;

         SELECT
         JSON_OBJECTAGG(
            CASE
            WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
            THEN
               a.short_id
            ELSE
               a.object_id
            END VALUE a.headertyp.toJSON(
                p_force_inline   => 'FALSE'
               ,p_short_id       => p_short_id
            ) FORMAT JSON
            RETURNING CLOB
         )
         INTO clb_headers
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'headertyp'
         AND a.reference_count > 1;
            
         SELECT
         JSON_OBJECTAGG(
            a.securityschemetyp.securityscheme_fullname VALUE a.securityschemetyp.toJSON() FORMAT JSON
            RETURNING CLOB
         )
         INTO clb_securitySchemes
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'securityschemetyp';
            
         SELECT
         JSON_OBJECTAGG(
            CASE
            WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
            THEN
               a.short_id
            ELSE
               a.object_id
            END VALUE a.linktyp.toJSON(
                p_force_inline   => 'FALSE'
               ,p_short_id       => p_short_id
            ) FORMAT JSON
            RETURNING CLOB
         )
         INTO clb_links
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'linktyp'
         AND a.reference_count > 1;
            
         SELECT
         JSON_OBJECTAGG(
            CASE
            WHEN COALESCE(p_short_id,'FALSE') = 'TRUE'
            THEN
               a.short_id
            ELSE
               a.object_id
            END VALUE a.pathtyp.toJSON(
                p_force_inline   => 'FALSE'
               ,p_short_id       => p_short_id
            ) FORMAT JSON
            RETURNING CLOB
         )
         INTO clb_callbacks
         FROM
         dz_swagger3_xobjects a
         WHERE
             a.object_type_id = 'callbacktyp'
         AND a.reference_count > 1;
            
            
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Add security
      --------------------------------------------------------------------------
      IF  self.security IS NOT NULL 
      AND self.security.COUNT > 0
      THEN
         SELECT 
         JSON_ARRAYAGG(
            a.securityschemetyp.toJSON_req( 
               p_oauth_scope_flows => b.object_attribute
            ) FORMAT JSON
            ORDER BY b.object_order
            RETURNING CLOB
         )
         INTO clb_security
         FROM 
         dz_swagger3_xobjects a 
         JOIN 
         TABLE(self.security) b
         ON 
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id;

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Add tags
      --------------------------------------------------------------------------
      SELECT
      JSON_ARRAYAGG(
         a.tagtyp.toJSON() FORMAT JSON
         ORDER BY a.object_id
         RETURNING CLOB
      )
      INTO clb_tags
      FROM
      dz_swagger3_xobjects a 
      WHERE 
          a.object_type_id = 'tagtyp'
      AND (
            a.tagtyp.tag_description IS NOT NULL
         OR a.tagtyp.tag_externaldocs IS NOT NULL 
      );
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Add externalDocs
      --------------------------------------------------------------------------
      IF self.externalDocs IS NOT NULL
      THEN
         BEGIN
            SELECT
            a.extrdocstyp.toJSON() 
            INTO clb_externalDocs
            FROM
            dz_swagger3_xobjects a
            WHERE 
                a.object_type_id = self.externalDocs.object_type_id 
            AND a.object_id      = self.externalDocs.object_id; 
         
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               clb_externalDocs := NULL;
               
            WHEN OTHERS
            THEN
               RAISE;
               
         END;

      END IF;


      --------------------------------------------------------------------------
      -- Step 80
      -- Build the object
      --------------------------------------------------------------------------
      SELECT
      JSON_OBJECT(
          'openapi'       VALUE dz_swagger3_constants.c_openapi_version
         ,'info'          VALUE self.info.toJSON(
            p_force_inline => p_force_inline
          )                                               FORMAT JSON
         ,'servers'       VALUE clb_servers               FORMAT JSON
         ,'paths'         VALUE clb_paths                 FORMAT JSON
         ,'components'    VALUE JSON_OBJECT(
             'schemas'         VALUE clb_schemas         FORMAT JSON
            ,'responses'       VALUE clb_responses       FORMAT JSON
            ,'parameters'      VALUE clb_parameters      FORMAT JSON
            ,'examples'        VALUE clb_examples        FORMAT JSON
            ,'requestBodies'   VALUE clb_requestBodies   FORMAT JSON
            ,'headers'         VALUE clb_headers         FORMAT JSON
            ,'securitySchemes' VALUE clb_securitySchemes FORMAT JSON
            ,'links'           VALUE clb_links           FORMAT JSON
            ,'callbacks'       VALUE clb_callbacks       FORMAT JSON
            ABSENT ON NULL
            RETURNING CLOB
          )
         ,'security'      VALUE clb_security              FORMAT JSON
         ,'tags'          VALUE clb_tags                  FORMAT JSON
         ,'externalDocs'  VALUE clb_externalDocs          FORMAT JSON
         ABSENT ON NULL
         RETURNING CLOB        
      )
      INTO clb_output
      FROM dual;

      --------------------------------------------------------------------------
      -- Step 90
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output    CLOB;
      
   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------

      --------------------------------------------------------------------------
      -- Step 20
      -- Convert the JSON result into YAML
      --------------------------------------------------------------------------
      dz_swagger3_util.json2yaml(
          p_input            => self.toJSON(
             p_force_inline        => p_force_inline
            ,p_short_id            => p_short_id
          )
         ,p_output           => clb_output
      );
      
      --------------------------------------------------------------------------
      -- Step 200
      -- Cough it out
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toYAML;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION validity(
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_options             IN  VARCHAR2  DEFAULT NULL
   ) RETURN CLOB
   AS
      clb_output CLOB;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      IF self.return_code <> 0
      THEN
         SELECT
         JSON_OBJECT(
             'valid'          VALUE NULL
            ,'return_code'    VALUE self.return_code
            ,'status_message' VALUE self.status_message
            RETURNING CLOB
         )
         INTO clb_output
         FROM dual;
         
         RETURN clb_output;
      
      END IF;
   
      RETURN dz_swagger3_validate.request_validate(
          p_doc => self.toJSON(
             p_force_inline => p_force_inline
            ,p_short_id     => p_short_id
          )
         ,p_options => p_options
      );
      
   END validity;

END;
/

--******************************--
PROMPT Types/DZ_SWAGGER3_JSONSCH_TYP.tps 

CREATE OR REPLACE TYPE dz_swagger3_jsonsch_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    schema_obj     dz_swagger3_schema_typ
   ,return_code    INTEGER
   ,status_message VARCHAR2(255 Char)
   
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
      p_short_id              IN  VARCHAR2 DEFAULT 'FALSE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_jsonsch_typ TO public;

--******************************--
PROMPT Types/DZ_SWAGGER3_JSONSCH_TYP.tpb 

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
      
      IF str_operation_id IS NULL
      THEN
         self.return_code    := -1;
         self.status_message := 'path does not have http method ' || p_http_method;
         RETURN;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Determine the response id
      --------------------------------------------------------------------------
      BEGIN
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

      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            self.return_code    := -1;
            self.status_message := 'operation does not have response map ' || p_response_code;
            RETURN;
            
         WHEN OTHERS
         THEN
            RAISE;

      END;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Determine the media id
      --------------------------------------------------------------------------
      BEGIN
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
         
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            self.return_code    := -1;
            self.status_message := 'path does not have media map of type ' || p_media_type;
            RETURN;
            
         WHEN OTHERS
         THEN
            RAISE;
            
      END;
            
      --------------------------------------------------------------------------
      -- Step 60
      -- Pull the base schema for the operation response
      --------------------------------------------------------------------------
      BEGIN
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
         
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            self.return_code    := -1;
            self.status_message := 'path does not have media ' || str_media_id;
            RETURN;
            
         WHEN OTHERS
         THEN
            RAISE;
            
      END;
      
      --------------------------------------------------------------------------
      -- Step 70
      -- Walk the schema tree
      --------------------------------------------------------------------------
      self.schema_obj.traverse();
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Determine the schema title
      --------------------------------------------------------------------------
      IF p_title IS NULL
      THEN
         self.schema_obj.schema_title := p_path_id || '|' || p_http_method || '|' || p_response_code || '|' || p_media_type;
         
      ELSE
         self.schema_obj.schema_title := p_title;
      
      END IF;
      
      self.schema_obj.inject_jsonschema := 'TRUE';
      
      RETURN;
   
   END dz_swagger3_jsonsch_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
      p_short_id              IN  VARCHAR2 DEFAULT 'FALSE'
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
          p_force_inline   => 'TRUE'
         ,p_short_id       => p_short_id
         ,p_jsonschema     => 'TRUE'
      );
 
   END toJSON;
   
END;
/

--******************************--
PROMPT Types/DZ_SWAGGER3_MOCKSRV_TYP.tps 

CREATE OR REPLACE TYPE dz_swagger3_mocksrv_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    schema_obj     dz_swagger3_schema_typ
   ,return_code    INTEGER
   ,status_message VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_mocksrv_typ 
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_mocksrv_typ(
       p_path_id              IN  VARCHAR2
      ,p_http_method          IN  VARCHAR2 DEFAULT 'get'
      ,p_response_code        IN  VARCHAR2 DEFAULT 'default'
      ,p_media_type           IN  VARCHAR2 DEFAULT 'application/json'
      ,p_versionid            IN  VARCHAR2 DEFAULT NULL
   ) RETURN SELF AS RESULT

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toMockJSON(
      p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toMockXML(
      p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_mocksrv_typ TO public;

--******************************--
PROMPT Types/DZ_SWAGGER3_MOCKSRV_TYP.tpb 

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
      self.return_code := 0;
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
      
      IF str_operation_id IS NULL
      THEN
         self.return_code    := -1;
         self.status_message := 'path does not have http method ' || p_http_method;
         RETURN;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Determine the response id
      --------------------------------------------------------------------------
      BEGIN
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

      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            self.return_code    := -1;
            self.status_message := 'operation does not have response map ' || p_response_code;
            RETURN;
            
         WHEN OTHERS
         THEN
            RAISE;
            
      END;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Determine the media id
      --------------------------------------------------------------------------
      BEGIN
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
         
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            self.return_code    := -1;
            self.status_message := 'path does not have media type ' || p_media_type;
            RETURN;
            
         WHEN OTHERS
         THEN
            RAISE;
            
      END;
            
      --------------------------------------------------------------------------
      -- Step 60
      -- Pull the base schema for the operation response
      --------------------------------------------------------------------------
      BEGIN
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
         
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            self.return_code    := -1;
            self.status_message := 'path does not have media ' || str_media_id;
            RETURN;
            
         WHEN OTHERS
         THEN
            RAISE;
            
      END;
      
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
   ) RETURN CLOB
   AS
      clb_output  CLOB;
      
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
      clb_output := '<?xml version="1.0" encoding="UTF-8"?><Root>'
                 || self.schema_obj.toMockXML(
         p_short_id => p_short_id
      ) || '</Root>'; 
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Return results
      --------------------------------------------------------------------------
      RETURN clb_output;

   END toMockXML;
   
END;
/

--******************************--
PROMPT Packages/DZ_SWAGGER3_CACHE_MGR.pks 

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
      ,p_short_id            IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_escapes       IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION yaml(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_refresh_interval    IN  INTERVAL  DAY TO SECOND DEFAULT NULL
      ,p_short_id            IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_escapes       IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION jsonschema(
       p_path_endpoint       IN  VARCHAR2
      ,p_path_group_id       IN  VARCHAR2  DEFAULT NULL
      ,p_operation           IN  VARCHAR2  DEFAULT 'get'
      ,p_response_code       IN  VARCHAR2  DEFAULT 'default'
      ,p_media_type          IN  VARCHAR2  DEFAULT 'application/json' 
      ,p_schema_title        IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_short_id            IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_escapes       IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION mocksrv(
       p_path_endpoint       IN  VARCHAR2
      ,p_path_group_id       IN  VARCHAR2  DEFAULT NULL
      ,p_operation           IN  VARCHAR2  DEFAULT 'get'
      ,p_response_code       IN  VARCHAR2  DEFAULT 'default'
      ,p_media_type          IN  VARCHAR2  DEFAULT 'application/json' 
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_short_id            IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_escapes       IN  VARCHAR2  DEFAULT 'FALSE'
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
      ,p_short_id            IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_escapes       IN  VARCHAR2  DEFAULT 'FALSE'
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

--******************************--
PROMPT Packages/DZ_SWAGGER3_CACHE_MGR.pkb 

CREATE OR REPLACE PACKAGE BODY dz_swagger3_cache_mgr
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE force_escape(
      p_json            IN OUT NOCOPY CLOB
   )
   AS
   BEGIN
   
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00A0'),'\u00A0');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00AE'),'\u00AE');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00B0'),'\u00B0');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00B1'),'\u00B1');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00B2'),'\u00B2');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00B3'),'\u00B3');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00B4'),'\u00B4');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00B5'),'\u00B5');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00B7'),'\u00B7');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00BC'),'\u00BC');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00BD'),'\u00BD');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00C0'),'\u00C0');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00C1'),'\u00C1');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00C7'),'\u00C7');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00C8'),'\u00C8');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00C9'),'\u00C9');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00CA'),'\u00CA');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00CD'),'\u00CD');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00D1'),'\u00D1');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00D3'),'\u00D3');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00D6'),'\u00D6');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00D7'),'\u00D7');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00DA'),'\u00DA');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00E0'),'\u00E0');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00E1'),'\u00E1');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00E2'),'\u00E2');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00E3'),'\u00E3');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00E7'),'\u00E7');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00E8'),'\u00E8');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00E9'),'\u00E9');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00EA'),'\u00EA');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00EB'),'\u00EB');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00EC'),'\u00EC');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00ED'),'\u00ED');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00F3'),'\u00F3');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\00F6'),'\u00F6');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\0100'),'\u0100');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\0112'),'\u0112');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\012A'),'\u012A');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\0141'),'\u0141');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\014C'),'\u014C');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\0160'),'\u0160');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\0161'),'\u0161');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\016A'),'\u016A');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\02BB'),'\u02BB');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\0302'),'\u0302');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\2013'),'\u2013');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\2014'),'\u2014');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\2015'),'\u2015');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\2018'),'\u2018');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\2019'),'\u2019');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\201B'),'\u201B');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\201C'),'\u201C');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\201D'),'\u201D');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\201F'),'\u201F');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\2022'),'\u2022');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\20AC'),'\u20AC');
      p_json := REGEXP_REPLACE(p_json,UNISTR('\2122'),'\u2122');
      
   END force_escape;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE vintage(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_timestamp           OUT TIMESTAMP
      ,p_short_id            OUT VARCHAR2
      ,p_force_escapes       OUT VARCHAR2
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
      ,a.short_id
      ,a.force_escapes
      INTO
       p_timestamp
      ,p_short_id
      ,p_force_escapes
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
      ,p_short_id            IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_escapes       IN  VARCHAR2  DEFAULT 'FALSE'
      ,out_json              OUT CLOB
      ,out_yaml              OUT CLOB
   )
   AS
   PRAGMA AUTONOMOUS_TRANSACTION;
      obj_core        dz_swagger3_typ;
      
   BEGIN
   
      obj_core := dz_swagger3_typ(
          p_doc_id    => p_doc_id
         ,p_group_id  => p_group_id
         ,p_versionid => p_versionid
      );
   
      out_json := obj_core.toJSON(
         p_short_id   => p_short_id   
      );
      
      dz_swagger3_util.json2yaml(
          p_input    => out_json
         ,p_output   => out_yaml
      );
      
      IF UPPER(p_force_escapes) = 'TRUE'
      THEN
         force_escape(p_json => out_json);
         force_escape(p_json => out_yaml);
      
      END IF;
      
      BEGIN
         INSERT INTO dz_swagger3_cache(
             doc_id
            ,group_id
            ,json_payload
            ,yaml_payload
            ,extraction_timestamp 
            ,short_id
            ,force_escapes
            ,versionid 
         ) VALUES (
             p_doc_id
            ,p_group_id
            ,out_json
            ,out_yaml
            ,SYSTIMESTAMP
            ,p_short_id
            ,p_force_escapes
            ,p_versionid
         );
         
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            UPDATE dz_swagger3_cache
            SET
             json_payload         = out_json
            ,yaml_payload         = out_yaml
            ,extraction_timestamp = SYSTIMESTAMP
            ,short_id             = p_short_id
            ,force_escapes        = p_force_escapes
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
      ,p_short_id            IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_escapes       IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output                  CLOB;
      clb_output3                 CLOB;
      str_doc_id                  VARCHAR2(255 Char);
      str_group_id                VARCHAR2(255 Char);
      str_versionid               VARCHAR2(40 Char);
      dat_timestamp               TIMESTAMP;
      str_stored_short_id         VARCHAR2(255 Char);
      str_stored_force_escapes    VARCHAR2(255 Char);
      str_requested_short_id      VARCHAR2(255 Char) := UPPER(p_short_id);
      str_requested_force_escapes VARCHAR2(255 Char) := UPPER(p_force_escapes);

   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF str_requested_short_id IS NULL
      OR str_requested_short_id NOT IN ('TRUE','FALSE')
      THEN
         str_requested_short_id := 'TRUE';
         
      END IF;
      
      IF str_requested_force_escapes IS NULL
      OR str_requested_force_escapes NOT IN ('TRUE','FALSE')
      THEN
         str_requested_force_escapes := 'FALSE';
         
      END IF;

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
         ,p_short_id      => str_stored_short_id
         ,p_force_escapes => str_stored_force_escapes
      );
      
      --------------------------------------------------------------------------
      -- Step 40     
      -- Return results if found
      --------------------------------------------------------------------------
      IF dat_timestamp IS NULL
      OR SYSTIMESTAMP - dat_timestamp > p_refresh_interval
      OR str_requested_short_id      <> str_stored_short_id
      OR str_requested_force_escapes <> str_stored_force_escapes
      THEN
         update_cache(
             p_doc_id          => str_doc_id
            ,p_group_id        => str_group_id
            ,p_versionid       => str_versionid
            ,p_short_id        => str_requested_short_id
            ,p_force_escapes   => str_requested_force_escapes
            ,out_json          => clb_output
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
   FUNCTION yaml(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_refresh_interval    IN  INTERVAL  DAY TO SECOND DEFAULT NULL
      ,p_short_id            IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_escapes       IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output                  CLOB;
      clb_output3                 CLOB;
      str_doc_id                  VARCHAR2(255 Char);
      str_group_id                VARCHAR2(255 Char);
      str_versionid               VARCHAR2(40 Char);
      dat_timestamp               TIMESTAMP;
      str_stored_short_id         VARCHAR2(255 Char);
      str_stored_force_escapes    VARCHAR2(255 Char);
      str_requested_short_id      VARCHAR2(255 Char) := UPPER(p_short_id);
      str_requested_force_escapes VARCHAR2(255 Char) := UPPER(p_force_escapes);

   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF str_requested_short_id IS NULL
      OR str_requested_short_id NOT IN ('TRUE','FALSE')
      THEN
         str_requested_short_id := 'TRUE';
         
      END IF;
      
      IF str_requested_force_escapes IS NULL
      OR str_requested_force_escapes NOT IN ('TRUE','FALSE')
      THEN
         str_requested_force_escapes := 'FALSE';
         
      END IF;
      
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
         ,p_short_id      => str_stored_short_id
         ,p_force_escapes => str_stored_force_escapes
      );
      
      --------------------------------------------------------------------------
      -- Step 40     
      -- Return results if found
      --------------------------------------------------------------------------
      IF dat_timestamp IS NULL
      OR SYSTIMESTAMP - dat_timestamp > p_refresh_interval
      OR str_requested_short_id      <> str_stored_short_id
      OR str_requested_force_escapes <> str_stored_force_escapes
      THEN
         update_cache(
             p_doc_id          => str_doc_id
            ,p_group_id        => str_group_id
            ,p_versionid       => str_versionid
            ,p_short_id        => str_requested_short_id
            ,p_force_escapes   => str_requested_force_escapes
            ,out_json          => clb_output
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
   FUNCTION jsonschema(
       p_path_endpoint       IN  VARCHAR2
      ,p_path_group_id       IN  VARCHAR2  DEFAULT NULL
      ,p_operation           IN  VARCHAR2  DEFAULT 'get'
      ,p_response_code       IN  VARCHAR2  DEFAULT 'default'
      ,p_media_type          IN  VARCHAR2  DEFAULT 'application/json' 
      ,p_schema_title        IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_short_id            IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_escapes       IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output         CLOB;
      typ_output         dz_swagger3_jsonsch_typ;
      str_pathid         VARCHAR2(4000 Char);
      str_versionid      VARCHAR2(4000 Char) := p_versionid;
      str_pathgroupid    VARCHAR2(4000 Char) := UPPER(p_path_group_id);
      str_path_endpoint  VARCHAR2(4000 Char) := p_path_endpoint;

   BEGIN
   
      IF str_versionid IS NULL
      THEN
         str_versionid := 'TRUNK';
         
      END IF;
   
      BEGIN
         IF str_pathgroupid IS NULL
         THEN
            SELECT
            a.path_id
            INTO
            str_pathid
            FROM
            dz_swagger3_path a
            WHERE
                a.versionid     = str_versionid
            AND a.path_endpoint = str_path_endpoint
            AND rownum <= 1;
            
         ELSE
            SELECT
            a.path_id
            INTO
            str_pathid
            FROM
            dz_swagger3_path a
            JOIN
            dz_swagger3_group b
            ON
            a.path_id = b.path_id
            WHERE
                a.versionid     = str_versionid
            AND b.versionid     = str_versionid
            AND a.path_endpoint = str_path_endpoint
            AND b.group_id      = str_pathgroupid;
         
         END IF;
      
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN NULL;
            
         WHEN OTHERS
         THEN
            RAISE;

      END;
      
      typ_output := dz_swagger3_jsonsch_typ(
          p_path_id        => str_pathid
         ,p_http_method    => p_operation
         ,p_response_code  => p_response_code
         ,p_media_type     => p_media_type
         ,p_title          => p_schema_title
         ,p_versionid      => str_versionid
      );
      
      clb_output := typ_output.toJSON();
      
      IF typ_output.return_code != 0
      THEN
         clb_output := '{"return_code":' || typ_output.return_code || ','
                    ||  '"status_message":"' || typ_output.status_message || '"}';
                    
      ELSE
         IF UPPER(p_force_escapes) = 'TRUE'
         THEN
            force_escape(p_json => clb_output);
            
         END IF;

      END IF;
      
      RETURN clb_output;
      
   END jsonschema;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION mocksrv(
       p_path_endpoint       IN  VARCHAR2
      ,p_path_group_id       IN  VARCHAR2  DEFAULT NULL
      ,p_operation           IN  VARCHAR2  DEFAULT 'get'
      ,p_response_code       IN  VARCHAR2  DEFAULT 'default'
      ,p_media_type          IN  VARCHAR2  DEFAULT 'application/json' 
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_short_id            IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_escapes       IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output         CLOB;
      typ_output         dz_swagger3_mocksrv_typ;
      str_pathid         VARCHAR2(4000 Char);
      str_versionid      VARCHAR2(4000 Char) := p_versionid;
      str_pathgroupid    VARCHAR2(4000 Char) := UPPER(p_path_group_id);
      str_path_endpoint  VARCHAR2(4000 Char) := p_path_endpoint;
      str_media_type     VARCHAR2(4000 Char) := LOWER(p_media_type);
      
   BEGIN
   
      IF str_versionid IS NULL
      THEN
         str_versionid := 'TRUNK';
         
      END IF;
   
      BEGIN
         IF str_pathgroupid IS NULL
         THEN
            SELECT
            a.path_id
            INTO
            str_pathid
            FROM
            dz_swagger3_path a
            WHERE
                a.versionid     = str_versionid
            AND a.path_endpoint = str_path_endpoint
            AND rownum <= 1;
            
         ELSE
            SELECT
            a.path_id
            INTO
            str_pathid
            FROM
            dz_swagger3_path a
            JOIN
            dz_swagger3_group b
            ON
            a.path_id = b.path_id
            WHERE
                a.versionid     = str_versionid
            AND b.versionid     = str_versionid
            AND a.path_endpoint = str_path_endpoint
            AND b.group_id      = str_pathgroupid;
         
         END IF;
      
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN NULL;
            
         WHEN OTHERS
         THEN
            RAISE;

      END;
      
      typ_output := dz_swagger3_mocksrv_typ(
          p_path_id        => str_pathid
         ,p_http_method    => p_operation
         ,p_response_code  => p_response_code
         ,p_media_type     => p_media_type
         ,p_versionid      => str_versionid
      );
      
      IF str_media_type = 'application/xml'
      THEN
         clb_output := typ_output.toMockXML(
            p_short_id        => p_short_id
         );
         
         IF typ_output.return_code != 0
         THEN
            clb_output := '<?xml version="1.0" encoding="UTF-8"?><root>'
                       || '<return_code>' || typ_output.return_code || '</return_code>'
                       || '<status_message>' || typ_output.status_message || '</status_message></root>';
                       
         END IF;
         
      ELSE
         clb_output := typ_output.toMockJSON(
            p_short_id        => p_short_id
         );
         
         IF typ_output.return_code != 0
         THEN
            clb_output := '{"return_code":' || typ_output.return_code || ','
                       ||  '"status_message":"' || typ_output.status_message || '"}';
                       
         END IF;
         
         IF UPPER(p_force_escapes) = 'TRUE'
         THEN
            force_escape(p_json => clb_output);
            
         END IF;
         
      END IF;
      
      RETURN clb_output;
   
   END mocksrv;
   
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
      str_force_escapes   VARCHAR2(255 Char);
      
   BEGIN
   
      vintage(
          p_doc_id        => p_doc_id
         ,p_group_id      => p_group_id
         ,p_versionid     => p_versionid
         ,p_timestamp     => dat_result
         ,p_short_id      => str_shorten_logic
         ,p_force_escapes => str_force_escapes
      );
   
      RETURN dat_result;
      
   END vintage;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE reload_cache(
       p_doc_id              IN  VARCHAR2  DEFAULT NULL
      ,p_group_id            IN  VARCHAR2  DEFAULT NULL
      ,p_versionid           IN  VARCHAR2  DEFAULT NULL
      ,p_short_id            IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_escapes       IN  VARCHAR2  DEFAULT 'FALSE'
   )
   AS
      clb_output          CLOB;
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
         ,p_short_id        => p_short_id
         ,p_force_escapes   => p_force_escapes
         ,out_json          => clb_output
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

--******************************--
PROMPT Packages/DZ_SWAGGER3_TEST.pks 

CREATE OR REPLACE PACKAGE dz_swagger3_test
AUTHID DEFINER
AS

   C_GITRELEASE    CONSTANT VARCHAR2(255 Char) := 'v1.1.0';
   C_GITCOMMIT     CONSTANT VARCHAR2(255 Char) := '9d4000272ab2b89c0a0d5eae5a6f855c453889fa';
   C_GITCOMMITDATE CONSTANT VARCHAR2(255 Char) := 'Mon May 3 08:41:58 2021 -0400';
   C_GITCOMMITAUTH CONSTANT VARCHAR2(255 Char) := 'Paul Dziemiela';
   
   C_PREREQUISITES CONSTANT dz_swagger3_string_vry := NULL;
   
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

--******************************--
PROMPT Packages/DZ_SWAGGER3_TEST.pkb 

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
      RETURN '{'
      || ' "GITRELEASE":"'    || C_GITRELEASE    || '"'
      || ',"GITCOMMIT":"'     || C_GITCOMMIT     || '"'
      || ',"GITCOMMITDATE":"' || C_GITCOMMITDATE || '"'
      || ',"GITCOMMITAUTH":"' || C_GITCOMMITAUTH || '"'
      || '}';
      
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

SHOW ERROR;

DECLARE
   l_num_errors PLS_INTEGER;

BEGIN

   SELECT
   COUNT(*)
   INTO l_num_errors
   FROM
   user_errors a
   WHERE
   a.name LIKE 'DZ_SWAGGER3%';

   IF l_num_errors <> 0
   THEN
      RAISE_APPLICATION_ERROR(-20001,'COMPILE ERROR');

   END IF;

   l_num_errors := DZ_SWAGGER3_TEST.inmemory_test();

   IF l_num_errors <> 0
   THEN
      RAISE_APPLICATION_ERROR(-20001,'INMEMORY TEST ERROR');

   END IF;

END;
/

SET DEFINE OFF;

