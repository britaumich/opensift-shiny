library(shiny)
library(shinythemes)

# Define UI for application 
ui <- navbarPage(
  
  # Theme
  theme=shinytheme("yeti"),
  
  # Application title
  title = 'CZEUM Interactive Phylogeny',
  
  # Show a plot and output table 
  sidebarLayout(
    mainPanel(
      plotOutput("treeDisplay",  
                 width = "100%",
                 height = "6000px",
                 click = "plot_click",
                 dblclick = "plot_dblclick",
                 brush = brushOpts(
                   id = "plot_brush",
                   clip = FALSE,
                   resetOnNew = TRUE)),
      
      dataTableOutput("info")

    ),
    
    # Instructions for user, slider bar for font size, text output
    sidebarPanel(
      style = "position:fixed;width:30%;",
      
      a("CZEUM Homepage", href = "https://czeum.herb.lsa.umich.edu/"),
    
      
      h6("Brush and double click inside of rectangle to zoom"),
      h6("Double click again to exit"),
      h6("Single click on tips for more information"),
      
      sliderInput(inputId = "text",
                  label = "Text Size",                            
                  min = 2, max = 5, step = 0.25, value = 2.5),
      
      h6("Blue = Available"),
      h6("Red = Not Available")
    )
  )
)