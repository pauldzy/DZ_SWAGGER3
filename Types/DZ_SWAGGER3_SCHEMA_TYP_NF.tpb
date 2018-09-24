CREATE OR REPLACE TYPE BODY dz_swagger3_schema_typ_nf
AS 

   ----------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_swagger3_schema_typ_nf
   RETURN SELF AS RESULT 
   AS 
   BEGIN 
      RETURN; 
      
   END dz_swagger3_schema_typ_nf;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION isNULL
   RETURN VARCHAR2
   AS
   BEGIN
      RETURN NULL;
      
   END isNULL;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION doRef
   RETURN VARCHAR2
   AS
   BEGIN
      RAISE_APPLICATION_ERROR(-20001,'err');
      RETURN NULL;
      
   END doRef;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON(
       p_pretty_print      IN  INTEGER  DEFAULT NULL
      ,p_jsonschema        IN  VARCHAR2 DEFAULT 'FALSE'       
   ) RETURN CLOB
   AS
   BEGIN
      RETURN NULL;
      
   END toJSON;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON_schema(
       p_pretty_print      IN  INTEGER  DEFAULT NULL
      ,p_jsonschema        IN  VARCHAR2 DEFAULT 'FALSE'       
   ) RETURN CLOB
   AS
   BEGIN
      RETURN NULL;
      
   END toJSON_schema;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON_ref(
       p_pretty_print      IN  INTEGER  DEFAULT NULL
      ,p_jsonschema        IN  VARCHAR2 DEFAULT 'FALSE'       
   ) RETURN CLOB
   AS
   BEGIN
      RETURN NULL;
      
   END toJSON_ref;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON_combine(
       p_pretty_print      IN  INTEGER  DEFAULT NULL
      ,p_jsonschema        IN  VARCHAR2 DEFAULT 'FALSE'       
   ) RETURN CLOB
   AS
   BEGIN
      RETURN NULL;
      
   END toJSON_combine;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toJSON_not(
       p_pretty_print      IN  INTEGER  DEFAULT NULL
      ,p_jsonschema        IN  VARCHAR2 DEFAULT 'FALSE'       
   ) RETURN CLOB
   AS
   BEGIN
      RETURN NULL;
      
   END toJSON_not;
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML(
       p_pretty_print      IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
   ) RETURN CLOB
   AS
   BEGIN
      RETURN NULL;
      
   END toYAML;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML_schema(
       p_pretty_print      IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
   ) RETURN CLOB
   AS
   BEGIN
      RETURN NULL;
      
   END toYAML_schema;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML_ref(
       p_pretty_print      IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
   ) RETURN CLOB
   AS
   BEGIN
      RETURN NULL;
      
   END toYAML_ref;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML_combine(
       p_pretty_print      IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
   ) RETURN CLOB
   AS
   BEGIN
      RETURN NULL;
      
   END toYAML_combine;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   MEMBER FUNCTION toYAML_not(
       p_pretty_print      IN  INTEGER   DEFAULT 0
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
   ) RETURN CLOB
   AS
   BEGIN
      RETURN NULL;
      
   END toYAML_not;
 
END;
/

