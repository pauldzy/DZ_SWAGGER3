CREATE OR REPLACE TYPE dz_swagger3_schema_typ FORCE 
AUTHID DEFINER 
AS OBJECT (
    
    schema_id                VARCHAR2(255 Char)
   ,schema_title             VARCHAR2(255 Char)
   ,schema_category          VARCHAR2(255 Char)
   ,schema_type              VARCHAR2(255 Char)
   ,schema_description       VARCHAR2(4000 Char)
   ,schema_format            VARCHAR2(255 Char)
   ,schema_nullable          VARCHAR2(5 Char)
   ,schema_discriminator     VARCHAR2(255 Char)
   ,schema_readonly          VARCHAR2(5 Char)
   ,schema_writeonly         VARCHAR2(5 Char)
   ,schema_externalDocs      dz_swagger3_object_typ --dz_swagger3_extrdocs_typ
   ,schema_example_string    VARCHAR2(4000 Char)
   ,schema_example_number    NUMBER
   ,schema_deprecated        VARCHAR2(5 Char)
   ,schema_required          VARCHAR2(5 Char)
   ,property_list_hidden     VARCHAR2(5 Char)
   ,schema_force_inline      VARCHAR2(5 Char)
   -----
   ,schema_items_schema      dz_swagger3_object_typ --dz_swagger3_schema_typ
   -----
   ,schema_default_string    VARCHAR2(255 Char) 
   ,schema_default_number    NUMBER 
   ,schema_multipleOf        NUMBER 
   ,schema_minimum           NUMBER 
   ,schema_exclusiveMinimum  VARCHAR2(5 Char) 
   ,schema_maximum           NUMBER 
   ,schema_exclusiveMaximum  VARCHAR2(5 Char) 
   ,schema_minLength         INTEGER 
   ,schema_maxLength         INTEGER 
   ,schema_pattern           VARCHAR2(4000 Char) 
   ,schema_minItems          INTEGER 
   ,schema_maxItems          INTEGER 
   ,schema_uniqueItems       VARCHAR2(5 Char) 
   ,schema_minProperties     INTEGER 
   ,schema_maxProperties     INTEGER
   -----
   ,schema_properties        dz_swagger3_object_vry --dz_swagger3_schema_list
   ,schema_emulated_parms    dz_swagger3_object_vry --dz_swagger3_parameter_list
   -----
   ,schema_enum_string       dz_swagger3_string_vry
   ,schema_enum_number       dz_swagger3_number_vry
   -----
   ,xml_name                 VARCHAR2(255 Char)
   ,xml_namespace            VARCHAR2(2000 Char)
   ,xml_prefix               VARCHAR2(255 Char)
   ,xml_attribute            VARCHAR2(5 Char)
   ,xml_wrapped              VARCHAR2(5 Char)
   -----
   ,combine_schemas          dz_swagger3_object_vry --dz_swagger3_schema_list
   -----
   ,inject_jsonschema        VARCHAR2(5 Char)
   ,versionid                VARCHAR2(255 Char)

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_schema_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_schema_typ(
       p_schema_id                IN  VARCHAR2
      ,p_versionid                IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_schema_typ(
       p_schema_id                IN  VARCHAR2
      ,p_parameters               IN  dz_swagger3_object_vry
      ,p_versionid                IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_schema_typ(
       p_schema_id                IN  VARCHAR2
      ,p_emulated_parameter_id    IN  VARCHAR2
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
      ,p_jsonschema          IN  VARCHAR2  DEFAULT 'FALSE'    
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

GRANT EXECUTE ON dz_swagger3_schema_typ TO public;

