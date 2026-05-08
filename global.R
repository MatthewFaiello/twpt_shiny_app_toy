# ==== STEP 2: global.R ====
#
# This file holds the shared app setup.
#
# global.R does three things:
# 1. Loads packages
# 2. Loads APP_DATA and app-wide defaults
# 3. Sources helper functions from the R/ folder
#
# Helper functions live in separate files so the app is easier to read 
# and maintain.


# ==== SETUP ====

needed_packages <- 
  c(
    "shiny",
    "tidyverse",
    "bslib",
    "DT",
    "scales",
    "ggthemes"
  )

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

# Tell R to avoid scientific notation when printing large numbers.
options(scipen = 999)


# ==== APP LABELS ====

APP_TITLE <- "Staffing Forecaster"

LABELS <-
  list(
    scope_1 = "County",
    scope_2 = "LEA",
    tab_plot = "Forecast plot",
    tab_data = "Underlying data" # <- Edit tab title here
  )


# ==== DATA INPUT ====

APP_DATA <- readRDS(file.path("input_data", "APP_DATA.rds"))


# ==== YEARS USED BY THE APP ====

CURRENT_YEAR <-
  APP_DATA %>%
  filter(rowType == "Observed LEA data") %>%
  summarize(value = max(SchoolYear, na.rm = TRUE)) %>%
  pull(value)

FORECAST_YEAR <- CURRENT_YEAR + 3


# ==== CHOICES USED IN UI ====

SCOPE_1_CHOICES <-
  APP_DATA %>%
  filter(
    !is.na(County_Name),
    County_Name != ""
  ) %>%
  distinct(County_Name) %>%
  arrange(County_Name) %>%
  pull(County_Name)

SCOPE_2_CHOICES <-
  APP_DATA %>%
  filter(
    !is.na(lea),
    lea != ""
  ) %>%
  distinct(lea) %>%
  arrange(lea) %>%
  pull(lea)


# ==== DEFAULTS ====

DEFAULTS_CHOICES <-
  APP_DATA %>% 
  distinct(County_Name, lea) %>% 
  arrange(County_Name, lea) %>% 
  slice(1)

DEFAULTS <-
  list(
    scope_1 = DEFAULTS_CHOICES$County_Name,
    scope_2 = DEFAULTS_CHOICES$lea
  )


# ==== DEFAULT ASSUMPTIONS ====

# These are the opening values for the user-controlled assumptions.
#
# The app starts with values based on the default LEA's current observed row.
# These are only starting values. Users can change them in the sidebar.

default_current_row <-
  APP_DATA %>%
  filter(
    SchoolYear == CURRENT_YEAR,
    County_Name == DEFAULTS$scope_1,
    lea == DEFAULTS$scope_2,
    rowType == "Observed LEA data"
  )

MATRICULATION <- default_current_row$matriculation

STUDENTS_PER_TEACHER <- default_current_row$StudentsPerTeacher


# ==== SOURCE HELPER FILES ====

# These files contain related groups of helper functions.
# They are sourced in order because later files use objects
# created in earlier files.

source(file.path("R", "theme_values.R"))
source(file.path("R", "data_helpers.R"))
source(file.path("R", "forecast_engine.R"))
source(file.path("R", "plot_helpers.R"))
source(file.path("R", "table_helpers.R"))





