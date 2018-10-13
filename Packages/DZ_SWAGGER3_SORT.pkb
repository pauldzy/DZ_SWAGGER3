CREATE OR REPLACE PACKAGE BODY dz_swagger3_sort
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE schemas(
       p_input        IN OUT NOCOPY dz_swagger3_schema_nf_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   )
   AS
      tmp_obj  dz_swagger3_schema_typ;
      idx      PLS_INTEGER;
      
   BEGIN
   
      IF p_input IS NULL
      OR p_input.COUNT = 1
      THEN
         RETURN;
         
      END IF;
      
      idx := p_input.COUNT - 1;
      WHILE ( idx > 0 )
      LOOP
         FOR j IN 1 .. idx
         LOOP
            IF p_direction = 'DESC'
            THEN
               IF p_input(j).schema_id < p_input(j+1).schema_id
               THEN
                  tmp_obj      := TREAT(p_input(j) AS dz_swagger3_schema_typ);
                  p_input(j)   := p_input(j+1);
                  p_input(j+1) := tmp_obj;
                  
               END IF;
               
            ELSE
               IF p_input(j).schema_id > p_input(j+1).schema_id
               THEN
                  tmp_obj      := TREAT(p_input(j) AS dz_swagger3_schema_typ);
                  p_input(j)   := p_input(j+1);
                  p_input(j+1) := tmp_obj;
                  
               END IF;
               
            END IF;
            
         END LOOP;
         
         idx := idx - 1;
         
      END LOOP;
   
   END schemas;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE responses(
       p_input        IN OUT NOCOPY dz_swagger3_response_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   )
   AS
      tmp_obj  dz_swagger3_response_typ;
      idx      PLS_INTEGER;
      
   BEGIN
   
      IF p_input IS NULL
      OR p_input.COUNT = 1
      THEN
         RETURN;
         
      END IF;
      
      idx := p_input.COUNT - 1;
      WHILE ( idx > 0 )
      LOOP
         FOR j IN 1 .. idx
         LOOP
            IF p_direction = 'DESC'
            THEN
               IF p_input(j).response_id < p_input(j+1).response_id
               THEN
                  tmp_obj      := p_input(j);
                  p_input(j)   := p_input(j+1);
                  p_input(j+1) := tmp_obj;
                  
               END IF;
               
            ELSE
               IF p_input(j).response_id > p_input(j+1).response_id
               THEN
                  tmp_obj      := p_input(j);
                  p_input(j)   := p_input(j+1);
                  p_input(j+1) := tmp_obj;
                  
               END IF;
               
            END IF;
            
         END LOOP;
         
         idx := idx - 1;
         
      END LOOP;
   
   END responses;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE examples(
       p_input        IN OUT NOCOPY dz_swagger3_example_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   )
   AS
      tmp_obj  dz_swagger3_example_typ;
      idx      PLS_INTEGER;
      
   BEGIN
   
      IF p_input IS NULL
      OR p_input.COUNT = 1
      THEN
         RETURN;
         
      END IF;
      
      idx := p_input.COUNT - 1;
      WHILE ( idx > 0 )
      LOOP
         FOR j IN 1 .. idx
         LOOP
            IF p_direction = 'DESC'
            THEN
               IF p_input(j).example_id < p_input(j+1).example_id
               THEN
                  tmp_obj      := p_input(j);
                  p_input(j)   := p_input(j+1);
                  p_input(j+1) := tmp_obj;
                  
               END IF;
               
            ELSE
               IF p_input(j).example_id > p_input(j+1).example_id
               THEN
                  tmp_obj      := p_input(j);
                  p_input(j)   := p_input(j+1);
                  p_input(j+1) := tmp_obj;
                  
               END IF;
               
            END IF;
            
         END LOOP;
         
         idx := idx - 1;
         
      END LOOP;
      
   END examples;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE parameters(
       p_input        IN OUT NOCOPY dz_swagger3_parameter_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   )
   AS
      tmp_obj  dz_swagger3_parameter_typ;
      idx      PLS_INTEGER;
      
   BEGIN
   
      IF p_input IS NULL
      OR p_input.COUNT = 1
      THEN
         RETURN;
         
      END IF;
      
      idx := p_input.COUNT - 1;
      WHILE ( idx > 0 )
      LOOP
         FOR j IN 1 .. idx
         LOOP
            IF p_direction = 'DESC'
            THEN
               IF p_input(j).parameter_id < p_input(j+1).parameter_id
               THEN
                  tmp_obj      := p_input(j);
                  p_input(j)   := p_input(j+1);
                  p_input(j+1) := tmp_obj;
                  
               END IF;
               
            ELSE
               IF p_input(j).parameter_id > p_input(j+1).parameter_id
               THEN
                  tmp_obj      := p_input(j);
                  p_input(j)   := p_input(j+1);
                  p_input(j+1) := tmp_obj;
                  
               END IF;
               
            END IF;
            
         END LOOP;
         
         idx := idx - 1;
         
      END LOOP;
      
   END parameters;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE requestBodies(
       p_input        IN OUT NOCOPY dz_swagger3_requestBody_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   )
   AS
      tmp_obj  dz_swagger3_requestBody_typ;
      idx      PLS_INTEGER;
      
   BEGIN
   
      IF p_input IS NULL
      OR p_input.COUNT = 1
      THEN
         RETURN;
         
      END IF;
      
      idx := p_input.COUNT - 1;
      WHILE ( idx > 0 )
      LOOP
         FOR j IN 1 .. idx
         LOOP
            IF p_direction = 'DESC'
            THEN
               IF p_input(j).requestBody_id < p_input(j+1).requestBody_id
               THEN
                  tmp_obj      := p_input(j);
                  p_input(j)   := p_input(j+1);
                  p_input(j+1) := tmp_obj;
                  
               END IF;
               
            ELSE
               IF p_input(j).requestBody_id > p_input(j+1).requestBody_id
               THEN
                  tmp_obj      := p_input(j);
                  p_input(j)   := p_input(j+1);
                  p_input(j+1) := tmp_obj;
                  
               END IF;
               
            END IF;
            
         END LOOP;
         
         idx := idx - 1;
         
      END LOOP;
   
   END requestBodies;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE headers(
       p_input        IN OUT NOCOPY dz_swagger3_header_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   )
   AS
      tmp_obj  dz_swagger3_header_typ;
      idx      PLS_INTEGER;
      
   BEGIN
   
      IF p_input IS NULL
      OR p_input.COUNT = 1
      THEN
         RETURN;
         
      END IF;
      
      idx := p_input.COUNT - 1;
      WHILE ( idx > 0 )
      LOOP
         FOR j IN 1 .. idx
         LOOP
            IF p_direction = 'DESC'
            THEN
               IF p_input(j).header_id < p_input(j+1).header_id
               THEN
                  tmp_obj      := p_input(j);
                  p_input(j)   := p_input(j+1);
                  p_input(j+1) := tmp_obj;
                  
               END IF;
               
            ELSE
               IF p_input(j).header_id > p_input(j+1).header_id
               THEN
                  tmp_obj      := p_input(j);
                  p_input(j)   := p_input(j+1);
                  p_input(j+1) := tmp_obj;
                  
               END IF;
               
            END IF;
            
         END LOOP;
         
         idx := idx - 1;
         
      END LOOP;
   
   END headers;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE securitySchemes(
       p_input        IN OUT NOCOPY dz_swagger3_securitySchem_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   )
   AS
      tmp_obj  dz_swagger3_securityScheme_typ;
      idx      PLS_INTEGER;
      
   BEGIN
   
      IF p_input IS NULL
      OR p_input.COUNT = 1
      THEN
         RETURN;
         
      END IF;
      
      idx := p_input.COUNT - 1;
      WHILE ( idx > 0 )
      LOOP
         FOR j IN 1 .. idx
         LOOP
            IF p_direction = 'DESC'
            THEN
               IF p_input(j).scheme_id < p_input(j+1).scheme_id
               THEN
                  tmp_obj      := p_input(j);
                  p_input(j)   := p_input(j+1);
                  p_input(j+1) := tmp_obj;
                  
               END IF;
               
            ELSE
               IF p_input(j).scheme_id > p_input(j+1).scheme_id
               THEN
                  tmp_obj      := p_input(j);
                  p_input(j)   := p_input(j+1);
                  p_input(j+1) := tmp_obj;
                  
               END IF;
               
            END IF;
            
         END LOOP;
         
         idx := idx - 1;
         
      END LOOP;
   
   END securitySchemes;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE links(
       p_input        IN OUT NOCOPY dz_swagger3_link_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   )
   AS
      tmp_obj  dz_swagger3_link_typ;
      idx      PLS_INTEGER;
      
   BEGIN
   
      IF p_input IS NULL
      OR p_input.COUNT = 1
      THEN
         RETURN;
         
      END IF;
      
      idx := p_input.COUNT - 1;
      WHILE ( idx > 0 )
      LOOP
         FOR j IN 1 .. idx
         LOOP
            IF p_direction = 'DESC'
            THEN
               IF p_input(j).link_id < p_input(j+1).link_id
               THEN
                  tmp_obj      := p_input(j);
                  p_input(j)   := p_input(j+1);
                  p_input(j+1) := tmp_obj;
                  
               END IF;
               
            ELSE
               IF p_input(j).link_id > p_input(j+1).link_id
               THEN
                  tmp_obj      := p_input(j);
                  p_input(j)   := p_input(j+1);
                  p_input(j+1) := tmp_obj;
                  
               END IF;
               
            END IF;
            
         END LOOP;
         
         idx := idx - 1;
         
      END LOOP;
   
   END links;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE callbacks(
       p_input        IN OUT NOCOPY dz_swagger3_callback_list 
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   )
   AS
      tmp_obj  dz_swagger3_callback_typ;
      idx      PLS_INTEGER;
      
   BEGIN
   
      IF p_input IS NULL
      OR p_input.COUNT = 1
      THEN
         RETURN;
         
      END IF;
      
      idx := p_input.COUNT - 1;
      WHILE ( idx > 0 )
      LOOP
         FOR j IN 1 .. idx
         LOOP
            IF p_direction = 'DESC'
            THEN
               IF p_input(j).callback_id < p_input(j+1).callback_id
               THEN
                  tmp_obj      := p_input(j);
                  p_input(j)   := p_input(j+1);
                  p_input(j+1) := tmp_obj;
                  
               END IF;
               
            ELSE
               IF p_input(j).callback_id > p_input(j+1).callback_id
               THEN
                  tmp_obj      := p_input(j);
                  p_input(j)   := p_input(j+1);
                  p_input(j+1) := tmp_obj;
                  
               END IF;
               
            END IF;
            
         END LOOP;
         
         idx := idx - 1;
         
      END LOOP;
   
   END callbacks;

END dz_swagger3_sort;
/

