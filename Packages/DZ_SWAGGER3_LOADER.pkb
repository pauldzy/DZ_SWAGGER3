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
      a.object_id IS NOT NULL;

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
          p_object_id        => a.object_id
         ,p_object_type_id   => a.object_type_id
         ,p_object_subtype   => a.object_subtype
         ,p_object_attribute => a.object_attribute
         ,p_object_key       => a.object_key
         ,p_object_hidden    => a.object_hidden
         ,p_object_required  => a.object_required
         ,p_object_order     => a.object_order
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
      AND a.object_id IS NOT NULL;
      
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
   BEGIN
      NULL;
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
          ,ordering_key
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_example_typ(
          p_example_id => a.object_id
         ,p_versionid  => p_versionid
       )
      ,a.object_order
      FROM 
      TABLE(ary_ids) a;

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
          ,ordering_key
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_extrdocs_typ(
          p_externaldoc_id => a.object_id
         ,p_versionid      => p_versionid
       )
      ,a.object_order
      FROM 
      TABLE(ary_ids) a;

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
          ,ordering_key
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_header_typ(
          p_header_id => a.object_id
         ,p_versionid      => p_versionid
       )
      ,a.object_order
      FROM 
      TABLE(ary_ids) a;

   END headertyp;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE linktyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   dz_swagger3_object_vry;
      str_otype VARCHAR2(255 Char) := 'linktyp';

   BEGIN
   
      NULL;

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
         ,object_key
         ,mediatyp
         ,ordering_key 
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,a.object_key
      ,dz_swagger3_media_typ(
          p_media_id    => a.object_id
         ,p_media_type  => a.object_key
         ,p_versionid   => p_versionid
       )
      ,a.object_order
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
          ,object_key
          ,mediatyp
          ,ordering_key
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,a.object_key
      ,dz_swagger3_media_typ(
          p_media_id       => a.object_id
         ,p_media_type     => a.object_key
         ,p_parameters     => p_parameter_ids
         ,p_versionid      => p_versionid
       )
      ,a.object_order
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
         ,ordering_key 
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_operation_typ(
          p_operation_id => a.object_id
         ,p_versionid    => p_versionid
       )
      ,a.object_order
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
          ,object_key
          ,object_hidden
          ,parametertyp
          ,ordering_key
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,a.object_key
      ,a.object_hidden
      ,dz_swagger3_parameter_typ(
          p_parameter_id => a.object_id
         ,p_versionid    => p_versionid
       )
      ,a.object_order
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
          ,object_key
          ,pathtyp
          ,ordering_key
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,a.object_key
      ,dz_swagger3_path_typ(
          p_path_id    => a.object_id
         ,p_versionid  => p_versionid
       )
      ,a.object_order
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
          ,object_key
          ,requestbodytyp
          ,ordering_key
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,a.object_key
      ,dz_swagger3_requestbody_typ(
          p_requestbody_id => a.object_id
         ,p_versionid      => p_versionid
       )
      ,a.object_order
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
      ,p_media_type          IN  VARCHAR2
      ,p_parameter_ids       IN  dz_swagger3_object_vry
      ,p_inline_rb           IN  VARCHAR2
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
          ,object_key
          ,requestbodytyp
          ,ordering_key
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,a.object_key
      ,dz_swagger3_requestbody_typ(
          p_requestbody_id => a.object_id
         ,p_media_type     => p_media_type
         ,p_parameters     => p_parameter_ids
         ,p_inline_rb      => p_inline_rb
         ,p_versionid      => p_versionid
       )
      ,a.object_order
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
          ,object_key
          ,responsetyp
          ,ordering_key
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,a.object_key
      ,dz_swagger3_response_typ(
          p_response_id    => a.object_id
         ,p_response_code  => a.object_key
         ,p_versionid      => p_versionid
       )
      ,a.object_order
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
          ,object_key
          ,object_required
          ,schematyp
          ,ordering_key
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,a.object_key
      ,a.object_required
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
            ,p_required              => a.object_required
            ,p_versionid             => p_versionid
         )
       END
      ,a.object_order
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
          ,object_key
          ,schematyp
          ,ordering_key
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,a.object_key
      ,dz_swagger3_schema_typ(
          p_schema_id     => a.object_id
         ,p_parameters    => p_parameter_ids
         ,p_versionid     => p_versionid
       )
      ,a.object_order
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
          ,ordering_key
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_server_typ(
          p_server_id   => a.object_id
         ,p_versionid   => p_versionid
       )
      ,a.object_order
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
          ,object_key
          ,servervartyp
          ,ordering_key
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,a.object_key
      ,dz_swagger3_server_var_typ(
          p_server_var_id  => a.object_id
         ,p_versionid      => p_versionid
       )
      ,a.object_order
      FROM 
      TABLE(ary_ids) a;
      
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
          ,ordering_key
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,dz_swagger3_string_hash_typ(
          p_hash_key       => a.object_id
         ,p_string_value   => a.object_key
         ,p_versionid      => p_versionid
       )
      ,a.object_order
      FROM 
      TABLE(ary_ids) a;
      
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
          ,object_key
          ,tagtyp
          ,ordering_key
      )
      SELECT
       a.object_id
      ,a.object_type_id
      ,a.object_key
      ,dz_swagger3_tag_typ(
          p_tag_id        => a.object_id
         ,p_versionid     => p_versionid
       )
      ,a.object_order
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

