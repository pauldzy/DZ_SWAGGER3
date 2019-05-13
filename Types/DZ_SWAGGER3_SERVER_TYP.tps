CREATE OR REPLACE TYPE dz_swagger3_server_typ FORCE
AUTHID DEFINER 
AS OBJECT (
    server_url          VARCHAR2(255 Char)
   ,server_description  VARCHAR2(4000 Char)
   ,server_variables    MDSYS.SDO_STRING2_ARRAY --dz_swagger3_server_var_list
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_server_typ
    RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_server_typ(
       p_server_id           IN  VARCHAR2
      ,p_versionid           IN  VARCHAR2 DEFAULT NULL
   ) RETURN SELF AS RESULT
    
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,CONSTRUCTOR FUNCTION dz_swagger3_server_typ(
       p_server_url          IN  VARCHAR2
      ,p_server_description  IN  VARCHAR2
      ,p_server_variables    IN  MDSYS.SDO_STRING2_ARRAY --dz_swagger3_server_var_list
   ) RETURN SELF AS RESULT
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,MEMBER FUNCTION isNULL
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
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   ,STATIC PROCEDURE loader(
       p_parent_id           IN  VARCHAR2
      ,p_children_ids        IN  MDSYS.SDO_STRING2_ARRAY
      ,p_versionid           IN  VARCHAR2
   )

);
/

GRANT EXECUTE ON dz_swagger3_server_typ TO public;

