SET DEFINE OFF;
Insert into DZ_SWAGGER3_SECURITYSCHEME
   (SECURITYSCHEME_ID, SECURITYSCHEME_TYPE, SECURITYSCHEME_DESCRIPTION, SECURITYSCHEME_NAME, SECURITYSCHEME_IN, 
    VERSIONID)
 Values
   ('SAMPLE.SEC.1', 'apiKey', 'A short description for the scheme.', 'API-SAMPLE-KEY', 'header', 
    'SAMPLE');
Insert into DZ_SWAGGER3_SECURITYSCHEME
   (SECURITYSCHEME_ID, SECURITYSCHEME_TYPE, SECURITYSCHEME_DESCRIPTION, SECURITYSCHEME_SCHEME, VERSIONID)
 Values
   ('SAMPLE.SEC.2', 'http', 'A second short description for the http security.', 'basic', 'SAMPLE');
Insert into DZ_SWAGGER3_SECURITYSCHEME
   (SECURITYSCHEME_ID, SECURITYSCHEME_TYPE, SECURITYSCHEME_DESCRIPTION, OAUTH_FLOW_IMPLICIT, OAUTH_FLOW_PASSWORD, 
    OAUTH_FLOW_CLIENTCREDENTIALS, OAUTH_FLOW_AUTHORIZATIONCODE, VERSIONID)
 Values
   ('SAMPLE.SEC.3', 'oauth2', 'A short description for oauth2 sample.', 'sample.implicit.flow', 'sample.password.flow', 
    'sample.clientcredentials.flow', 'sample.authorizationcode.flow', 'SAMPLE');
Insert into DZ_SWAGGER3_SECURITYSCHEME
   (SECURITYSCHEME_ID, SECURITYSCHEME_TYPE, SECURITYSCHEME_DESCRIPTION, SECURITYSCHEME_OPENIDCREDENTS, VERSIONID)
 Values
   ('SAMPLE.SEC.4', 'openIdConnect', 'Another description regarding OpenIdConnect', 'https://www.openid.org', 'SAMPLE');
COMMIT;
