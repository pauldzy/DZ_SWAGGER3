SET DEFINE OFF;
Insert into DZ_SWAGGER3_PATH
   (PATH_ID, PATH_ENDPOINT, PATH_GET_OPERATION_ID, PATH_POST_OPERATION_ID, VERSIONID)
 Values
   ('Sample.Navigation30', '/v3/navigation', 'Sample.Navigation30.GET', 'Sample.Navigation30.POST', 'SAMPLE');
Insert into DZ_SWAGGER3_PATH
   (PATH_ID, PATH_ENDPOINT, PATH_POST_OPERATION_ID, PATH_DESC_UPDATED, PATH_DESC_AUTHOR, 
    VERSIONID)
 Values
   ('Sample.Streamcat', '/v1/streamcat', 'Sample.Streamcat.POST', TO_DATE('3/22/2021', 'MM/DD/YYYY'), 'pdziemie', 
    'SAMPLE');
Insert into DZ_SWAGGER3_PATH
   (PATH_ID, PATH_ENDPOINT, PATH_GET_OPERATION_ID, PATH_DESC_UPDATED, PATH_DESC_AUTHOR, 
    VERSIONID)
 Values
   ('Sample.randomnav', '/v1/randomnav', 'Sample.randomnav.GET', TO_DATE('3/22/2021', 'MM/DD/YYYY'), 'pdziemie', 
    'SAMPLE');
Insert into DZ_SWAGGER3_PATH
   (PATH_ID, PATH_ENDPOINT, PATH_POST_OPERATION_ID, PATH_DESC_UPDATED, PATH_DESC_AUTHOR, 
    VERSIONID)
 Values
   ('Sample.randomnav.CALLBACK', '/v1/randomnav/callback/add', 'Sample.randomnav.CALLBACK.POST', TO_DATE('3/22/2021', 'MM/DD/YYYY'), 'pdziemie', 
    'SAMPLE');
COMMIT;
