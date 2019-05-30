SET DEFINE OFF;
Insert into DZ_SWAGGER3_PARENT_HEADER_MAP
   (PARENT_ID, HEADER_NAME, HEADER_ID, HEADER_ORDER, VERSIONID)
 Values
   ('Sample.Streamcat.default', 'Sample-Header-1', 'Sample.Header.1', 10, 'SAMPLE');
Insert into DZ_SWAGGER3_PARENT_HEADER_MAP
   (PARENT_ID, HEADER_NAME, HEADER_ID, HEADER_ORDER, VERSIONID)
 Values
   ('Sample.Streamcat.default', 'Sample-Header-2', 'Sample.Header.2', 20, 'SAMPLE');
Insert into DZ_SWAGGER3_PARENT_HEADER_MAP
   (PARENT_ID, HEADER_NAME, HEADER_ID, HEADER_ORDER, VERSIONID)
 Values
   ('Sample.Streamcat.Encoding.profileImage', 'X-Rate-Limit-Limit', 'Sample.X-Rate-Limit', 10, 'SAMPLE');
COMMIT;
