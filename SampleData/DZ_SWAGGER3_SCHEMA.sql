﻿SET DEFINE OFF;
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.Header.Integer', 'scalar', 'Header String Value', 'integer', 'TRUE', 
    TO_DATE('5/27/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.Header.String', 'scalar', 'Header String Value', 'string', 'TRUE', 
    TO_DATE('5/27/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESC_UPDATED, 
    SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.Navigation30.root', 'object', 'Sample Navigation 3.0 Root Schema', 'object', TO_DATE('5/25/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESC_UPDATED, 
    SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.Streamcat.RequestBody.root', 'object', 'Sample RequestBody Root', 'object', TO_DATE('5/25/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESC_UPDATED, 
    SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.Streamcat.root', 'object', 'Sample Streamcat Root Schema', 'object', TO_DATE('5/25/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESC_UPDATED, 
    SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.classic.StatusObject', 'object', 'Status Object', 'object', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.common.LinkPath', 'object', 'Result Link Path', 'object', 'TRUE', 
    TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.common.Streams', 'object', 'Streams', 'object', 'TRUE', 
    TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESC_UPDATED, 
    SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.common.Streams.feature', 'object', 'Streams Feature', 'object', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_ITEMS_SCHEMA_ID, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.common.Streams.features', 'array', 'Streams Features', 'array', 'Sample.common.Streams.feature', 
    TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESC_UPDATED, 
    SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.common.Streams.properties', 'object', 'Streams Properties', 'object', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_FORMAT, SCHEMA_NULLABLE, SCHEMA_DEFAULT_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, 
    VERSIONID)
 Values
   ('Sample.csv.download.root', 'scalar', 'CSV Download', 'string', 'Provides a comma-delimited text file extraction of the dataset for download.', 
    'binary', 'TRUE', 'FALSE', TO_DATE('5/25/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 
    'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.geojson.Feature.type', 'scalar', 'GeoJSON Feature Type', 'string', 'FALSE', 
    'Feature', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.geojson.FeatureCollection.type', 'scalar', 'GeoJSON Feature Collection', 'string', 'FALSE', 
    'FeatureCollection', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.geojson.Geometry', 'object', 'GeoJSON Geometry', 'object', 'TRUE', 
    TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, 
    VERSIONID)
 Values
   ('Sample.geojson.Geometry.coordinates', 'combine', 'GeoJSON Coordinates', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 
    'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_ITEMS_SCHEMA_ID, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.geojson.Geometry.coordinates.1', 'array', 'GeoJSON Coordinates 1', 'array', 'Sample.geojson.Geometry.ordinate', 
    TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_ITEMS_SCHEMA_ID, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.geojson.Geometry.coordinates.2', 'array', 'GeoJSON Coordinates 2', 'array', 'Sample.geojson.Geometry.coordinates.1', 
    TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_ITEMS_SCHEMA_ID, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.geojson.Geometry.coordinates.3', 'array', 'GeoJSON Coordinates 3', 'array', 'Sample.geojson.Geometry.coordinates.2', 
    TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_ITEMS_SCHEMA_ID, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.geojson.Geometry.coordinates.4', 'array', 'GeoJSON Coordinates 4', 'array', 'Sample.geojson.Geometry.coordinates.3', 
    TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_EXAMPLE_NUMBER, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.geojson.Geometry.ordinate', 'scalar', 'GeoJSON Ordinate', 'number', -89.5327, 
    TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESC_UPDATED, 
    SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.geojson.Geometry.type', 'scalar', 'GeoJSON Type', 'string', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_ITEMS_SCHEMA_ID, 
    SCHEMA_MINITEMS, SCHEMA_MAXITEMS, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.geojson.bbox', 'array', 'GeoJSON BBox', 'array', 'Sample.geojson.Geometry.ordinate', 
    4, 4, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DEFAULT_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.parameter.f', 'scalar', 'Format', 'string', 'TRUE', 
    'json', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DEFAULT_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.parameter.pAreaOfInterest', 'scalar', 'pAreaOfInterest', 'string', 'TRUE', 
    'UT', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.parameter.pComID', 'scalar', 'ComID Integer Identifier', 'string', 'TRUE', 
    TO_DATE('5/27/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.parameter.pFeatureID', 'scalar', 'FeatureID Integer Identifier', 'string', 'TRUE', 
    TO_DATE('5/27/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DEFAULT_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.parameter.pFilenameOverride', 'scalar', 'pFilenameOverride', 'string', 'TRUE', 
    'UT', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DEFAULT_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.parameter.pLandscapeMetricClass', 'scalar', 'pLandscapeMetricClass', 'string', 'TRUE', 
    'UT', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DEFAULT_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.parameter.pLandscapeMetricType', 'scalar', 'pLandscapeMetricType', 'string', 'TRUE', 
    'UT', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DEFAULT_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.parameter.pMeasure', 'scalar', 'pMeasure', 'string', 'TRUE', 
    'UT', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DEFAULT_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.parameter.pNavigationType', 'scalar', 'pNavigationType', 'string', 'TRUE', 
    'UT', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DEFAULT_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.parameter.pPermanentIdentifier', 'scalar', 'pPermanentIdentifier', 'string', 'TRUE', 
    'UT', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DEFAULT_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.parameter.pReachCode', 'scalar', 'pReachCode', 'string', 'TRUE', 
    'UT', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.parameter.pRegion', 'scalar', 'pRegion', 'string', 'TRUE', 
    TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DEFAULT_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.parameter.pReturnGeometry', 'scalar', 'pReturnGeometry', 'string', 'TRUE', 
    'UT', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.parameter.string', 'scalar', 'String Value', 'string', 'TRUE', 
    TO_DATE('5/27/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.catchment_featureid', 'scalar', 'Catchment Feature ID', 'integer', 'Identifier of the NHDPlus catchment with which the feature is associated.', 
    'TRUE', 14783717, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.coastal', 'scalar', 'Coastal Flag', 'string', 'Flag (Y/N) indicating if a given flowline is a coastline feature.', 
    'TRUE', 'N', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.comid', 'scalar', 'ComID', 'integer', 'Unique integer identifier for NHDPlus features.', 
    'TRUE', 14783717, TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.dnhydroseq', 'scalar', 'Down Hydrosequence Identifier', 'integer', 'Downstream mainstem hydrologic sequence number.', 
    'TRUE', 510029176, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.execution_time', 'scalar', 'Execution Time', 'number', 'Total time in seconds utilized by the server to provide service results.', 
    'TRUE', 14.963124, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.fcode', 'scalar', 'NHD Feature Code Identifier', 'integer', 'Five-digit integer value comprised of the feature type and combinations of characteristics and values.', 
    'TRUE', 46006, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.fcode_str', 'scalar', 'NHD Feature Code Name', 'string', 'Textual description of the NHDPlus Feature Code.', 
    'TRUE', 'Stream/River: Hydrographic Category = Perennial', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.fmeasure', 'scalar', 'From Measure', 'number', 'Start measure of an observation or event along an NHDPlus reach - in percentage from the downstream end.', 
    'TRUE', 23.54887, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.ftype', 'scalar', 'NHD Feature Type Identifier', 'integer', 'Three digit integer value, unique identifier of a feature type.', 
    'TRUE', 460, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.gnis_id', 'scalar', 'NHDPlus GNIS ID', 'string', 'Unique identifier assigned by GNIS, length 10.', 
    'TRUE', '421765', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.gnis_name', 'scalar', 'NHDPlus GNIS Name', 'string', 'Proper name, specific term, or expression by which a particular geographic entity is known, length 65.', 
    'TRUE', 'Des Plaines River', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.hydroseq', 'scalar', 'Hydro Sequence ID', 'integer', 'Hydrologic sequence number; places flowlines in hydrologic order; processing NHDFlowline features in ascending order, encounters the features from downstream to upstream; processing the NHDFlowline features in descending order, encounters the features from upstream to downstream.', 
    'TRUE', 510029993, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.innetwork', 'scalar', 'In Network Flag', 'string', 'Flag (Y/N) indicating if a given flowline is part of the NHDPlus stream network.', 
    'TRUE', 'Y', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.lengthkm', 'scalar', 'Length (Km)', 'number', 'Length of linear feature, Albers Equal Area Conic, length 8.', 
    'TRUE', 1.976, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.levelpathid', 'scalar', 'Level Path ID', 'integer', 'Hydrologic sequence number of most downstream NHDFlowline feature in the level path.', 
    'TRUE', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.measure', 'scalar', 'Event Measure', 'number', 'Measure along the reach, in percent from downstream end, where a point event is located.', 
    'TRUE', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.navigable', 'scalar', 'Navigable Flag', 'string', 'TRUE', 
    'Y', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.output_bytes', 'scalar', 'Output Bytes', 'number', 'Total size in bytes of the service results payload.', 
    'TRUE', '60847', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.permanent_identifier', 'scalar', 'Permanent Identifier', 'string', 'Global unique identifier assigned to each NHDPlus feature.  In most cases this value will simply be a string copy of the feature ComID.  However particularly in exclaves such as Puerto Rico and Hawaii using more detailed resolutions this value may be an Esri-formatted global unique identifier.', 
    'TRUE', '14783717', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.reachcode', 'scalar', 'Reach Code', 'string', 'A unique, permanent identifier in the National Hydrography Dataset associated with a uniquely identified linear feature that consists of one or more flowlines.', 
    'TRUE', '07120004000094', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_FORMAT, SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, 
    VERSIONID)
 Values
   ('Sample.property.reachsmdate', 'scalar', 'Reach Version Date', 'string', 'Reach version date indicating the last change to the feature identified by the reach code.', 
    'date-time', 'TRUE', '2019-04-26T17:54:00.213Z', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 
    'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.return_code', 'scalar', 'Return Code', 'integer', 'An integer code that is used to determine the nature of an error, and why it occurred.  A value of zero indicates success.', 
    'TRUE', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.status_code', 'scalar', 'Status Code', 'integer', 'Integer code indicating the overall success or failure of the service call.  A value of zero or null indicates success.', 
    'TRUE', 0, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.status_message', 'scalar', 'Status Message', 'string', 'Message provided with error conditions to elaborate on the cause of service failure.', 
    'TRUE', 'Success', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.submission_id', 'scalar', 'Submission ID', 'string', 'String identifier used to match submissions to results.', 
    'TRUE', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.terminalpathid', 'scalar', 'Terminal Path Identifier', 'integer', 'Hydrologic sequence number of terminal NHDFlowline feature.', 
    'TRUE', 350002977, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.tmeasure', 'scalar', 'To Measure', 'number', 'End measure of an observation or event along an NHDPlus reach - in percentage from the downstream end.', 
    'TRUE', 90.44532, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.total_distancekm', 'scalar', 'Running Total Distance', 'number', 'Running distance in kilometers of the navigation from the start point to this feature.', 
    'TRUE', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_NULLABLE, 
    SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.total_flowtimeday', 'scalar', 'Total Flow Time (Days)', 'number', 'TRUE', 
    2.4325, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.travtime', 'scalar', 'Travel Time', 'number', 'Travel flow time of the NHDPlus flowline.', 
    'TRUE', 2.4325, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_NUMBER, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.uphydroseq', 'scalar', 'Up Hydrosequence', 'integer', 'Upstream mainstem hydrologic sequence number.', 
    'TRUE', 510030895, TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.wbarea_comid', 'scalar', 'Waterbody/Area ComID', 'integer', 'ComID of the waterbody through which the Flowline (Artificial Path) flows.', 
    'TRUE', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.wbarea_permanent_identifier', 'scalar', 'Waterbody/Area Permanent Identifier', 'string', 'Permanent_Identifier of the waterbody through which the Flowline (Artificial Path) flows.', 
    'TRUE', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESCRIPTION, 
    SCHEMA_NULLABLE, SCHEMA_EXAMPLE_STRING, SCHEMA_DESC_UPDATED, SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.property.wbd_huc12', 'scalar', 'Watershed Boundary Dataset HUC12 ', 'string', 'WBD HUC12 unit that most encompasses the feature.', 
    'TRUE', '071200040104', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESC_UPDATED, 
    SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.randomnav.root', 'object', 'Random ComID', 'object', TO_DATE('5/29/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
Insert into DZ_SWAGGER3_SCHEMA
   (SCHEMA_ID, SCHEMA_CATEGORY, SCHEMA_TITLE, SCHEMA_TYPE, SCHEMA_DESC_UPDATED, 
    SCHEMA_DESC_AUTHOR, VERSIONID)
 Values
   ('Sample.streamcat.v1.output', 'object', 'StreamCat Output', 'object', TO_DATE('5/30/2019', 'MM/DD/YYYY'), 
    'PDZIEMIELA', 'SAMPLE');
COMMIT;
