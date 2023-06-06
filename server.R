# SERVER
shinyServer(function(input, output) {
  
  summary_df <- reactive({
    sum_df <- power_data %>%
      filter(grepl(input$project_input, name)) %>%
      group_by_at(.vars = vars('name', input$span_input)) %>%
      summarize(min = min(power_mw),
                mean = round(mean(power_mw),2),
                max = max(power_mw),
                n = n()) %>%
      select(name, everything()) %>%
      pivot_longer(cols = c(min, mean, max), names_to = 'stat') %>%
      filter(stat %in% input$stat_input)
      
  })
  
  output$power_plot2<- renderPlotly({
    
    shiny::validate(
      need(nrow(summary_df()) > 0, message = '*No spawner abundance data for the current selection.')
    )
    
      if(input$span_input == 'date') {title_span = 'Daily'}
      if(input$span_input == 'year_month') {title_span = 'Monthly'}
      if(input$span_input == 'year') {title_span = 'Yearly'}
    
    # plot
    plot_ly(data = summary_df(), 
            x = ~summary_df()[[2]],
            y = ~value,
            name = ~stat,
            text = ~stat,
            hovertemplate = paste(
              '%{x}<br>',
              '%{yaxis.title.text} (%{text}): %{y}'),
            type = 'scatter',
            mode = 'lines',  # lines+markers
            # linetype = ~stat,
            color = ~stat,
            colors = viridis_pal(option="D", begin=0.2, end=0.8)(length(unique(summary_df()$stat)))
    ) %>%
      layout(title = list(text = paste0(input$project_input, ' Dam (', title_span, ' Timestep)'),
                          font = list(size = main_title),
                          y = 0.98),
             yaxis = list(title= 'Hourly Power Generation (MW)',
                          titlefont = list(size = axis_titles), 
                          tickfont = list(size = axis_labels),
                          range = c(-15, max(summary_df()$value)*1.03)),
             xaxis = list(title= 'Date',
                          titlefont = list(size = axis_titles), 
                          tickfont = list(size = axis_labels)
                          ),
             legend = list(font = list(size = legend_text)),
             showlegend = TRUE,
             margin = list(b = 30, l = 110, r = 30, t = 85)
             )
  })
  
  
  
}) # close server 
