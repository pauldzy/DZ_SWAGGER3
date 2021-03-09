CREATE OR REPLACE TYPE BODY dz_swagger3_encoding_typ
AS 

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_encoding_typ
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_encoding_typ;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_encoding_typ(
       p_encoding_id            IN  VARCHAR2
      ,p_versionid              IN  VARCHAR2
   ) RETURN SELF AS RESULT 
   AS 
   BEGIN 
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Set up the object
      --------------------------------------------------------------------------
      self.versionid := p_versionid;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Pull the object information
      --------------------------------------------------------------------------
      SELECT
       a.encoding_id
      ,a.encoding_contentType
      ,a.encoding_style
      ,a.encoding_explode
      ,a.encoding_allowReserved
      INTO
       self.encoding_id
      ,self.encoding_contentType
      ,self.encoding_style 
      ,self.encoding_explode 
      ,self.encoding_allowReserved
      FROM
      dz_swagger3_encoding a
      WHERE
          a.versionid   = p_versionid
      AND a.encoding_id = p_encoding_id;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Collect the response headers
      --------------------------------------------------------------------------
      SELECT
      dz_swagger3_object_typ(
          p_object_id          => a.header_id
         ,p_object_type_id     => 'headertyp'
         ,p_object_key         => a.header_name
         ,p_object_order       => a.header_order
      )
      BULK COLLECT INTO self.encoding_headers 
      FROM
      dz_swagger3_parent_header_map a
      WHERE
          a.versionid  = p_versionid
      AND a.parent_id  = p_encoding_id;

      --------------------------------------------------------------------------
      -- Step 40
      -- Return the completed object
      --------------------------------------------------------------------------
      RETURN; 
      
   END dz_swagger3_encoding_typ;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER PROCEDURE traverse
   AS
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Load the external docs
      --------------------------------------------------------------------------
      IF  self.encoding_headers IS NOT NULL
      AND self.encoding_headers.COUNT > 0
      THEN
         dz_swagger3_loader.headertyp(
             p_parent_id    => self.encoding_id
            ,p_children_ids => self.encoding_headers
            ,p_versionid    => self.versionid
         );
      
      END IF;

   END traverse;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   AS
      clb_output           CLOB;
      clb_encoding_headers CLOB;
      int_encoding_headers PLS_INTEGER;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check incoming parameters
      --------------------------------------------------------------------------
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Add optional encoding headers
      --------------------------------------------------------------------------
      IF  self.encoding_headers IS NOT NULL 
      AND self.encoding_headers.COUNT > 0
      THEN
         SELECT
         JSON_OBJECTAGG(
             b.object_key VALUE a.headertyp.toJSON(
                p_force_inline     => p_force_inline
               ,p_short_id         => p_short_id
               ,p_identifier       => a.object_id
               ,p_short_identifier => a.short_id
               ,p_reference_count  => a.reference_count
            ) FORMAT JSON
            RETURNING CLOB
         )
         INTO clb_encoding_headers
         FROM
         dz_swagger3_xobjects a
         JOIN
         TABLE(self.encoding_headers) b
         ON
             a.object_type_id = b.object_type_id
         AND a.object_id      = b.object_id;

      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Build the object
      --------------------------------------------------------------------------
      IF self.encoding_headers IS NOT NULL
      THEN
         int_encoding_headers := self.encoding_headers.COUNT;
         
      ELSE
         int_encoding_headers := 0;
         
      END IF;

      SELECT
      JSON_OBJECT(
          'contentType'         VALUE self.encoding_contentType
         ,'headers'             VALUE CASE
            WHEN int_encoding_headers > 0
            THEN
               clb_encoding_headers
            ELSE
               NULL
            END FORMAT JSON
         ,'style'               VALUE self.encoding_style
         ,'explode'             VALUE CASE
            WHEN LOWER(self.encoding_explode) = 'true'
            THEN
               'true'
            WHEN LOWER(self.encoding_explode) = 'false'
            THEN
               'false'
            ELSE
               NULL
            END FORMAT JSON
         ,'allowReserved'       VALUE CASE
            WHEN LOWER(self.encoding_allowReserved) = 'true'
            THEN
               'true'
            WHEN LOWER(self.encoding_allowReserved) = 'false'
            THEN
               'false'
            ELSE
               NULL
            END FORMAT JSON
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

