library(shiny)
library(shinyWidgets)


shinyUI(pageWithSidebar(
  
  headerPanel(""),
  
  sidebarPanel(
    
    #Wybor rodzaju wykresu
    selectInput("plotType", "Rodzaj wykresu",
                choices = c("Wykresy statysyk", "Wykres pozycji", "Wykresy pozycji w lidze od statystyk", "Bilans zwyciestw i porazek")),
    
    #Slider sezonow
    conditionalPanel(condition = "input.plotType == 'Wykresy statysyk'", 
                     sliderTextInput("season", "Sezony:",
                    choices = c('06-07', '07-08', '08-09', '09-10', 
                                '10-11', '11-12', '12-13', '13-14', 
                                '14-15', '15-16', '16-17', '17-18', '18-19'),
                    selected = c('07-08', '16-17'),
                    grid = TRUE)),
    
    #Wybor druzyny
    selectInput("team", "Druzyna:",
                choices=c("Arsenal", "Chelsea", "Liverpool", "Manchester City", "Manchester United", "Tottenham Hotspur")),
    
    #Wybor statystyki do wykresu
    conditionalPanel(condition = "input.plotType == 'Wykresy statysyk' | input.plotType == 'Wykresy pozycji w lidze od statystyk'", 
                     selectInput("stat", "Statystyka:",
                                 choices=c("Wygrane", "Porazki", "Bramki", "Zolte_kartki", "Czerwone_kartki",
                                           "Strzaly", "Strzaly_celne", "Bramki_z_pola_karnego",
                                           "Bramki_zza_pola_karnego", "Bramki_po_kontratakach", "Czyste_konta", "Gole_stracone",
                                           "Sprokurowane_rzuty_karne", "Liczba_podan", "Liczba_dlugich_podan",
                                           "Liczba_dosrodkowan", "Kontakty_z_pilka", "Zmarnowane_okazje"))),
    
  ),
  
  mainPanel(
    plotOutput("distPlot")
  )
))