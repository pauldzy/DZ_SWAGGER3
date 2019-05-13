CREATE OR REPLACE TYPE dz_swagger3_response_typ FORCE
AUTHID DEFINER
AS OBJECT (
    response_id              VARCHAR2(255 Char)
   ,response_description     VARCHAR2(4000 Char)
   ,response_headers         MDSYS.SDO_STRING2_ARRAY --dz_swagger3_header_list
   ,response_content         MDSYS.SDO_STRING2_ARRAY --dz_swagger3_media_list
   ,response_links           MDSYS.SDO_STRING2_ARRAY --dz_swagger3_link_list
   ,response_force_inline    VARCHAR2(5 Char)

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_response_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_response_typ(
       p_response_id             IN  VARCHAR2
      ,p_response_code           IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
      ,p_load_components         IN  VARCHAR2 DEFAULT 'TRUE'
      ,p_ref_brake               IN  VARCHAR2 DEFAULT 'FALSE'
   ) RETURN SELF AS RESULT

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_response_typ(
       p_response_id             IN  VARCHAR2
      ,p_response_description    IN  VARCHAR2
      ,p_response_headers        IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_header_list
      ,p_response_content        IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_media_list
      ,p_response_links          IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_link_list
      ,p_load_components         IN  VARCHAR2 DEFAULT 'TRUE'
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
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,STATIC PROCEDURE loader(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  MDSYS.SDO_STRING2_ARRAY
      ,p_versionid           IN  VARCHAR2
   )

);
/

GRANT EXECUTE ON dz_swagger3_response_typ TO public;

