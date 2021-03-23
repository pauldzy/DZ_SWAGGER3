SET DEFINE OFF;
Insert into DZ_SWAGGER3_SERVER
   (SERVER_ID, SERVER_URL, SERVER_DESCRIPTION, VERSIONID)
 Values
   ('sample1', 'https://www.google.com', 'Sample Text 1 for server', 'SAMPLE');
Insert into DZ_SWAGGER3_SERVER
   (SERVER_ID, SERVER_URL, SERVER_DESCRIPTION, VERSIONID)
 Values
   ('sample2', 'https://www.bing.com', 'Sample Text 2 for server', 'SAMPLE');
Insert into DZ_SWAGGER3_SERVER
   (SERVER_ID, SERVER_URL, SERVER_DESCRIPTION, VERSIONID)
 Values
   ('sampleWATERS', 'https://api.epa.gov/waters', 'US EPA API Management Portal', 'SAMPLE');
COMMIT;
