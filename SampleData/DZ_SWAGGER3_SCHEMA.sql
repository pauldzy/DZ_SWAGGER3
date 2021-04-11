SET DEFINE OFF;
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.Header.Integer', 'scalar', 'Header String Value', 'integer', 'TRUE', 
    TO_DATE('5/27/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.Header.String', 'scalar', 'Header String Value', 'string', 'TRUE', 
    TO_DATE('5/27/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESC_UPDATED, 
    SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.Navigation30.root', 'object', 'Sample Navigation 3.0 Root Schema', 'object', TO_DATE('5/25/2019', 'MM/DD/YYYY'), 
    'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESC_UPDATED, 
    SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.Streamcat.REQUESTBODY.root', 'object', 'Sample RequestBody Root', 'object', TO_DATE('3/22/2021', 'MM/DD/YYYY'), 
    'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESC_UPDATED, 
    SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.Streamcat.root', 'object', 'Sample Streamcat Root Schema', 'object', TO_DATE('5/25/2019', 'MM/DD/YYYY'), 
    'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESC_UPDATED, 
    SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.classic.StatusObject', 'object', 'Status Object', 'object', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 
    'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.common.LinkPath', 'object', 'Result Link Path', 'object', 'TRUE', 
    TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.common.Streams', 'object', 'Streams', 'object', 'TRUE', 
    TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESC_UPDATED, 
    SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.common.Streams.feature', 'object', 'Streams Feature', 'object', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 
    'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_ITEMS_SCHEMA_ID, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.common.Streams.features', 'array', 'Streams Features', 'array', 'Sample.common.Streams.feature', 
    TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESC_UPDATED, 
    SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.common.Streams.properties', 'object', 'Streams Properties', 'object', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 
    'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_FORMAT, SCHEMA_NULLABLE, SCHEMA_DEFAULT_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, 
    VERSIONID)
 Values
   ('Sample.csv.download.root', 'scalar', 'CSV Download', 'string', 'Provides a comma-delimited text file extraction of the dataset for download.', 
    'binary', 'TRUE', 'FALSE', TO_DATE('5/25/2019', 'MM/DD/YYYY'), 'pdziemie', 
    'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.geojson.Feature.type', 'scalar', 'GeoJSON Feature Type', 'string', 'FALSE', 
    'Feature', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.geojson.FeatureCollection.type', 'scalar', 'GeoJSON Feature Collection', 'string', 'FALSE', 
    'FeatureCollection', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.geojson.Geometry', 'object', 'GeoJSON Geometry', 'object', 'TRUE', 
    TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, 
    VERSIONID)
 Values
   ('Sample.geojson.Geometry.coordinates', 'combine', 'GeoJSON Coordinates', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 
    'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_ITEMS_SCHEMA_ID, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.geojson.Geometry.coordinates.1', 'array', 'GeoJSON Coordinates 1', 'array', 'Sample.geojson.Geometry.ordinate', 
    TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_ITEMS_SCHEMA_ID, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.geojson.Geometry.coordinates.2', 'array', 'GeoJSON Coordinates 2', 'array', 'Sample.geojson.Geometry.coordinates.1', 
    TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_ITEMS_SCHEMA_ID, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.geojson.Geometry.coordinates.3', 'array', 'GeoJSON Coordinates 3', 'array', 'Sample.geojson.Geometry.coordinates.2', 
    TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_ITEMS_SCHEMA_ID, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.geojson.Geometry.coordinates.4', 'array', 'GeoJSON Coordinates 4', 'array', 'Sample.geojson.Geometry.coordinates.3', 
    TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_EXAMPLE_NUMBER, 
    XML_NAME, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.geojson.Geometry.ordinate', 'scalar', 'GeoJSON Ordinate', 'number', -89.5327, 
    'ordinate', TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESC_UPDATED, 
    SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.geojson.Geometry.type', 'scalar', 'GeoJSON Type', 'string', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 
    'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_ITEMS_SCHEMA_ID, 
    SCHEMA_MINITEMS, SCHEMA_MAXITEMS, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.geojson.bbox', 'array', 'GeoJSON BBox', 'array', 'Sample.geojson.Geometry.ordinate', 
    4, 4, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DEFAULT_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.parameter.f', 'scalar', 'Format', 'string', 'TRUE', 
    'json', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DEFAULT_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.parameter.pAreaOfInterest', 'scalar', 'pAreaOfInterest', 'string', 'TRUE', 
    'UT', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.parameter.pComID', 'scalar', 'ComID Integer Identifier', 'string', 'TRUE', 
    TO_DATE('5/27/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.parameter.pFeatureID', 'scalar', 'FeatureID Integer Identifier', 'string', 'TRUE', 
    TO_DATE('5/27/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DEFAULT_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.parameter.pFilenameOverride', 'scalar', 'pFilenameOverride', 'string', 'TRUE', 
    'UT', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DEFAULT_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.parameter.pLandscapeMetricClass', 'scalar', 'pLandscapeMetricClass', 'string', 'TRUE', 
    'UT', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DEFAULT_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.parameter.pLandscapeMetricType', 'scalar', 'pLandscapeMetricType', 'string', 'TRUE', 
    'UT', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DEFAULT_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.parameter.pMeasure', 'scalar', 'pMeasure', 'string', 'TRUE', 
    'UT', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DEFAULT_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.parameter.pNavigationType', 'scalar', 'pNavigationType', 'string', 'TRUE', 
    'UT', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DEFAULT_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.parameter.pPermanentIdentifier', 'scalar', 'pPermanentIdentifier', 'string', 'TRUE', 
    'UT', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DEFAULT_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.parameter.pReachCode', 'scalar', 'pReachCode', 'string', 'TRUE', 
    'UT', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.parameter.pRegion', 'scalar', 'pRegion', 'string', 'TRUE', 
    TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DEFAULT_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.parameter.pReturnGeometry', 'scalar', 'pReturnGeometry', 'string', 'TRUE', 
    'UT', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.parameter.string', 'scalar', 'String Value', 'string', 'TRUE', 
    TO_DATE('5/27/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TYPE, SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.area_description', 'scalar', 'string', 'TRUE', 'Area of watershed', 
    TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_EXAMPLE_STRING, XML_NAME, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.area_of_interest', 'scalar', 'Area of Interest', 'string', 'TRUE', 
    'Riparian Buffer (100m)', 'area_of_interest', TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.area_of_interest_id', 'scalar', 'Area of Interest ID', 'string', 'TRUE', 
    'cat', TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TYPE, SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.areasqkm', 'scalar', 'number', 'TRUE', 33.7597, 
    TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.catchment_featureid', 'scalar', 'Catchment Feature ID', 'integer', 'Identifier of the NHDPlus catchment with which the feature is associated.', 
    'TRUE', 14783717, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.coastal', 'scalar', 'Coastal Flag', 'string', 'Flag (Y/N) indicating if a given flowline is a coastline feature.', 
    'TRUE', 'N', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.comid', 'scalar', 'ComID', 'integer', 'Unique integer identifier for NHDPlus features.', 
    'TRUE', 14783717, TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TYPE, SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, 
    XML_NAME, XML_ATTRIBUTE, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.description', 'scalar', 'string', 'TRUE', 'National Hydrography Dataset version 2.1', 
    'description', 'TRUE', TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TYPE, SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, 
    XML_NAME, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.display_alias', 'scalar', 'string', 'TRUE', 'AgMidHiSlopes', 
    'display_name', TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TYPE, SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, 
    XML_NAME, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.display_name', 'scalar', 'string', 'TRUE', '2006 National Land Cover Database', 
    'display_name', TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.dnhydroseq', 'scalar', 'Down Hydrosequence Identifier', 'integer', 'Downstream mainstem hydrologic sequence number.', 
    'TRUE', 510029176, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.execution_time', 'scalar', 'Execution Time', 'number', 'Total time in seconds utilized by the server to provide service results.', 
    'TRUE', 14.963124, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.fcode', 'scalar', 'NHD Feature Code Identifier', 'integer', 'Five-digit integer value comprised of the feature type and combinations of characteristics and values.', 
    'TRUE', 46006, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.fcode_str', 'scalar', 'NHD Feature Code Name', 'string', 'Textual description of the NHDPlus Feature Code.', 
    'TRUE', 'Stream/River: Hydrographic Category = Perennial', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TYPE, SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.filename', 'scalar', 'string', 'TRUE', 'AgMidHiSlopes_<RegionID>.csv', 
    TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TYPE, SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.filter_group', 'scalar', 'string', 'TRUE', 'Riparian Buffer (100m)', 
    TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.fmeasure', 'scalar', 'From Measure', 'number', 'Start measure of an observation or event along an NHDPlus reach - in percentage from the downstream end.', 
    'TRUE', 23.54887, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.format_keyword', 'scalar', 'Format Keyword', 'string', 'TRUE', 
    'Percentage', TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.ftype', 'scalar', 'NHD Feature Type Identifier', 'integer', 'Three digit integer value, unique identifier of a feature type.', 
    'TRUE', 460, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.full_display_name', 'scalar', 'Full Display Name', 'string', 'TRUE', 
    'Agricultural Land Cover 20% Slope', TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.gnis_id', 'scalar', 'NHDPlus GNIS ID', 'string', 'Unique identifier assigned by GNIS, length 10.', 
    'TRUE', '421765', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.gnis_name', 'scalar', 'NHDPlus GNIS Name', 'string', 'Proper name, specific term, or expression by which a particular geographic entity is known, length 65.', 
    'TRUE', 'Des Plaines River', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.hydroseq', 'scalar', 'Hydro Sequence ID', 'integer', 'Hydrologic sequence number; places flowlines in hydrologic order; processing NHDFlowline features in ascending order, encounters the features from downstream to upstream; processing the NHDFlowline features in descending order, encounters the features from upstream to downstream.', 
    'TRUE', 510029993, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TYPE, SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.id', 'scalar', 'string', 'TRUE', 'agmidhislopes', 
    TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.innetwork', 'scalar', 'In Network Flag', 'string', 'Flag (Y/N) indicating if a given flowline is part of the NHDPlus stream network.', 
    'TRUE', 'Y', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, XML_PREFIX, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, 
    VERSIONID)
 Values
   ('Sample.property.is_coast', 'scalar', 'Catchment Coast Flag', 'string', 'Flag (Y/N) indicating if catchment is coastal.', 
    'TRUE', 'Y', 'dz', TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 
    'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, XML_PREFIX, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, 
    VERSIONID)
 Values
   ('Sample.property.is_headwater', 'scalar', 'Catchment Headwater Flag', 'string', 'Flag (Y/N) indicating if catchment is headwater.', 
    'TRUE', 'Y', 'dz', TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 
    'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, XML_PREFIX, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, 
    VERSIONID)
 Values
   ('Sample.property.is_sink', 'scalar', 'Catchment Sink Flag', 'string', 'Flag (Y/N) indicating if catchment is as sink.', 
    'TRUE', 'Y', 'dz', TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 
    'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, XML_PREFIX, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, 
    VERSIONID)
 Values
   ('Sample.property.is_tidal', 'scalar', 'Catchment Tidal Flag', 'string', 'Flag (Y/N) indicating if catchment is tidal.', 
    'TRUE', 'Y', 'dz', TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 
    'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TYPE, SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.landscape_layer_agg', 'scalar', 'string', 'TRUE', 'agmidhislopes', 
    TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TYPE, SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.landscape_layer_id', 'scalar', 'string', 'TRUE', 'agmidhislopes', 
    TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_EXAMPLE_STRING, XML_NAME, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.landscape_metric_class', 'scalar', 'Landscape Metric Class', 'string', 'TRUE', 
    'Disturbance', 'landscape_metric_class', TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_EXAMPLE_STRING, XML_NAME, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.landscape_metric_type', 'scalar', 'Landscape Metric Type', 'string', 'TRUE', 
    'Climate', 'landscape_metric_type', TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TYPE, SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.landscape_percentage', 'scalar', 'number', 'TRUE', 100, 
    TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.lengthkm', 'scalar', 'Length (Km)', 'number', 'Length of linear feature, Albers Equal Area Conic, length 8.', 
    'TRUE', 1.976, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.levelpathid', 'scalar', 'Level Path ID', 'integer', 'Hydrologic sequence number of most downstream NHDFlowline feature in the level path.', 
    'TRUE', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.measure', 'scalar', 'Event Measure', 'number', 'Measure along the reach, in percent from downstream end, where a point event is located.', 
    'TRUE', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TYPE, SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.metadata', 'scalar', 'string', 'TRUE', 'ftp://newftp.epa.gov/EPADataCommons/ORD/NHDPlusLandscapeAttributes/StreamCat/Documentation/Metadata/AgMidHiSlopes.html', 
    TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TYPE, SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.metric_alias', 'scalar', 'string', 'TRUE', 'PctAg2006Slp10Cat', 
    TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TYPE, SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.metric_class', 'scalar', 'string', 'TRUE', 'Disturbance', 
    TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TYPE, SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.metric_type', 'scalar', 'string', 'TRUE', 'Agriculture', 
    TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TYPE, SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.metric_value', 'scalar', 'number', 'TRUE', 23.546, 
    TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.navigable', 'scalar', 'Navigable Flag', 'string', 'TRUE', 
    'Y', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    XML_NAME, XML_PREFIX, XML_ATTRIBUTE, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, 
    VERSIONID)
 Values
   ('Sample.property.notification', 'scalar', 'Notification', 'string', 'TRUE', 
    'notification', 'dz', 'TRUE', TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 
    'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.output_bytes', 'scalar', 'Output Bytes', 'number', 'Total size in bytes of the service results payload.', 
    'TRUE', 60847, TO_DATE('3/23/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.permanent_identifier', 'scalar', 'Permanent Identifier', 'string', 'Global unique identifier assigned to each NHDPlus feature.  In most cases this value will simply be a string copy of the feature ComID.  However particularly in exclaves such as Puerto Rico and Hawaii using more detailed resolutions this value may be an Esri-formatted global unique identifier.', 
    'TRUE', '14783717', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.reachcode', 'scalar', 'Reach Code', 'string', 'A unique, permanent identifier in the National Hydrography Dataset associated with a uniquely identified linear feature that consists of one or more flowlines.', 
    'TRUE', '07120004000094', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_FORMAT, SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, 
    VERSIONID)
 Values
   ('Sample.property.reachsmdate', 'scalar', 'Reach Version Date', 'string', 'Reach version date indicating the last change to the feature identified by the reach code.', 
    'date-time', 'TRUE', '2019-04-26T17:54:00.213Z', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 
    'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.return_code', 'scalar', 'Return Code', 'integer', 'An integer code that is used to determine the nature of an error, and why it occurred.  A value of zero indicates success.', 
    'TRUE', 0, TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TYPE, SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.short_display_name', 'scalar', 'string', 'TRUE', 'Biological Nitrogen Mean Rate', 
    TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.status_code', 'scalar', 'Status Code', 'integer', 'Integer code indicating the overall success or failure of the service call.  A value of zero or null indicates success.', 
    'TRUE', 0, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.status_message', 'scalar', 'Status Message', 'string', 'Message provided with error conditions to elaborate on the cause of service failure.', 
    'TRUE', 'Success', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_FORMAT, SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, 
    VERSIONID)
 Values
   ('Sample.property.streamcat_extract_date', 'scalar', 'StreamCat Extraction Date', 'string', 'Unique Identifier for a project within the assigned grant', 
    'date-time', 'TRUE', '2017-03-27T00:00:00.00+00:00', TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 
    'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.streamcat_url', 'scalar', 'StreamCat URL', 'string', 'Unique Identifier for a project within the assigned grant', 
    'TRUE', 'https://www.epa.gov/national-aquatic-resource-surveys/streamcat', TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.submission_id', 'scalar', 'Submission ID', 'string', 'String identifier used to match submissions to results.', 
    'TRUE', '{2d2d511f-000b-4202-aee2-03b4347468c3}', TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.terminalpathid', 'scalar', 'Terminal Path Identifier', 'integer', 'Hydrologic sequence number of terminal NHDFlowline feature.', 
    'TRUE', 350002977, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.tmeasure', 'scalar', 'To Measure', 'number', 'End measure of an observation or event along an NHDPlus reach - in percentage from the downstream end.', 
    'TRUE', 90.44532, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.total_distancekm', 'scalar', 'Running Total Distance', 'number', 'Running distance in kilometers of the navigation from the start point to this feature.', 
    'TRUE', 5.6388, TO_DATE('3/23/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.total_flowtimeday', 'scalar', 'Total Flow Time (Days)', 'number', 'TRUE', 
    2.4325, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.travtime', 'scalar', 'Travel Time', 'number', 'Travel flow time of the NHDPlus flowline.', 
    'TRUE', 2.4325, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TYPE, SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.unit_of_measure', 'scalar', 'string', 'TRUE', 'kg/ha/yr', 
    TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.uphydroseq', 'scalar', 'Up Hydrosequence', 'integer', 'Upstream mainstem hydrologic sequence number.', 
    'TRUE', 510030895, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.wbarea_comid', 'scalar', 'Waterbody/Area ComID', 'integer', 'ComID of the waterbody through which the Flowline (Artificial Path) flows.', 
    'TRUE', 425689788, TO_DATE('3/23/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.wbarea_permanent_identifier', 'scalar', 'Waterbody/Area Permanent Identifier', 'string', 'Permanent_Identifier of the waterbody through which the Flowline (Artificial Path) flows.', 
    'TRUE', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.wbd_huc12', 'scalar', 'Watershed Boundary Dataset HUC12 ', 'string', 'WBD HUC12 unit that most encompasses the feature.', 
    'TRUE', '071200040104', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESC_UPDATED, 
    SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.randomnav.CALLBACK.root', 'object', 'Random ComID Callback', 'object', TO_DATE('3/22/2021', 'MM/DD/YYYY'), 
    'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESC_UPDATED, 
    SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.randomnav.root', 'object', 'Random ComID', 'object', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 
    'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TYPE, SCHEMA_NULLABLE, SCHEMA_ITEMS_SCHEMA_ID, 
    XML_NAME, XML_WRAPPED, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.streamcat.v1.area_of_interestArray', 'array', 'array', 'TRUE', 'Sample.property.area_of_interest', 
    'areas_of_interest', 'TRUE', TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TYPE, SCHEMA_NULLABLE, XML_NAME, 
    XML_NAMESPACE, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.streamcat.v1.areas_of_interest', 'object', 'object', 'TRUE', 'area_of_interest', 
    'http://www.dziemiela.com', TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TYPE, SCHEMA_NULLABLE, SCHEMA_ITEMS_SCHEMA_ID, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.streamcat.v1.areas_of_interestArray', 'array', 'array', 'TRUE', 'Sample.streamcat.v1.areas_of_interest', 
    TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    XML_NAMESPACE, XML_PREFIX, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.streamcat.v1.identifier_summary', 'object', 'Identifier Summary', 'object', 'TRUE', 
    'http://www.dziemiela.com', 'dz', TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TYPE, SCHEMA_NULLABLE, XML_NAME, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.streamcat.v1.landscape_layers', 'object', 'object', 'TRUE', 'landscape_layer', 
    TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TYPE, SCHEMA_NULLABLE, SCHEMA_ITEMS_SCHEMA_ID, 
    XML_NAME, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.streamcat.v1.landscape_layersArray', 'array', 'array', 'TRUE', 'Sample.streamcat.v1.landscape_layers', 
    'landscape_layers', TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TYPE, SCHEMA_NULLABLE, SCHEMA_ITEMS_SCHEMA_ID, 
    XML_NAME, XML_WRAPPED, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.streamcat.v1.landscape_metric_classArray', 'array', 'array', 'TRUE', 'Sample.property.landscape_metric_class', 
    'landscape_metric_classes', 'TRUE', TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TYPE, SCHEMA_NULLABLE, SCHEMA_ITEMS_SCHEMA_ID, 
    XML_NAME, XML_WRAPPED, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.streamcat.v1.landscape_metric_typeArray', 'array', 'array', 'TRUE', 'Sample.property.landscape_metric_type', 
    'landscape_metric_types', 'TRUE', TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    XML_NAME, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.streamcat.v1.metrics', 'object', 'Metrics', 'object', 'TRUE', 
    'metric', TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TYPE, SCHEMA_NULLABLE, SCHEMA_ITEMS_SCHEMA_ID, 
    XML_NAME, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.streamcat.v1.metricsArray', 'array', 'array', 'TRUE', 'Sample.streamcat.v1.metrics', 
    'metrics', TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESC_UPDATED, 
    SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.streamcat.v1.output', 'object', 'StreamCat Output', 'object', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 
    'pdziemie', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.streamcat.v1.search_criteria', 'object', 'Search Criteria', 'object', 'TRUE', 
    TO_DATE('4/11/2021', 'MM/DD/YYYY'), 'pdziemie', 'SAMPLE');
COMMIT;
