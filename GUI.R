library(shiny) #Import shiny library to create GUI
#Define rontend UI design
ui <- fluidPage(
  headerPanel("Rainfall prediction"),
  sidebarPanel(
    numericInput("Latitude", "Latitude", value = 0),
    numericInput("Longitude", "Longitude", value = 0),
    numericInput("Max_Temperature", "Max. Temperature (°C)", value = 0),
    numericInput("Min_Temperature", "Min Temperature (°C)", value = 0),
    numericInput("Wind", "Wind (Kmph)", value = 0),
    numericInput("Relative_Humidity", "Relative Humidity (%)", value = 0),
    numericInput("Solar", "Solar Coverage (MJ/m^2)", value = 0)
  ),
  mainPanel(
    headerPanel("Predicted Precipitation in mm: "),
    actionButton("calc", "Calculate"),
    textOutput("optext")
  )
)
#Define backend server functions
server <- function(input, output)
{
  observeEvent(input$calc,
               {
                 print("Initializing library")
                 library(sparklyr)
                 print("Creating table")
                 temp_tbl <- data.frame(
                   "Latitude" = input$Latitude,
                   "Longitude" = input$Longitude,
                   "Max_Temperature" = input$Max_Temperature,
                   "Min_Temperature" = input$Min_Temperature,
                   "Wind" = input$Wind,
                   "Relative_Humidity" = input$Relative_Humidity,
                   "Solar" = input$Solar
                 )
                 print("Connecting to local spark cluster")
                 sc <- spark_connect(master = 'local')
                 print("Creating spark dataframe")
                 userinput <-
                   copy_to(sc, temp_tbl, overwrite = TRUE)
                 print("Loading model")
                 model <-
                   ml_load(sc, "C:/Users/user/Documents/VIT/Sem 6/EDI/MODEL")
                 print("Predicting on user variables")
                 pred <- ml_predict(model, userinput) %>% collect
                 print("Done")
                 output$optext <- reactive(max(0, pred$prediction))
               })
  
}
shinyApp(ui, server) #Run app using UI and Server