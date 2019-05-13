CREATE OR REPLACE TYPE dz_swagger3_path_typ FORCE
AUTHID DEFINER
AS OBJECT (
    path_id                  VARCHAR2(255 Char)
   ,path_endpoint            VARCHAR2(255 Char)
   ,path_summary             VARCHAR2(255 Char)
   ,path_description         VARCHAR2(4000 Char)
   ,path_get_operation       VARCHAR2(40 Char)       --dz_swagger3_operation_typ
   ,path_put_operation       VARCHAR2(40 Char)       --dz_swagger3_operation_typ
   ,path_post_operation      VARCHAR2(40 Char)       --dz_swagger3_operation_typ
   ,path_delete_operation    VARCHAR2(40 Char)       --dz_swagger3_operation_typ
   ,path_options_operation   VARCHAR2(40 Char)       --dz_swagger3_operation_typ
   ,path_head_operation      VARCHAR2(40 Char)       --dz_swagger3_operation_typ
   ,path_patch_operation     VARCHAR2(40 Char)       --dz_swagger3_operation_typ
   ,path_trace_operation     VARCHAR2(40 Char)       --dz_swagger3_operation_typ
   ,path_servers             MDSYS.SDO_STRING2_ARRAY --dz_swagger3_server_list
   ,path_parameters          MDSYS.SDO_STRING2_ARRAY --dz_swagger3_parameter_list
   ,versionid                VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_path_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_path_typ(
       p_path_id                   IN  VARCHAR2
      ,p_versionid                 IN  VARCHAR2
      ,p_load_components           IN  VARCHAR2 DEFAULT 'TRUE'
      ,p_ref_brake                 IN  VARCHAR2 DEFAULT 'FALSE'
   ) RETURN SELF AS RESULT

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_path_typ(
       p_path_id                   IN  VARCHAR2
      ,p_path_summary              IN  VARCHAR2
      ,p_path_description          IN  VARCHAR2
      ,p_path_get_operation        IN  VARCHAR2 --dz_swagger3_operation_typ
      ,p_path_put_operation        IN  VARCHAR2 --dz_swagger3_operation_typ
      ,p_path_post_operation       IN  VARCHAR2 --dz_swagger3_operation_typ
      ,p_path_delete_operation     IN  VARCHAR2 --dz_swagger3_operation_typ
      ,p_path_options_operation    IN  VARCHAR2 --dz_swagger3_operation_typ
      ,p_path_head_operation       IN  VARCHAR2 --dz_swagger3_operation_typ
      ,p_path_patch_operation      IN  VARCHAR2 --dz_swagger3_operation_typ
      ,p_path_trace_operation      IN  VARCHAR2 --dz_swagger3_operation_typ
      ,p_path_servers              IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_server_list
      ,p_path_parameters           IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_parameter_list
      ,p_versionid                 IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE traverse

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION isNULL
    RETURN VARCHAR2

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION key
    RETURN VARCHAR2
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,STATIC PROCEDURE loader(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  MDSYS.SDO_STRING2_ARRAY
      ,p_versionid           IN  VARCHAR2
   )

);
/

GRANT EXECUTE ON dz_swagger3_path_typ TO public;

