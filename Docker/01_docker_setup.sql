ALTER SESSION SET CONTAINER = XEPDB1;

CREATE USER ECHO_SWAGGER IDENTIFIED BY swagger123;
GRANT CONNECT,RESOURCE,CREATE VIEW TO ECHO_SWAGGER;
ALTER USER ECHO_SWAGGER QUOTA UNLIMITED ON USERS;

BEGIN
   DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
       host => 'dz_badge'
      ,ace  =>  xs$ace_type(
          privilege_list => xs$name_list('connect','resolve')
         ,principal_name => 'ECHO_SWAGGER'
         ,principal_type => xs_acl.ptype_db
      )
   );
   
END;
/

CONNECT ECHO_SWAGGER/swagger123@//localhost:1521/XEPDB1;

@/opt/oracle/scripts/src/dz_swagger3_deploy.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_VALIDATE.sql

@/opt/oracle/scripts/src/DZ_SWAGGER3_DOC.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_ENCODING.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_EXAMPLE.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_EXTERNALDOC.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_GROUP.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_HEADER.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_LINK.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_LINK_OP_PARMS.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_MEDIA.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_MEDIA_ENCODING_MAP.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_OAUTH_FLOW.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_OAUTH_FLOW_SCOPE.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_OPERATION.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_OPERATION_CALL_MAP.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_OPERATION_RESP_MAP.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_OPERATION_TAG_MAP.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_PARAMETER.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_PARENT_EXAMPLE_MAP.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_PARENT_HEADER_MAP.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_PARENT_MEDIA_MAP.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_PARENT_PARM_MAP.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_PARENT_SECSCHM_MAP.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_PARENT_SERVER_MAP.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_PATH.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_REQUESTBODY.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_RESPONSE.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_RESPONSE_LINK_MAP.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_SCHEMA.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_SCHEMA_COMBINE_MAP.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_SCHEMA_ENUM_MAP.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_SCHEMA_PROP_MAP.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_SECURITYSCHEME.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_SERVER.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_SERVER_VARIABLE.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_SERVER_VAR_MAP.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_TAG.sql
@/opt/oracle/scripts/src/DZ_SWAGGER3_VERS.sql

exit;