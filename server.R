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
      mutate(
        diff_max_min = max - min,
        diff_max_mean = max - mean
      ) %>%
      pivot_longer(cols = c(min, mean, max, diff_max_min, diff_max_mean), names_to = 'stat') %>%
      mutate(line_color = case_when(
        stat == 'min' ~ color_palette[[5]],
        stat == 'max' ~ color_palette[[1]],
        stat == 'mean' ~ color_palette[[3]],
        stat == 'diff_max_min' ~ color_palette[[4]],
        stat == 'diff_max_mean' ~ color_palette[[2]],
      )) %>%
      filter(stat %in% input$stat_input)
      
  })
  
  # this dynamically builds a color palette to make sure plotly shows the lines
  # of the same stat always as the same color
  line_colors <- reactive({
    colors <- character(0)
    if('min' %in% input$stat_input){colors <- c(colors, color_palette[[1]])}
    if('mean' %in% input$stat_input){colors <- c(colors, color_palette[[2]])}
    if('max' %in% input$stat_input){colors <- c(colors, color_palette[[3]])}
    if('diff_max_min' %in% input$stat_input){colors <- c(colors, color_palette[[4]])}
    if('diff_max_mean' %in% input$stat_input){colors <- c(colors, color_palette[[5]])}
    
    return(colors)
  })
  
  # observe({
  #   cat(grepl('min', input$stat_input), '\n')
  #   cat("input$stat_input changed to:", input$stat_input, "\n")
  #   cat("line colors is now", line_colors(), '\n')
  # })
  
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
            colors = ~line_colors()
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
             margin = list(b = 30, l = 110, r = 30, t = 85)#,
             # hovermode = 'x unified'
             )
  })
  
  
  
}) # close server 
