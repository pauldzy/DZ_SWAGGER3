SET DEFINE OFF;
Insert into DZ_SWAGGER3_SERVER_VARIABLE
   (SERVER_VAR_ID, SERVER_VAR_NAME, SERVER_VAR_ENUM, SERVER_VAR_DEFAULT, SERVER_VAR_DESCRIPTION, 
    VERSIONID)
 Values
   ('oranother', 'oranother', 'blort,yada,trinity', 'yada', 'a classic value of classic worth', 
    'SAMPLE');
Insert into DZ_SWAGGER3_SERVER_VARIABLE
   (SERVER_VAR_ID, SERVER_VAR_NAME, SERVER_VAR_ENUM, SERVER_VAR_DEFAULT, SERVER_VAR_DESCRIPTION, 
    VERSIONID)
 Values
   ('port', 'port', '443,8443,9443', '8443', 'the magical port value generated by unicorns.', 
    'SAMPLE');
Insert into DZ_SWAGGER3_SERVER_VARIABLE
   (SERVER_VAR_ID, SERVER_VAR_NAME, SERVER_VAR_DEFAULT, SERVER_VAR_DESCRIPTION, VERSIONID)
 Values
   ('something', 'something', 'True', 'A sample boolean value', 'SAMPLE');
Insert into DZ_SWAGGER3_SERVER_VARIABLE
   (SERVER_VAR_ID, SERVER_VAR_NAME, SERVER_VAR_DEFAULT, SERVER_VAR_DESCRIPTION, VERSIONID)
 Values
   ('username', 'username', 'demo', 'this value is assigned by small elves in the forest.', 'SAMPLE');
COMMIT;
