CREATE OR REPLACE TYPE dz_swagger3_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    versionid           VARCHAR2(40 Char)
   ,group_id            VARCHAR2(255 Char)
   ,info                dz_swagger3_info_typ
   ,servers             dz_swagger3_object_vry --dz_swagger3_server_list
   ,paths               dz_swagger3_object_vry --dz_swagger3_path_list
   ,security            dz_swagger3_object_vry --dz_swagger3_security_req_list
   ,externalDocs        dz_swagger3_object_typ --dz_swagger3_extrdocs_typ
   ,return_code         NUMBER
   ,status_message      VARCHAR2(4000 Char)
   
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
   ,MEMBER FUNCTION toJSON(
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION validity(
       p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_options             IN  VARCHAR2  DEFAULT NULL
    ) RETURN CLOB
    
);
/

GRANT EXECUTE ON dz_swagger3_typ TO public;

