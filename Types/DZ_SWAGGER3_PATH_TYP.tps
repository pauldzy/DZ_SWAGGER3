CREATE OR REPLACE TYPE dz_swagger3_path_typ FORCE
AUTHID DEFINER
AS OBJECT (
    path_id                  VARCHAR2(255 Char)
   ,path_endpoint            VARCHAR2(255 Char)
   ,path_summary             VARCHAR2(255 Char)
   ,path_description         VARCHAR2(4000 Char)
   ,path_get_operation       dz_swagger3_object_typ --dz_swagger3_operation_typ
   ,path_put_operation       dz_swagger3_object_typ --dz_swagger3_operation_typ
   ,path_post_operation      dz_swagger3_object_typ --dz_swagger3_operation_typ
   ,path_delete_operation    dz_swagger3_object_typ --dz_swagger3_operation_typ
   ,path_options_operation   dz_swagger3_object_typ --dz_swagger3_operation_typ
   ,path_head_operation      dz_swagger3_object_typ --dz_swagger3_operation_typ
   ,path_patch_operation     dz_swagger3_object_typ --dz_swagger3_operation_typ
   ,path_trace_operation     dz_swagger3_object_typ --dz_swagger3_operation_typ
   ,path_servers             dz_swagger3_object_vry --dz_swagger3_server_list
   ,path_parameters          dz_swagger3_object_vry --dz_swagger3_parameter_list
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
   ) RETURN SELF AS RESULT

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE traverse

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
    ) RETURN CLOB

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_identifier          IN  VARCHAR2  DEFAULT NULL
      ,p_short_identifier    IN  VARCHAR2  DEFAULT NULL
      ,p_reference_count     IN  INTEGER   DEFAULT NULL
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_path_typ TO public;

