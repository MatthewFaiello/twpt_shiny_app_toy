# break 1
h4("Display")
nav_panel(title = LABELS$tab_data)

# break 2
output$detail_table <-
  renderDT({
    
    forecast_dt(
      data = selected_table_data()
    )
  })

nav_panel(
  LABELS$tab_data,
  DTOutput("detail_table")
)

# break 3
selectInput(
  inputId = "metric",
  label = "Metric to plot",
  choices = c(
    "Population" = "population",
    "Matriculation" = "matriculation",
    "Students per Teacher" = "StudentsPerTeacher",
    "Student Total" = "studentTotal",
    "Teacher Total" = "teacherTotal"
  ),
  selected = "population"
)

input$metric



