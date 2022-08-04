#!pip install yfinance requests
import requests
import yfinance as yf
import pandas as pd
import matplotlib.pyplot as plt
import seaborn; seaborn.set()
from tqdm.auto import tqdm
import os
from pylab import rcParams

def calculate_prices():
    print('hello')
    seaborn.set()
    # Затраты на производство
    PRODUCTION_COST = 400 # (EUR)

    # Расходы на логистику
    EU_LOGISTIC_COST_EUR = 30 # в Европу в евро
    CN_LOGISTIC_COST_USD = 130 # в Китай в долларах
    customers = {
        'Monty':{
            'location':'EU',
            'volumes':200,
            'formula':'moving_average'
        },

        'Triangle':{
            'location':'CN',
            'volumes': 30,
            'formula': 'monthly'
        },
        'Stone':{
            'location':'EU',
            'volumes': 150,
            'formula': 'moving_average'
        },
        'Poly':{
            'location':'EU',
            'volumes': 70,
            'formula': 'monthly'
        }
    }
    discounts = {100: 0.01, 300: 0.05, 301: 0.1}
    # Подгружаем котировки курсы
    print("Подгружаем котировки и курсы")
    all_dfs = []
    for y in tqdm(['2019','2020','2021']):
        for m in ['01','02','03','04','05','06','07','08','09','10','11','12']:
            url = f"https://www.lgm.gov.my/webv2api/api/rubberprice/month={m}&year={y}"
            res = requests.get(url)
            rj = res.json()
            temp_df = pd.json_normalize(rj)
            all_dfs.append(temp_df)
    for y in tqdm(['2022']):
        for m in ['01','02','03','04','05','06','07','08']:
            url = f"https://www.lgm.gov.my/webv2api/api/rubberprice/month={m}&year={y}"
            res = requests.get(url)
            rj = res.json()
            temp_df = pd.json_normalize(rj)
            all_dfs.append(temp_df)
    # создаем датафрейм
    df = pd.concat(all_dfs)
    df_smr20 = df[df['grade'] == 'SMR 20']
    df_smr20 = df_smr20.drop(['grade','masa','rm','tone'], axis=1)
    df_smr20['date'] = pd.to_datetime(df_smr20['date'], format='%Y-%m-%d')
    df_smr20 = df_smr20.set_index('date')
    df_smr20['us'] = pd.to_numeric(df_smr20['us'])
    mean_df_smr20 = df_smr20.resample('M').mean()
    mean_df_smr20.columns = ['SMR_20_US']
    # получаем данные по курсам валют
    df_dict = {}
    for ticker in tqdm(['USDRUB=X', 'EURUSD=X', 'EURRUB=X']):
        df1 = yf.download(ticker)
        df1 = df1.Close.copy()
        df1 = df1.resample('M').mean()
        df_dict[ticker] = df1
    main_df = pd.concat(df_dict.values(), axis=1)
    main_df.columns = ['USDRUB', 'EURUSD', 'EURRUB']
    main_df = main_df.loc['2019-01-31':'2022-08-31'].copy()
    # объединяем данные с биржи валют и каучука
    main_df = mean_df_smr20.add(main_df, fill_value=0)

    # Рассчитываем цены
    print("Рассчитываем цены")
    main_df['SMR20_PRICE_EUR'] = main_df.SMR_20_US * (1/main_df.EURUSD) + 400
    main_df['SMR20_PRICE_USD'] = main_df.SMR_20_US + 400
    main_df['SMR20_PRICE_EUR_EU'] = main_df['SMR20_PRICE_EUR'] + EU_LOGISTIC_COST_EUR
    main_df['SMR20_PRICE_USD_CN'] = main_df['SMR20_PRICE_USD'] + CN_LOGISTIC_COST_USD
    main_df['SMR20_PRICE_EUR_EU_MA'] = main_df.SMR20_PRICE_EUR_EU.rolling(window=3).mean()
    rcParams['figure.figsize'] = 15,7
    # скидки
    discounts = {100: 0.01, 300: 0.05, 301: 0.1}

    
    # Создаем директорию для ценовых предложений клиентам
    price_proposals_path = 'client_wbp_price_proposals'
    if not os.path.exists(price_proposals_path):
        os.mkdir(price_proposals_path)


    # Создаем отдельный файл для каждого из клиентов


    print("Готовим отдельный файл для клиентов")
    # Создаем отдельный файл для каждого из клиентов с расчетом
    for client, v in customers.items():
        client_proposal_file_path = os.path.join(price_proposals_path, f'{client}_SMR20_price_proposal.xlsx')
        location = v.get('location')
        disc = 0.0
        if v.get('location') == "EU":
            fl = 0
            for k_lim, discount_share in discounts.items():
                if v.get('volumes') > k_lim:
                    continue
                else:
                    disc = discount_share
                    fl = 1
                    break
            if fl == 0 :
                disc = discounts.get(max(discounts.keys()))

            if v.get('formula') == 'monthly':
                client_price = main_df['SMR20_PRICE_EUR_EU'] * (1-disc) + EU_LOGISTIC_COST_EUR
            elif v.get('formula') == 'moving_average':
                client_price = main_df['SMR20_PRICE_EUR_EU_MA'] * (1-disc) + EU_LOGISTIC_COST_EUR

        elif v.get('location') == 'CN':
            fl = 0
            for k_lim, discount_share in discounts.items():
                if v.get('volumes') > k_lim:
                    continue
                else:
                    disc = discount_share
                    fl = 1
                    break
            if fl == 0 :
                disc = discounts.get(max(discounts.keys()))

            client_price = main_df['SMR20_PRICE_USD_CN'] * (1-disc) + CN_LOGISTIC_COST_USD
        with pd.ExcelWriter(client_proposal_file_path, engine='xlsxwriter') as writer:
            client_price.to_excel(writer, sheet_name='price_proposal')
            print(f"{client} готов")
            # Добавляем график с ценой
            plot_path = f'{client}_SMR20.png'
            plt.title('Цена SMR20(DDP)', fontsize=16, fontweight='bold')
            plt.plot(client_price)
            plt.savefig(plot_path)
            plt.show()
            worksheet = writer.sheets['price_proposal']
            worksheet.insert_image('C2',plot_path)
    print("Удаляем ненужные файлы")
    for k,v in customers.items():
        if os.path.exists(f"{k}_SMR20.png"):
            os.remove(f"{k}_SMR20.png")

    print("Работа завершена!")

if __name__ == "__main__":
    calculate_prices()