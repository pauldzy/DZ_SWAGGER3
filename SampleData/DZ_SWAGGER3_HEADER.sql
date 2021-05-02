SET DEFINE OFF;
Insert into DZ_SWAGGER3_HEADER
   (HEADER_ID, HEADER_DESCRIPTION, HEADER_REQUIRED, HEADER_ALLOWEMPTYVALUE, HEADER_SCHEMA_ID, 
    HEADER_DESC_UPDATED, HEADER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.Header.1', 'Sample Header 1 description of the header', 'TRUE', 'FALSE', 'Sample.Header.String', 
    TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_HEADER
   (HEADER_ID, HEADER_DESCRIPTION, HEADER_REQUIRED, HEADER_ALLOWEMPTYVALUE, HEADER_SCHEMA_ID, 
    HEADER_DESC_UPDATED, HEADER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.Header.2', 'Sample Header 2 description of the header', 'FALSE', 'TRUE', 'Sample.Header.String', 
    TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_HEADER
   (HEADER_ID, HEADER_DESCRIPTION, HEADER_REQUIRED, HEADER_ALLOWEMPTYVALUE, HEADER_SCHEMA_ID, 
    HEADER_DESC_UPDATED, HEADER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.X-Rate-Limit', 'The number of allowed requests in the current period.', 'TRUE', 'FALSE', 'Sample.Header.Integer', 
    TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
COMMIT;
