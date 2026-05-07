# ==== PLOT HELPERS ====
#
# These helpers prepare and plot the forecast output.


# ==== METRIC LABELS ====

metric_label <-
  function(metric = "teacherTotal") {
    
    case_when(
      metric == "StudentsPerTeacher" ~ "Students per Teacher",
      metric == "studentTotal" ~ "Student Total",
      metric == "teacherTotal" ~ "Teacher Total",
      metric == "matriculation" ~ "Matriculation",
      metric == "population" ~ "Population",
      TRUE ~ metric
    )
  }


# ==== SCHOOL YEAR AXIS BREAKS ====

school_year_breaks <-
  function(years,
           every = 3) {
    
    years <-
      years %>%
      unique() %>%
      sort()
    
    years <-
      years[!is.na(years)]
    
    if (length(years) <= 2) {
      return(years)
    }
    
    first_index <-
      1
    
    last_index <-
      length(years)
    
    middle_indexes <-
      seq(
        from = first_index + every,
        to = last_index - 1,
        by = every
      )
    
    break_indexes <-
      c(
        first_index,
        middle_indexes,
        last_index
      ) %>%
      unique() %>%
      sort()
    
    years[break_indexes]
  }


# ==== PLOT DATA ====

make_plot_data <-
  function(data = make_forecast_data()) {
    
    data %>%
      transmute(
        SchoolYear,
        
        rowType = factor(
          rowType,
          levels = c("Observed LEA data", "Forecast from app inputs")
        ),
        
        County_Name,
        leaType,
        lea,
        population,
        matriculation,
        StudentsPerTeacher,
        studentTotal,
        teacherTotal
      )
  }


# ==== PLOT HELPER ====

plot_staffing_forecast <-
  function(data = make_forecast_data(),
           metric = "teacherTotal") {
    
    plot_dat <-
      make_plot_data(data)
    
    if (!metric %in% names(plot_dat)) {
      stop(
        paste0(
          "Metric '",
          metric,
          "' was not found in the plot data."
        ),
        call. = FALSE
      )
    }
    
    readable_metric <-
      metric_label(metric)
    
    plot_dat <-
      plot_dat %>%
      filter(
        !is.na(.data[[metric]])
      )
    
    x_breaks <-
      school_year_breaks(
        years = plot_dat$SchoolYear,
        every = 3
      )
    
    plot_dat %>%
      ggplot(
        aes(
          x = SchoolYear,
          y = .data[[metric]],
          color = rowType,
          linetype = rowType
        )
      ) +
      geom_line(
        linewidth = 1.1
      ) +
      geom_point(
        size = 2.5
      ) +
      geom_vline(
        xintercept = CURRENT_YEAR,
        color = DDOE_COLORS$dark_gray,
        linetype = "dotted",
        linewidth = 0.6
      ) +
      scale_color_manual(
        values = DDOE_ROW_COLORS
      ) +
      scale_linetype_manual(
        values = DDOE_ROW_LINETYPES
      ) +
      scale_x_continuous(
        breaks = x_breaks,
        labels = as.character(x_breaks),
        expand = expansion(
          mult = c(0.02, 0.03)
        )
      ) +
      labs(
        x = "\nSchool Year",
        y = paste0(readable_metric, "\n")
      ) +
      theme_ddoe()
  }


# ==== SCOPE NOTE HELPER ====

make_scope_note <-
  function(data = make_forecast_data(),
           metric = "teacherTotal") {
    
    county <-
      data %>%
      distinct(County_Name) %>%
      pull(County_Name) %>%
      first()
    
    lea <-
      data %>%
      distinct(lea) %>%
      pull(lea) %>%
      first()
    
    lea_type <-
      data %>%
      distinct(leaType) %>%
      pull(leaType) %>%
      first()
    
    begin <-
      min(data$SchoolYear, na.rm = TRUE)
    
    end <-
      max(data$SchoolYear, na.rm = TRUE)
    
    values <-
      data[[metric]]
    
    valley <-
      min(values, na.rm = TRUE) %>%
      round(1)
    
    peak <-
      max(values, na.rm = TRUE) %>%
      round(1)
    
    readable_metric <-
      metric_label(metric) %>%
      str_to_lower()
    
    paste0(
      "Showing ",
      lea,
      " in ",
      county,
      " County from ",
      begin,
      " to ",
      end,
      ". ",
      lea_type,
      " values are observed through ",
      CURRENT_YEAR,
      " and forecasted after ",
      CURRENT_YEAR,
      ". The chart shows ",
      readable_metric,
      ". Across these years, the value ranges from ",
      valley,
      " to ",
      peak,
      "."
    )
  }