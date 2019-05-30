SET DEFINE OFF;
Insert into DZ_SWAGGER3_OPERATION
   (OPERATION_ID, OPERATION_TYPE, OPERATION_SUMMARY, OPERATION_DESCRIPTION, OPERATION_EXTERNALDOCS_ID, 
    OPERATION_DESC_UPDATED, OPERATION_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.Navigation30.GET', 'get', 'Sample NHDPlus Navigation v3', 'The Sample Navigation service provides standard stream traversal on the NHDPlus flowline network. The traversal request requires a description of where, on the stream network, to begin the traversal, and a description of where or how to end the traversal. All executions require a navigation search type and a valid start location on the network. Stop location is only required when the navigation type is point-to-point.  Network locations may be specified via any combination of their ComID, Permanent Identifier, Reach Code or Hydro Sequence identifiers.  Providing reach measures allow for precise positioning on the network while leaving measure values empty will result in the entirety of the target hydrologic feature used in the traversal.', 'SAMPLE2', 
    TO_DATE('5/25/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_OPERATION
   (OPERATION_ID, OPERATION_TYPE, OPERATION_SUMMARY, OPERATION_DESCRIPTION, OPERATION_EXTERNALDOCS_ID, 
    OPERATION_DESC_UPDATED, OPERATION_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.Navigation30.POST', 'post', 'Sample NHDPlus Navigation v3', 'The Sample Navigation service provides standard stream traversal on the NHDPlus flowline network. The traversal request requires a description of where, on the stream network, to begin the traversal, and a description of where or how to end the traversal. All executions require a navigation search type and a valid start location on the network. Stop location is only required when the navigation type is point-to-point.  Network locations may be specified via any combination of their ComID, Permanent Identifier, Reach Code or Hydro Sequence identifiers.  Providing reach measures allow for precise positioning on the network while leaving measure values empty will result in the entirety of the target hydrologic feature used in the traversal.', 'SAMPLE2', 
    TO_DATE('5/25/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_OPERATION
   (OPERATION_ID, OPERATION_TYPE, OPERATION_SUMMARY, OPERATION_DESCRIPTION, OPERATION_EXTERNALDOCS_ID, 
    OPERATION_DESC_UPDATED, OPERATION_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.Streamcat.GET', 'get', 'Sample StreamCat Report v1', 'The Sample StreamCat Report service provides [EPA StreamCat](https://www.epa.gov/national-aquatic-resource-surveys/streamcat) attribute values for a catchment identified by one of several input values.', 'SAMPLE3', 
    TO_DATE('5/25/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_OPERATION
   (OPERATION_ID, OPERATION_TYPE, OPERATION_SUMMARY, OPERATION_DESCRIPTION, OPERATION_EXTERNALDOCS_ID, 
    OPERATION_REQUESTBODY_ID, OPERATION_DESC_UPDATED, OPERATION_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.Streamcat.POST', 'post', 'Sample StreamCat Report v1', 'The Sample StreamCat Report service provides [EPA StreamCat](https://www.epa.gov/national-aquatic-resource-surveys/streamcat) attribute values for a catchment identified by one of several input values.', 'SAMPLE3', 
    'Sample.Streamcat.RequestBody', TO_DATE('5/25/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_OPERATION
   (OPERATION_ID, OPERATION_TYPE, OPERATION_SUMMARY, OPERATION_DESCRIPTION, OPERATION_DESC_UPDATED, 
    OPERATION_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.randomnav.Callback.POST', 'post', 'Sample Callback Target', 'A Sample Description of the Callback target.', TO_DATE('5/25/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_OPERATION
   (OPERATION_ID, OPERATION_TYPE, OPERATION_SUMMARY, OPERATION_DESCRIPTION, OPERATION_DESC_UPDATED, 
    OPERATION_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.randomnav.GET', 'get', 'Random ComID Utility', 'The random ComID utility service provides a random ComID and one valid measure for testing and evaluation of NHDPlus based services.', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
COMMIT;
