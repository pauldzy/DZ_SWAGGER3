SET DEFINE OFF;
Insert into DZ_SWAGGER3_OAUTH_FLOW
   (OAUTH_FLOW_ID, OAUTH_FLOW_AUTHORIZATIONURL, OAUTH_FLOW_REFRESHURL, VERSIONID)
 Values
   ('sample.implicit.flow', 'https://sample.authorization.com', 'https://sample.refreshurl.com', 'SAMPLE');
Insert into DZ_SWAGGER3_OAUTH_FLOW
   (OAUTH_FLOW_ID, OAUTH_FLOW_TOKENURL, OAUTH_FLOW_REFRESHURL, VERSIONID)
 Values
   ('sample.password.flow', 'https://sample.tokenurl.com', 'https://sample.refreshurl.com', 'SAMPLE');
Insert into DZ_SWAGGER3_OAUTH_FLOW
   (OAUTH_FLOW_ID, OAUTH_FLOW_TOKENURL, OAUTH_FLOW_REFRESHURL, VERSIONID)
 Values
   ('sample.clientcredentials.flow', 'https://sample.tokenurl.com', 'https://sample.refreshurl.com', 'SAMPLE');
Insert into DZ_SWAGGER3_OAUTH_FLOW
   (OAUTH_FLOW_ID, OAUTH_FLOW_AUTHORIZATIONURL, OAUTH_FLOW_TOKENURL, OAUTH_FLOW_REFRESHURL, VERSIONID)
 Values
   ('sample.authorizationcode.flow', 'https://sample.authorization.com', 'https://sample.tokenurl.com', 'https://sample.refreshurl.com', 'SAMPLE');
COMMIT;
