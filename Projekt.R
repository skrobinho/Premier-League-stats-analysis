library(grid)
library(ggplot2)
library(lattice)
library(plyr)
library(viridis) 
library(dplyr)
library(plotrix)
library(data.table)


PremierLeagueStats <- read.csv(file="E:/MATI/Studia/SGH/Wizualizacja danych/Projekt/premier-league/stats.csv", header=TRUE, sep=",")

PremierLeagueStats$position <- NA
PremierLeagueStats$position <- rep(1:20, 12,nrow(PremierLeagueStats))

keeps <- c("team", "wins", "losses", "goals", "total_yel_card", "total_red_card", 
           "total_scoring_att", "ontarget_scoring_att", "att_hd_goal", "att_ibox_goal",
           "att_obox_goal", "goal_fastbreak", "clean_sheet", "goals_conceded", "saves",
           "penalty_conceded", "total_pass", "total_through_ball", "total_long_balls",
           "total_cross", "touches", "big_chance_missed", "season", "position")

for_loop <- c("wins", "losses", "goals", "total_yel_card", "total_red_card", 
              "total_scoring_att", "ontarget_scoring_att", "att_hd_goal", "att_ibox_goal",
              "att_obox_goal", "goal_fastbreak", "clean_sheet", "goals_conceded",
              "penalty_conceded", "total_pass", "total_long_balls",
              "total_cross", "touches", "position")

PremierLeagueStats <- PremierLeagueStats[keeps]

PremierLeagueStats$team <- as.factor(PremierLeagueStats$team)

PremierLeagueStatsTOP6 <- PremierLeagueStats[ which(PremierLeagueStats$team == 'Manchester United'
                                              | PremierLeagueStats$team == 'Arsenal'
                                              | PremierLeagueStats$team == 'Manchester City'
                                              | PremierLeagueStats$team == 'Chelsea'
                                              | PremierLeagueStats$team == 'Liverpool'
                                              | PremierLeagueStats$team == 'Tottenham Hotspur'), ]


PremierLeagueStatsTOP6$season <- mapvalues(PremierLeagueStatsTOP6$season, from = c('2006-2007', '2007-2008', '2008-2009', '2009-2010', 
                                           '2010-2011', '2011-2012', '2012-2013', '2013-2014', 
                                           '2014-2015', '2015-2016', '2016-2017', '2017-2018', '2018-2019'), 
                                  to = c('06-07', '07-08', '08-09', '09-10', 
                                         '10-11', '11-12', '12-13', '13-14', 
                                         '14-15', '15-16', '16-17', '17-18', '18-19'))


#Wykres zwycięstw w danym sezonie dla każdej drużyny w jednym oknie
print(
  ggplot(PremierLeagueStatsTOP6) + 
    geom_col(aes(x=season, y=wins, fill=wins))+
    facet_wrap(~ team)+
    labs(x = "Sezon", y="Liczba zwyciestw")+
    ggtitle("Liczba zwyciestw w poszczegolnych sezonach")+
    scale_y_continuous(breaks = seq(0, 38, by = 5), limits = c(0,38))+
    scale_fill_viridis(discrete = FALSE, direction = -1)+
    theme_bw()
  
) 

#Pętla tworząca oddzielny wykres zwycięstw w danym sezonie dla każdej z drużyn
for (i in seq(1,6)) {
  print(
    ggplot(subset(PremierLeagueStatsTOP6,team %in% team[i])) + 
      geom_col(aes(x=season, y=wins, fill=wins))+
      labs(x = "Sezon", y="Liczba zwyciestw")+
      ggtitle("Liczba zwyciestw w poszczegolnych sezonach")+
      scale_y_continuous(breaks = seq(0, 38, by = 5), limits = c(0,38))+
      scale_fill_viridis(discrete = FALSE, direction = -1)+
      theme_bw()
    
  )
}

#Pętla tworząca wykresy zmiennych z listy for_loop w każdym sezonie, dla każdej drużyny
for (i in seq_along(for_loop)) { 
  print(
    ggplot(PremierLeagueStatsTOP6) + 
      geom_col(aes_string(x='season', y=for_loop[i], fill=for_loop[i]))+
      facet_wrap(~ team)+
      scale_fill_viridis(discrete = FALSE, direction = -1)+
      theme_bw()
    
  ) 
}

#Dane do wykresów kołowych przedstawiających rozkłąd bramek strzelonych z pola i zza pola karnego
goals_list <- c(1,2)

for (j in seq(1,6)) {
  df2 <- subset(PremierLeagueStatsTOP6,team %in% team[j])[c("att_ibox_goal", "att_obox_goal")]
  for (i in seq(1, nrow(subset(PremierLeagueStatsTOP6,team %in% team[j])))) {
    goals_list <- c(goals_list, c(df2[i,1], df2[i,2]))
    
  }
}


goals_list <- goals_list[-c(1,2)]

goals_list <- split(goals_list, rep(1:ceiling(length(goals_list)/2), each=2)[1:length(goals_list)])

for (i in seq(1, nrow(PremierLeagueStatsTOP6))) {
  pie(goals_list[[i]], labels=c("Gole z pola karnego", "Gole zza pola karnego"), col=c("red3", "green3"))
  
}

pie(goals_list[[3]], col = c("red3", "green3"))

#Wykres pozycji każdego zespołu na przesteni sezonów
PremierLeagueStatsTOP6$position <- as.factor(PremierLeagueStatsTOP6$position)

print(
  ggplot(PremierLeagueStatsTOP6, mapping=aes(color=team)) + 
    geom_point(aes(season, position), show.legend = FALSE)+
    geom_line(aes(season, position), group=1, show.legend = FALSE)+
    facet_wrap(~ team)+
    scale_y_discrete(limits = rev(levels(PremierLeagueStatsTOP6$position)))+
    scale_fill_brewer(palette = "Set1", name = "team")+
    xlab("")+
    ylab("")+
    theme_bw()
)


#Wykresy zależności między każdą ze statystyk, a pozycją w lidze
for (i in seq_along(for_loop)) { 
  print(
    ggplot(PremierLeagueStatsTOP6, mapping=aes(color=team)) + 
      geom_point(aes_string(for_loop[i], "position"), show.legend = FALSE)+
      geom_smooth(aes_string(for_loop[i], "as.numeric(position)"), method = "lm", se=FALSE, color="black", show.legend = FALSE)+
      facet_wrap(~ team)+
      scale_y_discrete(limits = rev(levels(PremierLeagueStatsTOP6$position)))+
      scale_fill_brewer(palette = "Set1", name = "team")+
      theme_bw()
  )
}

#Wykresy liczby zwycięstw i porażek w poszczególnych sezonach, w jednym oknie
print(
  ggplot(PremierLeagueStatsTOP6) + 
    geom_point(aes(season, wins), color='green')+
    geom_line(aes(season, wins), group=1, color='green')+
    geom_point(aes(season, losses), color='red')+
    geom_line(aes(season, losses), group=1, color='red')+
    facet_wrap(~ team)+
    scale_y_continuous(breaks = seq(0, 38, by = 5), limits = c(0,38))+
    theme_bw()
)
