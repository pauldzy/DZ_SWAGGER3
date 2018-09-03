CREATE OR REPLACE PACKAGE dz_swagger3_constants
AUTHID DEFINER
AS
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   /*
   Header: DZ_SWAGGER3
     
   - Build ID: DZBUILDIDDZ
   - Change Set: DZCHANGESETDZ
   
   PLSQL module for the creation, storage and production of Open API 3.0 service 
   definitions.   Support for the unloading of Swagger JSON specifications into
   the storage tables is not currently supported.   
   
   */
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   /*
   Constant: dz_swagger3_constants.c_table_tablespace
      Tablespace in which to store table resources created by dz_swagger. Leave
      NULL to use the schema default
   */
   c_table_tablespace  CONSTANT VARCHAR2(40 Char) := NULL;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   /*
   Constant: dz_swagger3_constants.c_index_tablespace
      Tablespace in which to store index resources created by dz_swagger. Leave
      NULL to use the schema default
   */
   c_index_tablespace  CONSTANT VARCHAR2(40 Char) := NULL;

END dz_swagger3_constants;
/

GRANT EXECUTE ON dz_swagger3_constants TO PUBLIC;

