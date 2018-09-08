CREATE OR REPLACE TYPE dz_swagger3_security_list FORCE                                       
AS 
TABLE OF dz_swagger_security;
/

GRANT EXECUTE ON dz_swagger3_security_list TO public;

