CREATE OR REPLACE PACKAGE dz_swagger3_loader
AUTHID DEFINER
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE encodingtyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE exampletyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE extrdocstyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE headertyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE linktyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE mediatyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE mediatyp_emulated(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_parameter_ids       IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE operationtyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE parametertyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE pathtyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE requestbodytyp(
       p_parent_id           IN  VARCHAR2
      ,p_child_id            IN  dz_swagger3_object_typ
      ,p_versionid           IN  VARCHAR2
   );

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE requestbodytyp_emulated(
       p_parent_id           IN  VARCHAR2
      ,p_child_id            IN  dz_swagger3_object_typ
      ,p_parameter_ids       IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE responsetyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE schematyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE schematyp_emulated(
       p_parent_id           IN  VARCHAR2
      ,p_child_id            IN  dz_swagger3_object_typ
      ,p_parameter_ids       IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE servertyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE servervartyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE stringhashtyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE tagtyp(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  dz_swagger3_object_vry
      ,p_versionid           IN  VARCHAR2
   );
 
 END dz_swagger3_loader;
/

GRANT EXECUTE ON dz_swagger3_loader TO public;

