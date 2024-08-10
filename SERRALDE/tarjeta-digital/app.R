library(shiny)
library(tidyverse)
library(readxl)
library(flextable)
library(DT)

# Definir la interfaz de usuario
ui <- fluidPage(
  titlePanel("Descripción de Empresa"),
  sidebarLayout(
    sidebarPanel(
      selectInput("foco", "Seleccione el RFC:", choices = NULL) # Se rellenará dinámicamente
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Empresa", uiOutput("vista_empresa")),
        tabPanel("Personal", uiOutput("vista_personal")),
        tabPanel("Uniformes", uiOutput("vista_uniformes")),
        tabPanel("Equipo", uiOutput("vista_equipo"))
      )
    )
  )
)

# Definir la lógica del servidor
server <- function(input, output, session) {
  
  # Cargar los datos iniciales
  empresas <- read_excel("/Users/cristinaalvarez/Documents/GitHub/soluciones-tec/SERRALDE/Data/empresas.xlsx")
  personal <- read_excel("/Users/cristinaalvarez/Documents/GitHub/soluciones-tec/SERRALDE/Data/personal.xlsx")
  equipo <- read_excel("/Users/cristinaalvarez/Documents/GitHub/soluciones-tec/SERRALDE/Data/equipo.xlsx")
  uniformes <- read_excel("/Users/cristinaalvarez/Documents/GitHub/soluciones-tec/SERRALDE/Data/uniformes.xlsx")
  
  # Actualizar dinámicamente las opciones de RFC
  updateSelectInput(session, "foco", choices = unique(empresas$RFC))
  
  # Crear las tablas flextable para cada sección usando renderUI
  output$vista_empresa <- renderTable({
    req(input$foco) # Requiere que se seleccione un RFC para proceder
    datos_empresas <- empresas %>% 
      filter(RFC == input$foco) %>% 
      select(EXPEDIENTE,`NOMBRE DE LA EMPRESA`,`NUMERO DE REGISTRO`,
             `DESCRIPCION DE LAS MODALIDADES AUTORIZADAS`,
             `DOMICILIO MATRIZ`, `CORREO ELECTRONICO` ) %>% 
      pivot_longer(cols = everything(), names_to = "Datos Generales", values_to = " ") %>% 
      drop_na()
    # flextable(datos_empresas) %>%
    #   theme_zebra() %>%
    #   autofit() %>%
    #   flextable_to_rmd() # Se convierte a HTML
  })
  
   output$vista_personal <- renderTable({
     req(input$foco)
     datos_personal <- personal %>%
       filter(`RFC EMPRESARIAL` == input$foco) %>%
       group_by(AREA) %>%
       summarise(INFORME_MENSUAL = sum(INFORME_MENSUAL), INSCRITOS = sum(INSCRITOS))
  #   flextable(datos_personal) %>%
  #     theme_zebra() %>%
  #     autofit() %>%
  #     flextable_to_rmd()
   })
   
   output$vista_uniformes <- renderTable({
     req(input$foco)
     datos_uniformes <- uniformes %>%
       filter(`RFC EMPRESARIAL` == input$foco) %>%
       group_by(UNIFORMES) %>%
       summarise(INFORME_MENSUAL = sum(INFORME_MENSUAL), INSCRITOS = sum(INSCRITOS))
  #   flextable(datos_uniformes) %>%
  #     theme_zebra() %>%
  #     autofit() %>%
  #     flextable_to_rmd()
   })
   
   output$vista_equipo <- renderTable({
     req(input$foco)
     datos_equipo <- equipo %>%
       filter(`RFC EMPRESARIAL` == input$foco) %>%
       group_by(EQUIPO) %>%
       summarise(INFORME_MENSUAL = sum(INFORME_MENSUAL), INSCRITOS = sum(INSCRITAS))
  #   flextable(datos_equipo) %>%
  #     theme_zebra() %>%
  #     autofit() %>%
  #     flextable_to_rmd()
   })
}

# Ejecutar la aplicación
shinyApp(ui = ui, server = server)
