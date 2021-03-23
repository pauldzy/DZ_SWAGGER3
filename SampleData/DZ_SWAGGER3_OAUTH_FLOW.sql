SET DEFINE OFF;
Insert into DZ_SWAGGER3_OAUTH_FLOW
   (OAUTH_FLOW_ID, OAUTH_FLOW_AUTHORIZATIONURL, OAUTH_FLOW_REFRESHURL, VERSIONID)
 Values
   ('sample.implicit.flow', 'https://sampleimplicit.authorization.com', 'https://sampleimplicit.refreshurl.com', 'SAMPLE');
Insert into DZ_SWAGGER3_OAUTH_FLOW
   (OAUTH_FLOW_ID, OAUTH_FLOW_TOKENURL, OAUTH_FLOW_REFRESHURL, VERSIONID)
 Values
   ('sample.password.flow', 'https://password.sampletokenurl.com', 'https://samplepassword.refreshurl.com', 'SAMPLE');
Insert into DZ_SWAGGER3_OAUTH_FLOW
   (OAUTH_FLOW_ID, OAUTH_FLOW_TOKENURL, OAUTH_FLOW_REFRESHURL, VERSIONID)
 Values
   ('sample.clientcredentials.flow', 'https://clientcreds.sampletokenurl.com', 'https://sampleclientcreds.refreshurl.com', 'SAMPLE');
Insert into DZ_SWAGGER3_OAUTH_FLOW
   (OAUTH_FLOW_ID, OAUTH_FLOW_AUTHORIZATIONURL, OAUTH_FLOW_TOKENURL, OAUTH_FLOW_REFRESHURL, VERSIONID)
 Values
   ('sample.authorizationcode.flow', 'https://sampleauth.authorization.com', 'https://authcode.sampletokenurl.com', 'https://sampleauthcodes.refreshurl.com', 'SAMPLE');
COMMIT;
