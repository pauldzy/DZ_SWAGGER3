CREATE OR REPLACE PACKAGE BODY dz_swagger3_sort
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION schemas(
       p_input        IN  dz_swagger3_schema_nf_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   ) RETURN dz_swagger3_schema_nf_list
   AS
      tmp_obj  dz_swagger3_schema_typ;
      ary_out  dz_swagger3_schema_nf_list;
      idx      PLS_INTEGER;
      
   BEGIN
   
      ary_out := dz_swagger3_schema_nf_list();
   
      IF p_input IS NULL
      THEN
         RETURN ary_out;
         
      ELSIF p_input.COUNT = 1
      THEN
         RETURN p_input;
         
      END IF;
      
      ary_out := p_input;
      idx := p_input.COUNT - 1;
      WHILE ( idx > 0 )
      LOOP
         FOR j IN 1 .. idx
         LOOP
            IF p_direction = 'DESC'
            THEN
               IF ary_out(j).schema_id < ary_out(j+1).schema_id
               THEN
                  tmp_obj      := TREAT(ary_out(j) AS dz_swagger3_schema_typ);
                  ary_out(j)   := ary_out(j+1);
                  ary_out(j+1) := tmp_obj;
                  
               END IF;
               
            ELSE
               IF ary_out(j).schema_id > ary_out(j+1).schema_id
               THEN
                  tmp_obj      := TREAT(ary_out(j) AS dz_swagger3_schema_typ);
                  ary_out(j)   := ary_out(j+1);
                  ary_out(j+1) := tmp_obj;
                  
               END IF;
               
            END IF;
            
         END LOOP;
         
         idx := idx - 1;
         
      END LOOP;
      
      RETURN ary_out;
   
   END schemas;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION responses(
       p_input        IN  dz_swagger3_response_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   ) RETURN dz_swagger3_response_list
   AS
      tmp_obj  dz_swagger3_response_typ;
      ary_out  dz_swagger3_response_list;
      idx      PLS_INTEGER;
      
   BEGIN
   
      ary_out := dz_swagger3_response_list();
   
      IF p_input IS NULL
      THEN
         RETURN ary_out;
         
      ELSIF p_input.COUNT = 1
      THEN
         RETURN p_input;
         
      END IF;
      
      ary_out := p_input;
      idx := p_input.COUNT - 1;
      WHILE ( idx > 0 )
      LOOP
         FOR j IN 1 .. idx
         LOOP
            IF p_direction = 'DESC'
            THEN
               IF ary_out(j).response_id < ary_out(j+1).response_id
               THEN
                  tmp_obj      := ary_out(j);
                  ary_out(j)   := ary_out(j+1);
                  ary_out(j+1) := tmp_obj;
                  
               END IF;
               
            ELSE
               IF ary_out(j).response_id > ary_out(j+1).response_id
               THEN
                  tmp_obj      := ary_out(j);
                  ary_out(j)   := ary_out(j+1);
                  ary_out(j+1) := tmp_obj;
                  
               END IF;
               
            END IF;
            
         END LOOP;
         
         idx := idx - 1;
         
      END LOOP;
      
      RETURN ary_out;
   
   END responses;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION examples(
       p_input        IN  dz_swagger3_example_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   ) RETURN dz_swagger3_example_list
   AS
      tmp_obj  dz_swagger3_example_typ;
      ary_out  dz_swagger3_example_list;
      idx      PLS_INTEGER;
      
   BEGIN
   
      ary_out := dz_swagger3_example_list();
   
      IF p_input IS NULL
      THEN
         RETURN ary_out;
         
      ELSIF p_input.COUNT = 1
      THEN
         RETURN p_input;
         
      END IF;
      
      ary_out := p_input;
      idx := p_input.COUNT - 1;
      WHILE ( idx > 0 )
      LOOP
         FOR j IN 1 .. idx
         LOOP
            IF p_direction = 'DESC'
            THEN
               IF ary_out(j).example_id < ary_out(j+1).example_id
               THEN
                  tmp_obj      := ary_out(j);
                  ary_out(j)   := ary_out(j+1);
                  ary_out(j+1) := tmp_obj;
                  
               END IF;
               
            ELSE
               IF ary_out(j).example_id > ary_out(j+1).example_id
               THEN
                  tmp_obj      := ary_out(j);
                  ary_out(j)   := ary_out(j+1);
                  ary_out(j+1) := tmp_obj;
                  
               END IF;
               
            END IF;
            
         END LOOP;
         
         idx := idx - 1;
         
      END LOOP;
      
      RETURN ary_out;
      
   END examples;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION parameters(
       p_input        IN  dz_swagger3_parameter_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   ) RETURN dz_swagger3_parameter_list
   AS
      tmp_obj  dz_swagger3_parameter_typ;
      ary_out  dz_swagger3_parameter_list;
      idx      PLS_INTEGER;
      
   BEGIN
   
      ary_out := dz_swagger3_parameter_list();
   
      IF p_input IS NULL
      THEN
         RETURN ary_out;
         
      ELSIF p_input.COUNT = 1
      THEN
         RETURN p_input;
         
      END IF;
      
      ary_out := p_input;
      idx := p_input.COUNT - 1;
      WHILE ( idx > 0 )
      LOOP
         FOR j IN 1 .. idx
         LOOP
            IF p_direction = 'DESC'
            THEN
               IF ary_out(j).parameter_id < ary_out(j+1).parameter_id
               THEN
                  tmp_obj      := ary_out(j);
                  ary_out(j)   := ary_out(j+1);
                  ary_out(j+1) := tmp_obj;
                  
               END IF;
               
            ELSE
               IF ary_out(j).parameter_id > ary_out(j+1).parameter_id
               THEN
                  tmp_obj      := ary_out(j);
                  ary_out(j)   := ary_out(j+1);
                  ary_out(j+1) := tmp_obj;
                  
               END IF;
               
            END IF;
            
         END LOOP;
         
         idx := idx - 1;
         
      END LOOP;
      
      RETURN ary_out;
      
   END parameters;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION requestBodies(
       p_input        IN  dz_swagger3_requestBody_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   ) RETURN dz_swagger3_requestBody_list
   AS
      tmp_obj  dz_swagger3_requestBody_typ;
      ary_out  dz_swagger3_requestBody_list;
      idx      PLS_INTEGER;
      
   BEGIN
   
      ary_out := dz_swagger3_requestBody_list();
   
      IF p_input IS NULL
      THEN
         RETURN ary_out;
         
      ELSIF p_input.COUNT = 1
      THEN
         RETURN p_input;
         
      END IF;
      
      ary_out := p_input;
      idx := p_input.COUNT - 1;
      WHILE ( idx > 0 )
      LOOP
         FOR j IN 1 .. idx
         LOOP
            IF p_direction = 'DESC'
            THEN
               IF ary_out(j).requestBody_id < ary_out(j+1).requestBody_id
               THEN
                  tmp_obj      := ary_out(j);
                  ary_out(j)   := ary_out(j+1);
                  ary_out(j+1) := tmp_obj;
                  
               END IF;
               
            ELSE
               IF ary_out(j).requestBody_id > ary_out(j+1).requestBody_id
               THEN
                  tmp_obj      := ary_out(j);
                  ary_out(j)   := ary_out(j+1);
                  ary_out(j+1) := tmp_obj;
                  
               END IF;
               
            END IF;
            
         END LOOP;
         
         idx := idx - 1;
         
      END LOOP;
      
      RETURN ary_out;
   
   END requestBodies;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION headers(
       p_input        IN  dz_swagger3_header_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   ) RETURN dz_swagger3_header_list
   AS
      tmp_obj  dz_swagger3_header_typ;
      ary_out  dz_swagger3_header_list;
      idx      PLS_INTEGER;
      
   BEGIN
   
      ary_out := dz_swagger3_header_list();
   
      IF p_input IS NULL
      THEN
         RETURN ary_out;
         
      ELSIF p_input.COUNT = 1
      THEN
         RETURN p_input;
         
      END IF;
      
      ary_out := p_input;
      idx := p_input.COUNT - 1;
      WHILE ( idx > 0 )
      LOOP
         FOR j IN 1 .. idx
         LOOP
            IF p_direction = 'DESC'
            THEN
               IF ary_out(j).header_id < ary_out(j+1).header_id
               THEN
                  tmp_obj      := ary_out(j);
                  ary_out(j)   := ary_out(j+1);
                  ary_out(j+1) := tmp_obj;
                  
               END IF;
               
            ELSE
               IF ary_out(j).header_id > ary_out(j+1).header_id
               THEN
                  tmp_obj      := ary_out(j);
                  ary_out(j)   := ary_out(j+1);
                  ary_out(j+1) := tmp_obj;
                  
               END IF;
               
            END IF;
            
         END LOOP;
         
         idx := idx - 1;
         
      END LOOP;
      
      RETURN ary_out;
   
   END headers;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION securitySchemes(
       p_input        IN  dz_swagger3_securitySchem_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   ) RETURN dz_swagger3_securitySchem_list
   AS
      tmp_obj  dz_swagger3_securityScheme_typ;
      ary_out  dz_swagger3_securitySchem_list;
      idx      PLS_INTEGER;
      
   BEGIN
   
      ary_out := dz_swagger3_securitySchem_list();
   
      IF p_input IS NULL
      THEN
         RETURN ary_out;
         
      ELSIF p_input.COUNT = 1
      THEN
         RETURN p_input;
         
      END IF;
      
      ary_out := p_input;
      idx := p_input.COUNT - 1;
      WHILE ( idx > 0 )
      LOOP
         FOR j IN 1 .. idx
         LOOP
            IF p_direction = 'DESC'
            THEN
               IF ary_out(j).scheme_id < ary_out(j+1).scheme_id
               THEN
                  tmp_obj      := ary_out(j);
                  ary_out(j)   := ary_out(j+1);
                  ary_out(j+1) := tmp_obj;
                  
               END IF;
               
            ELSE
               IF ary_out(j).scheme_id > ary_out(j+1).scheme_id
               THEN
                  tmp_obj      := ary_out(j);
                  ary_out(j)   := ary_out(j+1);
                  ary_out(j+1) := tmp_obj;
                  
               END IF;
               
            END IF;
            
         END LOOP;
         
         idx := idx - 1;
         
      END LOOP;
      
      RETURN ary_out;
   
   END securitySchemes;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION links(
       p_input        IN  dz_swagger3_link_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   ) RETURN dz_swagger3_link_list
   AS
      tmp_obj  dz_swagger3_link_typ;
      ary_out  dz_swagger3_link_list;
      idx      PLS_INTEGER;
      
   BEGIN
   
      ary_out := dz_swagger3_link_list();
   
      IF p_input IS NULL
      THEN
         RETURN ary_out;
         
      ELSIF p_input.COUNT = 1
      THEN
         RETURN p_input;
         
      END IF;
      
      ary_out := p_input;
      idx := p_input.COUNT - 1;
      WHILE ( idx > 0 )
      LOOP
         FOR j IN 1 .. idx
         LOOP
            IF p_direction = 'DESC'
            THEN
               IF ary_out(j).link_id < ary_out(j+1).link_id
               THEN
                  tmp_obj      := ary_out(j);
                  ary_out(j)   := ary_out(j+1);
                  ary_out(j+1) := tmp_obj;
                  
               END IF;
               
            ELSE
               IF ary_out(j).link_id > ary_out(j+1).link_id
               THEN
                  tmp_obj      := ary_out(j);
                  ary_out(j)   := ary_out(j+1);
                  ary_out(j+1) := tmp_obj;
                  
               END IF;
               
            END IF;
            
         END LOOP;
         
         idx := idx - 1;
         
      END LOOP;
      
      RETURN ary_out;
   
   END links;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION callbacks(
       p_input        IN  dz_swagger3_callback_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   ) RETURN dz_swagger3_callback_list
   AS
      tmp_obj  dz_swagger3_callback_typ;
      ary_out  dz_swagger3_callback_list;
      idx      PLS_INTEGER;
      
   BEGIN
   
      ary_out := dz_swagger3_callback_list();
   
      IF p_input IS NULL
      THEN
         RETURN ary_out;
         
      ELSIF p_input.COUNT = 1
      THEN
         RETURN p_input;
         
      END IF;
      
      ary_out := p_input;
      idx := p_input.COUNT - 1;
      WHILE ( idx > 0 )
      LOOP
         FOR j IN 1 .. idx
         LOOP
            IF p_direction = 'DESC'
            THEN
               IF ary_out(j).callback_id < ary_out(j+1).callback_id
               THEN
                  tmp_obj      := ary_out(j);
                  ary_out(j)   := ary_out(j+1);
                  ary_out(j+1) := tmp_obj;
                  
               END IF;
               
            ELSE
               IF ary_out(j).callback_id > ary_out(j+1).callback_id
               THEN
                  tmp_obj      := ary_out(j);
                  ary_out(j)   := ary_out(j+1);
                  ary_out(j+1) := tmp_obj;
                  
               END IF;
               
            END IF;
            
         END LOOP;
         
         idx := idx - 1;
         
      END LOOP;
      
      RETURN ary_out;
   
   END callbacks;

END dz_swagger3_sort;
/

