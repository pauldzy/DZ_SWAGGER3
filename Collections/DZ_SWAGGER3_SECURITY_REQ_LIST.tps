CREATE OR REPLACE TYPE dz_swagger3_security_req_list FORCE                                       
AS 
TABLE OF dz_swagger_security_req;
/

GRANT EXECUTE ON dz_swagger3_security_req_list TO public;

