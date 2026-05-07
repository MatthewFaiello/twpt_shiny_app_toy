# ==== DATA HELPERS ====
#
# These helpers filter APP_DATA for the selected county and LEA.


# ==== DATA FILTERING ====

data_filtered <-
  function(data = APP_DATA,
           scope_1 = DEFAULTS$scope_1,
           scope_2 = DEFAULTS$scope_2) {
    
    data %>%
      filter(
        County_Name == scope_1,
        lea == scope_2
      ) %>%
      arrange(SchoolYear)
  }


# ==== LEA CHOICES BY COUNTY ====

scope_2_choices_filtered <-
  function(data = APP_DATA,
           scope_1 = DEFAULTS$scope_1) {
    
    data %>%
      filter(
        County_Name == scope_1,
        !is.na(lea),
        lea != ""
      ) %>%
      distinct(lea) %>%
      arrange(lea) %>%
      pull(lea)
  }

