CREATE OR REPLACE TYPE dz_swagger3_clob_vry FORCE                                       
AS 
VARRAY(2147483647) OF CLOB;
/

GRANT EXECUTE ON dz_swagger3_clob_vry TO public;

