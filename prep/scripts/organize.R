# ==== STEP 1: organize.R ====
#
# This script builds the app-ready dataset used by the Shiny app.
#
# The script does four main things:
# 1. Reads the raw TWPT data
# 2. Separates observed LEA rows from future county projection rows
# 3. Builds one app-ready dataset called APP_DATA
# 4. Saves APP_DATA so global.R can load it later
#
# Important data note:
# The observed data is LEA-level.
# That means each row represents a county / LEA / year combination.
#
# The future data is county-level.
# That means the future rows only contain county population projections.
# They do not contain future student totals or future teacher totals.
#
# Important:
# This does not create true future LEA estimates.


# ==== SETUP ====

needed_packages <- c("tidyverse")

missing_packages <-
  needed_packages[
    !vapply(
      needed_packages,
      requireNamespace,
      logical(1),
      quietly = TRUE
    )
  ]

if (length(missing_packages) > 0) {
  install.packages(missing_packages)
}

invisible(
  lapply(
    needed_packages,
    library,
    character.only = TRUE
  )
)


# ==== FILE PATHS ====

# The raw data should be saved here.
raw_data_path <- file.path("prep", "data", "twpt.csv")

# The app-ready data will be saved here.
output_folder <- "input_data"
output_path <- file.path(output_folder, "APP_DATA.rds")


# ==== READ RAW DATA ====

# Read the raw TWPT file.
# This is the starting point for the app data pipeline.

twpt_raw <- read_csv(raw_data_path, show_col_types = FALSE)


# ==== SEPARATE OBSERVED AND FUTURE ROWS ====

# Observed rows have an LEA name.
# These rows have student totals and teacher totals.

observed_lea_rows <-
  twpt_raw %>%
  filter(
    !is.na(lea),
    lea != ""
  ) %>%
  mutate(
    rowType = "Observed LEA data"
  )


# Future rows do not have an LEA name.
# These rows are county-level population projections.
# They do not have student totals or teacher totals.

future_county_rows <-
  twpt_raw %>%
  filter(
    is.na(lea) | lea == ""
  ) %>%
  select(
    SchoolYear,
    County_Name,
    population
  )


# ==== BUILD LEA LOOKUP TABLE ====

# This table lists each LEA and the county it belongs to.

lea_lookup <-
  observed_lea_rows %>%
  distinct(
    County_Name,
    lea,
    leaType,
    DistrictCode,
    gradeLevel
  )


# ==== COPY FUTURE COUNTY PROJECTIONS TO LEAS ====

# The future projection rows are county-level.
#
# Example:
# Kent County has one future projection row for 2030,
# and Kent County has several LEAs,
# this step creates one 2030 display row for each Kent County LEA.
#
# These rows still do not have future student or teacher totals.

future_lea_rows <-
  future_county_rows %>%
  left_join(
    lea_lookup,
    by = "County_Name",
    relationship = "many-to-many"
  ) %>%
  mutate(
    studentTotal = NA_real_,
    teacherTotal = NA_real_,
    rowType = "Future county projection copied to LEA"
  )


# ==== BUILD APP DATA ====

# Combine the observed LEA rows and the future display rows.
#
# Then keep only the fields the app needs.
#
# matriculation and StudentsPerTeacher are example metrics
# that the Shiny app can use as forecasting assumptions.

APP_DATA <-
  bind_rows(
    observed_lea_rows,
    future_lea_rows
  ) %>%
  transmute(
    SchoolYear,
    rowType,
    
    County_Name = factor(
      County_Name,
      levels = c("New Castle", "Kent", "Sussex")
    ),
    
    leaType = str_remove(leaType, "s$"),
    
    lea,
    DistrictCode,
    gradeLevel,
    population,
    studentTotal,
    teacherTotal,
    
    matriculation = if_else(
      !is.na(studentTotal) &
        studentTotal > 0 &
        !is.na(population) &
        population > 0,
      studentTotal / population,
      NA_real_
    ),
    
    StudentsPerTeacher = if_else(
      !is.na(studentTotal) &
        !is.na(teacherTotal) &
        teacherTotal > 0,
      studentTotal / teacherTotal,
      NA_real_
    )
  ) %>%
  arrange(
    SchoolYear,
    County_Name,
    leaType,
    lea
  )


# ==== EXPORT APP DATA ====

# Save the finished APP_DATA object where global.R expects to find it.
#
# The folder is created if it does not already exist.

dir.create(
  output_folder,
  showWarnings = FALSE,
  recursive = TRUE
)

write_rds(APP_DATA, output_path)

