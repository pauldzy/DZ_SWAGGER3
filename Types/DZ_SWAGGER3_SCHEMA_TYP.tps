CREATE OR REPLACE TYPE dz_swagger3_schema_typ FORCE 
UNDER dz_swagger3_schema_typ_nf(
    
    schema_title             VARCHAR2(255 Char)
   ,schema_type              VARCHAR2(255 Char)
   ,schema_description       VARCHAR2(4000 Char)
   ,schema_format            VARCHAR2(255 Char)
   ,schema_nullable          VARCHAR2(5 Char)
   ,schema_discriminator     VARCHAR2(255 Char)
   ,schema_readonly          VARCHAR2(5 Char)
   ,schema_writeonly         VARCHAR2(5 Char)
   ,schema_externalDocs      dz_swagger3_extrdocs_typ
   ,schema_example_string    VARCHAR2(4000 Char)
   ,schema_example_number    NUMBER
   ,schema_deprecated        VARCHAR2(5 Char)
   -----
   ,schema_items_schema      dz_swagger3_schema_typ_nf
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
   ,schema_properties        dz_swagger3_schema_nf_list
   -----
   ,xml_name                 VARCHAR2(255 Char)
   ,xml_namespace            VARCHAR2(2000 Char)
   ,xml_prefix               VARCHAR2(255 Char)
   ,xml_attribute            VARCHAR2(5 Char)
   ,xml_wrapped              VARCHAR2(5 Char)
   ,schema_force_inline      VARCHAR2(5 Char)
   -----
   ,combine_schemas          dz_swagger3_schema_nf_list
   ,not_schema               dz_swagger3_schema_typ_nf

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_schema_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_schema_typ(
       p_hash_key                IN  VARCHAR2
      ,p_schema_id               IN  VARCHAR2
      ,p_required                IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_schema_typ(
       p_schema_id               IN  VARCHAR2
      ,p_schema_title            IN  VARCHAR2
      ,p_schema_type             IN  VARCHAR2
      ,p_schema_description      IN  VARCHAR2
      ,p_schema_format           IN  VARCHAR2
      ,p_schema_nullable         IN  VARCHAR2
      ,p_schema_discriminator    IN  VARCHAR2
      ,p_schema_readonly         IN  VARCHAR2
      ,p_schema_writeonly        IN  VARCHAR2
      ,p_schema_externalDocs     IN  dz_swagger3_extrdocs_typ
      ,p_schema_example_string   IN  VARCHAR2
      ,p_schema_example_number   IN  NUMBER
      ,p_schema_deprecated       IN  VARCHAR2
      ,p_schema_default_string   IN  VARCHAR2
      ,p_schema_default_number   IN  NUMBER 
      ,p_schema_multipleOf       IN  NUMBER 
      ,p_schema_minimum          IN  NUMBER 
      ,p_schema_exclusiveMinimum IN  VARCHAR2
      ,p_schema_maximum          IN  NUMBER 
      ,p_schema_exclusiveMaximum IN  VARCHAR2
      ,p_schema_minLength        IN  INTEGER 
      ,p_schema_maxLength        IN  INTEGER 
      ,p_schema_pattern          IN  VARCHAR2
      ,p_schema_minItems         IN  INTEGER 
      ,p_schema_maxItems         IN  INTEGER 
      ,p_schema_uniqueItems      IN  VARCHAR2 
      ,p_schema_minProperties    IN  INTEGER 
      ,p_schema_maxProperties    IN  INTEGER
      ,p_xml_name                IN  VARCHAR2
      ,p_xml_namespace           IN  VARCHAR2
      ,p_xml_prefix              IN  VARCHAR2
      ,p_xml_attribute           IN  VARCHAR2
      ,p_xml_wrapped             IN  VARCHAR2
      ,p_schema_force_inline     IN  VARCHAR2
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_schema_typ(
       p_schema_id               IN  VARCHAR2
      ,p_schema_title            IN  VARCHAR2
      ,p_schema_type             IN  VARCHAR2
      ,p_schema_description      IN  VARCHAR2
      ,p_schema_format           IN  VARCHAR2
      ,p_schema_nullable         IN  VARCHAR2
      ,p_schema_discriminator    IN  VARCHAR2
      ,p_schema_readonly         IN  VARCHAR2
      ,p_schema_writeonly        IN  VARCHAR2
      ,p_schema_externalDocs     IN  dz_swagger3_extrdocs_typ
      ,p_schema_example_string   IN  VARCHAR2
      ,p_schema_example_number   IN  NUMBER
      ,p_schema_deprecated       IN  VARCHAR2
      ,p_schema_default_string   IN  VARCHAR2
      ,p_schema_default_number   IN  NUMBER 
      ,p_schema_multipleOf       IN  NUMBER 
      ,p_schema_minimum          IN  NUMBER 
      ,p_schema_exclusiveMinimum IN  VARCHAR2
      ,p_schema_maximum          IN  NUMBER 
      ,p_schema_exclusiveMaximum IN  VARCHAR2
      ,p_schema_minLength        IN  INTEGER 
      ,p_schema_maxLength        IN  INTEGER 
      ,p_schema_pattern          IN  VARCHAR2
      ,p_schema_minItems         IN  INTEGER 
      ,p_schema_maxItems         IN  INTEGER 
      ,p_schema_uniqueItems      IN  VARCHAR2 
      ,p_schema_minProperties    IN  INTEGER 
      ,p_schema_maxProperties    IN  INTEGER
      ,p_xml_name                IN  VARCHAR2
      ,p_xml_namespace           IN  VARCHAR2
      ,p_xml_prefix              IN  VARCHAR2
      ,p_xml_attribute           IN  VARCHAR2
      ,p_xml_wrapped             IN  VARCHAR2
      ,p_schema_items_schema     IN  dz_swagger3_schema_typ_nf
      ,p_schema_properties       IN  dz_swagger3_schema_nf_list
      ,p_schema_force_inline     IN  VARCHAR2
      ,p_combine_schemas         IN  dz_swagger3_schema_nf_list
      ,p_not_schema              IN  dz_swagger3_schema_typ_nf
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE addItemsSchema(
       SELF                  IN  OUT NOCOPY dz_swagger3_schema_typ
      ,p_items_schema_id     IN  VARCHAR2
      ,p_versionid           IN  VARCHAR2
   )
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE addProperties(
       SELF                  IN  OUT NOCOPY dz_swagger3_schema_typ
      ,p_versionid           IN  VARCHAR2
   )
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER PROCEDURE prune(
       SELF                  IN  OUT NOCOPY dz_swagger3_schema_typ
   )
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,OVERRIDING MEMBER FUNCTION isNULL
    RETURN VARCHAR2
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION key
    RETURN VARCHAR2
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,OVERRIDING MEMBER FUNCTION doRef
    RETURN VARCHAR2
    
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   ,MEMBER FUNCTION unique_schemas
    RETURN dz_swagger3_schema_nf_list
    
   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   ,MEMBER FUNCTION schema_properties_keys
    RETURN MDSYS.SDO_STRING2_ARRAY
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,OVERRIDING MEMBER FUNCTION toJSON(
       p_pretty_print        IN  INTEGER  DEFAULT NULL
      ,p_jsonschema          IN  VARCHAR2 DEFAULT 'FALSE'       
   ) RETURN CLOB
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,OVERRIDING MEMBER FUNCTION toJSON_schema(
       p_pretty_print        IN  INTEGER  DEFAULT NULL
      ,p_jsonschema          IN  VARCHAR2 DEFAULT 'FALSE'       
   ) RETURN CLOB
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,OVERRIDING MEMBER FUNCTION toJSON_ref(
       p_pretty_print        IN  INTEGER  DEFAULT NULL
      ,p_jsonschema          IN  VARCHAR2 DEFAULT 'FALSE'       
   ) RETURN CLOB
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,OVERRIDING MEMBER FUNCTION toJSON_combine(
       p_pretty_print        IN  INTEGER  DEFAULT NULL
      ,p_jsonschema          IN  VARCHAR2 DEFAULT 'FALSE'       
   ) RETURN CLOB
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,OVERRIDING MEMBER FUNCTION toJSON_not(
       p_pretty_print        IN  INTEGER  DEFAULT NULL
      ,p_jsonschema          IN  VARCHAR2 DEFAULT 'FALSE'       
   ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,OVERRIDING MEMBER FUNCTION toYAML(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
   ) RETURN CLOB
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,OVERRIDING MEMBER FUNCTION toYAML_schema(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
   ) RETURN CLOB
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,OVERRIDING MEMBER FUNCTION toYAML_ref(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
   ) RETURN CLOB
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,OVERRIDING MEMBER FUNCTION toYAML_combine(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
   ) RETURN CLOB
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,OVERRIDING MEMBER FUNCTION toYAML_not(
       p_pretty_print        IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
   ) RETURN CLOB
   
);
/

GRANT EXECUTE ON dz_swagger3_schema_typ TO public;

