CREATE OR REPLACE PACKAGE BODY dz_swagger3_validate
AS

   -----------------------------------------------------------------------------
   -- One partical solution to hard-coding your wallet password here would be 
   -- to encrypt the package body source via DBMS_DDL.CREATE_WRAPPED
   -----------------------------------------------------------------------------
   c_swagger_badge_url             CONSTANT VARCHAR2(4000 Char) 
      := NULL;
   c_swagger_badge_wallet_path     CONSTANT VARCHAR2(4000 Char) 
      := NULL;
   c_swagger_badge_wallet_password CONSTANT VARCHAR2(4000 Char) 
      := NULL;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION request_validate(
       p_reqb  IN  VARCHAR2
      ,p_doc   IN  CLOB 
   ) RETURN CLOB
   AS
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
   
      IF p_reqb IS NULL
      THEN
         RETURN '{"tests":null}';
         
      END IF;
      
      json_input := JSON_OBJECT_T.PARSE(p_reqb);
      json_keys  := json_input.GET_KEYS;
      
      IF json_input.has('tests')
      THEN
         json_element := json_input.get('tests');
      
      ELSE
         RETURN '{"tests":null}';
         
      END IF;
      
      IF json_element.is_array()
      THEN
         json_tests := JSON_ARRAY_T(json_element);
         json_index := json_element.get_size();
         
      ELSE
         RETURN '{"tests":null}';
         
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
      
      json_output := JSON_OBJECT_T();
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
      
   BEGIN
   
      json_output := JSON_OBJECT_T();
      json_output.put('test','swagger_badge');
   
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
               ,wallet_password => c_swagger_badge_wallet_password
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
      
      cst := 1;
      cln := 32767;
      LOOP
         buf := SUBSTR(clb,cst,cln);
         UTL_HTTP.WRITE_TEXT(req,buf);
         
         IF LENGTH(buf) < cln
         THEN
            EXIT;
         
         END IF;
      
         cst := cst + cln;
         
      END LOOP;
      
      res := UTL_HTTP.GET_RESPONSE(req);
      clb := NULL;

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

      json_output.put('valid',TRUE);
      
      json_output.put('results',JSON_OBJECT_T.parse(clb));
   
      RETURN json_output.to_clob();  
      
   END swagger_badge_validate;

END dz_swagger3_validate;
/

