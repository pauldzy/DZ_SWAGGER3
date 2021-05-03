# Change Log

## v1.2.0 (May 2021)

### Added
- New mock server functionality to express an endpoint as a mock service based on scalar example values.  May express both application/json and application/xml mime types.  XML logic works but has some issues in needing to look-ahead in walking the model to determine when to render nodes as XML attributes.  Unsure of how to improve this without violating the performance gains of the lazy-loading system.  

- New ability to optionally render a "x-order" attribute on paths, operations and schema properties.  The Oracle JSON handling introduced in v1.1.0 also removed any ability to order the contents of the maps in the OpenAPI specification.  This may or may not be a problem for users but does seems unideal.  However that is how Oracle rolls and there is no way around the matter in 18c.  By injecting an x-order attribute the front end application displaying the document _may_ order the various map components when they are rendered in the front end.  I should note there is no such ability to this today with any of the front ends I am familiar with.  But adding such logic should not be that difficult.

- New package to hold OpenAPI specification validation logic.  Two forms of validation logic are currently supported, *plsql* validation is a place-holder for future logic to interrogate an OpenAPI specification for errors and problems.  *swagger_badge* validation calls out to a [swagger badge server](https://github.com/swagger-api/validator-badge) somewhere to run the current specification through its debug level checking.  This latter solution is powerful but involves the need to host your own badge server and configure your database ACL settins to reach that server.

- New Docker files to guide users in spinning up an Oracle 18xe database and companion badge server.  The DZ_SWAGGER3 code and samples are automatically loaded into the new database to test code viability.   This provides a simple way to evaluate and/or test the project code.

### Changed
- Bug fixes discovered when automating deployments via Docker.

- Samples fixes discovered when validated against swagger badge server.

## v1.1.0 (March 2021)

### Added
- Added configuration options for force escaping results into \u notation.  Some older Oracle middleware solutions just do not properly handle UTF-8 output.  While the system is fully UTF-8 top to bottom, the output can be escaped to work around issues with legacy middleware.

### Changed
- Removal of dependency on DZ_JSON replacing with 18c native Oracle JSON handling.
- Removal of all YAML rendering logic replacing with a general JSON to YAML conversion logic using 18c native Oracle JSON handling.
- Removal of dependencies on MDSYS varrays replacing with in-project type varrays.
- Removal of support for pretty printing.  In 2021 there are all kinds of ways to format JSON client-side.  If a user desperately needs a human readable output, the YAML is always available.
- Superficial upgrade of specification version tag from 3.0.0 to 3.0.3.  The 3.0.3 changes to OpenAPI are not relevant to the existing codebase but moving to 3.0.3 looks nice.
- Relocation of JSON schema rendering into the cache manager to streamline permissions for external handlers.

## v1.0.0 (May 2019)

### Added
- Full rewrite of the type system moving the hierarchy out of memory and into a temp table.

### Changed
- Improvements to logic to reference or not reference components.

## v0.2.0 (November 2018)

### Added
- Initial release of new system

### Changed
- Not applicable
