﻿SET DEFINE OFF;
Insert into DZ_SWAGGER3_RESPONSE
   (RESPONSE_ID, RESPONSE_DESCRIPTION, RESPONSE_DESC_UPDATED, RESPONSE_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.Navigation30.default', 'Response Object', TO_DATE('5/25/2019', 'MM/DD/YYYY'), 'PDZIEMIE', 'SAMPLE');
Insert into DZ_SWAGGER3_RESPONSE
   (RESPONSE_ID, RESPONSE_DESCRIPTION, RESPONSE_DESC_UPDATED, RESPONSE_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.Streamcat.default', 'Response Object', TO_DATE('5/25/2019', 'MM/DD/YYYY'), 'PDZIEMIE', 'SAMPLE');
Insert into DZ_SWAGGER3_RESPONSE
   (RESPONSE_ID, RESPONSE_DESCRIPTION, RESPONSE_DESC_UPDATED, RESPONSE_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.randomnav.default', 'Response Object', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'PDZIEMIE', 'SAMPLE');
COMMIT;
