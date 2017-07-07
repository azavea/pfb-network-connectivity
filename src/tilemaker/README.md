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

#### Install Mapbox Studio Classic

[Mapbox Studio Classic](https://www.mapbox.com/mapbox-studio-classic/) is deprecated
(you have to confirm it's really what you want when you go to that page), but we're just using it
as a graphical editor then extracting Mapnik XML styles to use in our own stand-alone process.

To install:
- For MacOS, the version linked from the page above ([v0.3.8](https://mapbox.s3.amazonaws.com/mapbox-studio/mapbox-studio-darwin-x64-v0.3.8.zip)) works fine.
- For Linux, it seems not to.  The latest release from https://mapbox.s3.amazonaws.com/mapbox-studio/index.html (currently ["nsis-upgrade"](https://mapbox.s3.amazonaws.com/mapbox-studio/mapbox-studio-linux-x64-nsis-upgrade.zip)) should work.  Installation is just unzipping it and
running the `atom` command from the base directory.

We aren't publishing anything to Mapbox, but you still have to sign in with a Mapbox Studio
account to use Classic.

#### Open the project

**Edit file paths**
The project consists of both a data source (it uses the exports from Fort Collins, CO, chosen
so that all of the styled features are represented) and a style.  There are absolute paths
stored in some of the files that constitute the project, which will need to be changed to match
your local directory structure.

So before opening the project, modify all the hard-coded absolute paths in the
following files to point to the correct locations on your machine:
  ```
  working_files/combined_data.tm2source/data.yml
  working_files/combined_data.tm2source/data.xml
  working_files/neighborhood_ways.tm2/project.yml
  working_files/neighborhood_ways.tm2/project.xml
  working_files/neighborhood_census_blocks.tm2/project.yml
  working_files/neighborhood_census_blocks.tm2/project.xml
  working_files/bike_infrastructure.tm2/project.yml
  working_files/bike_infrastructure.tm2/project.xml
  ```
(Since these files are tracked, this will cause a diff.  It's fine if they get changed in the repo
to the right paths for whoever worked on them last.)

**Open project**
- After you've started Mapbox Studio Classic and signed in, you'll see a "New Style or Source" view.
Click the box on the right, for "Blank source".

![New Style or Source view](images/new_style_or_source.png?raw=true)

- That will put you in the main editor view with no layers or styles. Click "Styles & Sources" in
the bottom left then "Browse" in the panel that appears.

![Styles and Sources](images/styles_and_sources.png?raw=true)

- Find the `working_files` directory in the file browser and select `neighborhood_ways.tm2`, then
click "Open".

![Open .tm2 project](images/open_tm2_project.png?raw=true)

- The project should now be loaded and the map and the syles should show in the editor.

![Edit view](images/edit.png?raw=true)

Once you've opened the project once, the "New Style or Source" view will no longer appear. On
startup, you'll go straight to the edit view. Not necessarily to right to your last project, but
it should now show up in the "Styles & Sources" panel, so you don't have to Browse for it again.

If you're working on more than one style definition at a time, repeat this process for any of the other `.tm2` projects in the `working_files` directory.


#### Edit and save

Add or edit styles and data sources.  The styling interface isn't wildly user-friendly, since
it requires writing style rules by hand, but the "Docs" panel provides a decent reference, and it
provides a preview that updates on save.

We're not generating tiles using the TM2 project directly.  We use stand-alone Mapnik XML files
that each define their styles and data sources.  Once you've saved changes to the Mapbox Studio
project, you need to copy them by hand to the Mapnik style files.

For example, to update the neighborhood ways style opened above, open
`working_files/neighborhood_Ways.tm2/project.xml` and find all `<Style>` elements. Copy them all
over to `styles/neighborhood_census_blocks_style.xml`, overwriting any existing `<Style>` tags.
The data source shouldn't need changing.

Commit your changes to the TM2 project as well as to the XML styles, so that the project stays in
sync and subsequent edits can start from it.
