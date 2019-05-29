CREATE OR REPLACE TYPE dz_swagger3_link_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    link_id              VARCHAR2(255 Char)
   ,link_operationRef    VARCHAR2(255 Char)
   ,link_operationId     VARCHAR2(255 Char)
   ,link_op_parm_names   MDSYS.SDO_STRING2_ARRAY
   ,link_op_parm_exps    MDSYS.SDO_STRING2_ARRAY
   ,link_requestBody_exp VARCHAR2(4000 Char)
   ,link_description     VARCHAR2(4000 Char)
   ,link_server          dz_swagger3_object_typ --dz_swagger3_server_typ
   ,versionid            VARCHAR2(255 Char)
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_link_typ
    RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_link_typ(
       p_link_id                 IN  VARCHAR2
      ,p_versionid               IN  VARCHAR2
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

GRANT EXECUTE ON dz_swagger3_link_typ TO public;

