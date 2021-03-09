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

