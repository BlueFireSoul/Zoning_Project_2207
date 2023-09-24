import os
import getpass
import sys
script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)
current_user = getpass.getuser()
sys.path.append(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise")
from config import *
import requests
import csv
import json

def read_csv_as_dict(file_path):
    data_dict = {}
    with open(file_path, 'r', newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            key = row.pop('tract_index')  # Remove 'id' column from the row and use it as the key
            data_dict[key] = row  # Store the rest of the row as the value in the dictionary
    return data_dict


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

tract_dict = read_csv_as_dict(tract_ma_2019_csv)

temp_json_file = tract_ma_matrix_json
if os.path.exists(temp_json_file):
    with open(temp_json_file, 'r') as json_file:
        tract_matrix_dict = json.load(json_file)
else:
    tract_matrix_dict = {}
    for z in ['driving','walking','transit']:
        tract_matrix_dict[z] = {}

update = False
for z in ['driving','walking','transit']:
    for x in tract_dict:
        origins = [tract_dict[x]['INTPTLAT']+','+tract_dict[x]['INTPTLON']]  
        destinations = []
        ys = []
        while True:
            for y in tract_dict:
                if len(ys) > 60:
                    continue
                if x+","+y in tract_matrix_dict[z] or y+","+x in tract_matrix_dict[z]:
                    continue
                if x == y:
                    tract_matrix_dict[z][x+","+y] = 0
                else:
                    destinations = destinations + [tract_dict[y]['INTPTLAT']+','+tract_dict[y]['INTPTLON']] 
                    ys = ys + [x+","+y]
            if not ys:
                break
            update = True
            distance_matrix = get_distance_matrix(bing_api_key, origins, destinations, z)
            if distance_matrix:
                for i in range(len(ys)):
                    tract_matrix_dict[z][ys[i]] = distance_matrix[i]['travelDuration']
            else:
                with open(temp_json_file, 'w') as json_file:
                    json.dump(tract_matrix_dict, json_file)
                print("key run out, trying new key")
                key_index += 1
                bing_api_key = bing_api_keys[key_index]
            print(ys)
            print(len(tract_matrix_dict['driving'])+len(tract_matrix_dict['walking'])+len(tract_matrix_dict['transit']))
            ys = []
            destinations = []
    if update:
        with open(temp_json_file, 'w') as json_file:
            json.dump(tract_matrix_dict, json_file)