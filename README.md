# TWPT Shiny App Toy

An instructional Shiny app that shows how to prepare education data, organize app logic, and build a simple staffing forecast from user inputs.

This project is designed for teaching. It is intentionally small, plain, and linear so that a mixed audience—education administrators, analysts, and data scientists—can follow the full workflow from raw data to app output.

## What the app does

The app lets a user choose a Delaware county and LEA, set simple forecast assumptions, and view a staffing forecast.

The forecast uses two app inputs:

- **Matriculation**: the share of county population represented by the LEA student total
- **Students per teacher**: the student-to-teacher ratio used to estimate staffing demand

The app uses a yearly growth factor to move from the current observed value to the user's target value. It then estimates future student totals and teacher totals.

This is a toy instructional app. It is not meant to produce official enrollment or staffing projections.

## Project structure

```text
twpt_shiny_app_toy/
├── twpt_shiny_app_toy.Rproj
├── global.R
├── ui.R
├── server.R
├── R/
│   ├── theme_values.R
│   ├── data_helpers.R
│   ├── forecast_engine.R
│   ├── plot_helpers.R
│   └── table_helpers.R
├── www/
│   ├── styles.css
│   └── Website-Header.png
├── input_data/
│   └── APP_DATA.rds
└── prep/
    ├── data/
    │   └── twpt.csv
    └── scripts/
        └── organize.R
```

## App workflow

The project is organized around four main app files.

### 1. `prep/scripts/organize.R`

This is the data preparation script.

It reads the raw file:

```text
prep/data/twpt.csv
```

Then it creates:

```text
input_data/APP_DATA.rds
```

The prepared dataset includes:

- observed LEA rows
- future county population projection rows copied to each LEA for app display
- `matriculation`
- `StudentsPerTeacher`

Important data note:

The observed rows are LEA-level. The future rows are county-level population projections. The app copies each future county projection to each LEA in that county so that the Shiny app can keep a consistent county / LEA structure.

This does **not** create true future LEA estimates.

### 2. `global.R`

This file loads shared app objects.

It handles:

- package setup
- app labels
- loading `APP_DATA`
- current year and forecast year defaults
- sidebar choices
- default forecast assumptions
- sourcing helper scripts from the `R/` folder

### 3. `ui.R`

This file controls what users see.

It defines:

- the page layout
- the sidebar controls
- the Delaware Department of Education header logo
- forecast inputs
- plot and table tabs
- output placeholders used by `server.R`

### 4. `server.R`

This file connects user inputs to app outputs.

It handles:

- updating the LEA dropdown when the county changes
- reading user forecast assumptions
- running the forecast engine
- rendering the plot
- rendering the DT table
- creating the downloadable CSV

## Helper scripts

The `R/` folder holds related groups of helper functions.

### `R/theme_values.R`

Stores Delaware Department of Education-inspired colors and plot theme settings.

Used by:

- `ui.R`
- plot helpers
- `styles.css` design choices

### `R/data_helpers.R`

Holds helpers for filtering data.

Examples:

- filter to selected county and LEA
- return LEA choices for the selected county

### `R/forecast_engine.R`

Holds the core forecast logic.

The forecast engine:

1. starts from the selected LEA's current observed values
2. calculates yearly growth factors
3. forecasts matriculation and students per teacher
4. uses population, matriculation, and students per teacher to estimate students and teachers

### `R/plot_helpers.R`

Holds plot helpers.

These functions:

- prepare plot-ready data
- convert metric names into readable labels
- build the main staffing forecast plot
- create a short scope note for the selected LEA

### `R/table_helpers.R`

Holds table helpers.

These functions:

- prepare readable table output
- round values for display
- create the interactive DT table

## Data files

### `prep/data/twpt.csv`

The raw source file used by the prep script.

### `input_data/APP_DATA.rds`

The app-ready dataset created by `organize.R`.

The Shiny app reads this file when it starts.

If the raw data changes, rerun:

```r
source("prep/scripts/organize.R")
```

Then restart or reload the Shiny app.

## Static assets

### `www/Website-Header.png`

The Delaware Department of Education logo used in the app header.

### `www/styles.css`

The custom CSS file used to style the app.

The design uses:

- navy and blue for primary branding
- gold for accent lines and highlights
- light gray for cards, notes, and layout structure
- white backgrounds for readability

## How to run the app

1. Open `twpt_shiny_app_toy.Rproj` in RStudio.

2. Install required packages if needed:

```r
install.packages(
  c(
    "shiny",
    "tidyverse",
    "bslib",
    "DT",
    "scales",
    "ggthemes"
  )
)
```

3. Build the prepared app data:

```r
source("prep/scripts/organize.R")
```

4. Run the Shiny app:

```r
shiny::runApp()
```

Or click **Run App** in RStudio.

## Teaching notes

This app is designed to demonstrate several common Shiny app patterns:

- separating data prep from app logic
- using `global.R` for shared setup
- sourcing helper files from an `R/` folder
- using `ui.R` for layout only
- using `server.R` for reactive wiring
- keeping one central forecast dataset for the plot, table, and download
- styling a Shiny app with a simple CSS file

The project also demonstrates a useful modeling pattern:

```text
observed value
→ user target value
→ yearly growth factor
→ forecasted assumption values
→ estimated students and teachers
```

## Important limitations

This project is for instruction only.

The forecast is intentionally simple. It does not account for:

- grade-level cohort movement
- school choice behavior
- boundary changes
- staffing policy rules
- fiscal constraints
- program-specific staffing needs
- demographic uncertainty
- official enrollment projection methods

The app is best understood as a teaching tool for app structure, data preparation, and simple forecasting logic.

## Suggested development workflow

When updating the project:

1. Edit the raw data or prep logic.
2. Rerun `prep/scripts/organize.R`.
3. Confirm that `input_data/APP_DATA.rds` was recreated.
4. Restart the Shiny app.
5. Test the county and LEA dropdowns.
6. Test forecast inputs.
7. Confirm that the plot, table, and download all show the same forecasted data.

## File naming convention

The helper files are numbered so learners can read them in order:

```text
theme_values.R
data_helpers.R
forecast_engine.R
plot_helpers.R
table_helpers.R
```

This makes the app logic easier to follow during instruction.
