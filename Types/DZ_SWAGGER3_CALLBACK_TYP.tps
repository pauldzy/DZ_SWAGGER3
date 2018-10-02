CREATE OR REPLACE TYPE dz_swagger3_callback_typ FORCE
AUTHID DEFINER
AS OBJECT (
    hash_key                 VARCHAR2(255 Char)
   ,callback_id              VARCHAR2(255 Char)
   ,path_summary             VARCHAR2(255 Char)
   ,path_description         VARCHAR2(4000 Char)
   ,path_get_operation       dz_swagger3_cboperation_typ
   ,path_put_operation       dz_swagger3_cboperation_typ
   ,path_post_operation      dz_swagger3_cboperation_typ
   ,path_delete_operation    dz_swagger3_cboperation_typ
   ,path_options_operation   dz_swagger3_cboperation_typ
   ,path_head_operation      dz_swagger3_cboperation_typ
   ,path_patch_operation     dz_swagger3_cboperation_typ
   ,path_trace_operation     dz_swagger3_cboperation_typ
   ,path_servers             dz_swagger3_server_list
   ,path_parameters          dz_swagger3_parameter_list
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_callback_typ
    RETURN SELF AS RESULT

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_callback_typ(
       p_hash_key                IN  VARCHAR2
      ,p_callback_id             IN  VARCHAR2
      ,p_path_summary            IN  VARCHAR2
      ,p_path_description        IN  VARCHAR2
      ,p_path_get_operation      IN  dz_swagger3_cboperation_typ
      ,p_path_put_operation      IN  dz_swagger3_cboperation_typ
      ,p_path_post_operation     IN  dz_swagger3_cboperation_typ
      ,p_path_delete_operation   IN  dz_swagger3_cboperation_typ
      ,p_path_options_operation  IN  dz_swagger3_cboperation_typ
      ,p_path_head_operation     IN  dz_swagger3_cboperation_typ
      ,p_path_patch_operation    IN  dz_swagger3_cboperation_typ
      ,p_path_trace_operation    IN  dz_swagger3_cboperation_typ
      ,p_path_servers            IN  dz_swagger3_server_list
      ,p_path_parameters         IN  dz_swagger3_parameter_list
   ) RETURN SELF AS RESULT

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
   ,MEMBER FUNCTION doRef
    RETURN VARCHAR2
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION path_parameters_keys
    RETURN MDSYS.SDO_STRING2_ARRAY

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON_schema(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON_ref(
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
   ,MEMBER FUNCTION toYAML_schema(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML_ref(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_callback_typ TO public;

