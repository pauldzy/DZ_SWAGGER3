SET DEFINE OFF;
Insert into DZ_SWAGGER3_OAUTH_FLOW_SCOPE
   (OAUTH_FLOW_ID, OAUTH_FLOW_SCOPE_NAME, OAUTH_FLOW_SCOPE_DESC, VERSIONID)
 Values
   ('sample.implicit.flow', 'user', 'User Scope', 'SAMPLE');
Insert into DZ_SWAGGER3_OAUTH_FLOW_SCOPE
   (OAUTH_FLOW_ID, OAUTH_FLOW_SCOPE_NAME, OAUTH_FLOW_SCOPE_DESC, VERSIONID)
 Values
   ('sample.implicit.flow', 'admin', 'Admin Scope', 'SAMPLE');
Insert into DZ_SWAGGER3_OAUTH_FLOW_SCOPE
   (OAUTH_FLOW_ID, OAUTH_FLOW_SCOPE_NAME, OAUTH_FLOW_SCOPE_DESC, VERSIONID)
 Values
   ('sample.implicit.flow', 'poweruser', 'Power User Scope', 'SAMPLE');
COMMIT;
