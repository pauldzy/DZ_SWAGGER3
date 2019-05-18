CREATE OR REPLACE TYPE dz_swagger3_media_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    media_id                 VARCHAR2(255 Char)
   ,media_type               VARCHAR2(255 Char)
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
      ,p_media_type               IN  VARCHAR2
      ,p_versionid                IN  VARCHAR2
      ,p_ref_brake                IN  VARCHAR2 DEFAULT 'FALSE'
   ) RETURN SELF AS RESULT

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_media_typ(
       p_media_id                 IN  VARCHAR2
      ,p_media_type               IN  VARCHAR2
      ,p_parameters               IN  dz_swagger3_object_vry --dz_swagger3_parameter_list
      ,p_versionid                IN  VARCHAR2
      ,p_ref_brake                IN  VARCHAR2 DEFAULT 'FALSE'
   ) RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_media_typ(
       p_media_id                 IN  VARCHAR2
      ,p_media_schema             IN  dz_swagger3_object_typ --dz_swagger3_schema_typ_nf
      ,p_media_example_string     IN  VARCHAR2
      ,p_media_example_number     IN  NUMBER
      ,p_media_examples           IN  dz_swagger3_object_vry --dz_swagger3_example_list
      ,p_media_encoding           IN  dz_swagger3_object_vry --dz_swagger3_encoding_list
      ,p_versionid                IN  VARCHAR2
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

GRANT EXECUTE ON dz_swagger3_media_typ TO public;

