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
      
      IF INSTR(p_input,CHR(10)) > 0
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
