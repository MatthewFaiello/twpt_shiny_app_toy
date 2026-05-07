# ==== TABLE HELPERS ====
#
# These helpers prepare the forecast output for the DT table
# and for CSV download.


# ==== TABLE DATA ====

forecast_table_data <-
  function(data = make_forecast_data()) {
    
    data %>%
      transmute(
        `School Year` = SchoolYear,
        `Row Type` = rowType,
        County = County_Name,
        `LEA Type` = leaType,
        LEA = lea,
        `District Code` = DistrictCode,
        `Grade Level` = gradeLevel,
        Population = round(population, 0),
        Matriculation = round(matriculation, 3),
        `Students per Teacher` = round(StudentsPerTeacher, 1),
        `Student Total` = round(studentTotal, 0),
        `Teacher Total` = round(teacherTotal, 0)
      ) %>% 
      arrange(desc(`School Year`))
  }


# ==== DT TABLE HELPER ====

forecast_dt <-
  function(data = forecast_table_data()) {
    
    datatable(
      data,
      rownames = FALSE,
      options = list(
        pageLength = 10,
        scrollX = TRUE
      )
    )
  }