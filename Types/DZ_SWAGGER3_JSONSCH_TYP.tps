CREATE OR REPLACE TYPE dz_swagger3_jsonsch_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    schema_obj     dz_swagger3_schema_typ
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_jsonsch_typ 
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_jsonsch_typ(
       p_path_id              IN  VARCHAR2
      ,p_http_method          IN  VARCHAR2 DEFAULT 'get'
      ,p_response_code        IN  VARCHAR2 DEFAULT 'default'
      ,p_media_type           IN  VARCHAR2 DEFAULT 'application/json'
      ,p_title                IN  VARCHAR2 DEFAULT NULL
      ,p_versionid            IN  VARCHAR2 DEFAULT NULL
   ) RETURN SELF AS RESULT

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
      p_short_id              IN  VARCHAR2 DEFAULT 'FALSE'
   ) RETURN CLOB
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toXML(
      p_short_id              IN  VARCHAR2 DEFAULT 'FALSE'
   ) RETURN XMLTYPE

);
/

GRANT EXECUTE ON dz_swagger3_jsonsch_typ TO public;

