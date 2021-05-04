SET DEFINE OFF;
Insert into DZ_SWAGGER3_DOC
   (DOC_ID, INFO_TITLE, INFO_DESCRIPTION, INFO_TERMSOFSERVICE, INFO_CONTACT_NAME, 
    INFO_CONTACT_URL, INFO_CONTACT_EMAIL, INFO_LICENSE_NAME, INFO_LICENSE_URL, INFO_VERSION, 
    INFO_DESC_UPDATED, INFO_DESC_AUTHOR, DOC_EXTERNALDOCS_ID, IS_DEFAULT, VERSIONID)
 Values
   ('SAMPLE', 'Sample DZ_SWAGGER3 Services', 'The Sample DZ_SWAGGER3 Services are a mix of imaginary and public REST services provided as an illustration of the capacities of the DZ_SWAGGER3 OpenAPI management framework.', 'https://policies.google.com/terms?hl=en-US', 'Paul Dziemiela', 
    'https://github.com/pauldzy/DZ_SWAGGER3', 'sample_email@sample.com', 'Creative Commons Zero Public Domain Dedication', 'https://edg.epa.gov/EPA_Data_License.html', '1.0.0', 
    TO_DATE('5/25/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE', 'TRUE', 'SAMPLE');
COMMIT;
