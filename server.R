library(shiny)
library(shinyWidgets)

library(ggplot2)
library(plyr)
library(dplyr)
library(viridis) 
library(data.table)

#Wczytanie zbioru danych
PremierLeagueStats <- read.csv(file="E:/MATI/Studia/SGH/Wizualizacja danych/Projekt/premier-league/stats.csv", header=TRUE, sep=",")

#Dodanie kolumny z pozycja na koniec sezonu
PremierLeagueStats$position <- NA
PremierLeagueStats$position <- rep(1:20, 12,nrow(PremierLeagueStats))

#Lista zachowanych kolumn
keeps <- c("team", "wins", "losses", "goals", "total_yel_card", "total_red_card", 
           "total_scoring_att", "ontarget_scoring_att", "att_ibox_goal",
           "att_obox_goal", "goal_fastbreak", "clean_sheet", "goals_conceded", "saves",
           "penalty_conceded", "total_pass", "total_through_ball", "total_long_balls",
           "total_cross", "touches", "big_chance_missed", "season", "position")

PremierLeagueStats <- PremierLeagueStats[keeps]

PremierLeagueStats$team <- as.factor(PremierLeagueStats$team)

#Ograniczenie zbioru do najlepszej 6 druzyn
PremierLeagueStatsTOP6 <- PremierLeagueStats[ which(PremierLeagueStats$team == 'Manchester United'
                                                    | PremierLeagueStats$team == 'Arsenal'
                                                    | PremierLeagueStats$team == 'Manchester City'
                                                    | PremierLeagueStats$team == 'Chelsea'
                                                    | PremierLeagueStats$team == 'Liverpool'
                                                    | PremierLeagueStats$team == 'Tottenham Hotspur'), ]


#Zmiana nazw sezonow
PremierLeagueStatsTOP6$season <- mapvalues(PremierLeagueStatsTOP6$season, from = c('2006-2007', '2007-2008', '2008-2009', '2009-2010', 
                                                                                   '2010-2011', '2011-2012', '2012-2013', '2013-2014', 
                                                                                   '2014-2015', '2015-2016', '2016-2017', '2017-2018', '2018-2019'), 
                                           to = c('06-07', '07-08', '08-09', '09-10', 
                                                  '10-11', '11-12', '12-13', '13-14', 
                                                  '14-15', '15-16', '16-17', '17-18', '18-19'))

PremierLeagueStatsTOP6$position <- as.factor(PremierLeagueStatsTOP6$position)

#Zmiana nazw kolumn
setnames(PremierLeagueStatsTOP6, old = c("wins", "losses", "goals", "total_yel_card", "total_red_card",
                                          "total_scoring_att", "ontarget_scoring_att", "att_ibox_goal",
                                         "att_obox_goal", "goal_fastbreak", "clean_sheet", "goals_conceded",
                                          "penalty_conceded", "total_pass", "total_long_balls",
                                          "total_cross", "touches", "big_chance_missed", "position"), 
                                 new = c("Wygrane", "Porazki", "Bramki", "Zolte_kartki", "Czerwone_kartki",
                                          "Strzaly", "Strzaly_celne", "Bramki_z_pola_karnego",
                                         "Bramki_zza_pola_karnego", "Bramki_po_kontratakach", "Czyste_konta", "Gole_stracone",
                                          "Sprokurowane_rzuty_karne", "Liczba_podan", "Liczba_dlugich_podan",
                                          "Liczba_dosrodkowan", "Kontakty_z_pilka", "Zmarnowane_okazje", "Pozycja"))



shinyServer(function(input, output) {

  output$distPlot <- renderPlot({
    
    plot <- input$plotType
    
    #Stworzenie dynamicznej tablicy, która pozwala na stworzenie slidera z sezonami
    for (i in seq(1,13)){
      if(input$season[1] == subset(PremierLeagueStatsTOP6,team %in% input$team)$season[i]){
        index1 <- i  
      }
      if(input$season[2] == subset(PremierLeagueStatsTOP6,team %in% input$team)$season[i]){
        index2 <- i  
      }
    }
    
    sezony <- subset(PremierLeagueStatsTOP6,team %in% input$team)$season[index1:index2]
    
    if(plot == "Wykresy statysyk"){
      
      ggplot(subset(PremierLeagueStatsTOP6,team %in% input$team)[index1:index2,]) + 
      geom_col(aes_string(x='sezony', y=input$stat, fill=input$stat))+
      scale_fill_viridis(discrete = FALSE, direction = -1)+
      theme_bw()
      
    }
    
    else if(plot == "Wykres pozycji"){
      
      ggplot(subset(PremierLeagueStatsTOP6,team %in% input$team)) + 
      geom_point(aes(season, Pozycja), show.legend = FALSE)+
      geom_line(aes(season, Pozycja), group=1, show.legend = FALSE)+
      scale_y_discrete(limits = rev(levels(PremierLeagueStatsTOP6$Pozycja)))+
      theme_bw()
      
    }
    
    else if(plot == "Wykresy pozycji w lidze od statystyk"){
      
      ggplot(subset(PremierLeagueStatsTOP6,team %in% input$team)) + 
      geom_point(aes_string(input$stat, "Pozycja"), show.legend = FALSE)+
      scale_y_discrete(limits = rev(levels(PremierLeagueStatsTOP6$Pozycja)))+
      geom_smooth(aes_string(input$stat, "as.numeric(Pozycja)"), method = "lm", se=FALSE, color="black", show.legend = FALSE)+
      theme_bw()
      
    }
    
    else if(plot == "Bilans zwyciestw i porazek"){
      
      ggplot(subset(PremierLeagueStatsTOP6,team %in% input$team)) + 
        geom_point(aes(season, Wygrane), color='green')+
        geom_line(aes(season, Wygrane), group=1, color='green')+
        geom_point(aes(season, Porazki), color='red')+
        geom_line(aes(season, Porazki), group=1, color='red')+
        scale_y_continuous(breaks = seq(0, 38, by = 5), limits = c(0,38))+
        theme_bw()
      
    }
    

  })
})