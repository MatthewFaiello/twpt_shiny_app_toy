# ==== STEP 4: ui.R ====
#
# This file controls what people see.
# - display the sidebar controls
# - display the output placeholders
# - arrange the app into a sidebar + tabbed main panel layout
#
# ui.R defines the visible structure of the app.
# If you rename an input or output id here, you must rename it in server.R too.


# ==== UI ====

ui <-
  page_sidebar(
    window_title = APP_TITLE,
    
    theme =
      bs_theme(
        version = 5,
        primary = DDOE_COLORS$blue,
        secondary = DDOE_COLORS$navy,
        base_font = font_google("Source Sans 3"),
        heading_font = font_google("Source Sans 3")
      ),
    
    tags$head(
      tags$link(
        rel = "stylesheet",
        type = "text/css",
        href = "styles.css"
      )
    ),
    
    # ==== APP HEADER ====
    
    title =
      div(
        class = "app-header",
        
        tags$img(
          src = "Website-Header.png",
          alt = "Delaware Department of Education logo",
          class = "app-logo"
        ),
        
        div(
          class = "app-header-text",
          
          h1(
            class = "app-title",
            APP_TITLE
          ),
          
          p(
            class = "app-subtitle",
            "A simple instructional app for exploring staffing forecasts from prepared TWPT data."
          )
        )
      ),
    
    
    # ==== SIDEBAR ====
    
    sidebar =
      sidebar(
        open = "always",
        width = 310,
        
        div(
          class = "sidebar-intro",
          h3("App controls"),
          p(
            "Choose a county and LEA, set the forecast assumptions, and review the resulting staffing forecast."
          )
        ),
        
        # scope_1 = County
        # This input sends the selected county to server.R as input$scope_1.
        
        selectizeInput(
          inputId = "scope_1",
          label = LABELS$scope_1,
          choices = SCOPE_1_CHOICES,
          selected = DEFAULTS$scope_1,
          multiple = FALSE
        ),
        
        # scope_2 = LEA
        # This input sends the selected LEA to server.R as input$scope_2.
        # Its choices are updated dynamically when the county changes.
        
        selectizeInput(
          inputId = "scope_2",
          label = LABELS$scope_2,
          choices = SCOPE_2_CHOICES,
          selected = DEFAULTS$scope_2,
          multiple = FALSE
        ),
        
        hr(),
        
        h4("Forecast settings"),
        
        # The forecast year tells the app where the user wants
        # the forecast path to end.
        
        sliderInput(
          inputId = "forecast_year",
          label = "Forecast through",
          min = CURRENT_YEAR + 1,
          max = max(APP_DATA$SchoolYear, na.rm = TRUE),
          value = FORECAST_YEAR,
          step = 1,
          sep = ""
        ),
        
        # The target matriculation value is the user's end-year assumption.
        # The forecast engine creates a smooth path from the current observed
        # value to this target value.
        
        numericInput(
          inputId = "matriculation",
          label = "Target matriculation",
          value = round(MATRICULATION, 3),
          min = 0,
          max = 1,
          step = 0.001
        ),
        
        # The target students-per-teacher value is the user's end-year assumption.
        # The forecast engine creates a smooth path from the current observed
        # value to this target value.
        
        numericInput(
          inputId = "students_per_teacher",
          label = "Target students per teacher",
          value = round(STUDENTS_PER_TEACHER, 1),
          min = 1,
          step = 0.1
        ),
        
        div(
          class = "sidebar-note",
          textOutput("current_values_note")
        ),
        
        hr(),
        
        h4("Display"),
        
        # This lets the user choose what metric to plot.
        # The selected value is sent to server.R as input$metric.
        
        selectInput(
          inputId = "metric",
          label = "Metric to plot",
          choices =
            c(
              "Population" = "population",
              "Matriculation" = "matriculation",
              "Students per Teacher" = "StudentsPerTeacher",
              "Student Total" = "studentTotal",
              "Teacher Total" = "teacherTotal"
            ),
          selected = "population"
        ),
        
        hr(),
        
        # This button downloads the same forecast table shown in the table tab.
        
        downloadButton(
          outputId = "download_data",
          label = "Download forecast data",
          class = "btn-download"
        )
      ),
    
    
    # ==== MAIN BODY ====
    
    navset_card_tab(
      
      nav_panel(
        LABELS$tab_plot,
        
        div(
          class = "scope-note",
          textOutput("scope_note")
        ),
        
        plotOutput(
          outputId = "main_plot"
        )
      ),
      
      nav_panel(
        LABELS$tab_data,
        
        div(
          class = "table-intro",
          p(
            "This table shows the observed and forecasted values behind the chart."
          )
        ),
        
        DTOutput("detail_table")
      )
    )
  )