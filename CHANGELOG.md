# Change Log

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
