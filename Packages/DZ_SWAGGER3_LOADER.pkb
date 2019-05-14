CREATE OR REPLACE PACKAGE BODY dz_swagger3_loader
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION filter_ids(
       p_children_ids        IN  MDSYS.SDO_STRING2_ARRAY
      ,p_object_type_id      IN  VARCHAR2
      ,p_parent_id           IN  VARCHAR2
   ) RETURN MDSYS.SDO_STRING2_ARRAY
   AS
      ary_output MDSYS.SDO_STRING2_ARRAY;
      
   BEGIN
   
      INSERT INTO dz_swagger3_xrelates(
          parent_object_id
         ,child_object_id
         ,child_object_type_id
      )
      SELECT
       p_parent_id
      ,a.column_value
      ,p_object_type_id
      FROM
      TABLE(p_children_ids) a
      WHERE
      a.column_value IS NOT NULL;
   
      EXECUTE IMMEDIATE
      'SELECT
      a.column_value
      FROM
      TABLE(:p01) a
      WHERE 
      a.column_value NOT IN (
         SELECT b.object_id FROM dz_swagger3_xobjects b
         WHERE b.object_type_id = :p02
      )  
      AND a.column_value IS NOT NULL '
      BULK COLLECT INTO ary_output
      USING 
       p_children_ids
      ,p_object_type_id;
      
      RETURN ary_output;
      
   END filter_ids;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE exampletyp_loader(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  MDSYS.SDO_STRING2_ARRAY
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   MDSYS.SDO_STRING2_ARRAY;
      str_otype VARCHAR2(255 Char) := 'exampletyp';

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,str_otype,p_parent_id);
      
      EXECUTE IMMEDIATE 
      'INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,' || str_otype || '
          ,ordering_key
      )
      SELECT
       a.column_value
      ,:p01
      ,dz_swagger3_example_typ(
          p_example_id => a.column_value
         ,p_versionid      => :p02
       )
      ,10
      FROM 
      TABLE(:p03) a'
      USING
       str_otype
      ,p_versionid
      ,ary_ids;
      
      COMMIT;

   END exampletyp_loader;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE extrdocstyp_loader(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  MDSYS.SDO_STRING2_ARRAY
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   MDSYS.SDO_STRING2_ARRAY;
      str_otype VARCHAR2(255 Char) := 'extrdocstyp';

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,str_otype,p_parent_id);

      EXECUTE IMMEDIATE 
      'INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,' || str_otype || '
          ,ordering_key
      )
      SELECT
       a.column_value
      ,:p01
      ,dz_swagger3_extrdocs_typ(
          p_externaldoc_id => a.column_value
         ,p_versionid      => :p02
       )
      ,10
      FROM 
      TABLE(:p03) a'
      USING
       str_otype
      ,p_versionid
      ,ary_ids;
      
      COMMIT;

   END extrdocstyp_loader;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE headertyp_loader(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  MDSYS.SDO_STRING2_ARRAY
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   MDSYS.SDO_STRING2_ARRAY;
      str_otype VARCHAR2(255 Char) := 'headertyp';

   BEGIN
   
      NULL;

   END headertyp_loader;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE linktyp_loader(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  MDSYS.SDO_STRING2_ARRAY
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   MDSYS.SDO_STRING2_ARRAY;
      str_otype VARCHAR2(255 Char) := 'linktyp';

   BEGIN
   
      NULL;

   END linktyp_loader;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE mediatyp_loader(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  MDSYS.SDO_STRING2_ARRAY
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   MDSYS.SDO_STRING2_ARRAY;
      str_otype VARCHAR2(255 Char) := 'mediatyp';

   BEGIN
   
      NULL;

   END mediatyp_loader;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE operationtyp_loader(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  MDSYS.SDO_STRING2_ARRAY
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   MDSYS.SDO_STRING2_ARRAY;
      str_otype VARCHAR2(255 Char) := 'operationtyp';

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,str_otype,p_parent_id);

      EXECUTE IMMEDIATE '      
      INSERT 
      INTO dz_swagger3_xobjects(
          object_id
         ,object_type_id
         ,' || str_otype || '
         ,ordering_key 
      )
      SELECT
       a.column_value
      ,:p01
      ,dz_swagger3_operation_typ(
          p_operation_id => a.column_value
         ,p_versionid    => :p02
       )
      ,rownum * 10
      FROM
      TABLE(:p03) a '
      USING
       str_otype
      ,p_versionid
      ,ary_ids;
      
      EXECUTE IMMEDIATE
      'BEGIN
         FOR r IN (
            SELECT 
            a.' || str_otype || ' 
            FROM 
            dz_swagger3_xobjects a
            WHERE
            (a.object_id,a.object_type_id) IN (
               SELECT
                b.column_value
               ,:p01
               FROM
               TABLE(:p02) b
            )
         )
         LOOP
            r.' || str_otype || '.traverse();
         END LOOP;

      END;'
      USING
       str_otype
      ,ary_ids;
      
   END operationtyp_loader;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE parametertyp_loader(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  MDSYS.SDO_STRING2_ARRAY
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   MDSYS.SDO_STRING2_ARRAY;
      str_otype VARCHAR2(255 Char) := 'parametertyp';

   BEGIN
      
      ary_ids := filter_ids(p_children_ids,str_otype,p_parent_id);

      EXECUTE IMMEDIATE 
      'INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,object_key
          ,object_hidden
          ,' || str_otype || '
          ,ordering_key
      )
      SELECT
       a.column_value
      ,:p01
      ,a.parameter_name
      ,a.parameter_list_hidden
      ,dz_swagger3_parameter_typ(
          p_parameter_id => a.column_value
         ,p_versionid    => :p02
       )
      ,10
      FROM 
      dz_swagger3_parameter a
      JOIN
      dz_swagger3_parent_parm_map b
      ON
          a.parameter_id = b.parameter_id 
      AND a.versionid    = b.versionid
      JOIN
      TABLE(:p03) c
      ON
      a.parameter_id = c.column_value
      ORDER BY
      b.parameter_order '
      USING
       str_otype
      ,p_versionid
      ,ary_ids;
      
      EXECUTE IMMEDIATE
      'BEGIN
         FOR r IN (
            SELECT 
            a.' || str_otype || ' 
            FROM 
            dz_swagger3_xobjects a
            WHERE
            (a.object_id,a.object_type_id) IN (
               SELECT
                b.column_value
               ,:p01
               FROM
               TABLE(:p02) b
            )
         )
         LOOP
            r.' || str_otype || '.traverse();
         END LOOP;

      END;'
      USING
       str_otype
      ,ary_ids;
      
      COMMIT;
   
   END parametertyp_loader;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE pathtyp_loader(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  MDSYS.SDO_STRING2_ARRAY
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   MDSYS.SDO_STRING2_ARRAY;
      str_otype VARCHAR2(255 Char) := 'pathtyp';

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,str_otype,p_parent_id);

      EXECUTE IMMEDIATE 
      'INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,object_key
          ,' || str_otype || '
          ,ordering_key
      )
      SELECT
       a.path_id
      ,:p01
      ,a.path_endpoint
      ,dz_swagger3_path_typ(
          p_path_id    => a.path_id
         ,p_versionid  => :p02
       )
      ,10
      FROM 
      dz_swagger3_path a
      JOIN
      TABLE(:p03) b
      ON
      a.path_id = b.column_value 
      WHERE
      a.versionid = :p04 '
      USING
       str_otype
      ,p_versionid
      ,ary_ids
      ,p_versionid;
      
      EXECUTE IMMEDIATE
      'BEGIN
         FOR r IN (
            SELECT 
            a.' || str_otype || ' 
            FROM 
            dz_swagger3_xobjects a
            WHERE
            (a.object_id,a.object_type_id) IN (
               SELECT
                b.column_value
               ,:p01
               FROM
               TABLE(:p02) b
            )
         )
         LOOP
            r.' || str_otype || '.traverse();
         END LOOP;

      END;'
      USING
       str_otype
      ,ary_ids;
      
      COMMIT;

   END pathtyp_loader;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE requestbodytyp_loader(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  MDSYS.SDO_STRING2_ARRAY
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   MDSYS.SDO_STRING2_ARRAY;
      str_otype VARCHAR2(255 Char) := 'requestbodytyp';

   BEGIN
   
      NULL;

   END requestbodytyp_loader;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE schematyp_loader(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  MDSYS.SDO_STRING2_ARRAY
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   MDSYS.SDO_STRING2_ARRAY;
      str_otype VARCHAR2(255 Char) := 'schematyp';

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,str_otype,p_parent_id);

      EXECUTE IMMEDIATE 
      'INSERT INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,' || str_otype || '
          ,ordering_key
      )
      SELECT
       a.column_value
      ,:p01
      ,dz_swagger3_schema_typ(
          p_schema_id   => a.column_value
         ,p_versionid   => :p02
       )
      ,10
      FROM 
      TABLE(:p03) a'
      USING
       str_otype
      ,p_versionid
      ,ary_ids;
      
      EXECUTE IMMEDIATE
      'BEGIN
         FOR r IN (
            SELECT 
            a.' || str_otype || ' 
            FROM 
            dz_swagger3_xobjects a
            WHERE
            (a.object_id,a.object_type_id) IN (
               SELECT
                b.column_value
               ,:p01
               FROM
               TABLE(:p02) b
            )
         )
         LOOP
            r.' || str_otype || '.traverse();
         END LOOP;

      END;'
      USING
       str_otype
      ,ary_ids;
      
      COMMIT;

   END schematyp_loader;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE servertyp_loader(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  MDSYS.SDO_STRING2_ARRAY
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   MDSYS.SDO_STRING2_ARRAY;
      str_otype VARCHAR2(255 Char) := 'servertyp';

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,str_otype,p_parent_id);

      EXECUTE IMMEDIATE 
      'INSERT 
      INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,' || str_otype || '
          ,ordering_key
      )
      SELECT
       a.column_value
      ,:p01
      ,dz_swagger3_server_typ(
          p_server_id   => a.column_value
         ,p_versionid   => :p02
       )
      ,rownum * 10
      FROM 
      TABLE(:p03) a '
      USING 
       str_otype
      ,p_versionid
      ,ary_ids;
      
      EXECUTE IMMEDIATE
      'BEGIN
         FOR r IN (
            SELECT 
            a.' || str_otype || ' 
            FROM 
            dz_swagger3_xobjects a
            WHERE
            (a.object_id,a.object_type_id) IN (
               SELECT
                b.column_value
               ,:p01
               FROM
               TABLE(:p02) b
            )
         )
         LOOP
            r.' || str_otype || '.traverse();
         END LOOP;

      END;'
      USING 
       str_otype
      ,ary_ids;
      
   END servertyp_loader;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE servervartyp_loader(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  MDSYS.SDO_STRING2_ARRAY
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   MDSYS.SDO_STRING2_ARRAY;
      str_otype VARCHAR2(255 Char) := 'servervartyp';

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,str_otype,p_parent_id);

      EXECUTE IMMEDIATE 
      'INSERT 
      INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,object_key
          ,' || str_otype || '
          ,ordering_key
      )
      SELECT
       a.column_value
      ,:p01
      ,a.column_value
      ,dz_swagger3_server_var_typ(
          p_server_var_id  => a.column_value
         ,p_versionid      => :p02
       )
      ,rownum * 10
      FROM 
      TABLE(:p03) a '
      USING 
       str_otype
      ,p_versionid
      ,ary_ids;
      
   END servervartyp_loader;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE stringhashtyp_loader(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  MDSYS.SDO_STRING2_ARRAY
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   MDSYS.SDO_STRING2_ARRAY;
      str_otype VARCHAR2(255 Char) := 'stringhashtyp';

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,str_otype,p_parent_id);

      EXECUTE IMMEDIATE 
      'INSERT 
      INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,object_key
          ,' || str_otype || '
          ,ordering_key
      )
      SELECT
       a.column_value
      ,:p01
      ,a.column_value
      ,dz_swagger3_server_var_typ(
          p_server_var_id  => a.column_value
         ,p_versionid      => :p02
       )
      ,rownum * 10
      FROM 
      TABLE(:p03) a '
      USING 
       str_otype
      ,p_versionid
      ,ary_ids;
      
   END stringhashtyp_loader;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE tagtyp_loader(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  MDSYS.SDO_STRING2_ARRAY
      ,p_versionid           IN  VARCHAR2
   )
   AS
      ary_ids   MDSYS.SDO_STRING2_ARRAY;
      str_otype VARCHAR2(255 Char) := 'tagtyp';

   BEGIN
   
      ary_ids := filter_ids(p_children_ids,str_otype,p_parent_id);

      EXECUTE IMMEDIATE 
      'INSERT 
      INTO dz_swagger3_xobjects(
           object_id
          ,object_type_id
          ,object_key
          ,' || str_otype || '
          ,ordering_key
      )
      SELECT
       a.tag_id
      ,:p01
      ,a.tag_name
      ,dz_swagger3_tag_typ(
          p_tag_id           => a.tag_id
         ,p_tag_name         => a.tag_name
         ,p_tag_description  => a.tag_description
         ,p_tag_externalDocs => a.tag_externaldocs_id
         ,p_versionid        => :p02
       )
      ,rownum * 10
      FROM
      dz_swagger3_tag a
      JOIN (
         SELECT
          rownum AS array_order
         ,cc.column_value
         FROM
         TABLE(:p03) cc
      ) c
      ON
      a.tag_id = c.column_value
      WHERE
      a.versionid = :p04 
      ORDER BY 
      c.array_order '
      USING 
       str_otype
      ,p_versionid
      ,ary_ids
      ,p_versionid;
      
      EXECUTE IMMEDIATE
      'BEGIN
         FOR r IN (
            SELECT 
            a.' || str_otype || ' 
            FROM 
            dz_swagger3_xobjects a
            WHERE
            (a.object_id,a.object_type_id) IN (
               SELECT
                b.column_value
               ,:p01
               FROM
               TABLE(:p02) b
            )
         )
         LOOP
            r.' || str_otype || '.traverse();
         END LOOP;

      END;'
      USING 
       str_otype
      ,ary_ids;
      
   END tagtyp_loader;

END dz_swagger3_loader;
/

