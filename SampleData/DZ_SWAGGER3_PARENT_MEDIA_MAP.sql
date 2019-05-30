SET DEFINE OFF;
Insert into DZ_SWAGGER3_PARENT_MEDIA_MAP
   (PARENT_ID, MEDIA_TYPE, MEDIA_ID, MEDIA_ORDER, VERSIONID)
 Values
   ('Sample.Navigation30.default', 'application/json', 'Sample.Navigation30.Media', 10, 'SAMPLE');
Insert into DZ_SWAGGER3_PARENT_MEDIA_MAP
   (PARENT_ID, MEDIA_TYPE, MEDIA_ID, MEDIA_ORDER, VERSIONID)
 Values
   ('Sample.Streamcat.RequestBody', 'application/json', 'Sample.Streamcat.RequestBody.Media', 10, 'SAMPLE');
Insert into DZ_SWAGGER3_PARENT_MEDIA_MAP
   (PARENT_ID, MEDIA_TYPE, MEDIA_ID, MEDIA_ORDER, VERSIONID)
 Values
   ('Sample.Streamcat.default', 'application/json', 'Sample.Streamcat.Media', 10, 'SAMPLE');
Insert into DZ_SWAGGER3_PARENT_MEDIA_MAP
   (PARENT_ID, MEDIA_TYPE, MEDIA_ID, MEDIA_ORDER, VERSIONID)
 Values
   ('Sample.Streamcat.default', 'text/csv', 'Sample.csv.download', 20, 'SAMPLE');
Insert into DZ_SWAGGER3_PARENT_MEDIA_MAP
   (PARENT_ID, MEDIA_TYPE, MEDIA_ID, MEDIA_ORDER, VERSIONID)
 Values
   ('Sample.randomnav.default', 'application/json', 'Sample.randomnav.Media', 10, 'SAMPLE');
COMMIT;
