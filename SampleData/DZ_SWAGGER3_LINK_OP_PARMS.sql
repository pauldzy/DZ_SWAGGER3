SET DEFINE OFF;
Insert into DZ_SWAGGER3_LINK_OP_PARMS
   (LINK_ID, LINK_OP_PARM_NAME, LINK_OP_PARM_EXP, LINK_OP_PARM_ORDER, VERSIONID)
 Values
   ('Sample.randomnav.streamcat.link', 'pComID', '$.response.body#/pComID', 10, 'SAMPLE');
Insert into DZ_SWAGGER3_LINK_OP_PARMS
   (LINK_ID, LINK_OP_PARM_NAME, LINK_OP_PARM_EXP, LINK_OP_PARM_ORDER, VERSIONID)
 Values
   ('Sample.randomnav.streamcat.link', 'pReturnGeometry', 'TRUE', 20, 'SAMPLE');
COMMIT;
