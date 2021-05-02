SET DEFINE OFF;
Insert into DZ_SWAGGER3_EXAMPLE
   (EXAMPLE_ID, EXAMPLE_SUMMARY, EXAMPLE_DESCRIPTION, EXAMPLE_EXTERNALVALUE, VERSIONID)
 Values
   ('Sample.Media.Example', 'A sample media response example.', 'A far longer media response description with detailed description.', 'https://foo.example.com/response-example.txt', 'SAMPLE');
Insert into DZ_SWAGGER3_EXAMPLE
   (EXAMPLE_ID, EXAMPLE_SUMMARY, EXAMPLE_DESCRIPTION, EXAMPLE_VALUE_STRING, VERSIONID)
 Values
   ('Sample.Parm.Example', 'A sample of a parameter.', 'A much longer description of an example of a parameter', 'FOO', 'SAMPLE');
COMMIT;
