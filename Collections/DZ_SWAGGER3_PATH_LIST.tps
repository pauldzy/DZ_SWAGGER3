CREATE OR REPLACE TYPE dz_swagger_path_list FORCE                                       
AS 
TABLE OF dz_swagger_path;
/

GRANT EXECUTE ON dz_swagger_path_list TO public;

