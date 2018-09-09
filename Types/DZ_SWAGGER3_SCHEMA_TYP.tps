CREATE OR REPLACE TYPE dz_swagger3_schema_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    schema_id            VARCHAR2(255 Char)
   ,schema_title         VARCHAR2(255 Char)
   ,schema_type          VARCHAR2(255 Char)
   ,schema_description   VARCHAR2(4000 Char)
   ,schema_format        VARCHAR2(255 Char)
   ,schema_nullable      VARCHAR2(5 Char)
   ,schema_discriminator VARCHAR2(255 Char)
   ,schema_readonly      VARCHAR2(5 Char)
   ,schema_writeonly     VARCHAR2(5 Char)
   ,schema_externalDocs  dz_swagger3_extrdocs_typ
   ,schema_example       VARCHAR2(4000 Char)
   ,schema_deprecated    VARCHAR2(5 Char)
   ,xml_name             VARCHAR2(255 Char)
   ,xml_namespace        VARCHAR2(2000 Char)
   ,xml_prefix           VARCHAR2(255 Char)
   ,xml_attribute        VARCHAR2(5 Char)
   ,xml_wrapped          VARCHAR2(5 Char)
   ,schema_properties    dz_swagger3_property_list
   ,dummy                INTEGER

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_schema_typ
    RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_schema_typ(
       p_schema_id            IN  VARCHAR2
      ,p_schema_title         IN  VARCHAR2
      ,p_schema_type          IN  VARCHAR2
      ,p_schema_description   IN  VARCHAR2
      ,p_schema_format        IN  VARCHAR2
      ,p_schema_nullable      IN  VARCHAR2
      ,p_schema_discriminator IN  VARCHAR2
      ,p_schema_readonly      IN  VARCHAR2
      ,p_schema_writeonly     IN  VARCHAR2
      ,p_schema_externalDocs  IN  dz_swagger3_extrdocs_typ
      ,p_schema_example       IN  VARCHAR2
      ,p_schema_deprecated    IN  VARCHAR2
      ,p_xml_name             IN  VARCHAR2
      ,p_xml_namespace        IN  VARCHAR2
      ,p_xml_prefix           IN  VARCHAR2
      ,p_xml_attribute        IN  VARCHAR2
      ,p_xml_wrapped          IN  VARCHAR2
      ,p_schema_properties    IN  dz_swagger3_property_list
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
   ,MEMBER FUNCTION toJSON(
       p_pretty_print      IN  INTEGER  DEFAULT NULL
      ,p_jsonschema        IN  VARCHAR2 DEFAULT 'FALSE'       
   ) RETURN CLOB
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION toYAML(
      p_pretty_print      IN  INTEGER   DEFAULT 0
   ) RETURN CLOB

);
/

GRANT EXECUTE ON dz_swagger3_schema_typ TO public;

