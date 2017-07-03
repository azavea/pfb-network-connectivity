# Tilemaker

This container generates raster tiles using the results of an analysis job. It's run along with
analysis jobs and uses the shapefiles exported by the analysis.

The easiest way to run it locally is to load the `AnalysisJob` object you're interested in and
call its `generate_tiles` method.  That won't run the tilemaker command but will print the right
command to run to the logs, so you can copy it from there and run it.


## Adding and Editing Styles

The tiles are defined using Mapnik XML style files in the `styles` directory.
Since the style XML files aren't templated, the path of the shapefile that's used as the
data source is hard-coded to a file path in /data/.  The `run_tilemaker.sh` entrypoint script
downloads the required shapefiles to the expected paths.

For ease of editing and previewing, the styles are defined and maintained in a
Mapbox Studio Classic project from which the XML style definitions are extracted by hand.

Changes to the working files should be committed so that they're kept in sync with the actual
tile styles being applied.

### To open and edit the styles

- Download the latest release of Mapbox Studio Classic from https://mapbox.s3.amazonaws.com/mapbox-studio/index.html (the [Mapbox download page](https://www.mapbox.com/mapbox-studio-classic/) links to an older, seemingly-broken version) and install it (for Linux,
that just means unzipping it and running the `atom` command from the base directory).
- Modify the hard-coded absolute paths in the following files to point to the actual locations
on your machine.
  ```
  working_files/combined_data.tm2source/data.yml
  working_files/combined_data.tm2source/data.xml
  working_files/combined_styles.tm2/project.yml
  working_files/combined_styles.tm2/project.xml
  ```
- In Mapbox Studio Classic, click "Styles & Sources" > "Browse" and select the
`combined_styles.tm2` directory.  It should open a map of the defined tile layers, using data
from Glendale, AZ.
- Add or edit styles and data sources.  The styling interface isn't wildly user-friendly, since
it requires writing style rules by hand, but the "Docs" panel provides a decent reference, and it
provides a preview that updates on save.

### To save changes

We're not generating tiles using the TM2 project directly.  We use stand-alone Mapnik XML files
that each define their styles and data sources.  To update the census blocks style, open
`working_files/combined_styles.tm2/project.xml` and find the
`<Style name="neighborhood_census_blocks">` element.  Copy the whole thing over top of
the one in `styles/neighborhood_census_blocks_style.xml`.  The data source shouldn't need changing.
