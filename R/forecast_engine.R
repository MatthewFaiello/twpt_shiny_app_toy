# ==== FORECAST ENGINE ====
#
# These helpers run the app's forecasting logic.
#
# The app forecasts two assumptions:
# - matriculation
# - StudentsPerTeacher
#
# Then it uses those forecasted assumptions to estimate:
# - studentTotal
# - teacherTotal


# ==== ASSUMPTION CHANGE RATES ====

calculate_growth_factors <- 
  function(data = data_filtered(),
           begin = CURRENT_YEAR,
           end = FORECAST_YEAR,
           mat = MATRICULATION,
           ratio = STUDENTS_PER_TEACHER) {
    
    periods <- end - begin
    
    if (periods <= 0) {
      stop("The forecast end year must be later than the begin year.")
    }
    
    start_row <-
      data %>%
      filter(SchoolYear == begin) %>%
      slice(1)
    
    if (nrow(start_row) == 0) {
      stop("The selected data does not have a row for the begin year.")
    }
    
    start_matriculation <- start_row$matriculation
    
    start_students_per_teacher <- start_row$StudentsPerTeacher
    
    tmp <-
      tibble(
        name = c("matriculation", "StudentsPerTeacher"),
        first = begin,
        startValue = c(start_matriculation, start_students_per_teacher),
        last = end,
        endValue = c(mat, ratio),
        periods = periods
      ) %>%
      mutate(
        annualMultiplier = if_else(
          !is.na(startValue) &
            startValue > 0 &
            !is.na(endValue) &
            endValue > 0,
          (endValue / startValue) ^ (1 / periods),
          1
        ),
        
        annualPercentChange = annualMultiplier - 1
      )
    
    return(tmp)
  }


# ==== CREATE FORECAST ROWS ====

predict_model <- 
  function(data = data_filtered(),
           begin = CURRENT_YEAR,
           end = FORECAST_YEAR,
           mat = MATRICULATION,
           ratio = STUDENTS_PER_TEACHER) {
    
    rate <-
      calculate_growth_factors(
        data = data,
        begin = begin,
        end = end,
        mat = mat,
        ratio = ratio
      )
    
    start_row <-
      data %>%
      filter(SchoolYear == begin) %>%
      slice(1)
    
    if (nrow(start_row) == 0) {
      stop("The selected data does not have a row for the begin year.")
    }
    
    future_years <-
      tibble(
        SchoolYear = (begin + 1):end
      )
    
    # Use the future population values prepared by organize.R.
    # We do not forecast population here.
    
    future_population <-
      future_years %>%
      left_join(
        data %>%
          distinct(
            SchoolYear,
            population
          ),
        by = "SchoolYear"
      )
    
    # Forecast the two app assumptions from the begin year
    # to the selected forecast year.
    
    future_assumptions <-
      future_years %>%
      mutate(
        yearsAhead = SchoolYear - begin
      ) %>%
      crossing(
        rate %>%
          select(
            name,
            startValue,
            annualMultiplier
          )
      ) %>%
      mutate(
        value = startValue * annualMultiplier ^ yearsAhead
      ) %>%
      select(
        SchoolYear,
        name,
        value
      ) %>%
      pivot_wider(
        names_from = name,
        values_from = value
      )
    
    forecast_rows <-
      future_population %>%
      left_join(
        future_assumptions,
        by = "SchoolYear"
      ) %>%
      mutate(
        rowType = "Forecast from app inputs",
        County_Name = start_row$County_Name,
        leaType = start_row$leaType,
        lea = start_row$lea,
        DistrictCode = start_row$DistrictCode,
        gradeLevel = start_row$gradeLevel,
        studentTotal = NA_real_,
        teacherTotal = NA_real_
      ) %>%
      select(
        SchoolYear,
        rowType,
        County_Name,
        leaType,
        lea,
        DistrictCode,
        gradeLevel,
        population,
        studentTotal,
        teacherTotal,
        matriculation,
        StudentsPerTeacher
      )
    
    history_rows <-
      data %>%
      filter(SchoolYear <= begin) %>%
      select(
        SchoolYear,
        rowType,
        County_Name,
        leaType,
        lea,
        DistrictCode,
        gradeLevel,
        population,
        studentTotal,
        teacherTotal,
        matriculation,
        StudentsPerTeacher
      )
    
    output <-
      bind_rows(
        history_rows,
        forecast_rows
      ) %>%
      arrange(SchoolYear)
    
    return(output)
  }


# ==== ESTIMATE STUDENT AND TEACHER DEMAND ====

demand <- 
  function(data = predict_model()) {
    
    tmp <-
      data %>% 
      mutate(
        studentTotal = if_else(
          is.na(studentTotal) &
            !is.na(population) &
            !is.na(matriculation),
          round(population * matriculation, 0),
          studentTotal
        ),
        
        teacherTotal = if_else(
          is.na(teacherTotal) &
            !is.na(studentTotal) &
            !is.na(StudentsPerTeacher) &
            StudentsPerTeacher > 0,
          round(studentTotal / StudentsPerTeacher, 0),
          teacherTotal
        )
      )
    
    return(tmp)
  }


# ==== RUN FORECAST ENGINE ====

make_forecast_data <-
  function(data = APP_DATA,
           scope_1 = DEFAULTS$scope_1,
           scope_2 = DEFAULTS$scope_2,
           begin = CURRENT_YEAR,
           end = FORECAST_YEAR,
           mat = MATRICULATION,
           ratio = STUDENTS_PER_TEACHER) {
    
    selected_data <-
      data_filtered(
        data = data,
        scope_1 = scope_1,
        scope_2 = scope_2
      )
    
    forecasted_data <-
      predict_model(
        data = selected_data,
        begin = begin,
        end = end,
        mat = mat,
        ratio = ratio
      )
    
    output <-
      demand(
        data = forecasted_data
      )
    
    return(output)
  }