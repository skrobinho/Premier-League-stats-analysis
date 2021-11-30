import os
import json
import requests
import progressbar
import pandas as pd
import numpy as np
from bs4 import BeautifulSoup

def attributes(links):
    return [link[link.rfind('/')+1:] for link in links]

def uniques(links):
    l = []
    for link in links:
        if link not in l:
            l.append(link)
    return l

def scrap_stats(dates, links):
    for date in dates.keys():

        df = pd.DataFrame()
        print(date + ':')
        bar = progressbar.ProgressBar(maxval=len(links))
        bar.start()
        for i, attribute in zip(range(len(links)), links):

            # setup
            api = 'https://footballapi.pulselive.com/football/stats/ranked/teams/' + attribute
            headers = {'Origin': 'https://www.premierleague.com'}
            params = {'page': '0', 'pageSize': '20', 'compSeasons': dates[date], 'comps': '1', 'altIds': 'true'}

            # request
            response = requests.get(api, params=params, headers=headers)
            data = json.loads(response.text)

            # parse
            teams = []
            values = []
            for team in data['stats']['content']:
                teams.append(team['owner']['name'])
                values.append(team['value'])
            series = pd.Series(values, teams, float, attribute)
            if df.index.empty:
                df = pd.DataFrame(series)
            else:
                df = df.join(series)

            # progress
            bar.update(i+1)

        bar.finish()
        print('\n')
        df.dropna(axis=1, how='all', inplace=True)
        df.fillna(0, inplace=True)
        df.to_csv('files/stats/' + date + '.csv')

def scrap_results(dates):
    bar = progressbar.ProgressBar(maxval=len(dates))
    bar.start()
    for i, date in zip(range(len(dates)), dates.keys()):
        bar.widgets[0] = date
        team_ids = get_team_ids(dates, date)
        results = get_results(dates, date, team_ids)
        bar.update(i+1)
        results.to_csv('files/results/' + date + '.csv')
    bar.finish()

def get_team_ids(dates, date):
    # setup
    api = 'https://footballapi.pulselive.com/football/compseasons/' + str(dates[date]) + '/teams'
    headers = {'Origin': 'https://www.premierleague.com'}
    
    # request
    response = requests.get(api, headers=headers)
    teams = json.loads(response.text)
    
    # parse
    team_ids = []
    for team in teams:
        team_ids.append(int(team['id']))
    team_ids = ','.join(map(str, team_ids))
    
    return team_ids
    
def get_results(dates, date, team_ids):
    # setup
    api = 'https://footballapi.pulselive.com/football/fixtures'
    headers = {'Origin': 'https://www.premierleague.com'}
    params = {'comps':'1', 'compSeasons':dates[date], 'teams':team_ids, 'page':'0', 'pageSize':'380', 'sort':'asc', 'statuses':'C', 'altIds':'true'}

    # request
    response = requests.get(api, params=params, headers=headers)
    results = json.loads(response.text)
    
    # parse
    df = pd.DataFrame(columns=['home_team', 'away_team', 'home_goals', 'away_goals', 'result'])
    for result in results['content']:
        row = []
        row.append(result['teams'][0]['team']['name'])
        row.append(result['teams'][1]['team']['name'])
        row.append(result['teams'][0]['score'])
        row.append(result['teams'][1]['score'])
        row.append(result['outcome'])
        row = pd.Series(row, index=df.columns)
        df = df.append(row, ignore_index=True)
    
    return df

def csv_concatenation():
    files = ['2006-2007.csv', '2007-2008.csv', '2008-2009.csv', '2009-2010.csv', '2010-2011.csv', '2011-2012.csv', '2012-2013.csv', '2013-2014.csv', '2014-2015.csv', '2015-2016.csv', '2016-2017.csv', '2017-2018.csv', '2018-2019.csv']

    stats_df = pd.DataFrame()
    results_df = pd.DataFrame()
    for name in files:
        
        # Stats
        f = 'files/stats/' + name
        stats_series = pd.Series([name[:-4]]*20, name='season')
        stats_season = pd.concat([pd.read_csv(f, index_col=False), stats_series], axis=1)
        columns = stats_season.columns.tolist()
        columns[0] = 'team'
        stats_season.columns = columns
        if stats_df.empty:
            stats_df = stats_season
        else:
            stats_df = pd.concat([stats_df, stats_season])
            
        # Results
        f = 'files/results/' + name
        results_series = pd.Series([name[:-4]]*380, name='season')
        results_season = pd.concat([pd.read_csv(f), results_series], axis=1)
        if results_df.empty:
            results_df = results_season
        else:
            results_df = pd.concat([results_df, results_season])
        
    stats_df = stats_df[stats_season.columns.tolist()]
    stats_df.to_csv('files/stats/stats.csv', index=False)

    results_df.drop(results_df.columns[0], axis=1, inplace=True)
    results_df.to_csv('files/results/results.csv', index=False)

def main():
    webpage = requests.get('https://www.premierleague.com/stats/top/clubs/wins?se=79')
    soup = BeautifulSoup(webpage.text, 'html.parser')

    if not os.path.exists('files'):
        os.makedirs('files/stats')
        os.makedirs('files/results')

    top = [link['href'] for link in soup.select('a.topStatsLink')]
    more = [link['href'] for link in soup.select('nav.moreStatsMenu a')]
    links = uniques(attributes(more) + attributes(top))

    dates = {'2006-2007':15, '2007-2008':16, '2008-2009':17, '2009-2010':18, 
         '2010-2011':19, '2011-2012':20, '2012-2013':21, '2013-2014':22, 
         '2014-2015':27, '2015-2016':42, '2016-2017':54, '2017-2018':79, 
         '2018-2019':210}

    print("Scraping stats:")
    scrap_stats(dates, links)
    print("Scraping results:")
    scrap_results(dates)

    csv_concatenation()

if __name__ == "__main__":
    main()


