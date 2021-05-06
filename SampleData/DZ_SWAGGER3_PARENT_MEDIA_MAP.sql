SET DEFINE OFF;
Insert into DZ_SWAGGER3_PARENT_MEDIA_MAP
   (PARENT_ID, MEDIA_TYPE, MEDIA_ID, MEDIA_ORDER, VERSIONID)
 Values
   ('Sample.Navigation30.DEFAULT', 'application/json', 'Sample.Navigation30.MEDIA', 10, 'SAMPLE');
Insert into DZ_SWAGGER3_PARENT_MEDIA_MAP
   (PARENT_ID, MEDIA_TYPE, MEDIA_ID, MEDIA_ORDER, VERSIONID)
 Values
   ('Sample.Streamcat.DEFAULT', 'application/json', 'Sample.Streamcat.MEDIA', 10, 'SAMPLE');
Insert into DZ_SWAGGER3_PARENT_MEDIA_MAP
   (PARENT_ID, MEDIA_TYPE, MEDIA_ID, MEDIA_ORDER, VERSIONID)
 Values
   ('Sample.Streamcat.DEFAULT', 'application/xml', 'Sample.Streamcat.MEDIA', 20, 'SAMPLE');
Insert into DZ_SWAGGER3_PARENT_MEDIA_MAP
   (PARENT_ID, MEDIA_TYPE, MEDIA_ID, MEDIA_ORDER, VERSIONID)
 Values
   ('Sample.Streamcat.DEFAULT', 'text/csv', 'Sample.csv.download.MEDIA', 30, 'SAMPLE');
Insert into DZ_SWAGGER3_PARENT_MEDIA_MAP
   (PARENT_ID, MEDIA_TYPE, MEDIA_ID, MEDIA_ORDER, VERSIONID)
 Values
   ('Sample.Streamcat.REQUESTBODY', 'application/json', 'Sample.Streamcat.REQUESTBODY.MEDIA', 10, 'SAMPLE');
Insert into DZ_SWAGGER3_PARENT_MEDIA_MAP
   (PARENT_ID, MEDIA_TYPE, MEDIA_ID, MEDIA_ORDER, VERSIONID)
 Values
   ('Sample.randomnav.CALLBACK.DEFAULT', 'application/json', 'Sample.randomnav.CALLBACK.MEDIA', 10, 'SAMPLE');
Insert into DZ_SWAGGER3_PARENT_MEDIA_MAP
   (PARENT_ID, MEDIA_TYPE, MEDIA_ID, MEDIA_ORDER, VERSIONID)
 Values
   ('Sample.randomnav.DEFAULT', 'application/json', 'Sample.randomnav.MEDIA', 10, 'SAMPLE');
COMMIT;
