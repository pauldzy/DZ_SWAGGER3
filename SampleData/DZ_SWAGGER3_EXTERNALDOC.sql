SET DEFINE OFF;
Insert into DZ_SWAGGER3_EXTERNALDOC
   (EXTERNALDOC_ID, EXTERNALDOC_DESCRIPTION, EXTERNALDOC_URL, VERSIONID)
 Values
   ('SAMPLE', 'Sample External Documentation #1', 'https://www.dziemiela.com', 'SAMPLE');
Insert into DZ_SWAGGER3_EXTERNALDOC
   (EXTERNALDOC_ID, EXTERNALDOC_DESCRIPTION, EXTERNALDOC_URL, VERSIONID)
 Values
   ('SAMPLE2', 'Sample External Documentation #2', 'https://www.epa.gov', 'SAMPLE');
Insert into DZ_SWAGGER3_EXTERNALDOC
   (EXTERNALDOC_ID, EXTERNALDOC_DESCRIPTION, EXTERNALDOC_URL, VERSIONID)
 Values
   ('SAMPLE3', 'Sample External Documentation #3', 'https://example.com?foo=123&yada=humperdoo', 'SAMPLE');
Insert into DZ_SWAGGER3_EXTERNALDOC
   (EXTERNALDOC_ID, EXTERNALDOC_DESCRIPTION, EXTERNALDOC_URL, VERSIONID)
 Values
   ('SAMPLE4', 'Sample External Documentation #4', 'https://en.wikipedia.org', 'SAMPLE');
COMMIT;
