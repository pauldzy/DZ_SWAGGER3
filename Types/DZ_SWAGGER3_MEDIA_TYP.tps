CREATE OR REPLACE TYPE dz_swagger3_media_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    media_id                 VARCHAR2(255 Char)
   ,media_schema             dz_swagger3_object_typ --dz_swagger3_schema_typ
   ,media_emulated_parms     dz_swagger3_object_vry
   ,media_example_string     VARCHAR2(4000 Char)
   ,media_example_number     NUMBER
   ,media_examples           dz_swagger3_object_vry --dz_swagger3_example_list
   ,media_encoding           dz_swagger3_object_vry --dz_swagger3_encoding_list
   ,versionid                VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_media_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_media_typ(
       p_media_id                 IN  VARCHAR2
      ,p_versionid                IN  VARCHAR2
   ) RETURN SELF AS RESULT

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_media_typ(
       p_media_id                 IN  VARCHAR2
      ,p_parameters               IN  dz_swagger3_object_vry --dz_swagger3_parameter_list
      ,p_versionid                IN  VARCHAR2
   ) RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE traverse
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER   DEFAULT NULL
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
    ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_force_inline        IN  VARCHAR2  DEFAULT 'FALSE'
      ,p_short_id            IN  VARCHAR2  DEFAULT 'FALSE'
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_media_typ TO public;

