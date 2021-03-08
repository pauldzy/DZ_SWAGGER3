CREATE OR REPLACE TYPE dz_swagger3_requestbody_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    requestBody_id             VARCHAR2(255 Char)
   ,requestBody_description    VARCHAR2(4000 Char)
   ,requestBody_inline         VARCHAR2(5 Char)
   ,requestBody_force_inline   VARCHAR2(5 Char)
   ,requestBody_content        dz_swagger3_object_vry --dz_swagger3_media_list
   ,requestBody_emulated_parms dz_swagger3_object_vry
   ,requestBody_required       VARCHAR2(5 Char)
   ,versionid                  VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_requestbody_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_requestbody_typ(
       p_requestbody_id           IN  VARCHAR2
      ,p_versionid                IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_requestbody_typ(
       p_requestbody_id           IN  VARCHAR2
      ,p_parameters               IN  dz_swagger3_object_vry --dz_swagger3_parameter_list
      ,p_versionid                IN  VARCHAR2
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

GRANT EXECUTE ON dz_swagger3_requestbody_typ TO public;

