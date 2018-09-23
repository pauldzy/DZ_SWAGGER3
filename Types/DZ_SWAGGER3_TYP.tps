CREATE OR REPLACE TYPE dz_swagger3_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    versionid           VARCHAR2(40 Char)
   ,group_id            VARCHAR2(255 Char)
   ,info                dz_swagger3_info
   ,servers             dz_swagger3_server_list
   ,paths               dz_swagger3_path_list
   ,components          dz_swagger3_components
   ,security            dz_swagger3_security_req_list
   ,tags                dz_swagger3_tag_list
   ,externalDocs        dz_swagger3_extrdocs_typ
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_typ 
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_typ(
       p_doc_id              IN  VARCHAR2
      ,p_group_id            IN  VARCHAR2 DEFAULT NULL
      ,p_versionid           IN  VARCHAR2 DEFAULT NULL
   ) RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_typ(
       p_info                IN  dz_swagger3_info
      ,p_servers             IN  dz_swagger3_server_list
      ,p_paths               IN  dz_swagger3_path_list
      ,p_components          IN  dz_swagger3_components
      ,p_security            IN  dz_swagger3_security_req_list
      ,p_tags                IN  dz_swagger3_tag_list
      ,p_externalDocs        IN  dz_swagger3_extrdocs_typ
    ) RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION unique_requestBodies
    RETURN dz_swagger3_requestBody_list
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION unique_parameters
    RETURN dz_swagger3_parameter_list
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION paths_keys
    RETURN MDSYS.SDO_STRING2_ARRAY
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
      p_pretty_print        IN  INTEGER DEFAULT NULL
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
    ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_typ TO public;

