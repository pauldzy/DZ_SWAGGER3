SET DEFINE OFF;
Insert into DZ_SWAGGER3_PARAMETER
   (PARAMETER_ID, PARAMETER_NAME, PARAMETER_IN, PARAMETER_DESCRIPTION, PARAMETER_REQUIRED, 
    PARAMETER_DEPRECATED, PARAMETER_ALLOWEMPTYVALUE, PARAMETER_SCHEMA_ID, PARAMETER_EXAMPLE_STRING, PARAMETER_LIST_HIDDEN, 
    PARAMETER_DESC_UPDATED, PARAMETER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.api_key', 'api_key', 'query', 'api.data.gov registered API key.  The provisional key provided here allows for testing and development against the endpoint but is not suitable for production usage and may be cycled as needed by EPA.', 'TRUE', 
    'FALSE', 'FALSE', 'Sample.parameter.string', 'XcG7zwVwPItaicv1FSfffyZ2ozxyMeD7Deox2ib1', 'FALSE', 
    TO_DATE('4/4/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_PARAMETER
   (PARAMETER_ID, PARAMETER_NAME, PARAMETER_IN, PARAMETER_DESCRIPTION, PARAMETER_REQUIRED, 
    PARAMETER_DEPRECATED, PARAMETER_ALLOWEMPTYVALUE, PARAMETER_SCHEMA_ID, PARAMETER_EXAMPLE_STRING, PARAMETER_LIST_HIDDEN, 
    PARAMETER_DESC_UPDATED, PARAMETER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.f', 'f', 'query', 'Format keyword to govern output.', 'FALSE', 
    'FALSE', 'TRUE', 'Sample.parameter.f', 'json', 'FALSE', 
    TO_DATE('4/4/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_PARAMETER
   (PARAMETER_ID, PARAMETER_NAME, PARAMETER_IN, PARAMETER_DESCRIPTION, PARAMETER_REQUIRED, 
    PARAMETER_DEPRECATED, PARAMETER_ALLOWEMPTYVALUE, PARAMETER_SCHEMA_ID, PARAMETER_LIST_HIDDEN, PARAMETER_DESC_UPDATED, 
    PARAMETER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.pAreaOfInterest', 'pAreaOfInterest', 'query', 'Provide one or more semi-colon delimited area of interest values to filter service results.', 'FALSE', 
    'FALSE', 'TRUE', 'Sample.parameter.string', 'FALSE', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_PARAMETER
   (PARAMETER_ID, PARAMETER_NAME, PARAMETER_IN, PARAMETER_DESCRIPTION, PARAMETER_REQUIRED, 
    PARAMETER_DEPRECATED, PARAMETER_ALLOWEMPTYVALUE, PARAMETER_SCHEMA_ID, PARAMETER_LIST_HIDDEN, PARAMETER_DESC_UPDATED, 
    PARAMETER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.pComID', 'pComID', 'query', 'Provide the ComID integer value representing a NHDPlus networked flowline. ', 'FALSE', 
    'FALSE', 'TRUE', 'Sample.parameter.string', 'FALSE', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_PARAMETER
   (PARAMETER_ID, PARAMETER_NAME, PARAMETER_IN, PARAMETER_DESCRIPTION, PARAMETER_REQUIRED, 
    PARAMETER_DEPRECATED, PARAMETER_ALLOWEMPTYVALUE, PARAMETER_SCHEMA_ID, PARAMETER_EXAMPLE_STRING, PARAMETER_LIST_HIDDEN, 
    PARAMETER_DESC_UPDATED, PARAMETER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.pFeatureID', 'pFeatureID', 'query', 'Provide the FeatureID integer value representing a NHDPlus catchment. ', 'FALSE', 
    'FALSE', 'TRUE', 'Sample.parameter.string', '14783717', 'FALSE', 
    TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_PARAMETER
   (PARAMETER_ID, PARAMETER_NAME, PARAMETER_IN, PARAMETER_DESCRIPTION, PARAMETER_REQUIRED, 
    PARAMETER_DEPRECATED, PARAMETER_ALLOWEMPTYVALUE, PARAMETER_SCHEMA_ID, PARAMETER_LIST_HIDDEN, PARAMETER_DESC_UPDATED, 
    PARAMETER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.pFilenameOverride', 'pFilenameOverride', 'query', 'Optional value to override the default naming convention for data file downloads.  When used with JSON endpoints this forces the payload to download as a file.', 'FALSE', 
    'FALSE', 'TRUE', 'Sample.parameter.string', 'FALSE', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_PARAMETER
   (PARAMETER_ID, PARAMETER_NAME, PARAMETER_IN, PARAMETER_DESCRIPTION, PARAMETER_REQUIRED, 
    PARAMETER_DEPRECATED, PARAMETER_ALLOWEMPTYVALUE, PARAMETER_SCHEMA_ID, PARAMETER_LIST_HIDDEN, PARAMETER_DESC_UPDATED, 
    PARAMETER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.pLandscapeMetricClass', 'pLandscapeMetricClass', 'query', 'Provide one or more semi-colon delimited landscape metric class values to filter service results.', 'FALSE', 
    'FALSE', 'TRUE', 'Sample.parameter.string', 'FALSE', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_PARAMETER
   (PARAMETER_ID, PARAMETER_NAME, PARAMETER_IN, PARAMETER_DESCRIPTION, PARAMETER_REQUIRED, 
    PARAMETER_DEPRECATED, PARAMETER_ALLOWEMPTYVALUE, PARAMETER_SCHEMA_ID, PARAMETER_LIST_HIDDEN, PARAMETER_DESC_UPDATED, 
    PARAMETER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.pLandscapeMetricType', 'pLandscapeMetricType', 'query', 'Provide one or more semi-colon delimited landscape metric type values to filter service results.', 'FALSE', 
    'FALSE', 'TRUE', 'Sample.parameter.string', 'FALSE', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_PARAMETER
   (PARAMETER_ID, PARAMETER_NAME, PARAMETER_IN, PARAMETER_DESCRIPTION, PARAMETER_REQUIRED, 
    PARAMETER_DEPRECATED, PARAMETER_ALLOWEMPTYVALUE, PARAMETER_SCHEMA_ID, PARAMETER_EXAMPLE_STRING, PARAMETER_LIST_HIDDEN, 
    PARAMETER_DESC_UPDATED, PARAMETER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.pMaxDistanceKm', 'pMaxDistanceKm', 'query', 'Distance in kilometers to limit navigatation. If pMaxDistanceKm or pMaxFlowtimeDay is not provided the full extent of the navigation will be returned.  For certain configurations in large networks this is likely to timeout or otherwise fail to return results. ', 'FALSE', 
    'FALSE', 'TRUE', 'Sample.parameter.string', '15', 'FALSE', 
    TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_PARAMETER
   (PARAMETER_ID, PARAMETER_NAME, PARAMETER_IN, PARAMETER_DESCRIPTION, PARAMETER_REQUIRED, 
    PARAMETER_DEPRECATED, PARAMETER_ALLOWEMPTYVALUE, PARAMETER_SCHEMA_ID, PARAMETER_LIST_HIDDEN, PARAMETER_DESC_UPDATED, 
    PARAMETER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.pMaxFlowTimeDay', 'pMaxFlowTimeDay', 'query', 'Maximum flow time in days to navigate.  Only valid with UT, UM, DD and DM navigation.', 'FALSE', 
    'FALSE', 'TRUE', 'Sample.parameter.string', 'FALSE', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_PARAMETER
   (PARAMETER_ID, PARAMETER_NAME, PARAMETER_IN, PARAMETER_DESCRIPTION, PARAMETER_REQUIRED, 
    PARAMETER_DEPRECATED, PARAMETER_ALLOWEMPTYVALUE, PARAMETER_SCHEMA_ID, PARAMETER_LIST_HIDDEN, PARAMETER_DESC_UPDATED, 
    PARAMETER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.pMeasure', 'pMeasure', 'query', 'NHDPlus Reach measure value from 0 to 100 with up to five places of precision.', 'FALSE', 
    'FALSE', 'TRUE', 'Sample.parameter.string', 'FALSE', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_PARAMETER
   (PARAMETER_ID, PARAMETER_NAME, PARAMETER_IN, PARAMETER_DESCRIPTION, PARAMETER_REQUIRED, 
    PARAMETER_DEPRECATED, PARAMETER_ALLOWEMPTYVALUE, PARAMETER_SCHEMA_ID, PARAMETER_EXAMPLE_STRING, PARAMETER_LIST_HIDDEN, 
    PARAMETER_DESC_UPDATED, PARAMETER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.pNavigationType', 'pNavigationType', 'query', 'Navigation methodology for network discovery of events:'||CHR(13)||CHR(10)||'- UT = upstream with tributaries navigation'||CHR(13)||CHR(10)||'- UM = upstream mainstem navigation'||CHR(13)||CHR(10)||'- DD = downstream with divergences navigation'||CHR(13)||CHR(10)||'- DM = downstream mainstem navigation'||CHR(13)||CHR(10)||'- PP = point-to-point downstream navigation', 'TRUE', 
    'FALSE', 'TRUE', 'Sample.parameter.pNavigationType', 'UT', 'FALSE', 
    TO_DATE('1/14/2017', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_PARAMETER
   (PARAMETER_ID, PARAMETER_NAME, PARAMETER_IN, PARAMETER_DESCRIPTION, PARAMETER_REQUIRED, 
    PARAMETER_DEPRECATED, PARAMETER_ALLOWEMPTYVALUE, PARAMETER_SCHEMA_ID, PARAMETER_LIST_HIDDEN, PARAMETER_DESC_UPDATED, 
    PARAMETER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.pPermanentIdentifier', 'pPermanentIdentifier', 'query', 'Provide the Permanent Identifier string value representing a NHDPlus networked flowline. ', 'FALSE', 
    'FALSE', 'TRUE', 'Sample.parameter.string', 'FALSE', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_PARAMETER
   (PARAMETER_ID, PARAMETER_NAME, PARAMETER_IN, PARAMETER_DESCRIPTION, PARAMETER_REQUIRED, 
    PARAMETER_DEPRECATED, PARAMETER_ALLOWEMPTYVALUE, PARAMETER_SCHEMA_ID, PARAMETER_LIST_HIDDEN, PARAMETER_DESC_UPDATED, 
    PARAMETER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.pReachCode', 'pReachCode', 'query', 'NHDPlus Reach Code value.  Enter as 14 character numeric string with all leading zeroes.', 'FALSE', 
    'FALSE', 'TRUE', 'Sample.parameter.string', 'FALSE', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_PARAMETER
   (PARAMETER_ID, PARAMETER_NAME, PARAMETER_IN, PARAMETER_DESCRIPTION, PARAMETER_REQUIRED, 
    PARAMETER_DEPRECATED, PARAMETER_ALLOWEMPTYVALUE, PARAMETER_SCHEMA_ID, PARAMETER_LIST_HIDDEN, PARAMETER_DESC_UPDATED, 
    PARAMETER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.pRegion', 'pRegion', 'query', 'Optional parameter to limit results to a specific NHDPlus grid location.  Valid values include CONUS for the contiguous US (5070), PRVI for Puerto Rico and the Virgin Islands (32161), HAWAII for the Hawaiian Islands (26904), AS for American Samoa (32702) and GUMP for Guam and the Northern Mariana Islands (32655).  Leave empty to inspect all possible locations.', 'FALSE', 
    'FALSE', 'TRUE', 'Sample.parameter.pRegion', 'FALSE', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_PARAMETER
   (PARAMETER_ID, PARAMETER_NAME, PARAMETER_IN, PARAMETER_DESCRIPTION, PARAMETER_REQUIRED, 
    PARAMETER_DEPRECATED, PARAMETER_ALLOWEMPTYVALUE, PARAMETER_SCHEMA_ID, PARAMETER_LIST_HIDDEN, PARAMETER_DESC_UPDATED, 
    PARAMETER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.pReturnGeometry', 'pReturnGeometry', 'query', 'TRUE/FALSE flag to return the watershed geometries in the JSON payload.', 'FALSE', 
    'FALSE', 'TRUE', 'Sample.parameter.string', 'FALSE', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_PARAMETER
   (PARAMETER_ID, PARAMETER_NAME, PARAMETER_IN, PARAMETER_DESCRIPTION, PARAMETER_REQUIRED, 
    PARAMETER_DEPRECATED, PARAMETER_ALLOWEMPTYVALUE, PARAMETER_SCHEMA_ID, PARAMETER_LIST_HIDDEN, PARAMETER_DESC_UPDATED, 
    PARAMETER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.pStartComID', 'pStartComID', 'query', 'NHDPlus flowline ComID integer value from which to begin the navigation.', 'FALSE', 
    'FALSE', 'TRUE', 'Sample.parameter.string', 'FALSE', TO_DATE('1/14/2017', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_PARAMETER
   (PARAMETER_ID, PARAMETER_NAME, PARAMETER_IN, PARAMETER_DESCRIPTION, PARAMETER_REQUIRED, 
    PARAMETER_DEPRECATED, PARAMETER_ALLOWEMPTYVALUE, PARAMETER_SCHEMA_ID, PARAMETER_LIST_HIDDEN, PARAMETER_DESC_UPDATED, 
    PARAMETER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.pStartHydroSequence', 'pStartHydroSequence', 'query', 'NHDPlus flowline Hydro Sequence integer value from which to begin the navigation.', 'FALSE', 
    'FALSE', 'TRUE', 'Sample.parameter.string', 'FALSE', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_PARAMETER
   (PARAMETER_ID, PARAMETER_NAME, PARAMETER_IN, PARAMETER_DESCRIPTION, PARAMETER_REQUIRED, 
    PARAMETER_DEPRECATED, PARAMETER_ALLOWEMPTYVALUE, PARAMETER_SCHEMA_ID, PARAMETER_LIST_HIDDEN, PARAMETER_DESC_UPDATED, 
    PARAMETER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.pStartMeasure', 'pStartMeasure', 'query', 'Measure on the NHDPlus starting reach code to begin navigating from.  Must be between 0 and 100 inclusive, or NULL. A value of NULL means that a measure will be calculated to be either the bottom or the top of the NHD flowline (depending on whether the navigation type is upstream or downstream and whether it is a start or stop measure).', 'FALSE', 
    'FALSE', 'TRUE', 'Sample.parameter.string', 'FALSE', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_PARAMETER
   (PARAMETER_ID, PARAMETER_NAME, PARAMETER_IN, PARAMETER_DESCRIPTION, PARAMETER_REQUIRED, 
    PARAMETER_DEPRECATED, PARAMETER_ALLOWEMPTYVALUE, PARAMETER_SCHEMA_ID, PARAMETER_LIST_HIDDEN, PARAMETER_DESC_UPDATED, 
    PARAMETER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.pStartPermanentIdentifier', 'pStartPermanentIdentifier', 'query', 'NHDPlus flowline Permanent Identifier string value from which to begin the navigation.', 'FALSE', 
    'FALSE', 'TRUE', 'Sample.parameter.string', 'FALSE', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_PARAMETER
   (PARAMETER_ID, PARAMETER_NAME, PARAMETER_IN, PARAMETER_DESCRIPTION, PARAMETER_REQUIRED, 
    PARAMETER_DEPRECATED, PARAMETER_ALLOWEMPTYVALUE, PARAMETER_SCHEMA_ID, PARAMETER_LIST_HIDDEN, PARAMETER_DESC_UPDATED, 
    PARAMETER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.pStartReachCode', 'pStartSourceFeatureID', 'query', 'Reach Address Database event source feature id from which to begin navigating.', 'FALSE', 
    'FALSE', 'TRUE', 'Sample.parameter.string', 'FALSE', TO_DATE('4/4/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_PARAMETER
   (PARAMETER_ID, PARAMETER_NAME, PARAMETER_IN, PARAMETER_DESCRIPTION, PARAMETER_REQUIRED, 
    PARAMETER_DEPRECATED, PARAMETER_ALLOWEMPTYVALUE, PARAMETER_SCHEMA_ID, PARAMETER_LIST_HIDDEN, PARAMETER_DESC_UPDATED, 
    PARAMETER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.pStopComID', 'pStopComID', 'query', 'NHDPlus flowline ComID integer value at which navigation will cease.  Only used in point-to-point navigation.', 'FALSE', 
    'FALSE', 'TRUE', 'Sample.parameter.string', 'FALSE', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_PARAMETER
   (PARAMETER_ID, PARAMETER_NAME, PARAMETER_IN, PARAMETER_DESCRIPTION, PARAMETER_REQUIRED, 
    PARAMETER_DEPRECATED, PARAMETER_ALLOWEMPTYVALUE, PARAMETER_SCHEMA_ID, PARAMETER_LIST_HIDDEN, PARAMETER_DESC_UPDATED, 
    PARAMETER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.pStopHydroSequence', 'pStopHydroSequence', 'query', 'NHDPlus flowline HydroSequence integer value at which navigation will cease.  Only used in point-to-point navigation.', 'FALSE', 
    'FALSE', 'TRUE', 'Sample.parameter.string', 'FALSE', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_PARAMETER
   (PARAMETER_ID, PARAMETER_NAME, PARAMETER_IN, PARAMETER_DESCRIPTION, PARAMETER_REQUIRED, 
    PARAMETER_DEPRECATED, PARAMETER_ALLOWEMPTYVALUE, PARAMETER_SCHEMA_ID, PARAMETER_LIST_HIDDEN, PARAMETER_DESC_UPDATED, 
    PARAMETER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.pStopMeasure', 'pStopMeasure', 'query', 'Measure on the NHDPlus stopping reach code at which navigation will cease.  Must be between 0 and 100 inclusive, or NULL. A value of NULL means that a measure will be calculated to be either the bottom or the top of the NHD flowline (depending on whether the navigation type is upstream or downstream and whether it is a start or stop measure).  Only used in point-to-point navigation.', 'FALSE', 
    'FALSE', 'TRUE', 'Sample.parameter.string', 'FALSE', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_PARAMETER
   (PARAMETER_ID, PARAMETER_NAME, PARAMETER_IN, PARAMETER_DESCRIPTION, PARAMETER_REQUIRED, 
    PARAMETER_DEPRECATED, PARAMETER_ALLOWEMPTYVALUE, PARAMETER_SCHEMA_ID, PARAMETER_LIST_HIDDEN, PARAMETER_DESC_UPDATED, 
    PARAMETER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.pStopPermanentIdentifier', 'pStopPermanentIdentifier', 'query', 'NHDPlus flowline Permanent Identifier string value at which navigation will cease.  Only used in point-to-point navigation.', 'FALSE', 
    'FALSE', 'TRUE', 'Sample.parameter.string', 'FALSE', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_PARAMETER
   (PARAMETER_ID, PARAMETER_NAME, PARAMETER_IN, PARAMETER_DESCRIPTION, PARAMETER_REQUIRED, 
    PARAMETER_DEPRECATED, PARAMETER_ALLOWEMPTYVALUE, PARAMETER_SCHEMA_ID, PARAMETER_LIST_HIDDEN, PARAMETER_DESC_UPDATED, 
    PARAMETER_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.pStopReachCode', 'pStopReachCode', 'query', 'NHDPlus flowline reach code string value at which navigation will cease.  Reach codes must be comprised of 14 digits with leading zeros.  Only used in point-to-point navigation.', 'FALSE', 
    'FALSE', 'TRUE', 'Sample.parameter.string', 'FALSE', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
COMMIT;
