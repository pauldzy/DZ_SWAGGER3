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

