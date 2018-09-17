CREATE OR REPLACE TYPE dz_swagger3_schema_typ_nf FORCE
AUTHID DEFINER 
AS OBJECT (

    dummy INTEGER
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_schema_typ_nf
    RETURN SELF AS RESULT
    
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
      ,p_initial_indent      IN  VARCHAR2  DEFAULT 'TRUE'
      ,p_final_linefeed      IN  VARCHAR2  DEFAULT 'TRUE'
   ) RETURN CLOB

) NOT FINAL;
/

GRANT EXECUTE ON dz_swagger3_schema_typ_nf TO public;

