SET DEFINE OFF;
Insert into DZ_SWAGGER3_RESPONSE
   (RESPONSE_ID, RESPONSE_DESCRIPTION, RESPONSE_DESC_UPDATED, RESPONSE_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.Navigation30.DEFAULT', 'Response Object', TO_DATE('3/16/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_RESPONSE
   (RESPONSE_ID, RESPONSE_DESCRIPTION, RESPONSE_DESC_UPDATED, RESPONSE_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.Streamcat.DEFAULT', 'Response Object', TO_DATE('3/16/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_RESPONSE
   (RESPONSE_ID, RESPONSE_DESCRIPTION, RESPONSE_DESC_UPDATED, RESPONSE_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.randomnav.CALLBACK.DEFAULT', 'Response Object', TO_DATE('3/22/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_RESPONSE
   (RESPONSE_ID, RESPONSE_DESCRIPTION, RESPONSE_DESC_UPDATED, RESPONSE_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.randomnav.DEFAULT', 'Response Object', TO_DATE('3/16/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
COMMIT;
