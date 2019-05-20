CREATE OR REPLACE PACKAGE BODY dz_swagger3_loader
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE xrelates(
       p_children_ids        IN  dz_swagger3_object_vry
      ,p_parent_id           IN  VARCHAR2
   )
   AS
   BEGIN

      INSERT INTO dz_swagger3_xrelates(
          parent_object_id
         ,child_object_id
         ,child_object_type_id
      )
      SELECT
       p_parent_id
      ,a.object_id
      ,a.object_type_id
      FROM
      TABLE(p_children_ids) a
      WHERE
      NOT EXISTS (
         SELECT 1 FROM dz_swagger3_xrelates b 
         WHERE 
             b.parent_object_id = p_parent_id
         AND b.child_object_id  = a.object_id
      )
      AND a.object_id IS NOT NULL
      GROUP BY
       a.object_id
      ,a.object_type_id;

   END;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION filter_ids(
       p_children_ids        IN  dz_swagger3_object_vry
      ,p_parent_id           IN  VARCHAR2
   ) RETURN dz_swagger3_object_vry
   AS
      ary_output dz_swagger3_object_vry;
      
   BEGIN
   
      xrelates(p_children_ids,p_parent_id);
   
      SELECT
      dz_swagger3_object_typ(
          p_object_id           => a.object_id
         ,p_object_type_id      => a.object_type_id
         ,p_object_key          => MAX(a.object_key)
         ,p_object_subtype      => MAX(a.object_subtype)
         ,p_object_attribute    => MAX(a.object_attribute)
      )
      BULK COLLECT INTO ary_output
      FROM
      TABLE(p_children_ids) a
      LEFT JOIN
      dz_swagger3_xobjects b
      ON
          a.object_id      = b.object_id
      AND a.object_type_id = b.object_type_id
      WHERE 
          b.object_id IS NULL 
      AND a.object_id IS NOT NULL
      GROUP BY
       a.object_id
      ,a.object_type_id;
      
      RETURN ary_output;
      
   END filter_ids;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE encodingtyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,encodingtyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_encoding_typ(
          p_encoding_id   => a.object_id
         ,p_versionid     => p_versionid
      )
      FROM 
      TABLE(ary_ids) a;

      FOR r IN (
         SELECT 
         a.encodingtyp
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.encodingtyp.traverse();
      END LOOP;
      
   END encodingtyp;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE exampletyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);
      
      INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,exampletyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_example_typ(
          p_example_id => a.object_id
         ,p_versionid  => p_versionid
       )
      FROM 
      TABLE(ary_ids) a;
      
      -- No subobjects

   END exampletyp;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE extrdocstyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,extrdocstyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_extrdocs_typ(
          p_externaldoc_id => a.object_id
         ,p_versionid      => p_versionid
       )
      FROM 
      TABLE(ary_ids) a;
      
      -- No subobjects

   END extrdocstyp;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE headertyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,headertyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_header_typ(
          p_header_id    => a.object_id
         ,p_versionid    => p_versionid
       )
      FROM 
      TABLE(ary_ids) a;

      FOR r IN (
         SELECT 
         a.headertyp
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.headertyp.traverse();
      END LOOP;

   END headertyp;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE linktyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,linktyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_link_typ(
          p_link_id    => a.object_id
         ,p_versionid  => p_versionid
       )
      FROM 
      TABLE(ary_ids) a;

      FOR r IN (
         SELECT 
         a.linktyp
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.linktyp.traverse();
      END LOOP;

   END linktyp;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE mediatyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      INSERT 
      INTO dz_swagger3_xobjects(
          object_id
         ,object_type_id
         ,mediatyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_media_typ(
          p_media_id    => a.object_id
         ,p_versionid   => p_versionid
       )
      FROM
      TABLE(ary_ids) a;
      
      FOR r IN (
         SELECT 
         a.mediatyp
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.mediatyp.traverse();
      END LOOP;

   END mediatyp;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE mediatyp_emulated(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_parameter_ids       IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(
          p_children_ids
         ,p_parent_id
      );

      INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,mediatyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_media_typ(
          p_media_id       => a.object_id
         ,p_parameters     => p_parameter_ids
         ,p_versionid      => p_versionid
       )
      FROM 
      TABLE(ary_ids) a;

      FOR r IN (
         SELECT 
         a.mediatyp
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.mediatyp.traverse();
      END LOOP;   

   END mediatyp_emulated;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE operationtyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      INSERT 
      INTO dz_swagger3_xobjects(
          object_id
         ,object_type_id
         ,operationtyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_operation_typ(
          p_operation_id => a.object_id
         ,p_versionid    => p_versionid
       )
      FROM
      TABLE(ary_ids) a;
      
      FOR r IN (
         SELECT 
         a.operationtyp
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.operationtyp.traverse();
      END LOOP;
      
   END operationtyp;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE parametertyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
      
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,parametertyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_parameter_typ(
          p_parameter_id => a.object_id
         ,p_versionid    => p_versionid
       )
      FROM 
      TABLE(ary_ids) a;

      FOR r IN (
         SELECT 
         a.parametertyp
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.parametertyp.traverse();
      END LOOP;
   
   END parametertyp;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE pathtyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,pathtyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_path_typ(
          p_path_id    => a.object_id
         ,p_versionid  => p_versionid
       )
      FROM 
      TABLE(ary_ids) a;
      
      FOR r IN (
         SELECT 
         a.pathtyp
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.pathtyp.traverse();
      END LOOP;

   END pathtyp;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE requestbodytyp(
       p_parent_id           IN  VARCHAR2
      ,p_child_id            IN  dz_swagger3_object_typ
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(
          dz_swagger3_object_vry(p_child_id)
         ,p_parent_id
      );

      INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,requestbodytyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_requestbody_typ(
          p_requestbody_id => a.object_id
         ,p_versionid      => p_versionid
       )
      FROM 
      TABLE(ary_ids) a;
      
      FOR r IN (
         SELECT 
         a.requestbodytyp
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.requestbodytyp.traverse();
      END LOOP;

   END requestbodytyp;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE requestbodytyp_emulated(
       p_parent_id           IN  VARCHAR2
      ,p_child_id            IN  dz_swagger3_object_typ
      ,p_parameter_ids       IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(
          dz_swagger3_object_vry(p_child_id)
         ,p_parent_id
      );

      INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,requestbodytyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_requestbody_typ(
          p_requestbody_id => a.object_id
         ,p_parameters     => p_parameter_ids
         ,p_versionid      => p_versionid
       )
      FROM 
      TABLE(ary_ids) a;

      FOR r IN (
         SELECT 
         a.requestbodytyp
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.requestbodytyp.traverse();
      END LOOP;

   END requestbodytyp_emulated;
   
    -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE responsetyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(
          p_children_ids
         ,p_parent_id
      );

      INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,responsetyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_response_typ(
          p_response_id    => a.object_id
         ,p_response_code  => a.object_key
         ,p_versionid      => p_versionid
       )
      FROM 
      TABLE(ary_ids) a;

      FOR r IN (
         SELECT 
         a.responsetyp
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.responsetyp.traverse();
      END LOOP;

   END responsetyp;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE schematyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,schematyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,CASE 
       WHEN a.object_subtype = 'emulated_item'
       THEN
         dz_swagger3_schema_typ(
             p_schema_id             => a.object_id
            ,p_emulated_parameter_id => a.object_attribute
            ,p_versionid             => p_versionid
         )
       ELSE
         dz_swagger3_schema_typ(
             p_schema_id             => a.object_id
            ,p_versionid             => p_versionid
         )
       END
      FROM 
      TABLE(ary_ids) a;
      
      FOR r IN (
         SELECT 
         a.schematyp 
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.schematyp.traverse();
      END LOOP;

   END schematyp;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE schematyp_emulated(
       p_parent_id           IN  VARCHAR2
      ,p_child_id            IN  dz_swagger3_object_typ
      ,p_parameter_ids       IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(
          dz_swagger3_object_vry(p_child_id)
         ,p_parent_id
      );

      INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,schematyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_schema_typ(
          p_schema_id     => a.object_id
         ,p_parameters    => p_parameter_ids
         ,p_versionid     => p_versionid
       )
      FROM 
      TABLE(ary_ids) a;

      FOR r IN (
         SELECT 
         a.schematyp
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.schematyp.traverse();
      END LOOP;

   END schematyp_emulated;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE servertyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      INSERT 
      INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,servertyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_server_typ(
          p_server_id   => a.object_id
         ,p_versionid   => p_versionid
       )
      FROM 
      TABLE(ary_ids) a;
      
      FOR r IN (
         SELECT 
         a.servertyp
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.servertyp.traverse();
      END LOOP;
      
   END servertyp;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE servervartyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      INSERT 
      INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,servervartyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_server_var_typ(
          p_server_var_id  => a.object_id
         ,p_versionid      => p_versionid
       )
      FROM 
      TABLE(ary_ids) a;
      
      -- No subobjects
      
   END servervartyp;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE stringhashtyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;
      str_otype VARCHAR2(255 Char) := 'stringhashtyp';

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      INSERT 
      INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,stringhashtyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_string_hash_typ(
          p_hash_key       => a.object_id
         ,p_string_value   => a.object_key
         ,p_versionid      => p_versionid
       )
      FROM 
      TABLE(ary_ids) a;
      
      -- No subobjects
      
   END stringhashtyp;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE tagtyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;
      str_otype VARCHAR2(255 Char) := 'tagtyp';

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,p_parent_id);

      INSERT 
      INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,tagtyp
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_tag_typ(
          p_tag_id        => a.object_id
         ,p_versionid     => p_versionid
       )
      FROM
      TABLE(ary_ids) a;
      
      FOR r IN (
         SELECT 
         a.tagtyp
         FROM 
         dz_swagger3_xobjects a
         WHERE
         (a.object_id,a.object_type_id) IN (
            SELECT
             b.object_id
            ,b.object_type_id
            FROM
            TABLE(ary_ids) b
         )
      )
      LOOP
         r.tagtyp.traverse();
      END LOOP;
      
   END tagtyp;

END dz_swagger3_loader;
/

