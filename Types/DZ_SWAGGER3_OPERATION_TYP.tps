CREATE OR REPLACE TYPE dz_swagger3_operation_typ FORCE
AUTHID DEFINER
AS OBJECT (
    operation_id                  VARCHAR2(255 Char)
   ,operation_type                VARCHAR2(255 Char)
   ,operation_tags                dz_swagger3_object_vry --dz_swagger3_tag_list
   ,operation_summary             VARCHAR2(255 Char)
   ,operation_description         VARCHAR2(4000 Char)
   ,operation_externalDocs        dz_swagger3_object_typ --dz_swagger3_extrdocs_typ
   ,operation_parameters          dz_swagger3_object_vry --dz_swagger3_parameter_list
   ,operation_emulated_rbparms    dz_swagger3_object_vry --dz_swagger3_parameter_list
   ,operation_requestBody         dz_swagger3_object_typ --dz_swagger3_requestbody_typ
   ,operation_responses           dz_swagger3_object_vry --dz_swagger3_response_list
   ,operation_callbacks           dz_swagger3_object_vry --dz_swagger3_path_list
   ,operation_deprecated          VARCHAR2(5 Char)
   ,operation_inline_rb           VARCHAR2(5 Char)
   ,operation_security            dz_swagger3_object_vry --dz_swagger3_security_req_list
   ,operation_servers             dz_swagger3_object_vry --dz_swagger3_server_list
   ,versionid                     VARCHAR2(255 Char)

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_operation_typ
    RETURN SELF AS RESULT

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_operation_typ(
       p_operation_id              IN  VARCHAR2
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
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_operation_typ TO public;

