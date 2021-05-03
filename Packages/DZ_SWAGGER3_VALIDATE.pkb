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

