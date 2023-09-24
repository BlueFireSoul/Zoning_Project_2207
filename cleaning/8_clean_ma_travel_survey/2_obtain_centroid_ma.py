import os
import getpass
import sys
current_user = getpass.getuser()
sys.path.append(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise")
from config import *
import geopandas as gpd
import pandas as pd
import requests
import csv
import json

block_path = f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - database/raw/tl_2010_block/tl_2010_25_tabblock10.shp"

block_shp = gpd.read_file(block_path)

block_df = block_shp[['STATEFP10','COUNTYFP10','TRACTCE10','BLOCKCE10','INTPTLAT10','INTPTLON10']]
block_df.loc[:, 'STATEFP10'] = block_df['STATEFP10'].astype(int)
block_df.loc[:, 'COUNTYFP10'] = block_df['COUNTYFP10'].astype(int)
block_df.loc[:, 'TRACTCE10'] = block_df['TRACTCE10'].astype(int)
block_df.loc[:, 'BLOCKCE10'] = block_df['BLOCKCE10'].astype(int)

block_dict = pd.read_csv(temp_dir + "block_dict.csv")
block_dict = pd.merge(block_dict, block_df, left_on=['WSTATE10', 'WCOUNTY10', 'WTRACT10', 'WBLOCK10'],
                     right_on=['STATEFP10', 'COUNTYFP10', 'TRACTCE10', 'BLOCKCE10'])
block_dict.rename(columns={'INTPTLAT10': 'wlat'}, inplace=True)
block_dict.rename(columns={'INTPTLON10': 'wlon'}, inplace=True)
block_dict.drop(columns=['STATEFP10', 'COUNTYFP10', 'TRACTCE10', 'BLOCKCE10'], inplace=True)
block_dict = pd.merge(block_dict, block_df, left_on=['HSTATE10', 'HCOUNTY10', 'HTRACT10', 'HBLOCK10'],
                     right_on=['STATEFP10', 'COUNTYFP10', 'TRACTCE10', 'BLOCKCE10'])
block_dict.drop(columns=['STATEFP10', 'COUNTYFP10', 'TRACTCE10', 'BLOCKCE10'], inplace=True)
block_dict.rename(columns={'INTPTLAT10': 'hlat'}, inplace=True)
block_dict.rename(columns={'INTPTLON10': 'hlon'}, inplace=True)
print(block_dict.columns)

def get_distance_matrix(api_key, origins, destinations, mode):
    url = "https://dev.virtualearth.net/REST/v1/Routes/DistanceMatrix"
    params = {
        "origins": ";".join(origins),
        "destinations": ";".join(destinations),
        "travelMode": mode,
        "key": api_key
    }

    try:
        response = requests.get(url, params=params)
        data = response.json()

        if response.status_code == 200 and data.get('statusCode') == 200:
            return data['resourceSets'][0]['resources'][0]['results']
        else:
            print("Error occurred: ", data.get('errorDetails', 'Unknown error'))
            return None
    except Exception as e:
        print("Error occurred:", e)
        return None
    
bing_api_keys = ["AhVC3RFSiTn4O7bSmEMbLYiG6zTGNG46p53mrZrlDDZnwPjGdNSs3ppOEtb87yhZ"]
key_index = 0
bing_api_key = bing_api_keys[key_index]

block_dict['driving'] = None
block_dict['walking'] = None
block_dict['transit'] = None

for index, row in block_dict.iterrows():
    print(index)
    origins = [row['wlat'] + ',' + row['wlon']]
    destinations = [row['hlat'] + ',' + row['hlon']]
    duration_dict = {}
    for z in ['driving', 'walking', 'transit']:
        distance_matrix = get_distance_matrix(bing_api_key, origins, destinations, z)
        duration_dict[z] = distance_matrix[0]['travelDuration']
    print(duration_dict)
    block_dict.at[index, 'driving'] = duration_dict['driving']
    block_dict.at[index, 'walking'] = duration_dict['walking']
    block_dict.at[index, 'transit'] = duration_dict['transit']

block_dict.to_csv(output_dir + 'block_survey_time.csv', index=False)
