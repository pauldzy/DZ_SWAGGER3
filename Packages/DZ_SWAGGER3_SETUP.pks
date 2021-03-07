CREATE OR REPLACE PACKAGE dz_swagger3_setup
AUTHID CURRENT_USER
AS
  
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE create_storage_tables(
       p_table_tablespace VARCHAR2 DEFAULT dz_swagger3_constants.c_table_tablespace
      ,p_index_tablespace VARCHAR2 DEFAULT dz_swagger3_constants.c_index_tablespace
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE create_temp_tables(
       p_table_tablespace VARCHAR2 DEFAULT dz_swagger3_constants.c_table_tablespace
      ,p_index_tablespace VARCHAR2 DEFAULT dz_swagger3_constants.c_index_tablespace
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dz_swagger3_storage_table_list
   RETURN dz_swagger3_string_vry;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dz_swagger3_temp_table_list
   RETURN dz_swagger3_string_vry;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION is_valid
   RETURN dz_swagger3_string_vry PIPELINED;
 
 END dz_swagger3_setup;
/

