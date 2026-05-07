# ==== STEP 3: server.R ====
#
# This file is the reactive wiring for the app.
#
# This is where the app connects:
# - input values coming from ui.R
# - output objects going back to ui.R
#
# In this app:
# - input$scope_1 = selected county
# - input$scope_2 = selected LEA
# - input$forecast_year = selected forecast end year
# - input$matriculation = target matriculation value
# - input$students_per_teacher = target students-per-teacher value
# - input$metric = selected metric for the plot
#
# And the outputs sent back to the UI are:
# - output$current_values_note
# - output$main_plot
# - output$scope_note
# - output$detail_table
# - output$download_data


server <-
  function(input, output, session) {
    
    
    # ==== LEA CHOICES ====
    
    # lea_choices() returns the valid LEA choices for the selected county.
    #
    # The helper scope_2_choices_filtered() lives in global.R.
    
    lea_choices <-
      reactive({
        req(input$scope_1)
        
        scope_2_choices_filtered(
          data = APP_DATA,
          scope_1 = input$scope_1
        )
      })
    
    
    # ==== UPDATE LEA DROPDOWN WHEN COUNTY CHANGES ====
    
    # When the selected county changes, update the LEA dropdown.
    # The app selects the first LEA in the selected county by default.
    
    observeEvent(input$scope_1, {
      
      choices <- lea_choices()
      
      updateSelectizeInput(
        session = session,
        inputId = "scope_2",
        choices = choices,
        selected = choices[1],
        server = TRUE
      )
    })
    
    
    # ==== CURRENT OBSERVED ROW ====
    
    # selected_current_row() finds the current observed row for the selected LEA.
    #
    # The app uses this to:
    # - show the current values in the sidebar note
    # - reset the opening forecast assumptions when the user changes LEA
    
    selected_current_row <-
      reactive({
        req(input$scope_1, input$scope_2)
        
        APP_DATA %>%
          filter(
            SchoolYear == CURRENT_YEAR,
            County_Name == input$scope_1,
            lea == input$scope_2,
            rowType == "Observed LEA data"
          )
      })
    
    
    # ==== UPDATE ASSUMPTION INPUTS WHEN LEA CHANGES ====
    
    # When the selected LEA changes, use that LEA's current values
    # to set simple starting target assumptions.
    #
    # The target matriculation value starts slightly above the current value.
    # The target students-per-teacher value starts slightly below the current value.
    #
    # These are just opening assumptions.
    # Users can edit them in the sidebar.
    
    observeEvent(input$scope_2, {
      
      row <- selected_current_row()
      
      if (nrow(row) == 1) {
        
        if (!is.na(row$matriculation)) {
          updateNumericInput(
            session = session,
            inputId = "matriculation",
            value = round(row$matriculation, 3)
          )
        }
        
        if (!is.na(row$StudentsPerTeacher)) {
          updateNumericInput(
            session = session,
            inputId = "students_per_teacher",
            value = round(row$StudentsPerTeacher, 1)
          )
        }
      }
    })
    
    
    # ==== CURRENT VALUES NOTE ====
    
    # This sidebar note helps users understand the target inputs.
    # It shows the current observed values for the selected LEA.
    
    output$current_values_note <-
      renderText({
        
        row <- selected_current_row()
        
        req(nrow(row) == 1)
        
        paste0(
          "Current observed values in ",
          CURRENT_YEAR,
          ": matriculation = ",
          round(row$matriculation, 3),
          "; students per teacher = ",
          round(row$StudentsPerTeacher, 1),
          "."
        )
      })
    
    
    # ==== RUN FORECAST ENGINE ====
    
    # selected_forecast_data() is the central reactive dataset.
    #
    # It calls make_forecast_data() from global.R.
    # That helper runs the full app forecast engine:
    # - filter selected LEA
    # - forecast matriculation and StudentsPerTeacher
    # - estimate future student and teacher totals
    
    selected_forecast_data <-
      reactive({
        req(
          input$scope_1,
          input$scope_2,
          input$forecast_year,
          input$matriculation,
          input$students_per_teacher
        )
        
        req(input$forecast_year > CURRENT_YEAR)
        req(input$matriculation >= 0)
        req(input$matriculation <= 1)
        req(input$students_per_teacher > 0)
        
        make_forecast_data(
          data = APP_DATA,
          scope_1 = input$scope_1,
          scope_2 = input$scope_2,
          begin = CURRENT_YEAR,
          end = input$forecast_year,
          mat = input$matriculation,
          ratio = input$students_per_teacher
        )
      })
    
    
    # ==== TABLE DATA ====
    
    # selected_table_data() formats the forecast data for display
    # and download.
    #
    # It uses forecast_table_data() from global.R.
    
    selected_table_data <-
      reactive({
        
        forecast_table_data(
          data = selected_forecast_data()
        )
      })
    
    
    # ==== PLOT OUTPUT ====
    
    # This sends the main plot back to plotOutput("main_plot") in ui.R.
    #
    # The plotting code itself lives in global.R inside
    # plot_staffing_forecast().
    
    output$main_plot <-
      renderPlot({
        
        plot_staffing_forecast(
          data = selected_forecast_data(),
          metric = input$metric
        )
      }, res = 100)
    
    
    # ==== SCOPE NOTE OUTPUT ====
    
    # This sends a text summary back to textOutput("scope_note") in ui.R.
    #
    # The text is created by make_scope_note() in global.R.
    
    output$scope_note <-
      renderText({
        
        make_scope_note(
          data = selected_forecast_data(),
          metric = input$metric
        )
      })
    
    
    # ==== DETAIL TABLE OUTPUT ====
    
    # This sends the formatted forecast table back to DTOutput("detail_table").
    
    output$detail_table <-
      renderDT({
        
        forecast_dt(
          data = selected_table_data()
        )
      })
    
    
    # ==== DOWNLOAD OUTPUT ====
    
    # This creates the downloadable CSV tied to the current filters
    # and forecast assumptions.
    #
    # Important idea:
    # the download uses the same selected_table_data() object as the table tab.
    # That keeps the displayed data and downloaded data in sync.
    
    output$download_data <-
      downloadHandler(
        
        filename =
          function() {
            
            safe_county <-
              str_replace_all(
                input$scope_1,
                "[^A-Za-z0-9]+",
                "_"
              )
            
            safe_lea <-
              str_replace_all(
                input$scope_2,
                "[^A-Za-z0-9]+",
                "_"
              )
            
            paste0(
              "staffing_forecast_",
              safe_county,
              "_",
              safe_lea,
              "_",
              Sys.Date(),
              ".csv"
            )
          },
        
        content =
          function(file) {
            
            write_csv(
              selected_table_data(),
              file
            )
          }
      )
  }