CREATE OR REPLACE TYPE dz_swagger3_path_typ FORCE
AUTHID DEFINER
AS OBJECT (
    hash_key                 VARCHAR2(255 Char)
   ,path_summary             VARCHAR2(255 Char)
   ,path_description         VARCHAR2(4000 Char)
   ,path_get_operation       dz_swagger3_operation_typ
   ,path_post_operation      dz_swagger3_operation_typ
   ,path_delete_operation    dz_swagger3_operation_typ
   ,path_options_operation   dz_swagger3_operation_typ
   ,path_head_operation      dz_swagger3_operation_typ
   ,path_patch_operation     dz_swagger3_operation_typ
   ,path_trace_operation     dz_swagger3_operation_typ
   ,path_servers             dz_swagger3_server_list
   ,path_parameters          dz_swagger3_parameter_list
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_path_typ
    RETURN SELF AS RESULT

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_path_typ(
       p_hash_key                IN  VARCHAR2
      ,p_path_summary            IN  VARCHAR2
      ,p_path_description        IN  VARCHAR2
      ,p_path_get_operation      IN  dz_swagger3_operation_typ
      ,p_path_post_operation     IN  dz_swagger3_operation_typ
      ,p_path_delete_operation   IN  dz_swagger3_operation_typ
      ,p_path_options_operation  IN  dz_swagger3_operation_typ
      ,p_path_head_operation     IN  dz_swagger3_operation_typ
      ,p_path_patch_operation    IN  dz_swagger3_operation_typ
      ,p_path_trace_operation    IN  dz_swagger3_operation_typ
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
   ,MEMBER FUNCTION path_parameters_keys
    RETURN MDSYS.SDO_STRING2_ARRAY

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
      p_pretty_print      IN  INTEGER   DEFAULT NULL
    ) RETURN CLOB

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
      p_pretty_print      IN  INTEGER   DEFAULT 0
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_path_typ TO public;

