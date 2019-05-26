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
   ) RETURN VARCHAR2 DETERMINISTIC
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
   ) RETURN VARCHAR2 DETERMINISTIC
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
   ) RETURN VARCHAR2 DETERMINISTIC
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
   ) RETURN VARCHAR2 DETERMINISTIC
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
   ) RETURN VARCHAR2 DETERMINISTIC
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
   )  RETURN VARCHAR2 CHARACTER SET p_input_url%CHARSET DETERMINISTIC
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
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE conc(
       p_c                IN OUT NOCOPY CLOB
      ,p_v                IN OUT NOCOPY VARCHAR2
      ,p_in_c             IN  CLOB     DEFAULT NULL
      ,p_in_v             IN  VARCHAR2 DEFAULT NULL
   )
   AS
   BEGIN
      
      IF  p_in_c IS NOT NULL
      AND p_in_v IS NOT NULL
      THEN
         RAISE_APPLICATION_ERROR(
             -20001
            ,'only one var or clb exclusive'
         );
         
      ELSIF p_in_c IS NOT NULL
      AND   p_in_v IS NULL
      THEN
         IF  p_c IS NULL
         AND p_v IS NULL
         THEN
            p_c := p_in_c;
            
         ELSIF p_c IS NULL
         AND   p_v IS NOT NULL
         THEN
            p_c := p_v;
            DBMS_LOB.APPEND(p_c,p_in_c);

            p_v := NULL;   
         
         ELSIF p_c IS NOT NULL
         AND   p_v IS NULL
         THEN
            DBMS_LOB.APPEND(p_c,p_in_c); 
         
         ELSIF p_c IS NOT NULL
         AND   p_v IS NOT NULL
         THEN
            DBMS_LOB.WRITEAPPEND(
                lob_loc => p_c
               ,amount  => LENGTH(p_v)
               ,buffer  => p_v
            );
            
            p_v := NULL;

            DBMS_LOB.APPEND(p_c,p_in_c);
            
         END IF;
         
      ELSIF p_in_c IS NULL
      AND   p_in_v IS NOT NULL
      THEN
         BEGIN
            p_v := p_v || p_in_v;
      
         EXCEPTION
            WHEN VALUE_ERROR
            THEN
               IF p_c IS NULL
               THEN
                  p_c := p_v;
                  
               ELSE
                  IF p_v IS NOT NULL
                  THEN
                     DBMS_LOB.WRITEAPPEND(
                         lob_loc => p_c
                        ,amount  => LENGTH(p_v)
                        ,buffer  => p_v
                     );
                     
                  END IF;
                  
               END IF;

               p_v := p_in_v;
               
            WHEN OTHERS
            THEN
               RAISE;

         END;
         
      END IF;
      
      RETURN;

   END conc;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE fconc(
       p_c                IN OUT NOCOPY CLOB
      ,p_v                IN OUT NOCOPY VARCHAR2
   )
   AS
   BEGIN
   
      IF p_v IS NOT NULL
      THEN
         IF p_c IS NULL
         THEN
            p_c := TO_CLOB(p_v);

         ELSE
            DBMS_LOB.WRITEAPPEND(
                lob_loc => p_c
               ,amount  => LENGTH(p_v)
               ,buffer  => p_v
            );

         END IF;

         p_v := NULL;

      END IF;
   
   END fconc;

END dz_swagger3_util;
/

