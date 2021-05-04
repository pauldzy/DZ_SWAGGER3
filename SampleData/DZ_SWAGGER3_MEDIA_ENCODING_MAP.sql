SET DEFINE OFF;
Insert into DZ_SWAGGER3_MEDIA_ENCODING_MAP
   (MEDIA_ID, ENCODING_NAME, ENCODING_ID, ENCODING_ORDER, VERSIONID)
 Values
   ('Sample.Streamcat.MEDIA', 'historyMetadata', 'Sample.Streamcat.Encoding.historyMetadata', 10, 'SAMPLE');
Insert into DZ_SWAGGER3_MEDIA_ENCODING_MAP
   (MEDIA_ID, ENCODING_NAME, ENCODING_ID, ENCODING_ORDER, VERSIONID)
 Values
   ('Sample.Streamcat.MEDIA', 'profileImage', 'Sample.Streamcat.Encoding.profileImage', 20, 'SAMPLE');
COMMIT;
