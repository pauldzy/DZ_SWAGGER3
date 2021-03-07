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
      ary_strings dz_swagger3_string_vry;
      
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
      ,p_input_b          IN dz_swagger3_string_vry
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
      ,p_in_c             IN  CLOB      DEFAULT NULL
      ,p_in_v             IN  VARCHAR2  DEFAULT NULL
      ,p_pretty_print     IN  INTEGER   DEFAULT NULL
      ,p_amount           IN  VARCHAR2  DEFAULT '   '
      ,p_initial_indent   IN  BOOLEAN   DEFAULT TRUE
      ,p_final_linefeed   IN  BOOLEAN   DEFAULT TRUE
   )
   AS
      lf   VARCHAR2(1 Char) := CHR(10);
      vtmp VARCHAR2(32000 Char);
      
      FUNCTION ind(
          p_level   IN  INTEGER
         ,p_amount  IN  VARCHAR2
      ) RETURN VARCHAR2
      AS
         str_output VARCHAR2(32000 Char);
         
      BEGIN
      
         IF p_amount IS NULL
         THEN
            RETURN NULL;
           
         END IF;
         
         FOR i IN 1 .. p_level
         LOOP
            str_output := str_output || p_amount;
            
         END LOOP;
         
         RETURN str_output;
          
      END ind;
      
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
            IF p_pretty_print IS NULL
            THEN
               p_c := p_in_c;
            
            ELSE
               IF NOT p_initial_indent
               THEN
                  p_c := p_in_c;

               ELSE
                  p_c := TO_CLOB(ind(p_pretty_print,p_amount));
               
                  DBMS_LOB.APPEND(p_c,p_in_c);
               
               END IF;
               
               IF p_final_linefeed
               THEN
                  DBMS_LOB.WRITEAPPEND(
                      lob_loc => p_c
                     ,amount  => 1
                     ,buffer  => lf
                  );

               END IF;
                              
            END IF;
            
         ELSIF p_c IS NULL
         AND   p_v IS NOT NULL
         THEN
            p_c := p_v;
            p_v := NULL;  
            
            IF p_pretty_print IS NULL
            THEN
               DBMS_LOB.APPEND(p_c,p_in_c);
               
            ELSE
               IF p_initial_indent
               THEN
                  vtmp := ind(p_pretty_print,p_amount);
                  
                  IF vtmp IS NOT NULL
                  THEN
                     DBMS_LOB.WRITEAPPEND(
                         lob_loc => p_c
                        ,amount  => LENGTH(vtmp)
                        ,buffer  => vtmp
                     );
                     
                  END IF;
                  
               END IF;
 
               DBMS_LOB.APPEND(p_c,p_in_c);

               IF p_final_linefeed
               THEN
                  DBMS_LOB.WRITEAPPEND(
                      lob_loc => p_c
                     ,amount  => 1
                     ,buffer  => lf
                  );

               END IF;   
            
            END IF;

         ELSIF p_c IS NOT NULL
         AND   p_v IS NULL
         THEN
            IF p_pretty_print IS NULL
            THEN
               DBMS_LOB.APPEND(p_c,p_in_c);
               
            ELSE
               IF p_initial_indent
               THEN
                  vtmp := ind(p_pretty_print,p_amount);
                  
                  IF vtmp IS NOT NULL
                  THEN
                     DBMS_LOB.WRITEAPPEND(
                         lob_loc => p_c
                        ,amount  => LENGTH(vtmp)
                        ,buffer  => vtmp
                     );
                     
                  END IF;
                  
               END IF;
               
               DBMS_LOB.APPEND(p_c,p_in_c);
               
               IF p_final_linefeed
               THEN
                  DBMS_LOB.WRITEAPPEND(
                      lob_loc => p_c
                     ,amount  => 1
                     ,buffer  => lf
                  );
                  
               END IF;
            
            END IF;
         
         ELSIF p_c IS NOT NULL
         AND   p_v IS NOT NULL
         THEN
            DBMS_LOB.WRITEAPPEND(
                lob_loc => p_c
               ,amount  => LENGTH(p_v)
               ,buffer  => p_v
            );
            
            p_v := NULL;
               
            IF p_pretty_print IS NULL
            THEN
               DBMS_LOB.APPEND(p_c,p_in_c);
               
            ELSE
               IF p_initial_indent
               THEN
                  vtmp := ind(p_pretty_print,p_amount);
                  
                  IF vtmp IS NOT NULL
                  THEN
                     DBMS_LOB.WRITEAPPEND(
                         lob_loc => p_c
                        ,amount  => LENGTH(vtmp)
                        ,buffer  => vtmp
                     );
                     
                  END IF;
                  
               END IF;
               
               DBMS_LOB.APPEND(p_c,p_in_c);
               
               IF p_final_linefeed
               THEN
                  DBMS_LOB.WRITEAPPEND(
                      lob_loc => p_c
                     ,amount  => 1
                     ,buffer  => lf
                  );
                  
               END IF;
               
            END IF;
            
         END IF;
         
      ELSIF p_in_c IS NULL
      AND   p_in_v IS NOT NULL
      THEN
         BEGIN
            IF p_pretty_print IS NULL
            THEN
               p_v := p_v || p_in_v;
            
            ELSE
               IF p_initial_indent
               THEN
                  p_v := p_v || ind(p_pretty_print,p_amount);
                  
               END IF;
               
               p_v := p_v || p_in_v;

               IF p_final_linefeed
               THEN
                  p_v := p_v || lf;
                  
               END IF;
               
            END IF;
            
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

               IF p_pretty_print IS NULL
               THEN
                  p_v := p_in_v;
                  
               ELSE
                  IF p_initial_indent
                  THEN
                     p_v := ind(p_pretty_print,p_amount) || p_in_v;
                     
                  ELSE
                     p_v := p_in_v;
                     
                  END IF;
                  
                  IF p_final_linefeed
                  THEN
                     p_v := p_v || lf;
                     
                  END IF;
               
               END IF;
               
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

