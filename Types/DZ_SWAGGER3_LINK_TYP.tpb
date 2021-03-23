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

