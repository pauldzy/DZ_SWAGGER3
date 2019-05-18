BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE dz_swagger3_xobjects';
EXCEPTION
   WHEN OTHERS THEN NULL;
END;
/ 

CREATE OR REPLACE TYPE dz_swagger3_operation_typ FORCE
AUTHID DEFINER
AS OBJECT (
    operation_id                  VARCHAR2(255 Char)
   ,operation_type                VARCHAR2(255 Char)
   ,operation_tags                dz_swagger3_object_vry --dz_swagger3_tag_list
   ,operation_summary             VARCHAR2(255 Char)
   ,operation_description         VARCHAR2(4000 Char)
   ,operation_externalDocs        dz_swagger3_object_typ --dz_swagger3_extrdocs_typ
   ,operation_operationId         VARCHAR2(255 Char)
   ,operation_parameters          dz_swagger3_object_vry --dz_swagger3_parameter_list
   ,operation_emulated_rbparms    dz_swagger3_object_vry --dz_swagger3_parameter_list
   ,operation_emulated_media_type VARCHAR2(255 Char)
   ,operation_emulated_inline_rb  VARCHAR2(5 Char)
   ,operation_requestBody         dz_swagger3_object_typ --dz_swagger3_requestbody_typ
   ,operation_responses           dz_swagger3_object_vry --dz_swagger3_response_list
   ,operation_callbacks           dz_swagger3_object_vry --dz_swagger3_path_list
   ,operation_inline_rb           VARCHAR2(5 Char)
   ,operation_deprecated          VARCHAR2(5 Char)
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
      ,p_load_components           IN  VARCHAR2 DEFAULT 'TRUE'
      ,p_ref_brake                 IN  VARCHAR2 DEFAULT 'FALSE'
   ) RETURN SELF AS RESULT

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_operation_typ(
       p_operation_id              IN  VARCHAR2
      ,p_operation_type            IN  VARCHAR2
      ,p_operation_tags            IN  dz_swagger3_object_vry --dz_swagger3_tag_list
      ,p_operation_summary         IN  VARCHAR2
      ,p_operation_description     IN  VARCHAR2
      ,p_operation_externalDocs    IN  dz_swagger3_object_typ  --dz_swagger3_extrdocs_typ
      ,p_operation_operationId     IN  VARCHAR2
      ,p_operation_parameters      IN  dz_swagger3_object_vry --dz_swagger3_parameter_list
      ,p_operation_requestBody     IN  dz_swagger3_object_typ --dz_swagger3_requestbody_typ
      ,p_operation_responses       IN  dz_swagger3_object_vry --dz_swagger3_response_list
      ,p_operation_callbacks       IN  dz_swagger3_object_vry --dz_swagger3_callback_list
      ,p_operation_inline_rb       IN  VARCHAR2
      ,p_operation_deprecated      IN  VARCHAR2
      ,p_operation_security        IN  dz_swagger3_object_vry --dz_swagger3_security_req_list
      ,p_operation_servers         IN  dz_swagger3_object_vry --dz_swagger3_server_list
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
   ,MEMBER FUNCTION tags
    RETURN MDSYS.SDO_STRING2_ARRAY
    
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

);
/

GRANT EXECUTE ON dz_swagger3_operation_typ TO public;

