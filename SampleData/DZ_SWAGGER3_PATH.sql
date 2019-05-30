SET DEFINE OFF;
Insert into DZ_SWAGGER3_PATH
   (PATH_ID, PATH_ENDPOINT, PATH_GET_OPERATION_ID, PATH_POST_OPERATION_ID, PATH_DESC_UPDATED, 
    PATH_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.Navigation30', '/v3/navigation', 'Sample.Navigation30.GET', 'Sample.Navigation30.POST', TO_DATE('5/25/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_PATH
   (PATH_ID, PATH_ENDPOINT, PATH_GET_OPERATION_ID, PATH_POST_OPERATION_ID, PATH_DESC_UPDATED, 
    PATH_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.Streamcat', '/v1/streamcat', 'Sample.Streamcat.GET', 'Sample.Streamcat.POST', TO_DATE('5/25/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_PATH
   (PATH_ID, PATH_ENDPOINT, PATH_GET_OPERATION_ID, PATH_DESC_UPDATED, PATH_DESC_AUTHOR, 
    VERSIONID)
 Values
   ('Sample.randomnav', '/v1/randomnav', 'Sample.randomnav.GET', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 
    'SAMPLE');
Insert into DZ_SWAGGER3_PATH
   (PATH_ID, PATH_ENDPOINT, PATH_POST_OPERATION_ID, PATH_DESC_UPDATED, PATH_DESC_AUTHOR, 
    VERSIONID)
 Values
   ('Sample.randomnav.Callback', '/v3/navigation', 'Sample.randomnav.Callback.POST', TO_DATE('5/25/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 
    'SAMPLE');
COMMIT;
