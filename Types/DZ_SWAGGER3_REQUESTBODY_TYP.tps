CREATE OR REPLACE TYPE dz_swagger3_requestbody_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    hash_key                 VARCHAR2(255 Char)
   ,requestBody_id           VARCHAR2(255 Char)
   ,requestBody_description  VARCHAR2(4000 Char)
   ,requestBody_inline       VARCHAR2(5 Char)
   ,requestBody_force_inline VARCHAR2(5 Char)
   ,requestBody_content      dz_swagger3_media_list
   ,requestBody_required     VARCHAR2(5 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_requestbody_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_requestbody_typ(
       p_requestbody_id           IN  VARCHAR2
      ,p_versionid                IN  VARCHAR2
      ,p_load_components          IN  VARCHAR2 DEFAULT 'TRUE'
      ,p_ref_brake                IN  VARCHAR2 DEFAULT 'FALSE'
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_requestbody_typ(
       p_requestbody_id           IN  VARCHAR2
      ,p_media_type               IN  VARCHAR2
      ,p_parameters               IN  dz_swagger3_parameter_list
      ,p_inline_rb                IN  VARCHAR2
      ,p_load_components          IN  VARCHAR2 DEFAULT 'TRUE'
   ) RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_requestbody_typ(
       p_hash_key                 IN  VARCHAR2
      ,p_requestbody_id           IN  VARCHAR2
      ,p_requestbody_description  IN  VARCHAR2
      ,p_requestBody_force_inline IN  VARCHAR2
      ,p_requestbody_content      IN  dz_swagger3_media_list
      ,p_requestbody_required     IN  VARCHAR2
      ,p_load_components          IN  VARCHAR2 DEFAULT 'TRUE'
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
   ,MEMBER FUNCTION requestbody_content_keys
    RETURN MDSYS.SDO_STRING2_ARRAY
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print         IN  INTEGER   DEFAULT NULL
      ,p_force_inline         IN  VARCHAR2  DEFAULT 'FALSE'   
    ) RETURN CLOB
    
    -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON_schema(
       p_pretty_print         IN  INTEGER   DEFAULT NULL
      ,p_force_inline         IN  VARCHAR2  DEFAULT 'FALSE' 
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON_ref(
       p_pretty_print         IN  INTEGER   DEFAULT NULL
      ,p_force_inline         IN  VARCHAR2  DEFAULT 'FALSE' 
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print         IN  INTEGER   DEFAULT 0
      ,p_initial_indent       IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed       IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline         IN  VARCHAR2  DEFAULT 'FALSE' 
   ) RETURN CLOB
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML_schema(
       p_pretty_print         IN  INTEGER   DEFAULT 0
      ,p_initial_indent       IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed       IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline         IN  VARCHAR2  DEFAULT 'FALSE' 
   ) RETURN CLOB
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML_ref(
       p_pretty_print         IN  INTEGER   DEFAULT 0
      ,p_initial_indent       IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed       IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline         IN  VARCHAR2  DEFAULT 'FALSE' 
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_requestbody_typ TO public;

